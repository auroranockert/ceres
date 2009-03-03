//
//  CharacterFuture.m
//  This file is part of Ceres.
//
//  Ceres is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Ceres is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Ceres.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Jens Nockert on 3/3/09.
//

#import "CharacterFuture.h"

@interface CharacterFuture (Private)

- (void) increment;

@end

@implementation CharacterFuture

- (id) initWithCharacter: (Character *) c
{
  if (self = [super init]) {
    character = c;
    complete = 0;
    
    if ([[character cachedUntil] timeIntervalSinceNow] < 0) {
      [[character api] request: @"char/CharacterSheet.xml.aspx" target: self selector: @selector(updateCharacterSheet:)];
    }
    else {
      [self increment];
    }
    
    if ([[character trainingCachedUntil] timeIntervalSinceNow] < 0) {
      [[character api] request: @"char/SkillInTraining.xml.aspx" target: self selector: @selector(updateTrainingSkill:)];
    }
    else {
      [self increment];
    }
  }
  
  return self;
}

- (void) increment
{
  complete += 1;
  
  if (complete == 2) {
    [self notify];
    [self setOperationComplete: true];
  }
}
     
- (void) updateCharacterSheet: (IOFuture *) future 
{
  NSError * error = nil;
  NSXMLDocument * document = [[NSXMLDocument alloc] initWithData: [future result] options: 0 error: &error];
  
  if (!document) {
    NSLog(@"No character sheet xml available");
    return;
  }
  
  [character setCachedUntil: [document cachedUntil]];
  
  [character setName: [[document readNode: @"/eveapi/result/name"] stringValue]];
  [character setRace: [[document readNode: @"/eveapi/result/race"] stringValue]];
  [character setBloodline: [[document readNode: @"/eveapi/result/bloodLine"] stringValue]];
  [character setGender: [[document readNode: @"/eveapi/result/gender"] stringValue]];
  
  NSNumber * intelligence = [[document readNode: @"/eveapi/result/attributes/intelligence"]  numberValueInteger];
  NSNumber * memory = [[document readNode: @"/eveapi/result/attributes/memory"]  numberValueInteger];
  NSNumber * charisma = [[document readNode: @"/eveapi/result/attributes/charisma"]  numberValueInteger];
  NSNumber * perception = [[document readNode: @"/eveapi/result/attributes/perception"]  numberValueInteger];
  NSNumber * willpower = [[document readNode: @"/eveapi/result/attributes/willpower"]  numberValueInteger];
  
  [character setBaseAttributes: [[Attributes alloc] init: intelligence : perception : charisma : memory : willpower]];      
  
  [character setCorporationIdentifier: [[document readNode: @"/eveapi/result/corporationID"] numberValueInteger]];
  [character setCorporationName: [[document readNode: @"/eveapi/result/corporationName"] stringValue]];
  
  [character setBalance: [[document readNode: @"/eveapi/result/balance"] numberValueDouble]];
  [character setClone: [Clone findWithName: [[document readNode: @"/eveapi/result/cloneName"] stringValue]]];
  
  if (![character currentImplantSet]) {
    [character setCurrentImplantSet: [[ImplantSet alloc] init]];
  }
  
  ImplantSet * current = [character currentImplantSet];
  
  [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/intelligenceBonus/augmentatorName"]  stringValue]]];
  [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/memoryBonus/augmentatorName"]  stringValue]]];
  [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/charismaBonus/augmentatorName"]  stringValue]]];
  [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/perceptionBonus/augmentatorName"]  stringValue]]];
  [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/willpowerBonus/augmentatorName"]  stringValue]]];
  
  NSArray * skills = [document readNodes: @"/eveapi/result/rowset[@name='skills']/row"];
  for (NSXMLNode * skill in skills)
  {
    TrainedSkill * ts = [[TrainedSkill alloc] initWithCharacter: character skill: [Skill findWithIdentifier: [NSNumber numberWithInteger: [[skill readAttribute: @"typeID"] integerValue]]]];
    [ts setSkillpoints: [NSNumber numberWithInteger: [[skill readAttribute: @"skillpoints"] integerValue]]];
    [ts setLevel: [NSNumber numberWithInteger: [[skill readAttribute: @"level"] integerValue]]];
  }
  
  [character setSkillpoints: [character valueForKeyPath: @"skills.@sum.skillpoints"]];
  [character updateSkillGroups];
  
  [self increment];
  
  [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: character name: @"updatedCharacter"]];
}

- (void) updateTrainingSkill: (IOFuture *) future
{
  NSError * error = nil;
  NSXMLDocument * document = [[NSXMLDocument alloc] initWithData: [future result] options: 0 error: &error];
  
  if (!document) {
    NSLog(@"No skill training xml available");
    return;
  }
  
  [character setTrainingCachedUntil: [document cachedUntil]];
  
  if ([[document readNode: @"/eveapi/result/skillInTraining"] integerValue])
  {
    NSString * startTimeString = [[[document readNode: @"/eveapi/result/trainingStartTime"] stringValue] stringByAppendingString: @" +0000"];      
    NSDate * startDate = [[NSDate alloc] initWithString: startTimeString];
    
    if (![character trainingStartedAt] || ![character trainingSkill] || [startDate compare: [character trainingStartedAt]] != NSOrderedSame) {
      [character updateSkillpoints];
      
      [character setTrainingStartedAt: startDate];
      
      NSString * endTimeString = [[[document readNode: @"/eveapi/result/trainingEndTime"] stringValue] stringByAppendingString: @" +0000"];
      [character setTrainingEndsAt: [[NSDate alloc] initWithString: endTimeString]];
      
      NSNumber * skillIdentifer = [[document readNode: @"/eveapi/result/trainingTypeID"] numberValueInteger];
      TrainedSkill * skill = [[TrainedSkill alloc] initWithCharacter: character skill: [Skill findWithIdentifier: skillIdentifer]];
      [skill setSkillpoints: [[document readNode: @"/eveapi/result/trainingStartSP"] numberValueInteger]];
      [skill setLevel: [[[document readNode: @"/eveapi/result/trainingToLevel"] numberValueInteger] previous]];

      [character setTrainingSkill: skill];
    }
  }
  else {
    if ([character trainingSkill]) {
      [character updateSkillpoints];
      [character setTrainingSkill: nil];
    }
  }
  
  [self increment];
  
  [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: character name: @"updatedTraining"]];
  
  if ([character trainingSkill]) {
    [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: character name: @"skillTrainingCompleted"] date: [character trainingEndsAt]];
  }
}

@end

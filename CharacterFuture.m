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
    
    if ([[character queueCachedUntil] timeIntervalSinceNow] < 0) {
      [[character api] request: @"char/SkillQueue.xml.aspx" target: self selector: @selector(updateSkillQueue:)];
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
  
  [character setBaseIntelligence: [[document readNode: @"/eveapi/result/attributes/intelligence"]  numberValueInteger]];
  [character setBaseMemory: [[document readNode: @"/eveapi/result/attributes/memory"]  numberValueInteger]];
  [character setBaseCharisma: [[document readNode: @"/eveapi/result/attributes/charisma"]  numberValueInteger]];
  [character setBasePerception: [[document readNode: @"/eveapi/result/attributes/perception"]  numberValueInteger]];
  [character setBaseWillpower: [[document readNode: @"/eveapi/result/attributes/willpower"]  numberValueInteger]];
    
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
  
  [character setBaseSkillpoints: [character valueForKeyPath: @"skills.@sum.skillpoints"]];
  [character updateSkillGroups];
  
  [self increment];
  
  [[CeresNotificationCenter instance] postNotification: [CharacterNotification notificationWithCharacter: character name: @"updatedCharacter"]];
}

- (void) updateSkillQueue: (IOFuture *) future
{
  NSError * error = nil;
  NSXMLDocument * document = [[NSXMLDocument alloc] initWithData: [future result] options: 0 error: &error];
  
  if (!document) {
    NSLog(@"No skill queue xml available");
    return;
  }
  
  [character setQueueCachedUntil: [document cachedUntil]];
  [character clearSkillQueue];
  
  NSArray * skills = [document readNodes: @"/eveapi/result/skill"];
  
  for (NSXMLNode * skill in skills)
  {
    TrainedSkill * ts = [[TrainedSkill alloc] initWithCharacter: character skill: [Skill findWithIdentifier: [[skill readNode: @"/typeID"] numberValueInteger]]];
    [ts setSkillpoints: [[skill readNode: @"/startSP"] numberValueInteger]];
    [ts setLevel: [[[skill readNode: @"/level"] numberValueInteger] previous]];
    
    SkillQueueEntry * entry = [[SkillQueueEntry alloc] init];

    NSString * startTimeString = [[[skill readNode: @"/startTime"] stringValue] stringByAppendingString: @" +0000"];      
    [entry setStartsAt: [[NSDate alloc] initWithString: startTimeString]];
    
    NSString * endTimeString = [[[skill readNode: @"/endTime"] stringValue] stringByAppendingString: @" +0000"];
    [entry setEndsAt: [[NSDate alloc] initWithString: endTimeString]];
    
    [entry setOrder: [[skill readNode: @"/queuePosition"] numberValueInteger]];
    [entry setTrainedSkill: ts];
    [entry setCharacter: character];
  }
  
  [character setBaseSkillpoints: [character valueForKeyPath: @"skills.@sum.skillpoints"]];
  
  [self increment];
  
  [[CeresNotificationCenter instance] postNotification: [CharacterNotification notificationWithCharacter: character name: @"updatedTraining"]];
  
  if ([character currentlyTraining]) {
    [[CeresNotificationCenter instance] postNotification: [CharacterNotification notificationWithCharacter: character name: @"skillTrainingCompleted"] date: [[character currentSkillQueueEntry] endsAt]];
  }
}

@end

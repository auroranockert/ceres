//
//  Character.m
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
//  Created by Jens Nockert on 12/8/08.
//

#import "Character.h"


@implementation Character

@synthesize implants;

@dynamic balance, race, bloodline, gender;
@dynamic account, clone, baseAttributes;

@dynamic corporationIdentifier, corporationName;

@dynamic training, trainingToLevel, trainingSkillpointsStart, trainingSkillpointsEnd;
@dynamic trainingStartedAt, trainingEndsAt, trainingCachedUntil;
@dynamic trainingSkill;

@dynamic portraitData;


- (id) initWithIdentifier: (NSNumber *) ident
                  account: (Account *) acc
{
  if (self = [super initWithIdentifier: ident]) {
    [self setAccount: acc];
  
    [self invalidate];
    [self update];
  }
  
  return self;
}

- (NSNumber *) intelligence
{
  return [[self baseAttributes] intelligence];
}

- (NSNumber *) perception
{
  return [[self baseAttributes] perception];
}

- (NSNumber *) charisma
{
  return [[self baseAttributes] charisma];
}

- (NSNumber *) willpower
{
  return [[self baseAttributes] willpower];
}

- (NSNumber *) memory
{
  return [[self baseAttributes] memory];
}

- (CorporationInfo *) corporation
{
  return [[CorporationInfo alloc] initWithIdentifier: [self corporationIdentifier] name: [self corporationName]];
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Character"];
  }
  
  return entityDescription;
}

- (Api *) initializeApi
{
  return [[Api alloc] initWithIdentifier: [[self account] identifier] apikey: [[self account] apikey] characterIdentifier: [self identifier]];
}

- (CharacterInfo *) characterInfo
{
  return [[CharacterInfo alloc] initWithIdentifier: [self identifier] name: [self name] corporation: [self corporation] account: [self account]];
}

- (NSImage *) portrait
{
  return [[NSImage alloc] initWithData: [self portraitData]];
}

- (NSNumber *) trainingCurrentSkillpoints
{
  NSInteger skillTime = [[self trainingStartedAt] timeIntervalSinceReferenceDate] - [[self trainingEndsAt] timeIntervalSinceReferenceDate];
  NSInteger currentDifference = -[[self trainingStartedAt] timeIntervalSinceNow];
  double percentage = (double)currentDifference / skillTime;
  
  NSInteger skillSP = [[self trainingSkillpointsStart] integerValue] - [[self trainingSkillpointsEnd] integerValue];
  
  return [NSNumber numberWithInteger: [[self trainingSkillpointsStart] integerValue] + [[NSNumber numberWithDouble: (skillSP * percentage)] integerValue]];
}

- (void) update
{
  bool updatedPortrait = false;
  bool updatedCharacter = false;
  bool updatedTraining = false;
  
  if(![self portraitData]) {
    updatedPortrait = true;
    [self setPortraitData: [[[self api] requestImage: [self identifier]] TIFFRepresentation]];
  }
  
  if([[self cachedUntil] timeIntervalSinceNow] < 0)
  {
    NSXMLDocument * document = [[self api] request: @"char/CharacterSheet.xml.aspx"];
    [self setCachedUntil: [document cachedUntil]];
    
    if (![self name]) {
      [self setName: [[document readNode: @"/eveapi/result/name"] stringValue]];
      [self setRace: [[document readNode: @"/eveapi/result/race"] stringValue]];
      [self setBloodline: [[document readNode: @"/eveapi/result/bloodLine"] stringValue]];
      [self setGender: [[document readNode: @"/eveapi/result/gender"] stringValue]];
      
      updatedCharacter = true;
    }
    
    NSNumber * corporationIdentifier = [NSNumber numberWithInteger: [[document readNode: @"/eveapi/result/corporationID"] integerValue]];
    
    if ([[self corporationIdentifier] compare: corporationIdentifier] != NSOrderedSame) {
      [self setCorporationIdentifier: corporationIdentifier];
      [self setCorporationName: [[document readNode: @"/eveapi/result/corporationName"] stringValue]];
      
      updatedCharacter = true;
    }
    
    NSNumber * balance = [[document readNode: @"/eveapi/result/balance"] numberValueDouble];
    if (![self balance] || [[self balance] compare: balance] != NSOrderedSame) {
      [self setBalance: balance];
      
      updatedCharacter = true;
    }
    
    Clone * clone = [Clone findWithName: [[document readNode: @"/eveapi/result/cloneName"] stringValue]];
    if (![self clone] || [self clone] == clone) {
      [self setClone: clone];
    }
    
    if (![self baseAttributes]) {
      NSNumber * intelligence = [[document readNode: @"/eveapi/result/attributes/intelligence"]  numberValueInteger];
      NSNumber * memory = [[document readNode: @"/eveapi/result/attributes/memory"]  numberValueInteger];
      NSNumber * charisma = [[document readNode: @"/eveapi/result/attributes/charisma"]  numberValueInteger];
      NSNumber * perception = [[document readNode: @"/eveapi/result/attributes/perception"]  numberValueInteger];
      NSNumber * willpower = [[document readNode: @"/eveapi/result/attributes/willpower"]  numberValueInteger];
      
      [self setBaseAttributes: [[Attributes alloc] init: intelligence : charisma : perception : memory : willpower]];
      updatedCharacter = true;
    }
    
    [[Ceres instance] notificationCenter];
    [[Ceres instance] save];
  }
  
  if([[self trainingCachedUntil] timeIntervalSinceNow] < 0) {
    NSXMLDocument * document = [[self api] request: @"char/SkillInTraining.xml.aspx"];
    
    [self setTrainingCachedUntil: [document cachedUntil]];
    
    int trainingInt = [[document readNode: @"/eveapi/result/skillInTraining"] integerValue];
    
    [self setTraining: [NSNumber numberWithBool: (trainingInt == 1)]];
    
    if ([[self training] boolValue])
    {
      NSString * startTimeString = [[[document readNode: @"/eveapi/result/trainingStartTime"] stringValue] stringByAppendingString: @" +0000"];      
      NSDate * startDate = [[NSDate alloc] initWithString: startTimeString];
      
      if (![self trainingStartedAt] || [startDate compare: [self trainingStartedAt]] != NSOrderedSame) {
        [self setTrainingStartedAt: startDate];
        
        NSString * endTimeString = [[[document readNode: @"/eveapi/result/trainingEndTime"] stringValue] stringByAppendingString: @" +0000"];
        [self setTrainingEndsAt: [[NSDate alloc] initWithString: endTimeString]];
        
        NSNumber * skillIdentifer = [NSNumber numberWithInteger: [[document readNode: @"/eveapi/result/trainingTypeID"] integerValue]];
        [self setTrainingSkill: [Skill findWithIdentifier: skillIdentifer]];
        [self setTrainingToLevel: [NSNumber numberWithInteger: [[document readNode: @"/eveapi/result/trainingToLevel"] integerValue]]];
        [self setTrainingSkillpointsStart: [NSNumber numberWithInteger: [[document readNode: @"/eveapi/result/trainingStartSP"] integerValue]]];
        [self setTrainingSkillpointsEnd: [NSNumber numberWithInteger: [[document readNode: @"/eveapi/result/trainingDestinationSP"] integerValue]]];
        
        updatedTraining = true;
      }
    }
    
    if (updatedPortrait || updatedCharacter) {
      [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"updatedCharacter"]];
    }
    
    if (updatedTraining) {
      [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"updatedTraining"]];
      [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"skillTrainingCompleted"] date: [self trainingEndsAt]];
    }
    
    [[Ceres instance] save];
  }
}

- (void) prepareMessages
{
  if ([self trainingSkill]) {
    [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"skillTrainingCompleted"] date: [self trainingEndsAt]];
  }
}

- (void) invalidate
{
  [self setCachedUntil: [[NSDate alloc] initWithTimeIntervalSinceNow: -1]];
  [self setTrainingCachedUntil: [[NSDate alloc] initWithTimeIntervalSinceNow: -1]];
}
      
@end
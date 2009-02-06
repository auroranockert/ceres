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

@dynamic balance, race, bloodline, gender;
@dynamic account, clone, baseAttributes;

@dynamic corporationIdentifier, corporationName;

@dynamic trainingToLevel, trainingSkillpointsEnd;
@dynamic trainingStartedAt, trainingEndsAt, trainingCachedUntil;
@dynamic trainingSkill;

@dynamic currentImplantSet;

@dynamic portraitData;

@dynamic skills, skillpoints;


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

- (double) learningBonus
{
  TrainedSkill * learning = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Learning"]];
  return 1.0 + 0.02 * [[learning level] integerValue];
}

- (NSNumber *) intelligence
{
  return [NSNumber numberWithDouble: ([[[self baseAttributes] intelligence] integerValue] + [[[self skillAttributes] intelligence] integerValue] + [[[self implantAttributes] intelligence] integerValue]) * [self learningBonus]];
}

- (NSNumber *) perception
{
  return [NSNumber numberWithDouble: ([[[self baseAttributes] perception] integerValue] + [[[self skillAttributes] perception] integerValue] + [[[self implantAttributes] perception] integerValue]) * [self learningBonus]];
}

- (NSNumber *) charisma
{
  return [NSNumber numberWithDouble: ([[[self baseAttributes] charisma] integerValue] + [[[self skillAttributes] charisma] integerValue] + [[[self implantAttributes] charisma] integerValue]) * [self learningBonus]];
}

- (NSNumber *) willpower
{
  return [NSNumber numberWithDouble: ([[[self baseAttributes] willpower] integerValue] + [[[self skillAttributes] willpower] integerValue] + [[[self implantAttributes] willpower] integerValue]) * [self learningBonus]];
}

- (NSNumber *) memory
{
  return [NSNumber numberWithDouble: ([[[self baseAttributes] memory] integerValue] + [[[self skillAttributes] memory] integerValue] + [[[self implantAttributes] memory] integerValue]) * [self learningBonus]];
}

- (Attributes *) skillAttributes
{
  NSInteger intelligence, perception, charisma, willpower, memory;

  TrainedSkill * analyticalMind = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Analytical Mind"]];
  TrainedSkill * logic = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Logic"]];
  intelligence = [[analyticalMind level] integerValue] + [[logic level] integerValue];
  
  TrainedSkill * spatialAwareness = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Spatial Awareness"]];
  TrainedSkill * clarity = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Clarity"]];
  perception = [[spatialAwareness level] integerValue] +  [[clarity level] integerValue];
  
  TrainedSkill * empathy = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Empathy"]];
  TrainedSkill * presence = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Presence"]];
  charisma = [[empathy level] integerValue] + [[presence level] integerValue];
  
  TrainedSkill * ironWill = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Iron Will"]];
  TrainedSkill * focus = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Focus"]];
  willpower = [[ironWill level] integerValue] + [[focus level] integerValue];
  
  TrainedSkill * instantRecall = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Instant Recall"]];
  TrainedSkill * eideticMemory = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Eidetic Memory"]];
  memory = [[instantRecall level] integerValue] +  [[eideticMemory level] integerValue];
  
  return [[Attributes alloc] initWithoutCoreData: [NSNumber numberWithUnsignedInteger: intelligence] : [NSNumber numberWithUnsignedInteger: perception] : [NSNumber numberWithUnsignedInteger: charisma] : [NSNumber numberWithUnsignedInteger: memory] : [NSNumber numberWithUnsignedInteger: willpower]];
}

- (Attributes *) implantAttributes
{
  NSNumber * intelligenceImplant = [[self currentImplantSet] bonusForAttribute: @"Intelligence"];
  NSNumber * perceptionImplant = [[self currentImplantSet] bonusForAttribute: @"Perception"];
  NSNumber * charismaImplant = [[self currentImplantSet] bonusForAttribute: @"Charisma"];
  NSNumber * willpowerImplant = [[self currentImplantSet] bonusForAttribute: @"Willpower"];
  NSNumber * memoryImplant = [[self currentImplantSet] bonusForAttribute: @"Memory"];

  return [[Attributes alloc] initWithoutCoreData: intelligenceImplant : perceptionImplant : charismaImplant : memoryImplant : willpowerImplant];
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

- (NSNumber *) additionalSkillpoints
{
  NSInteger skillTime = [[self trainingStartedAt] timeIntervalSinceReferenceDate] - [[self trainingEndsAt] timeIntervalSinceReferenceDate];
  NSInteger currentDifference = [[self trainingStartedAt] timeIntervalSinceNow];
  double percentage = (double)currentDifference / skillTime;
  
  return [NSNumber numberWithDouble: ([[[self trainingSkill] requiredSkillpointsForNextLevel] integerValue] * percentage)];
}

- (NSNumber *) trainingCurrentSkillpoints
{
  return [NSNumber numberWithInteger: [[[self trainingSkill] skillpoints] integerValue] + [[self additionalSkillpoints] integerValue]];
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
      
      NSNumber * intelligence = [[document readNode: @"/eveapi/result/attributes/intelligence"]  numberValueInteger];
      NSNumber * memory = [[document readNode: @"/eveapi/result/attributes/memory"]  numberValueInteger];
      NSNumber * charisma = [[document readNode: @"/eveapi/result/attributes/charisma"]  numberValueInteger];
      NSNumber * perception = [[document readNode: @"/eveapi/result/attributes/perception"]  numberValueInteger];
      NSNumber * willpower = [[document readNode: @"/eveapi/result/attributes/willpower"]  numberValueInteger];
      
      [self setBaseAttributes: [[Attributes alloc] init: intelligence : perception : charisma : memory : willpower]];      
      
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
    
    if (![self currentImplantSet]) {
      [self setCurrentImplantSet: [[ImplantSet alloc] init]];
    }
    
    ImplantSet * current = [self currentImplantSet];
    
    [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/intelligenceBonus/augmentatorName"]  stringValue]]];
    [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/memoryBonus/augmentatorName"]  stringValue]]];
    [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/charismaBonus/augmentatorName"]  stringValue]]];
    [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/perceptionBonus/augmentatorName"]  stringValue]]];
    [current replaceImplant: [Implant findWithName: [[document readNode: @"/eveapi/result/attributeEnhancers/willpowerBonus/augmentatorName"]  stringValue]]];
    
    NSArray * skills = [document readNodes: @"/eveapi/result/rowset[@name='skills']/row"];
    for (NSXMLNode * skill in skills)
    {
      TrainedSkill * ts = [[TrainedSkill alloc] initWithCharacter: self skill: [Skill findWithIdentifier: [NSNumber numberWithInteger: [[skill readAttribute: @"typeID"] integerValue]]]];
      [ts setSkillpoints: [NSNumber numberWithInteger: [[skill readAttribute: @"skillpoints"] integerValue]]];
      [ts setLevel: [NSNumber numberWithInteger: [[skill readAttribute: @"level"] integerValue]]];
    }
    
    [self updateSkillpoints];
  }
  
  if([[self trainingCachedUntil] timeIntervalSinceNow] < 0) {
    NSXMLDocument * document = [[self api] request: @"char/SkillInTraining.xml.aspx"];
    
    [self setTrainingCachedUntil: [document cachedUntil]];
    
    if ([[document readNode: @"/eveapi/result/skillInTraining"] integerValue])
    {
      NSString * startTimeString = [[[document readNode: @"/eveapi/result/trainingStartTime"] stringValue] stringByAppendingString: @" +0000"];      
      NSDate * startDate = [[NSDate alloc] initWithString: startTimeString];
      
      if (![self trainingStartedAt] || ![self trainingSkill] || [startDate compare: [self trainingStartedAt]] != NSOrderedSame) {
        [self updateSkillpoints];
        [[self trainingSkill] setTraining: [NSNumber numberWithBool: false]];
        [self setTrainingStartedAt: startDate];

        NSString * endTimeString = [[[document readNode: @"/eveapi/result/trainingEndTime"] stringValue] stringByAppendingString: @" +0000"];
        [self setTrainingEndsAt: [[NSDate alloc] initWithString: endTimeString]];
        
        NSNumber * skillIdentifer = [NSNumber numberWithInteger: [[document readNode: @"/eveapi/result/trainingTypeID"] integerValue]];
        TrainedSkill * skill = [TrainedSkill findWithCharacter: self skill: [Skill findWithIdentifier: skillIdentifer]];
        [self setTrainingSkill: skill];
        
        [[self trainingSkill] setSkillpoints: [NSNumber numberWithInteger: [[document readNode: @"/eveapi/result/trainingStartSP"] integerValue]]];
        [[self trainingSkill] setTraining: [NSNumber numberWithBool: true]];
        
        updatedTraining = true;
      }
    }
    else {
      if ([self trainingSkill]) {
        [self updateSkillpoints];
        
        [[self trainingSkill] setTraining: false];
        
        [self setTrainingSkill: nil];
        
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

- (void) updateSkillpoints
{
  [[self trainingSkill] setSkillpoints: [NSNumber numberWithInteger: [[[self trainingSkill] skillpoints] integerValue] + [[self additionalSkillpoints] integerValue]]];
  [self setSkillpoints: [self valueForKeyPath: @"skills.@sum.skillpoints"]];
}

- (NSNumber *) totalSkillpoints
{
  return [NSNumber numberWithInteger: [[self skillpoints] integerValue] + [[self additionalSkillpoints] integerValue]];
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

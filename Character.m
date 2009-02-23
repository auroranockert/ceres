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

@dynamic order;

@dynamic balance, race, bloodline, gender;
@dynamic account, clone, baseAttributes;

@dynamic corporationIdentifier, corporationName;

@dynamic trainingToLevel, trainingSkillpointsEnd;
@dynamic trainingStartedAt, trainingEndsAt, trainingCachedUntil;
@dynamic trainingSkill;

@dynamic currentImplantSet;

@dynamic portraitData;

@dynamic skills, skillpoints;

@synthesize skillGroups;


- (id) initWithIdentifier: (NSNumber *) ident
                  account: (Account *) acc
{
  if (self = [super initWithIdentifier: ident]) {
    [self setAccount: acc];
  
    
    [self setOrder: [NSNumber numberWithInteger: [[Character find] count]]];
        
    [self invalidate];
    [self update];
        
    [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"characterAdded"]];
  }
  
  return self;
}

- (double) learningBonus
{
  TrainedSkill * ts = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Learning"]];
  return 1.0 + 0.02 * [[ts level] integerValue];
}

- (NSNumber *) attribute: (NSString *) name
{
  if ([name compare: @"Intelligence"] == NSOrderedSame) {
    return [self intelligence];
  }
  else if ([name compare: @"Perception"] == NSOrderedSame) {
    return [self perception];
  }
  else if ([name compare: @"Charisma"] == NSOrderedSame) {
    return [self charisma];
  }
  else if ([name compare: @"Willpower"] == NSOrderedSame) {
    return [self willpower];
  }
  else if ([name compare: @"Memory"] == NSOrderedSame) {
    return [self memory];
  }
  else {
    return nil;
  }
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
  NSNumber * intelligence, * perception, * charisma, * willpower, * memory;

  TrainedSkill * analyticalMind = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Analytical Mind"]];
  TrainedSkill * logic = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Logic"]];
  intelligence = [[analyticalMind level] addInteger: [logic level]];
  
  TrainedSkill * spatialAwareness = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Spatial Awareness"]];
  TrainedSkill * clarity = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Clarity"]];
  perception = [[spatialAwareness level] addInteger: [clarity level]];
  
  TrainedSkill * empathy = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Empathy"]];
  TrainedSkill * presence = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Presence"]];
  charisma = [[empathy level] addInteger: [presence level]];
  
  TrainedSkill * ironWill = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Iron Will"]];
  TrainedSkill * focus = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Focus"]];
  willpower = [[ironWill level] addInteger: [focus level]];
  
  TrainedSkill * instantRecall = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Instant Recall"]];
  TrainedSkill * eideticMemory = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Eidetic Memory"]];
  memory = [[instantRecall level] addInteger: [eideticMemory level]];
  
  return [[Attributes alloc] initWithoutCoreData: intelligence : perception : charisma : memory : willpower];
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

- (NSNumber *) skillpointsForGroup: (Group *) group
{
  NSNumber * sp = [[[self skills] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"skill.group == %@", group]] valueForKeyPath: @"@sum.skillpoints"];
  if (group = [[[self trainingSkill] skill] group]) {
    sp = [sp addInteger: [self additionalSkillpoints]];
  }
  
  return sp;
}

- (NSNumber *) skillsForGroup: (Group *) group
{
  return [NSNumber numberWithInteger: [[[self skills] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"skill.group == %@", group]] count]];
}

- (void) update
{  
  if(![self portraitData]) {
    [self setPortraitData: [[[self api] requestImage: [self identifier]] TIFFRepresentation]];
  }
  
  bool updatedCharacterSheet = [self updateCharacterSheet];
  bool updatedTrainingSkill = [self updateTrainingSkill];
      
    
  if (updatedCharacterSheet) {
    [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"updatedCharacter"]];
  }
  
  if (updatedTrainingSkill) {
    [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"updatedTraining"]];
    
    if ([self trainingSkill]) {
      [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"skillTrainingCompleted"] date: [self trainingEndsAt]];
    }
    else {
      [[Ceres instance] cancelNotification: [CharacterNotification notificationWithCharacter: self name: @"skillTrainingCompleted"]];
    }
  }
  
  [[Ceres instance] save];
}

- (bool) updateCharacterSheet
{
  if([[self cachedUntil] timeIntervalSinceNow] < 0) {
    NSXMLDocument * document = [[self api] request: @"char/CharacterSheet.xml.aspx"];
    
    if (!document) {
      NSLog(@"No character sheet xml available");
      return false;
    }
    
    [self setCachedUntil: [document cachedUntil]];
    
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
    
    [self setCorporationIdentifier: [[document readNode: @"/eveapi/result/corporationID"] numberValueInteger]];
    [self setCorporationName: [[document readNode: @"/eveapi/result/corporationName"] stringValue]];
    
    [self setBalance: [[document readNode: @"/eveapi/result/balance"] numberValueDouble]];
    [self setClone: [Clone findWithName: [[document readNode: @"/eveapi/result/cloneName"] stringValue]]];
    
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
    
    [self setSkillpoints: [self valueForKeyPath: @"skills.@sum.skillpoints"]];
    [self updateSkillGroups];
    
    return true;
  }
    
  return false;
}
    
- (bool) updateTrainingSkill
{
  bool updatedTraining = false;
  
  if([[self trainingCachedUntil] timeIntervalSinceNow] < 0) {
    NSXMLDocument * document = [[self api] request: @"char/SkillInTraining.xml.aspx"];
    
    if (!document) {
      NSLog(@"No skill training xml available");
      return false;
    }
    
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
        
        NSNumber * skillIdentifer = [[document readNode: @"/eveapi/result/trainingTypeID"] numberValueInteger];
        TrainedSkill * skill = [TrainedSkill findWithCharacter: self skill: [Skill findWithIdentifier: skillIdentifer]];
        [self setTrainingSkill: skill];
        
        [[self trainingSkill] setSkillpoints: [[document readNode: @"/eveapi/result/trainingStartSP"] numberValueInteger]];
        [[self trainingSkill] setLevel: [[[document readNode: @"/eveapi/result/trainingToLevel"] numberValueInteger] previous]] ;
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
  }
  
  return updatedTraining;
}
  
- (void) updateSkillGroups
{
  NSMutableSet * groups = [[NSMutableSet alloc] init];
  
  for (TrainedSkill * skill in [self skills]) {
    [groups addObject: [[skill skill] group]];
  }
  
  [self setSkillGroups: [[groups allObjects] sortedArrayUsingDescriptors: [NSArray arrayWithObject: [[NSSortDescriptor alloc] initWithKey: @"name" ascending: true]]]];
}

- (void) updateSkillpoints
{
  [[self trainingSkill] setSkillpoints: [[[self trainingSkill] skillpoints] addInteger: [self additionalSkillpoints]]];
  [self setSkillpoints: [self valueForKeyPath: @"skills.@sum.skillpoints"]];
}

- (NSNumber *) totalSkillpoints
{
  return [[self skillpoints] addInteger: [self additionalSkillpoints]];
}

- (void) prepareMessages
{
  if ([self trainingSkill]) {
    [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"skillTrainingCompleted"] date: [self trainingEndsAt]];
  }
  
  [self updateSkillGroups];
}

- (void) invalidate
{
  [self setCachedUntil: [[NSDate alloc] initWithTimeIntervalSinceNow: -1]];
  [self setTrainingCachedUntil: [[NSDate alloc] initWithTimeIntervalSinceNow: -1]];
}

- (void) remove
{  
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"order" ascending: true];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"order > %@", [self order]];
  
  [super remove];
  
  for (Character * c in [Character findWithSort: sort predicate: predicate]) {
    [c setOrder: [[c order] previous]];
  }  
  
  [[Ceres instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"characterRemoved"]];
}
      
@end

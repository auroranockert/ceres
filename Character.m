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
@dynamic account, clone;

@dynamic baseIntelligence, basePerception, baseCharisma, baseWillpower, baseMemory;
@dynamic skillIntelligence, skillPerception, skillCharisma, skillWillpower, skillMemory;
@dynamic implantIntelligence, implantPerception, implantCharisma, implantWillpower, implantMemory;

@dynamic corporationIdentifier, corporationName;

@dynamic currentImplantSet;

@dynamic portraitData;

@dynamic skills, baseSkillpoints;

@dynamic queueCachedUntil;

@synthesize skillGroups;

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Character"];
  }
  
  return entityDescription;
}

- (id) initWithIdentifier: (NSNumber *) ident
                  account: (Account *) acc
{
  if (self = [super initWithIdentifier: ident]) {
    if (![self account]) {
      [self setAccount: acc];
      [self setOrder: [NSNumber numberWithInteger: [[Character find] count]]];
        
      [self invalidate];
      [[self update] join];
      
      [self prepareMessages];
    
      [[CeresNotificationCenter instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"characterAdded"]];
    }
  }
  
  return self;
}

- (Api *) initializeApi
{
  return [[Api alloc] initWithIdentifier: [[self account] identifier] apikey: [[self account] apikey] characterIdentifier: [self identifier]];
}

- (NSNumber *) learningBonus
{
  TrainedSkill * ts = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Learning"]];
  return [NSNumber numberWithDouble: 1.0 + 0.02 * [[ts level] integerValue]];
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
  return [[[[self baseIntelligence] addInteger: [self skillIntelligence]] addInteger: [self implantIntelligence]] scale: [self learningBonus]];
}

- (NSNumber *) perception
{
  return [[[[self basePerception] addInteger: [self skillPerception]] addInteger: [self implantPerception]] scale: [self learningBonus]];
}

- (NSNumber *) charisma
{
  return [[[[self baseCharisma] addInteger: [self skillCharisma]] addInteger: [self implantCharisma]] scale: [self learningBonus]];
}

- (NSNumber *) willpower
{
  return [[[[self baseWillpower] addInteger: [self skillWillpower]] addInteger: [self implantWillpower]] scale: [self learningBonus]];
}

- (NSNumber *) memory
{
  return [[[[self baseMemory] addInteger: [self skillMemory]] addInteger: [self implantMemory]] scale: [self learningBonus]];
}

- (NSNumber *) skillIntelligence
{
  TrainedSkill * analyticalMind = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Analytical Mind"]];
  TrainedSkill * logic = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Logic"]];
  return [[analyticalMind level] addInteger: [logic level]];  
}

- (NSNumber *) skillPerception
{
  TrainedSkill * spatialAwareness = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Spatial Awareness"]];
  TrainedSkill * clarity = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Clarity"]];
  return [[spatialAwareness level] addInteger: [clarity level]];  
}

- (NSNumber *) skillCharisma
{
  TrainedSkill * empathy = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Empathy"]];
  TrainedSkill * presence = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Presence"]];
  return [[empathy level] addInteger: [presence level]];  
}

- (NSNumber *) skillWillpower
{
  TrainedSkill * ironWill = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Iron Will"]];
  TrainedSkill * focus = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Focus"]];
  return [[ironWill level] addInteger: [focus level]];
}

- (NSNumber *) skillMemory
{
  TrainedSkill * instantRecall = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Instant Recall"]];
  TrainedSkill * eideticMemory = [TrainedSkill findWithCharacter: self skill: [Skill findWithName: @"Eidetic Memory"]];
  return [[instantRecall level] addInteger: [eideticMemory level]];  
}

- (NSNumber *) implantIntelligence
{
  return [[self currentImplantSet] bonusForAttribute: @"Intelligence"];
}

- (NSNumber *) implantPerception
{
  return [[self currentImplantSet] bonusForAttribute: @"Perception"];
}

- (NSNumber *) implantCharisma
{
  return [[self currentImplantSet] bonusForAttribute: @"Charisma"];
}

- (NSNumber *) implantWillpower
{
  return [[self currentImplantSet] bonusForAttribute: @"Willpower"];
}

- (NSNumber *) implantMemory
{
  return [[self currentImplantSet] bonusForAttribute: @"Memory"];
}

- (CorporationInfo *) corporation
{
  return [[CorporationInfo alloc] initWithIdentifier: [self corporationIdentifier] name: [self corporationName]];
}

- (CharacterInfo *) characterInfo
{
  return [[CharacterInfo alloc] initWithIdentifier: [self identifier] name: [self name] corporation: [self corporation] account: [self account]];
}

- (NSImage *) portrait
{
  return [[NSImage alloc] initWithData: [self portraitData]];
}

- (TrainedSkill *) currentlyTraining
{
  return [[self currentSkillQueueEntry] trainedSkill];
}

- (SkillQueueEntry *) lastTrainedSkillQueueEntry
{
  for (SkillQueueEntry * entry in [self skillQueue]) {
    if ([[entry startsAt] timeIntervalSinceNow] > 0 && [[entry endsAt] timeIntervalSinceNow] < -60) {
      return entry;
    }
  }
  
  return nil;
}

- (SkillQueueEntry *) currentSkillQueueEntry
{
  for (SkillQueueEntry * entry in [self skillQueue]) {
    if ([[entry startsAt] timeIntervalSinceNow] > 0 && [[entry endsAt] timeIntervalSinceNow] < 0) {
      return entry;
    }
  }
  
  return nil;
}

- (NSArray *) skillQueue
{
  return [SkillQueueEntry findWithSort: [[NSSortDescriptor alloc] initWithKey: @"order" ascending: true] predicate: [NSPredicate predicateWithFormat: @"character = %@", self]];
}

- (void) clearSkillQueue
{
  for (SkillQueueEntry * entry in [self skillQueue]) {
    [entry remove];
  }
}

- (NSNumber *) additionalSkillpoints
{
  NSInteger skillTime = [[[self currentSkillQueueEntry] endsAt] timeIntervalSinceReferenceDate] - [[[self currentSkillQueueEntry] startsAt] timeIntervalSinceReferenceDate];
  NSInteger currentDifference = [[[self currentSkillQueueEntry] startsAt] timeIntervalSinceNow];
  double percentage = (double) currentDifference / skillTime;
  
  return [NSNumber numberWithDouble: ([[[self currentlyTraining] requiredSkillpointsForNextLevel] integerValue] * percentage)];
}

- (NSNumber *) skillpointsForGroup: (Group *) group
{
  NSNumber * sp = [[[self skills] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"skill.group == %@", group]] valueForKeyPath: @"@sum.skillpoints"];

  if (group == [[[self currentlyTraining] skill] group]) {
    sp = [sp addInteger: [self additionalSkillpoints]];
  }
  
  return sp;
}

- (NSNumber *) skillsForGroup: (Group *) group
{
  return [NSNumber numberWithInteger: [[[self skills] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"skill.group == %@", group]] count]];
}

- (IOFuture *) update
{  
  if(![self portraitData]) {
    [self setPortraitData: [[[self api] requestImage: [self identifier]] TIFFRepresentation]];
  }
  
  return [[CharacterFuture alloc] initWithCharacter: self];
}

- (void) updateSkillGroups
{
  NSMutableSet * groups = [[NSMutableSet alloc] init];
  
  for (TrainedSkill * skill in [self skills]) {
    [groups addObject: [[skill skill] group]];
  }
  
  [self setSkillGroups: [[groups allObjects] sortedArrayUsingDescriptors: [NSArray arrayWithObject: [[NSSortDescriptor alloc] initWithKey: @"name" ascending: true]]]];
}

- (NSNumber *) skillpoints
{
  return [[self baseSkillpoints] addInteger: [self additionalSkillpoints]];
}

- (void) prepareMessages
{
  [[CeresNotificationCenter instance] addObserver: self selector: @selector(skillTrainingCompleted:) name: [CharacterNotification nameForMessage: @"skillTrainingCompleted"] object: self];
  
  if ([self currentlyTraining]) {
    [[CeresNotificationCenter instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"skillTrainingCompleted"] date: [[self currentSkillQueueEntry] endsAt]];
  }
  
  [self updateSkillGroups];
}

- (void) invalidate
{
  [self setCachedUntil: [[NSDate alloc] initWithTimeIntervalSinceNow: -1]];
  [self setQueueCachedUntil: [[NSDate alloc] initWithTimeIntervalSinceNow: -1]];
}

- (void) remove
{  
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"order" ascending: true];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"order > %@", [self order]];
  
  [super remove];
  
  for (Character * c in [Character findWithSort: sort predicate: predicate]) {
    [c setOrder: [[c order] previous]];
  }  
  
  [[CeresNotificationCenter instance] postNotification: [CharacterNotification notificationWithCharacter: self name: @"characterRemoved"]];
}

- (void) skillTrainingCompleted: (NSNotification *) notification
{
  for (SkillQueueEntry * entry in [self skillQueue]) {
    if ([[entry endsAt] timeIntervalSinceNow] < 0 && [[entry trainedSkill] level] != [entry toLevel]) {
      [[entry trainedSkill] setLevel: [entry toLevel]];
      [[entry trainedSkill] setSkillpoints: [[[entry trainedSkill] skill] skillpointsForLevel: [entry toLevel]]];
    }
  }  
}
      
@end

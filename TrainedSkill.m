//
//  TrainedSkill.m
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
//  Created by Jens Nockert on 1/27/09.
//

#import "TrainedSkill.h"


@implementation TrainedSkill

@dynamic skillpoints, level;
@dynamic skill, character;

- (id) initWithCharacter: (Character *) character skill: (Skill *) skill
{
  TrainedSkill * ts = [[self class] findWithCharacter: character skill: skill];
  
  if (ts) {
    return ts;
  }
  
  if (self = [super init]) {
    [self setCharacter: character];
    [self setSkill: skill];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"TrainedSkill"];
  }
  
  return entityDescription;
}

+ (NSArray *) findWithCharacter: (Character *) character
{
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"skill.identifier" ascending: true];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"character == %@", character];
  
  return [self findWithSort: sort predicate: predicate];
}
  
+ (id) findWithCharacter: (Character *) character skill: (Skill *) skill
{
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"skill.identifier" ascending: true];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"character == %@ AND skill == %@", character, skill];
  
  return [[self findWithSort: sort predicate: predicate] anyObject];
}

+ (NSArray *) findWithCharacter: (Character *) character group: (Group *) group
{
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"skill.name" ascending: true];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"character == %@ AND skill.group == %@", character, group];
  
  return [self findWithSort: sort predicate: predicate];
}

+ (NSArray *) findWithCharacter: (Character *) character marketGroup: (MarketGroup *) group
{
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"skill.name" ascending: true];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"character == %@ AND skill.marketGroup == %@", character, group];
  
  return [self findWithSort: sort predicate: predicate];
}

- (NSString *) name
{
  return [[self skill] name];
}

- (bool) complete
{
  if (self == [[self character] trainingSkill] && [[[self character] trainingEndsAt] timeIntervalSinceNow] < 0) {
    return true;
  }
  
  return false;
}

- (bool) partiallyTrained
{
  if (self == [[self character] trainingSkill] || [[self skillpoints] compare: [[self skill] skillpointsForLevel: [self level]]] != NSOrderedSame) {
    return true;
  }
  
  return false;
}

- (NSNumber *) nextLevel
{
  return [[self level] next];
}

- (NSNumber *) requiredSkillpointsForNextLevel
{
  if ([[[self character] trainingEndsAt] timeIntervalSinceNow] < 0) {
    return [NSNumber numberWithInteger: 0];
  }
  else {
    return [[[self skill] skillpointsForLevel: [self nextLevel]] subtractInteger: [self skillpoints]];
  }
}

- (NSNumber *) skillpointsPerHour
{
  return [NSNumber numberWithDouble: ([[[self character] attribute: [[self skill] primaryAttribute]] doubleValue] + [[[self character] attribute: [[self skill] secondaryAttribute]] doubleValue] / 2) * 60];
}

- (NSNumber *) currentSkillpoints
{
  if (self == [[self character] trainingSkill]) {
    return [[self skillpoints] addInteger: [[self character] additionalSkillpoints]];
  }
  else {
    return [self skillpoints];
  }
}

- (NSNumber *) percentDone
{
  if ([[self level] integerValue] < 5) {
    NSInteger current = [[[self skill] skillpointsForLevel: [self level]] integerValue], next = [[[self skill] skillpointsForLevel: [self nextLevel]] integerValue];
    return [NSNumber numberWithDouble: (double)([[self currentSkillpoints] integerValue] - current) / (next - current)];
  }
  else {
    return [NSNumber numberWithDouble: 1.0];
  }
}

@end

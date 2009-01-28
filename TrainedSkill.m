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
  
  NSArray * results = [self findWithSort: sort predicate: predicate];
  
  if ([results count] == 1) {
    return [results objectAtIndex: 0];
  }
  else {
    if (![results count]) {
      NSLog(@"Error: Not 0/1 trained skills");
    }
    
    return nil;
  }
}

@end

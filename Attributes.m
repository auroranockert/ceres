//
//  Attributes.m
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

#import "Attributes.h"


@implementation Attributes

@dynamic intelligence, charisma, perception, memory, willpower;

- (id) init: (NSNumber *) intel : (NSNumber *) per : (NSNumber *) cha : (NSNumber *) mem : (NSNumber *) will
{
  if(self = [super initWithEntity: [[self class] entityDescription] insertIntoManagedObjectContext: [[Ceres instance] managedObjectContext]]) {
    [self setIntelligence: intel];
    [self setCharisma: cha];
    [self setPerception: per];
    [self setMemory: mem];
    [self setWillpower: will];
  }
  
  return self;
}

- (id) initWithoutCoreData: (NSNumber *) intel : (NSNumber *) per : (NSNumber *) cha : (NSNumber *) mem : (NSNumber *) will
{
  if(self = [super initWithEntity: [[self class] entityDescription] insertIntoManagedObjectContext: nil]) {
    [self setIntelligence: intel];
    [self setCharisma: cha];
    [self setPerception: per];
    [self setMemory: mem];
    [self setWillpower: will];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Attribute"];
  }
  
  return entityDescription;  
}

- (NSString *) description
{
  NSString * value = @"";
  value = [value stringByAppendingFormat: @"Intelligence: %@\n", [self intelligence]];
  value = [value stringByAppendingFormat: @"Charisma: %@\n", [self charisma]];
  value = [value stringByAppendingFormat: @"Perception: %@\n", [self perception]];
  value = [value stringByAppendingFormat: @"Memory: %@\n", [self memory]];
  value = [value stringByAppendingFormat: @"Willpower: %@\n", [self willpower]];
  return value;
}

@end

//
//  SkillQueue.m
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
//  Created by Jens Nockert on 4/14/09.
//

#import "SkillQueue.h"


@implementation SkillQueue

@dynamic character, skillQueueEntries;

- (id) initWithCharacter: (Character *) character
{
  if (self = [super init]) {
    [self setCharacter: character];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"SkillQueue"];
  }
  
  return entityDescription;
}

- (void) awakeFromFetch
{
  currentEntry = 0;
}

- (NSDate *) startsAt
{
  return [[[self orderedSkillQueueEntries] firstObject] startsAt];
}

- (NSDate *) endsAt
{
  return [[[self orderedSkillQueueEntries] lastObject] endsAt];
}

- (bool) complete
{
  if ([[self endsAt] timeIntervalSinceNow] < 0) {
    return true;
  }
  
  return false;
}

- (NSUInteger) length
{
  return [[self orderedSkillQueueEntries] count];
}

- (NSArray *) orderedSkillQueueEntries
{
  if (!orderedSkillQueueEntries) {
    orderedSkillQueueEntries = [SkillQueueEntry findWithSort: [[NSSortDescriptor alloc] initWithKey: @"order" ascending: true] predicate: [NSPredicate predicateWithFormat: @"skillQueue = %@", self]];
  }
  
  return orderedSkillQueueEntries;
}

- (SkillQueueEntry *) currentSkillQueueEntry
{
  SkillQueueEntry * current = nil;
  NSArray * entries = [self orderedSkillQueueEntries];
  
  if (!entries || [entries count] == 0) {
    return current;
  }
  
  current = [entries objectAtIndex: currentEntry];
  
  if ([[current endsAt] timeIntervalSinceNow] < 0) {    
    if ( !(currentEntry < [self length] - 1)) {
      return current;
    }
    
    current = [[self orderedSkillQueueEntries] objectAtIndex: ++currentEntry];
  }
  
  return current;
}

@end

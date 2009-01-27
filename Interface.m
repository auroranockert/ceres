//
//  Interface.m
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
//  Created by Jens Nockert on 1/11/09.
//

#import "Interface.h"


@implementation Interface

static Interface * shared;

+ (Interface *) instance
{
  @synchronized(self) {
    if (!shared) {
      [[self alloc] init];
      [shared addDelegates];
    }    
  }
  
  return shared;
}

+ (id) allocWithZone: (NSZone *) zone
{
  @synchronized(self) {
    if (!shared) {
      shared = [super allocWithZone: zone];
      return shared;
    }
  }
  
  return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (void) addDelegates
{
  [[Ceres instance] addObserver: self selector: @selector(notification:) name: nil object: nil];
  [[Ceres instance] addObserver: self selector: @selector(notificationForSkillTrainingCompleted:) name: [CharacterNotification nameForMessage: @"skillTrainingCompleted"] object: nil];
  [GrowlApplicationBridge setGrowlDelegate: self];
}

- (void) notification: (NSNotification *) o
{
  NSLog(@"%@ Sent", [o name]);
}

- (void) notificationForSkillTrainingCompleted: (NSNotification *) o
{
  Character * character = [o object];
  [GrowlApplicationBridge notifyWithTitle: [character name]
                              description: [NSString stringWithFormat: @"Training %@ to level %@ complete", [character trainingToLevel], [[character trainingSkill] name]]
                         notificationName: @"Skill training completed"
                                 iconData: [character portraitData]
                                 priority: 0
                                 isSticky: true
                             clickContext: nil];
}

- (NSManagedObjectContext *) managedObjectContext
{
  return [[Ceres instance] managedObjectContext];
}

- (bool) loadNib: (NSString *) name
{
  if (![NSBundle loadNibNamed: name owner: self])
  {
    NSLog(@"Warning! Could not load %@.", name);
    return false;
  }
  
  return true;
}

- (bool) loadNib: (NSString *) name owner: (id) owner
{
  if (![NSBundle loadNibNamed: name owner: owner])
  {
    NSLog(@"Warning! Could not load %@.", name);
    return false;
  }
  
  return true;  
}

- (NSString *) applicationNameForGrowl
{
  return @"Ceres";
}

- (NSDictionary *) registrationDictionaryForGrowl
{
  NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
  [dictionary setValue: [NSArray arrayWithObjects: @"Skill training completed", nil] forKey: GROWL_NOTIFICATIONS_DEFAULT];
  [dictionary setValue: [NSArray arrayWithObjects: @"Skill training completed", nil] forKey: GROWL_NOTIFICATIONS_ALL];
  return dictionary; 
}

@end
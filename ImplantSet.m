//
//  ImplantSet.m
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
//  Created by Jens Nockert on 2/4/09.
//

#import "ImplantSet.h"


@implementation ImplantSet

@dynamic character, implants;

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"ImplantSet"];
  }
  
  return entityDescription;
}

- (NSNumber *) bonusForAttribute: (NSString *) attribute
{
  if ([attribute compare: @"Perception"] == NSOrderedSame) {
    return [[self implantForSlot: [NSNumber numberWithInteger: 1]] attributeBonus];
  }
  else if ([attribute compare: @"Memory"] == NSOrderedSame) {
    return [[self implantForSlot: [NSNumber numberWithInteger: 2]] attributeBonus];
  }
  else if ([attribute compare: @"Willpower"] == NSOrderedSame) {
    return [[self implantForSlot: [NSNumber numberWithInteger: 3]] attributeBonus];
  }
  else if ([attribute compare: @"Intelligence"] == NSOrderedSame) {
    return [[self implantForSlot: [NSNumber numberWithInteger: 4]] attributeBonus];
  }
  else if ([attribute compare: @"Charisma"] == NSOrderedSame) {
    return [[self implantForSlot: [NSNumber numberWithInteger: 5]] attributeBonus];
  }
  else {
    return nil;
  }
}

- (Implant *) implantForSlot: (NSNumber *) slot
{
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"identifier" ascending: true];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"implantSets == %@", self];
  
  NSSet * set = [[self implants] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"slot == %@", slot]];
  
  return [set anyObject];
}

- (void) addImplant: (Implant *) implant
{
  Implant * oldImplant = [self implantForSlot: [implant slot]];
  
  if (oldImplant) {
    [[self implants] removeObject: oldImplant];
  }
  
  [[self implants] addObject: implant];
}

@end

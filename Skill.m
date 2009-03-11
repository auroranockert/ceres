//
//  Skill.m
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
//  Created by Jens Nockert on 12/17/08.
//

#import "Skill.h"


@implementation Skill

@dynamic rank, primaryAttribute, secondaryAttribute;

- (id) initWithDictionary: (NSDictionary *) dictionary
{
  if (self = [super initWithDictionary: dictionary]) {
    [self setRank: [dictionary objectForKey: @"Rank"]];
    [self setPrimaryAttribute: [dictionary objectForKey: @"PrimaryAttribute"]];
    [self setSecondaryAttribute: [dictionary objectForKey: @"SecondaryAttribute"]];
  }
  
  return self;  
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Skill"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * skills = [document readNodes: @"/skills/skill"];
  
  [NSThread process: skills sender: self selector: @selector(worker:)];
}

+ (void) worker: (NSArray *) arguments
{
  NSArray * objects = [arguments objectAtIndex: 0];
  NSMutableArray * queue = [arguments objectAtIndex: 1];
  NSLock * lock = [arguments objectAtIndex: 2];
  
  for (NSXMLNode * skill in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [[skill readNode: @"/identifier"] numberValueInteger], @"Identifier",
                                 [[skill readNode: @"/name"] stringValue], @"Name",
                                 [[skill readNode: @"/price"] numberValueInteger], @"Price",
                                 [[skill readNode: @"/rank"] numberValueInteger], @"Rank",
                                 [[skill readNode: @"/primaryAttribute"] stringValue], @"PrimaryAttribute",
                                 [[skill readNode: @"/secondaryAttribute"] stringValue], @"SecondaryAttribute",
                                 [[skill readNode: @"/marketGroupIdentifier"] numberValueInteger], @"MarketGroupIdentifier",
                                 [[skill readNode: @"/groupIdentifier"] numberValueInteger], @"GroupIdentifier",
                                 [[skill readNode: @"/description"] stringValue], @"Description",
                                 nil];
    
    [lock lock];
    [queue addObject: dictionary];
    [lock unlock];
  }  
}

- (NSNumber *) levelForSkillpoints: (NSNumber *) skillpoints
{
  NSInteger sp = [skillpoints integerValue];
  
  for (int i = 5; i > 0; i--) {
    if (sp >= [[self skillpointsForLevel: [NSNumber numberWithInteger: i]] integerValue]) {
      return [NSNumber numberWithInteger: 5];
    }
  }
  
  return [NSNumber numberWithInteger: 0];
}

- (NSNumber *) skillpointsForLevel: (NSNumber *) level
{
  NSInteger currentLevel = (NSInteger) ceil(250 * [[self rank] integerValue] * pow(32, ([level integerValue] - 1) / 2.0));
  return [NSNumber numberWithInteger: currentLevel];
}

@end

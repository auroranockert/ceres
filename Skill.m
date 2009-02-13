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
  NSMutableSet * queue = [arguments objectAtIndex: 1];
  NSLock * lock = [arguments objectAtIndex: 2];
  
  for (NSXMLNode * clone in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [[clone readNode: @"/identifier"] numberValueInteger], @"Identifier",
                                 [[clone readNode: @"/name"] stringValue], @"Name",
                                 [[clone readNode: @"/price"] numberValueInteger], @"Price",
                                 [[clone readNode: @"/rank"] numberValueInteger], @"Rank",
                                 [[clone readNode: @"/primaryAttribute"] stringValue], @"PrimaryAttribute",
                                 [[clone readNode: @"/secondaryAttribute"] stringValue], @"SecondaryAttribute",
                                 [[clone readNode: @"/marketGroupIdentifier"] numberValueInteger], @"MarketGroupIdentifier",
                                 [[clone readNode: @"/groupIdentifier"] numberValueInteger], @"GroupIdentifier",
                                 nil];
    
    [lock lock];
    [queue addObject: dictionary];
    [lock unlock];
  }  
}

- (NSNumber *) skillpointsForLevel: (NSNumber *) level
{
  NSInteger currentLevel = (NSInteger)(250 * [[self rank] integerValue] * pow(32, ([level integerValue] - 1) / 2.0));
  return [NSNumber numberWithInteger: currentLevel];
}

@end

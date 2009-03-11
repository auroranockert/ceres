//
//  RequiredSkill.m
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
//  Created by Jens Nockert on 3/6/09.
//

#import "RequiredSkill.h"


@implementation RequiredSkill

@dynamic item, skill, level, order;

static NSInteger count = 0;

- (id) initWithDictionary: (NSDictionary *) dictionary
{
  if (self = [super init]) {
    [self setItem: [ItemType findWithIdentifier: [dictionary objectForKey: @"Item"]]];
    [self setSkill: [Skill findWithIdentifier: [dictionary objectForKey: @"Skill"]]];
    [self setLevel: [dictionary objectForKey: @"Level"]];
    [self setOrder: [dictionary objectForKey: @"Order"]];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"RequiredSkill"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * skills = [document readNodes: @"/requirements/requirement"];
  
  [NSThread process: skills sender: self selector: @selector(worker:)];
}

+ (void) worker: (NSArray *) arguments
{
  NSArray * objects = [arguments objectAtIndex: 0];
  NSMutableArray * queue = [arguments objectAtIndex: 1];
  NSLock * lock = [arguments objectAtIndex: 2];
  
  for (NSXMLNode * requirement in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [[requirement readNode: @"/typeIdentifier"] numberValueInteger], @"Item",
                                 [[requirement readNode: @"/skillIdentifier"] numberValueInteger], @"Skill",
                                 [[requirement readNode: @"/level"] numberValueInteger], @"Level",
                                 [[requirement readNode: @"/order"] numberValueInteger], @"Order",
                                 nil];
    
    [lock lock];
    [queue addObject: dictionary];
    [lock unlock];  }
}

@end

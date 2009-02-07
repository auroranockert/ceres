//
//  Clone.m
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

#import "Clone.h"


@implementation Clone

@dynamic skillpoints;

- (id) initWithDictionary: (NSDictionary *) dictionary
{
  if (self = [super initWithDictionary: dictionary]) {
    [self setSkillpoints: [dictionary objectForKey: @"Skillpoints"]];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Clone"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * clones = [document readNodes: @"/clones/clone"];
  
  NSThread * worker = [[NSThread alloc] initWithTarget: [self class] selector: @selector(worker) object: nil];
  [worker process: clones sender: self];
}

+ (void) worker
{
  NSArray * objects = [[[NSThread currentThread] threadDictionary] valueForKey: @"Object"];
  NSMutableSet * queue = [[[NSThread currentThread] threadDictionary] valueForKey: @"Queue"];
  NSLock * lock = [[[NSThread currentThread] threadDictionary] valueForKey: @"Lock"];
  
  for (NSXMLNode * clone in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [[clone readNode: @"/identifier"] numberValueInteger], @"Identifier",
                                 [[clone readNode: @"/name"] stringValue], @"Name",
                                 [[clone readNode: @"/price"] numberValueInteger], @"Price",
                                 [[clone readNode: @"/skillpoints"] numberValueInteger], @"Skillpoints",
                                 nil];
    
    [lock lock];
    [queue addObject: dictionary];
    [lock unlock];
  }
}

- (void) invalidate
{
  NSLog(@"Invalidate called on a Clone");
}

- (void) update
{
  NSLog(@"Update Called on a Clone");
}

@end

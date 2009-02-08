//
//  MarketGroup.m
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
//  Created by Jens Nockert on 12/26/08.
//

#import "MarketGroup.h"

#import "Loader.h"

@implementation MarketGroup

@dynamic identifier, name, published;
@dynamic parent, children, items, hasTypes;

- (id) initWithDictionary: (NSDictionary *) dictionary
{
  if (self = [super initWithIdentifier: [dictionary valueForKey: @"Identifier"]]) {
    [self setName: [dictionary valueForKey: @"Name"]];
    [self setHasTypes: [dictionary valueForKey: @"HasTypes"]];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"MarketGroup"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * marketGroups = [document readNodes: @"/marketgroups/marketgroup"];
  
  NSThread * worker = [[NSThread alloc] initWithTarget: [self class] selector: @selector(worker) object: nil];
  [worker process: marketGroups sender: self];
  
  for (NSXMLNode * marketGroup in marketGroups)
  {
    NSInteger parentIdentifier = [[marketGroup readNode: @"/parentIdentifier"] integerValue];
    
    if(parentIdentifier) {
      [[MarketGroup findWithIdentifier: [[marketGroup readNode: @"/identifier"] numberValueInteger]] setParent: [MarketGroup findWithIdentifier: [[marketGroup readNode: @"/parentIdentifier"] numberValueInteger]]];
    }
    
    [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.0]];
  }
}

+ (void) worker
{
  NSArray * objects = [[[NSThread currentThread] threadDictionary] valueForKey: @"Object"];
  NSMutableSet * queue = [[[NSThread currentThread] threadDictionary] valueForKey: @"Queue"];
  NSLock * lock = [[[NSThread currentThread] threadDictionary] valueForKey: @"Lock"];
  
  for (NSXMLNode * marketGroup in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
    [[marketGroup readNode: @"/identifier"] numberValueInteger], @"Identifier",
    [[marketGroup readNode: @"/name"] stringValue], @"Name",
    [NSNumber numberWithBool: [[marketGroup readNode: @"/hasTypes"] integerValue]], @"HasTypes",
     nil];
    
    [lock lock];
    [queue addObject: dictionary];
    [lock unlock];
  }
}

+ (NSInteger) priority
{
  return 10;
}

@end

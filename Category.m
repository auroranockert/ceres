//
//  Category.m
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

#import "Category.h"


@implementation Category

@dynamic identifier, name, published;
@dynamic groups;

- (id) initWithDictionary: (NSDictionary *) dictionary
{
  if (self = [super initWithIdentifier: [dictionary valueForKey: @"Identifier"]]) {
    [self setName: [dictionary valueForKey: @"Name"]];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Category"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * categories = [document readNodes: @"/categories/category"];
  
  NSThread * worker = [[NSThread alloc] initWithTarget: [self class] selector: @selector(worker) object: nil];
  [worker process: categories sender: self];
}

+ (void) worker
{
  NSArray * objects = [[[NSThread currentThread] threadDictionary] valueForKey: @"Object"];
  NSMutableSet * queue = [[[NSThread currentThread] threadDictionary] valueForKey: @"Queue"];
  NSLock * lock = [[[NSThread currentThread] threadDictionary] valueForKey: @"Lock"];
  
  for (NSXMLNode * category in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [[category readNode: @"/identifier"] numberValueInteger], @"Identifier",
                                 [[category readNode: @"/name"] stringValue], @"Name",
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

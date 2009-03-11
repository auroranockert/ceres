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
  if (self = [super initWithIdentifier: [dictionary objectForKey: @"Identifier"]]) {
    [self setName: [dictionary objectForKey: @"Name"]];
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
  
  [NSThread process: categories sender: self selector: @selector(worker:)];
}

+ (void) worker: (NSArray *) arguments
{
  NSArray * objects = [arguments objectAtIndex: 0];
  NSMutableArray * queue = [arguments objectAtIndex: 1];
  NSLock * lock = [arguments objectAtIndex: 2];
  
  for (NSXMLNode * category in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [[category readNode: @"/identifier"] numberValueInteger], @"Identifier",
                                 [[category readNode: @"/name"] stringValue], @"Name",
                                 [[category readNode: @"/description"] stringValue], @"Description",
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

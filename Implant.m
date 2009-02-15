//
//  Implant.m
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

#import "Implant.h"


@implementation Implant

@dynamic slot;
@dynamic attribute, attributeBonus;

- (id) initWithDictionary: (NSDictionary *) dictionary
{
  if (self = [super initWithDictionary: dictionary]) {
    [self setAttribute: [dictionary objectForKey: @"Attribute"]];
    [self setAttributeBonus: [dictionary objectForKey: @"AttributeBonus"]];
    [self setSlot: [dictionary objectForKey: @"Slot"]];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Implant"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * implants = [document readNodes: @"/implants/implant"];
  
  [NSThread process: implants sender: self selector: @selector(worker:)];
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
                                 [[clone readNode: @"/attribute"] stringValue], @"Attribute",
                                 [[clone readNode: @"/attributeBonus"] numberValueInteger], @"AttributeBonus",
                                 [[clone readNode: @"/slot"] numberValueInteger], @"Slot",
                                 [[clone readNode: @"/marketGroupIdentifier"] numberValueInteger], @"MarketGroupIdentifier",
                                 [[clone readNode: @"/groupIdentifier"] numberValueInteger], @"GroupIdentifier",
                                 [[clone readNode: @"/description"] stringValue], @"Description",
                                 nil];
    
    [lock lock];
    [queue addObject: dictionary];
    [lock unlock];
  }
}

@end

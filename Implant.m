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
  NSMutableArray * queue = [arguments objectAtIndex: 1];
  NSLock * lock = [arguments objectAtIndex: 2];
  
  for (NSXMLNode * implant in objects)
  {
    NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [[implant readNode: @"/identifier"] numberValueInteger], @"Identifier",
                                 [[implant readNode: @"/name"] stringValue], @"Name",
                                 [[implant readNode: @"/price"] numberValueInteger], @"Price",
                                 [[implant readNode: @"/attribute"] stringValue], @"Attribute",
                                 [[implant readNode: @"/attributeBonus"] numberValueInteger], @"AttributeBonus",
                                 [[implant readNode: @"/slot"] numberValueInteger], @"Slot",
                                 [[implant readNode: @"/marketGroupIdentifier"] numberValueInteger], @"MarketGroupIdentifier",
                                 [[implant readNode: @"/groupIdentifier"] numberValueInteger], @"GroupIdentifier",
                                 [[implant readNode: @"/description"] stringValue], @"Description",
                                 nil];
    
    [lock lock];
    [queue addObject: dictionary];
    [lock unlock];
  }
}

@end

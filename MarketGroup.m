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


@implementation MarketGroup

@dynamic identifier, name, published;
@dynamic parent, children, items, hasTypes;

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
  
  for (NSXMLNode * marketGroup in marketGroups)
  {
    MarketGroup * group = [[MarketGroup alloc] initWithIdentifier: [NSNumber numberWithInteger: [[[marketGroup readNode: @"/identifier"] stringValue] integerValue]]];
    [group setName: [[marketGroup readNode: @"/name"] stringValue]];
    [group setHasTypes: [NSNumber numberWithBool: [[[marketGroup readNode: @"/hasTypes"] stringValue] compare: @"1"] ? true : false]];
  }
    
  for (NSXMLNode * marketGroup in marketGroups)
  {
    MarketGroup * child = [MarketGroup findWithIdentifier: [[marketGroup readNode: @"/identifier"] numberValueInteger]];
    MarketGroup * parent;
    if([[marketGroup readNode: @"/parentIdentifier"] integerValue] == 0) {
      parent = nil;
    }
    else {
      parent = [MarketGroup findWithIdentifier: [[marketGroup readNode: @"/parentIdentifier"] numberValueInteger]];
    }
    
    [child setParent: parent];
  }
}

+ (NSInteger) priority
{
  return 10;
}

@end

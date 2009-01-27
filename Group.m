//
//  Group.m
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

#import "Group.h"


@implementation Group

@dynamic identifier, name, published;
@dynamic category, items;

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Group"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * groups = [document readNodes: @"/groups/group"];
  
  for (NSXMLNode * group in groups)
  {
    Group * g = [[Group alloc] initWithIdentifier: [[group readNode: @"/identifier"] numberValueInteger]];
    [g setName: [[group readNode: @"/name"] stringValue]];
    [g setCategory: [Category findWithIdentifier: [[group readNode: @"/categoryIdentifier"] numberValueInteger]]];
  }
}

+ (NSInteger) priority
{
  return 9;
}

@end

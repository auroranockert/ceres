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
  
  for (NSXMLNode * category in categories)
  {
    Category * c = [[Category alloc] initWithIdentifier: [[category readNode: @"/identifier"] numberValueInteger]];
    [c setName: [[category readNode: @"/name"] stringValue]];
  }
}

+ (NSInteger) priority
{
  return 10;
}

@end

//
//  Skill.m
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
//  Created by Jens Nockert on 12/17/08.
//

#import "Skill.h"


@implementation Skill

@dynamic rank, primaryAttribute, secondaryAttribute;

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entityDescription;
  
  if (!entityDescription) {
    entityDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Skill"];
  }
  
  return entityDescription;  
}

+ (void) load: (NSXMLDocument *) document
{
  NSArray * skills = [document readNodes: @"/skills/skill"];
  
  for (NSXMLNode * skill in skills)
  {
    Skill * s = [[Skill alloc] initWithIdentifier: [[skill readNode: @"/identifier"] numberValueInteger]];
    [s setName: [[skill readNode: @"/name"] stringValue]];
    [s setPrice: [[skill readNode: @"/price"] numberValueInteger]];
    if (![[skill readNode: @"/marketGroupIdentifier"] integerValue] == 0) {
      [s setMarketGroup: [MarketGroup findWithIdentifier: [[skill readNode: @"/marketGroupIdentifier"] numberValueInteger]]];
    }
    [s setGroup: [Group findWithIdentifier: [[skill readNode: @"/groupIdentifier"] numberValueInteger]]];
  }
}

@end

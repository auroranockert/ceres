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
  
  for (NSXMLNode * implant in implants)
  {
    Implant * i = [[Implant alloc] initWithIdentifier: [[implant readNode: @"/identifier"] numberValueInteger]];
    [i setName: [[implant readNode: @"/name"] stringValue]];
    [i setPrice: [[implant readNode: @"/price"] numberValueInteger]];
    [i setAttribute: [[implant readNode: @"/attribute"] stringValue]];
    [i setAttributeBonus: [[implant readNode: @"/attributeBonus"] numberValueInteger]];
    [i setSlot: [[implant readNode: @"/slot"] numberValueInteger]];
    
    NSInteger ident = [[implant readNode: @"/marketGroupIdentifier"] integerValue];
    if (ident) {
      [i setMarketGroup: [MarketGroup findWithIdentifier: [NSNumber numberWithInteger: ident]]];
    }
    
    ident = [[implant readNode: @"/groupIdentifier"] integerValue];
    if (ident) {
      [i setGroup: [Group findWithIdentifier: [NSNumber numberWithInteger: ident]]];
    }
  }
}

@end

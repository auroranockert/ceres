//
//  ImplantSet.h
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
//  Created by Jens Nockert on 2/4/09.
//

#import <Cocoa/Cocoa.h>

#import "Character.h"
#import "Implant.h"

@class Character;

@interface ImplantSet : CeresObject {

}

@property(retain) Character * character;
@property(retain) NSMutableSet * implants;

- (Implant *) implantForSlot: (NSNumber *) slot;
- (void) replaceImplant: (Implant *) implant;

- (NSNumber *) bonusForAttribute: (NSString *) attribute;

@end

@interface ImplantSet (ImplantAccessors)

- (void)addImplantsObject: (Implant *) value;
- (void)removeImplantsObject: (Implant *) value;
- (void)addImplants: (NSSet *) value;
- (void)removeImplants: (NSSet *) value;

@end

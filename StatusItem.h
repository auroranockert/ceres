//
//  StatusItem.h
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
//  Created by Fernando Alexandre on 1/9/09.
//

#import <Cocoa/Cocoa.h>
#import "Interface.h"
#import "CeresHeader.h"


@interface StatusItem : NSObject {
	NSStatusItem * statusMenuItem;
  Character * character;
  
  NSString * enabled;
}

@property(retain) NSString * enabled;

- (void) update: (id) sender;
- (void) updateCharacter: (NSNotification *) notification;

@end

//
//  CharacterCell.h
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
//  Created by Jens Nockert on 1/15/09.
//

#import <Cocoa/Cocoa.h>

#import "CeresHeader.h"
#import "CharacterController.h"
#import "CharacterListController.h"

@class CharacterListController;

@interface CharacterCell : NSCell {
  CharacterListController * characterListController;
  Character * character;
  
	NSFont * font;
	float maxImageWidth;
	float imageTextPadding;
	bool highlightWhenNotKey;
}

@property(retain) Character * character;
@property(assign) float maxImageWidth, imageTextPadding;
@property(assign) bool highlightWhenNotKey;

- (id) initWithController: (CharacterListController *) controller;

@end

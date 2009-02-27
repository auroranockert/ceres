//
//  SkillListController.h
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
//  Created by Jens Nockert on 1/31/09.
//

#import <Cocoa/Cocoa.h>

#import "Interface.h"
#import "SkillCell.h"
#import "GroupCell.h"

@interface SkillListController : NSArrayController {
  NSOutlineView * skillOutlineView;
  
  GroupCell * groupCell;
  SkillCell * skillCell;
  
  Character * character;
}

@property(retain) Character * character;
@property(retain) NSOutlineView * skillOutlineView;

- (NSCell *) outlineView: (NSOutlineView *) outlineView dataCellForTableColumn: (NSTableColumn *) tableColumn item: (id) item;

@end

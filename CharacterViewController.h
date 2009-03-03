//
//  CharacterTabController.h
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
//  Created by Jens Nockert on 2/25/09.
//

#import <Cocoa/Cocoa.h>

#import "CeresHeader.h"

#import "Module.h"
#import "Interface.h"
#import "SkillListController.h"

@interface CharacterViewController : NSViewController <Module> {
  IBOutlet NSOutlineView * skillView;
  SkillListController * skillController;
  Character * character;
  
  NSImage * portrait;
  
  NSManagedObjectContext * managedObjectContext;
}

- (id) initWithNibName: (NSString *) nib bundle: (NSBundle *) bundle character: (Character *) character;

@property(retain) Character * character;
@property(retain) NSManagedObjectContext * managedObjectContext;
@property(copy, readonly) NSAttributedString * name;
@property(copy, readonly) NSString * bloodline, * corporation, * balance, * skillpoints;
@property(copy, readonly) NSString * intelligence, * perception, * charisma, * willpower, * memory;
@property(copy, readonly) NSAttributedString * clone;
@property(copy, readonly) NSString * training, * trainingSkillpoints, * skillCount;
@property(retain, readonly) NSImage * portrait;

- (NSString *) identifier;
- (NSImage *) icon;

- (void) update: (id) sender;
- (void) updateCharacter: (id) sender;

@end

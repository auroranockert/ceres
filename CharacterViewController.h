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

@interface CharacterViewController : NSViewController <Module> {
  Character * character;
  
  NSImage * portrait;
}

- (id) initWithNibName: (NSString *) nib bundle: (NSBundle *) bundle character: (Character *) character;

@property(retain) Character * character;
@property(copy, readonly) NSString * name, * bloodline, * corporation, * balance, * skillpoints;
@property(copy, readonly) NSString * intelligence, * perception, * charisma, * willpower, * memory;
@property(copy, readonly) NSString * training, * trainingSkillpoints, * clone, * skillCount;
@property(retain, readonly) NSImage * portrait;
@property(retain, readonly) NSManagedObjectContext * managedObjectContext;


- (NSString *) identifier;
- (NSImage *) icon;

@end

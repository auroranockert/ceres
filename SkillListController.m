//
//  SkillListController.m
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

#import "SkillListController.h"


@implementation SkillListController

- (void) awakeFromNib
{
  [super awakeFromNib];

  character = [characterController character];
  
  NSTableColumn * column = [[skillOutlineView tableColumns] anyObject];
  skillCell = [[SkillCell alloc] initWithCharacter: character];
  groupCell = [[GroupCell alloc] initWithCharacter: character];
  
  [skillOutlineView setAutosaveName: [NSString stringWithFormat: @"SkillList.%@", [character name]]];
  [skillOutlineView setAutosaveExpandedItems: true];
  
  [self setSortDescriptors: [NSArray arrayWithObjects: [[NSSortDescriptor alloc] initWithKey: @"skill.group.name" ascending: true], [[NSSortDescriptor alloc] initWithKey: @"skill.name" ascending: true], nil]];
  [self setFetchPredicate: [NSPredicate predicateWithFormat: @"character = %@", character, character]];
}

- (id) outlineView: (NSOutlineView *) outlineView child: (NSInteger) index ofItem: (id) item
{
  if (item) {
    return [[TrainedSkill findWithCharacter: character group: item] objectAtIndex: index];
  }
  
  return [[character skillGroups] objectAtIndex: index];
}

- (bool) outlineView: (NSOutlineView *) outlineView isItemExpandable: (id)item
{
  if ([item class] == [Group class]) {
    return true;
  }
  
  return false;
}

- (NSInteger) outlineView: (NSOutlineView *) outlineView numberOfChildrenOfItem: (id)item
{
  if (item) {
    return [[TrainedSkill findWithCharacter: character group: item] count];
  }
  
  return [[character skillGroups] count];
}

- (id) outlineView: (NSOutlineView *) outlineView objectValueForTableColumn: (NSTableColumn *) tableColumn byItem: (id) item
{
  return item;
}

- (id) outlineView: (NSOutlineView *) outlineView persistentObjectForItem: (id)item
{
  return [item identifier];
}

- (id) outlineView: (NSOutlineView *) outlineView itemForPersistentObject: (id)object
{
  return [Group findWithIdentifier: object];
}

- (NSCell *) outlineView: (NSOutlineView *) outlineView dataCellForTableColumn: (NSTableColumn *) tableColumn item: (id) item
{
  if ([item class] == [Group class]) {
    return groupCell;
  }
  else if ([item class] == [TrainedSkill class]) {
    if (tableColumn) {
      return skillCell;
    }
  }
  
  return nil;
}

@end

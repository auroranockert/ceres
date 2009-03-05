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

@synthesize character, skillOutlineView;

+ (NSImage *) skillImage
{
  static NSImage * skillImage;
  
  if (!skillImage) {
    skillImage = [[NSImage imageNamed: @"Skill"] flip];
  }
  
  return skillImage;
}

+ (NSImage *) partialSkillImage
{
  static NSImage * partialSkillImage;
  
  if (!partialSkillImage) {
    partialSkillImage = [[NSImage imageNamed: @"PartialSkill"] flip];
  }
  
  return partialSkillImage;
}

+ (NSImage *) finishedSkillImage
{
  static NSImage * finishedSkillImage;
  
  if (!finishedSkillImage) {
    finishedSkillImage = [[NSImage imageNamed: @"FinishedSkill"] flip];
  }
  
  return finishedSkillImage;
}

- (void) setSkillOutlineView: (NSOutlineView *) view
{
  skillOutlineView = view;
  
  NSTableColumn * column = [[skillOutlineView tableColumns] anyObject];
  skillCell = [[SkillCell alloc] initWithCharacter: character];
  groupCell = [[GroupCell alloc] initWithCharacter: character];
  
  [skillOutlineView setDataSource: self];
  [skillOutlineView setDelegate: self];
  
  [skillOutlineView setTarget: self];
  [skillOutlineView setDoubleAction: @selector(doubleClick:)];
  
  [skillOutlineView setAutosaveName: [NSString stringWithFormat: @"Ceres.SkillList.%@", [character name]]];
  [skillOutlineView setAutosaveExpandedItems: true];
  
  [[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(reload:) name: [CharacterNotification nameForMessage: @"updatedTraining"] object: character];
	[[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(reload:) name: [CharacterNotification nameForMessage: @"updatedCharacter"] object: character];
	[[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(reload:) name: [CharacterNotification nameForMessage: @"skillTrainingCompleted"] object: character];

  [character updateSkillGroups];
  [skillOutlineView reloadData];
}

- (id) outlineView: (NSOutlineView *) outlineView child: (NSInteger) index ofItem: (id) item
{
  if (item) {
    return [[TrainedSkill findWithCharacter: character group: item] objectAtIndex: index];
  }
  
  return [[character skillGroups] objectAtIndex: index];
}

- (bool) outlineView: (NSOutlineView *) outlineView isItemExpandable: (id) item
{
  if (item && [item class] == [Group class]) {
    return true;
  }
  
  return false;
}

- (NSInteger) outlineView: (NSOutlineView *) outlineView numberOfChildrenOfItem: (id) item
{
  if (item) {
    return [[TrainedSkill findWithCharacter: character group: item] count];
  }
  
  NSInteger count = [[character skillGroups] count];
    
  return count;
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

- (bool) outlineView: (NSOutlineView *)outlineView shouldSelectItem: (id)item
{
  selection = item;
    
  return true;
}

- (void) doubleClick: (id) object
{  
  if([skillOutlineView isItemExpanded: selection]) {
    [skillOutlineView collapseItem: selection];
  }
  else {
    [skillOutlineView expandItem: selection];
  }
}

- (void) reload: (NSNotification *) notification
{
  [skillOutlineView reloadData];
}

@end

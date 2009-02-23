//
//  CeresArrayController.m
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
//  Created by Jens Nockert on 2/23/09.
//

#import "CeresArrayController.h"

@implementation CeresArrayController

- (bool) tableView: (NSTableView *) tableView writeRows: (NSArray *) rows toPasteboard: (NSPasteboard *) pasteboard
{
  [pasteboard declareTypes: [NSArray arrayWithObject: CeresDataType] owner: self];
  [pasteboard setPropertyList: rows forType: CeresDataType];

  return true;
}

- (NSDragOperation) tableView: (NSTableView *) tableView validateDrop: (id <NSDraggingInfo>)info proposedRow: (int) row proposedDropOperation: (NSTableViewDropOperation) op
{
  NSDragOperation dragOp = NSDragOperationNone;
  
  if ([info draggingSource] == tableView)
	{
		dragOp =  NSDragOperationMove;
  }
  
  [tableView setDropRow: row dropOperation: NSTableViewDropAbove];
	
  return dragOp;
}

- (bool) tableView: (NSTableView *) tableView acceptDrop: (id <NSDraggingInfo>) info row: (NSInteger) toRow dropOperation: (NSTableViewDropOperation) operation
{
  if ([info draggingSource] == tableView)
  {
    NSArray * rows = [[info draggingPasteboard] propertyListForType: CeresDataType];
    NSInteger fromRow = [[rows anyObject] integerValue];
    
    NSArray * objects = [self arrangedObjects];
    Character * from = [objects objectAtIndex: fromRow], * to;
    
    NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"order" ascending: true];
    NSPredicate * predicate;
    
    NSNumber * fromOrder = [from order], * toOrder;
    
    if (fromRow > toRow) {
      to = [objects objectAtIndex: toRow];
      toOrder = [to order];
      predicate = [NSPredicate predicateWithFormat: @"order >= %@ AND order < %@", toOrder, fromOrder];
      
      for (Character * c in [Character findWithSort: sort predicate: predicate]) {
        [c setOrder: [[c order] next]];
      }
    }
    else {
      to = [objects objectAtIndex: toRow - 1];
      toOrder = [to order];
      predicate = [NSPredicate predicateWithFormat: @"order <= %@ AND order > %@", toOrder, fromOrder];
      
      for (Character * c in [Character findWithSort: sort predicate: predicate]) {
        [c setOrder: [[c order] previous]];
      }
    }
    
    [from setOrder: toOrder];
    
		return true;
  }
	
  return false;
}

@end

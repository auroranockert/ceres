//
//  CeresArrayController.h
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

#import <Cocoa/Cocoa.h>

#import "CeresHeader.h"
#import "CeresAdditions.h"

#define CeresDataType @"CeresDataType"

@interface CeresArrayController : NSArrayController {

}

- (bool) tableView: (NSTableView *) tableView writeRows: (NSArray *) rows toPasteboard: (NSPasteboard *) pasteboard;
- (NSDragOperation) tableView: (NSTableView *) tableView validateDrop: (id <NSDraggingInfo>)info proposedRow: (int) row proposedDropOperation: (NSTableViewDropOperation) op;
- (bool) tableView: (NSTableView *) tableView acceptDrop: (id <NSDraggingInfo>) info row: (NSInteger)row dropOperation: (NSTableViewDropOperation) operation;

@end

//
//  CharacterController.m
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
//  Created by Jens Nockert on 1/16/09.
//

#import "CharacterListController.h"

@implementation CharacterListController

- (void) awakeFromNib
{
  [super awakeFromNib];
    
  [[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(notification:) name: @"Ceres.character.updatedTraining" object: nil];
  
  [characterTableView setDataSource: self];
  [characterTableView setDelegate: self];
  [characterTableView registerForDraggedTypes: [NSArray arrayWithObject: CeresDataType]];
  
  NSTableColumn * column = [[characterTableView tableColumns] anyObject];
  [column setDataCell: [[CharacterCell alloc] initWithController: self]];
  
  [self setSortDescriptors: [NSArray arrayWithObject: [[NSSortDescriptor alloc] initWithKey: @"order" ascending: true]]];
  [self setAutomaticallyRearrangesObjects: true];
    
  [self performSelector: @selector(update:) withObject: self afterDelay: 1];
}

- (CGFloat) tableView: (NSTableView *) tableView heightOfRow: (NSInteger) row
{
  if ([characterTableView selectedRow] == row) {
    return 120;
  }
  else {
    return 50;
  }
}

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
  NSLog(@"%@", notification);
}

- (void) doubleClick: (id) object
{
  [[CharacterController controllerForCharacter: object] showCharacter];
}

- (void) notification: (id) object
{
  [characterTableView setNeedsDisplay: true];
}

- (void) update: (id) sender
{
  if ([[characterTableView window] isKeyWindow] || (NSInteger)[NSDate timeIntervalSinceReferenceDate] % 60) {
    [characterTableView setNeedsDisplay: true];
  }

  [self performSelector: @selector(update:) withObject: self afterDelay: 1];
}

- (NSString *) training: (Character *) character
{
  if ([character currentSkillQueueEntry])
  {
    if ([[character currentSkillQueueEntry] trainingComplete]) {
      return [[NSString alloc] initWithFormat: @"Training %@ to level %@ is finished", [[character currentSkillQueueEntry] name], [[character currentSkillQueueEntry] toLevel]];
    }
    else {
      return [[NSString alloc] initWithFormat: @"Training %@ to level %@ and is finished by %@", [[character currentSkillQueueEntry] name], [[character currentSkillQueueEntry] toLevel], [[[character currentSkillQueueEntry] endsAt] preferedDateFormatString]];
    }
  }
  else
  {
    return @"Not training";
  }
}

@end

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
    
  [[[Ceres instance] notificationCenter] addObserver: self selector: @selector(notification:) name: @"Ceres.character.updatedTraining" object: nil];
  
  NSTableColumn * column = [[characterTableView tableColumns] anyObject];
  [column setDataCell: [[CharacterCell alloc] initWithController: self]];
  
  [self setSortDescriptors: [NSArray arrayWithObject: [[NSSortDescriptor alloc] initWithKey: @"identifier" ascending: false]]];
  
  characterControllers = [[NSMutableDictionary alloc] init];
  
  [self performSelector: @selector(update:) withObject: self afterDelay: 1];
}

- (CharacterController *) controllerForCharacter: (Character *) character
{
  CharacterController * controller = [characterControllers objectForKey: character];
  
  if (!controller) {
    controller = [[CharacterController alloc] initWithCharacter: character];
    [characterControllers setObject: controller forKey: character];
  }
  
  return controller;
}

- (void) doubleClick: (id) object
{
  [[self controllerForCharacter: object] showCharacter];
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
  if ([character trainingSkill])
  {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm 'on' MMMM d"];
    NSInteger current = [[character trainingCurrentSkillpoints] integerValue];
    
    if (current > [[character trainingSkillpointsEnd] integerValue]) {
      return [[NSString alloc] initWithFormat: @"Training %@ to level %ld is finished", [[character trainingSkill] name], [[[character trainingSkill] nextLevel] integerValue]];
    }
    else {
      return [[NSString alloc] initWithFormat: @"Training %@ to level %ld and is finished by %@", [[character trainingSkill] name], [[[character trainingSkill] nextLevel] integerValue], [formatter stringFromDate: [character trainingEndsAt]]];
    }
  }
  else
  {
    return @"Not training";
  }
}

@end

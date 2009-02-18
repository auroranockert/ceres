//
//  StatusItem.m
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
//  Created by Fernando Alexandre on 1/9/09.
//

#import "StatusItem.h"


@implementation StatusItem

- (void) awakeFromNib 
{
  [[[Ceres instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"characterAdded"] object: nil];
	[[[Ceres instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"updatedTraining"] object: nil];
	[[[Ceres instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"skillTrainingCompleted"] object: nil];
	[[[Ceres instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"characterRemoved"] object: nil];
      
  [self updateCharacter: nil];
    
  [self bind: @"enabled" toObject: [NSUserDefaultsController sharedUserDefaultsController] withKeyPath: @"values.statusIcon" options: nil];

  [self performSelectorOnMainThread: @selector(update:) withObject: self waitUntilDone: false];
}

- (void) updateCharacter: (NSNotification *) notification
{
	NSPredicate * training = [NSPredicate predicateWithFormat: @"trainingSkill != nil"];
	NSSortDescriptor * trainingEndsAt = [[NSSortDescriptor alloc] initWithKey: @"trainingEndsAt" ascending: true];
	
	NSArray * characters = [Character findWithSort: trainingEndsAt predicate: training];
  character = [characters firstObject];
}

- (void) update: (id) sender
{
  if (statusMenuItem) {
    [statusMenuItem setTitle: [[character trainingEndsAt] shortRelativeDateString]];
  }
  
  [self performSelector: @selector(update:) withObject: self afterDelay: 1];
}

- (NSString *) enabled
{
  return enabled;
}

- (void) setEnabled: (NSString *) boolean
{
  enabled = boolean;
  
  if ([enabled compare: @"Yes"] == NSOrderedSame) {
    NSStatusBar * statusBar = [NSStatusBar systemStatusBar]; 
    
    NSImage * menuIcon = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"StatusIcon" ofType: @"tiff"]];
    NSImage * menuIconAlt = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"StatusIconAlternative" ofType: @"tiff"]];    
    
    statusMenuItem = [statusBar statusItemWithLength: NSVariableStatusItemLength];
    
    // [statusMenuItem setImage: menuIcon];
    // [statusMenuItem setAlternateImage: menuIconAlt];
    [statusMenuItem setHighlightMode: true];
    [statusMenuItem setTarget: [Interface instance]];
    [statusMenuItem setAction: @selector(makeKeyAndOrderFront)];
    [statusMenuItem setEnabled: true];
  }
  else {
    statusMenuItem = nil;
  }
  
  [[NSGarbageCollector defaultCollector] collectExhaustively];
}

@end

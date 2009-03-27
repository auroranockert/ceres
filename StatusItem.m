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
  [[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"characterAdded"] object: nil];
	[[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"updatedTraining"] object: nil];
	[[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"skillTrainingCompleted"] object: nil];
	[[[CeresNotificationCenter instance] notificationCenter] addObserver: self selector: @selector(updateCharacter:) name: [CharacterNotification nameForMessage: @"characterRemoved"] object: nil];
      
  [self updateCharacter: nil];
    
  [self bind: @"enabled" toObject: [NSUserDefaultsController sharedUserDefaultsController] withKeyPath: @"values.statusIcon" options: nil];
}

- (void) activate: (id) sender
{
  [[Interface instance] makeKeyAndOrderFront];
}

- (void) updateCharacter: (NSNotification *) notification
{
  NSMenu * menu = [[NSMenu alloc] init];
	NSSortDescriptor * trainingEndsAt = [[NSSortDescriptor alloc] initWithKey: @"currentSkillQueueEntry.endsAt" ascending: true];
	
	NSArray * characters = [[[Character find] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"currentSkillQueueEntry != nil"]] sortedArrayUsingDescriptors: [NSArray arrayWithObject: trainingEndsAt]];
  
  character = [characters firstObject];
  
  for (Character * c in characters) {
    [menu addItem: [[CharacterMenuItem alloc] initWithCharacter: c]];
  }
  
  NSMenuItem * open = [[NSMenuItem alloc] initWithTitle: @"Open Ceres" action: @selector(activate:) keyEquivalent: @""];
  [open setTarget: self];
  
  [menu addItem: [NSMenuItem separatorItem]];  
  [menu addItem: open];
  
  [statusMenuItem setMenu: menu];
}

- (void) update: (id) sender
{
  if (statusMenuItem) {
    if ([[character currentlyTraining] complete]) {
      [statusMenuItem setTitle: @"Done"];
    }
    else {
      [statusMenuItem setTitle: [[[character  currentSkillQueueEntry] endsAt] shortRelativeDateString]];
    }
    
    [self performSelector: @selector(update:) withObject: self afterDelay: 1];
  }
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
    
    // NSImage * menuIcon = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"StatusIcon" ofType: @"tiff"]];
    // NSImage * menuIconAlt = [[NSImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"StatusIconAlternate" ofType: @"tiff"]];    
    
    statusMenuItem = [statusBar statusItemWithLength: NSVariableStatusItemLength];
    
    // [statusMenuItem setImage: menuIcon];
    // [statusMenuItem setAlternateImage: menuIconAlt];
    [statusMenuItem setHighlightMode: true];
    
    [self updateCharacter: nil];
    [self performSelectorOnMainThread: @selector(update:) withObject: self waitUntilDone: false];
  }
  else {
    [[NSStatusBar systemStatusBar] removeStatusItem: statusMenuItem];
    statusMenuItem = nil;
  }
}

@end

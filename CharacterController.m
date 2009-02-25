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
//  Created by Jens Nockert on 1/17/09.
//

#import "CharacterController.h"


@implementation CharacterController

- (id) initWithCharacter: (Character *) c
{
  if (self = [super init]) {
    character = c;
    
    [[[Ceres instance] notificationCenter] addObserver: self selector: @selector(notification:) name: nil object: character];
  }
  
  return self;
}

- (NSMenu *) menu
{
  NSMenu * menu = [[NSMenu alloc] init];
  
  NSMenuItem * showCharacter = [[NSMenuItem alloc] initWithTitle: @"Show more details" action: @selector(showCharacter) keyEquivalent: @""];
  NSMenuItem * invalidateCharacter = [[NSMenuItem alloc] initWithTitle: @"Invalidate cache" action: @selector(invalidateCharacter) keyEquivalent: @""];
  NSMenuItem * removeCharacter = [[NSMenuItem alloc] initWithTitle: @"Remove Character" action: @selector(removeCharacter) keyEquivalent: @""];  
  NSMenuItem * cacheCharacter = [[CacheMenuItem alloc] initWithCharacter: character type: @"Character"];
  NSMenuItem * cacheTraining = [[CacheMenuItem alloc] initWithCharacter: character type: @"Training"];
  
  [showCharacter setTarget: self];
  [invalidateCharacter setTarget: self];
  [removeCharacter setTarget: self];
  
  [menu addItem: showCharacter];
  [menu addItem: invalidateCharacter];
  [menu addItem: [NSMenuItem separatorItem]];
  [menu addItem: cacheCharacter];
  [menu addItem: cacheTraining];
  [menu addItem: [NSMenuItem separatorItem]];
  [menu addItem: removeCharacter];
  
  return menu;
}

- (NSImage *) portrait
{
  if (!portrait) {
    portrait = [character portrait];
    
    [portrait setFlipped: true];
    
    portrait = [portrait imageWithRoundedCorners: 10.0];
  }
  
  return portrait;
}

- (Character *) character
{
  return character;
}

- (void) invalidateCharacter
{
  [character invalidate];
  [character update];
}

- (void) showCharacter
{
  if ([[[NSUserDefaults standardUserDefaults] valueForKey: @"tabbedCharacters"] compare: @"Yes"] == NSOrderedSame) {
    [[TabbedCharacterController instance] showWindow: self];
  }
  else {
    if(!characterViewController) {
      characterViewController = [[CharacterViewController alloc] initWithNibName: @"Character" bundle: nil character: character];
      characterWindowController = [[NSWindowController alloc] init];
      [characterWindowController setWindow: [[NSWindow alloc] initWithContentRect: NSMakeRect(100, 100, 500, 600) styleMask: (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask) backing: NSBackingStoreBuffered defer: true]];
      [[characterWindowController window] setContentView: [characterViewController view]];
      [[characterWindowController window] setTitle: [character name]];
      [[characterWindowController window] setFrameAutosaveName: [NSString stringWithFormat: @"CharacterWindow.%@", [character name]]];
    }
    
    [characterWindowController showWindow: self];
  }
}

- (void) removeCharacter
{
  [character remove];
  [[Ceres instance] save];
}

- (void) notification: (NSNotification *) argument
{
  // [self updateCharacter: self];
}

@end

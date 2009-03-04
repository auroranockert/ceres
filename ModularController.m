//
//  ModularController.m
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

#import "ModularController.h"

@interface ModularController (Private)

- (void) setupToolbar;
- (void) selectModule: (NSToolbarItem *) sender;

@end

@implementation ModularController

@synthesize modules;

- (id) init
{
	if (self = [super init]) {
		NSWindow * window;
    if ([self resizable]) {
      window = [[NSWindow alloc] initWithContentRect: NSMakeRect(100, 100, 500, 600) styleMask: (NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask) backing: NSBackingStoreBuffered defer: true];
      [window setFrameAutosaveName: [NSString stringWithFormat: @"%@.Frame", [self autosaveKey]]];

    }
    else {
      window = [[NSWindow alloc] initWithContentRect: NSMakeRect(100, 100, 500, 600) styleMask: (NSTitledWindowMask | NSClosableWindowMask) backing: NSBackingStoreBuffered defer: true];
    }
    
    [window setShowsToolbarButton: false];
    
		[self setWindow: window];
		[self setupToolbar];
	}
  
	return self;
}

- (void) setupToolbar
{
	NSToolbar * toolbar = [[NSToolbar alloc] initWithIdentifier: [[self class] description]];
	[toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	[toolbar setAllowsUserCustomization: false];
	[toolbar setDelegate: self];
	[toolbar setAutosavesConfiguration: false];
	
  [[self window] setToolbar: toolbar];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	NSMutableArray * identifiers = [NSMutableArray array];
	for (id <Module> module in [self modules]) {
		[identifiers addObject: [module identifier]];
	}
	
	return identifiers;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	return nil;
}

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) itemIdentifier willBeInsertedIntoToolbar: (bool)flag
{
	id <Module> module = [self moduleForIdentifier: itemIdentifier];
	
	NSToolbarItem * item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
	if (!module) {
		return item;
  }
	
	[item setLabel: [module title]];
	[item setImage: [module icon]];
	[item setTarget: self];
	[item setAction: @selector(selectModule:)];
	return item;
}

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
{
	return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (id <Module>) moduleForIdentifier: (NSString *) identifier
{
	for (id <Module> module in [self modules]) {
		if ([[module identifier] compare: identifier] == NSOrderedSame) {
			return module;
		}
	}
	return nil;
}

- (void) setModules: (NSArray *) newModules
{
  modules = newModules;
    
  [self changeToModule: nil];
  
  // Reset the toolbar items
  NSToolbar * toolbar = [[self window] toolbar];
  NSInteger index = [[toolbar items] count] - 1;
  while (index >= 0) {
    [toolbar removeItemAtIndex: index];
    index--;
  }
  
  [toolbar setSelectedItemIdentifier: nil];
  
  // Add the new items
  for (id <Module> module in [self modules]) {
    [toolbar insertItemWithItemIdentifier: [module identifier] atIndex: [[toolbar items] count]];
  }
  
  // Change to the correct module
  if ([[toolbar items] count] != 0) {			
    // Check the autosave info
    id <Module> defaultModule = [self moduleForIdentifier: [[NSUserDefaults standardUserDefaults] stringForKey: [NSString stringWithFormat: @"%@.Module", [self autosaveKey]]]];
    
    if (!defaultModule) {
      defaultModule = [[self modules] objectAtIndex: 0];
    }
    
    [self changeToModule: defaultModule];
  }
  else {
    [[self window] close];
  }
}

- (void) selectModule: (NSToolbarItem *) sender
{
	if ([sender class] != [NSToolbarItem class]) {
    NSLog(@"Wrong class...");
		return;
  }
	
	id <Module> module = [self moduleForIdentifier: [sender itemIdentifier]];
	if (!module) {
		return;
  }
	
	[self changeToModule: module];
}

- (void) changeToModule: (id <Module>) module
{
  if (!module) {
    [[self window] setContentView: [[NSView alloc] init]];
    [[self window] setTitle: @"Empty"];
    [[[self window] toolbar] setSelectedItemIdentifier: nil];
    
    return;
  }
  
  if ([self resizable]) {
    [[self window] setContentView: [module view]];
  }
  else {
    [[currentModule view] removeFromSuperview];
    
    NSView * newView = [module view];
    
    // Resize the window
    NSRect newWindowFrame = [[self window] frameRectForContentRect: [newView frame]];
    newWindowFrame.origin = [[self window] frame].origin;
    newWindowFrame.origin.y -= newWindowFrame.size.height - [[self window] frame].size.height;
    [[self window] setFrame: newWindowFrame display: true animate: true];
    
    
    currentModule = module;
    [[[self window] contentView] addSubview: [currentModule view]];
  }
  
  [[self window] setTitle: [self windowTitle: module]];
  [[[self window] toolbar] setSelectedItemIdentifier: [module identifier]];
	
	// Autosave the selection
	[[NSUserDefaults standardUserDefaults] setObject: [module identifier] forKey: [NSString stringWithFormat: @"%@.Module", [self autosaveKey]]];
}

- (bool) resizable
{
  return false;
}

- (NSString *) windowTitle: (id <Module>) module
{
  return [module title];
}

- (NSString *) autosaveKey
{
  NSLog(@"No autosave key...");
  return @"Ceres.Modular";
}

@end

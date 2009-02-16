//
//  PreferencesController.m
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
//  Created by Jens Nockert on 2/16/09.
//

#import "PreferencesController.h"

NSString * PreferencesSelectionAutosaveKey = @"Ceres.PreferencesSelection";

@interface PreferencesController (Private)
- (void) setupToolbar;
- (void) selectModule: (NSToolbarItem *) sender;
- (void) changeToModule: (id <PreferencesModule>) module;
@end

@implementation PreferencesController

@synthesize modules;

- (id)init
{
	if (self = [super init]) {
		NSWindow * prefsWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 200) styleMask: (NSTitledWindowMask | NSClosableWindowMask) backing: NSBackingStoreBuffered defer: true];
		[prefsWindow setShowsToolbarButton: false];
		[self setWindow: prefsWindow];
		
		[self setupToolbar];
	}
	return self;
}

static PreferencesController * shared = nil;

+ (PreferencesController *) instance
{
	@synchronized(self) {
		if (!shared) {
			[[self alloc] init];
		}
	}
  
	return shared;
}

+ (id) allocWithZone: (NSZone *) zone
{
	@synchronized(self) {
		if (!shared) {
			shared = [super allocWithZone: zone];
			return shared;
		}
	}
	return nil; // on subsequent allocation attempts return nil
}

- (id) copyWithZone: (NSZone *) zone
{
	return self;
}

- (void) showWindow: (id)sender
{
	[[self window] center];
	[super showWindow: sender];
}

- (void) setupToolbar
{
	NSToolbar * toolbar = [[NSToolbar alloc] initWithIdentifier: @"PreferencesToolbar"];
	[toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	[toolbar setAllowsUserCustomization: false];
	[toolbar setDelegate: self];
	[toolbar setAutosavesConfiguration: false];
	
  [[self window] setToolbar: toolbar];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	NSMutableArray * identifiers = [NSMutableArray array];
	for (id <PreferencesModule> module in [self modules]) {
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
	id <PreferencesModule> module = [self moduleForIdentifier: itemIdentifier];
	
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

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
{
	return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (id <PreferencesModule>) moduleForIdentifier: (NSString *) identifier
{
	for (id <PreferencesModule> module in [self modules]) {
		if ([[module identifier] compare: identifier] == NSOrderedSame) {
			return module;
		}
	}
	return nil;
}

- (void) setModules: (NSArray *) newModules
{
	if (newModules != modules) {
		modules = newModules;
		
		// Reset the toolbar items
		NSToolbar * toolbar = [[self window] toolbar];
		if (toolbar) {
			NSInteger index = [[toolbar items] count] - 1;
			while (index > 0) {
				[toolbar removeItemAtIndex: index];
				index--;
			}
			
			// Add the new items
			for (id <PreferencesModule> module in [self modules]) {
				[toolbar insertItemWithItemIdentifier: [module identifier] atIndex: [[toolbar items] count]];
			}
		}
		
		// Change to the correct module
		if ([[self modules] count]) {
			id <PreferencesModule> defaultModule = nil;
			
			// Check the autosave info
			NSString * savedIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey: PreferencesSelectionAutosaveKey];
			defaultModule = [self moduleForIdentifier: savedIdentifier];
			
			if (!defaultModule) {
				defaultModule = [[self modules] objectAtIndex: 0];
			}
			
			[self changeToModule: defaultModule];
		}
		
	}
}

- (void) selectModule: (NSToolbarItem *) sender
{
	if ([sender class] != [NSToolbarItem class]) {
    NSLog(@"Wrong class...");
		return;
  }
	
	id <PreferencesModule> module = [self moduleForIdentifier: [sender itemIdentifier]];
	if (!module)
		return;
	
	[self changeToModule: module];
}

- (void) changeToModule: (id <PreferencesModule>)module
{
	[[currentModule view] removeFromSuperview];
	
	NSView * newView = [module view];
	
	// Resize the window
	NSRect newWindowFrame = [[self window] frameRectForContentRect: [newView frame]];
	newWindowFrame.origin = [[self window] frame].origin;
	newWindowFrame.origin.y -= newWindowFrame.size.height - [[self window] frame].size.height;
	[[self window] setFrame: newWindowFrame display: true animate: true];
	
	[[self.window toolbar] setSelectedItemIdentifier: [module identifier]];
	[[self window] setTitle: [module title]];
	
	currentModule = module;
	[[[self window] contentView] addSubview:[currentModule view]];
	
	// Autosave the selection
	[[NSUserDefaults standardUserDefaults] setObject: [module identifier] forKey: PreferencesSelectionAutosaveKey];
}

@end

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

@implementation PreferencesController

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
	return nil;
}

- (id) copyWithZone: (NSZone *) zone
{
	return self;
}

- (void) showWindow: (id) sender
{
  [super showWindow: sender];
	[[self window] center];
}

- (NSString *) windowTitle: (id <Module>) module
{
  return [NSString stringWithFormat: @"%@ Preferences", [module title]];
}

- (NSString *) autosaveKey
{
  return @"Ceres.PreferencesSelection";
}

@end

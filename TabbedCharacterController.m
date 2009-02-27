//
//  TabbedCharacterController.m
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

#import "TabbedCharacterController.h"


@implementation TabbedCharacterController

static TabbedCharacterController * shared = nil;

+ (TabbedCharacterController *) instance
{
	@synchronized(self) {
		if (!shared) {
			[[self alloc] init];
      
      [[shared window] setMinSize: NSMakeSize(400, 400)];
      
      [shared loadCharacters];
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

- (NSString *) autosaveKey
{
  return @"Ceres.CharacterSelection";
}

- (void) loadCharacters
{
  NSMutableArray * modulesArray = [NSMutableArray array];
  
  for (Character * character in [Character findWithSort: [[NSSortDescriptor alloc] initWithKey: @"order" ascending: true] predicate: [NSPredicate predicateWithValue: true]]) {
    [modulesArray addObject: [[CharacterViewController alloc] initWithNibName: @"Character" bundle: nil character: character]];
  }
  
	[self setModules: modulesArray];
}

- (bool) resizable
{
  return true;
}

@end

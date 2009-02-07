//
//  APIController.m
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
//  Created by Jens Nockert on 1/10/09.
//

#import "APIController.h"


@implementation APIController

- (void) openApiWindow: (id) sender
{
  [apiWindow setIsVisible: true];
  [apiWindow makeKeyAndOrderFront: self];
}

- (void) addApikey: (id) sender
{
  NSNumber * i = [NSNumber numberWithInteger: [[identifier stringValue] integerValue]];
  NSString * k = [apikey stringValue];
  
  Account * a = [[Account alloc] initWithIdentifier: i apikey: k];
  
  [self freeze];
  
  [self performSelectorOnMainThread: @selector(addCharacters:) withObject: a waitUntilDone: false];
}

- (void) addCharacters: (Account *) account
{
  NSArray * chars = [account requestCharacters];
  
  for(CharacterInfo * ci in chars)
  {
    [[Character alloc] initWithIdentifier: [ci identifier] account: account];
  }
  
  [self performSelectorOnMainThread: @selector(unfreeze) withObject: nil waitUntilDone: false];
  
  [[Ceres instance] save];
}

- (void) freeze
{
  [identifier setEnabled: false];
  [apikey setEnabled: false];
  [button setEnabled: false];
}

- (void) unfreeze
{
  [identifier setEnabled: true];
  [apikey setEnabled: true];
  [button setEnabled: true];
}

@end

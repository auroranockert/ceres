//
//  CharacterPreferencesController.m
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

#import "CharacterPreferencesController.h"


@implementation CharacterPreferencesController

- (void) loadView
{
  [super loadView];
  
  NSMutableAttributedString * text = [[apilink attributedStringValue] mutableCopy];
  NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"http://myeve.eve-online.com/api/", NSLinkAttributeName,
                               [NSColor blueColor], NSForegroundColorAttributeName,
                               [NSNumber numberWithInteger: NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
                               nil];
  [text addAttributes: attributes range: NSMakeRange(0, [text length])];
  [apilink setAttributedStringValue: text];  
}

- (NSString *) title
{
	return @"Character";
}

- (NSString *) identifier
{
	return @"Ceres.CharacterPreferences";
}

- (NSImage *) icon
{
	return [NSImage imageNamed: @"NSEveryone"];
}

- (void) addCharacters: (id) sender
{
  NSNumber * i = [NSNumber numberWithInteger: [[userid stringValue] integerValue]];
  NSString * k = [apikey stringValue];
  
  [userid setEnabled: false];
  [apikey setEnabled: false];
  [button setEnabled: false];

  [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0]];
  
  Account * account = [[Account alloc] initWithIdentifier: i apikey: k];
  NSArray * chars = [account requestCharacters];
  
  for(CharacterInfo * ci in chars)
  {
    [[Character alloc] initWithIdentifier: [ci identifier] account: account];
  }
  
  [[Ceres instance] save];  
  
  [userid setEnabled: true];
  [apikey setEnabled: true];
  [button setEnabled: true];
}

@end

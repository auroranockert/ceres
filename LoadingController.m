//
//  LoadingController.m
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

#import "LoadingController.h"


@implementation LoadingController

- (void) awakeFromNib
{
  [progressIndicator setUsesThreadedAnimation: true];
  [progressIndicator startAnimation: self];
  [[Loader instance] performSelectorOnMainThread: @selector(start:) withObject: self waitUntilDone: false];
}

- (void) downloadTimeout: (NSInteger) timer
{
  NSAlert * alert = [[NSAlert alloc] init];
  [alert setMessageText: @"Downloading the data failed, and no data is currently in the database."];
  [alert addButtonWithTitle: @"Cancel"];
  [alert runModal];
  [[NSApplication sharedApplication] terminate: self];
}

- (void) databaseNewer: (NSString *) version
{
  NSAlert * alert = [[NSAlert alloc] init];
  [alert setMessageText: @"The current database is newer than this version of Ceres."];
  [alert addButtonWithTitle: @"Cancel"];
  [alert runModal];
  [[NSApplication sharedApplication] terminate: self];
}

- (void) setText: (NSString *) text
{
  [textField setStringValue: text];
}

- (void) finished
{
  NSLog(@"Finished Loading");
  
  [window performSelectorOnMainThread: @selector(setIsVisible:) withObject: false waitUntilDone: false];
  [[Interface instance] performSelectorOnMainThread: @selector(loadNib:) withObject: @"Ceres" waitUntilDone: false];
}

@end

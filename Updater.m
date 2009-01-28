//
//  Updater.m
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
//  Created by Jens Nockert on 1/22/09.
//

#import "Updater.h"


@implementation Updater

static Updater * shared;

+ (Updater *) instance
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

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (void) prepare
{
  NSArray * characters = [Character find]; 
  for (Character * character in characters) {
    [character prepareMessages];
  }
}

- (void) update
{
  NSArray * characters = [Character find]; 
  for (Character * character in characters) {
    [character update];
  }
  
  [[ServerStatus instance] update];
  
  NSLog(@"Running");
  
  [self performSelector: @selector(update) withObject: nil afterDelay: 180];
}

@end

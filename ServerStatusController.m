//
//  ServerStatusController.m
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
//  Created by Jens Nockert on 1/11/09.
//

#import "ServerStatusController.h"


@implementation ServerStatusController

- (void) awakeFromNib
{
  static ServerStatusController * retainer;
  
  if (!retainer) {
    retainer = self;
    [[Ceres instance] addObserver: self selector: @selector(notification:) name: @"Ceres.server.playerCountUpdated" object: nil];
  }
  else {
    NSLog(@"ServerStatusController loaded several times, the current hack does not allow this");
  }
}

- (void) notification: (NSNotification *) notification
{
  if ([[notification object] integerValue]) {
    [serverStatus setStringValue: [NSString stringWithFormat: @"%@ players", [notification object]]];
  }
  else {
    [serverStatus setStringValue: @"Server offline"];
  }
}

@end

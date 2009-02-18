//
//  ServerStatus.m
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
//  Created by Jens Nockert on 12/14/08.
//

#import "ServerStatus.h"


@implementation ServerStatus

@synthesize online, players;

static ServerStatus * shared;

+ (ServerStatus *) instance
{
  @synchronized(self) {
    if (!shared) {
      [[self alloc] init];
      [shared invalidate];
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

- (void) update
{
  if ([cachedUntil timeIntervalSinceNow] < 0) {
    Api * api = [[Api alloc] init];
    NSXMLDocument * status = [api request: @"server/ServerStatus.xml.aspx"];
    
    if (!status) {
      NSLog(@"No server status xml available");
      return;
    }
    
    NSString * open = [[status readNode: @"/eveapi/result/serverOpen"] stringValue];
    cachedUntil = [status cachedUntil];
    if ([open compare: @"True"] == NSOrderedSame) {
      online = [NSNumber numberWithBool: true];
      players = [[status readNode: @"/eveapi/result/onlinePlayers"] numberValueInteger];
    }
    else {
      online = [NSNumber numberWithBool: false];
      players = [NSNumber numberWithInteger: 0];
    }
        
    NSNotification * notification = [NSNotification notificationWithName: @"Ceres.server.playerCountUpdated" object: [self players]]; //[NSNumber numberWithInteger: [self players]]];
    [[Ceres instance] postNotification: notification];
    
  }
}

- (void) invalidate
{
  cachedUntil = [[NSDate alloc] initWithTimeIntervalSinceNow: -1];
}

@end

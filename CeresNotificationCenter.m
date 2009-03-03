//
//  CeresNotificationCenter.m
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
//  Created by Jens Nockert on 3/3/09.
//

#import "CeresNotificationCenter.h"


@implementation CeresNotificationCenter

static CeresNotificationCenter * shared;

+ (CeresNotificationCenter *) instance
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

- (NSNotificationCenter *) notificationCenter
{
  if (!notificationCenter) {
    notificationCenter = [[NSNotificationCenter alloc] init];
  }
  
  return notificationCenter;  
}

- (NSNotificationQueue *) notificationQueue
{
  if (!notificationQueue) {
    notificationQueue = [[NSNotificationQueue alloc] initWithNotificationCenter: [self notificationCenter]];
  }
  
  return notificationQueue;
}

- (void) addObserver: (id) observer selector: (SEL) selector name: (NSString*) name object: (id) object
{
  [[self notificationCenter] addObserver: observer selector: selector name: name object: object];
}

- (void) postNotification: (NSNotification *) notification
{
  [[self notificationQueue] enqueueNotification: notification postingStyle: NSPostWhenIdle];
}

- (void) postNotification: (NSNotification *) notification date: (NSDate *) date
{
  [self cancelNotification: notification];
  
  NSMutableDictionary * objectDictionary = [notificationDictionary objectForKey: [notification object]];
  if (!objectDictionary) {
    objectDictionary = [[NSMutableDictionary alloc] init];
    [notificationDictionary setObject: objectDictionary forKey: [notification object]];
  } 
  
  [objectDictionary setValue: notification forKey: [notification name]]; 
  
  [self performSelector: @selector(postNotification:) withObject: notification afterDelay: [date timeIntervalSinceNow]];
}

- (void) cancelNotification: (NSNotification *) notification
{
  if (!notificationDictionary) {
    notificationDictionary = [[NSMutableDictionary alloc] init];
  }
  
  NSNotification * oldNotification = [[notificationDictionary objectForKey: [notification object]] objectForKey: [notification name]];
  if (oldNotification) {
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(postNotification:) object: oldNotification];
  }
}

@end

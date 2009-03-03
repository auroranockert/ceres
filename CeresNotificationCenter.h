//
//  CeresNotificationCenter.h
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

#import <Cocoa/Cocoa.h>


@interface CeresNotificationCenter : NSObject {  
  NSNotificationCenter * notificationCenter;
  NSNotificationQueue * notificationQueue;
  NSMutableDictionary * notificationDictionary;
}

+ (CeresNotificationCenter *) instance;

@property(retain, readonly) NSNotificationCenter * notificationCenter;
@property(retain, readonly) NSNotificationQueue * notificationQueue;

- (void) postNotification: (NSNotification *) notification;
- (void) postNotification: (NSNotification *) notification date: (NSDate *) date;
- (void) cancelNotification: (NSNotification *) notification;
- (void) addObserver: (id) observer selector: (SEL) selector name: (NSString *) name object: (id) object;

@end

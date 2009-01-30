//
//  Ceres.h
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
//  Created by Jens Nockert on 12/11/08.
//

// Frameworks

#import <Cocoa/Cocoa.h>

#import "Api.h"

@interface Ceres : NSObject {
  NSPersistentStoreCoordinator * persistentStoreCoordinator;
  NSManagedObjectModel * managedObjectModel;
  NSManagedObjectContext * managedObjectContext;
  
  NSNotificationCenter * notificationCenter;
  NSNotificationQueue * notificationQueue;
  NSMutableDictionary * notificationDictionary;
}

@property(retain) NSString * version;

+ (Ceres *) instance;

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator;
- (NSManagedObjectModel *) managedObjectModel;
- (NSManagedObjectContext *) managedObjectContext;
- (NSNotificationCenter *) notificationCenter;

- (void) save;
- (void) postNotification: (NSNotification *) notification;
- (void) postNotification: (NSNotification *) notification date: (NSDate *) date;
- (void) addObserver: (id) observer selector: (SEL) selector name: (NSString*) name object: (id) object;
- (void) handleError: (NSError *) error;

@end


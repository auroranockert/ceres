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

#import "CeresAdditions.h"

#import "Api.h"

enum CeresVersionComparison {
  ApplicationNewer    = 1,
  VersionSame   = 0,
  DatabaseNewer = -1,
  NoDatabase = -2
};
typedef enum CeresVersionComparison CeresVersionComparison;

@interface Ceres : NSObject {
  NSPersistentStoreCoordinator * persistentStoreCoordinator;
  NSManagedObjectModel * managedObjectModel;
  NSManagedObjectContext * managedObjectContext;
}

@property(copy) NSDictionary * metadata;
@property(copy) NSString * databaseVersion;
@property(copy, readonly) NSString * applicationVersion;

@property(retain, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;
@property(retain, readonly) NSPersistentStore * persistentStore;
@property(retain, readonly) NSManagedObjectContext * managedObjectContext;
@property(retain, readonly) NSManagedObjectModel * managedObjectModel;

@property(retain, readonly) NSURL * persistentStoreUrl;

- (NSString *) persistentStorePathForVersion: (NSString *) version;
- (NSString *) managedObjectModelPathForVersion: (NSString *) version;

+ (Ceres *) instance;

- (void) save;
- (void) handleError: (NSError *) error;
- (CeresVersionComparison) compareVersion;

@end


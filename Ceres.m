//
//  Ceres.m
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

#import "Ceres.h"

@implementation Ceres

static Ceres * shared;

+ (Ceres *) instance
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

- (NSDictionary *) metadata
{
  NSError * error = nil;
  return [NSPersistentStoreCoordinator metadataForPersistentStoreWithURL: [self persistentStoreUrl] error: &error];
}

- (void) setMetadata: (NSDictionary *) value
{
  [[self persistentStoreCoordinator] setMetadata: value forPersistentStore: [self persistentStore]];
}

- (NSString *) databaseVersion
{
  return [[self metadata] valueForKey: @"Version"];
}

- (void) setDatabaseVersion: (NSString *) version
{
  NSDictionary * metadata = [self metadata];
  
  if (!metadata) {
    metadata = [[NSMutableDictionary alloc] init];
  }
  
  [metadata setValue: version forKey: @"Version"];
  [self setMetadata: metadata];
}

- (NSString *) applicationVersion
{
  return @"0.0.14";
}

- (CeresVersionComparison) compareVersion
{
  NSArray * application, * database;
  
  NSLog(@"Application version: %@ Database version: %@", [self applicationVersion], [self databaseVersion]);
  
  if (![self databaseVersion]) {
    return NoDatabase;
  }
  
  application = [[self applicationVersion] componentsSeparatedByString: @"."];
  database = [[self databaseVersion] componentsSeparatedByString: @"."];
    
  for (int i = 0; i < 3; i++) {
    bool greater = [[application objectAtIndex: i] integerValue] > [[database objectAtIndex: i] integerValue];
    bool less = [[application objectAtIndex: i] integerValue] < [[database objectAtIndex: i] integerValue];
        
    if (greater) {
      return ApplicationNewer;
    }
    else if (less) {
      return DatabaseNewer;
    }
  }
  
  return VersionSame;
}

- (NSManagedObjectContext *) managedObjectContext
{
  if (!managedObjectContext) {
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
      managedObjectContext = [[NSManagedObjectContext alloc] init];
      [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
  }
  
  return managedObjectContext;
}

- (NSManagedObjectModel *) managedObjectModel
{
  if (!managedObjectModel) {
    
    // Load model from Ceres.framework bundle
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL fileURLWithPath: [self managedObjectModelPathForVersion: [self applicationVersion]]]];
  }
  
  return managedObjectModel;
}

- (NSString *) managedObjectModelPathForVersion: (NSString *) version
{
  NSString * path = nil;
  
  for (NSBundle * currentBundle in [NSBundle allBundles]) {
    path = [currentBundle pathForResource: @"Ceres" ofType: @"momd"];
    
    if (path) {
      break;
    }      
  }
  
  path = [NSString stringWithFormat: @"%@/Ceres %@.mom", path, version];
  return path;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
  if(!persistentStoreCoordinator) {
    NSError * error;
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if ( ![persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: [self persistentStoreUrl] options: nil error: &error] ) {
      [self handleError: error];
    }
  }
  
  return persistentStoreCoordinator;
}

- (NSPersistentStore *) persistentStore
{
  return [[[self persistentStoreCoordinator] persistentStores] anyObject];
}

- (NSString *) persistentStorePathForVersion: (NSString *) version
{
  NSFileManager * fileManager = [NSFileManager defaultManager];
  NSString * applicationSupportFolder = [[NSBundle mainBundle] applicationSupportFolder];
  
  if ( ![fileManager fileExistsAtPath: applicationSupportFolder isDirectory: nil] ) {
    [fileManager createDirectoryAtPath: applicationSupportFolder attributes: nil];
  }
  
  if (version) {
    return [applicationSupportFolder stringByAppendingPathComponent: [NSString stringWithFormat: @"Ceres %@.sqlite3", version]];
  }
  else {
    return [applicationSupportFolder stringByAppendingPathComponent: @"Ceres.sqlite3"];
  }
}

- (NSURL *) persistentStoreUrl
{
  return [NSURL fileURLWithPath: [self persistentStorePathForVersion: nil]];
}

- (void) save
{
  NSError * error;
  if ( ![[self managedObjectContext] save: &error] ) {
    [self handleError: error];
  }
}

- (void) handleError: (NSError *) error
{
  NSLog(@"Error > %@ (Info: %@)", error, [error userInfo]);
  
  for (NSError * innerError in [[error userInfo] objectForKey: NSDetailedErrorsKey]) {
    NSLog(@"\tInner Error > %@ (Info: %@)", innerError, [innerError userInfo]);
  }
}

@end

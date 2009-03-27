//
//  Loader.m
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
//  Created by Jens Nockert on 1/6/09.
//

#import "Loader.h"

@implementation Loader

static Loader * shared;

+ (Loader *) instance
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

- (void) start: (id) d
{
  delegate = d;
  [delegate setText: [NSString stringWithFormat: @"Loading Ceres (Version %@)", [[Ceres instance] applicationVersion]]];
  
  CeresVersionComparison versionComparison = [[Ceres instance] compareVersion];
  
  NSString * currentDatabase = [[Ceres instance] persistentStorePathForVersion: nil];
  NSString * newDatabase = [[NSBundle mainBundle] pathForResource: @"Ceres" ofType: @"sqlite3"];
  
  if (versionComparison == NoDatabase)
  {
    [delegate setText: @"Moving new database"];
    
    if(![[NSFileManager defaultManager] movePath: newDatabase toPath: currentDatabase handler: nil]) {
      NSLog(@"Failed to move new database, terminating.");
      [[NSApplication sharedApplication] terminate: self];
    }    
  }
  else if (versionComparison == DatabaseNewer) {
    [delegate databaseNewer: [[Ceres instance] databaseVersion]];
  }
  else if (versionComparison == ApplicationNewer) {
    NSString * databaseVersion = [[Ceres instance] databaseVersion];
    NSString * oldDatabase = [[Ceres instance] persistentStorePathForVersion: databaseVersion];
        
    [delegate setText: @"Moving old database"];
    
    if(![[NSFileManager defaultManager] movePath: currentDatabase toPath: oldDatabase handler: nil]) {
      NSLog(@"Failed to move old database, terminating.");
      [[NSApplication sharedApplication] terminate: self];
    }
    
    [delegate setText: @"Moving new database"];
    
    if(![[NSFileManager defaultManager] movePath: newDatabase toPath: currentDatabase handler: nil]) {
      NSLog(@"Failed to move new database, terminating.");
      [[NSApplication sharedApplication] terminate: self];
    }
    
    [delegate setText: [NSString stringWithFormat: @"Migrating from version %@", databaseVersion]];
    
    NSManagedObjectModel * oldManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL fileURLWithPath: [[Ceres instance] managedObjectModelPathForVersion: databaseVersion]]];
    
    NSError * error = nil;
    NSPersistentStoreCoordinator * oldPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: oldManagedObjectModel];
    if (![oldPersistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: [NSURL fileURLWithPath: oldDatabase] options: nil error: &error] ) {
      NSLog(@"Failed to open old persistent store, terminating.");
      [[NSApplication sharedApplication] terminate: self];
    }
    
    NSManagedObjectContext * oldManagedObjectContext = [[NSManagedObjectContext alloc] init];
    [oldManagedObjectContext setPersistentStoreCoordinator: oldPersistentStoreCoordinator];
    
    [self migrate: oldManagedObjectContext model: oldManagedObjectModel];
    
    [delegate setText: [NSString stringWithFormat: @"Migrating complete"]];
  }

  [delegate finished];
  
  [[Updater instance] performSelectorOnMainThread: @selector(prepare) withObject: nil waitUntilDone: false];
}

- (void) migrate: (NSManagedObjectContext *) from model: (NSManagedObjectModel *) model
{
  NSFetchRequest * oldCharacterFetchRequest = [[NSFetchRequest alloc] init];
  [oldCharacterFetchRequest setEntity: [[model entitiesByName] valueForKey: @"Character"]];
  
  NSError * error;
  NSArray * oldCharacters = [from executeFetchRequest: oldCharacterFetchRequest error: &error];
  
  for (NSManagedObject * character in oldCharacters) {
    NSManagedObject * account = [character valueForKey: @"account"];
    [[Character alloc] initWithIdentifier: [character valueForKey: @"identifier"] account: [[Account alloc] initWithIdentifier: [account valueForKey: @"identifier"] apikey: [account valueForKey: @"apikey"]]];
  }
}

@end


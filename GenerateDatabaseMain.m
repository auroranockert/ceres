//
//  GenerateDatabaseMain.m
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
//  Created by Jens Nockert on 3/4/09.
//

#import "GenerateDatabaseMain.h"

int main(int argc, char *argv[])
{
  objc_startCollectorThread();
  
  NSString * newDatabase = @"../../Generator/Data/Ceres.sqlite3";
  NSString * currentDatabase = [[Ceres instance] persistentStorePathForVersion: nil];
  NSString * oldDatabase = [[Ceres instance] persistentStorePathForVersion: @"Backup"];
  
  if (![[NSFileManager defaultManager] movePath: currentDatabase toPath: oldDatabase handler: nil]) {
    NSLog(@"Failed to move current database.");

    if (![[NSFileManager defaultManager] removeFileAtPath: currentDatabase handler: nil]) {
      NSLog(@"Failed to remove current database.");
    }
  }  
  
  [[Ceres instance] setDatabaseVersion: [[Ceres instance] applicationVersion]];
  
  Data * data = [[Data alloc] init];
  
  NSMutableDictionary * loaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Clones.xml",       [Clone class],
                                   @"Skills.xml",       [Skill class],
                                   @"MarketGroups.xml", [MarketGroup class],
                                   @"Groups.xml",       [Group class],
                                   @"Categories.xml",   [Category class],
                                   @"Implants.xml",     [Implant class],
                                   @"Requirements.xml", [RequiredSkill class],
                                   nil];
  
  NSMutableSet * futures = [NSMutableSet set];
  for (id key in [loaders allKeys])
  {
    IOHttpFuture * future = [[[IOHttpRequestChannel alloc] initWithUrl: [data url: [loaders objectForKey: key]]] get];
    [loaders setValue: future forKey: key]; 
    [futures addObject: future];
  }
  
  [[[IOCompositeFuture alloc] initWithFutures: futures] join];
  
  for (id key in [[loaders allKeys] sortedArrayUsingSelector: @selector(comparePriority:)])
  {
    NSError * error = nil;
    [key performSelector: @selector(load:) withObject: [[NSXMLDocument alloc] initWithData: [[loaders objectForKey: key] result] options: 0 error: &error]];
  }
  
  [[Ceres instance] save];
  
  if (![[NSFileManager defaultManager] removeFileAtPath: newDatabase handler: nil]) {
    NSLog(@"Failed to remove current database.");
  }  
  
  if(![[NSFileManager defaultManager] movePath: currentDatabase toPath: newDatabase handler: nil]) {
    NSLog(@"Failed to move current database.");
  }
  
  if(![[NSFileManager defaultManager] movePath: oldDatabase toPath: currentDatabase handler: nil]) {
    NSLog(@"Failed to move old database.");
  }  
  
  return 0;
}

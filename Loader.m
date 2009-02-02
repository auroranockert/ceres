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
  
  if ([[Ceres instance] compareVersion] == ApplicationNewer)
  {
    [[Ceres instance] setDatabaseVersion: [[Ceres instance] applicationVersion]];

    Data * data = [[Data alloc] init];
    
    NSMutableDictionary * loaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     @"Clones.xml",       [Clone class],
                                     @"Skills.xml",       [Skill class],
                                     @"MarketGroups.xml", [MarketGroup class],
                                     @"Groups.xml",       [Group class],
                                     @"Categories.xml",   [Category class],
                                     nil
                                     ];
    
    for (id key in [loaders allKeys])
    {
      NSURL * u = [data url: [loaders objectForKey: key]];
      URLDelegate * d = [[URLDelegate alloc] initWithURL: u];
      [loaders setValue: d forKey: key]; 
    }
    
    NSInteger finished = 0;
    NSInteger count = 0;
    NSInteger done, total;    
    while (finished < [loaders count]) {      
      finished = done = total = 0;
      for (URLDelegate * d in [loaders allValues])
      {
        done += [d receivedData];
        total += [d totalData];
        
        if ([d done]) {
          finished++;
        }
      }
      
      [delegate setText: [NSString stringWithFormat: @"Downloaded %d / %d files (%d / %d kB)", finished, [loaders count], done / 1024, total / 1024]];
      
      if (count > 180) {
        [delegate downloadTimeout: count];
      }
      else {
        count++;
      }
      
      [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0]];
    }
        
    finished = 0;
    double priority = [NSThread threadPriority];
    [NSThread setThreadPriority: 0.0];
    for (id key in [[loaders allKeys] sortedArrayUsingSelector: @selector(comparePriority:)])
    {
      [delegate setText: [NSString stringWithFormat: @"Parsing data (%d / %d files processed)", finished, [loaders count]]];
      NSThread * thread = [[NSThread alloc] initWithTarget: key selector: @selector(load:) object: [[loaders objectForKey: key] xml]];
      [thread start];
      
      while (![thread isFinished]) {
        [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.0]];
        [NSThread sleepForTimeInterval: 1.0];
      }
      
      finished++;
    }
    [NSThread setThreadPriority: priority];
    
    [[Ceres instance] save];
  }
  else if ([[Ceres instance] compareVersion] == DatabaseNewer)
  {
    [delegate databaseNewer: [[Ceres instance] databaseVersion]];
  }
  
  [delegate finished];
  
  [[Updater instance] performSelectorOnMainThread: @selector(prepare) withObject: nil waitUntilDone: true];
  [[Updater instance] performSelectorOnMainThread: @selector(update) withObject: nil waitUntilDone: false];
}

@end


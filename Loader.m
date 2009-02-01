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
  NSString * version = [self currentVersion];
  delegate = d;
  [delegate setText: [NSString stringWithFormat: @"Loading Ceres (Version %@)", version]];
  NSLog([[Ceres instance] version]);
  if ([version compare: [[Ceres instance] version]] != NSOrderedSame)
  {
    NSLog(@"Updating from %@", [[Ceres instance] version]);
    
    [[Ceres instance] setVersion: version];

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
    
    int finished = 0;
    
    while (finished < [loaders count]) {
      [[NSRunLoop currentRunLoop] runMode: @"Ceres.download"
                               beforeDate: [NSDate dateWithTimeIntervalSinceNow: 30.0]];
      finished = 0;
      for (URLDelegate * d in [loaders allValues])
      {
        if ([d done]) {
          finished++;
        }
      }
    }
    
    finished = 0;
    
    for (id key in [[loaders allKeys] sortedArrayUsingSelector: @selector(comparePriority:)])
    {
      [self text: [NSString stringWithFormat: @"Parsing data (%d / %d files processed)", finished, [loaders count]]];
      [key performSelector: @selector(load:) withObject: [[loaders objectForKey: key] xml]];
      finished++;
    }
    
    [[Ceres instance] save];
  }
  
  [delegate finished];
  
  [[Updater instance] performSelectorOnMainThread: @selector(prepare) withObject: nil waitUntilDone: true];
  [[Updater instance] performSelectorOnMainThread: @selector(update) withObject: nil waitUntilDone: false];
}

- (NSString *) currentVersion
{
  return @"0.0.8";
}
    
- (void) text: (NSString *) text
{
  NSLog(text);
  [delegate setText: text];
}

@end


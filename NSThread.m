//
//  NSThread.m
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
//  Created by Jens Nockert on 2/7/09.
//

#import "NSThread.h"


@implementation NSThread (CeresAdditions)

- (void) process: (NSArray *) object sender: (id) sender
{
  NSLock * lock = [[NSLock alloc] init];
  NSMutableSet * queue = [[NSMutableSet alloc] init];
  
  [[self threadDictionary] setObject: object forKey: @"Object"];
  [[self threadDictionary] setObject: queue forKey: @"Queue"];
  [[self threadDictionary] setObject: lock forKey: @"Lock"];    
  
  [self start];
  
  while ([self isExecuting] || [queue count]) {
    [lock lock];
    for (NSDictionary * dictionary in queue) {
      [[[sender class] alloc] initWithDictionary: dictionary];
      [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.0]];
    }
    [queue removeAllObjects];
    [lock unlock];
  }
}

@end

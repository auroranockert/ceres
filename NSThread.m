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

+ (void) process: (NSArray *) object sender: (id) sender selector: (SEL) selector
{
  NSLock * lock = [[NSLock alloc] init];
  NSMutableSet * queue = [[NSMutableSet alloc] init];
  
  NSArray * array = [NSArray arrayWithObjects: object, queue, lock, nil];
  
  NSInteger done = 0;
  
  NSThread * thread = [[NSThread alloc] initWithTarget: [sender class] selector: selector object: array];
  
  [thread start];
  
  while (![thread isFinished] || [queue count]) {
    [lock lock];
    NSSet * set = [queue copy];
    [queue removeAllObjects];
    [lock unlock];
    
    done += [set count];
    
    for (NSDictionary * dictionary in set) {
      [[[sender class] alloc] initWithDictionary: dictionary];
    }
    [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0]];
  }
  
  NSLog(@"Finished %d / %d %@", done, [object count], [sender class]);
}

@end

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
  
  NSInteger done = 0, total = [object count];
  ItemCount processors = MPProcessors();
  
  for (int i = 0; i < processors; i++) {
    NSRange range = NSMakeRange(i * (total / processors) + (total % processors), total / processors);
    
    if (i == 0) {
      range = NSMakeRange(0, (total / processors) + (total % processors));
    }
    
    NSArray * array = [NSArray arrayWithObjects: [object subarrayWithRange: range], queue, lock, nil];
    NSThread * thread = [[NSThread alloc] initWithTarget: [sender class] selector: selector object: array];
    
    [thread start];
  }
    
  while (done != total) {
    [lock lock];
    NSSet * set = [queue copy];
    [queue removeAllObjects];
    [lock unlock];
    
    done += [set count];
    
    for (NSDictionary * dictionary in set) {
      [[[sender class] alloc] initWithDictionary: dictionary];
    }
    
    NSLog(@"Finished %ld / %ld %@", done, total, [sender class]);
    
    [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0]];
  }
}

@end

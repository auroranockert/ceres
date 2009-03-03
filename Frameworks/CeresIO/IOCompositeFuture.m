//
//  IOCompositeFuture.m
//  This file is part of CeresIO.
//
//  CeresIO is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  CeresIO is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with CeresIO.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Jens Nockert on 3/3/09.
//

#import "IOCompositeFuture.h"

@implementation IOCompositeFuture

- (id) initWithFutures: (NSSet *) f;
{
  if (self = [super init]) {
    futures = f;
    finished = 0;
    
    for (IOFuture * future in futures) {
      [future addObserver: self selector: @selector(process:)];
    }
  }
  
  return self;
}

- (void) process: (IOFuture *) future
{
  finished += 1;
  
  if (finished == [futures count]) {
    [self setOperationComplete: true];
    [self performSelectorOnMainThread: @selector(notify) withObject: nil waitUntilDone: true];
  }
}

- (id) result
{
  [self join];
  
  return futures;
}

@end

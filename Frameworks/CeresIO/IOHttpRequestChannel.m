//
//  IOHTTPGetRequestChannel.m
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
//  Created by Jens Nockert on 3/2/09.
//

#import "IOHttpRequestChannel.h"

@implementation IOHttpRequestChannel

- (id) initWithUrl: (NSURL *) u
{
  if (self = [super init]) {
    url = u;
  }
  
  return self;
}

- (IOFuture *) receive
{
  return [self get];
}

- (IOHttpFuture *) get
{
  return [[IOHttpFuture alloc] initWithUrl: url];
}

- (void) close
{
  url = nil;
}

- (bool) isOpen
{
  return !url;
}

@end
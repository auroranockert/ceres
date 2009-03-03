//
//  IOHTTPReadFuture.m
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

#import "IOHttpFuture.h"


@implementation IOHttpFuture

- (id) initWithUrl: (NSURL *) u
{
  if (self = [super init]) {
    url = u;
    
    [NSThread detachNewThreadSelector: @selector(startDownload) toTarget: self withObject: nil];
  }
  
  return self;
}

- (void) startDownload
{
  data = [[NSData alloc] initWithContentsOfURL: url];
  [self performSelectorOnMainThread: @selector(notify) withObject: nil waitUntilDone: false];
  [self setOperationComplete: true];
}

- (NSData *) result
{
  [super result];
  
  return data;
}

- (NSURL *) url
{
  return url;
}

@end

//
//  URLLoaderDelegate.m
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
//  Created by Jens Nockert on 1/8/09.
//

#import "URLDelegate.h"


@implementation URLDelegate

@synthesize data, totalData, receivedData, done;

- (id) initWithURL: (NSURL *) url
{
  if (self = [super init]) {
    [self setDone: false];
    [self setTotalData: NSURLResponseUnknownLength];
    [self setReceivedData: 0];
    [[[URLLoader alloc] initWithURL: url delegate: self] start];
  }
  
  return self;
}

- (void) willReceive: (NSInteger) length
{
  [self setTotalData: length];
}

- (void) hasReceived: (NSInteger) length
{
  [self setReceivedData: length];
}

- (void) finished: (NSData *) d
{
  [self setData: d];
  [self setDone: true];
}

- (NSXMLDocument *) xml
{
  NSError * error;
  return [[NSXMLDocument alloc] initWithData: [self data] options: 0 error: &error];
}

@end

//
//  URLLoader.m
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

#import "URLLoader.h"

enum {
  URLLoaderInit = 1,
  URLLoaderLoading,
  URLLoaderFinished,
  URLLoaderCancelled
};

@implementation URLLoader

@synthesize error;

- (id) initWithURL: (NSURL *) u delegate: (id) d
{
  if (self = [super init]) {
    status = URLLoaderInit;
    url = [u copy];
    receivedData = [NSMutableData data];
    error = nil;
    delegate = d;
    lock = [[NSRecursiveLock alloc] init];
    connection = nil;
  }
  
  return self;
}

- (void) start
{
  [lock lock];
  NSLog(@"Starting load of url > %@", url);
  status = URLLoaderLoading;
  connection = [[NSURLConnection alloc] initWithRequest: [NSURLRequest requestWithURL: url] delegate: self startImmediately: NO];
  [connection scheduleInRunLoop: [NSRunLoop currentRunLoop] forMode: @"Ceres.download"];
  [connection start];
  [lock unlock];
}

- (void) cancel
{
  [lock lock];
  
  //return right away if we are not loading.
  if (status != URLLoaderLoading) {
    [lock unlock];
    return;
  }
  
  status = URLLoaderCancelled;
  
  if (connection) {
    [connection cancel];
  }
  [receivedData setLength: 0];
  
  [lock unlock];
}

- (void) willReceive: (NSInteger) length
{
  if (delegate && [delegate respondsToSelector: @selector(willReceive:)]) {
    [delegate willReceive: length];
  }  
}
- (void) hasReceived: (NSInteger) length
{
  if (delegate && [delegate respondsToSelector: @selector(hasReceived:)]) {
    [delegate hasReceived: length];
  }    
}

- (void) finished
{
  NSAssert(status != URLLoaderFinished, @"Why am I here if I already finished.");
  status = URLLoaderFinished;
  
  if (delegate && [delegate respondsToSelector: @selector(finished:)]) {
    [delegate finished: receivedData];
  }
}

/* NSURLConnection Delegates */

- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response
{
  [lock lock];
  NSAssert(status == URLLoaderLoading, @"I should be loadiing.");
  expectedLength = [response expectedContentLength];
  [self willReceive: expectedLength];
  [lock unlock];

}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) d
{
  [lock lock];
  NSAssert(status == URLLoaderLoading, @"I should be loadiing.");
  [receivedData appendData: d];
  
  [self hasReceived: [receivedData length]];
  
  [lock unlock];
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) e
{
  [lock lock];
  [receivedData setLength: 0];
  [self setError: e];
  [self finished];
  [lock unlock];
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
  [lock lock];
  [self setError: nil];
  [self finished];
  [lock unlock];
}

@end

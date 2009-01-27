//
//  URLLoader.h
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

#import <Cocoa/Cocoa.h>

@interface URLLoader : NSObject {
  int status;
  NSURL * url;
  NSMutableData * receivedData;
  NSData * data;
  NSError * error;
  id delegate;
  NSRecursiveLock * lock;
  NSURLConnection * connection;
  NSInteger expectedLength;
}

@property(retain) NSError * error;

- (id) initWithURL: (NSURL *)  url delegate: (id) delegate;
- (void) finished;
- (void) start;
- (void) cancel;

@end

@interface NSObject (URLLoaderDelegate)

- (void) willReceive: (NSInteger) length;
- (void) hasReceived: (NSInteger) length;
- (void) finished: (NSData *) data;

@end

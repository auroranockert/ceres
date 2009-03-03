//
//  Xml.m
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
//  Created by Jens Nockert on 12/27/08.
//

#import "Xml.h"


@implementation Xml

- (NSURL *) url: (NSString *) url
{
  return [NSURL URLWithString: url];
}

- (IOHttpFuture *) request: (NSString *) url target: (id) target selector: (SEL) selector;
{
  IOHttpRequestChannel * channel = [[IOHttpRequestChannel alloc] initWithUrl: [self url: url]];
  
  IOHttpFuture * future = [channel get];
  [future addObserver: target selector: selector];
  return future;
}

@end

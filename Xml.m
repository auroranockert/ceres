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

- (NSXMLDocument *) request: (NSString *) urlstring
{
  NSURL * url = [NSURL URLWithString: urlstring];
  
  URLDelegate * delegate = [[URLDelegate alloc] initWithURL: url];
  
  while (![delegate done]) {
    [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
  }
  
  NSError * error = nil;
  if ([[delegate data] length] != 0) {
    return [[NSXMLDocument alloc] initWithData: [delegate data] options: 0 error: &error];
  }
  else {
    NSLog(@"No data, did finished get called?");
    return nil;
  }  
}

@end

//
//  Data.m
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
//  Created by Jens Nockert on 12/13/08.
//

#import "Data.h"


@implementation Data

- (id) init
{
  if (self = [super init]) {
    dataApi = @"http://Ceres.doesntexist.org/xml/0.0.2/";
  }
  
  return self;
}

- (NSURL *) url: (NSString *) file
{
  return [NSURL URLWithString: [dataApi stringByAppendingString: file]];
}

- (NSXMLDocument *) request: (NSString *) file
{
  NSString * urlString = [dataApi stringByAppendingString: file]; 
  
  return [super request: urlString];
}

- (NSXMLDocument *) requestVersion
{
  static NSXMLDocument * version;
  
  if (!version) {
    version = [self request: @"Version.xml"];
  }
  
  return version;
}

@end

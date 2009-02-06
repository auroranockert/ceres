//
//  NSXMLDocument.m
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
//  Created by Jens Nockert on 2/6/09.
//

#import "NSXMLDocument.h"

@implementation NSXMLDocument (CeresAdditions)

- (NSArray *) readNodes: (NSString *) xpath
{
  NSError * error;
  return [self nodesForXPath: xpath error: &error];
}

- (NSXMLNode *) readNode: (NSString *) xpath
{
  return [[self readNodes: xpath] anyObject];
}

- (NSDate *) cachedUntil
{
  NSXMLNode * currentTimeNode = [self readNode: @"/eveapi/currentTime"];
  NSXMLNode * cachedUntilNode = [self readNode: @"/eveapi/cachedUntil"];
  
  NSString * currentTimeString = [[currentTimeNode stringValue] stringByAppendingString: @" +0000"];
  NSString * cachedUntilString = [[cachedUntilNode stringValue] stringByAppendingString: @" +0000"];
  
  NSDate * currentTime = [[NSDate alloc] initWithString: currentTimeString];
  NSDate * cachedUntil = [[NSDate alloc] initWithString: cachedUntilString];
  
  return [[NSDate alloc] initWithTimeIntervalSinceNow: [cachedUntil timeIntervalSinceDate: currentTime]];
}

@end


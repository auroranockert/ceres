//
//  NSXMLNode.m
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

#import "NSXMLNode.h"

@implementation NSXMLNode (CeresAdditions)

- (NSArray *) readNodes: (NSString *) xpath
{
  NSError * error;
  return [self objectsForXQuery: [[self XPath] stringByAppendingString: xpath] error: &error];
}

- (NSXMLNode *) readNode: (NSString *) xpath
{
  return [[self readNodes: xpath] anyObject];
}

- (NSString *) readAttribute: (NSString *) attribute
{
  return [[self readNode: [[NSString alloc] initWithFormat: @"/@%@", attribute]] stringValue];
}

- (NSNumber *) numberValueInteger
{
  return [NSNumber numberWithInteger: [self integerValue]];
}

- (NSNumber *) numberValueDouble
{
  return [NSNumber numberWithDouble: [[self stringValue] doubleValue]];
}

- (NSInteger) integerValue
{
  return [[self stringValue] integerValue];
}

@end

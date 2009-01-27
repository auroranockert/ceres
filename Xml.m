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
    [[NSRunLoop currentRunLoop] runMode: @"Ceres.download"
                             beforeDate: [NSDate dateWithTimeIntervalSinceNow: 30.0]];
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

@implementation NSXMLDocument (CeresXmlProcessing)

- (NSArray *) readNodes: (NSString *) xpath
{
  NSError * error;
  return [self nodesForXPath: xpath error: &error];
}

- (NSXMLNode *) readNode: (NSString *) xpath
{
  return [[self readNodes: xpath] objectAtIndex: 0];
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

@implementation NSXMLNode (CeresXmlProcessing)

- (NSArray *) readNodes: (NSString *) xpath
{
  NSError * error;
  return [self objectsForXQuery: [[self XPath] stringByAppendingString: xpath] error: &error];
}

- (NSXMLNode *) readNode: (NSString *) xpath
{
  return [[self readNodes: xpath] objectAtIndex: 0];
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
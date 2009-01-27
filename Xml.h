//
//  Xml.h
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

#import <Cocoa/Cocoa.h>

#import "URLLoader.h"
#import "URLDelegate.h"

@interface Xml : NSObject {
  
}

- (NSXMLDocument *) request: (NSString *) url;

@end

@interface NSXMLDocument (CeresXmlProcessing)

- (NSArray *) readNodes: (NSString *) xpath;
- (NSXMLNode *) readNode: (NSString *) xpath;
- (NSDate *) cachedUntil;

@end

@interface NSXMLNode (CeresXmlProcessing)

- (NSArray *) readNodes: (NSString *) xpath;
- (NSXMLNode *) readNode: (NSString *) xpath;
- (NSString *) readAttribute: (NSString *) xpath;
- (NSNumber *) numberValueInteger;
- (NSNumber *) numberValueDouble;
- (NSInteger) integerValue;

@end
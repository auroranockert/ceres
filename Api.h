//
//  Api.h
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
//  Created by Jens Nockert on 12/8/08.
//

#import <Cocoa/Cocoa.h>

#import "Xml.h"

@interface Api : Xml {
  NSNumber * identifier, * characterIdentifier;
  NSString * apikey, * imageApi, * methodApi;
  bool account, character;
}

- (id) initWithIdentifier: (NSNumber *) ident
                   apikey: (NSString *) key
      characterIdentifier: (NSNumber *) cha;

- (id) initWithIdentifier: (NSNumber *) ident
                   apikey: (NSString *) key;

- (bool) isAccountApiAvailable;
- (bool) isCharacterApiAvailable;

- (NSImage *) requestImage: (NSNumber *) image;
- (NSImage *) requestImage: (NSNumber *) image
                      size: (NSInteger) size;

- (NSXMLDocument *) request: (NSString *) method;

@end

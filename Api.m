//
//  Api.m
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

#import "Api.h"

@implementation Api

- (id) initWithIdentifier: (NSNumber *) ident
                   apikey: (NSString *) key
      characterIdentifier: (NSNumber *) cha
{
  if (self = [super init]) {
    identifier = ident;
    characterIdentifier = cha;
    apikey = key;
    
    // methodApi = [[NSString alloc] initWithString: @"http://Ceres.doesntexist.org/xml/api/"];
    methodApi = [[NSString alloc] initWithString: @"http://api.eve-online.com/"];
    imageApi = [[NSString alloc] initWithString: @"http://img.eve.is/serv.asp"];
  }
  return self;
}

- (id) initWithIdentifier: (NSNumber *) ident
                   apikey: (NSString *) key
{
  return [self initWithIdentifier: ident
                           apikey: key
              characterIdentifier: 0];
}

- (id) init
{
  return [self initWithIdentifier: nil
                           apikey: nil
              characterIdentifier: nil];
}

- (NSXMLDocument *) request: (NSString *) method
{
  NSString * urlString = [methodApi stringByAppendingString: method];  
  if (identifier)
  {
    urlString = [urlString stringByAppendingFormat: @"?userId=%d&apiKey=%@", [identifier integerValue], apikey];
  }
  
  if (characterIdentifier)
  {
    urlString = [urlString stringByAppendingFormat: @"&characterId=%d", [characterIdentifier integerValue]];
  }
  
  return [super request: urlString];
}

- (NSImage *) requestImage: (NSNumber *) image
{
  return [self requestImage: image
                       size: 256];
}
                     
- (NSImage *) requestImage: (NSNumber *) image
                      size: (NSInteger) size
{
  NSString * urlString = [[imageApi stringByAppendingFormat: @"?s=%d", size] stringByAppendingFormat: @"&c=%d", [image integerValue]];

  NSURL * url = [[NSURL alloc] initWithString: urlString];
  return [[NSImage alloc] initWithContentsOfURL: url];
}

- (bool) isAccountApiAvailable
{
  return account;
}

- (bool) isCharacterApiAvailable
{
  return character;
}

@end

//
//  Account.m
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

#import "Account.h"


@implementation Account

@dynamic identifier, apikey;
@dynamic characters;
@dynamic cachedUntil;

- (id) initWithIdentifier: (NSNumber *) ident apikey: (NSString *) key
{
  if (self = [super initWithIdentifier: ident]) {
    [self setApikey: key];
    [self invalidate];
  }
  
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  static NSEntityDescription * entDescription;
  
  if (!entDescription) {
    entDescription = [[[[Ceres instance] managedObjectModel] entitiesByName] objectForKey: @"Account"];
  }
  
  return entDescription;  
}

- (Api *) initializeApi
{
  return [[Api alloc] initWithIdentifier: [self identifier] apikey: [self apikey]];
}

- (NSArray *) requestCharacters
{
  if([[self cachedUntil] timeIntervalSinceNow] < 0)
  {
    NSXMLDocument * document = [[self api] request: @"account/Characters.xml.aspx"];
    NSArray * characterNodes = [document readNodes: @"/eveapi/result/rowset/row"];
        
    [self setCachedUntil: [document cachedUntil]];
    
    chars = [[NSMutableArray alloc] init];
    
    for(NSXMLNode * node in characterNodes)
    {
      NSString * characterName = [node readAttribute: @"name"];
      NSNumber * characterId = [NSNumber numberWithInteger: [[node readAttribute: @"characterID"] integerValue]];
      NSString * corporationName = [node readAttribute: @"corporationName"];
      NSNumber * corporationId = [NSNumber numberWithInteger: [[node readAttribute: @"corporationID"] integerValue]];
      
      CorporationInfo * corporation = [[CorporationInfo alloc] initWithIdentifier: corporationId
                                                                             name: corporationName];
      CharacterInfo * character = [[CharacterInfo alloc] initWithIdentifier: characterId
                                                                       name: characterName
                                                                corporation: corporation 
                                                                    account: self];
      [chars addObject: character];
    }
    
    if ([chars count] > 0) {
      return chars;
    } else {
      return nil;
    }
  }
  else
  {
    return chars;
  }
}

- (void) invalidate
{
  [self setCachedUntil: [[NSDate alloc] initWithTimeIntervalSinceNow: -1]];
}

@end

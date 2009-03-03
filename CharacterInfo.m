//
//  CharacterInfo.m
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

#import "CharacterInfo.h"


@implementation CharacterInfo

@synthesize identifier, name, account, corporation;

- (id) initWithIdentifier: (NSNumber *) ident
                     name: (NSString *) n
              corporation: (CorporationInfo *) corp
                  account: (Account *) acc
{
  if (self = [super init]) {
    [self setIdentifier: ident];
    [self setName: n];
    [self setCorporation: corporation];
    [self setAccount: acc];
  }
  
  return self;
}

@end

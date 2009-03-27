//
//  CacheMenuItem.m
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
//  Created by Jens Nockert on 2/23/09.
//

#import "CacheMenuItem.h"


@implementation CacheMenuItem

- (id) initWithCharacter: (Character *) c type: (NSString *) t
{
  if (self = [super init]) {
    character = c;
    if ([t compare: @"Character"] == NSOrderedSame) {
      characterCache = true;
    }
  }
  
  return self;
}

- (NSString *) title
{
  if (characterCache) {
    return [NSString stringWithFormat: @"Character sheet updated %@", [[character cachedUntil] preferedDateFormatString]];
  }
  else {
    return [NSString stringWithFormat: @"Queue updated %@", [[character queueCachedUntil] preferedDateFormatString]];
  }
}

@end

//
//  CharacterNotification.m
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
//  Created by Jens Nockert on 1/26/09.
//

#import "CharacterNotification.h"


@implementation CharacterNotification

- (id) initWithCharacter: (Character *) character name: (NSString *) n
{
  if (self = [super initWithObject: (id) character name: n]) {
    
  }
  
  return self;
}

+ (CharacterNotification *) notificationWithCharacter: (Character *) character name: (NSString *) n;
{
  return [[CharacterNotification alloc] initWithCharacter: character name: [NSString stringWithFormat: @"character.%@", n]];
}

+ (NSString *) nameForMessage: (NSString *) message
{
  return [NSString stringWithFormat: @"%@.%@", [super nameForMessage: @"character"], message];
}

- (Character *) character
{
  return (Character *) object;
}

@end

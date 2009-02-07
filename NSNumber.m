//
//  NSNumber.m
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

#import "NSNumber.h"


@implementation NSNumber (CeresAdditions)

- (NSNumber *) next
{
  return [NSNumber numberWithInteger: [self integerValue] + 1];
}

- (NSNumber *) previous
{
  return [NSNumber numberWithInteger: [self integerValue] - 1];
}

- (NSNumber *) addInteger: (NSNumber *) other
{
  return [NSNumber numberWithInteger: [self integerValue] + [other integerValue]];
}

- (NSNumber *) subtractInteger: (NSNumber *) other
{
  return [NSNumber numberWithInteger: [self integerValue] - [other integerValue]];
}

- (NSString *) romanValue
{
  switch ([self integerValue]) {
    case 0:
      return @"0";
    case 1:
      return @"I";
    case 2:
      return @"II";
    case 3:
      return @"III";
    case 4:
      return @"IV";
    case 5:
      return @"V";
    default:
      return nil;
  }
}

@end

//
//  NSNumberFormatting.m
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
//  Created by Jens Nockert on 2/16/09.
//

#import "NSNumberFormatting.h"


@implementation NSNumber (CeresFormattingAdditions)

+ (NSNumberFormatter *) formatter: (NSInteger) fractionDigits
{
  NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
  [formatter setMinimumFractionDigits: fractionDigits];
  [formatter setMaximumFractionDigits: fractionDigits];

  return formatter;
}

- (NSString *) levelString
{
  if ([[[NSUserDefaults standardUserDefaults] valueForKey: @"skillLevels"] compare: @"Arabic"] == NSOrderedSame) {
    return [self stringValue];
  }
  else {
    return [self romanValue];
  }
}

- (NSString *) iskString
{
  return [NSString stringWithFormat: @"%@", [[[self class] formatter: 2] stringFromNumber: self]];
}

- (NSString *) spString
{
  return [NSString stringWithFormat: @"%@", [[[self class] formatter: 0] stringFromNumber: self]];
}

- (NSString *) attributeString
{
  return [NSString stringWithFormat: @"%@", [[[self class] formatter: 2] stringFromNumber: self]];
}

- (NSString *) percentString
{
  return [NSString stringWithFormat: @"%@", [[[self class] formatter: 0] stringFromNumber: [NSNumber numberWithDouble: [self doubleValue] * 100.0]]];
}

@end

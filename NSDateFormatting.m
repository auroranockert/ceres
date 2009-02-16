//
//  NSDateFormatting.m
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

#import "NSDateFormatting.h"


@implementation NSDate (CeresFormattingAdditions)

- (NSString *) preferedDateFormat
{
  NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
  
  if ([[defaults valueForKey: @"skillLevels"] compare: @"Absolute"] == NSOrderedSame) {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"'by' HH:mm 'on' MMMM d"];
    
    return [dateFormatter stringFromDate: self];
  }
  else {
    NSInteger time = (NSInteger)[self timeIntervalSinceNow];
    
    const int secondsPerMinute = 60;
    const int secondsPerHour = 60 * secondsPerMinute;
    const int secondsPerDay = 24 * secondsPerHour;
    
    NSInteger seconds, minutes, hours, days;
    days = time / secondsPerDay;
    hours = (time % secondsPerDay) / secondsPerHour;
    minutes = (time % secondsPerHour) / secondsPerMinute;
    seconds = time % secondsPerMinute;
    
    if (days) {
      return [NSString stringWithFormat: @"in %d days %d hours", days, hours];
    }
    else if (hours) {
      return [NSString stringWithFormat: @"in %d hours %d minutes", hours, minutes];
    }
    else if (minutes) {
      return [NSString stringWithFormat: @"in %d minutes %d seconds", minutes, seconds];
    }
    else {
      return [NSString stringWithFormat: @"in %d seconds", seconds];
    }
  }
}

@end

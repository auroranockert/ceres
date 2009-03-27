//
//  CeresNotification.m
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
//  Created by Jens Nockert on 1/22/09.
//

#import "CeresNotification.h"

@implementation CeresNotification

- (id) initWithObject: (id) o name: (NSString *) n
{
  object = o;
  name = [[self class] nameForMessage: n];
  
  return self;
}

+ (CeresNotification *) notificationWithObject: (id) o name: (NSString *) n
{
  return [[CeresNotification alloc] initWithObject: o name: n];
}

+ (NSString *) nameForMessage: (NSString *) message
{
  return [NSString stringWithFormat: @"Ceres.%@", message];
}

- (id) object
{
  return object;
}

- (NSDictionary *)userInfo
{
  return [[NSDictionary alloc] init];
}

- (NSString *) name
{
  return name;
}

@end

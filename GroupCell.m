//
//  GroupCell.m
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
//  Created by Jens Nockert on 2/22/09.
//

#import "GroupCell.h"


@implementation GroupCell

@synthesize group;

- (id) initWithCharacter: (Character *) c
{
  if (self = [super init]) {
    character = c;
    [self setPadding: 10.0];
  }
  
  return self;
}

static NSMutableDictionary * images;

+ (NSImage *) imageForGroup: (Group *) g
{
  if (!images) {
    images = [NSMutableDictionary dictionary];
  }
  
  if (![images objectForKey: g]) {
    [images setObject: [[NSImage imageNamed: [g name]] flip] forKey: g];
  }
  
  return [images objectForKey: g];
}

- (void) setObjectValue: (id) object
{
  [self setGroup: object];
}

- (NSImage *) image
{
  return [GroupCell imageForGroup: group];
}

- (NSString *) name
{
  return [group name];
}

- (NSFont *) nameFont
{
  return [NSFont systemFontOfSize: 14];  
}

- (NSString *) subString
{
  NSString * training = @"";
  NSNumber * skills = [character skillsForGroup: group];
  
  if ([[[character trainingSkill] skill] group] == group) {
    training = @", (1 in training)";
  }
  
  if ([skills compare: [NSNumber numberWithInteger: 1]] == NSOrderedSame) {
    return [NSString stringWithFormat: @"%@ Skill, %@ skillpoints%@", skills, [[character skillpointsForGroup: group] spString], training];
  }
  else {
    return [NSString stringWithFormat: @"%@ Skills, %@ skillpoints%@", skills, [[character skillpointsForGroup: group] spString], training]; 
  }
}

@end

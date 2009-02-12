//
//  SkillCell.m
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
//  Created by Jens Nockert on 1/31/09.
//

#import "SkillCell.h"


@implementation SkillCell

@synthesize skill, group;

- (id)copyWithZone: (NSZone *) zone
{
	SkillCell * newCell = [super copyWithZone: zone];
  
  [newCell setSkill: [self skill]];
  
	return newCell;
}

- (void) setObjectValue: (id) object
{  
  [super setObjectValue: object];
  
  if ([object class] == [TrainedSkill class]) {
    [self setSkill: object];
    [self setGroup: nil];
  }
  else if ([object class] == [Group class]) {
    [self setSkill: nil];
    [self setGroup: object];
  }
}

- (NSImage *) image
{
  return nil;
}

- (NSString *) name
{
  if (skill) {
    return [skill name];
  }
  
  return [group name];
}

- (NSFont *) nameFont
{
  if (skill) {
    return [NSFont systemFontOfSize: 12];
  }
  
  return [NSFont systemFontOfSize: 16];  
}

- (NSString *) subString
{
  if ([self skill]) {
    return [NSString stringWithFormat: @"Level %@ (%@ SP)", [[skill level] romanValue], [skill skillpoints]];
  }
  
  return nil;
}

@end

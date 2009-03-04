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

@synthesize skill;

- (id) initWithCharacter: (Character *) c
{
  if (self = [super init]) {
    character = c;
    [self setPadding: 9.0];
    [self setImageTextPadding: 0.0];
  }
  
  return self;
}

- (void) setObjectValue: (id) object
{  
  [self setSkill: object];
}

- (NSImage *) image
{
  if ([[skill level] compare: [NSNumber numberWithInteger: 5]] == NSOrderedSame) {
    return [SkillListController finishedSkillImage];
  }
  else if ([skill partiallyTrained]) {
    return [SkillListController partialSkillImage];
  }
  else {
    return [SkillListController skillImage];
  }
}

- (NSString *) name
{
  return [NSString stringWithFormat: @"%@ (Rank %@)", [skill name], [[skill skill] rank]];
}

- (NSFont *) nameFont
{
  return [NSFont systemFontOfSize: 12];
}

- (NSString *) subString
{
  NSString * training = @"";
  
  if ([self skill] == [character trainingSkill]) {
    training = @", in training";
  }
  
  return [NSString stringWithFormat: @"Level %@, %@ SP (%@%% done%@)", [[skill level] levelString], [[skill currentSkillpoints] spString], [[skill percentDone] percentString], training];
}

@end

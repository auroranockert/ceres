//
//  CharacterTable.m
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
//  Created by Jens Nockert on 1/16/09.
//

#import "CharacterCell.h"

@implementation CharacterCell

@synthesize character;

- (id) initWithController: (CharacterListController *) controller
{
	if (self = [super init]) {    
    characterListController = controller;
	}
  
	return self;
}

- (NSString *) training
{
  if ([[self character] trainingSkill])
  {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm 'on' MMMM d"];
    NSInteger current = [[[self character] trainingCurrentSkillpoints] integerValue];
    
    if ([[[[self character] trainingSkill] requiredSkillpointsForNextLevel] integerValue] == 0) {
      return [[NSString alloc] initWithFormat: @"Training %@ to level %@ is finished", [[[[self character] trainingSkill] skill] name], [[[self character] trainingSkill] nextLevel]];
    }
    else {
      return [[NSString alloc] initWithFormat: @"Training %@ to level %@ and is finished by %@", [[[[self character] trainingSkill] skill] name], [[[self character] trainingSkill] nextLevel], [formatter stringFromDate: [[self character] trainingEndsAt]]];
    }
  }
  else
  {
    return @"Not training";
  }
}

- (id)copyWithZone: (NSZone *) zone
{
	CharacterCell * newCell = [super copyWithZone: zone];
  
  [newCell setCharacter: [self character]];
    
	return newCell;
}

- (void) setObjectValue: (id) object
{
  [super setObjectValue: object];
  [self setCharacter: object];
}

- (NSMenu *) menu
{
  return [[characterListController controllerForCharacter: character] menu];
}

- (NSImage *) image
{
  return [character portrait];
}

- (NSString *) name
{
  return [character name];
}

- (NSString *) subString
{
  return [self training];
}

@end

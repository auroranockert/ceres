//
//  SkillQueueEntry.h
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
//  Created by Jens Nockert on 3/14/09.
//

#import <Cocoa/Cocoa.h>

#import "CeresObject.h"
#import "SkillQueue.h"
#import "Character.h"
#import "TrainedSkill.h"

@class SkillQueue;
@class Character;
@class TrainedSkill;

@interface SkillQueueEntry : CeresObject {

}

@property(retain) NSDate * startsAt, * endsAt;
@property(retain) NSNumber * order, * toLevel;
@property(retain) TrainedSkill * trainedSkill;
@property(retain) SkillQueue * skillQueue;

@property(retain, readonly) NSString * name;
@property(retain, readonly) NSNumber * currentSkillpoints, * toSkillpoints, * skillpointsPerHour;
@property(assign, readonly) bool trainingComplete;
@property(retain, readonly) Skill * skill;
@property(retain, readonly) Character * character;

@end

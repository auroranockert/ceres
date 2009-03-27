//
//  Character.h
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
//  Created by Jens Nockert on 12/8/08.
//

#import <Cocoa/Cocoa.h>

#import <CeresIO/CeresIO.h>
#import "CharacterFuture.h"

#import "Ceres.h"
#import "CeresNotificationCenter.h"

#import "CharacterInfo.h"
#import "CorporationInfo.h"

#import "Account.h"
#import "CharacterNotification.h"

#import "EveObject.h"
#import "Clone.h"
#import "Attributes.h"

#import "Skill.h"
#import "TrainedSkill.h"
#import "SkillQueueEntry.h"

#import "Implant.h"
#import "ImplantSet.h"

@class Account;
@class CharacterInfo;
@class TrainedSkill;
@class SkillQueueEntry;
@class ImplantSet;
@class CharacterFuture;

@interface Character : EveObject {
  NSArray * skillGroups, * skillQueue;
  
  bool queueCached;
}

@property(retain) NSNumber * order;

@property(retain) NSString * race, * bloodline, * gender;
@property(retain) NSNumber * balance;
@property(retain) NSData * portraitData;

@property(retain) Account * account;
@property(retain, readonly) CorporationInfo * corporation;
@property(retain) NSNumber * corporationIdentifier;
@property(retain) NSString * corporationName;

@property(retain) Clone * clone;
@property(retain) ImplantSet * currentImplantSet;

@property(retain) NSNumber * baseIntelligence, * basePerception, * baseCharisma, * baseWillpower, * baseMemory;
@property(retain, readonly) NSNumber * skillIntelligence, * skillPerception, * skillCharisma, * skillWillpower, * skillMemory, * learningBonus;
@property(retain, readonly) NSNumber * implantIntelligence, * implantPerception, * implantCharisma, * implantWillpower, * implantMemory;

@property(copy, readonly) NSNumber * intelligence, * perception, * charisma, * willpower, * memory;

@property(retain) NSArray * skillGroups;

@property(retain, readonly) SkillQueueEntry * currentSkillQueueEntry, * lastTrainedSkillQueueEntry;
@property(retain, readonly) NSArray * skillQueue;
@property(retain) NSDate * queueCachedUntil;

@property(retain) NSSet * skills;
@property(retain) NSNumber * baseSkillpoints;
@property(copy, readonly) NSNumber * skillpoints;

- (id) initWithIdentifier: (NSNumber *) ident
                  account: (Account *) acc;

- (CharacterInfo *) characterInfo;
- (NSImage *) portrait;

- (NSNumber *) attribute: (NSString *) name;

- (NSNumber *) skillsForGroup: (Group *) group;
- (NSNumber *) skillpointsForGroup: (Group *) group;

- (void) updateSkillQueue;
- (void) updateSkillGroups;

- (void) clearSkillQueue;

- (NSNumber *) additionalSkillpoints;

- (void) prepareMessages;

@end

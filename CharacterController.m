//
//  CharacterController.m
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
//  Created by Jens Nockert on 1/17/09.
//

#import "CharacterController.h"


@implementation CharacterController

- (id) initWithCharacter: (Character *) c
{
  if (self = [super init]) {
    character = c;
    
    [[[Ceres instance] notificationCenter] addObserver: self selector: @selector(notification:) name: nil object: character];
  }
  
  return self;
}

- (NSMenu *) menu
{
  NSMenu * menu = [[NSMenu alloc] init];
  
  NSMenuItem * showCharacter = [[NSMenuItem alloc] initWithTitle: @"Show more details" action: @selector(showCharacter) keyEquivalent: @""];
  NSMenuItem * invalidateCharacter = [[NSMenuItem alloc] initWithTitle: @"Invalidate cache" action: @selector(invalidateCharacter) keyEquivalent: @""];
  NSMenuItem * removeCharacter = [[NSMenuItem alloc] initWithTitle: @"Remove Character" action: @selector(removeCharacter) keyEquivalent: @""];  
  
  [showCharacter setTarget: self];
  [invalidateCharacter setTarget: self];
  [removeCharacter setTarget: self];
  
  [menu addItem: showCharacter];
  [menu addItem: invalidateCharacter];
  [menu addItem: [NSMenuItem separatorItem]];
  [menu addItem: removeCharacter];
  
  return menu;
}

- (NSManagedObjectContext *) managedObjectContext
{
  return [[Interface instance] managedObjectContext];
}

- (NSString *) name
{
  return [character name];
}

- (NSString *) bloodline
{
  return [NSString stringWithFormat: @"%@ %@ %@", [character gender], [character race], [character bloodline]];
}

- (NSString *) corporation
{
  return [character corporationName];
}

- (NSString *) balance
{
  return [NSString stringWithFormat: @"%@ ISK", [[character balance] iskString]];
}

- (NSString *) skillpoints
{
  return [NSString stringWithFormat: @"%@ SP", [[character totalSkillpoints] spString]];
}

- (NSString *) intelligence
{
  return [NSString stringWithFormat: @"Intelligence: %@", [[character intelligence] attributeString]];
}

- (NSString *) perception
{
  return [NSString stringWithFormat: @"Perception: %@", [[character perception] attributeString]];
}

- (NSString *) charisma
{
  return [NSString stringWithFormat: @"Charisma: %@", [[character charisma] attributeString]];
}

- (NSString *) willpower
{
  return [NSString stringWithFormat: @"Willpower: %@", [[character willpower] attributeString]];
}

- (NSString *) memory
{
  return [NSString stringWithFormat: @"Memory: %@", [[character memory] attributeString]];
}

- (NSString *) training
{
  if ([character trainingSkill])
  {
    return [[NSString alloc] initWithFormat: @"Currently training %@ to level %@ at %@ SP/h", [[character trainingSkill] name], [[[character trainingSkill] nextLevel] levelString], [[[character trainingSkill] skillpointsPerHour] spString]];
  }
  else
  {
    return @"Not training";
  }
}

- (NSString *) trainingSkillpoints
{
  if ([character trainingSkill])
  {
    NSInteger current = [[character trainingCurrentSkillpoints] integerValue];
        
    if ([[[character trainingSkill] requiredSkillpointsForNextLevel] integerValue] == 0) {
      return @"Finished";
    }
    else {
      return [[NSString alloc] initWithFormat: @"%@ / %@ SP Complete (Finished %@)", [[character trainingCurrentSkillpoints] spString], [[[[character trainingSkill] skill] skillpointsForLevel: [[character trainingSkill] nextLevel]] spString], [[character trainingEndsAt] preferedDateFormatString]];
    }
  }
  else
  {
    return @"Not training";
  }
}

- (NSString *) skillCount
{
  return [NSString stringWithFormat: @"%d of %d skills are currently trained to level %@.", [[[character skills] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"level = 5"]] count], [[character skills] count], [[NSNumber numberWithInteger: 5] levelString]];
}

- (NSString *) clone
{
  return [NSString stringWithFormat: @"%@ (Stores %@ SP)", [[character clone] name], [[[character clone] skillpoints] spString]];
}

- (NSImage *) portrait
{
  if (!portrait) {
    portrait = [character portrait];
    
    [portrait setFlipped: true];
    
    portrait = [portrait imageWithRoundedCorners: 10.0];
  }
  
  return portrait;
}

- (NSImage *) characterViewPortrait
{
  if (!characterViewPortrait) {
    characterViewPortrait = [[character portrait] imageWithRoundedCorners: 10.0];
  }
  
  return characterViewPortrait;
}

- (NSSet *) skills
{
  return [character skills];
}

- (Character *) character
{
  return character;
}

- (void) invalidateCharacter
{
  [character invalidate];
  [character update];
}

- (void) showCharacter
{
  if(!characterWindow) {
    [[Interface instance] loadNib: @"Character" owner: self];
  }
  
  [characterWindow setIsVisible: true];
  [characterWindow makeKeyAndOrderFront: self];

  [self update: self];
}

- (void) removeCharacter
{
  [character remove];
  [[Ceres instance] save];
}

- (void) notification: (NSNotification *) argument
{
  if ([[argument name] compare: [CharacterNotification nameForMessage: @"characterRemoved"]] == NSOrderedSame) {
    [characterWindow close];
  }
  else {
    [self updateCharacter: self];
  }
}

- (void) updateCharacter: (id) sender
{
  [self willChangeValueForKey: @"corporation"];
  [self willChangeValueForKey: @"balance"];
  [self willChangeValueForKey: @"training"];
  [self willChangeValueForKey: @"clone"];
  
  [self didChangeValueForKey: @"clone"];
  [self didChangeValueForKey: @"corporation"];
  [self didChangeValueForKey: @"balance"];
  [self didChangeValueForKey: @"training"];
}

- (void) update: (id) sender
{
  [self willChangeValueForKey: @"skillpoints"];
  [self willChangeValueForKey: @"trainingSkillpoints"];
  
  [self didChangeValueForKey: @"trainingSkillpoints"];
  [self didChangeValueForKey: @"skillpoints"];
  
  if ([characterWindow isVisible]) {
    [self performSelector: @selector(update:) withObject: self afterDelay: 1];
  }
}

@end

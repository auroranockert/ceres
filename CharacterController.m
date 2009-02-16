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
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [formatter setMinimumFractionDigits: 2];
    [formatter setMaximumFractionDigits: 2];
    
    spFormatter = [[NSNumberFormatter alloc] init];
    [spFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [spFormatter setMinimumFractionDigits: 0];
    [spFormatter setMaximumFractionDigits: 0];
    
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
  return [[character balance] isk];
}

- (NSString *) skillpoints
{
  return [[character totalSkillpoints] sp];
}

- (NSString *) intelligence
{
  return [NSString stringWithFormat: @"Intelligence: %@", [formatter stringFromNumber: [character intelligence]]];
}

- (NSString *) perception
{
  return [NSString stringWithFormat: @"Perception: %@", [formatter stringFromNumber: [character perception]]];
}

- (NSString *) charisma
{
  return [NSString stringWithFormat: @"Charisma: %@", [formatter stringFromNumber: [character charisma]]];
}

- (NSString *) willpower
{
  return [NSString stringWithFormat: @"Willpower: %@", [formatter stringFromNumber: [character willpower]]];
}

- (NSString *) memory
{
  return [NSString stringWithFormat: @"Memory: %@", [formatter stringFromNumber: [character memory]]];
}

- (NSString *) training
{
  if ([character trainingSkill])
  {
    return [[NSString alloc] initWithFormat: @"Currently training %@ to level %@ at %@/h", [[character trainingSkill] name], [[[character trainingSkill] nextLevel] level], [[[character trainingSkill] skillpointsPerHour] sp]];
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
      return [[NSString alloc] initWithFormat: @"%@ / %@ Complete (Finished %@)", [spFormatter stringFromNumber: [character trainingCurrentSkillpoints]], [[[[character trainingSkill] skill] skillpointsForLevel: [[character trainingSkill] nextLevel]] sp], [[character trainingEndsAt] preferedDateFormat]];
    }
  }
  else
  {
    return @"Not training";
  }
}

- (NSString *) skillCount
{
  return [NSString stringWithFormat: @"%d of %d skills are currently trained to level V.", [[[character skills] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"level = 5"]] count], [[character skills] count]];
}

- (NSString *) clone
{
  return [NSString stringWithFormat: @"%@ (Stores %@)", [[character clone] name], [[[character clone] skillpoints] sp]];
}

- (NSData *) portraitData
{
  return [character portraitData];
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

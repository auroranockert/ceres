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
  return [NSString stringWithFormat: @"%@ ISK", [character balance]];
}

- (NSString *) skillpoints
{
  return @"Sorry, Ceres doesn't really know how to calculate SP total yet...";
}

- (NSString *) intelligence
{
  return [NSString stringWithFormat: @"Intelligence: %@", [character intelligence]];
}

- (NSString *) perception
{
  return [NSString stringWithFormat: @"Perception: %@", [character perception]];
}

- (NSString *) charisma
{
  return [NSString stringWithFormat: @"Charisma: %@", [character charisma]];
}

- (NSString *) willpower
{
  return [NSString stringWithFormat: @"Willpower: %@", [character willpower]];
}

- (NSString *) memory
{
  return [NSString stringWithFormat: @"Memory: %@", [character memory]];
}

- (NSString *) training
{
  if ([[character training] boolValue])
  {
    return [[NSString alloc] initWithFormat: @"Currently training %@ to level %@", [[character trainingSkill] name], [character trainingToLevel]];
  }
  else
  {
    return @"Not training";
  }
}

- (NSString *) trainingSkillpoints
{
  if ([[character training] boolValue])
  {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm 'on' MMMM d"];
    NSInteger current = [[character trainingCurrentSkillpoints] integerValue];
    
    if (current > [[character trainingSkillpointsEnd] integerValue]) {
      return [[NSString alloc] initWithFormat: @"Finished", [[character trainingSkill] name]];
    }
    else {
      return [[NSString alloc] initWithFormat: @"%ld / %ld SP Complete (Finished by %@)", current, [[character trainingSkillpointsEnd] integerValue], [formatter stringFromDate: [character trainingEndsAt]]];
    }
  }
  else
  {
    return @"";
  }
}

- (NSString *) clone
{
  return [NSString stringWithFormat: @"%@ (Stores %@ SP)", [[character clone] name], [[character clone] skillpoints]];
}

- (NSData *) portraitData
{
  return [character portraitData];
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

- (void) notification: (id) argument
{
  [self updateCharacter: self];
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
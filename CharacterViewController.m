//
//  CharacterTabController.m
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
//  Created by Jens Nockert on 2/25/09.
//

#import "CharacterViewController.h"


@implementation CharacterViewController

@synthesize character, managedObjectContext;

- (id) initWithNibName: (NSString *) nib bundle: (NSBundle *) bundle character: (Character *) c
{
  if (self = [self initWithNibName: nib bundle: bundle]) {
    character = c;
    
    [[CeresNotificationCenter instance] addObserver: self selector: @selector(updateCharacter:) name: nil object: character];
    [self update: self];
  }
  
  return self;
}

- (void) loadView
{
  [super loadView];
  
  skillController = [[SkillListController alloc] init];
  [skillController setCharacter: character];
  [skillController setSkillOutlineView: skillView];  
}

- (NSString *) title
{
	return [character name];
}

- (NSString *) identifier
{
	return [NSString stringWithFormat: @"Ceres.Character.%@", [character name]];
}

- (NSImage *) icon
{
	return [self portrait];
}

- (NSAttributedString *) name
{
  NSLog(@"%@", [character name]);
  return [[NSAttributedString alloc] initWithString: [character name] attributes: [NSDictionary dictionaryWithObject: [NSFont systemFontOfSize: 14] forKey:NSFontAttributeName]];
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
  return [NSString stringWithFormat: @"%@ SP", [[character skillpoints] spString]];
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
  if ([character currentlyTraining])
  {
    return [[NSString alloc] initWithFormat: @"Currently training %@ to level %@ at %@ SP/h", [[character currentlyTraining] name], [[[character currentlyTraining] nextLevel] levelString], [[[character currentlyTraining] skillpointsPerHour] spString]];
  }
  else
  {
    return @"Not training";
  }
}

- (NSString *) trainingSkillpoints
{
  if ([character currentlyTraining])
  {
    if ([[character currentlyTraining] complete]) {
      return @"Finished";
    }
    else {
      return [[NSString alloc] initWithFormat: @"%@ / %@ SP Complete (Finished %@)", [[[character currentlyTraining] currentSkillpoints] spString], [[[[character currentlyTraining] skill] skillpointsForLevel: [[character currentlyTraining] nextLevel]] spString], [[[character currentSkillQueueEntry] endsAt] preferedDateFormatString]];
    }
  }
  else
  {
    return @"Not training";
  }
}

- (NSString *) skillCount
{
  return [NSString stringWithFormat: @"%ld of %ld skills are currently trained to level %@.", [[[character skills] filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"level = 5"]] count], [[character skills] count], [[NSNumber numberWithInteger: 5] levelString]];
}

- (NSAttributedString *) clone
{
  NSString * string = [NSString stringWithFormat: @"%@ (Stores %@ SP)", [[character clone] name], [[[character clone] skillpoints] spString]];
  if ([[[character clone] skillpoints] compare: [character skillpoints]] == NSOrderedAscending) {
    return [[NSAttributedString alloc] initWithString: string attributes: [NSDictionary dictionaryWithObject: [NSColor redColor] forKey: NSForegroundColorAttributeName]];
  }
  else {
    return [[NSAttributedString alloc] initWithString: string attributes: [NSDictionary dictionaryWithObject: [NSColor blackColor] forKey: NSForegroundColorAttributeName]];
  }
}

- (NSImage *) portrait
{
  if (!portrait) {
    portrait = [[character portrait] imageWithRoundedCorners: 10.0];
  }
  
  return portrait;
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
  
  [self performSelector: @selector(update:) withObject: self afterDelay: 1];
}

@end

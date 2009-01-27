//
//  CharacterNotification.m
//  Ceres
//
//  Created by Jens Nockert on 1/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CharacterNotification.h"


@implementation CharacterNotification

- (id) initWithCharacter: (Character *) character name: (NSString *) n
{
  if (self = [super initWithObject: (id) character name: n]) {
    
  }
  
  return self;
}

+ (CharacterNotification *) notificationWithCharacter: (Character *) character name: (NSString *) n;
{
  return [[CharacterNotification alloc] initWithCharacter: character name: [NSString stringWithFormat: @"character.%@", n]];
}

+ (NSString *) nameForMessage: (NSString *) message
{
  return [NSString stringWithFormat: @"%@.%@", [super nameForMessage: @"character"], message];
}

- (Character *) character
{
  return (Character *) object;
}

@end

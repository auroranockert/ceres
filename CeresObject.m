//
//  CeresObject.m
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
//  Created by Jens Nockert on 1/4/09.
//

#import "CeresObject.h"


@implementation CeresObject

- (id) init
{
  return [super initWithEntity: [[self class] entityDescription] insertIntoManagedObjectContext: [[Ceres instance] managedObjectContext]];
}

- (id) initWithIdentifier: (NSNumber *) identifier
{
  id possible = [[self class] findWithIdentifier: identifier];
  
  if (possible) {
    return possible;
  }
  
  if (self = [self init]) {
    [self setValue: identifier forKey: @"identifier"];
  }
  
  return self;
}

- (id) copyWithZone: (NSZone *) zone
{
  return self;
}

+ (NSEntityDescription *) entityDescription
{
  NSLog(@"Dummy Entity Description requested for class %@, returned nil. This is a bug.", [self class]);
  return nil;
}

+ (NSArray *) findWithSort: (NSSortDescriptor *) sort
                 predicate: (NSPredicate *) predicate;
{
  NSFetchRequest * request = [[NSFetchRequest alloc] init];
  
  [request setEntity: [self entityDescription]];
  [request setSortDescriptors: [NSArray arrayWithObject: sort]];
  [request setPredicate: predicate];
  
  NSError * error = nil;
  NSArray * array = [[[Ceres instance] managedObjectContext] executeFetchRequest: request error: &error];
  
  if ((error != nil) || (array == nil)) {
    [[Ceres instance] handleError: error];
  }
  
  return array;
}

+ (NSArray *) find
{
  NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"identifier" ascending: YES];
  NSPredicate * predicate = [NSPredicate predicateWithValue: true];
  return [self findWithSort: sortDescriptor predicate: predicate];
}

+ (id) findWithIdentifier: (NSNumber *) ident
{
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"identifier" ascending: YES];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"identifier == %@", ident];
  
  return [[[self class] findWithSort: sort predicate: predicate] anyObject];
}

+ (id) findWithName: (NSString *) n
{
  NSSortDescriptor * sort = [[NSSortDescriptor alloc] initWithKey: @"identifier" ascending: YES];
  NSPredicate * predicate = [NSPredicate predicateWithFormat: @"name == %@", n];
  
  return [[[self class] findWithSort: sort predicate: predicate] anyObject];
}

+ (NSInteger) priority
{
  return 0;
}

+ (NSComparisonResult) comparePriority: (id) other
{
  return [[NSNumber numberWithInteger: [other priority]] compare: [NSNumber numberWithInteger: [self priority]]];
}

- (Api *) api
{
  if (!api) {
    api = [self initializeApi];
  }
  
  return api;
}

- (Api *) initializeApi
{
  return [[Api alloc] init];
}

- (Data *) data
{
  if (!data) {
    data = [self initializeData];
  }
  
  return data;
}

- (Data *) initializeData
{
  return [[Data alloc] init];
}

- (void) remove
{
  [[[Ceres instance] managedObjectContext] deleteObject: self];
}

@end

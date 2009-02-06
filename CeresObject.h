//
//  CeresObject.h
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

#import <Cocoa/Cocoa.h>

#import "Ceres.h"
#import "CeresAdditions.h"

#import "Api.h"
#import "Data.h"

@interface CeresObject : NSManagedObject {
  Api * api;
  Data * data;
}

- (id) initWithIdentifier: (NSNumber *) identifier;

+ (NSEntityDescription *) entityDescription;

+ (NSArray *) find;

+ (NSArray *) findWithSort: (NSSortDescriptor *) sort
                 predicate: (NSPredicate *) predicate;

+ (NSInteger) priority;
+ (NSComparisonResult) comparePriority: (id) other;

+ (id) findWithIdentifier: (NSNumber *) identifier;
+ (id) findWithName: (NSString *) name;

- (Api *) api;
- (Api *) initializeApi;
- (Data *) data;
- (Data *) initializeData;

- (void) remove;

@end

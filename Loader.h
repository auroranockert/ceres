//
//  Loader.h
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
//  Created by Jens Nockert on 1/6/09.
//

#import <Cocoa/Cocoa.h>

#import "URLLoader.h"
#import "URLDelegate.h"

#import "Updater.h"
#import "Data.h"

#import "Category.h"
#import "Group.h"
#import "MarketGroup.h"
#import "Skill.h"
#import "Clone.h"

@interface Loader : NSObject {
  id delegate;
}

+ (Loader *) instance;

- (void) start: (id) delegate;

- (void) text: (NSString *) text;

@end

@interface NSObject (LoaderDelegate)

- (void) setText: (NSString *) text;
- (void) finished;

@end

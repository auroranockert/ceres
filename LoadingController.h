//
//  LoadingController.h
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
//  Created by Jens Nockert on 1/10/09.
//

#import <Cocoa/Cocoa.h>

#import "CeresHeader.h"
#import "Interface.h"

@interface LoadingController : NSObject {
  IBOutlet NSWindow * window;
  IBOutlet NSProgressIndicator * progressIndicator;
  IBOutlet NSTextField * textField;
}

- (void) awakeFromNib;
- (void) downloadTimeout: (NSInteger) time;
- (void) databaseNewer: (NSString *) text;
- (void) setText: (NSString *) text;
- (void) finished;

@end

//
//  NSNumber.h
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
//  Created by Jens Nockert on 2/6/09.
//

#import <Cocoa/Cocoa.h>


@interface NSNumber (CeresAdditons)

- (NSNumber *) next;
- (NSNumber *) previous;

- (NSNumber *) addInteger: (NSNumber *) other;
- (NSNumber *) subtractInteger: (NSNumber *) other;

- (NSString *) romanValue;

@end

//
//  NSRect.h
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
//  Created by Jens Nockert on 2/10/09.
//

#import <Cocoa/Cocoa.h>

NS_INLINE NSRect SizeCenteredInRect(NSSize size, NSRect frame) {
	return NSInsetRect(frame, (NSWidth(frame) - size.width)/2.0, (NSHeight(frame) - size.height)/2.0);
}

NS_INLINE NSRect SquareCenteredInRect(CGFloat squareSize, NSRect frame) {
	return NSInsetRect(frame, (NSWidth(frame) - squareSize)/2.0, (NSHeight(frame) - squareSize)/2.0);
}

NS_INLINE NSPoint CentrePointFromRect(NSRect rect) {
	return NSMakePoint(NSMidX(rect), NSMidY(rect));
}

NS_INLINE NSRect RectFromCentrePoint(NSPoint point, NSSize size) {
	return (NSRect){(NSPoint){point.x - (size.width/2.0), point.y - (size.height/2.0)}, (NSSize)size};
}

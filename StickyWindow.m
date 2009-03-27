//
//  StickyWindow.m
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
//  Created by Jens Nockert on 2/23/09.
//

#import "StickyWindow.h"

#define WINDOW_DOCKING_DISTANCE 	12	//Distance in pixels before the window is snapped to an edge
#define IGNORED_X_RESISTS			3
#define IGNORED_Y_RESISTS			3

@interface StickyWindow (PRIVATE)
- (void) initStickyWindow;
- (NSRect) dockWindowFrame: (NSRect) windowFrame toScreenFrame: (NSRect)screenFrame;
@end


@implementation StickyWindow

- (id) initWithContentRect: (NSRect) contentRect styleMask: (NSUInteger) aStyle backing: (NSBackingStoreType) bufferingType defer: (bool) flag
{
	if ((self = [super initWithContentRect: contentRect styleMask: aStyle backing: bufferingType defer: flag])) {
		[self initStickyWindow];
	}
  
	return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder: aDecoder])) {
		[self initStickyWindow];
	}
  
	return self;
}
- (id) init
{
	if ((self = [super init])) {
		[self initStickyWindow];
	}
	return self;
}

- (void) initStickyWindow
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(windowDidMove:)
                                               name:NSWindowDidMoveNotification 
                                             object:self];
	resisted_XMotion = 0;
	resisted_YMotion = 0;
	oldWindowFrame = NSMakeRect(0,0,0,0);
	alreadyMoving = false;
}

- (void) windowDidMove: (NSNotification *) notification
{
	//Our setFrame call below will cause a re-entry into this function, we must guard against this
	if (!alreadyMoving) {
		alreadyMoving = true;	
		
		//Attempt to dock this window the the visible frame first, and then to the screen frame
		NSRect	newWindowFrame = [self frame];
		NSRect  dockedWindowFrame;
		
		dockedWindowFrame = [self dockWindowFrame:newWindowFrame toScreenFrame: [[self screen] visibleFrame]];
		dockedWindowFrame = [self dockWindowFrame:dockedWindowFrame toScreenFrame: [[self screen] frame]];
    
		//If the window wants to dock, animate it into place
		if (!NSEqualRects(newWindowFrame, dockedWindowFrame)) {
			
			if (!NSIsEmptyRect(oldWindowFrame)) {
				bool	user_XMovingLeft = ((oldWindowFrame.origin.x - newWindowFrame.origin.x) >= 0);
				bool	docking_XMovingLeft = ((newWindowFrame.origin.x - dockedWindowFrame.origin.x) >= 0);
				
				//If the user is trying to move in the opposite X direction as the docking movement, use the user's movement
				if ((user_XMovingLeft && !docking_XMovingLeft) || (!user_XMovingLeft && docking_XMovingLeft)) {
					if (resisted_XMotion <= IGNORED_X_RESISTS) {
						dockedWindowFrame.origin.x = newWindowFrame.origin.x;
						resisted_XMotion = 0;
					} else {
						resisted_XMotion++;
					}
				} else {
					//They went with the flow
					resisted_XMotion = 0;
				}
				
				bool	user_YMovingDown = ((oldWindowFrame.origin.y - newWindowFrame.origin.y) >= 0);
				bool	docking_YMovingDown = ((newWindowFrame.origin.y - dockedWindowFrame.origin.y) >= 0);
				
				//If the user is trying to move in the opposite Y direction as the docking movement, use the user's movement
				if ((user_YMovingDown && !docking_YMovingDown) || (!user_YMovingDown && docking_YMovingDown)) {
					if (resisted_YMotion <= IGNORED_Y_RESISTS) {
						dockedWindowFrame.origin.y = newWindowFrame.origin.y;
						resisted_YMotion = 0;
					} else {
						resisted_YMotion++;
					}
				} else {
					resisted_YMotion = 0;
				}
			}
			
			[self setFrame: dockedWindowFrame display: true animate: true];
			oldWindowFrame = dockedWindowFrame;
			
		} else {
			resisted_XMotion = 0;
			resisted_YMotion = 0;	
			oldWindowFrame = NSMakeRect(0,0,0,0);
		}
		
		alreadyMoving = false; //Clear the guard, we are now safe
	}
}

//Dock the passed window frame if it's close enough to the screen edges
- (NSRect)dockWindowFrame:(NSRect)windowFrame toScreenFrame:(NSRect)screenFrame
{
	//Left
	if (abs(NSMinX(windowFrame) - NSMinX(screenFrame)) < WINDOW_DOCKING_DISTANCE) {
		windowFrame.origin.x = screenFrame.origin.x;
	}
	
	//Bottom
	if (abs(NSMinY(windowFrame) - NSMinY(screenFrame)) < WINDOW_DOCKING_DISTANCE) {
		windowFrame.origin.y = screenFrame.origin.y;
	}
	
	//Right
	if (abs(NSMaxX(windowFrame) - NSMaxX(screenFrame)) < WINDOW_DOCKING_DISTANCE) {
		windowFrame.origin.x -= NSMaxX(windowFrame) - NSMaxX(screenFrame);
	}
	
	//Top
	if (abs(NSMaxY(windowFrame) - NSMaxY(screenFrame)) < WINDOW_DOCKING_DISTANCE) {
		windowFrame.origin.y -= NSMaxY(windowFrame) - NSMaxY(screenFrame);
	}
	
	return windowFrame;
}

@end

//
//  CharacterTable.m
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
//  Created by Jens Nockert on 1/16/09.
//

#import "CharacterTableView.h"

@interface CharacterTableView (PRIVATE)

- (void) _drawRowInRect: (NSRect) rect colored: (bool) colored selected: (bool) selected;
- (void) initCharacterTableView;

@end

@interface NSTableView (Undocumented)
- (id) _highlightColorForCell: (NSCell *) cell;
@end

@implementation CharacterTableView

@synthesize acceptFirstMouse;

- (id) initWithCoder: (NSCoder *) aDecoder
{
	if ((self = [super initWithCoder: aDecoder])) {
		[self initCharacterTableView];
	}
	return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame: frameRect])) {
		[self initCharacterTableView];
	}
	return self;
}

- (void) initCharacterTableView
{
	acceptFirstMouse = false;
	[[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector(characterTableViewSelectionDidChange:)
                                               name: NSTableViewSelectionDidChangeNotification
                                             object: self];	
}

- (void) tile
{
  [super tile];
  [[self enclosingScrollView] setVerticalLineScroll: ([self rowHeight] + [self intercellSpacing].height) ];
}

- (void)highlightSelectionInClipRect: (NSRect) clipRect
{
	if ([[self window] isKeyWindow] && ([[self window] firstResponder] == self)) {
    NSColor	* startColor = [[NSColor alternateSelectedControlColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    NSColor * endColor = [[NSColor alternateSelectedControlColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
    
    startColor = [NSColor colorWithCalibratedHue:[startColor hueComponent]
                                saturation:(([startColor saturationComponent] == 0.0) ? [startColor saturationComponent] : ([startColor saturationComponent] - 0.1))
                                brightness:([startColor brightnessComponent] - 0.1)
                                     alpha:[startColor alphaComponent]];
    
    
    endColor = [NSColor colorWithCalibratedHue:[endColor hueComponent]
                                      saturation:(([endColor saturationComponent] == 0.0) ? [endColor saturationComponent] : ([endColor saturationComponent] + 0.1))
                                      brightness:([endColor brightnessComponent] + 0.1)
                                           alpha:[endColor alphaComponent]];
    
    NSGradient * gradient = [[NSGradient alloc] initWithColors: [NSArray arrayWithObjects: endColor, startColor, nil]];
    [gradient drawInRect: [self rectOfRow: [self selectedRow]] angle: 90];
	} else {
		[super highlightSelectionInClipRect: clipRect];
	}
}

- (id) _highlightColorForCell: (NSCell *)cell
{
	if ([[self window] isKeyWindow] && ([[self window] firstResponder] == self)) {
		return nil;
	} else {
		return [super _highlightColorForCell: cell];
	}
}

- (void) characterTableViewSelectionDidChange: (NSNotification *) notification
{
  [self setNeedsDisplay:YES];
}

@end


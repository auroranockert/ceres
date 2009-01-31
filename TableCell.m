//
//  TableCell.m
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
//  Created by Jens Nockert on 1/31/09.
//

#import "TableCell.h"

#define DEFAULT_MAX_IMAGE_WIDTH			  96
#define DEFAULT_IMAGE_TEXT_PADDING		6
#define LINEBREAKMODE                 NSLineBreakByTruncatingTail

@interface NSCell (UndocumentedHighlightDrawing)
- (void)_drawHighlightWithFrame: (NSRect) cellFrame inView: (NSView *) controlView;
@end

@implementation TableCell

@synthesize maxImageWidth, imageTextPadding, highlightWhenNotKey;

- (id) init
{
  if (self = [super init]) {
		highlightWhenNotKey = NO;
		maxImageWidth = DEFAULT_MAX_IMAGE_WIDTH;
		imageTextPadding = DEFAULT_IMAGE_TEXT_PADDING;
  }
  
  return self;
}

- (id)copyWithZone: (NSZone *) zone
{
	TableCell * newCell = [super copyWithZone: zone];
  
	[newCell setMaxImageWidth: maxImageWidth];
  
	return newCell;
}

- (NSImage *) image
{
  return nil;
}

- (NSString *) name
{
  return @"Abstract class";
}

- (NSString *) subString
{
  return @"Something is wrong...";
}

- (NSFont *) nameFont
{
  return [NSFont fontWithName: @"Lucida Grande" size: 16];
}

- (NSFont *) subStringFont
{
  return [NSFont systemFontOfSize: 10];
}

#pragma mark Drawing

- (NSSize) cellSizeForBounds: (NSRect) cellFrame
{
  NSImage * image = [self image];
  NSString * nameString = [self name];
  NSString * subString= [self subString];
  
	NSSize cellSize = NSZeroSize;
	
	if (image) {
		NSSize destSize = [image size];
    
		//Center image vertically, or scale as needed
		if (destSize.height > cellFrame.size.height) {
			float proportionChange = cellFrame.size.height / destSize.height;
			destSize.height = cellFrame.size.height;
			destSize.width = destSize.width * proportionChange;
		}
		
		if (destSize.width > maxImageWidth) {
			float proportionChange = maxImageWidth / destSize.width;
			destSize.width = maxImageWidth;
			destSize.height = destSize.height * proportionChange;
		}
    
		cellSize.width += destSize.width + imageTextPadding;
		cellSize.height = destSize.height;
	}
	
	if (nameString) {
		NSDictionary * attributes;
		NSSize nameSize;
    
		cellSize.width += (imageTextPadding * 2);
    
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment: [self alignment]];
    [paragraphStyle setLineBreakMode: LINEBREAKMODE];
		
    attributes = [NSDictionary dictionaryWithObjectsAndKeys: paragraphStyle, NSParagraphStyleAttributeName, [self nameFont], NSFontAttributeName, nil];
		nameSize = [nameString sizeWithAttributes: attributes];
		
		if (subString) {
			NSSize			subStringSize;
      
			attributes = [NSDictionary dictionaryWithObject: [self subStringFont] forKey: NSFontAttributeName];
			subStringSize = [subString sizeWithAttributes: attributes];
			
			if (subStringSize.width > nameSize.width) {
				cellSize.width += subStringSize.width;
			} else {
				cellSize.width += nameSize.width;
			}
			
			if (cellSize.height < (subStringSize.height + nameSize.height)) {
				cellSize.height = (subStringSize.height + nameSize.height);
			}
		} else {
			cellSize.width += nameSize.width;
			if (cellSize.height < nameSize.height) {
				cellSize.height = nameSize.height;
			}
		}
	}
	
	return cellSize;
}

- (NSSize) drawImage: (NSImage *) image withFrame: (NSRect)cellFrame
{
	NSSize size = [[self image] size];
	NSRect destRect = { cellFrame.origin, size };
	
	destRect.origin.y += 0;
	destRect.origin.x += imageTextPadding;
	
	if (destRect.size.height > cellFrame.size.height) {
    float proportionChange = cellFrame.size.height / size.height;
    destRect.size.height = cellFrame.size.height;
    destRect.size.width = size.width * proportionChange;
  }
  
  if (destRect.size.width > maxImageWidth) {
    float proportionChange = maxImageWidth / destRect.size.width;
    destRect.size.width = maxImageWidth;
    destRect.size.height = destRect.size.height * proportionChange;
  }
  
	if (destRect.size.height < cellFrame.size.height) {
		destRect.origin.y += (cellFrame.size.height - destRect.size.height) / 2.0;
	} 
	
	BOOL flippedIt = NO;
	if (![image isFlipped]) {
		[image setFlipped:YES];
		flippedIt = YES;
	}
	
	[NSGraphicsContext saveGraphicsState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	[image drawInRect:destRect
           fromRect:NSMakeRect(0,0,size.width,size.height)
          operation:NSCompositeSourceOver
           fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
  
	if (flippedIt) {
		[image setFlipped:NO];
	}
  
	return destRect.size;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[NSGraphicsContext saveGraphicsState];
  
  NSImage * image = [self image];
  NSString * nameString = [self name];
  NSString * subString = [self subString];
  
	BOOL highlighted = [self isHighlighted];
  
	if (image) {
		NSSize drawnImageSize = [self drawImage:image withFrame:cellFrame];
    
		cellFrame.size.width -= imageTextPadding + drawnImageSize.width;
		
		NSAffineTransform *imageTranslation = [NSAffineTransform transform];
		[imageTranslation translateXBy:(imageTextPadding * 2 + drawnImageSize.width) yBy:0.0];
		[imageTranslation concat];
	}
	
	if (nameString) {
		NSAttributedString	*attributedMainString = nil, *attributedSubString = nil;
		NSColor				*mainTextColor, *subStringTextColor;
		NSDictionary		*mainAttributes = nil, *subStringAttributes = nil;
		float				mainStringHeight = 0.0, subStringHeight = 0.0, textSpacing = 0.0;
    
		NSWindow * window;
    
		if (highlighted && (highlightWhenNotKey ||
                        ((window = [controlView window]) &&
                         ([window isKeyWindow] && ([window firstResponder] == controlView))))) {
			// Draw the text inverted
			mainTextColor = [NSColor alternateSelectedControlTextColor];
			subStringTextColor = [NSColor alternateSelectedControlTextColor];
		} else {
			if ([self isEnabled]) {
				// Draw the text regular
				mainTextColor = [NSColor controlTextColor];
				subStringTextColor = [NSColor colorWithCalibratedWhite:0.4 alpha:1.0];
			} else {
				// Draw the text disabled
				mainTextColor = [NSColor grayColor];
				subStringTextColor = [NSColor colorWithCalibratedWhite:0.8 alpha:1.0];
			}
		}
    
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment: [self alignment]];
    [paragraphStyle setLineBreakMode: LINEBREAKMODE];
    
    mainAttributes = [NSDictionary dictionaryWithObjectsAndKeys:  paragraphStyle, NSParagraphStyleAttributeName, [self nameFont], NSFontAttributeName, mainTextColor, NSForegroundColorAttributeName, nil];
		
		attributedMainString = [[NSAttributedString alloc] initWithString: nameString attributes: mainAttributes];
		
		if (subString) {
			subStringAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                             paragraphStyle, NSParagraphStyleAttributeName,
                             [self subStringFont], NSFontAttributeName,
                             subStringTextColor, NSForegroundColorAttributeName,
                             nil];
			
			attributedSubString = [[NSAttributedString alloc] initWithString: subString
                                                            attributes: subStringAttributes];
		}
    
    mainStringHeight = [nameString sizeWithAttributes:mainAttributes].height;
		if (subString) {
			subStringHeight = [subString sizeWithAttributes:subStringAttributes].height;
		}
    
		//Calculate the centered rect
		if (!subString && mainStringHeight < cellFrame.size.height) {
			// Space out the main string evenly
			cellFrame.origin.y += (cellFrame.size.height - mainStringHeight) / 2.0;
		} else if (subString) {
			// Space out our extra space evenly
			textSpacing = (cellFrame.size.height - mainStringHeight - subStringHeight) / 3.0;
			// In case we don't have enough height..
			if (textSpacing < 0.0)
				textSpacing = 0.0;
			cellFrame.origin.y += textSpacing;
		}
    
		//Draw the string
		[attributedMainString drawInRect: cellFrame];
    
		//Draw the substring
		if (subString) {
			NSAffineTransform *subStringTranslation = [NSAffineTransform transform];
			[subStringTranslation translateXBy:0.0 yBy:mainStringHeight + textSpacing];
			[subStringTranslation concat];
			
			//Draw the substring
			[attributedSubString drawInRect:cellFrame];
			[attributedSubString release];
		}
	}
  
	[NSGraphicsContext restoreGraphicsState];
}

@end

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
#define DEFAULT_IMAGE_TEXT_PADDING		4
#define LINEBREAKMODE                 NSLineBreakByTruncatingTail

@implementation TableCell

@synthesize maxImageWidth, imageTextPadding;

- (id) init
{
  if (self = [super init]) {
		maxImageWidth = DEFAULT_MAX_IMAGE_WIDTH;
		imageTextPadding = DEFAULT_IMAGE_TEXT_PADDING;
  }
  
  return self;
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
  return [NSFont systemFontOfSize: 16];
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
  NSString * subString = [self subString];
  
	NSSize cellSize = NSZeroSize;
  
	if (image) {
		NSSize destSize = [self imageRectForBounds: cellFrame].size;
		
    cellSize.width += destSize.width + imageTextPadding;
		cellSize.height = destSize.height;
	}
  
  NSMutableDictionary * attributes = [[NSDictionary dictionaryWithObjectsAndKeys: [self paragraphStyle], NSParagraphStyleAttributeName, [self nameFont], NSFontAttributeName, nil] mutableCopy];
  
  NSSize textSize = NSZeroSize;
	
	if (nameString) {
    
		cellSize.width += imageTextPadding;
    
		textSize = [nameString sizeWithAttributes: attributes];
  }
  
  if (subString) {
    NSSize subStringSize;
    
    [attributes setObject: [self subStringFont] forKey: NSFontAttributeName];
    
    subStringSize = [subString sizeWithAttributes: attributes];
    
    if (subStringSize.width > textSize.width) {
      textSize.width = subStringSize.width;
    }
    
    if (cellSize.height < (subStringSize.height + textSize.height)) {
      cellSize.height = (subStringSize.height + textSize.height);
    }
  }
	
	return cellSize;
}

- (NSRect) imageRectForBounds: (NSRect) frame {
	NSRect imageFrame = frame;
	imageFrame.size.width = NSHeight(frame);
	
	return imageFrame;
}

- (NSSize) drawImage: (NSImage *) image withFrame: (NSRect) frame
{
  NSRect imageFrame = [self imageRectForBounds: frame];
  
  bool imageFlipped = [image isFlipped];
  [image setFlipped: false];
  
  [NSGraphicsContext saveGraphicsState];
  [[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];
  [image drawInRect: SquareCenteredInRect((NSHeight(frame) * 0.95), imageFrame) fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
  [NSGraphicsContext restoreGraphicsState];
  
  [image setFlipped: imageFlipped];
  
  return imageFrame.size;
}

- (void) drawInteriorWithFrame: (NSRect) frame inView: (NSView *) view
{
	[NSGraphicsContext saveGraphicsState];
  
  NSImage * image = [self image];
  NSString * nameString = [self name];
  NSString * subString = [self subString];
  
	bool highlighted = [self isHighlighted];
  
	if (image) {
    frame.origin.x += imageTextPadding;
		NSSize drawnImageSize = [self drawImage: image withFrame: frame];
    frame.origin.x += imageTextPadding + drawnImageSize.width;
	}
	
	if (nameString) {
		NSAttributedString * attributedNameString = nil, * attributedSubString = nil;
		NSColor * nameStringColor, * subStringStringColor;
    
    NSParagraphStyle * paragraphStyle = [self paragraphStyle];
		NSDictionary * nameAttributes = nil, * subStringAttributes = nil;
		float	nameStringHeight = 0.0, subStringHeight = 0.0, textSpacing = 0.0;
    
		NSWindow * window;
    
		if (highlighted) {
			nameStringColor = [NSColor alternateSelectedControlTextColor];
			subStringStringColor = [NSColor alternateSelectedControlTextColor];
		} else {
      nameStringColor = [NSColor controlTextColor];
			subStringStringColor = [NSColor colorWithCalibratedWhite: 0.4 alpha: 1.0];
		}
    
    nameAttributes = [NSDictionary dictionaryWithObjectsAndKeys: paragraphStyle, NSParagraphStyleAttributeName, [self nameFont], NSFontAttributeName, nameStringColor, NSForegroundColorAttributeName, nil];
		attributedNameString = [[NSAttributedString alloc] initWithString: nameString attributes: nameAttributes];
		
		if (subString) {
			subStringAttributes = [NSDictionary dictionaryWithObjectsAndKeys: paragraphStyle, NSParagraphStyleAttributeName, [self subStringFont], NSFontAttributeName, subStringStringColor, NSForegroundColorAttributeName, nil];
			attributedSubString = [[NSAttributedString alloc] initWithString: subString attributes: subStringAttributes];
		}
    
    nameStringHeight = [nameString sizeWithAttributes: nameAttributes].height;
		if (subString) {
			subStringHeight = [subString sizeWithAttributes: subStringAttributes].height;
		}
    
    if (subString) {
			textSpacing = (frame.size.height - nameStringHeight - subStringHeight) / 3.0;

			if (textSpacing < 0.0) {
				textSpacing = 0.0;
      }
      
			frame.origin.y += textSpacing;
		}
    else {
      frame.origin.y += (frame.size.height - nameStringHeight) / 2.0;
    }
     
		[attributedNameString drawInRect: frame];
		if (subString) {
      frame.origin.y += nameStringHeight + textSpacing;
			[attributedSubString drawInRect: frame];
		}
	}
  
	[NSGraphicsContext restoreGraphicsState];
}

- (NSParagraphStyle *) paragraphStyle
{
  NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  [paragraphStyle setAlignment: [self alignment]];
  [paragraphStyle setLineBreakMode: LINEBREAKMODE];

  return paragraphStyle;
}

@end

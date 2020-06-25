/*
    This file is part of HelpViewer (http://www.roard.com/helpviewer)
    Copyright (C) 2003 Nicolas Roard (nicolas@roard.com)
                  2020 Riccardo Mottola <rm@gnu.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include "NoteCell.h"

@implementation NoteCell

- (id) initWithTextView: (NSTextView*) textview 
{
  if ((self = [super init]))
    {
      _image = nil;
      _note = nil;
      _color = nil;
      [self resizeWithTextView: textview];
    }
  return self;    
}

- (void) setText: (NSMutableAttributedString*) text
{
    ASSIGN (_note, text);
}

- (void) setImage:  (NSImage*) img
{
    ASSIGN (_image, img);
}

- (void) setColor: (NSColor*) color
{
    ASSIGN (_color, color);
}

- (NSSize) cellSize 
{
    return _size;
}

- (void) resize: (id) sender
{
	[self resizeWithTextView: [sender object]];
}

- (void) resizeWithTextView: (NSTextView*) textView
{
    CGFloat height = [_image size].height;

    CGFloat heighttext;
    CGFloat imageWidth = [_image size].width;
    CGFloat imageHeight = [_image size].height;   
    CGFloat border = 12.0;
    CGFloat Margin = ([textView bounds].size.width - 16 - imageWidth- border);

      NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
      [paragraph setAlignment: NSLeftTextAlignment];
      [paragraph setTailIndent: Margin];
      
      NSDictionary* attributes = [NSDictionary dictionaryWithObject: paragraph 
	    forKey: NSParagraphStyleAttributeName];

      [_note addAttributes: attributes range: NSMakeRange (0, [_note length])];

      heighttext = [_note size].height;

    NSLog (@"heightext : %.2f height : %.2f", heighttext, height);
    if (heighttext > height) height = heighttext;

    float width = [textView bounds].size.width - 16;
    if (width <= 0) width = 375;

    _size = NSMakeSize (width, height);
}

- (void) drawWithFrame: (NSRect) cellFrame
    inView: (NSView*) controlView
{
      if (![controlView window])
	            return;

        [controlView lockFocus];

	//[[NSColor colorWithCalibratedRed: 0.62 green: 0.71 blue: 0.84 alpha:1.0] set];
	//[[NSColor colorWithCalibratedRed: 0.81 green: 0.84 blue: 0.88 alpha:1.0] set];
	//[[NSColor colorWithCalibratedRed: 0.88 green: 0.78 blue: 0.78 alpha:1.0] set];
	[_color set];

	//NSRectFill (cellFrame);

	//[[NSColor blackColor] set];

	NSBezierPath* path = [[NSBezierPath alloc] init];

	CGFloat radius = 8;

	NSPoint p1 = NSMakePoint (cellFrame.origin.x, cellFrame.origin.y + radius);
	NSPoint p2 = NSMakePoint (cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height - radius);
	NSPoint p3 = NSMakePoint (cellFrame.origin.x + radius, cellFrame.origin.y + cellFrame.size.height);
	NSPoint p4 = NSMakePoint (cellFrame.origin.x + cellFrame.size.width - radius, cellFrame.origin.y + cellFrame.size.height);
	NSPoint p5 = NSMakePoint (cellFrame.origin.x + cellFrame.size.width, cellFrame.origin.y + cellFrame.size.height - radius);
	NSPoint p6 = NSMakePoint (cellFrame.origin.x + cellFrame.size.width, cellFrame.origin.y + radius);
	NSPoint p7 = NSMakePoint (cellFrame.origin.x + cellFrame.size.width - radius, cellFrame.origin.y);
	NSPoint p8 = NSMakePoint (cellFrame.origin.x + radius, cellFrame.origin.y);

	NSPoint pr1 = NSMakePoint (cellFrame.origin.x + radius, cellFrame.origin.y + cellFrame.size.height - radius);
	NSPoint pr2 = NSMakePoint (cellFrame.origin.x + cellFrame.size.width - radius, cellFrame.origin.y + cellFrame.size.height - radius);
	NSPoint pr3 = NSMakePoint (cellFrame.origin.x + cellFrame.size.width - radius, cellFrame.origin.y + radius);
	NSPoint pr4 = NSMakePoint (cellFrame.origin.x + radius, cellFrame.origin.y + radius);

	[path moveToPoint: p1];
	[path lineToPoint: p2];
	//[path appendBezierPathWithArcFromPoint: p2 toPoint: p3 radius: radius];
	[path appendBezierPathWithArcWithCenter: pr1 radius: radius startAngle: 180 endAngle: 90 clockwise: YES];
	//[path moveToPoint: p3];
	[path lineToPoint: p4];
	//[path appendBezierPathWithArcFromPoint: p4 toPoint: p5 radius: radius];
	[path appendBezierPathWithArcWithCenter: pr2 radius: radius startAngle: 90 endAngle: 0 clockwise: YES];
	//[path moveToPoint: p5];
	[path lineToPoint: p6];
	//[path appendBezierPathWithArcFromPoint: p6 toPoint: p7 radius: radius];
	[path appendBezierPathWithArcWithCenter: pr3 radius: radius startAngle: 0 endAngle: 270 clockwise: YES];
	//[path moveToPoint: p7];
	[path lineToPoint: p8];
	//[path appendBezierPathWithArcFromPoint: p8 toPoint: p1 radius: radius];
	[path appendBezierPathWithArcWithCenter: pr4 radius: radius startAngle: 270 endAngle: 180 clockwise: YES];
	[path fill];

	if (_note)
	{
		  
	      int i;
	      CGFloat interspace = 20.0;
	      CGFloat imageWidth = [_image size].width;
	      CGFloat imageHeight = [_image size].height;   
	      CGFloat spaceMargin = 20.0;
	      CGFloat border = 12.0;
	      //NSLog (@"cellFrame.size.width : %.2f", cellFrame.size.width);
	      CGFloat Margin = (cellFrame.size.width - imageWidth- border);
	
	      NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
	      [paragraph setAlignment: NSLeftTextAlignment];
	      [paragraph setTailIndent: Margin];
	      
	      NSDictionary* attributes = [NSDictionary dictionaryWithObject: paragraph 
		    forKey: NSParagraphStyleAttributeName];

	      [_note addAttributes: attributes range: NSMakeRange (0, [_note length])];
	      NSSize sizenote = [_note size];

	      CGFloat posy = 0;
	      if (sizenote.height < cellFrame.size.height)
	      {
	      	posy = (cellFrame.size.height - sizenote.height) / 2;
	      }
	      posy += cellFrame.origin.y;
	      
	      NSPoint imageOrigin = NSMakePoint (cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height);
	      if (cellFrame.size.height > imageHeight)
	      {
	      	imageOrigin = NSMakePoint (cellFrame.origin.x, cellFrame.origin.y + 
			cellFrame.size.height - (cellFrame.size.height - imageHeight)/2);
	      }
	      
	      [_image compositeToPoint: imageOrigin operation: NSCompositeSourceAtop];
	      

	      [_note drawAtPoint: NSMakePoint (cellFrame.origin.x + imageWidth + border, posy)];
	}
      [controlView unlockFocus];
}

@end

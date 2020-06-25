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

#include "FigureCell.h"

@implementation FigureCell

- (id) initWithSize: (NSSize) size 
{
    [super init];
    _size = size;
    _image = nil;
    _legends = nil;
    return self;    
}

- (void) setLegends: (NSArray*) legends
{
    ASSIGN (_legends, legends);
}

- (void) setImage:  (NSImage*) img
{
    ASSIGN (_image, img);
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
    CGFloat minimalHeight;
    CGFloat imageWidth = [_image size].width;
    CGFloat imageHeight = [_image size].height;   

    if (_legends)
    {
	      int i;
	      CGFloat interspace = 20;
	      CGFloat spaceMargin = 20;
	      CGFloat border = 12;
	      CGFloat Margin = ([textView bounds].size.width - imageWidth - 2*spaceMargin - 2*border)/2;

	      NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
	      [paragraph setAlignment: NSLeftTextAlignment];
	      [paragraph setTailIndent: Margin];
	      [paragraph setHeadIndent: 0.0];
	      [paragraph setFirstLineHeadIndent: 0.0];

	      NSDictionary* attributes = [NSDictionary dictionaryWithObject: paragraph 
		    forKey: NSParagraphStyleAttributeName];

	      NSMutableArray* preLeftLegends = [NSMutableArray array];
	      NSMutableArray* preRightLegends = [NSMutableArray array];
	      
	      for (i=0; i<[_legends count]; i++)
	      {
		  Legend* current = [_legends objectAtIndex: i];
		  [[current legend] addAttributes: attributes 
			range: NSMakeRange (0, [[current legend] length])];
		  NSSize s = [[current legend] size];

		  [current setHeight: s.height];
		  if ([current point].x > (imageWidth/2))
		  {
		    [current setRightPos]; // on range ˆ droite
		    [preRightLegends addObject: current];
		  }
		  else
		  {
		    [preLeftLegends addObject: current];
		  }        
	      }
		    
	      NSArray* LeftLegends = [preLeftLegends sortedArrayUsingSelector: @selector (compareLegends:)];
	      NSArray* RightLegends = [preRightLegends sortedArrayUsingSelector: @selector (compareLegends:)];

	      CGFloat LeftLegendsHeight = 0;
	      CGFloat RightLegendsHeight = 0;
	      
	      for (i=0; i < [LeftLegends count]; i++)
	      {
		    LeftLegendsHeight += [[LeftLegends objectAtIndex: i] height];
	      }

	      for (i=0; i < [RightLegends count]; i++)
	      {
		    RightLegendsHeight += [[RightLegends objectAtIndex: i] height];
	      }
	      
	      float minimalInterspace = 8;

	      minimalHeight = LeftLegendsHeight+([LeftLegends count]+1)*minimalInterspace;

	      if (imageHeight < minimalHeight) imageHeight = minimalHeight;
    }

    _size = NSMakeSize ([textView bounds].size.width, imageHeight);
}

- (void) drawLegends: (NSArray*) legends onRight: (BOOL) right 
    withInterspace: (CGFloat) interspace withAttributes: (NSDictionary*) attributes
    withFrame: (NSRect) cellFrame withBorder: (CGFloat) border withMargin: (CGFloat) Margin 
    withSpaceMargin: (CGFloat) spaceMargin withImageWidth: (CGFloat) imageWidth withPosImage: (CGFloat) posImage
{
      CGFloat posY = interspace;
      int i;
      for (i=0; i < [legends count]; i++)
      {
	  NSRect r;
          NSPoint t, tp, p;
          Legend* current = [legends objectAtIndex: i];
          [[current legend] addAttributes: attributes 
                range: NSMakeRange (0, [[current legend] length])];
          NSSize s = [[current legend] size];
//	  NSSize s = [[current legend] sizeWithAttributes: attributes];

          if (!right)
          {
            r  = NSMakeRect (cellFrame.origin.x + border + (Margin-s.width) - 2, cellFrame.origin.y + posY - 2, s.width + 4, s.height + 4);
            t  = NSMakePoint (cellFrame.origin.x + border + (Margin-s.width), cellFrame.origin.y + posY);
            tp = NSMakePoint (cellFrame.origin.x + border + Margin + 2, cellFrame.origin.y + posY + s.height/2);
          }
          else
          {
            r  = NSMakeRect (cellFrame.origin.x + border + Margin + (2*spaceMargin) + imageWidth - 2, 
                    cellFrame.origin.y + posY - 2, s.width + 4, s.height + 4);
            t  = NSMakePoint (cellFrame.origin.x + border + Margin + (2*spaceMargin) + imageWidth,
                    cellFrame.origin.y + posY);
            tp = NSMakePoint (cellFrame.origin.x + border + Margin + (2*spaceMargin) + imageWidth - 2, 
                    cellFrame.origin.y + posY + s.height/2);
          }
          
          p  = NSMakePoint (cellFrame.origin.x + border + Margin + spaceMargin + [current point].x,
		  cellFrame.origin.y + [current point].y + posImage);
          
         // [[NSBezierPath bezierPathWithRect: r] stroke];
	[[NSColor colorWithCalibratedRed: 0.81 green: 0.84 blue: 0.88 alpha:1.0] set];
	NSBezierPath* path = [[NSBezierPath alloc] init];

	CGFloat radius = 8;

	NSPoint p1 = NSMakePoint (r.origin.x, r.origin.y + radius);
	NSPoint p2 = NSMakePoint (r.origin.x, r.origin.y + r.size.height - radius);
	NSPoint p3 = NSMakePoint (r.origin.x + radius, r.origin.y + r.size.height);
	NSPoint p4 = NSMakePoint (r.origin.x + r.size.width - radius, r.origin.y + r.size.height);
	NSPoint p5 = NSMakePoint (r.origin.x + r.size.width, r.origin.y + r.size.height - radius);
	NSPoint p6 = NSMakePoint (r.origin.x + r.size.width, r.origin.y + radius);
	NSPoint p7 = NSMakePoint (r.origin.x + r.size.width - radius, r.origin.y);
	NSPoint p8 = NSMakePoint (r.origin.x + radius, r.origin.y);

	NSPoint pr1 = NSMakePoint (r.origin.x + radius, r.origin.y + r.size.height - radius);
	NSPoint pr2 = NSMakePoint (r.origin.x + r.size.width - radius, r.origin.y + r.size.height - radius);
	NSPoint pr3 = NSMakePoint (r.origin.x + r.size.width - radius, r.origin.y + radius);
	NSPoint pr4 = NSMakePoint (r.origin.x + radius, r.origin.y + radius);

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
//          [[current legend] drawAtPoint: t withAttributes: attributes];            
          [[current legend] drawAtPoint: t];
	  NSBezierPath* path2 = [NSBezierPath bezierPath];
          
          [path2 moveToPoint: tp];                        
	  [path2 lineToPoint: p];
	  [path2 stroke];          
          
          posY += s.height + interspace;          
      }
}


- (void) drawWithFrame: (NSRect) cellFrame
    inView: (NSView*) controlView
{
      if (![controlView window]) return;

      [controlView lockFocus];

	[[NSColor whiteColor] set];
	NSRectFill (cellFrame);

      //NSLog (@"drawInteriorWithFrame de FigureCell ... ");
      //NSLog (@"image : %@", _image);
      //NSLog (@"cellframe origin x : %.2f origin y : %.2f", cellFrame.origin.x, cellFrame.origin.y);
      NSLog (@"cellFrame height : %.2f", cellFrame.size.height);

	if (_legends)
	{
		  
	      int i;
	      CGFloat interspace = 20.0;
	      CGFloat imageWidth = [_image size].width;
	      CGFloat imageHeight = [_image size].height;   
	      CGFloat spaceMargin = 20.0;
	      CGFloat border = 12.0;
	      CGFloat Margin = (cellFrame.size.width - imageWidth - 2*spaceMargin - 2*border)/2;

	      CGFloat posImage = 0.0;
	      if (imageHeight < cellFrame.size.height)
	      {
	      	posImage = (cellFrame.size.height - imageHeight)/2;
	      }
	      NSPoint imageOrigin = NSMakePoint (cellFrame.origin.x + border + Margin + spaceMargin,
		      cellFrame.origin.y + imageHeight + posImage);
	      [_image compositeToPoint: imageOrigin operation: NSCompositeSourceAtop];
	      
	      NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
	      [paragraph setAlignment: NSLeftTextAlignment];
	      [paragraph setTailIndent: Margin];
	      [paragraph setHeadIndent: 0.0];
	      [paragraph setFirstLineHeadIndent: 0.0];
	      
	      NSDictionary* attributes = [NSDictionary dictionaryWithObject: paragraph 
		    forKey: NSParagraphStyleAttributeName];

	      NSMutableArray* preLeftLegends = [NSMutableArray array];
	      NSMutableArray* preRightLegends = [NSMutableArray array];
	      
	      for (i=0; i<[_legends count]; i++)
	      {
		  Legend* current = [_legends objectAtIndex: i];
		  [[current legend] addAttributes: attributes 
			range: NSMakeRange (0, [[current legend] length])];
		  NSSize s = [[current legend] size];

		  [current setHeight: s.height];
		  if ([current point].x > (imageWidth/2))
		  {
		    [current setRightPos]; // on range ˆ droite
		    [preRightLegends addObject: current];
		  }
		  else
		  {
		    [preLeftLegends addObject: current];
		  }        
	      }
		    
	      NSArray* LeftLegends = [preLeftLegends sortedArrayUsingSelector: @selector (compareLegends:)];
	      NSArray* RightLegends = [preRightLegends sortedArrayUsingSelector: @selector (compareLegends:)];

	      //NSLog (@"preLL : %d LL : %d", [preLeftLegends count], [LeftLegends count]);
	      //NSLog (@"preRL : %d RL : %d", [preRightLegends count], [RightLegends count]);

	      CGFloat LeftLegendsHeight = 0.0;
	      CGFloat RightLegendsHeight = 0.0;
	      
	      for (i=0; i < [LeftLegends count]; i++)
	      {
		    LeftLegendsHeight += [[LeftLegends objectAtIndex: i] height];
	      }

	      for (i=0; i < [RightLegends count]; i++)
	      {
		    RightLegendsHeight += [[RightLegends objectAtIndex: i] height];
	      }
	      
	      interspace = (cellFrame.size.height - LeftLegendsHeight)/ ([LeftLegends count]+1);      

	      [self drawLegends: LeftLegends onRight: NO withInterspace: interspace
		    withAttributes: attributes withFrame: cellFrame withBorder: border
		    withMargin: Margin withSpaceMargin: spaceMargin withImageWidth: imageWidth
		    withPosImage: posImage];

	      interspace = (cellFrame.size.height - RightLegendsHeight)/ ([RightLegends count]+1);      
	      [self drawLegends: RightLegends onRight: YES withInterspace: interspace
		    withAttributes: attributes withFrame: cellFrame withBorder: border
		    withMargin: Margin withSpaceMargin: spaceMargin withImageWidth: imageWidth
		    withPosImage: posImage];

	}
      [controlView unlockFocus];
}

@end

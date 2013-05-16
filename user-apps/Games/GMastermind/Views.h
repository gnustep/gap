/*
	Views.h

	Main View class

	Copyright (C) 2003 Marko Riedel

	Author: Marko Riedel <mriedel@bogus.example.com>
	Date:	5 July 2003

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA
*/

#import <AppKit/NSDragging.h>
#import <AppKit/NSView.h>
#import <AppKit/NSColor.h>


#define PEGDIMENSION    48 // 40
#define DRAGDIMENSION   (PEGDIMENSION/2)

#define PEGMARGIN       8 // 6

#define SEPARATOR       60

@interface Result : NSView
{
    int black, white;
}

- initAtPoint:(NSPoint)aPoint;

- getBlack:(int *)bptr andWhite:(int *)wptr;
- setBlack:(int)bval andWhite:(int)wval;

- (void)drawRect:(NSRect)aRect;

@end

@interface Peg : NSView
{
    NSColor *color;
    int cvalue;
}

- initAtPoint:(NSPoint)aPoint;

- color;
- setColor:(NSColor *)aColor;

- (int)cvalue;
- setCValue:(int)cval;

- (void)drawRect:(NSRect)aRect;

@end

@interface SourcePeg : Peg

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag;

- makeDragImageForColor:(int)val withComponents:(CGFloat *)thecomps;

- (void)mouseDown:(NSEvent *)theEvent;

@end

@interface DestinationPeg : SourcePeg
{
    BOOL active;
}

- initAtPoint:(NSPoint)aPoint;

- setActive:(BOOL)flag;

- (void)drawRect:(NSRect)aRect;


- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;

@end


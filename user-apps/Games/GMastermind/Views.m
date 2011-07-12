/*
	Views.m

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


#include "Views.h"

#include <AppKit/PSOperators.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSBezierPath.h>
#include <AppKit/NSPasteboard.h>
#include <AppKit/NSImage.h>
#include <AppKit/NSEvent.h>

#include <math.h>

void shadow(float x, float y, float r)
{
    int angle;
    PSsetlinewidth(2.0);

    for(angle=132; angle<492; angle+=6){
	float gray =
	    (angle < 312 ? 0.9-(float)(angle-132)/180.0*0.8 :
	     0.1+(float)(angle-312)/180.0*0.8);
	PSsetgray(gray);
	PSarc(x, y, r, angle, angle+6);
	PSstroke();
    }
}

void shadow2(float x, float y, float r)
{
    int angle;
    PSsetlinewidth(2.0);

    for(angle=312; angle<672; angle+=6){
	float gray =
	    (angle < 492 ? 0.9-(float)(angle-312)/180.0*0.8 :
	     0.1+(float)(angle-492)/180.0*0.8);
	PSsetgray(gray);
	PSarc(x, y, r, angle, angle+6);
	PSstroke();
    }
}

void tile(NSRect rect)
{
    NSRectEdge sides[] = {
	NSMinXEdge, NSMaxXEdge, NSMinYEdge, NSMaxYEdge,
	NSMinXEdge, NSMaxXEdge, NSMinYEdge, NSMaxYEdge};
    float grays[] = {
	NSWhite, NSBlack, NSBlack, NSWhite,
	NSWhite, NSBlack, NSBlack, NSWhite};
    NSDrawTiledRects(rect, rect, sides, grays, 8);
}

@implementation Result

- initAtPoint:(NSPoint)aPoint
{
    NSRect frame;

    frame.origin = aPoint;
    frame.size.width = frame.size.height = PEGDIMENSION;

    [super initWithFrame:frame];

    black = white = 0;

    return self;
}

- getBlack:(int *)bptr andWhite:(int *)wptr;
{
    *bptr = black; *wptr = white;

    return self;
}

- setBlack:(int)bval andWhite:(int)wval
{
    black = bval; white = wval;
    [self setNeedsDisplay:YES];
    return self;
}

- (void)drawRect:(NSRect)aRect
{
    int index;
    tile([self bounds]);
    
    for(index=0; index<4; index++){
        float 
            x = PEGDIMENSION/4+(index%2)*PEGDIMENSION/2,
            y = PEGDIMENSION/4+(index/2)*PEGDIMENSION/2;
        NSColor *col = 
            (index<white ? 
             [NSColor whiteColor] : [NSColor blackColor]);

        if(index<white+black){
            [col set];
            PSarc(x, y, PEGDIMENSION/5, 0, 360);
            PSfill();
	    shadow(x, y, PEGDIMENSION/5);
        }
        else{
	    PSsetlinewidth(1.0);
            [[NSColor blackColor] set];
            PSarc(x, y, PEGDIMENSION/5, 0, 360);
            PSstroke();
	    shadow2(x, y, PEGDIMENSION/5);
        }
    }
}

@end

@implementation Peg

- initAtPoint:(NSPoint)aPoint
{
    NSRect frame;

    frame.origin = aPoint;
    frame.size.width = frame.size.height = PEGDIMENSION;

    [super initWithFrame:frame];

    color = nil;

    return self;
}

- color
{
    return color;
}

- setColor:(NSColor *)aColor
{
    float thecomps[4];

    if(color!=nil){
        [color release];
    }
    color = aColor; 
    [color retain];

    if(color==nil){
        cvalue = 0;
    }
    else{
        [color getRed:thecomps 
               green:thecomps+1 
               blue:thecomps+2 
               alpha:thecomps+3];

        cvalue = 
            (thecomps[0]==1.0 ? 4 : 0) +
            (thecomps[1]==1.0 ? 2 : 0) +
            (thecomps[2]==1.0 ? 1 : 0);
    }

    [self setNeedsDisplay:YES];

    return self;
}

- (int)cvalue
{
    return cvalue;
}

- setCValue:(int)cval
{
    float thecomps[3];

    if(color!=nil){
        [color release];
    }

    if(!cval){
        cvalue = 0;
        color = nil;
        return self;
    }

    cvalue = cval;

    thecomps[0] = (cvalue & 4 ? 1.0 : 0.0);
    thecomps[1] = (cvalue & 2 ? 1.0 : 0.0);
    thecomps[2] = (cvalue & 1 ? 1.0 : 0.0);

    color = [NSColor colorWithDeviceRed:thecomps[0]
                     green:thecomps[1]
                     blue:thecomps[2]
                     alpha:1.0];   

    [color retain];
    
    return self;
}


#define RAD2 (PEGDIMENSION-2*PEGMARGIN)
- (void)drawRect:(NSRect)aRect
{
    if(color!=nil){
        [color set];
        PSarc(PEGDIMENSION/2, PEGDIMENSION/2, 
              PEGDIMENSION/2-PEGMARGIN, 0, 360);
        PSfill();

	shadow(PEGDIMENSION/2, PEGDIMENSION/2, 
	       PEGDIMENSION/2-PEGMARGIN);
    }
    else{
	shadow2(PEGDIMENSION/2, PEGDIMENSION/2, 
		PEGDIMENSION/2-PEGMARGIN);
    }

    tile([self bounds]);
}

@end

@implementation SourcePeg

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return NSDragOperationCopy;
}

static NSImage *dragImages[8] = {
    nil, nil, nil, nil,
    nil, nil, nil, nil
};

- makeDragImageForColor:(int)val withComponents:(float *)thecomps
{
    NSImage *dragImage = 
      [[NSImage alloc] 
	  initWithSize:NSMakeSize(PEGDIMENSION/2, PEGDIMENSION/2)];
    NSBitmapImageRep *rep;
    unsigned char *base, *data;
    int x, y;
    float rsq, rsq1, d, dx, dy;

    rsq = DRAGDIMENSION/2-2; rsq *= rsq;
    rsq1 = DRAGDIMENSION/2; rsq1 *= rsq1;

    rep = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
              pixelsWide:DRAGDIMENSION
              pixelsHigh:DRAGDIMENSION
              bitsPerSample:8
              samplesPerPixel:4
              hasAlpha:YES
              isPlanar:NO
              colorSpaceName:NSDeviceRGBColorSpace
	      bytesPerRow:DRAGDIMENSION*4
              bitsPerPixel:32];
    data = [rep bitmapData];

    for(x=0; x<DRAGDIMENSION; x++){
        for(y=0; y<DRAGDIMENSION; y++){
            float ccomps[4];

            dx = x-DRAGDIMENSION/2;
            dy = y-DRAGDIMENSION/2;

            d = dx*dx+dy*dy; 

            if(d<rsq){
                ccomps[0] = thecomps[0];
                ccomps[1] = thecomps[1];
                ccomps[2] = thecomps[2];
                ccomps[3] = 1.0;
            }
            else if(d<rsq1){
		float gray;
		float angle = (atan2(dy, -dx)+M_PI)/M_PI*180.0;
		if(angle<132.0){
		    angle += 360.0;
		}
		angle -= (float)(((int)angle)%6);

		gray =
		    (angle < 312.0 ? 0.9-(angle-132.0)/180.0*0.8 :
		     0.1+(float)(angle-312.0)/180.0*0.8);

                ccomps[0] = gray;
                ccomps[1] = gray;
                ccomps[2] = gray;
                ccomps[3] = 1.0;
            }
            else{
                ccomps[0] = 0;
                ccomps[1] = 0;
                ccomps[2] = 0;
                ccomps[3] = 0;
            }

            base = data+y*DRAGDIMENSION*4+x*4;
            base[0] = (int)(ccomps[0]*255.0);
            base[1] = (int)(ccomps[1]*255.0);
            base[2] = (int)(ccomps[2]*255.0);
            base[3] = (int)(ccomps[3]*255.0);
        }
    }

    [dragImage addRepresentation:rep];
    [dragImage retain];

    dragImages[val] = dragImage;
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSEventType theType = [theEvent type];
    NSPoint startp;
    float dx, dy, rsq, thecomps[4];

    if(color==nil){
        return;
    }

    startp = [theEvent locationInWindow];
    startp = [self convertPoint:startp fromView: nil];

    dx = startp.x-PEGDIMENSION/2;
    dy = startp.y-PEGDIMENSION/2;

    rsq = PEGDIMENSION/2-PEGMARGIN; rsq *= rsq;

    if(dx*dx+dy*dy<rsq && theType==NSLeftMouseDown){
        NSPasteboard *pboard =
            [NSPasteboard pasteboardWithName:NSDragPboard];

        [pboard declareTypes:
                    [NSArray arrayWithObjects:NSColorPboardType, nil]
                owner:self];
        [color writeToPasteboard:pboard];

        thecomps[0] = (cvalue & 4 ? 1.0 : 0.0);
        thecomps[1] = (cvalue & 2 ? 1.0 : 0.0);
        thecomps[2] = (cvalue & 1 ? 1.0 : 0.0);

        if(dragImages[cvalue]==nil){
            [self makeDragImageForColor:cvalue 
                  withComponents:thecomps];
        }

        [self dragImage:dragImages[cvalue]
              at:NSMakePoint(PEGDIMENSION/4, PEGDIMENSION/4)
              offset:NSMakeSize(0, 0)
              event:theEvent
              pasteboard:pboard
              source:self
              slideBack:YES];
   }

    return;
}

@end

@implementation DestinationPeg

- initAtPoint:(NSPoint)aPoint
{
    [super initAtPoint:aPoint];

    active = YES;
    [self registerForDraggedTypes:
              [NSArray arrayWithObjects:NSColorPboardType, nil]];
    
    return self;
}

- setActive:(BOOL)flag
{
    if(flag!=active){
        [self setNeedsDisplay:YES];
    }
    active = flag;
    return self;
}

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];

    if(active==YES){
	NSRect bounds = [self bounds];
	bounds.origin.x += 2.0;
	bounds.origin.y += 2.0;
	bounds.size.width  -= 4.0;
	bounds.size.height -= 4.0;

	tile(bounds);
    }
}

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb;
    NSDragOperation sourceDragMask;

    if(active==NO){
        return NSDragOperationNone;
    }

    sourceDragMask = [sender draggingSourceOperationMask];
    pb = [sender draggingPasteboard];
 
    if([[pb types] indexOfObject:NSColorPboardType]!=NSNotFound){
        if(sourceDragMask & NSDragOperationCopy){
            NSColor *col = [NSColor colorFromPasteboard:pb], *rgb;
            float ccomps[4];

            rgb = [col colorUsingColorSpaceName:NSDeviceRGBColorSpace];

            [rgb getRed:ccomps green:ccomps+1 blue:ccomps+2 
                   alpha:ccomps+3];

            if((ccomps[0]==0.0 || ccomps[0]==1.0) &&
               (ccomps[1]==0.0 || ccomps[1]==1.0) &&
               (ccomps[2]==0.0 || ccomps[2]==1.0) &&
               ccomps[3]==1.0){
                float s = ccomps[0]+ccomps[1]+ccomps[2];
                if(s==1.0 || s==2.0){
                    return NSDragOperationCopy;
                }
            }
        }
    }
 
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSColor *rgb;

    rgb = [[NSColor colorFromPasteboard:pb] 
              colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    [self setColor:rgb];

    return YES;
}



- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}
 

@end

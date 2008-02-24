//
//  DBOverlayWindowBkgrnd.m
//  Version 1.0
//  22 November 2006
//
//  Created by Dave Batton
//  http://www.Mere-Mortal-Software.com/
//
//  Portions based on the RoundedFloatingPanel class by Matt Gemmell
//
//  Copyright 2006. Some rights reserved.
//  This work is licensed under a Creative Commons license:
//  http://creativecommons.org/licenses/by/2.5/
//

#import "DBOverlayWindowBkgrnd.h"


@implementation DBOverlayWindowBkgrnd


- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(unsigned int)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag {
    
    if (self = [super initWithContentRect:contentRect 
								styleMask:NSBorderlessWindowMask 
								  backing:NSBackingStoreBuffered 
									defer:NO]) {
		
		_cornerRadius = 20.0;

		[self setBackgroundColor:[NSColor clearColor]];
		[self setOverlayColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.35]];

		[self setAlphaValue:0.0];	// We start hidden, then fade it in when we get an -orderFront.
		[self setOpaque:NO];
		[self setHasShadow:NO];

			// Modify this window's behavior so it ignores clicks.
			// We also prevent it from being hidden.
		[self setLevel:NSFloatingWindowLevel];
		[self setIgnoresMouseEvents:YES];
		[self setCanHide:YES];

			// Make the background window a child of the message window (but behind it) so that moving the message window moves the background with it.	
		[self setDelegate:self];
	}
    
	return self;
}



- (void)update
{
	[super update];
}




//---------------------------------------------------------- 
//  overlayColor 
//---------------------------------------------------------- 
- (NSColor *)overlayColor
{
    return [[_overlayColor retain] autorelease]; 
}


- (void)setOverlayColor:(NSColor *)aColor
{
    if (_overlayColor != aColor) {
        [_overlayColor release];
        _overlayColor = [aColor copy];

		[self setBackgroundColor:[self backgroundAsColor]];
		[self display];		
    }
}




	// This is a trick I learned from the HUDWindow class posted by Matt Gemmell on his website: <http://mattgemmell.com/source/>. It allows the drawing of a shape as the window background without requiring a custom view or any other content in the window. All of the NSBezierPath routines here are copied from his example.
- (NSColor *)backgroundAsColor
{
    NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];
    [bg lockFocus];
    
		// Make background path
    NSRect bgRect = NSMakeRect(0, 0, [bg size].width, [bg size].height);
    int minX = NSMinX(bgRect);
    int midX = NSMidX(bgRect);
    int maxX = NSMaxX(bgRect);
    int minY = NSMinY(bgRect);
    int midY = NSMidY(bgRect);
    int maxY = NSMaxY(bgRect);

    NSBezierPath *bgPath = [NSBezierPath bezierPath];
    
		// Bottom edge and bottom-right curve.
    [bgPath moveToPoint:NSMakePoint(midX, minY)];
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                     toPoint:NSMakePoint(maxX, midY) 
                                      radius:_cornerRadius];
    
		// Right edge and top-right curve.
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                     toPoint:NSMakePoint(midX, maxY) 
                                      radius:_cornerRadius];
    
		// Top edge and top-left curve.
    [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                     toPoint:NSMakePoint(minX, midY) 
                                      radius:_cornerRadius];
    
		// Left edge and bottom-left curve.
    [bgPath appendBezierPathWithArcFromPoint:bgRect.origin 
                                     toPoint:NSMakePoint(midX, minY) 
                                      radius:_cornerRadius];
    [bgPath closePath];

	[[self overlayColor] set];
	
		// Composite background color and transparency into bg.
	[bgPath fill];
    
	[bg unlockFocus];
    
    return [NSColor colorWithPatternImage:[bg autorelease]];
}

 


- (void)windowDidResize:(NSNotification *)aNotification
{
    [self setBackgroundColor:[self backgroundAsColor]];  // Yes, I checked. This is necessary.
}




- (void)dealloc
{
    [self setBackgroundColor:nil];
    [super dealloc];
}


@end

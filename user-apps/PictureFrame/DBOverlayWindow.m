//
//  DBOverlayWindow.m
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


#import "DBOverlayWindow.h"


@implementation DBOverlayWindow


- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(unsigned int)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag {
    
    if (self = [super initWithContentRect:contentRect 
								styleMask:NSBorderlessWindowMask 
								  backing:NSBackingStoreBuffered 
									defer:NO]) {

			// Completely hide the window so only its contents can be seen.
			// The semi-transparent background will actually be displayed by another window that we'll open in -awakeFromNib.
			// Although we can fake that by setting an object's color to appear translucent, that messes up any text we draw on top of it, and looks like crap. This technique gives us the visual affect we want.
        [self setBackgroundColor:[NSColor clearColor]];
        [self setAlphaValue:0.0];	// We start hidden, then fade it in when we get an -orderFront.
        [self setOpaque:NO];

			// Modify this window's behavior so it ignores clicks.
			// We also prevent it from being hidden.
        [self setLevel:NSFloatingWindowLevel];
		[self setIgnoresMouseEvents:NO];
		[self setCanHide:NO];
		[self setDelegate:self];

		_fadingIn = NO;
		_fadingOut = NO;

        return self;
    }

    return nil;
}




- (void)awakeFromNib {
		// We can't display our transparent background with this message window, so we'll set up another window behind it that will display the transparent background.
	_bkgrndWindow = [[DBOverlayWindowBkgrnd alloc] initWithContentRect:[self frame]
													  styleMask:NSBorderlessWindowMask
														backing:NSBackingStoreBuffered
														  defer:YES];

		// Make the window look like the overlay pannel used by the OS.
	[self addChildWindow:_bkgrndWindow
				 ordered:NSWindowBelow];
}




- (BOOL)canBecomeKeyWindow
{
    return NO;
}




	// _overlayColor accessor method
- (NSColor *)overlayColor
{
    return [[_overlayColor retain] autorelease]; 
}




	// _overlayColor accessor method
- (void)setOverlayColor:(NSColor *)aColor
{
    if (_overlayColor != aColor) {
        [_overlayColor release];
        _overlayColor = [aColor copy];
		[_bkgrndWindow setOverlayColor:_overlayColor];
    }
}




	// When the message window is displayed, we also need to display our background window behind it.
- (void)orderFront:(id)sender
{
		// If we're currently fading out, stop doing this.
	if (_fadingOut == YES) {
		if ([_fadeOutTimer isValid]) {
			[_fadeOutTimer invalidate];
		}
		_fadingOut = NO;
	}
	
		// If we're not already fading in, fade in.
	if (_fadingIn == NO) {
		[_bkgrndWindow orderFront:sender];
		[super orderFront:sender];

		_fadingIn = YES;
		_fadeInTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
										  target:self
										selector:@selector(fadedOrderFront:)
										userInfo:nil 
										 repeats:YES];
	}
}




- (void)orderOut:(id)sender {
		// If we're currently fading in, stop doing this.
	if (_fadingIn == YES) {
		if ([_fadeInTimer isValid]) {
			[_fadeInTimer invalidate];
		}
		_fadingIn = NO;
	}
	
		// If we're not already fading out...
	if (_fadingOut == NO) {
		_fadingOut = YES;
			// Set up our timer to periodically call the -fadedOrderOut: method.
		_fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
														  target:self
														selector:@selector(fadedOrderOut:)
														userInfo:nil 
														 repeats:YES];		
	}
}




	// This gets called by a timer from the window's -orderFront: method to slowly fade in the window.
- (void)fadedOrderFront:(NSTimer *)theTimer
{
    if ([self alphaValue] < 1.0) {
        [self setAlphaValue: [self alphaValue] + 0.05];  // Increase the window's opacity until it's completely visible.
		[_bkgrndWindow setAlphaValue: [self alphaValue]];  // Also show our background window.
		[self invalidateShadow];
    } else {
        [theTimer invalidate];
		_fadingIn = NO;
    }
}




	// This gets called by a timer from the window's -orderOut: method to slowly fade out the window.
- (void)fadedOrderOut:(NSTimer *)theTimer
{
    if ([self alphaValue] > 0.0) {
		[self setAlphaValue:[self alphaValue] - 0.05];  // If window is still partially opaque, reduce its opacity.
		[_bkgrndWindow setAlphaValue:[self alphaValue]];  // Also hide our background window.
    } else {
			// Otherwise, if window is completely transparent, destroy the timer and close the window.
		[_bkgrndWindow orderOut:self];
		[super orderOut:self];
        [theTimer invalidate];
		_fadingOut = NO;
	}
}




- (void)mouseDown:(NSEvent *)theEvent
{    
    NSRect windowFrame = [self frame];
    
		// Get mouse location in global coordinates
    _initialLocation = [self convertBaseToScreen:[theEvent locationInWindow]];
    _initialLocation.x -= windowFrame.origin.x;
    _initialLocation.y -= windowFrame.origin.y;
}




- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentLocation;
    NSPoint newOrigin;
    
    currentLocation = [self convertBaseToScreen:[self mouseLocationOutsideOfEventStream]];
    newOrigin.x = currentLocation.x - _initialLocation.x;
    newOrigin.y = currentLocation.y - _initialLocation.y;
        
    [self setFrameOrigin:newOrigin];
}




- (void)windowDidMove:(NSNotification *)aNotification {
	[_bkgrndWindow setFrame:[self frame] display:NO animate:NO];
	[self invalidateShadow];
}




- (void)windowDidResize:(NSNotification *)aNotification {
	[_bkgrndWindow setFrame:[self frame] display:NO animate:NO];
}




- (void) dealloc {
	if (_fadeInTimer) {
		[_fadeInTimer invalidate];
	}
	if (_fadeOutTimer) {
		[_fadeOutTimer invalidate];
	}
	[_bkgrndWindow release], _bkgrndWindow = nil;
	[super dealloc];
}


@end

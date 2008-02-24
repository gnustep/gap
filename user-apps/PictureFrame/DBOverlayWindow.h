//
//  DBOverlayWindow.h
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

#import <Cocoa/Cocoa.h>
#import "DBOverlayWindowBkgrnd.h"


@interface DBOverlayWindow : NSWindow
{
	DBOverlayWindowBkgrnd *_bkgrndWindow;
	NSColor *_overlayColor;  // NSWindow has already defined _backgroundColor, so we can't use that.
	NSTimer *_fadeOutTimer;
	NSTimer *_fadeInTimer;
	BOOL _fadingIn;
	BOOL _fadingOut;
    NSPoint _initialLocation;
}

- (NSColor *)overlayColor;
- (void)setOverlayColor:(NSColor *)aColor;


@end

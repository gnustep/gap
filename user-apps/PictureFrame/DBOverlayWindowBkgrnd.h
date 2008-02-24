//
//  DBOverlayWindowBkgrnd.h
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


@interface DBOverlayWindowBkgrnd : NSWindow {
    float _cornerRadius;
	NSColor *_overlayColor;  // NSWindow has already defined _backgroundColor.
}

- (NSColor *)overlayColor;
- (void)setOverlayColor:(NSColor *)aColor;
- (NSColor *)backgroundAsColor;


@end

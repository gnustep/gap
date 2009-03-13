/*  -*-objc-*-
 *  GSPdfDocWin.m: Implementation of the GSPdfDocWin Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: February 2002
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "GSPdfDocWin.h"
#include "GNUstep.h"

@implementation GSPdfDocWin

- (void)dealloc
{
	RELEASE (leftButt);
	RELEASE (rightButt);
	RELEASE (matrixScroll);
	RELEASE (zoomField);
	RELEASE (zoomStepper);
	RELEASE (zoomButt);
	RELEASE (handButt);
	RELEASE (scroll);	
	if (window && ([window isVisible])) {
		[window close];
	}
	RELEASE (window);
	
  [super dealloc];
}

- (id)init
{
	self = [super init];

	if (self) {		
		nc = [NSNotificationCenter defaultCenter];

		[NSBundle loadNibNamed: @"GSPdfDocWin.gorm" owner: self];
		[[window contentView] setPostsFrameChangedNotifications: YES];
		
    [nc addObserver: self
           selector: @selector(mainViewDidResize:)
               name: NSViewFrameDidChangeNotification
             object: [window contentView]];    		
		
		[leftButt	setImage: [NSImage imageNamed: @"left.tiff"]];
		[rightButt setImage: [NSImage imageNamed: @"right.tiff"]];
		
		[matrixScroll setHasHorizontalScroller: YES];
    [matrixScroll setHasVerticalScroller: NO]; 
		
		[zoomButt	setImage: [NSImage imageNamed: @"zoomin.tiff"]];
		[handButt setImage: [NSImage imageNamed: @"hand.tiff"]];
		
	 	[scroll setHasHorizontalScroller: YES];
  	[scroll setHasVerticalScroller: YES]; 
		[scroll setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];

  	if ([window setFrameUsingName: @"gspdfdoc"] == NO) {
    	[window setFrame: NSMakeRect(300, 200, 500, 400) display: NO];
  	}    		
		[window orderFrontRegardless];
	}
	
	return self;
}

- (void)mainViewDidResize:(NSNotification *)notif
{
	NSRect r = [[window contentView] frame];

	float h = r.size.height;
	
	[leftButt setFrameOrigin: NSMakePoint(7, h - 54)];
	[rightButt setFrameOrigin: NSMakePoint(63, h - 54)];
	[matrixScroll setFrameOrigin: NSMakePoint(122, h - 54)];
	[zoomField setFrameOrigin: NSMakePoint(351, h - 53)];
	[zoomStepper setFrameOrigin: NSMakePoint(416, h - 54)];
	[zoomButt setFrameOrigin: NSMakePoint(440, h - 54)];
	[handButt setFrameOrigin: NSMakePoint(473, h - 54)];
}

- (NSWindow *)window
{
	return window;
}

- (NSScrollView *)scroll
{
	return scroll;
}

- (NSButton *)leftButt
{
	return leftButt;
}

- (NSButton *)rightButt
{
	return rightButt;
}

- (NSScrollView *)matrixScroll
{
	return matrixScroll;
}

- (NSTextField *)zoomField
{
	return zoomField;
}

- (NSStepper *)zoomStepper
{
	return zoomStepper;
}

- (NSButton *)zoomButt
{
	return zoomButt;
}

- (NSButton *)handButt
{
	return handButt;
}

@end




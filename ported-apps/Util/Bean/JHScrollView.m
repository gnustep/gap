/*
 JHScrollView.m
 Bean

 Created 11 JUL 2006 by JH.
 Copyright (c) 2007 James Hoover

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
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

//based on: ScalingScrollView.m Copyright (c) 1995-2005 by Apple Computer Author: Mike Ferris

#import <Cocoa/Cocoa.h>
#import "JHScrollView.h"

@implementation JHScrollView

#pragma mark -
#pragma mark ---- Init ----
//revision 30 DEC 2006 BH

- (id)initWithFrame:(NSRect)rect
{
	//if ((self = [super initWithFrame:rect])) {  }
	[self setHasVerticalRuler:YES];
    [self setRulersVisible:YES];
	return self;
}

#pragma mark -
#pragma mark ---- Drawing Methods ----

- (void)tile
{
	//NSScrollView does most of the work, drawing the view's components
    [super tile];
	
	//4 July 2007 I finally gave up on trying to show the pageUp/pageDown buttons below the vertical scroller
	//			no trigger for the message [pgUpBtn display] (I tried JHScrollView's tile method, 
	//			WindowDidUpdateNotification, etc.) the buttons would disappear, for instance, during background
	//			repagination
	
	//this shortens the vertical scroller to make room for page up/down buttons similar to scroll buttons
	NSScroller *verticalScroller;
	NSRect verticalScrollerFrame;
	verticalScroller = [self verticalScroller];
    verticalScrollerFrame = [verticalScroller frame];
	//now we'll adjust the vertical scroller size to accomodate the page up/down button locations.
	int spacer = 0;
	if ([self hasHorizontalScroller]) spacer = verticalScrollerFrame.size.width;
	//space adjusts for presence of horizontal scroller (14 May 2007 BH)
	verticalScrollerFrame.size.height = verticalScrollerFrame.size.height - 35 + spacer;
	[verticalScroller setFrameSize:verticalScrollerFrame.size];
	[verticalScroller setFrame:verticalScrollerFrame];
	spacer = nil;
	
}

- (void)drawRect:(NSRect)rect
{
	//if 'Fit Width' view type is selected, do it
	//NOTE: that the scaleFactor here is not actually used, since it is figured instead within the setScaleFactor method
	if ([self isFitWidth]) [self setScaleFactor:1.0];
	//if 'Fit Page' view type is selected, do it
	//NOTE: that the scaleFactor here is not actually used, since it is figured instead within the setScaleFactor method
	if ([self isFitPage]) [self setScaleFactor:1.0];
	//[pageDownButton setNeedsDisplay:YES];
	//draw rect by calling super's method
	[super drawRect:rect];
}

- (float)scaleFactor
{
    return scaleFactor;
}

#pragma mark -
#pragma mark ---- Scale Factor Method ----

//isFitWidth causes page WIDTH to fit to width of window; isFitPage causes WHOLE PAGE to fit to window
//otherwise, an arbitrary scale factor determined by the slider control is used to set view scale
- (void)setScaleFactor:(float)newScaleFactor
{
	if (scaleFactor != newScaleFactor)
	{
		NSSize curDocFrameSize, newDocBoundsSize;
		NSView *clipView = [[self documentView] superview];
		//save spot in document to restore after resizing bounds for zoom!
		NSRect saveScrollPoint;
		saveScrollPoint = NSZeroRect;
		saveScrollPoint = [self documentVisibleRect];
		
		if (isFitWidth)
		{
			//make page width fit clipView
			scaleFactor = [clipView frame].size.width / [[self documentView] frame].size.width;
		} 
		else if (isFitPage)
		{
			thePrintInfo = [NSPrintInfo sharedPrintInfo];
			NSSize thePaperSize = [thePrintInfo paperSize]; 
			float  ratioPaperSize;
			ratioPaperSize = 0.0;
			ratioPaperSize = thePaperSize.width / thePaperSize.height;
			float  clipViewRatio;
			clipViewRatio = 0.0;
			clipViewRatio = [clipView frame].size.width / [clipView frame].size.height;
			if (ratioPaperSize > clipViewRatio)
			{
				//we fudge a little (1.05) for aesthetic reasons
				scaleFactor = [clipView frame].size.width / (thePaperSize.width * 1.05);
			}
			else
			{
				scaleFactor = [clipView frame].size.height / (thePaperSize.height * 1.05);
			}
		}
		else
		{
			scaleFactor = newScaleFactor;
		}
		//get the frame.  The frame must stay the same.
		curDocFrameSize = [clipView frame].size;
		//the new bounds will be frame divided by scale factor
		newDocBoundsSize.width = curDocFrameSize.width / scaleFactor;
		newDocBoundsSize.height = curDocFrameSize.height / scaleFactor;
		[clipView setBoundsSize:newDocBoundsSize];
		//clipView scrolls when bounds of documentView frame are resized; remember visible rect and make origin of clipView after scrollView frame resize!
		[[self documentView] scrollRectToVisible:saveScrollPoint];
	}
}

#pragma mark -
#pragma mark ---- Accessors ----

- (void)setHasHorizontalScroller:(BOOL)flag
{
    [super setHasHorizontalScroller:flag];
}

- (BOOL)isFitWidth
{
	return isFitWidth;
}

- (void)setIsFitWidth:(BOOL)flag
{
	isFitWidth = flag;
}

- (BOOL)isFitPage
{
	return isFitPage;
}

- (void)setIsFitPage:(BOOL)flag
{
	isFitPage = flag;
}

@end

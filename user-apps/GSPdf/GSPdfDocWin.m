/*  -*-objc-*-
 *  GSPdfDocWin.m: Implementation of the GSPdfDocWin Class 
 *  of the GNUstep GWorkspace application
 *
 *  Copyright (c) 2002-2010
 *  Riccardo Mottola
 *  Enrico Sersale <enrico@imago.ro>
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
#import "GSPdfDocWin.h"
#import "GSPdfDocument.h"

@implementation GSPdfDocWin

- (void)dealloc
{
  RELEASE (imageView);
  [super dealloc];
}

- (NSScrollView *)matrixScroll
{
  return matrixScroll;
}

- (GSPdfView *)imageView
{
  return imageView;
}

- (void)setBusy:(BOOL)value
{
  [leftButt setEnabled: !value];
  [rightButt setEnabled: !value];
}

- (BOOL)antiAlias
{
  return ([antiAliasSwitch state] == NSOnState);
}

- (void)windowDidLoad
/* some initialization stuff */
{
  [leftButt  setImage: [NSImage imageNamed: @"left.tiff"]];
  [rightButt setImage: [NSImage imageNamed: @"right.tiff"]];
		
  [matrixScroll setHasHorizontalScroller: YES];
  [matrixScroll setHasVerticalScroller: NO];
		
  [zoomButt setImage: [NSImage imageNamed: @"zoomin.tiff"]];
  [handButt setImage: [NSImage imageNamed: @"hand.tiff"]];
		
  [scroll setHasHorizontalScroller: YES];
  [scroll setHasVerticalScroller: YES]; 
  [scroll setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];

  imageView = [[GSPdfView alloc] init];
  [imageView setImageAlignment: NSImageAlignBottomLeft];
  [imageView setImageScaling: NSScaleNone];
  [imageView setEditable: NO];
  [imageView setDelegate: self];

  [scroll setDocumentView: imageView];

  [zoomField setStringValue: [NSString stringWithFormat: @"%i", [zoomStepper intValue]]];
}

- (void)scrollToOrigin
{
  
  NSLog(@"height: %f",  [[scroll contentView] bounds].size.height);
  //  [[scroll contentView] scrollToPoint: NSMakePoint(0, [[scroll contentView] bounds].origin.y + [[scroll contentView] bounds].size.height)];
  [scroll reflectScrolledClipView: [scroll contentView]];
  [scroll setNeedsDisplay: YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
  if ([zoomButt state] == NSOnState)
    {
      if([theEvent type] == NSLeftMouseDown)
        {
          if ([theEvent modifierFlags] & NSControlKeyMask)
            {
              [zoomStepper setIntValue: [zoomStepper intValue] - [zoomStepper increment]];
              [self setZoomValue: zoomStepper];
            }
          else
            {
              [zoomStepper setIntValue: [zoomStepper intValue] + [zoomStepper increment]];
              [self setZoomValue: zoomStepper];
            }
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  if([handButt state] == NSOnState)
    {
      if ([theEvent type] == NSLeftMouseDragged)
      {
        float deltaX, deltaY;
	NSPoint oldPoint;
	NSClipView *contentView;
        
        deltaX = [theEvent deltaX];
        deltaY = [theEvent deltaY];

	contentView = [scroll contentView];
	oldPoint = [contentView bounds].origin;
        [contentView scrollToPoint: NSMakePoint(oldPoint.x - deltaX, oldPoint.y - deltaY)];
      	[scroll setNeedsDisplay: YES];
      }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
  NSLog(@"up");
}

/* --- ACTIONS --- */

- (IBAction)selectZoomButt:(id)sender
{
  [handButt setState: NSOffState];
}

- (IBAction)selectHandButt:(id)sender
{
  [zoomButt setState: NSOffState];
}


- (IBAction)nextPage:(id)sender
{
  [[self document] nextPage];
}

- (IBAction)previousPage:(id)sender
{
  [[self document] previousPage];
}

- (IBAction)setAntiAlias:(id)sender
{
  [[self document] regeneratePage];
}

- (IBAction)setZoomValue:(id)sender
{
  int value = [sender intValue];
  [(GSPdfDocument*)[self document] setZoomValue: value];
  [zoomField setStringValue: [NSString stringWithFormat: @"%i", value]];		
}

@end




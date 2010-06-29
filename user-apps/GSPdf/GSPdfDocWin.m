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
  [super dealloc];
}

- (NSScrollView *)scroll
{
  return scroll;
}

- (NSScrollView *)matrixScroll
{
  return matrixScroll;
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
  
  [zoomField setStringValue: [NSString stringWithFormat: @"%i", [zoomStepper intValue]]];
}

- (BOOL)windowShouldClose:(id)sender
{
NSLog(@"should close!!");
  [[self document] clearTempFiles];
/*  if (isPdf)
    {
      [fm removeFileAtPath: myPath handler: nil];
    }	
  [window saveFrameUsingName: @"gspdfdoc"]; */
  return YES;
}

/* --- ACTIONS --- */
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




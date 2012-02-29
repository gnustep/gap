/*

  ZipperCell.m
  Zipper

  Copyright (C) 2012 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <AppKit/AppKit.h>
#import "ZipperCell.h"

@implementation ZipperCell : NSTextFieldCell

- (id) init
{
	self = [super initTextCell: @""];
	return self;
}

/*
 * drawInteriorWithFrame is copied from NSCell.m and NSTextFieldCell.m
 * and modified to to display an image _and_ text.
 */
- (void) drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView*)controlView
{
  NSAttributedString *attStrVal;

  if ([self drawsBackground])
    {
      [[self backgroundColor] set];
      NSRectFill ([self drawingRectForBounds: cellFrame]);
    }
  if (![controlView window])
    {
      return;
    }

  cellFrame = [self drawingRectForBounds: cellFrame];

  //FIXME: Check if this is also neccessary for images,
  // Add spacing between border and inside 
  if ([self isBordered] || [self isBezeled])
    {
      cellFrame.origin.x += 3;
      cellFrame.size.width -= 6;
      cellFrame.origin.y += 1;
      cellFrame.size.height -= 2;
    }

  if ([self image])
    {
      NSSize size;
      NSPoint position;

      size = [[self image] size];
      position.x = 0.;
      position.y = MAX(NSMidY(cellFrame) - (size.height/2.),0.);
      /*
       * Images are always drawn with their bottom-left corner
       * at the origin so we must adjust the position to take
       * account of a flipped view.
       */
      if ([controlView isFlipped])
	position.y += size.height;
      [[self image] compositeToPoint: position operation: NSCompositeSourceOver];

      cellFrame.origin.x += size.width+3;
      cellFrame.size.width -= (size.width+3);
    }

  attStrVal = [self attributedStringValue];

  if (attStrVal)
    {
      NSRect aRect;
      NSSize stringSize;

      stringSize = [attStrVal size];
      aRect = cellFrame;
      aRect.origin.y = NSMidY (aRect) - stringSize.height/2; 
      aRect.size.height = stringSize.height;

      [attStrVal drawInRect: cellFrame];
    }

  if ([self showsFirstResponder])
    {
      NSDottedFrameRect(cellFrame);
    }
}

@end

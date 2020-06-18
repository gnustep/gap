/*
    This file is part of HelpViewer (http://www.roard.com/helpviewer)
    Copyright (C) 2003 Nicolas Roard (nicolas@roard.com)

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
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include "ViewCell.h"

@implementation ViewCell

- (id) initWithSize: (NSSize) size 
{
    [super init];
    _size = size;
    _view = nil;
    return self;    
}

- (NSSize) cellSize 
{
    return _size;
}

- (void) resize: (id) sender
{
    NSTextView* textView = (NSTextView*) [sender object];
    _size = NSMakeSize ([textView bounds].size.width, _size.height);
}

- (void) setView : (NSView*) view
{
    _view = view;
}

- (void) removeView
{
    [_view removeFromSuperview];
}

- (void) drawInteriorWithFrame: (NSRect) cellFrame
    inView: (NSView*) controlView
{
      if (![controlView window])
	            return;

      [[NSColor lightGrayColor] set];
      NSRectFill (cellFrame);

      if (_view != nil) 
      {
	  [controlView addSubview: _view];
	  [_view setFrame: cellFrame];
	  [[(NSTextView*)_view textContainer] setContainerSize: cellFrame.size];
	  [_view setNeedsDisplay: YES];
      }
}

@end

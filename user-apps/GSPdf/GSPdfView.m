/*
   Project: GSPdf

   Copyright (C) 2010 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2010-07-03 23:16:10 +0200 by multix

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "GSPdfView.h"

@implementation GSPdfView

- (void)setDelegate: (id)aDelegate
{
  delegate = aDelegate;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  //  [super mouseDown: theEvent];
  [delegate mouseDown: theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  [super mouseDragged: theEvent];
  [delegate mouseDragged: theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  [super mouseUp: theEvent];
  [delegate mouseUp: theEvent];
}

@end

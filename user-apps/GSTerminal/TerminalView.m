/*
    TerminalView.m

    This program is part of the GNUstep Application Project

    Copyright (C) 2002 Gregory John Casamento

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

    Gregory John Casamento <greg_casamento@yahoo.com>
    14218 Oxford Drive, Laurel, MD 20707, USA
*/

#import "TerminalView.h"
#import <AppKit/NSEvent.h>

@implementation TerminalView
- (void) keyDown: (NSEvent *)theEvent
{
    [super keyDown: theEvent];
    puts("x");
}
@end
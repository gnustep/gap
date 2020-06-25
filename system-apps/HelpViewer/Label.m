/*
    This file is part of HelpViewer (http://www.roard.com/helpviewer)
    Copyright (C) 2003 Nicolas Roard (nicolas@roard.com)
                  2020 Riccardo Mottola <rm@gnu.org>

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

#include "Label.h"

@implementation Label

- (id) init
{
  if ((self = [super init]))
    {
      range.location = 0;
      range.length = 0;
      part = nil; 
      _ID = nil;
    }
  return self;
}

- (void) dealloc
{
  RELEASE (_ID);
  [super dealloc];
}

- (void) setBegin: (int) locationBegin {
    range.location = locationBegin;
}

- (void) setEnd: (int) locationEnd {
    range.length = locationEnd - range.location;
}

- (void) setPage: (Part*) _part {
    part = _part;
}

- (void) setID: (NSString*) __ID {
    ASSIGN (_ID, [__ID lowercaseString]);
}

- (NSRange) range {
    return range;
}

- (Part*) page {
    return part;
}

- (NSString*) ID {
    return _ID;
}

@end


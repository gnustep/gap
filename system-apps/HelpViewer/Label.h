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

#ifndef __LABEL_H__
#define __LABEL_H__

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "Page.h"
#include "GNUstep.h"

@interface Label : NSObject
{
    NSRange range;
    Part* part;
    NSString* _ID;
}
- (void) setPage: (Part*) part;
- (void) setID: (NSString*) _ID;
- (void) setRange: (NSRange)r;
- (NSRange) range;
- (Part*) page;
- (NSString*) ID;
@end

#endif

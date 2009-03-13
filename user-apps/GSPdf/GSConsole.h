 /*
 *  GSConsole.h: Interface and declarations for the GSConsole 
 *  Class of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
 *  
 *  Author: Enrico Sersale
 *  Date: July 2002
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

#ifndef GSCONSOLE_H
#define GSCONSOLE_H

#include <Foundation/Foundation.h>
#include <AppKit/NSView.h>

@class NSWindow;
@class NSTextView;

@interface GSConsole : NSObject
{
	id window;
	id textView;
}

- (NSWindow *)window;

- (NSTextView *)textView;

@end

#endif // GSCONSOLE_H


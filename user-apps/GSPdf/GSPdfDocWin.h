 /*
 *  GSPdfDocWin.h: Interface and declarations for the GSPdfDocWin 
 *  Class of the GNUstep GSPdf application
 *
 *  Copyright (c) 2002 Enrico Sersale <enrico@imago.ro>
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

#ifndef GSPDFDOCWIN_H
#define GSPDFDOCWIN_H

#include <Foundation/Foundation.h>
#include <AppKit/NSView.h>

@class NSWindow;
@class NSScrollView;
@class NSButton;
@class NSTextField;
@class NSStepper;

@interface GSPdfDocWin : NSObject
{
	id window;
	id scroll;
	id leftButt;
	id rightButt;
	id matrixScroll;
	id zoomField;
	id zoomStepper;
	id zoomButt;
	id handButt;
	
	NSNotificationCenter *nc;
}

- (NSWindow *)window;

- (NSScrollView *)scroll;

- (NSButton *)leftButt;

- (NSButton *)rightButt;

- (NSScrollView *)matrixScroll;

- (NSTextField *)zoomField;

- (NSStepper *)zoomStepper;

- (NSButton *)zoomButt;

- (NSButton *)handButt;

- (void)mainViewDidResize:(NSNotification *)notif;

@end

#endif // GSPDFDOCWIN_H


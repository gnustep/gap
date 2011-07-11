/*
	Controller.h

	window controller class

	Copyright (C) 2003 Marko Riedel

	Author: Marko Riedel <mriedel@bogus.example.com>
	Date:	5 July 2003

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA
*/


#ifndef _MasterMinds_Controller_H
#define _MasterMinds_Controller_H

#include "Views.h"
#include <Foundation/Foundation.h>
#include <AppKit/NSBox.h>
#include <AppKit/NSFont.h>
#include <AppKit/NSWindow.h>
#include <AppKit/NSMenu.h>

typedef enum {
    MENU_NEW_WITH_REP = 500,
    MENU_NEW_NO_REP,
    MENU_COMMIT,
    MENU_MOVE
} MENU_TAG;

@interface Controller : NSObject
{
    NSWindow *window;
    NSWindow *palette;

    int currentRow;

    DestinationPeg *pegs[8][4];
    Result *res[8];
    Peg *sol[4];
    BOOL done;

    BOOL unique;
    int combo[4];
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- makeGameWindow;
- makeColorPalette;

- evalCombos:(int *)combo1 and:(int *)combo2
       white:(int *)wptr black:(int *)bptr;

- newGameUnique:(BOOL)uniq;

- newGameWithRep:(id)sender;
- newGameNoRep:(id)sender;

- commit:(id)sender;
- move:(id)sender;

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;
@end

#endif

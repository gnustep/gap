/*
 *  main.m: main function of Fractal.app
 *
 *  Copyright (c) 2002 Free Software Foundation, Inc.
 *  
 *  Author: Marko Riedel
 *  Date: May 2002
 *
 *  With code fragments from MemoryPanel, ImageViewer, Finger, GDraw 
 *  and GShisen.
 *
 *  This sample program is part of GNUstep.
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
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include "Controller.h"

int main(int argc, const char **argv, char** env)
{
   NSAutoreleasePool *pool;
   NSApplication *app;
   NSMenu *mainMenu, *menu, *newGameMenu;
   NSMenuItem *menuItem, *gameMenuItem,
		*commitMenuItem, *moveMenuItem;
   Controller *controller;

   pool = [NSAutoreleasePool new];
   app = [NSApplication sharedApplication];

   //
   // Create the Menu 
   //

   // Main Menu
   mainMenu = AUTORELEASE ([NSMenu new]);

   // Info SubMenu
   menuItem = (NSMenuItem *)
       [mainMenu addItemWithTitle:_(@"Info")
		 action:NULL
		 keyEquivalent: @""];
   menu = AUTORELEASE ([NSMenu new]);
   [mainMenu setSubmenu:menu forItem:menuItem];
   [menu addItemWithTitle: _(@"Info Panel...")
	 action: @selector (orderFrontStandardInfoPanel:) 
	 keyEquivalent: @""];
   [menu addItemWithTitle: _(@"Preferences...")
	 action: @selector (runPreferencesPanel:) 
	 keyEquivalent: @""];
   [menu addItemWithTitle: _(@"Help...")
	 action: @selector (orderFrontHelpPanel:)
	 keyEquivalent: @"?"];

   // Game SubMenu
   menuItem = (NSMenuItem *)
       [mainMenu addItemWithTitle: _(@"Game")
		 action:NULL
		 keyEquivalent: @""];
   menu = AUTORELEASE ([NSMenu new]);
   [mainMenu setSubmenu: menu forItem: menuItem];

   gameMenuItem = (NSMenuItem *)
       [menu addItemWithTitle: _(@"New game")
	     action:NULL
	     keyEquivalent: @""];

   newGameMenu = AUTORELEASE ([NSMenu new]);
   [menu setSubmenu:newGameMenu forItem: gameMenuItem];

   [[newGameMenu addItemWithTitle: _(@"With replacement")
		 action: @selector(newGameWithRep:) 
		 keyEquivalent: @"n"] setTag:MENU_NEW_WITH_REP];
   [[newGameMenu addItemWithTitle: _(@"Without replacement")
		 action: @selector(newGameNoRep:) 
		 keyEquivalent: @"N"] setTag:MENU_NEW_NO_REP];

   commitMenuItem = [[NSMenuItem alloc] init];
   [commitMenuItem setTag:MENU_COMMIT];
   [commitMenuItem setTitle: _(@"Commit")];
   [commitMenuItem setKeyEquivalent: @"c"];
   [commitMenuItem setAction: @selector(commit:)];
   [menu addItem: commitMenuItem];

   moveMenuItem = [[NSMenuItem alloc] init];
   [moveMenuItem setTag:MENU_MOVE];
   [moveMenuItem setTitle: _(@"Move")];
   [moveMenuItem setKeyEquivalent: @""];
   [moveMenuItem setAction: @selector(move:)];
   [menu addItem: moveMenuItem];

   
   // Hide MenuItem
   [mainMenu addItemWithTitle: _(@"Hide")
	     action: @selector (hide:)
	     keyEquivalent: @"h"];	

   // Quit MenuItem
   [mainMenu addItemWithTitle: _(@"Quit") 
	     action: @selector (terminate:)
	     keyEquivalent: @"q"];	

   [app setMainMenu: mainMenu];

   controller = [Controller new];
   [app setDelegate: controller];

   NSApplicationMain(argc, argv);

   [[NSUserDefaults standardUserDefaults] synchronize];

   // RELEASE (controller);
   // RELEASE (pool);
   return 0;
}


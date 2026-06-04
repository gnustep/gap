/*
 *  main.m: main function of Gomoku.app
 *
 *  Copyright (c) 2000 Nicola Pero <n.pero@mi.flashnet.it>
 *  
 *  Author: Nicola Pero
 *  Date: April 2000
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

#include "Controller.h"

/* Hack needed to create the menu from code on Apple.  */
#ifndef GNUSTEP
@interface NSApplication (AppleMenu)
- (void) setAppleMenu: (NSMenu *)menu;
@end
#endif


int main (int argc, char **argv)
{
   NSAutoreleasePool *pool;
   NSApplication *app;
   NSMenu *mainMenu;
   NSMenu *menu;
   NSMenuItem *menuItem;
   Controller *controller;
   int cnt;

   pool = [NSAutoreleasePool new];
   app = [NSApplication sharedApplication];
   [app setApplicationIconImage: [NSImage imageNamed: @"Gomoku"]];

   //
   // Create the Menu 
   //

#ifdef GNUSTEP
   // Main Menu
   mainMenu = AUTORELEASE ([[NSMenu alloc] initWithTitle: @"Gomoku"]);

   // Info SubMenu
   menuItem = [mainMenu addItemWithTitle: _(@"Info") 
			action: NULL 
			keyEquivalent: @""];
   menu = AUTORELEASE ([[NSMenu alloc] initWithTitle: _(@"Info")]);
   [mainMenu setSubmenu: menu  forItem: menuItem];
   [menu addItemWithTitle: _(@"Info Panel...") 
	 action: @selector (orderFrontStandardInfoPanel:) 
	 keyEquivalent: @""];
   [menu addItemWithTitle: _(@"Set Difficulty Level...")
	 action: @selector (runDifficultyLevelPanel:) 
	 keyEquivalent: @""];
	 [menu addItemWithTitle: _(@"Help...") 
	 action: @selector (orderFrontHelpPanel:)
	 keyEquivalent: @"?"];

   // Game Submenu
   menuItem = [mainMenu addItemWithTitle: _(@"Game")
			action: NULL 
			keyEquivalent: @""];
   menu = AUTORELEASE ([[NSMenu alloc] initWithTitle: _(@"Game")]);
   [mainMenu setSubmenu: menu  forItem: menuItem];
   [menu addItemWithTitle: _(@"New Game") 
	 action: @selector (newGame:)
	 keyEquivalent: @"n"];
   [menu addItemWithTitle: _(@"Miniaturize")
	 action: @selector(performMiniaturize:)
	 keyEquivalent: @"m"];
   [menu addItemWithTitle: _(@"Close")
	 action: @selector(performClose:)
	 keyEquivalent: @"w"];

   // Windows SubMenu
   menuItem = [mainMenu addItemWithTitle: _(@"Windows") 
			action: NULL 
			keyEquivalent:@""];
   menu = AUTORELEASE ([[NSMenu alloc] initWithTitle: _(@"Windows")]);
   [mainMenu setSubmenu: menu  forItem: menuItem];
   [menu addItemWithTitle: _(@"Arrange")
	 action: @selector(arrangeInFront:)
	 keyEquivalent: @""];
   [menu addItemWithTitle: _(@"Miniaturize")
	 action: @selector(performMiniaturize:)
	 keyEquivalent: @"m"];
   [menu addItemWithTitle: _(@"Close")
	 action: @selector(performClose:)
	 keyEquivalent: @"w"];
   // FIXME: Shouldn't we be setting this as the 'Windows' submenu ?

   // Hide MenuItem
   [mainMenu addItemWithTitle: _(@"Hide") 
	     action: @selector (hide:)
	     keyEquivalent: @"h"];	

   // Quit MenuItem
   [mainMenu addItemWithTitle: _(@"Quit") 
	     action: @selector (terminate:)
	     keyEquivalent: @"q"];	

   [app setMainMenu: mainMenu];
#else
   {
   // Main Menu
   mainMenu = AUTORELEASE ([[NSMenu alloc] initWithTitle: @"Gomoku"]);


   // Apple Menu
   menu = AUTORELEASE ([[NSMenu alloc] initWithTitle: _(@"Gomoku")]);

   [menu addItemWithTitle: _(@"About Gomoku...") 
	 action: @selector (orderFrontStandardAboutPanel:) 
	 keyEquivalent: @""];

   [menu addItem: [NSMenuItem separatorItem]];

   [menu addItemWithTitle: _(@"Preferences...")
	 action: @selector (runDifficultyLevelPanel:) 
	 keyEquivalent: @""];

   [menu addItem: [NSMenuItem separatorItem]];

   // Hide MenuItem
   [menu addItemWithTitle: _(@"Hide") 
	 action: @selector (hide:)
	 keyEquivalent: @"h"];	

   [menu addItem: [NSMenuItem separatorItem]];

   // Quit MenuItem
   [menu addItemWithTitle: _(@"Quit") 
	 action: @selector (terminate:)
	 keyEquivalent: @"q"];	
   
   [app setAppleMenu: menu];

   menuItem = [mainMenu addItemWithTitle: _(@"Gomoku")
			action: NULL 
			keyEquivalent: @""];
   [mainMenu setSubmenu: menu  forItem: menuItem];

   // Game Submenu
   menu = AUTORELEASE ([[NSMenu alloc] initWithTitle: _(@"Game")]);
   [menu addItemWithTitle: _(@"New Game") 
	 action: @selector (newGame:)
	 keyEquivalent: @"n"];
   [menu addItemWithTitle: _(@"Close")
	 action: @selector(performClose:)
	 keyEquivalent: @"w"];

   menuItem = [mainMenu addItemWithTitle: _(@"Game")
			action: NULL 
			keyEquivalent: @""];
   [mainMenu setSubmenu: menu  forItem: menuItem];

   // Windows SubMenu
   menu = AUTORELEASE ([[NSMenu alloc] initWithTitle: _(@"Windows")]);
   [menu addItemWithTitle: _(@"Miniaturize")
	 action: @selector(performMiniaturize:)
	 keyEquivalent: @"m"];
   [menu addItemWithTitle: _(@"Arrange")
	 action: @selector(arrangeInFront:)
	 keyEquivalent: @""];
   [menu addItemWithTitle: _(@"Close")
	 action: @selector(performClose:)
	 keyEquivalent: @"w"];

   [app setWindowsMenu: menu];

   menuItem = [mainMenu addItemWithTitle: _(@"Windows") 
			action: NULL 
			keyEquivalent:@""];
   [mainMenu setSubmenu: menu  forItem: menuItem];

   [app setMainMenu: mainMenu];
   }
#endif

   if (argc <= 1 || (cnt = atoi(argv[1])) < 8)
     {
       cnt = 8;
     }
   controller = [Controller new: cnt];
   [app setDelegate: controller];
   [app run];
   RELEASE (controller);
   RELEASE (pool);
   return 0;
}

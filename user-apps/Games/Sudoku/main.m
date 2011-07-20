/* 
   Project: Sudoku
   main.m

   Copyright (C) 2007-2011 The Free Software Foundation, Inc

   Author: Marko Riedel

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Controller.h"

#ifdef __MINGW__
#define srand48 srand
#endif

time_t time(time_t *t);

int main(int argc, const char **argv, char** env)
{
  NSAutoreleasePool *pool;
  NSApplication *app;
  NSMenu *mainMenu, *menu;
  NSMenuItem *menuItem;
  NSMenu *file;
  Controller *controller;

   pool = [NSAutoreleasePool new];
   app = [NSApplication sharedApplication];

   //
   // Create the Menu 
   //



   // Main Menu
   mainMenu = [[NSMenu new] autorelease];

   // Info SubMenu
   menuItem = (NSMenuItem *)[mainMenu addItemWithTitle: @"Info" 
			action: NULL 
			keyEquivalent: @""];
   menu = [[NSMenu new] autorelease];
   [mainMenu setSubmenu: menu forItem: menuItem];
   [menu addItemWithTitle: @"Info Panel..." 
	 action: @selector (orderFrontStandardInfoPanel:) 
	 keyEquivalent: @""];
   [menu addItemWithTitle: @"Preferences..." 
	 action: @selector (runPreferencesPanel:) 
	 keyEquivalent: @""];
   [menu addItemWithTitle: @"Help..." 
	 action: @selector (orderFrontHelpPanel:)
	 keyEquivalent: @"?"];

  // Create the file submenu
  file = [NSMenu new];

  menuItem = (NSMenuItem *)[mainMenu addItemWithTitle: @"File" 
				     action: NULL 
				     keyEquivalent: @""];
  [mainMenu setSubmenu:file forItem: menuItem];

  [file addItemWithTitle: @"Open Document"
		  action: @selector(openDocument:)
	   keyEquivalent: @"o"];

  [file addItemWithTitle: @"Save"
	          action: @selector(saveDocument:)
	   keyEquivalent: @"s"];

  [file addItemWithTitle: @"Save To..."
	          action: @selector(saveDocumentTo:)
	   keyEquivalent: @"t"];

  [file addItemWithTitle: @"Save All"
	action: @selector(saveDocumentAll:)
	   keyEquivalent: @""];

  [file addItemWithTitle: @"Revert to Saved"
		  action: @selector(revertDocumentToSaved:)
	   keyEquivalent: @"u"];

  [file addItemWithTitle: @"Close"
		  action: @selector(close)
	   keyEquivalent: @""];

  [file release];

   // create new game menu
   menuItem = (NSMenuItem *)[mainMenu addItemWithTitle: @"New game" 
			action: NULL 
			keyEquivalent: @""];
   menu = [[NSMenu new] autorelease];
   [mainMenu setSubmenu:menu forItem: menuItem];

   [[menu addItemWithTitle: _(@"20 clues")
	  action: @selector(newPuzzle:)
	      keyEquivalent: @""] setTag:MENU_NEW_20CLUES];

   [[menu addItemWithTitle: _(@"25 clues")
	  action: @selector(newPuzzle:)
	      keyEquivalent: @"n"] setTag:MENU_NEW_25CLUES];

   [[menu addItemWithTitle: _(@"30 clues")
	  action: @selector(newPuzzle:)
	      keyEquivalent: @""] setTag:MENU_NEW_30CLUES];

   [[menu addItemWithTitle: _(@"35 clues")
	  action: @selector(newPuzzle:)
	      keyEquivalent: @""] setTag:MENU_NEW_35CLUES];

   [[menu addItemWithTitle: _(@"48 clues")
	  action: @selector(newPuzzle:)
	      keyEquivalent: @""] setTag:MENU_NEW_48CLUES];

   [[menu addItemWithTitle: _(@"60 clues")
	  action: @selector(newPuzzle:)
	      keyEquivalent: @""] setTag:MENU_NEW_60CLUES];

   [[menu addItemWithTitle: _(@"70 clues")
	  action: @selector(newPuzzle:)
	      keyEquivalent: @""] setTag:MENU_NEW_70CLUES];

   // Reset puzzle
   [mainMenu addItemWithTitle: @"Reset Puzzle" 
	     action: @selector (resetPuzzle:)
	     keyEquivalent: @""];	

   // Load solution
   [mainMenu addItemWithTitle: @"Load solution"
	     action: @selector (solvePuzzle:)
	     keyEquivalent: @""];	

   // Enter puzzle
   [mainMenu addItemWithTitle: @"Enter Puzzle" 
	     action: @selector (enterPuzzle:)
	     keyEquivalent: @""];	

   // Hide MenuItem
   [mainMenu addItemWithTitle: @"Hide" 
	     action: @selector (hide:)
	     keyEquivalent: @"h"];	

   // Quit MenuItem
   [mainMenu addItemWithTitle: @"Quit" 
	     action: @selector (terminate:)
	     keyEquivalent: @"q"];	

   [app setMainMenu: mainMenu];

   srand48(time(NULL));

   controller = [Controller new];
   [app setDelegate: controller];

   NSApplicationMain(argc, argv);

   [[NSUserDefaults standardUserDefaults] synchronize];

   [controller release];
   [pool release];
   return 0;
}


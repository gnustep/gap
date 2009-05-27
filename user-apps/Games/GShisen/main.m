#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "gshisen.h"

void createMenu();

int main(int argc, char** argv) 
{
	id pool;
	NSApplication *theApp;

	pool = [NSAutoreleasePool new];

#if LIB_FOUNDATION_LIBRARY
  	[NSProcessInfo initializeWithArguments:argv count:argc environment:env];
#endif

	theApp = [NSApplication sharedApplication];
	[theApp setDelegate: [GShisen sharedshisen]]; 
#ifdef __APPLE__
	[NSBundle loadNibNamed:@"gshisen" owner:theApp];
#endif // __APPLE__
	createMenu();
	[theApp run];
	[pool release];
	return 0;
}

void createMenu()
{
#ifdef __APPLE__
	NSMenu *mainMenu;
#endif // __APPLE__
	NSMenu *menu;
	NSMenu *infoMenu;
	NSMenu *game;

#ifndef __APPLE__
	menu = [[NSMenu alloc] initWithTitle:@"GShisen"];
	[[NSApplication sharedApplication] setMainMenu: menu];		
#else
	mainMenu = [[NSApplication sharedApplication] mainMenu];
	menu = [[NSMenu new] initWithTitle:@"Game"];
#endif // __APPLE__				
				
#ifndef __APPLE__
	[menu addItemWithTitle: @"Info" action: NULL keyEquivalent: @""];
#endif // __APPLE__
	[menu addItemWithTitle:@"Game" action: NULL keyEquivalent:@""];
#ifndef __APPLE__
	[menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
#endif // __APPLE__

#ifndef __APPLE__
	infoMenu = [NSMenu new];
	[infoMenu addItemWithTitle:@"Info Panel..." action:@selector(runInfoPanel:) keyEquivalent:@"i"];
	[menu setSubmenu:infoMenu forItem:[menu itemWithTitle:@"Info"]];
#endif // __APPLE__

	game = [NSMenu new];
	[game addItemWithTitle:@"New Game" action:@selector(newGame:) keyEquivalent:@"n"];
	[game addItemWithTitle:@"Pause" action:@selector(pause:) keyEquivalent:@"p"];
	[game addItemWithTitle:@"Get hint" action:@selector(getHint:) keyEquivalent:@"g"];
	[game addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
        
	[game addItemWithTitle:@"Hall of Fame" 
	action:@selector(showHallOfFame:) keyEquivalent:@""];
	[menu setSubmenu:game forItem:[menu itemWithTitle:@"Game"]];

#ifdef __APPLE__
	[mainMenu addItemWithTitle:@"Game" action: NULL keyEquivalent: @""];
	[mainMenu update];
	[mainMenu setSubmenu:menu forItem:[mainMenu itemWithTitle:@"Game"]];
	[[mainMenu itemWithTitle:@"Game"] setEnabled:YES];
#endif // __APPLE__				

#ifndef __APPLE__
	[[NSApplication sharedApplication] setMainMenu: menu];		
#endif

	[menu update];
}

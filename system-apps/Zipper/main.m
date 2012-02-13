#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include "AppDelegate.h"

int main(int argc, const char *argv[]) 
{
	CREATE_AUTORELEASE_POOL (pool);
	  
	[NSApplication sharedApplication];
 	[NSApp setDelegate: [AppDelegate new]];
  
	[NSBundle loadGSMarkupNamed: @"MainMenu-GNUstep"  owner: [NSApp delegate]];

	RELEASE (pool);
	return NSApplicationMain(argc, argv);
}

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GSPdf.h"
#import "Functions.h"
#import "GNUstep.h"

void createMenu();

int main(int argc, char **argv, char** env)
{
  CREATE_AUTORELEASE_POOL (pool);
  NSApplication *theApp = [NSApplication sharedApplication];
  [theApp setDelegate: [GSPdf gspdf]];  
  createMenu();
  [theApp run];	
  DESTROY (pool);
  return 0;
}

void createMenu()
{
  NSMenu *mainmenu;
  NSMenu *info, *file, *edit, *document, *tools;
  NSMenu *pagesize;
  NSMenu *windows, *services;  
  NSMenuItem *menuItem;
	
  // Main
  mainmenu = AUTORELEASE ([[NSMenu alloc] initWithTitle: @"GSPdf"]);
	
  // Info 	
  menuItem = addItemToMenu(mainmenu, @"Info", @"", nil, @"");
  info = AUTORELEASE ([NSMenu new]);
  [mainmenu setSubmenu: info forItem: menuItem];	
  addItemToMenu(info, @"Info Panel...", @"", @"runInfoPanel:", @"");
  addItemToMenu(info, @"Preferences...", @"", @"showPreferences:", @"");
  addItemToMenu(info, @"Help...", @"", nil, @"");
	 
  // File
  menuItem = addItemToMenu(mainmenu, @"File", @"", nil, @"");
  file = AUTORELEASE ([NSMenu new]);
  [mainmenu setSubmenu: file forItem: menuItem];		
  addItemToMenu(file, @"Open...", @"", @"openFile:", @"o");

  // Edit
  menuItem = addItemToMenu(mainmenu, @"Edit", @"", nil, @"");
  edit = AUTORELEASE ([NSMenu new]);
  [mainmenu setSubmenu: edit forItem: menuItem];	
  addItemToMenu(edit, @"Cut", @"", nil, @"x");
  addItemToMenu(edit, @"Copy", @"", nil, @"c");
  addItemToMenu(edit, @"Paste", @"", nil, @"v");
  addItemToMenu(edit, @"Select All", @"", nil, @"a");
				
  // Document
  menuItem = addItemToMenu(mainmenu, @"Document", @"", nil, @"");
  document = AUTORELEASE ([NSMenu new]);
  [mainmenu setSubmenu: document forItem: menuItem];	
  addItemToMenu(document, @"Next Page", @"", @"nextPage:", @"");	
  addItemToMenu(document, @"Previous Page", @"", @"previousPage:", @"");	
  menuItem = addItemToMenu(document, @"Page Size", @"", nil, @"");
  pagesize = AUTORELEASE ([NSMenu new]);
  [document setSubmenu: pagesize forItem: menuItem];

  // Tools
  menuItem = addItemToMenu(mainmenu, @"Tools", @"", nil, @"");
  tools = AUTORELEASE ([NSMenu new]);
  [mainmenu setSubmenu: tools forItem: menuItem];	
  addItemToMenu(tools, @"Console", @"", @"showConsole:", @"C");	

  // Windows
  menuItem = addItemToMenu(mainmenu, @"Windows", @"", nil, @"");
  windows = AUTORELEASE ([NSMenu new]);
  [mainmenu setSubmenu: windows forItem: menuItem];		
  addItemToMenu(windows, @"Arrange in Front", @"", nil, @"");
  addItemToMenu(windows, @"Miniaturize Window", @"", nil, @"");
  addItemToMenu(windows, @"Close Window", @"", @"closeMainWin:", @"w");

  // Services 
  menuItem = addItemToMenu(mainmenu, @"Services", @"", nil, @"");
  services = AUTORELEASE ([NSMenu new]);
  [mainmenu setSubmenu: services forItem: menuItem];		

  // Hide
  addItemToMenu(mainmenu, @"Hide", @"", @"hide:", @"h");
	
  // Quit
  addItemToMenu(mainmenu, @"Quit", @"", @"terminate:", @"q");

  [mainmenu update];

  [[NSApplication sharedApplication] setServicesMenu: services];
  [[NSApplication sharedApplication] setWindowsMenu: windows];
  [[NSApplication sharedApplication] setMainMenu: mainmenu];		
}

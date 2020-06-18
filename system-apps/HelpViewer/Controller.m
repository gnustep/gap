/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "Controller.h"

@implementation Controller

- (void) initButtons 
{
    [search setTitle: _(@"Search")];
    [search setFont: [NSFont systemFontOfSize: 0]];
    [search setImagePosition: NSImageAbove];
    [search setImage: [NSImage imageNamed: @"Search.tiff"]];

    [index setTitle: _(@"Index")];
    [index setFont: [NSFont systemFontOfSize: 0]];
    [index setImagePosition: NSImageAbove];
    [index setImage: [NSImage imageNamed: @"Index.tiff"]];

    [back setTitle: _(@"Back")];
    [back setFont: [NSFont systemFontOfSize: 0]];
    [back setImagePosition: NSImageAbove];
    [back setImage: [NSImage imageNamed: @"Back.tiff"]];

    [bookshelf setTitle: _(@"Bookshelf")];
    [bookshelf setFont: [NSFont systemFontOfSize: 0]];
    [bookshelf setImagePosition: NSImageAbove];
    [bookshelf setImage: [NSImage imageNamed: @"Bookshelf.tiff"]];
}

- (void) awakeFromNib
{
    NSLog (@"Controller réveillé !");
    windowController = [[MainWindowController alloc] initWithTextView: textview
			    andBrowserView: tocview];
   
    [infoMenu setAction: @selector (orderFrontStandardInfoPanel:)];
    [helpMenu setAction: @selector (orderFrontHelpPanel:)];

    [self initButtons];

    [window setTitle: @"HelpViewer"];
    [windowController setWindow: window];

    [NSApp setDelegate: self];
}

- (void) applicationDidFinishLaunching: (NSNotification *) not {
    NSLog (@"Controller : applicationDidFinishLaunching !");
    NSArray *args = [[NSProcessInfo processInfo] arguments];

    if ([args count] > 1)
    {
	if ([[NSFileManager defaultManager] fileExistsAtPath: [args objectAtIndex: 1]])
	{
	    [windowController loadFile: [args objectAtIndex: 1]];
	}
    }
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    NSLog (@"Controller : application:openFile: !");
    return [windowController loadFile: filename];
}

- (void) dealloc 
{
    RELEASE (windowController);
}

- (void) openFile: (id) sender
{
    int ret;
    NSLog (@"openFile ...");
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection: NO];
    ret = [panel runModalForTypes: [NSArray arrayWithObject: @"help"]];
    if (ret == NSOKButton)
    {
	[windowController loadFile: [[panel filenames] objectAtIndex: 0]];
    }
}

- (void) search: (id) sender
{
    NSLog (@"Search ...");
}

- (void) index: (id) sender 
{
    NSLog (@"Index ...");
}

- (void) back: (id) sender
{
    NSLog (@"Back ...");
}

- (void) bookshelf: (id) sender
{
    NSLog (@"Bookshelf ...");
}

- (void) print: (id) sender
{
	[windowController print: sender];
}

@end

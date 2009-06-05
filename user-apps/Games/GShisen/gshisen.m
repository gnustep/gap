#include "gshisen.h"

static GShisen *sharedshisen = nil;

@implementation GShisen

+ (GShisen *)sharedshisen
{
    if(!sharedshisen) {
        NS_DURING
            {
                sharedshisen = [[self alloc] init];
            }
        NS_HANDLER
            {
                [localException raise];
            }
        NS_ENDHANDLER
            }
    return sharedshisen;
}

- (void)dealloc
{
    [board release];
    [win release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [win center];
    [win display];
    [win orderFront:nil];
}

- (BOOL)applicationShouldTerminate:(NSApplication *)app 
{
    return YES;
}

- (void)newGame:(id)sender
{
    [board newGame];
}

- (void)pause:(id)sender
{
    [board pause];
}

- (void)undo:(id)sender
{
    [board undo];
}

- (void)getHint:(id)sender
{
    [board getHint];
}

- (void)showHallOfFame:(id)sender
{
  [board showHallOfFame]; 
}

- (void)runInfoPanel:(id)sender
{
  NSMutableDictionary *d;

  d = [NSMutableDictionary new];
  [d setObject: @"GShisen" forKey: @"ApplicationName"];
  [d setObject: @"The first GNUstep Game!" 
     forKey: @"ApplicationDescription"];
  [d setObject: @"GShisen 1.2.1" forKey: @"ApplicationRelease"];
  [d setObject: @"June 2006" forKey: @"FullVersionID"];
  [d setObject: [NSArray arrayWithObjects: 
			   @"James Dessart <james@skwirl.ca>",
				@" Enrico Sersale <enrico@imago.ro>", 
				@"Larry Coleman <larryliberty@yahoo.com>",
				nil]
     forKey: @"Authors"];
  [d setObject: @"See http://www.imago.ro/gshisen" forKey: @"URL"];
  [d setObject: @"Copyright (C) 2003, 2004, 2005, 2006 Free Software Foundation, Inc."
     forKey: @"Copyright"];
  [d setObject: @"Released under the GNU General Public License 2.0"
     forKey: @"CopyrightDescription"];
  
#ifdef GNUSTEP	
  [NSApp orderFrontStandardInfoPanelWithOptions: d];
#else
	[NSApp orderFrontStandardAboutPanel: d];
#endif
}

@end


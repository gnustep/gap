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
  NSMutableArray *scores;
  NSDictionary *scoresEntry;
  NSString *userName, *minutes, *seconds, *totTime;
  NSRect myRect = {{0, 0}, {150, 300}};
  NSRect matrixRect = {{0, 0}, {150, 300}};
  int i;
  NSButtonCell *buttonCell;
  NSScrollView *scoresScroll;
  
  scores = [board scores];
  if ([scores count] >= 20) {
    matrixRect.size.height = [scores count] * 15;
  }

  [hallOfFamePanel makeKeyAndOrderFront:self];
  myView = [[NSView alloc] initWithFrame: [hallOfFamePanel frame]];
  [hallOfFamePanel setContentView: myView];


  buttonCell = [[NSButtonCell new] autorelease];
  [buttonCell setButtonType: NSPushOnPushOffButton];
  [buttonCell setBordered:NO];
  [buttonCell setAlignment:NSLeftTextAlignment];	
  //	NSLog(@"Height: %d", [buttonCell cellSize].height);

  scoresMatrix = [[NSMatrix alloc] initWithFrame:matrixRect mode:NSRadioModeMatrix
				   prototype:buttonCell 
				   numberOfRows:[scores count] 
				   numberOfColumns:2];

  [scoresMatrix setAutoresizingMask: NSViewWidthSizable];
											
  scoresScroll = [[NSScrollView alloc] initWithFrame: myRect];
  [scoresScroll setAutoresizingMask: NSViewHeightSizable | NSViewWidthSizable];
  [scoresScroll setHasVerticalScroller: YES];
  [scoresScroll setHasHorizontalScroller: NO];
		
  for(i = 0; i < [scores count]; i++) {
    scoresEntry = [scores objectAtIndex: i];
    userName = [scoresEntry objectForKey: @"username"];
    minutes = [scoresEntry objectForKey: @"minutes"];
    seconds = [scoresEntry objectForKey: @"seconds"];
    totTime = [NSString stringWithFormat:@"%@:%@", minutes, seconds];
    //		[scoresMatrix addRow];
    [[scoresMatrix cellAtRow:i column:0] setTitle: userName];
    [[scoresMatrix cellAtRow:i column:1] setTitle: totTime];
  }
		
  [scoresScroll setDocumentView: scoresMatrix];
  [myView addSubview: scoresScroll];
	
  [hallOfFamePanel makeKeyAndOrderFront:self];
}


@end


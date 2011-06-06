#import "Document.h"

@interface Document (Private)

- (NSWindow*)makeWindow;

@end

@implementation Document

- init
{
  [super init];

  sdkview = nil; lines = nil;
  return self;
}

- (NSData *)dataRepresentationOfType:(NSString *)aType 
{
    if([aType isEqualToString:DOCTYPE]){
        [[sdkview window] saveFrameUsingName:[self fileName]];

        NSString *all =
	    [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n",
		      [[sdkview sudoku] stateToString:FIELD_VALUE],
		      [[sdkview sudoku] stateToString:FIELD_PUZZLE],
		      [[sdkview sudoku] stateToString:FIELD_GUESS],
		      [[sdkview sudoku] stateToString:FIELD_SCORE]];

        return [all dataUsingEncoding:NSASCIIStringEncoding];
    }
    else{
        NSString *msg = [NSString stringWithFormat: @"Unknown type: %@", 
                        [aType uppercaseString]];
        NSRunAlertPanel(@"Alert", msg, @"Ok", nil, nil);
        return nil;
    }
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType 
{
    if([aType isEqualToString:DOCTYPE]){
        lines = 
            [[NSString stringWithCString:[data bytes] 
                       length:[data length]] 
                componentsSeparatedByString:@"\n"];

	RETAIN(lines);
    }
    else{
        NSString *msg = [NSString stringWithFormat: @"Unknown type: %@", 
                        [aType uppercaseString]];
        NSRunAlertPanel(@"Alert", msg, @"Ok", nil, nil);
        return NO;
    }

    return YES;
}

- (void) makeWindowControllers
{
  NSWindowController *controller;
  NSWindow *win = [self makeWindow];
  
  controller = [[NSWindowController alloc] initWithWindow: win];
  RELEASE (win);
  [self addWindowController: controller];
  RELEASE(controller);

  // We have to do this ourself, as there is currently no nib file
  // [controller setShouldCascadeWindows:NO];
  [self windowControllerDidLoadNib: controller];

  [win setFrameAutosaveName:[self fileName]];
  if([win setFrameUsingName:[self fileName]]==NO){
      [win center];
  }

  [win orderFrontRegardless];
  [win makeKeyWindow];
  [win display];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController;
{
  [super windowControllerDidLoadNib:aController];

  NSEnumerator *en = [lines objectEnumerator];

  if(lines != nil){
    [[sdkview sudoku] stateFromLineEnumerator:en what:FIELD_VALUE];
    [[sdkview sudoku] stateFromLineEnumerator:en what:FIELD_PUZZLE];
    [[sdkview sudoku] stateFromLineEnumerator:en what:FIELD_GUESS];
    [[sdkview sudoku] stateFromLineEnumerator:en what:FIELD_SCORE];
    
    RELEASE(lines); lines = nil;
  }
}

- (Sudoku *)sudoku
{
  return [sdkview sudoku];
}

- (SudokuView *)sudokuView
{
  return sdkview;
}

- resetPuzzle:(id)sender
{
  [sdkview reset];
  [self updateChangeCount:NSChangeDone];

  return self;
}

- solvePuzzle:(id)sender
{
  [sdkview loadSolution];
  [self updateChangeCount:NSChangeDone];

  return self;
}


@end

@implementation Document (Private)

- (NSWindow*)makeWindow
{
  NSWindow *window;
  int m = (NSTitledWindowMask |  
	   NSClosableWindowMask | 
           NSMiniaturizableWindowMask);

  NSRect frame = {{ 0, 0}, {SDK_DIM, SDK_DIM} };
  sdkview  = [[SudokuView alloc] initWithFrame:frame];

  frame = [sdkview frame]; // just in case

  window = 
      [[NSWindow alloc] initWithContentRect:frame 
			styleMask:m                   
			backing: NSBackingStoreRetained 
                             defer:YES];
  [window setDelegate:self];

  [window setContentView:sdkview];
  [window setReleasedWhenClosed:YES];

  [self setFileType:DOCTYPE];
  
  return window;
}

@end

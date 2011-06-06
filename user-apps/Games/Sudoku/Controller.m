
#include <time.h>
time_t time(time_t *t);


#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Controller.h"
#import "Document.h"
#import "KnobView.h"
#import "DigitSource.h"

@implementation Controller

static NSPanel *_prog_ind_panel = nil;

#define PROG_IND_WIDTH 200
#define PROG_IND_HEIGHT 20

+ (NSPanel *)prog_ind
{
    if(_prog_ind_panel==nil){
	NSRect pi_frame =
	    NSMakeRect(0, 0, PROG_IND_WIDTH, PROG_IND_HEIGHT);

        _prog_ind_panel = 
            [[NSPanel alloc]
                initWithContentRect:pi_frame
                styleMask:NSTitledWindowMask
                backing:NSBackingStoreBuffered
                defer:NO];
        [_prog_ind_panel setReleasedWhenClosed:NO];
        
	KnobView *_prog_ind =
	    [[KnobView alloc] initWithFrame:pi_frame];
        [_prog_ind_panel setContentView:_prog_ind];

	[_prog_ind_panel setTitle:_(@"Computing Sudoku")];
    }

    [_prog_ind_panel center];
    return _prog_ind_panel;
}

#define TICK_ITER 20
#define TICK_STEP  5

typedef enum {
  STATE_FIND,
  STATE_CLUES,
  STATE_SELECT,
  STATE_DONE
} STATE;

#define MAXTRIES 25

- newPuzzle:(id)sender; // clues = [sender tag]
{
    NSApplication *app = [NSApplication sharedApplication];

    NSDocumentController *dc =
	[NSDocumentController sharedDocumentController];
    [dc newDocument:self];

    Document *doc = [dc currentDocument];
    Sudoku *sdk = [doc sudoku];

    NSPanel *pi_panel = [Controller prog_ind];
    KnobView *pi = [pi_panel contentView];
    
    [pi_panel makeKeyAndOrderFront:self];

    NSModalSession findSession;
    findSession = [app beginModalSessionForWindow:pi_panel];

    float percent = 0, dir = 1;
    STATE st = STATE_FIND;

    NSString *checkseq = nil; 
    Sudoku *other = [[Sudoku alloc] init], *pick = [[Sudoku alloc] init];
    int tries = 0;

    do {
	int tick;
	for(tick=0; tick<TICK_ITER; tick++){
	    [pi setPercent:percent];
	    [pi display];

	    [[pi_panel contentView] setNeedsDisplay:YES];
	    [pi_panel flushWindow];

	    percent += TICK_STEP*dir;
	}
	if(percent==100.0){
	    dir = -1;
	}
	else if(percent==0.0){
	    dir = +1;
	}

	if(st==STATE_FIND){
	  if([sdk find]==YES){
	    st = STATE_CLUES;
	    [other copyStateFromSource:sdk];
	    [other setClues:[sender tag]];
	  }
	}
	else if(st==STATE_CLUES){
	  if([other selectClues]==YES){
	    [other find]; // == YES
	    st = STATE_SELECT;
	  }
	}
	else if(st==STATE_SELECT){
	  NSString *othercseq = [other checkSequence];
	  // NSLog(@"%d %@", __LINE__, checkseq);
	  // NSLog(@"%d %@", __LINE__, othercseq);
	  
	  if(checkseq==nil || 
	     [checkseq compare:othercseq]==NSOrderedDescending){
	    NSLog(@"%d tries, picked %@ over %@", tries,  
		  othercseq, checkseq);
	    
	    checkseq = othercseq;
	    [pick copyStateFromSource:other];
	  }

	  tries++;
	  if(tries==MAXTRIES){
	    st = STATE_DONE;
	  }
	  else{
	    [other copyStateFromSource:sdk];
	    [other setClues:[sender tag]];
	    st = STATE_CLUES;
	  }
	}

	[app runModalSession:findSession];
    } while(st!=STATE_DONE);

    [sdk copyStateFromSource:pick];
    [sdk cluesToPuzzle];

    [other dealloc]; [pick dealloc];

    [pi_panel orderOut:self];
    [app endModalSession:findSession];

    [[doc sudokuView] setNeedsDisplay:YES];
    [[doc sudokuView] display];
    [[[doc sudokuView] window] flushWindow];

    [doc updateChangeCount:NSChangeDone];

    return self;
}

#define BUTTON_HEIGHT 30

- makeInputPanel
{
  int m = NSTitledWindowMask;

  NSRect frame = 
      {{ 0, BUTTON_HEIGHT + DIGIT_FIELD_DIM},  { SDK_DIM, SDK_DIM} };
  sdkview  = [[SudokuView alloc] initWithFrame:frame];

  NSRect allframe = frame;
  allframe.size.height += BUTTON_HEIGHT + DIGIT_FIELD_DIM;

  enterPanel = 
      [[NSPanel alloc] initWithContentRect:allframe 
			styleMask:m                   
			backing: NSBackingStoreRetained 
                             defer:YES];
  [enterPanel setTitle:_(@"Enter Sudoku")];
  [enterPanel setDelegate:self];

  [[enterPanel contentView] addSubview:sdkview];

  float margin = (SDK_DIM - DIGIT_FIELD_DIM*10)/2;
  assert(margin>0);

  int x;
  for(x=1; x<=10; x++){
      DigitSource *dgs =
	[[DigitSource alloc] 
	    initAtPoint:
		NSMakePoint(margin+(x-1)*DIGIT_FIELD_DIM, BUTTON_HEIGHT)
	    withDigit:x];
      [[enterPanel contentView] addSubview:dgs];
  }


  NSButton *button = [NSButton new];
  [button setTitle:_(@"Enter")];
  [button setTarget:self];
  [button setAction:@selector(actionEnter:)];

  [button 
      setFrame:NSMakeRect(0, 0, SDK_DIM/3, BUTTON_HEIGHT)];
  
  [[enterPanel contentView] addSubview:button];

  button = [NSButton new];
  [button setTitle:_(@"Reset")];
  [button setTarget:self];
  [button setAction:@selector(actionReset:)];

  [button 
      setFrame:NSMakeRect(SDK_DIM/3, 0, SDK_DIM/3, BUTTON_HEIGHT)];
  
  [[enterPanel contentView] addSubview:button];

  button = [NSButton new];
  [button setTitle:_(@"Cancel")];
  [button setTarget:self];
  [button setAction:@selector(actionCancel:)];

  [button 
      setFrame:NSMakeRect(2*SDK_DIM/3, 0, SDK_DIM/3, BUTTON_HEIGHT)];
  
  [[enterPanel contentView] addSubview:button];

  [enterPanel setReleasedWhenClosed:NO];

  return self;
}

#define MAX_SOLVE_SECS 40

- actionEnter:(id)sender
{
    [[NSApplication sharedApplication]
        stopModal];
    [enterPanel orderOut:self];

    [palette orderFront:self];

    NSApplication *app = [NSApplication sharedApplication];

    NSDocumentController *dc =
        [NSDocumentController sharedDocumentController];
    [dc newDocument:self];

    Document *doc = [dc currentDocument];
    Sudoku *sdk = [doc sudoku], *user = [sdkview sudoku];

    [sdk copyStateFromSource:user];
    [sdk guessToClues];
    // [sdk cluesToPuzzle];

    NSPanel *pi_panel = [Controller prog_ind];
    KnobView *pi = [pi_panel contentView];
    
    [pi_panel makeKeyAndOrderFront:self];

    NSModalSession solveSession;
    solveSession = [app beginModalSessionForWindow:pi_panel];

    float percent = 0, dir = 1;

    BOOL success;
    NSDate *end = [NSDate dateWithTimeIntervalSinceNow:MAX_SOLVE_SECS];

    do {
	int tick;
	for(tick=0; tick<TICK_ITER; tick++){
	    [pi setPercent:percent];
	    [pi display];

	    [[pi_panel contentView] setNeedsDisplay:YES];
	    [pi_panel flushWindow];

	    percent += TICK_STEP*dir;
	}
	if(percent==100.0){
	    dir = -1;
	}
	else if(percent==0.0){
	    dir = +1;
	}

	[app runModalSession:solveSession];

	NSDate *now = [NSDate date];
	if([now laterDate:end]==now){
	    break;
	}

	success = [sdk find];
    } while(success==NO);

    [pi_panel orderOut:self];
    [app endModalSession:solveSession];

    if(success==NO){
	NSRunAlertPanel(_(@"Solve failed"),
			_(@"Could not solve Sudoku after %d sec(s)."),
			_(@"Ok"), nil, nil, MAX_SOLVE_SECS);
	[doc close];
    }
    else{
	[[doc sudokuView] setNeedsDisplay:YES];
	[[doc sudokuView] display];

	[[[doc sudokuView] window] flushWindow];

	[doc updateChangeCount:NSChangeDone];
    }

    return self;
}

- actionReset:(id)sender
{
    [sdkview reset];
    return self;
}

- actionCancel:(id)sender
{
    [[NSApplication sharedApplication]
        stopModal];
    [enterPanel orderOut:self];

    [palette orderFront:self];
    return self;
}

- enterPuzzle:(id)sender
{
    [palette orderOut:self];

    [enterPanel center];
    [enterPanel makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication]
	runModalForWindow:enterPanel];
    
    return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
  NSDocumentController *dc = 
    [NSDocumentController sharedDocumentController];

  // Make the DocumentController the delegate of the application.
  // [NSApp setDelegate: dc];

  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *procArgs = [[NSProcessInfo processInfo] arguments];
  int arg;

  for(arg=1; arg<[procArgs count]; arg++){  // skip program name
    NSString *docFile = [procArgs objectAtIndex:arg];

    if([fm isReadableFileAtPath:docFile]==NO){
        NSLog(@"couldn't open %@ for reading", docFile);
    }
    else{
        NSArray *comps = [docFile pathComponents];
        if([[comps objectAtIndex:0] isEqualToString:@"/"]==NO){
            docFile = 
                [NSString stringWithFormat:@"%@/%@",
                          [fm currentDirectoryPath], docFile];
        }

        [dc openDocumentWithContentsOfFile:docFile display:YES];
    }
  }

  [self makeDigitPalette];
  [self makeInputPanel];
}

- makeDigitPalette
{
  NSRect pbounds = 
    NSMakeRect(0, 0, 2*DIGIT_FIELD_DIM, 5*DIGIT_FIELD_DIM);

  NSRect 
    pframe =
    [NSWindow frameRectForContentRect:pbounds
	      styleMask:NSTitledWindowMask];

  palette =
    [[NSPanel alloc] initWithContentRect:pframe 
		      styleMask:NSTitledWindowMask                   
		      backing: NSBackingStoreRetained 
		      defer:YES];

  [palette setMinSize:pframe.size];
  [palette setMaxSize:pframe.size];

  [palette setTitle:_(@"Digits")];
  [palette setDelegate:self];

  [palette setFrameUsingName: @"SudokuDigitPalette"];
  [palette setFrameAutosaveName: @"SudokuDigitPalette"];


  int x, y;
  for(x=0; x<2; x++){
    for(y=0; y<5; y++){
      DigitSource *dgs =
	[[DigitSource alloc] 
	  initAtPoint:
	    NSMakePoint(x*DIGIT_FIELD_DIM, (4-y)*DIGIT_FIELD_DIM)
	  withDigit:y*2+x+1];
      [[palette contentView] addSubview:dgs];
    }
  }

  [palette orderFrontRegardless];
  [palette makeKeyWindow];

  return self;
}

@end



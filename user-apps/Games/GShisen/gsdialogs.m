#include "gsdialogs.h"
#include "gshisen.h"

@implementation GSDlogView

- (void)drawRect:(NSRect)rect
{
  	[[NSColor darkGrayColor] set];
  	PSmoveto(0, 91);
 	PSlineto(240, 91);
	PSstroke();
  	[[NSColor whiteColor] set];
  	PSmoveto(0, 90);
 	PSlineto(240, 90);
	PSstroke();
	
  	[[NSColor darkGrayColor] set];
  	PSmoveto(0, 45);
 	PSlineto(240, 45);
	PSstroke();
  	[[NSColor whiteColor] set];
  	PSmoveto(0, 44);
 	PSlineto(240, 44);
	PSstroke();
}

@end

@implementation GSUserNameDialog

- (id)initWithTitle:(NSString *)title;
{
  	NSFont *font;

	self = [super initWithContentRect:NSMakeRect(0, 0, 240, 120) styleMask:NSTitledWindowMask
                                                                       backing:NSBackingStoreRetained 
                                                                         defer:NO];
  	if(self) {
  		dialogView = [[[GSDlogView alloc] initWithFrame: _frame] autorelease];
		font = [NSFont systemFontOfSize: 18];
		
		titlefield = [[NSTextField alloc] initWithFrame: NSMakeRect(10, 95, 200, 20)];
		//[titlefield setBackgroundColor:[NSColor lightGrayColor]];
		[titlefield setBezeled:NO];
		[titlefield setEditable:NO];
		[titlefield setSelectable:NO];
		[titlefield setFont: font];
		[titlefield setStringValue: title];
		[dialogView addSubview: titlefield]; 

		editfield = [[NSTextField alloc] initWithFrame: NSMakeRect(30, 56, 180, 22)];
		[dialogView addSubview: editfield];

	  	okbutt = [[NSButton alloc] initWithFrame: NSMakeRect(170, 10, 60, 25)];
	  	[okbutt setButtonType: NSMomentaryLight];
	  	[okbutt setTitle: @"Ok"];
	  	[okbutt setTarget:self];
	  	[okbutt setAction:@selector(buttonAction:)];		
		[dialogView addSubview: okbutt]; 
                [self makeFirstResponder: editfield];

		[self setContentView: dialogView];
		[self setTitle: @""];
	}

	return self;
}

- (void)dealloc
{
	[titlefield release];
	[editfield release];
	[okbutt release];	
  	[super dealloc];
}

- (int)runModal
{
  	NSApplication *app;

  	app = [NSApplication sharedApplication];
  	[app runModalForWindow: self];
  	return result;
}

- (NSString *)getEditFieldText
{
	return [editfield stringValue];
}

- (void)buttonAction:(id)sender
{
	result = NSAlertDefaultReturn;
		
  	[self orderOut: self];
  	[[NSApplication sharedApplication] stopModal];
}

@end

@implementation GSHallOfFameWin

- (id)initWithScoreArray:(NSArray *)scores
{
	NSDictionary *scoresEntry;
	NSString *userName, *minutes, *seconds, *totTime;
	NSRect myRect = {{0, 0}, {150, 300}};
	NSRect matrixRect = {{0, 0}, {150, 300}};
  unsigned int style;
  int i;
  
	if ([scores count] >= 20) {
	  matrixRect.size.height = [scores count] * 15;
	}
  style = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
	
	self = [super initWithContentRect:myRect
									styleMask:style
									  backing:NSBackingStoreRetained
										 defer:NO];
  	if(self) {
		[self setTitle:@"Hall Of Fame"];
		[self setFrameAutosaveName:@"Hall Of Fame"]; 
		
		myView = [[NSView alloc] initWithFrame: _frame];
		[self setContentView: myView];

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
	}
	return self;
}

- (void) dealloc
{
	[scoresMatrix release];
	[scoresScroll release];
	[myView release];
  	[super dealloc];
}

@end

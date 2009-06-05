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


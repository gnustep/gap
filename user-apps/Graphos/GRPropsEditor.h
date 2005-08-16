#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class GRDocView;

@interface GRPropsEditor : NSView
{
	GRDocView *docview;
	int result;
	
	NSButton *stkButt;
	NSTextField *stkLabel;
	NSTextField *stkCyanLabel, *stkMagentaLabel, *stkYellowLabel, *stkBlakLabel;
	NSTextField *stkCyanField, *stkMagentaField, *stkYellowField, *stkBlakField;
	NSButton *fllButt;
	NSTextField *fllLabel;
	NSTextField *fllCyanLabel, *fllMagentaLabel, *fllYellowLabel, *fllBlakLabel;	
	NSTextField *fllCyanField, *fllMagentaField, *fllYellowField, *fllBlakField;
	
	NSTextField *lineCapLabel;
	NSMatrix* lineCapMatrix;
	NSTextField *lineJoinLabel;
	NSMatrix* lineJoinMatrix;
	NSButtonCell* buttonCell;
	
	NSTextField *flatnessLabel;
	NSTextField *flatnessField;
	NSTextField *miterlimitLabel;
	NSTextField *miterlimitField;
	NSTextField *linewidthLabel;
	NSTextField *linewidthField;
	
	NSButton *cancelButt, *okButt;
	
	NSRect strokeColorRect, fillColorRect;
	
	BOOL ispath;
	float flatness, miterlimit, linewidth;
	int linejoin, linecap;
	BOOL stroked;
	float strokecyan, strokemagenta, strokeyellow, strokeblack, strokealpha;
	BOOL filled;
	float fillcyan, fillmagenta, fillyellow, fillblack, fillalpha;
}

- (id)initWithFrame:(NSRect)frameRect 
			forDocView:(GRDocView *)aView
	objectProperties:(NSDictionary *)objprops;

- (int)runModal;
			
- (void)textFieldDidEndEditing:(NSNotification *)notification;

- (void)setLnJoin:(id)sender;

- (void)setLnJoin:(id)sender;

- (void)fllButtPressed:(id)sender;

- (void)stkButtPressed:(id)sender;

- (void)okCancelPressed:(id)sender;

- (NSDictionary *)properties;

@end

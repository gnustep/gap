#ifndef DIALOGS_H
#define DIALOGS_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

@interface GSDlogView : NSView
@end

@interface GSUserNameDialog : NSWindow
{
	GSDlogView *dialogView;
	NSTextField *titlefield, *editfield;	
	NSButton *okbutt;
	int result;
}

- (id)initWithTitle:(NSString *)title;
- (int)runModal;
- (NSString *)getEditFieldText;
- (void)buttonAction:(id)sender;

@end

@interface GSHallOfFameWin : NSWindow
{
	NSView *myView;
  	NSScrollView *scoresScroll;
  	NSMatrix *scoresMatrix;	
  	NSButtonCell *buttonCell;
}

- (id)initWithScoreArray:(NSArray *)scores;

@end

#endif // DIALOGS_H

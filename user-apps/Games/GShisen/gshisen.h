#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "board.h"

@interface GShisen : NSObject
{
  IBOutlet NSWindow *win;
  IBOutlet GSBoard *board;
  IBOutlet NSPanel *askNamePanel;
  IBOutlet NSTextField *nameField;
  IBOutlet NSPanel *hallOfFamePanel;
  IBOutlet NSMatrix *scoresMatrix;
  NSView *myView;
}

+ (GShisen *)sharedshisen;

- (IBAction)newGame:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)getHint:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)showHallOfFame:(id)sender;
- (IBAction)buttonOk:(id)sender;

- (NSString *)getUserName;

@end


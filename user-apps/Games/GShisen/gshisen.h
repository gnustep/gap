#ifndef GSHISEN_H
#define GSHISEN_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "board.h"

@interface GShisen : NSObject
{
  IBOutlet NSWindow *win;
  IBOutlet GSBoard *board;
  IBOutlet NSPanel *askNamePanel;
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

@end

#endif // GSHISEN_H

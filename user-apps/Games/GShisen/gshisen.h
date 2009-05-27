#ifndef GSHISEN_H
#define GSHISEN_H

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "board.h"

@interface GShisen : NSObject
{
	NSWindow *win;
	GSBoard *board;
}

+ (GShisen *)sharedshisen;

- (void)newGame:(id)sender;
- (void)pause:(id)sender;
- (void)getHint:(id)sender;
- (void)undo:(id)sender;
- (void)runInfoPanel:(id)sender;
- (void)showHallOfFame:(id)sender;

@end

#endif // GSHISEN_H

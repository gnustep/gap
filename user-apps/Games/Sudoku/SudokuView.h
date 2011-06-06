
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Sudoku.h"

#define FIELD_DIM   54
#define FONT_SIZE   36
#define MARKUP_SIZE 10

@interface SudokuView : NSView
{
  Sudoku *sdk;
}

- initWithFrame:(NSRect)frame;
- (Sudoku *)sudoku;

- reset;
- loadSolution;

- (void)drawMarkupAtX:(int)x andY:(int)y;
- (void)drawString:(char *)str atX:(int)x andY:(int)y color:(NSColor *)col;
- (void)drawRect:(NSRect)rect;

- (void)mouseDown:(NSEvent *)theEvent;

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;
- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender;

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender;


@end

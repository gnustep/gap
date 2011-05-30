#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#define DIMENSION    24

#define SEPARATOR    10
#define MARGIN        6

typedef enum {
    COV_COVERED = 0,
    COV_UNCOVERED,
    COV_UNCOVERED_BY_CLICK
} COV_STATE;

@interface Square : NSView
{
    int row, col;

    BOOL isMine;
    int neighbors;
    COV_STATE covered;
    BOOL marked;

    id con;
}

- initAtPoint:(NSPoint)aPoint row:(int)rval col:(int)cval
   controller:(id)theCon;

- (int)row;
- (int)col;

- setDefaults;

- setMine:(BOOL)flag;
- setNeighbors:(int)count;
- setCovered:(COV_STATE)aState;
- setMarked:(BOOL)flag;

- (BOOL)mine;
- (int)neighbors;
- (COV_STATE)covered;
- (BOOL)marked;

- (void)drawRect:(NSRect)aRect;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)rightMouseDown:(NSEvent *)theEvent;

@end


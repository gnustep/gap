#import "tile.h"
#import "board.h"

@implementation GSTile

- (id)initOnBoard:(GSBoard *)aboard 
          iconRef:(NSString *)ref 
            group:(int)grp
           rndpos:(int)rnd
     isBorderTile:(BOOL)btile
{
    self = [super init];
    if(self) {
        [self setFrame: NSMakeRect(0, 0, 40, 56)];
        isBorderTile = btile;
        if(!isBorderTile) {
            theBoard = aboard;
            iconName = [[NSString alloc] initWithFormat:@"%@.tiff", ref];
            iconSelName = [[NSString alloc] initWithFormat:@"%@-h.tiff", ref];
            icon = [NSImage imageNamed: iconName];
            group = grp;
            rndpos = [[NSNumber alloc] initWithInt: rnd];
            isSelect = NO;
            isActive = YES;
        } else {
            isActive = NO;
        }
    }
    return self;
}

- (void)dealloc
{
    if(!isBorderTile) {
        //[icon release];
        [iconName release];
        [iconSelName release];
        [rndpos release];
    }
    [super dealloc];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)setPositionOnBoard:(int)x posy:(int)y
{
    px = x;
    py = y;
}

- (void)select
{
    int result = [theBoard prepareTilesToRemove: self];
    if(!result) {
        return;
    } else {
        isSelect = YES;
        icon = [NSImage imageNamed: iconSelName];
        [self setNeedsDisplay: YES];
    }
    if(result == 2)
        [theBoard removeCurrentTiles];
}

- (void)hightlight
{
    icon = [NSImage imageNamed: iconSelName];
    [self setNeedsDisplay: YES];
}

- (void)unselect
{
    isSelect = NO;
    icon = [NSImage imageNamed: iconName];
    [self setNeedsDisplay: YES];
    [theBoard unSetCurrentTiles];
}

- (void)deactivate
{
    isActive = NO;
    [self setNeedsDisplay: YES];
}

- (void)activate
{
    isActive = YES;
    [self setNeedsDisplay: YES];
}


- (BOOL)isSelect
{
    return isSelect;
}

- (BOOL)isActive
{
    return isActive;
}

- (BOOL)isBorderTile
{
    return isBorderTile;
}

- (int)group
{
    return group;
}

- (NSNumber *)rndpos
{
    return rndpos;
}

- (int)px
{
    return px;
}

- (int)py
{
    return py;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if([theBoard gameState] != GAME_STATE_RUNNING)
        return;
    if(!isActive)
        return;
    if(!isSelect)
        [self select];
    else
        [self unselect];
}

- (void)drawRect:(NSRect)rect
{
    if(!isActive || ([theBoard gameState] != GAME_STATE_RUNNING)) {
        // This doesn't need to be done, since the board will take care of it.
        //[[NSColor colorWithCalibratedRed: 0.1 green: 0.47 blue: 0 alpha: 1] set];
        //NSRectFill(rect);
    } else {
        [icon compositeToPoint: NSZeroPoint operation: NSCompositeCopy];
    }
}

@end



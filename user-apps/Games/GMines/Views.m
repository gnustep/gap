
#import "Views.h"
#import "Controller.h"


@implementation Square

- initAtPoint:(NSPoint)aPoint row:(int)rval col:(int)cval
   controller:(id)theCon
{
    NSRect frame;

    frame.origin = aPoint;
    frame.size.width = frame.size.height = DIMENSION;

    [super initWithFrame:frame];

    [self setDefaults];
    con = theCon;

    row = rval;
    col = cval;

    return self;
}

- (int)row
{
    return row;
}

- (int)col
{
    return col;
}

- setDefaults
{
    isMine = NO;
    neighbors = 0;
    covered = COV_COVERED;
    marked = NO;

    [self setNeedsDisplay:YES];
    return self;
}

- setMine:(BOOL)flag;
{
    if(flag!=isMine){
        [self setNeedsDisplay:YES];
    }

    isMine = flag;
    return self;
}

- setNeighbors:(int)count;
{
    if(count!=neighbors){
        [self setNeedsDisplay:YES];
    }

    neighbors = count;
    return self;
}

- setCovered:(COV_STATE)aState
{
    if(aState!=covered){
        [self setNeedsDisplay:YES];
    }

    covered = aState;
    return self;
}

- setMarked:(BOOL)flag;
{
    if(flag!=marked){
        [self setNeedsDisplay:YES];
    }

    marked = flag;
    return self;
}

- (BOOL)mine;
{
    return isMine;
}

- (int)neighbors
{
    return neighbors;
}

- (COV_STATE)covered
{
    return covered;
}

- (BOOL)marked
{
    return marked;
}

- (void)drawRect:(NSRect)aRect
{
    PSsetlinewidth(1.0);

    if(covered==COV_COVERED){
        if(marked==YES){
            int center = DIMENSION-DIMENSION/3, width = DIMENSION/3+4;

            [[NSColor blackColor] set];
            PSrectfill(center-width/2, 2, width, 4);
            PSrectfill(center-width/2+2, 6, width-4, 3);

            PSmoveto(center, 9);
            PSlineto(center, 5*DIMENSION/6);
            PSstroke();

            [[NSColor redColor] set];
            PSrectfill(center-DIMENSION/2, DIMENSION/2, 
                       DIMENSION/2, 5*DIMENSION/6-DIMENSION/2);
        }
    }
    else{
        if(covered==COV_UNCOVERED_BY_CLICK && isMine==YES){
            [[NSColor redColor] set];
        }
        else{
            [[NSColor whiteColor] set];
        }
        PSrectfill(0, 0, DIMENSION, DIMENSION);

        if(isMine==YES || marked==YES){
            [[NSColor blackColor] set];
            PSarc(DIMENSION/2, DIMENSION/2,
                  DIMENSION/2-3, 0, 360);
            PSfill();

            PSgsave();

            PStranslate(DIMENSION/2, DIMENSION/2);

            PSmoveto(-DIMENSION/2, 0);
            PSlineto(DIMENSION/2, 0);
            PSmoveto(0, -DIMENSION/2);
            PSlineto(0, DIMENSION/2);

            PSrotate(45);

            PSmoveto(-DIMENSION/2, 0);
            PSlineto(DIMENSION/2, 0);
            PSmoveto(0, -DIMENSION/2);
            PSlineto(0, DIMENSION/2);

            PSstroke();

            PSgrestore();

            [[NSColor whiteColor] set];
            PSarc(DIMENSION/2-DIMENSION/8, DIMENSION/2+DIMENSION/8,
                  DIMENSION/10, 0, 360);
            PSfill();
        }

        if(isMine==NO && marked==YES){
            [[NSColor redColor] set];

            PSgsave();

            PSsetlinewidth(5.0);
            PSmoveto(3, 3);
            PSlineto(DIMENSION-3, DIMENSION-3);
            PSmoveto(3, DIMENSION-3);
            PSlineto(DIMENSION-3, 3);
            PSstroke();

            PSgrestore();
        }

        if(isMine==NO && marked==NO && neighbors>0){
            char str[2] = { '0', 0 };
            float comp = ((float)neighbors)/9.0;
            NSFont *font = 
                [NSFont systemFontOfSize:DIMENSION-6];
            [font set];

            str[0] += neighbors;

            PSsetrgbcolor(1.0-comp, comp, comp);
            PSmoveto(DIMENSION/2-4, DIMENSION/4);
            PSshow(str);
            PSstroke();
        }
    }


    [[NSColor blackColor] set];
    PSrectstroke(0, 0, DIMENSION, DIMENSION);
    [[NSColor whiteColor] set];
    PSrectstroke(1, 1, DIMENSION-2, DIMENSION-2);
}


- (void)mouseDown:(NSEvent *)theEvent
{
    if(covered==COV_COVERED && marked==NO){
        [con uncovered:self];
        [self setCovered:COV_UNCOVERED_BY_CLICK];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if(covered==COV_COVERED){
	if(marked==NO && ![con markCount]){
	    NSBeep();
	    return;
	}

        [self setMarked:(marked==YES ? NO : YES)];
        [con marked:self];
    }
}

@end


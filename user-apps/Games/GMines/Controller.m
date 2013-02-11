
#import <time.h>

#import "Controller.h"

#ifdef __MINGW__
#define srand48 srand
#define lrand48 rand
#endif


@implementation Controller

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    NSInvocation *inv;

    inv = [NSInvocation 
              invocationWithMethodSignature: 
                  [self methodSignatureForSelector: 
                            @selector(tick)]];
    [inv setSelector:@selector(tick)];
    [inv setTarget:self];
    [inv retain];

    [NSTimer scheduledTimerWithTimeInterval:1.0
             invocation:inv
             repeats:YES];

    window = nil;

    srand48(time(NULL));

    [self makeGameWindow];
    [self newGame:nil];
}

- makeGameWindow
{
    NSRect frame;
    NSView *view;
    int m = NSTitledWindowMask;
    int row, col;
    NSBox *boardBox;

    view  = [[NSView alloc] 
                initWithFrame:
                    NSMakeRect(0, 0, DIMENSION*8, DIMENSION*8)];
    for(row=0; row<8; row++){
        for(col=0; col<8; col++){
            NSPoint spoint = 
                NSMakePoint(row*DIMENSION, col*DIMENSION);
            Square *field = 
                [[Square alloc] initAtPoint:spoint
                    row:row col:col controller:self];
            [view addSubview:field];
            fields[row][col] = field;
        }
    }

    markField =
        [[NSTextField alloc]
            initWithFrame:
                NSMakeRect(0, DIMENSION*8+SEPARATOR,
                           3*DIMENSION, DIMENSION)];
    [markField setEditable:NO];
    [markField setSelectable:NO];
    [markField setBackgroundColor:[NSColor blackColor]];
    [markField setTextColor:[NSColor redColor]];
    [view addSubview:markField];


    timeField =
        [[NSTextField alloc]
            initWithFrame:
                NSMakeRect(DIMENSION*5, DIMENSION*8+SEPARATOR,
                           3*DIMENSION, DIMENSION)];
    [timeField setEditable:NO];
    [timeField setSelectable:NO];
    [timeField setBackgroundColor:[NSColor blackColor]];
    [timeField setTextColor:[NSColor redColor]];
    [view addSubview:timeField];

    boardBox = 
        [[NSBox alloc] 
            initWithFrame:
                NSMakeRect(0, 0, DIMENSION*8, DIMENSION*8)];
    [boardBox setContentView:view];
    [boardBox setContentViewMargins:NSMakeSize(MARGIN, MARGIN)];
    [boardBox setTitle:@"Board"];
    [boardBox setBorderType:NSGrooveBorder];
    [boardBox sizeToFit];

    frame = [NSWindow frameRectForContentRect:[boardBox frame] 
                      styleMask:m];

    window = [[NSWindow alloc] initWithContentRect:frame 
                                styleMask:m			       
                                backing: NSBackingStoreRetained 
                                defer:NO];
    [window setMinSize:frame.size];
    [window setTitle:@"Mines"];
    [window setDelegate:self];

    [window setFrame:frame display:YES];
    [window setMaxSize:frame.size];

    [window setContentView:boardBox];
    [window setReleasedWhenClosed:YES];

    // RELEASE(view);

    [window center];
    [window orderFrontRegardless];
    [window makeKeyWindow];
    [window display];


    return self;
}


- newGame:(id)sender
{
    int row, col, mrow, mcol, index;

    for(row=0; row<8; row++){
        for(col=0; col<8; col++){
            [fields[row][col] setDefaults];
        }
    }

    for(index=0; index<10; index++){
        do {
            mrow = lrand48()%8;
            mcol = lrand48()%8;
        }
        while([fields[mrow][mcol] mine]==YES);
        [fields[mrow][mcol] setMine:YES];
    }

    for(row=0; row<8; row++){
        for(col=0; col<8; col++){
            int sx, sy, nb;
            nb = 0;
            for(sx=-1; sx<=1; sx++){
                for(sy=-1; sy<=1; sy++){
                    int cx = row+sx, cy = col+sy;
                    if(!(sx==0 && sy==0) &&
                       (0<=cx && cx<8) &&
                       (0<=cy && cy<8)){
                        if([fields[cx][cy] mine]==YES){
                            nb++;
                        }
                    }
                }
            }

            if(nb>0){
                [fields[row][col] setNeighbors:nb];
            }
        }
    }

    [markField setIntValue:10];
    [timeField setStringValue:@""];

    uncovered = 0;
    atStart = YES;

    return self;
}


- uncoverRegion:(Square *)item
{
    int row, col, sx, sy, cx, cy;

    if([item covered]!=COV_COVERED || [item marked]==YES){
        return self;
    }

    [item setCovered:COV_UNCOVERED];
    uncovered++;

    if([item neighbors]>0){
        return self;
    }

    row = [item row]; col = [item col];
    for(sx=-1; sx<=1; sx++){
        for(sy=-1; sy<=1; sy++){
            cx = row + sx; cy = col + sy;
            if(!(sx==0 && sy==0) &&
               (0<=cx && cx<8) &&
               (0<=cy && cy<8)){
                [self uncoverRegion:fields[cx][cy]];
            }
        }
    }

    return self;
}

- uncoverAll:(Square *)item
{
    int row, col;
    for(row=0; row<8; row++){
        for(col=0; col<8; col++){
            Square *other = fields[row][col];
            if(other!=item){
                [other setCovered:COV_UNCOVERED];
            }
        }
    }
    
    atStart = YES;

    return self;
}

- uncovered:(Square *)item
{
    BOOL win;

    [self start];

    if(![item neighbors] && [item mine]==NO){
        [self uncoverRegion:item];
    }
    else if([item mine]==NO){
        uncovered++;
    }

    win = ((uncovered==(64-10) && ![markField intValue]) ? YES : NO);

    if([item mine]==YES || win==YES){
        [self uncoverAll:item];
    }

    if([item mine]==YES){
        NSRunAlertPanel(@"Game over.", @"You lose.",
                        @"Ok", nil, nil);
    }
    else if(win==YES){
        NSRunAlertPanel(@"Congratulations!", @"You win.",
                        @"Ok", nil, nil);
    }

    return self;
}

- marked:(Square *)item
{
    BOOL win;
    int marks = [markField intValue];
    [markField setIntValue:marks+([item marked]==YES ? -1 : 1)];

    [self start];

    win = ((uncovered==(64-10) && ![markField intValue]) ? YES : NO);
    if(win==YES){
        [self uncoverAll:nil];
        NSRunAlertPanel(@"Congratulations!", @"You win.",
                        @"Ok", nil, nil);
    }

    return self;
}

- (int)markCount
{
    return [markField intValue];
}


- start
{
    if(atStart==YES){
        startDate = [NSDate date];
        [startDate retain];
        atStart = NO;
    }
    
    return self;
}

- tick
{
    if(atStart==NO){
        int delta = -[startDate timeIntervalSinceNow];
        NSString *timeStr = 
            [NSString stringWithFormat:@"%06d:%02d", 
                      delta/60, delta%60];
        [timeField setStringValue:timeStr];
    }

    return self;
}

@end



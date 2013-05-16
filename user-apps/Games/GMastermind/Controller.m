/*
	Controller.m

	window controller class

	Copyright (C) 2003 Marko Riedel
	Copyright (C) 2011 GNUstep Application Team
                           Riccardo Mottola

	Author: Marko Riedel <mriedel@bogus.example.com>
	Date:	5 July 2003

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public
	License along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA
*/

#include <time.h>
#include <AppKit/NSPanel.h>
#include "Controller.h"

#ifdef __MINGW__
#define srand48 srand
#define lrand48 rand
#endif



@implementation Controller

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
{
    window = nil;

    srand48(time(NULL));

    [self makeGameWindow];
    [self makeColorPalette];

    [self newGameUnique:NO];
}

- makeGameWindow
{
    NSRect frame;
    NSView *view;
    int m = NSTitledWindowMask;
    int row, col;
    NSBox *boardBox, *solBox;
    NSRect contentRect, rectForTitle;

    view  = [[NSView alloc] 
                initWithFrame:
                    NSMakeRect(0, 0, PEGDIMENSION*4,PEGDIMENSION*8)];
    for(col=0; col<4; col++){
        NSPoint spoint = 
            NSMakePoint(PEGMARGIN+col*PEGDIMENSION, 0);
        Peg *speg = 
            [[Peg alloc] initAtPoint:spoint];
        [view addSubview:speg];
        sol[col] = speg;
    }
    
    solBox = [[NSBox alloc] init];
    [solBox setContentView:view];
    [solBox setContentViewMargins:NSMakeSize(PEGMARGIN, PEGMARGIN)];
    [solBox setTitle:@"Answer"];
    [solBox setBorderType:NSGrooveBorder];
    [solBox sizeToFit];

    view  = [[NSView alloc] 
                initWithFrame:
                    NSMakeRect(0, PEGDIMENSION+PEGMARGIN, 
                               PEGDIMENSION*4,PEGDIMENSION*8)];
    
    for(row=0; row<8; row++){
        NSPoint rpoint = 
            NSMakePoint(PEGMARGIN+4*PEGDIMENSION+SEPARATOR, 
                        PEGMARGIN+row*PEGDIMENSION);
        Result *rview =
            [[Result alloc] initAtPoint:rpoint];
        [view addSubview:rview];
        res[row] = rview;

        for(col=0; col<4; col++){
            NSPoint dpoint = 
                NSMakePoint(PEGMARGIN+col*PEGDIMENSION, 
                            PEGMARGIN+row*PEGDIMENSION);
            DestinationPeg *dpeg = 
                [[DestinationPeg alloc] initAtPoint:dpoint];
            [view addSubview:dpeg];
            pegs[row][col] = dpeg;
        }
    }

    boardBox = 
        [[NSBox alloc] 
            initWithFrame:
                NSMakeRect(0, PEGMARGIN+2*PEGDIMENSION-3*PEGMARGIN/2, 0, 0)];
    [boardBox setContentView:view];
    [boardBox setContentViewMargins:NSMakeSize(PEGMARGIN, PEGMARGIN)];
    [boardBox setTitle:@"Board"];
    [boardBox setBorderType:NSGrooveBorder];
    [boardBox sizeToFit];

    rectForTitle = [[boardBox titleFont] boundingRectForFont];

    contentRect.origin = NSMakePoint(0, 0);
    contentRect.size =
        NSMakeSize([boardBox frame].size.width,
                   [solBox frame].size.height+
		   PEGMARGIN+
		   [boardBox frame].size.height+
		   rectForTitle.size.height);

    view  = [[NSView alloc] initWithFrame:contentRect];
    [view addSubview:boardBox];
    [view addSubview:solBox];

    frame = [NSWindow frameRectForContentRect:[view frame] 
                      styleMask:m];

     window = [[NSWindow alloc] initWithContentRect:frame 
                                 styleMask:m			       
                                 backing: NSBackingStoreBuffered 
				defer:NO];
    [window setMinSize:frame.size];
    [window setMaxSize:frame.size];

    [window setTitle:@"Mastermind"];
    [window setDelegate:self];
    [window setContentView:view];
    [window setReleasedWhenClosed:YES];
    //    [window setFrame:frame display:YES];
    
    [window setFrameUsingName: @"MasterMindsMain"];
    [window setFrameAutosaveName: @"MasterMindsMain"];

    // [window setBackgroundColor:[NSColor orangeColor]];
    [window orderFrontRegardless];
    // RELEASE(view);

    // [window center];
    // [window orderFrontRegardless];
    // [window makeKeyWindow];
    // [window display];

    return self;
}

- makeColorPalette
{
    NSRect frame;
    NSView *view;

    int m = NSTitledWindowMask;
    int rcol, gcol, bcol, index;

    view  = [[NSView alloc] 
                initWithFrame:
                    NSMakeRect(0, 0, PEGDIMENSION*3,PEGDIMENSION*2)];
    index = 0;

    for(rcol=0; rcol<=1; rcol++){
        for(gcol=0; gcol<=1; gcol++){
            for(bcol=0; bcol<=1; bcol++){
                if(0<index && index<7){
                    int 
                        x = ((index-1)%3)*PEGDIMENSION,
                        y = ((index-1)%2)*PEGDIMENSION;
                    NSPoint spoint = NSMakePoint(x, y);
                    SourcePeg *speg = 
                        [[SourcePeg alloc] initAtPoint:spoint];
                    NSColor *col =
                        [NSColor colorWithDeviceRed:(CGFloat)rcol
                                 green:(CGFloat)gcol
                                 blue:(CGFloat)bcol
                                 alpha:1.0];
                    [speg setColor:col];
                    [view addSubview:speg];
                }
                index++;
            }
        }
    }


    frame = [NSWindow frameRectForContentRect:[view frame] 
                      styleMask:m];

    palette = [[NSWindow alloc] initWithContentRect:frame 
                                styleMask:m			       
                                backing: NSBackingStoreBuffered 
                                defer:YES];
    [palette setMinSize:frame.size];
    [palette setTitle:@"Palette"];
    [palette setDelegate:self];

    //    [palette setFrame:frame display:YES];
    [palette setMaxSize:frame.size];
    [palette setContentView:view];
    [palette setReleasedWhenClosed:YES];

    // RELEASE(view);

    // [palette setBackgroundColor:[NSColor orangeColor]];

    [palette setFrameUsingName: @"MasterMindsPalette"];
    [palette setFrameAutosaveName: @"MasterMindsPalette"];



    // [palette center];
    [palette orderFrontRegardless];
    [palette makeKeyWindow];
    // [palette display];

    return self;
}

- evalCombos:(int *)combo1 and:(int *)combo2
       white:(int *)wptr black:(int *)bptr;
{
    int colcount[8][2];
    int col, black, white;

    for(col=1; col<7; col++){
        colcount[col][0] = 0;
        colcount[col][1] = 0;
    }

    for(col=0; col<4; col++){
        colcount[combo1[col]][0]++;
        colcount[combo2[col]][1]++;
    }

    white = 0;
    for(col=1; col<7; col++){
        int smaller = 
            (colcount[col][0]>colcount[col][1] ? 1 : 0);
        white += colcount[col][smaller];            
    }

    black = 0;
    for(col=0; col<4; col++){
        if(combo1[col]==combo2[col]){
            black++;
        }
    }
    white -= black;

    *wptr = white;
    *bptr = black;

    return self;
}

#define DOUBLES(__combo)	 \
    (__combo[0] == __combo[1] || \
     __combo[0] == __combo[2] || \
     __combo[0] == __combo[3] || \
     __combo[1] == __combo[2] || \
     __combo[1] == __combo[3] || \
     __combo[2] == __combo[3])


- newGameUnique:(BOOL)uniq
{
    int row, col;

    for(row=0; row<8; row++){
        [res[row] setBlack:0 andWhite:0];

        for(col=0; col<4; col++){
            [pegs[row][col] setColor:nil];
            [pegs[row][col] setActive:(row==7 ? YES : NO)];
        }
    }
    
    for(col=0; col<4; col++){
        [sol[col] setColor:nil];
    }

    currentRow = 7;

    do {
	combo[0] = 1+(lrand48()%6);
	combo[1] = 1+(lrand48()%6);
	combo[2] = 1+(lrand48()%6);
	combo[3] = 1+(lrand48()%6);
    } while(uniq==YES && DOUBLES(combo));

    unique = uniq;
    done = NO;

    [window 
	setTitle:
	    (unique==NO ?
	     @"Mastermind (with replacement)" :
	     @"Mastermind (without replacement)")];

    return self;
}

- newGameWithRep:(id)sender
{
    return [self newGameUnique:NO];
}

- newGameNoRep:(id)sender
{
    return [self newGameUnique:YES];
}


- commit:(id)sender
{
    int col;
    int aCombo[4];
    CGFloat thecomps[4];
    int white, black;

    for(col=0; col<4; col++){
        NSColor *color = [pegs[currentRow][col] color];
        if(color==nil){
            NSRunAlertPanel(@"Alert", @"All four colors must be set.",
                            @"OK", nil, nil);
            return self;
        }

        [color getRed:thecomps green:thecomps+1 blue:thecomps+2 
               alpha:thecomps+3];
        aCombo[col] = 
            (thecomps[0]==1.0 ? 4 : 0) +
            (thecomps[1]==1.0 ? 2 : 0) +
            (thecomps[2]==1.0 ? 1 : 0);
    }

    if(unique==YES && DOUBLES(aCombo)){
	NSRunAlertPanel(@"Alert", @"No double colors, please.",
			@"OK", nil, nil);
	return self;
    }

    for(col=0; col<4; col++){
        [pegs[currentRow][col] setActive:NO];
    }

    [self evalCombos:combo and:aCombo
          white:&white black:&black];

    [res[currentRow] setBlack:black andWhite:white];

    currentRow--;
    if(black==4){
        done = YES;
        NSRunAlertPanel(@"Congratulations!", @"You win.",
                        @"OK", nil, nil);
    }
    else if(currentRow<0){
        done = YES;
        NSRunAlertPanel(@"Game over.", @"You lose.",
                        @"OK", nil, nil);
    }
    else{
        for(col=0; col<4; col++){
            [pegs[currentRow][col] setActive:YES];
        }
    }

    if(done==YES){
        for(col=0; col<4; col++){
            int c = combo[col];
            NSColor *color = 
                [NSColor colorWithDeviceRed:(CGFloat)(c & 4 ? 1 : 0)
                         green:(CGFloat)(c & 2 ? 1 : 0)
                         blue:(CGFloat)(c & 1 ? 1 : 0)
                         alpha:1.0];
            [sol[col] setColor:color];
        }
    }

    return self;
}

- move:(id)sender
{
    int upper = 6*6*6*6, current, cur, testit[4], prev[4];
    int row, black, white, pblack, pwhite, col;

    for(current=0; current<upper; current++){
        cur = current;
        for(col=0; col<4; col++){
            testit[col] = 1+cur%6; cur /= 6;
        }

	if(unique==YES && DOUBLES(testit)){
	    continue;
	}

        for(row=7; row>currentRow; row--){
            for(col=0; col<4; col++){
                prev[col] = [pegs[row][col] cvalue];
            }

            [self evalCombos:(int *)testit and:(int *)prev
                  white:&white black:&black];
            [res[row] getBlack:&pblack andWhite:&pwhite];

            if(pblack!=black || pwhite!=white){
                break;
            }
        }

        if(row==currentRow){
            break;
        }
    }

    for(col=0; col<4; col++){
        [pegs[currentRow][col] setCValue:testit[col]];
    }
    
    [self commit:nil];

    return self;
}


- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;
{
  int tag = [menuItem tag];
  if (done == YES &&
     ( (tag == MENU_MOVE) ||(tag == MENU_COMMIT) ) )
    {
      
      return NO;
    }
  
  return YES;
}

@end

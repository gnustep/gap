/* 
   Project: Sudoku
   SudokuView.m

   Copyright (C) 2007-2011 The Free Software Foundation, Inc

   Author: Marko Riedel
           Riccardo Mottola

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import <AppKit/AppKit.h>
#import "SudokuView.h"
#import "DigitSource.h"

@implementation SudokuView

- initWithFrame:(NSRect)frame
{
    frame.size.width = SDK_DIM;
    frame.size.height = SDK_DIM;

    [super initWithFrame:frame];

    [self registerForDraggedTypes:
	    [NSArray arrayWithObjects:DIGIT_TYPE, nil]];


    sdk = [[Sudoku alloc] init];
    [sdk retain];

    return self;
}

- (Sudoku *)sudoku
{
  return sdk;
}

- (void)drawMarkupAtX:(int)x andY:(int)y
{
  NSFont *font;
  NSColor *col = [NSColor colorWithDeviceRed:0
			  green:1.0/3.0
			   blue:0
			  alpha:1.0];
  NSDictionary *attrDict;
  int present[9], digit;
  int nb;
  char str[2] = { '1', 0 };

  font = [NSFont boldSystemFontOfSize:MARKUP_SIZE];
  attrDict =[NSDictionary dictionaryWithObjectsAndKeys:
			    font, NSFontAttributeName, 
			  col, NSForegroundColorAttributeName, 
			  nil];
  [font set];

  
  for(digit=0; digit<9; digit++)
    present[digit] = 0;

  
  for(nb=0; nb<NBCOUNT; nb++)
    {
      int nx, ny;
      nx = [sdk fieldX:x Y:y].adj[nb].nx; 
      ny = [sdk fieldX:x Y:y].adj[nb].ny;
      present[[sdk retrX:nx Y:ny]]++;
    }

  

  for(digit=0; digit<9; digit++)
    {
      if(!present[digit])
	{
	  NSString *strObj;
	  NSSize strSize;
	  int idx, idy;
	  NSPoint loc;

	  str[0] = '1'+digit;
	  
	  strObj = [NSString stringWithCString:str];
	  strSize = [strObj sizeWithAttributes:attrDict];	    

	  idx = digit % 3;
	  idy = digit / 3;

	  loc = NSMakePoint(x*FIELD_DIM + idx*FIELD_DIM/3 + (FIELD_DIM/3-strSize.width)/2,
			    (8-y)*FIELD_DIM + (2-idy)*FIELD_DIM/3 + (FIELD_DIM/3-strSize.height)/2 );

	  [strObj drawAtPoint:loc withAttributes:attrDict];
	}
    }
}

- (void)drawString:(char *)str atX:(int)x andY:(int)y 
	     color:(NSColor *)col
{
  NSFont *font;
  NSDictionary *attrDict;
  NSString *strObj;
  NSSize strSize;
  NSPoint loc;


  font = [NSFont boldSystemFontOfSize:FONT_SIZE];
  attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
		    font, NSFontAttributeName, 
		  col, NSForegroundColorAttributeName, nil];
  [font set];

  strObj = [NSString stringWithCString:str];
  strSize = [strObj sizeWithAttributes:attrDict];	    

  loc = NSMakePoint(x*FIELD_DIM + (FIELD_DIM-strSize.width)/2,
		(8-y)*FIELD_DIM + (FIELD_DIM-strSize.height)/2);
  [strObj drawAtPoint:loc withAttributes:attrDict];
}

- (void)drawRect:(NSRect)rect
{
  int x, y, pos;
  

  [[NSColor whiteColor] set];

  NSRectFill([self bounds]);

  [[NSColor blackColor] set];
  for(pos=0; pos<=9; pos++)
    {
      NSBezierPath *path;
      path = [[NSBezierPath alloc] init];

      if(!(pos % 9))
	[path setLineWidth: 10.0];
      else if(!(pos % 3))
	[path setLineWidth: 4.0];
      else
	[path setLineWidth: 2.0];


      [path moveToPoint: NSMakePoint(0, pos*FIELD_DIM)];
      [path lineToPoint: NSMakePoint(9*FIELD_DIM, pos*FIELD_DIM)];
      [path stroke];
       
      [path moveToPoint: NSMakePoint(pos*FIELD_DIM, 0)];
      [path lineToPoint: NSMakePoint(pos*FIELD_DIM, 9*FIELD_DIM)];
      [path stroke];
      
      [path release];
    }

    for(x=0; x<9; x++){
        for(y=0; y<9; y++){
	    NSColor *col;
	    char str[2] = { '1', 0 };
	    
	    BOOL empty = NO;
	    if([sdk puzzleX:x Y:y] != -1){
		col = [NSColor blackColor];
		str[0] += [sdk puzzleX:x Y:y];
	    }
	    else if([sdk guessX:x Y:y] != -1){
		col = [NSColor blueColor];
		str[0] += [sdk guessX:x Y:y];
	    }
	    else{
		empty = YES;
	    }

	    if(empty==NO){
		[self drawString:str atX:x andY:y color:col];
	    }
	    else{
		[self drawMarkupAtX:x andY:y];
	    }
	}
    }
}

- reset
{
  [sdk reset];

  [self setNeedsDisplay:YES];
  [self display];

  [[self window] flushWindow];

  return self;
}  

- loadSolution
{
  [sdk loadSolution];

  [self setNeedsDisplay:YES];
  [self display];

  [[self window] flushWindow];

  return self;
}  


#define TICK 0.75
#define POLL 0.20

- (void)mouseDown:(NSEvent *)theEvent
{
  NSPoint startp = [theEvent locationInWindow];
  NSWindow *win = [self window];
  NSEvent *curEvent = theEvent;
  int guess;
  NSRect box, cachebox;
  BOOL first;
  NSDate *tick;
  NSBezierPath *bpfilled, *bpstroked;
  unsigned int cmask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;
  NSDocumentController *dc;
  char str[2];
  int nb;
  int x, y;

  startp = [self convertPoint:startp fromView: nil];
  startp.x/=(float)FIELD_DIM; startp.y/=(float)FIELD_DIM; 
  x = (int)startp.x;
  y = 8-(int)startp.y;

  if([sdk fieldX:x Y:y].puzzle != -1){
    NSBeep();
    return;
  }

  guess = [sdk fieldX:x Y:y].guess;

  box = NSMakeRect(x*FIELD_DIM, (8-y)*FIELD_DIM, FIELD_DIM,  FIELD_DIM);
  cachebox = box;
  cachebox.origin.x -= 4;
  cachebox.origin.y -= 4;
  cachebox.size.width += 8;
  cachebox.size.height += 8;
  
  cachebox = [self convertRect:cachebox toView:nil];

  first = YES;
  
  tick = [NSDate dateWithTimeIntervalSinceNow:TICK];

  bpfilled = [NSBezierPath bezierPathWithRect:box],
  bpstroked = [NSBezierPath bezierPathWithRect:box];

  [bpstroked setLineWidth:6.0];

  guess = (guess==-1 ? 0 : (guess==8 ? -1 : guess+1));

  do {
    NSDate *now;
    char str[2];

    if(first==NO){
      [win restoreCachedImage];
    }
    first = NO;       

    [win cacheImageInRect:cachebox];

    [self lockFocus];

    [[NSColor greenColor] set];
    [bpfilled fill];

    [[NSColor blueColor] set];
    [bpstroked stroke];

    now = [NSDate date];
    if([now laterDate:tick]==now){
      guess = 
	(guess==-1 ? 0 : (guess==8 ? -1 : guess+1));
      tick = [NSDate dateWithTimeIntervalSinceNow:TICK];
    }

    str[0] = (guess==-1 ? '.' : '1' + guess);
    str[1] = 0;
 
    [self drawString:str atX:x andY:y 
     color:[NSColor blackColor]];

    [self unlockFocus];

    [win flushWindow];

    curEvent = 
      [[self window]
	nextEventMatchingMask:cmask
	untilDate:[NSDate dateWithTimeIntervalSinceNow:POLL]
	inMode:NSEventTrackingRunLoopMode
	dequeue:YES];
  } while(curEvent==nil || [curEvent type] != NSLeftMouseUp);

  [win restoreCachedImage];
  [win flushWindow];
        
  if(guess == [sdk fieldX:x Y:y].guess){
    return;
  }
  
  dc = [NSDocumentController sharedDocumentController];

  if(guess == -1){
    [sdk fieldptrX:x Y:y]->guess = -1;

    [self setNeedsDisplay:YES];

    [self display];
    [win flushWindow];

    [[dc currentDocument] updateChangeCount:NSChangeDone];
    return;
  }

  str[0] = '1' + guess;
  str[1] = 0 ;


  for(nb=0; nb<NBCOUNT; nb++){
    int 
      nx = [sdk fieldX:x Y:y].adj[nb].nx, 
      ny = [sdk fieldX:x Y:y].adj[nb].ny;

    if([sdk retrX:nx Y:ny]==guess){
      break;
    }
  }

  if(nb<NBCOUNT){
    NSDate *errpause;
    NSBeep();
    
    [win cacheImageInRect:cachebox];

    [self lockFocus];

    [[NSColor redColor] set];
    [bpfilled fill];

    [[NSColor blueColor] set];
    [bpstroked stroke];

    [self drawString:str atX:x andY:y
     color:[NSColor blackColor]];

    [self unlockFocus];

    [win flushWindow];

    errpause = [NSDate dateWithTimeIntervalSinceNow:TICK*5];
    [NSThread sleepUntilDate:errpause];

    [win restoreCachedImage];
    [win flushWindow];

    return;
  }

  [[dc currentDocument] updateChangeCount:NSChangeDone];

  [sdk fieldptrX:x Y:y]->guess = guess;
  [self setNeedsDisplay:YES];

  [self display];
  [win flushWindow];

  if([sdk completed]==YES){
    NSRunAlertPanel(@"Congratulations!", @"Sudoku solved.",
		    @"Ok", nil, nil);
  }
    
  return;
}

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
  NSPasteboard *pb = [sender draggingPasteboard];
  NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];

  if([[pb types] indexOfObject:DIGIT_TYPE]!=NSNotFound)
    {
      if(sourceDragMask & NSDragOperationCopy)
	{
	  int newDigit;
	  NSPoint startp;
	  NSString *dstr;
	  int x, y;
	  int nb;

	  dstr = [pb stringForType:DIGIT_TYPE];
	  [[NSScanner scannerWithString:dstr] scanInt:&newDigit];

	  startp = [sender draggingLocation];
	  startp = [self convertPoint:startp fromView: nil];

	  startp.x/=(float)FIELD_DIM; startp.y/=(float)FIELD_DIM; 
	  x = (int)startp.x;
	  y = 8-(int)startp.y;

	  if([sdk fieldX:x Y:y].puzzle != -1)
	    return NSDragOperationNone;

	  if(newDigit==10)
	    return NSDragOperationCopy;

	  newDigit--;

	  for(nb=0; nb<NBCOUNT; nb++)
	    {
	      int nx, ny;

	      nx = [sdk fieldX:x Y:y].adj[nb].nx;
	      ny = [sdk fieldX:x Y:y].adj[nb].ny;

	      if([sdk retrX:nx Y:ny]==newDigit)
		break;
	    }

	  if(nb<NBCOUNT)
	    return NSDragOperationNone;
	}
    }
 
  return NSDragOperationCopy;
}

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
  return [self draggingEntered:sender];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  NSPasteboard *pb = [sender draggingPasteboard];
  NSString *dstr = [pb stringForType:DIGIT_TYPE];
  NSDocumentController *dc;
  NSPoint startp;
  int newDigit;
  int x, y;

  [[NSScanner scannerWithString:dstr] scanInt:&newDigit];

  startp = [sender draggingLocation];
  startp = [self convertPoint:startp fromView: nil];

  startp.x/=(float)FIELD_DIM; startp.y/=(float)FIELD_DIM; 
  x = (int)startp.x;
  y = 8-(int)startp.y;

  [sdk fieldptrX:x Y:y]->guess = 
    (newDigit==10 ? -1 : newDigit-1);

  [self setNeedsDisplay:YES];
  [self display];
  [[self window] flushWindow];

  dc = [NSDocumentController sharedDocumentController];
  [[dc currentDocument] updateChangeCount:NSChangeDone];

  if([sdk completed]==YES){
    NSRunAlertPanel(@"Congratulations!", @"Sudoku solved.",
		    @"Ok", nil, nil);
  }

  return YES;
}



- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
  return YES;
}


@end

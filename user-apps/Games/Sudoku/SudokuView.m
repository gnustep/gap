
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
    RETAIN(sdk);

    return self;
}

- (Sudoku *)sudoku
{
  return sdk;
}

- (void)drawMarkupAtX:(int)x andY:(int)y
{
  NSFont *font = [NSFont boldSystemFontOfSize:MARKUP_SIZE];
  NSColor *col = 
      [NSColor colorWithDeviceRed:0
	       green:1.0/3.0
	       blue:0
	       alpha:1.0];
  NSDictionary *attrDict =
    [NSDictionary dictionaryWithObjectsAndKeys:
		      font, NSFontAttributeName, 
		  col, NSForegroundColorAttributeName, 
		  nil];
  [font set];

  int present[9], digit;
  for(digit=0; digit<9; digit++){
      present[digit] = 0;
  }

  int nb;
  for(nb=0; nb<NBCOUNT; nb++){
    int 
      nx = [sdk fieldX:x Y:y].adj[nb].nx, 
      ny = [sdk fieldX:x Y:y].adj[nb].ny;
    present[[sdk retrX:nx Y:ny]]++;
  }

  char str[2] = { '1', 0 };

  for(digit=0; digit<9; digit++){
      if(!present[digit]){
	  str[0] = '1'+digit;
	  
	  NSString *strObj = [NSString stringWithCString:str];
	  NSSize strSize = [strObj sizeWithAttributes:attrDict];	    

	  int idx = digit % 3, idy = digit / 3;

	  NSPoint loc = { 
	      x*FIELD_DIM + idx*FIELD_DIM/3 +
	      (FIELD_DIM/3-strSize.width)/2,
	      (8-y)*FIELD_DIM + (2-idy)*FIELD_DIM/3 +
	      (FIELD_DIM/3-strSize.height)/2 };

	  [strObj drawAtPoint:loc withAttributes:attrDict];
      }
  }
}

- (void)drawString:(char *)str atX:(int)x andY:(int)y 
	     color:(NSColor *)col
{

  NSFont *font = [NSFont boldSystemFontOfSize:FONT_SIZE];
  NSDictionary *attrDict =
    [NSDictionary dictionaryWithObjectsAndKeys:
		    font, NSFontAttributeName, 
		  col, NSForegroundColorAttributeName, nil];
  [font set];

  NSString *strObj = [NSString stringWithCString:str];
  NSSize strSize = [strObj sizeWithAttributes:attrDict];	    

  NSPoint loc =
    NSMakePoint(x*FIELD_DIM + (FIELD_DIM-strSize.width)/2,
		(8-y)*FIELD_DIM + (FIELD_DIM-strSize.height)/2);
  [strObj drawAtPoint:loc withAttributes:attrDict];
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);

    // NSRect frect = [font boundingRectForFont];

    int x, y, pos;

    PSsetlinewidth(2);
    PSsetrgbcolor(0, 0, 0);

    for(pos=0; pos<=9; pos++){
	if(!(pos % 9)){
	    PSsetlinewidth(12);
	}
	else if(!(pos % 3)){
	    PSsetlinewidth(6);
	}
	else{
	    PSsetlinewidth(3);
	}

	PSmoveto(0, pos*FIELD_DIM);
	PSlineto(9*FIELD_DIM, pos*FIELD_DIM);
	PSstroke();

	PSmoveto(pos*FIELD_DIM, 0);
	PSlineto(pos*FIELD_DIM, 9*FIELD_DIM);
	PSstroke();
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
  startp = [self convertPoint:startp fromView: nil];
    
  NSWindow *win = [self window];
  NSEvent *curEvent = theEvent;

  unsigned int cmask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;

  startp.x/=(float)FIELD_DIM; startp.y/=(float)FIELD_DIM; 
  int x = (int)startp.x, y = 8-(int)startp.y;

  if([sdk fieldX:x Y:y].puzzle != -1){
    NSBeep();
    return;
  }

  int guess = [sdk fieldX:x Y:y].guess;

  NSRect box = 
    NSMakeRect(x*FIELD_DIM, (8-y)*FIELD_DIM, 
	       FIELD_DIM,  FIELD_DIM), cachebox = box;
  cachebox.origin.x -= 4;
  cachebox.origin.y -= 4;
  cachebox.size.width += 8;
  cachebox.size.height += 8;
  
  cachebox = [self convertRect:cachebox toView:nil];

  BOOL first = YES;
  
  NSDate *tick = [NSDate dateWithTimeIntervalSinceNow:TICK];

  NSBezierPath 
    *bpfilled = [NSBezierPath bezierPathWithRect:box],
    *bpstroked = [NSBezierPath bezierPathWithRect:box];

  [bpstroked setLineWidth:6.0];

  guess = 
      (guess==-1 ? 0 : (guess==8 ? -1 : guess+1));

  do {
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

    NSDate *now = [NSDate date];
    if([now laterDate:tick]==now){
      guess = 
	(guess==-1 ? 0 : (guess==8 ? -1 : guess+1));
      tick = [NSDate dateWithTimeIntervalSinceNow:TICK];
    }

    char str[2] = { 
      (guess==-1 ? '.' : '1' + guess), 
      0 };
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
  
  NSDocumentController *dc =
      [NSDocumentController sharedDocumentController];

  if(guess == -1){
    [sdk fieldptrX:x Y:y]->guess = -1;

    [self setNeedsDisplay:YES];

    [self display];
    [win flushWindow];

    [[dc currentDocument] updateChangeCount:NSChangeDone];
    return;
  }

  char str[2] = { '1' + guess, 0 };

  int nb;
  for(nb=0; nb<NBCOUNT; nb++){
    int 
      nx = [sdk fieldX:x Y:y].adj[nb].nx, 
      ny = [sdk fieldX:x Y:y].adj[nb].ny;

    if([sdk retrX:nx Y:ny]==guess){
      break;
    }
  }

  if(nb<NBCOUNT){
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

    NSDate *errpause =
      [NSDate dateWithTimeIntervalSinceNow:TICK*5];
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
  NSDragOperation
    sourceDragMask = [sender draggingSourceOperationMask];

  if([[pb types] indexOfObject:DIGIT_TYPE]!=NSNotFound){
    if(sourceDragMask & NSDragOperationCopy){
      NSString *dstr = [pb stringForType:DIGIT_TYPE];

      int newDigit;
      [[NSScanner scannerWithString:dstr] scanInt:&newDigit];

      NSPoint startp = [sender draggingLocation];
      startp = [self convertPoint:startp fromView: nil];

      startp.x/=(float)FIELD_DIM; startp.y/=(float)FIELD_DIM; 
      int x = (int)startp.x, y = 8-(int)startp.y;

      if([sdk fieldX:x Y:y].puzzle != -1){
	return NSDragOperationNone;
      }

      if(newDigit==10){
	return NSDragOperationCopy;
      }

      newDigit--;

      int nb;
      for(nb=0; nb<NBCOUNT; nb++){
	int 
	  nx = [sdk fieldX:x Y:y].adj[nb].nx, 
	  ny = [sdk fieldX:x Y:y].adj[nb].ny;

	if([sdk retrX:nx Y:ny]==newDigit){
	  break;
	}
      }

      if(nb<NBCOUNT){
	return NSDragOperationNone;
      }
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
  
  int newDigit;
  [[NSScanner scannerWithString:dstr] scanInt:&newDigit];

  NSPoint startp = [sender draggingLocation];
  startp = [self convertPoint:startp fromView: nil];

  startp.x/=(float)FIELD_DIM; startp.y/=(float)FIELD_DIM; 
  int x = (int)startp.x, y = 8-(int)startp.y;

  [sdk fieldptrX:x Y:y]->guess = 
    (newDigit==10 ? -1 : newDigit-1);

  [self setNeedsDisplay:YES];
  [self display];
  [[self window] flushWindow];

  NSDocumentController *dc =
      [NSDocumentController sharedDocumentController];
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

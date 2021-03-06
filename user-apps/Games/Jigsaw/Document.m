#import "Document.h"
#import "PieceView.h"

@interface Document (Private)

- adjacent;

- dragCluster:(BTree *)cluster offs:(CGFloat *)delta
    superview:(NSView *)sv;

- (BOOL)loadError:(NSString *)msg;
- (NSWindow*)makeWindow;

@end

static NSArray *types = nil;

@implementation Document

static NSMenu *_action_menu = nil;

+ actionMenu
{
  if(_action_menu==nil){
        NSMenu *menu = 
          [[NSMenu alloc] initWithTitle:_(@"Action")];
    
        [[menu addItemWithTitle: _(@"Scramble")
               action: @selector (scramble:) 
               keyEquivalent: @""] setTag:MENU_SCRAMBLE];
        [[menu addItemWithTitle: _(@"Verify")
               action: @selector (verify:) 
               keyEquivalent: @""] setTag:MENU_VERIFY];
        [[menu addItemWithTitle: _(@"Solve")
               action: @selector (solve:) 
               keyEquivalent: @""] setTag:MENU_SOLVE];
        
        _action_menu = menu;
        RETAIN(_action_menu);
  }

  return _action_menu;
}


static NSPanel *_stopper_panel = nil;

#define STOP_WIDTH 150
#define STOP_HEIGHT 30

+ stopperForDocument:(Document *)doc
{
    NSRect wframe;  
    NSPoint sorigin;
    if(_stopper_panel==nil){
	NSButton *_stopper;
        _stopper_panel = 
            [[NSPanel alloc]
                initWithContentRect:
                    NSMakeRect(0, 0, STOP_WIDTH, STOP_HEIGHT)
                styleMask:NSBorderlessWindowMask
                backing:NSBackingStoreBuffered
                defer:NO];
        [_stopper_panel setReleasedWhenClosed:NO];

        _stopper = [NSButton new];
        // [_stopper setTransparent:YES];
        [_stopper setTitle:@"Stop"];

        [_stopper setAction:@selector(stopSolve:)];
        
        [_stopper_panel setContentView:_stopper];
    }

    [[_stopper_panel contentView] setTarget:doc];

    wframe = [[[[doc windowControllers] objectAtIndex:0]
             window] frame];

    sorigin = NSMakePoint (wframe.origin.x+wframe.size.width/2 - STOP_WIDTH/2,
         wframe.origin.y+wframe.size.height/2 - STOP_HEIGHT/2);

    [_stopper_panel setFrameOrigin:sorigin];

    return _stopper_panel;
}

- init
{
  self = [super init];
  if (self)
    {
      if(types==nil)
	{
	  types = 
	    [NSArray 
              arrayWithObjects:@"tiff", @"TIFF",
	      @"png", @"PNG",
	      @"jpg", @"JPG",
	      @"jpeg", @"JPEG",
	      nil];
	  RETAIN(types);
	}

      solving = NO;
      done = NO;
    }
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (NSInteger)setDone:(NSInteger)flag
{
    NSInteger prev = done;

    if(prev!=flag){
        NSUInteger c, ccount = [clusters count];

        for(c=0; c<ccount; c++){
            [[clusters objectAtIndex:c]
                inorderWithInteger:flag
                sel:@selector(setDone:)];
        }

        done = flag;
    }

    return prev;
}

- (NSSize)withPadding
{
  NSSize plain;
  NSInteger padding;

  plain = NSMakeSize(0, 0);

  if (image == nil)
    return plain;

  plain = [image size];
  padding = ((NSInteger)plain.width) % PIECE_WIDTH;
  if(padding)
    plain.width += PIECE_WIDTH - padding;
    
  padding = ((NSInteger)plain.height) % PIECE_HEIGHT;
  if(padding)
    plain.height += PIECE_HEIGHT - padding;
    
  return plain;
}

- scramble:(id)sender
{
  if(solving==YES){
    NSBeep();
    return self;
  } else {

    NSMutableArray *allLeaves;
    NSInteger ind;
    PieceView *piece;
    BTree *cluster;

    NSSize desksize = [image size];
    NSInteger 
        width  = DESKTOPEXTRA/2+desksize.width, 
        height = DESKTOPEXTRA/2+desksize.height;

    NSSize padding = [self withPadding];

    width += padding.width-desksize.width;
    height += padding.height-desksize.height;

    if([clusters count]==px*py){
        for(ind=0; ind<[clusters count]; ind++){
            piece = [[clusters objectAtIndex:ind] leaf];
            
            [piece setFrameOrigin:
                       NSMakePoint(DESKTOPEXTRA/2+rand()%width,
                                   DESKTOPEXTRA/2+rand()%height)];
        }
    }
    else{
        allLeaves = [NSMutableArray array];
        for(ind=0; ind<[clusters count]; ind++){
            cluster = [clusters objectAtIndex:ind];
            [allLeaves addObjectsFromArray:[cluster leaves]];
            [cluster deallocAll];
        }
        // [clusters release];
        
        clusters = [NSMutableArray array];
        for(ind=0; ind<[allLeaves count]; ind++){
            piece = (PieceView *)[allLeaves objectAtIndex:ind];
            
            cluster = [[BTree alloc] 
                          initWithLeaf:piece];
            [piece setCluster:cluster];
            [clusters addObject:cluster];
            
            [piece setFrameOrigin:
                       NSMakePoint(DESKTOPEXTRA/2+rand()%width,
                                   DESKTOPEXTRA/2+rand()%height)];
        }
        [clusters retain];
    }

    [self setDone:NO];

    [self updateChangeCount:NSChangeDone];
    // [[view window] setDocumentEdited:YES];
    [view setNeedsDisplay:YES];

    return self;
  }
}

#define INVALID_DISPLAY_SECS 1

- verify:(id)sender
{
  if(solving==YES){
    NSBeep();
    return self;
  } else {

    NSInteger ind;
    BTree *cluster;
    PieceView **pieces;

    for(ind=0; ind<[clusters count]; ind++){
        cluster = [clusters objectAtIndex:ind];
        if((pieces = [PieceView checkCluster:cluster
		dimX:piece_width dimY:piece_height]) != NULL){
            NSBeep();
            [pieces[0] showInvalid];
            [pieces[1] showInvalid];

            [NSThread 
                sleepUntilDate:
                    [NSDate 
                        dateWithTimeIntervalSinceNow:
                            INVALID_DISPLAY_SECS]];

            [pieces[0] setNeedsDisplay:YES];
            [pieces[1] setNeedsDisplay:YES];

            return self;
        }
    }
     
    NSRunAlertPanel(@"Verify", @"No conflicting pieces.", 
                    @"Ok", nil, nil);
    return self;
  }
}

- stopSolve:(id)sender
{
    NSApplication *app = [NSApplication sharedApplication];

    solving = NO;
    [app stopModal];

    return self;
}

- solve:(id)sender
{
  NSApplication *app = [NSApplication sharedApplication];

  NSWindow *win = 
    [[[self windowControllers] objectAtIndex:0]
      window];
  NSInteger ind;
  PieceView **pieces;
  BTree *cl1, *all;
  NSPanel *sp;
  NSPoint sp_orig;
  NSModalSession solveSession = 0;
  NSPoint orig;
  NSMutableArray *processed;
  NSView *sv = nil;
  NSInteger pc;
  BOOL complete;

  [view setNeedsDisplay:YES];
  [view display];


    for(ind=0; ind<[clusters count]; ind++){
        cl1 = [clusters objectAtIndex:ind];
        if((pieces = [PieceView checkCluster:cl1
				dimX:piece_width 
				dimY:piece_height])!=NULL){
            [pieces[0] showInvalid];
            [pieces[1] showInvalid];

            [NSThread 
                sleepUntilDate:
                    [NSDate 
                        dateWithTimeIntervalSinceNow:
                            INVALID_DISPLAY_SECS]];

            [pieces[0] extractFromCluster];
            [pieces[1] extractFromCluster];

            [pieces[0] display];
            [pieces[1] display];

            ind = -1;
        }
    }

    if([clusters count]==1){
        return self;
    }

  sp = [Document stopperForDocument:self];
  sp_orig = [sp frame].origin;

  solving = YES;
  solveSession = [app beginModalSessionForWindow:sp];
  [sp setFrameOrigin:sp_orig];
  [sp display];
  [sp flushWindow];

  [view setNeedsDisplay:YES];
  [view display];
  [win flushWindow];

    // for(ind=0; ind<[clusters count]; ind++){
    //    [[clusters objectAtIndex:ind]
    //        inorderWithPointer:&allBbox
    //        sel:@selector(bbox:)];
    // }

    processed = [NSMutableArray arrayWithCapacity:[clusters count]];

    [self adjacent];

    for(ind=0; ind<[clusters count]; ind++){
        BTree *cluster = [clusters objectAtIndex:ind];
        NSMutableArray *leaves = [cluster leaves];
        PieceView *pv = [leaves objectAtIndex:0];
        NSRect bbox, frame = [pv frame];
        CGFloat delta[2];

        if(sv==nil){
	    NSRect cframe;
	    NSSize padding;
            sv = [pv superview];

            cframe = [sv frame];
            padding = [self withPadding];

            orig.x = (cframe.size.width-padding.width)/2;
            orig.y = (cframe.size.height-padding.height)/2;
        }

        delta[0] = -frame.origin.x +
            orig.x + PIECE_WIDTH*[pv x];
        delta[1] = -frame.origin.y +
            orig.y + PIECE_HEIGHT*[pv y];

        if(!(delta[0]==0.0 && delta[1]==0.0)){
            [self dragCluster:cluster offs:delta superview:sv];

            bbox = NSMakeRect(0, 0, 0, 0);
            [cluster inorderWithPointer:&bbox
                     sel:@selector(bbox:)];
            [cluster inorderWithPointer:delta
                     sel:@selector(shiftView:)];

            [sv displayRect:bbox];
            bbox.origin.x += delta[0];
            bbox.origin.y += delta[1];
            [sv displayRect:bbox];
        }

        // [[sv window] flushWindow];

        [processed addObject:cluster];

        if([app runModalSession:solveSession] != 
           NSRunContinuesResponse){
          break;
        }
    }


    [sp orderOut:self];
    [app endModalSession:solveSession];

    pc = [processed count];
    complete = (ind==[clusters count] ? YES : NO);


    // build a fairly balanced tree
    while([processed count] > 1){
      BTree 
          *cl1 = [processed objectAtIndex:0],
          *cl2 = [processed objectAtIndex:1],
          *newCluster;

      // clusters are already adjacent
      newCluster = 
        [[BTree alloc] 
          initWithPairFirst:cl1 andSecond:cl2];

      // prepend
      [processed removeObjectAtIndex:0];
      [processed replaceObjectAtIndex:0 withObject:newCluster];
    }

    all = [processed objectAtIndex:0];
    [all inorderWithPointer:(void *)all
         sel:@selector(setCluster:)];

    [clusters 
      replaceObjectsInRange:
        NSMakeRange(0, pc) withObjectsFromArray:processed];

    if(complete==YES){
        [self setDone:YES];
        [sv setNeedsDisplay:YES];
    };
    
    solving = NO;
    [sender setTitle:_(@"Solve")];

    [self updateChangeCount:NSChangeDone];
    // [[view window] setDocumentEdited:YES];
    return self;
}

- (NSMutableArray *)clusters
{
    return clusters;
}


- (NSData *)dataRepresentationOfType:(NSString *)aType 
{
    NSString *msg;

    if([aType isEqualToString:DOCTYPE]){
        NSString *trees = @"", *pieces = @"", *all;
        NSInteger clind, pind;
        BTree *cluster; PieceView *piece;
        NSMutableArray *leaves;

        for(clind=0; clind<[clusters count]; clind++){
            cluster = [clusters objectAtIndex:clind];
            trees = [trees stringByAppendingString:
                                 [cluster toString]];
            
            leaves = [cluster leaves];
            for(pind=0; pind<[leaves count]; pind++){
                piece = [leaves objectAtIndex:pind];
                pieces = [pieces stringByAppendingString:
                                     [piece toString]];
            }
        }

        [[view window] saveFrameUsingName:[self fileName]];

        all = [NSString stringWithFormat:@"%@\n%d %d %d %d %d\n",
                        nameOfImageFile, 
			piece_width, piece_height,
			px, py, [clusters count]];

        all = [all stringByAppendingString:trees];
        all = [all stringByAppendingString:pieces];
        return [all dataUsingEncoding:NSASCIIStringEncoding];
    }
    else{
        msg = [NSString stringWithFormat: @"Unknown type: %@", 
                        [aType uppercaseString]];
        NSRunAlertPanel(@"Alert", msg, @"Ok", nil, nil);
        return nil;
    }
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType 
{
    NSString *msg;
    NSSize size;
    NSInteger x, y;
    PieceView *piece;
    BTree *cluster;

    NSInteger horizontal[DIM_MAX][DIM_MAX];
    NSInteger vertical[DIM_MAX][DIM_MAX];

    if([aType isEqualToString:DOCTYPE]){
        NSArray *lines = 
            [[NSString stringWithCString:[data bytes] 
                       length:[data length]] 
                componentsSeparatedByString:@"\n"];
        NSEnumerator *en = [lines objectEnumerator];
        NSString *line;
        NSScanner *scanner;
        NSInteger clcount, clind, lind;
        NSMutableDictionary *pdict;
        NSInteger x, y, ktag, posx, posy;
        PTYPE left, right, lower, upper;

        image = nil;
        clusters = nil;

        if((line = [en nextObject])==nil){
            return [self loadError:@"File name is missing"];
        }
        if ((image = [[NSImage alloc] 
                         initWithContentsOfFile:line])==nil){
            msg = [NSString stringWithFormat: @"Load failed (IMAGE)", 
                            data];
            return [self loadError:msg];
        }
        nameOfImageFile = [line copy];

        if((line = [en nextObject])==nil){
            return [self loadError:@"Image dimensions missing"];
        }
        scanner = [NSScanner scannerWithString:line];
        if([scanner scanInteger:&piece_width]==NO ||
	   [scanner scanInteger:&piece_height]==NO ||
	   [scanner scanInteger:&px]==NO ||
           [scanner scanInteger:&py]==NO ||
           [scanner scanInteger:&clcount]==NO ||
           px<DIM_MIN || px>DIM_MAX-1 ||
           py<DIM_MIN || py>DIM_MAX-1 ||
           clcount<1 || clcount>px*py){
            return [self loadError:
                             @"Image dimensions/clusters out of range"];
        }

        clusters = [NSMutableArray arrayWithCapacity:clcount];
        for(clind=0; clind<clcount; clind++){
            if((cluster = [BTree fromLines:en])==nil){
                msg = [NSString stringWithFormat: 
                                    @"Read failure  (cluster %"PRIiPTR"/%"PRIiPTR")", 
                                clind, clcount];
                return [self loadError:msg];
            }
            [clusters addObject:cluster];
        }

        pdict = [NSMutableDictionary dictionaryWithCapacity:px*py];
        for(lind = 0; lind<px*py; lind++){
            if((line = [en nextObject])==nil){
                msg = [NSString stringWithFormat: 
                                    @"EOF  (piece %d/%d)", 
                                lind, px*py];
                return [self loadError:msg];
            }

            scanner = [NSScanner scannerWithString:line];
            if([scanner scanInteger:&ktag]==NO ||
               [scanner scanInteger:&x]==NO ||
               [scanner scanInteger:&y]==NO ||
               [scanner scanInteger:&left]==NO ||
               [scanner scanInteger:&right]==NO ||
               [scanner scanInteger:&upper]==NO ||
               [scanner scanInteger:&lower]==NO ||
               [scanner scanInteger:&posx]==NO ||
               [scanner scanInteger:&posy]==NO){
                msg = [NSString stringWithFormat: 
                                    @"missing fields  (piece %d/%d)", 
                                lind, px*py];
                return [self loadError:msg];
            }

            piece = [[PieceView alloc]
                        initWithImage:image
			dimX:piece_width
			dimY:piece_height
                        loc:NSMakePoint(posx, posy)
                        posX:x outOf:px
                        posY:y outOf:py
                        left:left
                        right:right
                        upper:upper
                        lower:lower];
            [piece setDocument:self];
            [pdict setObject:piece 
                   forKey:[NSNumber numberWithInt:ktag]];
        }

        for(clind=0; clind<[clusters count]; clind++){
            cluster = [clusters objectAtIndex:clind];
            [cluster substituteLeaves:pdict];
            [cluster
                inorderWithPointer:(void *)cluster
                sel:@selector(setCluster:)]; 
        }

        [clusters retain];

        done = NO;
        NSLog(@"%d: read %" PRIuPTR " cluster(s)", __LINE__, [clusters count]);
        [self setDone:([clusters count]==1 ? YES : NO)];

        return YES;
    }
    else if([types containsObject:aType]){
	NSInteger dim_alert;
        if (!(image = [[NSImage alloc] initWithData:data])){
            NSRunAlertPanel(@"Alert", @"Load failed (IMAGE)",
                            @"Ok", nil, nil);
            return NO;
        }

	dim_alert = NSRunAlertPanel(@"What size pieces?",
			    @"Choose a size.",
			    @"Small", @"Medium", @"Large");
	
	if(dim_alert==NSAlertDefaultReturn){
	    piece_width = PIECE_WIDTH_SMALL;
	    piece_height = PIECE_HEIGHT_SMALL;
	}
	else if(dim_alert==NSAlertAlternateReturn){
	    piece_width = PIECE_WIDTH_MEDIUM;
	    piece_height = PIECE_HEIGHT_MEDIUM;
	}
	else{
	    piece_width = PIECE_WIDTH_LARGE;
	    piece_height = PIECE_HEIGHT_LARGE;
	}

        size = [image size];

        px = (size.width)/PIECE_WIDTH;
        if(((NSInteger)size.width)%PIECE_WIDTH){
            px++;
        }

        py = (size.height)/PIECE_HEIGHT;
        if(((NSInteger)size.height)%PIECE_HEIGHT){
            py++;
        }

        if(px<DIM_MIN || py<DIM_MIN){
            [image dealloc];
            NSRunAlertPanel(@"Alert", @"Image too small (IMAGE)",
                            @"Ok", nil, nil);
            return NO;
        }
        if(px>DIM_MAX-1 || py>DIM_MAX-1){
            [image dealloc];
            NSRunAlertPanel(@"Alert", @"Image too large (IMAGE)", 
                            @"Ok", nil, nil);
            return NO;
        }

        // horizontal 
        for(y=0; y<py; y++){
            horizontal[0][y] = BORDER;
            for(x=1; x<px; x++){
                horizontal[x][y] = (rand()%2 ? INNER : OUTER);
            }
            horizontal[px][y] = BORDER;
        }
        
        // vertical
        for(x=0; x<px; x++){
            vertical[x][0] = BORDER;
            for(y=1; y<py; y++){
                vertical[x][y] = (rand()%2 ? INNER : OUTER);
            }
            vertical[x][py] = BORDER;
        }

        clusters = [NSMutableArray arrayWithCapacity:px*py];
        for(y=0; y<py; y++){
            for(x=0; x<px; x++){
                piece = [[PieceView alloc]
                            initWithImage:image
			    dimX:piece_width dimY:piece_height
                            loc:NSMakePoint(DESKTOPEXTRA+x*PIECE_WIDTH, 
                                            DESKTOPEXTRA+y*PIECE_HEIGHT)
                            posX:x outOf:px
                            posY:y outOf:py
                            left:horizontal[x][y]
                            right:(-horizontal[x+1][y])
                            upper:(-vertical[x][y+1])
                            lower:vertical[x][y]];
                [piece setDocument:self];

                cluster = [[BTree alloc] initWithLeaf:piece];
                [piece setCluster:cluster];
                [clusters addObject:cluster];
            }
        }

        [clusters retain];
        [self scramble:self];
    }
    else{
        msg = [NSString stringWithFormat: @"Unknown type: %@", 
                        [aType uppercaseString]];
        NSRunAlertPanel(@"Alert", msg, @"Ok", nil, nil);
        return NO;
    }

    return YES;
}

- (void) makeWindowControllers
{
  NSWindowController *controller;
  NSWindow *win = [self makeWindow];
  
  controller = [[NSWindowController alloc] initWithWindow: win];  
  [self addWindowController: controller];
  RELEASE(controller);

  // We have to do this ourself, as there is currently no nib file
  // [controller setShouldCascadeWindows:NO];
  [self windowControllerDidLoadNib: controller];

  [win setFrameAutosaveName:[self fileName]];
  if([win setFrameUsingName:[self fileName]]==NO){
      [win center];
  }
  RELEASE (win);
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController;
{
  [super windowControllerDidLoadNib:aController];
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
    if([types containsObject:docType]){
        nameOfImageFile = [fileName copy];
    }

    return [super readFromFile:fileName ofType:docType];
}

@end

@implementation Document (Private)

- adjacent
{
    BTree *cl1, *cl2;
    unsigned c1, c2, l1, l2, ccount = [clusters count];
    
    NSMutableArray 
        *allLeaves = [NSMutableArray arrayWithCapacity:px*py],
        *curLeaves;

    for(c1=0; c1<ccount-1; c1++){
        BOOL success = NO;
        cl1 = [clusters objectAtIndex:c1];
        [allLeaves addObjectsFromArray:[cl1 leaves]];

        for(c2=c1+1; c2<ccount; c2++){
            cl2 = [clusters objectAtIndex:c2];
            curLeaves = [cl2 leaves];

            for(l1=0; l1<[curLeaves count]; l1++){
                PieceView *pv1 = [curLeaves objectAtIndex:l1];
                NSInteger x1 = [pv1 x], y1 = [pv1 y];

                for(l2=0; l2<[allLeaves count]; l2++){
                    PieceView *pv2 = [allLeaves objectAtIndex:l2];
                    NSInteger x2 = [pv2 x], y2 = [pv2 y];
                    
                    if((x1==x2 && (y1==y2+1 || y1==y2-1)) ||
                       (y1==y2 && (x1==x2+1 || x1==x2-1))){
                        success = YES;
                        [clusters 
                            exchangeObjectAtIndex:c1+1
                            withObjectAtIndex:c2];

                        goto DONE;
                    }
                }
            }
        }

    DONE:
        if(success==NO){
            NSString *fmt = 
                @"could not find adjacent cluster for cluster %d";
            [NSException 
                raise:NSGenericException format:fmt, c1];
        }
    }
    
    return self;
}

#define TICK 3
#define DRAGINTERVAL (0.01)

- dragCluster:(BTree *)cluster offs:(CGFloat *)delta
    superview:(NSView *)sv
{
    NSWindow *win = [sv window];
    NSRect bbox = { {0, 0}, {0, 0} }, wbbox;
    NSPoint orig;
    BOOL first = YES;
    NSInteger step, steps;
    CGFloat dx, dy, cur[2];

    [cluster inorderWithPointer:&bbox
             sel:@selector(bbox:)];
    orig = bbox.origin;

    #define ABSF(_v) ((_v)>0 ? (_v) : -(_v))
    if(ABSF(delta[0])>ABSF(delta[1])){
        if(delta[0]<0){
            steps = -delta[0];
            dx = -1;
        }
        else{
            steps = delta[0];
            dx = 1;
        }
        dy = delta[1]/(CGFloat)steps;
    }
    else{
        if(delta[1]<0){
            steps = -delta[1];
            dy = -1;
        }
        else{
            steps = delta[1];
            dy = 1;
        }
        dx = delta[0]/(CGFloat)steps;
    }

    [sv lockFocus];
    for(step = 0; step < steps; step+=TICK){
        if(first==NO){
            [win restoreCachedImage];
        }
        first = NO;

        cur[0] = step*dx;
        cur[1] = step*dy;

        bbox.origin.x = orig.x + cur[0];
        bbox.origin.y = orig.y + cur[1];

        wbbox = [sv convertRect:bbox toView:nil];

        [win cacheImageInRect:wbbox];
        [cluster inorderWithPointer:cur
                 sel:@selector(outline:)];
        [win flushWindow];
    }

    [win restoreCachedImage];
    [win flushWindow];

    [sv unlockFocus];

    return self;
}

- (NSWindow*)makeWindow
{
  NSWindow *window;
  NSRect frame;
  NSInteger m = (NSTitledWindowMask |  
       NSResizableWindowMask |
       NSClosableWindowMask | 
           NSMiniaturizableWindowMask);

  NSInteger clind;
  BTree *cluster;
  NSScrollView *scroller;
  NSSize scrollSize, desktop, initialSize;
  NSString *fname, *ext;

  frame.origin.x = 0;
  frame.origin.y = 0;
  if (image != nil)
    frame.size = [image size];
  else
    frame.size = NSMakeSize(0, 0);
  frame.size.width  += 2*(BOUNDARY+DESKTOPEXTRA);
  frame.size.height += 2*(BOUNDARY+DESKTOPEXTRA);

  desktop = frame.size;

  view  = [NSView alloc];
  [view initWithFrame:frame];
  for(clind=0; clind<[clusters count]; clind++){
      cluster = [clusters objectAtIndex:clind];
      [cluster inorderWithTarget:view
               sel:@selector(addSubview:)];
  }
  [view setMenu:[Document actionMenu]];

  initialSize = NSMakeSize((desktop.width<DESKTOPMAX ?
                  desktop.width : DESKTOPMAX),
                 (desktop.height<DESKTOPMAX ?
                  desktop.height : DESKTOPMAX));

  scrollSize = [NSScrollView frameSizeForContentSize:initialSize
                    hasHorizontalScroller:YES
                    hasVerticalScroller:YES
                    borderType:NSLineBorder];
  scroller = [[NSScrollView alloc] 
                 initWithFrame:NSMakeRect(0, 0, 
                                          scrollSize.width,
                                          scrollSize.height)];
  [scroller setHasHorizontalScroller:YES];
  [scroller setHasVerticalScroller:YES];
  [scroller setDocumentView:view];

  frame = [scroller frame];

  window = [[NSWindow alloc] initWithContentRect:frame 
                             styleMask:m                   
                             backing: NSBackingStoreRetained 
                             defer:YES];
  [window setMinSize:NSMakeSize(DESKTOPEXTRA, DESKTOPEXTRA)];
  // [window setReleasedWhenClosed:NO];
  [window setDelegate:self];

  // [window setFrame:frame display:YES];

  desktop.width  += scrollSize.width  -initialSize.width;
  desktop.height += scrollSize.height -initialSize.height;
  [window setMaxSize:desktop];

  [window setContentView:scroller];
  [window setReleasedWhenClosed:YES];

  // RELEASE(view);

  [window orderFrontRegardless];
  [window makeKeyWindow];
  [window display];

  [self setFileType:DOCTYPE];
  
  fname = [self fileName]; 
  ext = [fname pathExtension];
  if([types containsObject:ext]){
      NSArray *docs = 
          [[NSDocumentController sharedDocumentController]
              documents];
      NSString *result, *fixIt = 
          [fname substringToIndex:
                     ([fname length]-[ext length]-1)];
      NSFileManager *manager = [NSFileManager defaultManager];
      NSInteger comp, index = 1;

      while(index){
          result = [fixIt stringByAppendingFormat:@"-%u.%@", 
                          index, DOCTYPE];

          for(comp=0; comp<[docs count]; comp++){
              if([[[docs objectAtIndex:comp] fileName]
                     isEqual:result]){
                  break;
              }
          }

          if(comp==[docs count] && 
             [manager fileExistsAtPath:result]==NO){
              break;
          }
          index++;
      }
      
      [self setFileName:result];
  }
  NSLog(@"file name %@\n",  [self fileName]);

  return window;
}

- (BOOL)loadError:(NSString *)msg
{
    if(image!=nil){
        [image dealloc];
    }
    if(clusters!=nil){
        [clusters dealloc];
    }
    NSRunAlertPanel(@"Alert", msg, @"Ok", nil, nil);
    return NO;
}

@end

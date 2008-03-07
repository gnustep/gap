#import "GRDocView.h"
#import "Graphos.h"
#import "GRFunctions.h"
#import "GRBezierPath.h"
#import "GRBox.h"
#import "GRBoxEditor.h"
#import "GRText.h"
#import "GRTextEditor.h"
#import "GRPropsEditor.h"


float zFactors[9] = {0.25, 0.5, 1, 1.5, 2, 3, 4, 6, 8};

@implementation GRDocView


- (id)initWithFrame:(NSRect)aRect
{
    NSLog (@"initing doc view with win");
    pageRect = NSMakeRect(0, 0, 695, 942);
    a4Rect = NSMakeRect(50, 50, 595, 842);
    zmdRect = NSMakeRect(50, 50, 595, 842);

    self = [super initWithFrame: pageRect];
    if(self)
    {
        NSImage *img = [NSImage imageNamed: @"blackarrow.tiff"];
        NSCursor *cur = [[NSCursor alloc] initWithImage: img hotSpot: NSMakePoint(0, 0)];
        [cur setOnMouseEntered: YES];
        [cur setOnMouseExited: YES];
        [self addTrackingRect: [self frame]
                        owner: cur userData: NULL
                 assumeInside: YES];


        objects = [[NSMutableArray alloc] initWithCapacity: 1];
        delObjects = [[NSMutableArray alloc] initWithCapacity: 1];
        undoManager = [[NSUndoManager alloc] init];
        doItAgain = nil;
        shiftclick = NO;
        altclick = NO;
        ctrlclick = NO;
        zIndex = 2;
        zFactor = zFactors[zIndex];
        NSLog (@"inited doc view with win");
    }
    return self;
}

- (void)dealloc
{
    [objects release];
    [delObjects release];
    [undoManager release];
    [super dealloc];
}

- (NSDictionary *) objectDictionary
{
    NSMutableDictionary *objsdict;
    NSString *str;
    id obj;
    int i, p = 0, t = 0;

    objsdict = [NSMutableDictionary dictionaryWithCapacity: 1];
    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBezierPath class]])
        {
            str = [NSString stringWithFormat: @"path%i", p];
            p++;
        } else
        {
            str = [NSString stringWithFormat: @"text%i", t];
            t++;
        }
        [objsdict setObject: [obj objectDescription] forKey: str];
    }
    return [NSDictionary dictionaryWithDictionary: objsdict];
}

// FIXME I'm not sure if this is necessary
// it can probably be deleted. need to test.
/*
 - (void) print: (id)sender
 {
     NSString *str, *fpath, *prstr, *fname;
     NSArray *fnames;
     id obj;
     int i;

     prstr = [NSString stringWithFormat: @"%%!PS-Adobe-2.0 EPSF-1.2 \
 %%%%Creator: GDraw 0.1\n\
 %%%%For: %@\n\
 %%%%Title: %@\n\
 %%%%CreationDate: %@\n\
 %%%%Pages: 1\n\
 %%%%Copies: 1\n\
 %%%%DocumentSuppliedResources: procset GDraw_Procset 0 0 \
 ", NSFullUserName(), docName, [[NSDate date] description]];

     fnames = [self usedFonts];
     if([fnames count]) {
         for(i = 0; i < [fnames count]; i++)
             prstr = [prstr stringByAppendingFormat: @"%%%%+ font %@\n",
                 [fnames objectAtIndex: i]];
     }

     prstr = [prstr stringByAppendingFormat: @"%%%%BoundingBox: %i %i %i %i\n",
         (int)a4Rect.origin.x, (int)a4Rect.origin.y,
         (int)a4Rect.size.width, (int)a4Rect.size.height];

     prstr = [prstr stringByAppendingString:
         @"%%EndComments\n\n%%BeginResource: procset GDraw_Procset 0 0\n"];

     fpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Resources/GDProcSet"];
     prstr = [prstr stringByAppendingString:
         [NSString stringWithContentsOfFile: fpath]];

     prstr = [prstr stringByAppendingString: @"%%EndResource\n\n"];

     if([fnames count]) {
         for(i = 0; i < [fnames count]; i++) {
             fname = [fnames objectAtIndex: i];
             prstr = [prstr stringByAppendingFormat: @"%%%%BeginResource: font %@\n\n", fname];
             prstr = [prstr stringByAppendingString:
                 [[Draw sharedgdraw] pfaDescriptionOfFont: fname]];
             prstr = [prstr stringByAppendingString: @"\n%%EndResource\n\n"];
         }
     }

     prstr = [prstr stringByAppendingString:
   @"\n\n%%BeginProlog\n%%EndProlog\n%%Page: 1 1\nGDraw_Procset begin\n\n"];

     for(i = 0; i < [objects count]; i++) {
         obj = [objects objectAtIndex: i];
         str = [obj psDescription];
         if(str)
             prstr = [prstr stringByAppendingString: str];
     }
     prstr = [prstr stringByAppendingString: @"\nshowpage\n\n%%Trailer\n"];
     [prstr writeToFile: @"/tmp/gdraw.ps" atomically: NO];
 }
 */

- (NSArray *)usedFonts
{
    NSMutableArray *usedfonts;
    NSString *fname;
    id obj;
    int i, j;
    BOOL exist;

    usedfonts = [NSMutableArray arrayWithCapacity: 1];
    for(i = 0; i < [objects count]; i++)
    {
        exist = NO;
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRText class]])
        {
            fname = [obj fontName];
            for(j = 0; j < [usedfonts count]; j++)
            {
                if([[usedfonts objectAtIndex: j] isEqualToString: fname])
                {
                    exist = YES;
                    break;
                }
            }
            if(!exist)
                [usedfonts addObject: fname];
        }
    }

    return usedfonts;
}

- (BOOL)createObjectsFromDictionary:(NSDictionary *)dict
{
    NSArray *keys;
    NSString *key;
    NSDictionary *objdict;
    GRBezierPath *bzPath;
    GRText *gGRText;
    int i;

    if(!dict)
        return NO;

    keys = [dict allKeys];
    for(i = 0; i < [keys count]; i++)
    {
        key = [keys objectAtIndex: i];
        objdict = [dict objectForKey: key];
        if(!objdict)
            return NO;
        // ### fixme extend for other objects
        if([key rangeOfString: @"path"].length)
        {
            bzPath = [[GRBezierPath alloc] initFromData: objdict
                                                         inView: self zoomFactor: zFactor];
            [objects addObject: bzPath];
            [bzPath release];
            edind = [objects count] -1;
        } else
        {
            gGRText = [[GRText alloc] initFromData: objdict
                                            inView: self zoomFactor: zFactor];
            [objects addObject: gGRText];
            [gGRText release];
        }
    }
    return YES;
}

- (void)addPath
{
    GRBezierPath *path;

    path = [[GRBezierPath alloc] initInView: self zoomFactor: zFactor];
    [objects addObject: path];
    [path release];
    edind = [objects count] -1;
}

- (void)addTextAtPoint:(NSPoint)p
{
    GRText *gdtxt;
    int i;
    
    NSLog(@"AddTextAtPoint");
    for(i = 0; i < [objects count]; i++)
        [[[objects objectAtIndex: i] editor] unselect];

    gdtxt = [[GRText alloc] initInView: self atPoint: p
                            zoomFactor: zFactor openEditor: YES];
    [objects addObject: gdtxt];
    [[gdtxt editor] select];
    [gdtxt release];
    [self setNeedsDisplay: YES];
    // ####	[myWin setSaved: NO];
}

- (void)addBoxAtPoint:(NSPoint)p
{
    GRBoxEditor *box;
    int i;

    NSLog(@"AddBoxtAtPoint");
    for(i = 0; i < [objects count]; i++)
        [[[objects objectAtIndex: i] editor] unselect];

    box = [[GRBox alloc] initInView: self atPoint: p
                            zoomFactor: zFactor];
    [objects addObject: box];
    [[box editor] select];
    [box release];
    [self setNeedsDisplay: YES];
}

- (NSArray *)duplicateObjects:(NSArray *)objs andMoveTo:(NSPoint)p
{
    id obj, duplObj;
    NSMutableArray *duplObjs;
    int i;

    duplObjs = [NSMutableArray arrayWithCapacity: 1];

    for(i = 0; i < [objs count]; i++) {
        obj = [objs objectAtIndex: i];
        // ##### FIXME in case of superclass
        if([obj isKindOfClass: [GRBezierPath class]])
            duplObj = [(GRBezierPath *)obj duplicate];
        else if ([obj isKindOfClass: [GRBox class]])
            duplObj = [(GRBox *)obj duplicate];
        else
            duplObj = [(GRText *)obj duplicate];
        [[obj editor] unselect];
        [duplObj selectAsGroup];
        [duplObj moveAddingCoordsOfPoint: p];
        [objects addObject: duplObj];
        [duplObjs addObject: duplObj];
    }
    edind = [objects count] -1;
    [self setNeedsDisplay: YES];

    [doItAgain setArgument: &duplObjs atIndex: 2];
    [doItAgain setArgument: &p atIndex: 3];
    [doItAgain retainArguments];

    // ####	[myWin setSaved: NO];
    return duplObjs;
}

- (NSArray *)updatePrintInfo: (NSPrintInfo *)pi;
{
    pageRect = NSMakeRect(0,0,[pi paperSize].width, [pi paperSize].height);
    a4Rect = NSMakeRect([pi leftMargin], [pi bottomMargin],
             pageRect.size.width-([pi leftMargin]+[pi rightMargin]),
             pageRect.size.height-([pi topMargin]+[pi bottomMargin]));
    
    zmdRect = a4Rect;
    zIndex = 2;
    zFactor = zFactors[zIndex];
                                                          
    [self setFrame: pageRect];
    [self setNeedsDisplay:YES];
}
                                                              
- (void)deleteSelectedObjects
{
    id obj;
    NSMutableArray *deleted;
    int i, count;

    deleted = [NSMutableArray arrayWithCapacity: 1];

    count = [objects count];
    for(i = 0; i < count; i++)
    {
        obj = [objects objectAtIndex: i];
        if([[obj editor] isGroupSelected])
        {
            [deleted addObject: obj];
            [objects removeObject: obj];
            count--;
            i--;
        }
    }
    if([deleted count])
    {
        [delObjects addObject: deleted];
        // ###		[myWin setSaved: NO];
    }
    [self setNeedsDisplay: YES];

    PREPAREUNDO(self, undoDeleteObjects);
}

- (void)undoDeleteObjects
{
    NSMutableArray *deleted;
    id obj;
    int i, index, count;

    for(i = 0; i < [objects count]; i++)
        [[[objects objectAtIndex: i] editor] unselect];

    if([delObjects count])
    {
        index = [delObjects count] -1;
        deleted = [delObjects objectAtIndex: index];
        count = [deleted count];
        // #### this self-modifying for end looks very crappy. needs a rewrite
        for(i = 0; i < count; i++)
        {
            obj = [deleted objectAtIndex: i];
            [objects addObject: obj];
            [deleted removeObject: obj];
            count--;
            i--;
        }
        [delObjects removeObjectAtIndex: index];
        // ####		[myWin setSaved: NO];
    }
    [self setNeedsDisplay: YES];
}

- (void)startDrawingAtPoint:(NSPoint)p
{
    NSEvent *nextEvent;
    GRBezierPath *bzpath;
    id obj;
    BOOL isneweditor = YES;
    int i;

    // #### [myWin setSaved: NO];
    for(i = 0; i < [objects count]; i++) {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBezierPath class]])
            if(![[obj editor] isdone])
                isneweditor = NO;
    }

    if(isneweditor)
        for(i = 0; i < [objects count]; i++)
            [[[objects objectAtIndex: i] editor] unselect];

    nextEvent = [[self window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    [self verifyModifiersOfEvent: nextEvent];

    if([nextEvent type] != NSLeftMouseDragged)
    {
        if(isneweditor)
        {
            [self addPath];
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            [bzpath addControlAtPoint: p];
            [self setNeedsDisplay: YES];
            return;
        } else
        {
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            if(shiftclick)
                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [bzpath addLineToPoint: p];
            [self setNeedsDisplay: YES];
            return;
        }
    } else
    {
        if(isneweditor)
        {
            [self addPath];
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            [bzpath addControlAtPoint: p];
        } else
        {
            bzpath = [objects objectAtIndex: edind];
            [[bzpath editor] selectForEditing];
            if(shiftclick)
                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [bzpath addControlAtPoint: p];
        }
        [self setNeedsDisplay: YES];

        do
        {
            p = [nextEvent locationInWindow];
            p = [self convertPoint: p fromView: nil];
            if(shiftclick)
                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);

            [bzpath addCurveWithBezierHandlePosition: p];

            [self setNeedsDisplay: YES];

            nextEvent = [[self window] nextEventMatchingMask:
                NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [self verifyModifiersOfEvent: nextEvent];
        } while([nextEvent type] != NSLeftMouseUp);

        [bzpath confirmNewCurve];
        [self setNeedsDisplay: YES];
    }
}

- (void)selectObjectAtPoint:(NSPoint)p
{
    id obj;
    NSMutableArray *objs;
    int i;

    objs = [NSMutableArray arrayWithCapacity: 1];

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBezierPath class]])
        {
            if([obj onPathBorder: p])
                [[obj editor] selectAsGroup];
            else
                if(!shiftclick)
                    [[obj editor] unselect];
        } else
        {
            if([obj pointInBounds: p])
                [[obj editor] select];
            else if(!shiftclick)
                [[obj editor] unselect];
        }
    }

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([[obj editor] isGroupSelected])
            [objs addObject: obj];
    }

    [self setNeedsDisplay: YES];

    if([objs count])
        [self moveSelectedObjects: objs startingPoint: p];
}

- (void)editPathAtPoint:(NSPoint)p
{
    id obj;
    int i;

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBezierPath class]])
        {
            if([obj onPathBorder: p])
            {
                [[obj editor] selectForEditing];
                [self setNeedsDisplay: YES];
                [self moveControlPointOfEditor: [obj editor] toPoint: p];
                return;
            } else
            {
                if([self moveBezierHandleOfEditor: [obj editor] toPoint: p])
                    return;
                else
                    [[obj editor] unselect];
            }
        } else
        {
            [[obj editor] unselect];
        }
    }
    [self setNeedsDisplay: YES];
}

- (void)editTextAtPoint:(NSPoint)p
{
    id obj;
    int i;

    for(i = 0; i < [objects count]; i++)
        [[[objects objectAtIndex: i] editor] unselect];

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRText class]])
        {
            if([obj pointInBounds: p])
            {
                [[obj editor] select];
                [self setNeedsDisplay: YES];
                [obj edit];
                // ####				[myWin setSaved: NO];
                return;
            }
        }
    }
    [self setNeedsDisplay: YES];
}

- (void)editSelectedText
{
    id obj;
    int i;

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRText class]]) {
            if([obj isSelect]) {
                [obj edit];
                // ####				[myWin setSaved: NO];
            }
        }
    }
}

- (void)moveSelectedObjects:(NSArray *)objs startingPoint:(NSPoint)startp
{
    NSEvent *nextEvent;
    NSArray *moveobjs = nil;
    id obj;
    NSPoint p, op, diffp;
    BOOL dupl = NO;
    int i;

    nextEvent = [[self window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([nextEvent type] == NSLeftMouseDragged)
    {
        // ####		[myWin setSaved: NO];
        [self verifyModifiersOfEvent: nextEvent];
        op.x = startp.x;
        op.y = startp.y;

        do
        {
            p = [nextEvent locationInWindow];
            p = [self convertPoint: p fromView: nil];
            if(shiftclick)
                p = pointApplyingCostrainerToPoint(p, startp);

            if(altclick && !dupl)
            {
                moveobjs = [self duplicateObjects: objs andMoveTo: NSMakePoint(0, 0)];
                dupl = YES;
            } else if(!moveobjs)
            {
                moveobjs = [NSArray arrayWithArray: objs];
            }

            diffp.x = p.x - op.x;
            diffp.y = p.y - op.y;
            for(i = 0; i < [moveobjs count]; i++)
            {
                obj = [moveobjs objectAtIndex: i];
                [obj moveAddingCoordsOfPoint: diffp];
            }
            op.x = p.x;
            op.y = p.y;
            [self setNeedsDisplay: YES];
            nextEvent = [[self window] nextEventMatchingMask:
                NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [self verifyModifiersOfEvent: nextEvent];
        } while([nextEvent type] != NSLeftMouseUp);

        if(dupl)
        {
            diffp.x = p.x - startp.x;
            diffp.y = p.y - startp.y;
            [self prepareDoItAgainWithSelector: @selector(duplicateObjects:andMoveTo:)
                                         owner: self target: self , &moveobjs, &diffp, nil];
        } else
        {
            diffp.x = startp.x - p.x;
            diffp.y = startp.y - p.y;
            PREPAREUNDO(self, undoMoveObjects: [moveobjs retain] moveBackTo: diffp);
        }
    }
}

- (void)undoMoveObjects:(NSArray *)objs moveBackTo:(NSPoint)p
{
    id obj;
    int i;

    for(i = 0; i < [objects count]; i++)
        [[[objects objectAtIndex: i] editor] unselect];

    for(i = 0; i < [objs count]; i++)
    {
        obj = [objs objectAtIndex: i];
        [obj selectAsGroup];
        [obj moveAddingCoordsOfPoint: p];
    }
    [self setNeedsDisplay: YES];
    // ##### [myWin setSaved: NO];
}

- (BOOL)moveControlPointOfEditor:(GRBezierPathEditor *)editor toPoint:(NSPoint)pos
{
    NSPoint p;

    p = [editor moveControlAtPoint: pos];
    if(p.x == pos.x && p.y == pos.y)
        return NO;

    PREPAREUNDO(editor, moveControlAtPoint: p toPoint: pos);

    [self setNeedsDisplay: YES];
    // #####	[myWin setSaved: NO];
    return YES;
}

- (BOOL)moveBezierHandleOfEditor:(GRBezierPathEditor *)editor toPoint:(NSPoint)pos
{
    NSPoint p;

    p = [editor moveBezierHandleAtPoint: pos];
    if(p.x == pos.x && p.y == pos.y)
        return NO;

    PREPAREUNDO(editor, moveBezierHandleAtPoint: p toPoint: pos);

    [self setNeedsDisplay: YES];
    // #####	[myWin setSaved: NO];
    return YES;
}

- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split
{
    id obj;
    int i;

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBezierPathEditor class]])
        {
            if([obj onPathBorder: p])
            {
                [obj selectForEditing];
                [obj subdividePathAtPoint: p splitIt: split];
                // #####				[myWin setSaved: NO];
                break;
            }
        }
    }
}

- (void)inspectObject:(id)sender
{
    NSWindow *epwin;
    GRPropsEditor *propsEditor;
    unsigned int style = NSTitledWindowMask;
    NSMutableDictionary *objProps = nil;
    NSDictionary *newProps;
    id obj;
    NSNumber *num;
    float *color, newcolor[4];
    int i, count, result;

    if(![objects count])
        return;

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([[obj editor] isSelect]) {
            objProps = [NSMutableDictionary dictionaryWithCapacity: 1];
            if([obj isKindOfClass: [GRBezierPath class]])
            {
                [objProps setObject: @"path" forKey: @"type"];
                num = [NSNumber numberWithFloat: [obj flatness]];
                [objProps setObject: num forKey: @"flatness"];
                num = [NSNumber numberWithInt: [obj lineJoin]];
                [objProps setObject: num forKey: @"linejoin"];
                num = [NSNumber numberWithInt: [obj lineCap]];
                [objProps setObject: num forKey: @"linecap"];
                num = [NSNumber numberWithFloat: [obj miterLimit]];
                [objProps setObject: num forKey: @"miterlimit"];
                num = [NSNumber numberWithFloat: [obj lineWidth]];
                [objProps setObject: num forKey: @"linewidth"];
                num = [NSNumber numberWithInt: [obj isStroked]];
                [objProps setObject: num forKey: @"stroked"];
                color = [obj strokeColor];
                num = [NSNumber numberWithFloat: color[0]];
                [objProps setObject: num forKey: @"strokecyan"];
                num = [NSNumber numberWithFloat: color[1]];
                [objProps setObject: num forKey: @"strokemagenta"];
                num = [NSNumber numberWithFloat: color[2]];
                [objProps setObject: num forKey: @"strokeyellow"];
                num = [NSNumber numberWithFloat: color[3]];
                [objProps setObject: num forKey: @"strokeblack"];
                num = [NSNumber numberWithFloat: [obj strokeAlpha]];
                [objProps setObject: num forKey: @"strokealpha"];
                num = [NSNumber numberWithInt: [obj isFilled]];
                [objProps setObject: num forKey: @"filled"];
                color = [obj fillColor];
                num = [NSNumber numberWithFloat: color[0]];
                [objProps setObject: num forKey: @"fillcyan"];
                num = [NSNumber numberWithFloat: color[1]];
                [objProps setObject: num forKey: @"fillmagenta"];
                num = [NSNumber numberWithFloat: color[2]];
                [objProps setObject: num forKey: @"fillyellow"];
                num = [NSNumber numberWithFloat: color[3]];
                [objProps setObject: num forKey: @"fillblack"];
                num = [NSNumber numberWithFloat: [obj fillAlpha]];
                [objProps setObject: num forKey: @"fillalpha"];
            } else
            {
                [objProps setObject: @"text" forKey: @"type"];
                num = [NSNumber numberWithInt: [obj isStroked]];
                [objProps setObject: num forKey: @"stroked"];
                color = [obj strokeColor];
                num = [NSNumber numberWithFloat: color[0]];
                [objProps setObject: num forKey: @"strokecyan"];
                num = [NSNumber numberWithFloat: color[1]];
                [objProps setObject: num forKey: @"strokemagenta"];
                num = [NSNumber numberWithFloat: color[2]];
                [objProps setObject: num forKey: @"strokeyellow"];
                num = [NSNumber numberWithFloat: color[3]];
                [objProps setObject: num forKey: @"strokeblack"];
                num = [NSNumber numberWithFloat: [obj strokeAlpha]];
                [objProps setObject: num forKey: @"strokealpha"];
                num = [NSNumber numberWithInt: [obj isFilled]];
                [objProps setObject: num forKey: @"filled"];
                color = [obj fillColor];
                num = [NSNumber numberWithFloat: color[0]];
                [objProps setObject: num forKey: @"fillcyan"];
                num = [NSNumber numberWithFloat: color[1]];
                [objProps setObject: num forKey: @"fillmagenta"];
                num = [NSNumber numberWithFloat: color[2]];
                [objProps setObject: num forKey: @"fillyellow"];
                num = [NSNumber numberWithFloat: color[3]];
                [objProps setObject: num forKey: @"fillblack"];
                num = [NSNumber numberWithFloat: [obj fillAlpha]];
                [objProps setObject: num forKey: @"fillalpha"];
            }
            break;
        }
    }

    if(!objProps)
        return;

    epwin = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 500, 305)
                                        styleMask: style
                                          backing: NSBackingStoreBuffered
                                            defer: NO];
    
    [epwin setTitle: @"Object Properties"];
    propsEditor = [[GRPropsEditor alloc] initWithFrame: NSMakeRect(0, 0, 500, 300)
                                            forDocView: self objectProperties: objProps];
    [epwin setContentView: propsEditor];
    [epwin center];
    result = [propsEditor runModal];
    if(result == NSAlertDefaultReturn)
    {
        newProps = [propsEditor properties];
        count = 0;
        for(i = 0; i < [objects count]; i++)
            if([[[objects objectAtIndex: i] editor] isGroupSelected])
                count++;
        if(count > 1) {
            result = NSRunAlertPanel(@"Alert", @"You are going to set the properties of many objects! Are you sure?", @"Ok", @"No", nil);
            if(result != NSAlertDefaultReturn)
            {
                [epwin release];
                return;
            }
        }

        for(i = 0; i < [objects count]; i++)
        {
            obj = [objects objectAtIndex: i];
            if([[obj editor] isGroupSelected]) {
                objProps = [NSMutableDictionary dictionaryWithCapacity: 1];
                if([obj isKindOfClass: [GRBezierPath class]])
                {
                    [obj setFlat: [[newProps objectForKey: @"flatness"] floatValue]];
                    [obj setLineJoin: [[newProps objectForKey: @"linejoin"] intValue]];
                    [obj setLineCap: [[newProps objectForKey: @"linecap"] intValue]];
                    [obj setMiterLimit: [[newProps objectForKey: @"miterlimit"] floatValue]];
                    [obj setLineWidth: [[newProps objectForKey: @"linewidth"] floatValue]];
                }
                [obj setStroked: (BOOL)[[newProps objectForKey: @"stroked"] intValue]];
                newcolor[0] = [[newProps objectForKey: @"strokecyan"] floatValue];
                newcolor[1] = [[newProps objectForKey: @"strokemagenta"] floatValue];
                newcolor[2] = [[newProps objectForKey: @"strokeyellow"] floatValue];
                newcolor[3] = [[newProps objectForKey: @"strokeblack"] floatValue];
                [obj setStrokeColor: newcolor];
                [obj setStrokeAlpha: [[newProps objectForKey: @"strokealpha"] floatValue]];
                [obj setFilled: (BOOL)[[newProps objectForKey: @"filled"] intValue]];
                newcolor[0] = [[newProps objectForKey: @"fillcyan"] floatValue];
                newcolor[1] = [[newProps objectForKey: @"fillmagenta"] floatValue];
                newcolor[2] = [[newProps objectForKey: @"fillyellow"] floatValue];
                newcolor[3] = [[newProps objectForKey: @"fillblack"] floatValue];
                [obj setFillColor: newcolor];
                [obj setFillAlpha: [[newProps objectForKey: @"fillalpha"] floatValue]];
            }
        }
        // ####		[myWin setSaved: NO];
    }

    [epwin release];
    [self setNeedsDisplay: YES];
}

- (void)moveSelectedObjectsToFront:(id)sender
{
    id obj = nil;
    int i;

    for(i = 0; i < [objects count]; i++)
    {
        if([[[objects objectAtIndex: i] editor] isGroupSelected])
        {
            obj = [[objects objectAtIndex: i] retain];
            break;
        }
    }
    if(!obj)
        return;

    for(i = 0; i < [objects count]; i++)
        if([objects objectAtIndex: i] != obj)
            [[[objects objectAtIndex: i] editor] unselect];

    for(i = 0; i < [objects count]; i++)
    {
        if((obj == [objects objectAtIndex: i]) && (i + 1 < [objects count]))
        {
            [objects removeObjectAtIndex: i];
            [objects insertObject: obj atIndex: i + 1];
            [obj release];
            break;
        }
    }

    // #####	[myWin setSaved: NO];
    [self setNeedsDisplay: YES];
}

- (void)moveSelectedObjectsToBack:(id)sender
{
    id obj = nil;
    int i;

    for(i = 0; i < [objects count]; i++)
    {
        if([[[objects objectAtIndex: i] editor] isGroupSelected])
        {
            obj = [[objects objectAtIndex: i] retain];
            break;
        }
    }
    if(!obj)
        return;

    for(i = 0; i < [objects count]; i++)
        if([objects objectAtIndex: i] != obj)
            [[[objects objectAtIndex: i] editor] unselect];

    for(i = 0; i < [objects count]; i++) {
        if((obj == [objects objectAtIndex: i]) && ((i - 1) >= 0)) {
            [objects removeObjectAtIndex: i];
            [objects insertObject: obj atIndex: i - 1];
            [obj release];
            break;
        }
    }

    // #####	[myWin setSaved: NO];
    [self setNeedsDisplay: YES];
}

- (void)unselectOtherObjects:(id)anObject
{
    id obj;
    int i;

    if(shiftclick)
        return;

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if(obj != anObject)
            [[obj editor] unselect];
    }

    [self setNeedsDisplay: YES];
}

- (void)zoomOnPoint:(NSPoint)p zoomOut:(BOOL)isout
{
    float orx, ory, szx, szy;
    NSRect vr;
    NSPoint pp;
    int i;

    if(isout) {
        zIndex--;
        if(zIndex < 0)
        {
            zIndex = 0;
            return;
        }
    } else
    {
        zIndex++;
        if(zIndex > 8)
        {
            zIndex = 8;
            return;
        }
    }

    zFactor = zFactors[zIndex];

    orx = a4Rect.origin.x * zFactor;
    ory = a4Rect.origin.y * zFactor;
    szx = a4Rect.size.width * zFactor;
    szy = a4Rect.size.height * zFactor;
    zmdRect = NSMakeRect(orx, ory, szx, szy);
    szx = pageRect.size.width * zFactor;
    szy = pageRect.size.height * zFactor;

    pp.x = p.x * ([self frame].origin.x + pageRect.size.width) / [self frame].size.width;
    pp.y = p.y * ([self frame].origin.y + pageRect.size.height) / [self frame].size.height;
    vr = NSMakeRect(pp.x * zFactor - 200, pp.y * zFactor - 200, 400, 400);

    [self setFrame: NSMakeRect(0, 0, szx, szy)];
    [self scrollRectToVisible: vr];

    for(i = 0; i < [objects count]; i++)
        [[objects objectAtIndex: i] setZoomFactor: zFactor];

    [[self window] display];
}

- (void)movePageFromHandPoint:(NSPoint)handpos
{
    NSEvent *nextEvent;
    NSPoint p, diffp;
    NSRect r;

    nextEvent = [[self window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([nextEvent type] == NSLeftMouseDragged) {
        do {
            p = [nextEvent locationInWindow];
            p = [self convertPoint: p fromView: nil];
            diffp.x = p.x - handpos.x;
            diffp.y = p.y - handpos.y;
            r = [self visibleRect];
            r = NSMakeRect(r.origin.x - diffp.x, r.origin.y - diffp.y,
                           r.size.width, r.size.height);
            [self scrollRectToVisible: r];
            nextEvent = [[self window] nextEventMatchingMask:
                NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        } while([nextEvent type] != NSLeftMouseUp);
        [[self window] display];
    }
}

- (void)cut:(id)sender
{
    [self copy: sender];
    [self deleteSelectedObjects];
    // #####	[myWin setSaved: NO];
}

- (void)copy:(id)sender
{
    NSMutableArray *types;
    NSPasteboard *pboard;
    id obj;
    NSMutableArray *objsdesc;
    int i;

    objsdesc = [NSMutableArray arrayWithCapacity: 1];
    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([[obj editor] isGroupSelected])
            [objsdesc addObject: [obj objectDescription]];
    }

    if([objsdesc count]) {
        types = [NSMutableArray arrayWithObjects: @"GRObjectPboardType", nil];
        pboard = [NSPasteboard generalPasteboard];
        [pboard declareTypes: types owner: self];
        [pboard setString: [objsdesc description] forType: @"GRObjectPboardType"];
    }
}

- (void)paste:(id)sender
{
    NSPasteboard *pboard;
    NSArray *types;
    NSArray *descriptions;
    NSDictionary *objdesc;
    id obj;
    NSString *str;
    int i;

    pboard = [NSPasteboard generalPasteboard];
    types = [NSArray arrayWithObject: @"GRObjectPboardType"];
    if([[pboard availableTypeFromArray: types] isEqualToString: @"GRObjectPboardType"]) {
        descriptions = (NSArray *)[[pboard stringForType: @"GRObjectPboardType"] propertyList];

        for(i = 0; i < [descriptions count]; i++) {
            objdesc = [descriptions objectAtIndex: i];
            str = [objdesc objectForKey: @"type"];
            if([str isEqualToString: @"path"])
                obj = [[GRBezierPathEditor alloc] initFromData: objdesc
                                                        inView: self zoomFactor: zFactor];
            else
                obj = [[GRText alloc] initFromData: objdesc
                                            inView: self zoomFactor: zFactor];
            [objects addObject: obj];
            [obj selectAsGroup];
            [obj release];
        }
        [self setNeedsDisplay: YES];
        // ####		[myWin setSaved: NO];
    }
}

- (void)doUndo
{
    if([undoManager canUndo])
    {
        [undoManager undoNestedGroup];
        // #####		[myWin setSaved: NO];
    }
}

- (void)doRedo
{
    if([undoManager canRedo])
    {
        [undoManager redo];
        // #####		[myWin setSaved: NO];
    }
}

- (void)prepareDoItAgainWithSelector:(SEL)selector owner:(id)owner target:(id)target , ...
{
    NSMethodSignature	*sign;
    va_list ap;
    id arg;
    int i = 2;

    sign = [owner methodSignatureForSelector: selector];
    if(doItAgain)
        [doItAgain release];
    doItAgain = [[NSInvocation invocationWithMethodSignature: sign] retain];
    [doItAgain setTarget: target];
    [doItAgain setSelector: selector];

    va_start(ap, target);
    while(1) {
        arg = va_arg(ap, id);
        if(!arg)
            break;
        [doItAgain setArgument: arg atIndex: i];
        i++;
    }
    va_end(ap);

    [doItAgain retainArguments];
}

- (void)verifyModifiersOfEvent:(NSEvent *)theEvent
{
    if([theEvent type] == NSLeftMouseDown
       || [theEvent type] == NSLeftMouseDragged)
    {
        if([theEvent modifierFlags] & NSShiftKeyMask)
            shiftclick = YES;
        else
            shiftclick = NO;
        if([theEvent modifierFlags] & NSCommandKeyMask)
            altclick = YES;
        else
            altclick = NO;
        if([theEvent modifierFlags] & NSControlKeyMask)
            ctrlclick = YES;
        else
            ctrlclick = NO;
    }

    if([theEvent type] == NSLeftMouseUp)
    {
        if(!([theEvent modifierFlags] & NSShiftKeyMask))
            shiftclick = NO;
        if(!([theEvent modifierFlags] & NSCommandKeyMask))
            altclick = NO;
        if(!([theEvent modifierFlags] & NSControlKeyMask))
            ctrlclick = NO;
    }
}

- (BOOL)shiftclick
{
    return shiftclick;
}

- (BOOL)altclick
{
    return altclick;
}

- (BOOL)ctrlclick
{
    return ctrlclick;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint p;
    int count = [theEvent clickCount];

    [self verifyModifiersOfEvent: theEvent];

    p = [theEvent locationInWindow];
    p = [self convertPoint: p fromView: nil];

    if(count == 1) {
        switch([[NSApp delegate] currentToolType])
        {
            case blackarrowtool:
                [self selectObjectAtPoint: p];
                break;
            case whitearrowtool:
                [self editPathAtPoint: p];
                break;
            case beziertool:
                [self startDrawingAtPoint: p];
                break;
            case texttool:
                [self addTextAtPoint: p];
                break;
            case circletool:

                break;
            case rectangletool:
                [self addBoxAtPoint: p];
                break;
            case painttool:

                break;
            case penciltool:

                break;
            case rotatetool:

                break;
            case reducetool:

                break;
            case reflecttool:

                break;
            case scissorstool:
                if(altclick)
                    [self subdividePathAtPoint: p splitIt: NO];
                else
                    [self subdividePathAtPoint: p splitIt: YES];
                break;
            case handtool:
                [self movePageFromHandPoint: p];
                break;
            case magnifytool:
                if(altclick)
                    [self zoomOnPoint: p zoomOut: YES];
                else
                    [self zoomOnPoint: p zoomOut: NO];
                break;
            default:
                break;
        }
    } else {
        if([[NSApp delegate] currentToolType] == blackarrowtool)
            [self editTextAtPoint: p];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self verifyModifiersOfEvent: theEvent];
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    NSString *commchar = [theEvent charactersIgnoringModifiers];

    if([commchar isEqualToString: @"t"]) {
        [self editSelectedText];
        return YES;
    }
    if([commchar isEqualToString: @"z"]) {
        [self doUndo];
        return YES;
    }
    if([commchar isEqualToString: @"r"]) {
        [self doRedo];
        return YES;
    }
    if([commchar isEqualToString: @"d"]) {
        if(doItAgain) {
            [doItAgain invoke];
            [self setNeedsDisplay: YES];
            // ####			[myWin setSaved: NO];
        }
        return YES;
    }

    return NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
    unsigned short keyCode;
    NSRect vRect, hiddRect;
    NSPoint vPoint;
    float hiddRx, hiddRy, hiddRw, hiddRh;

    keyCode = [theEvent keyCode];

    if(keyCode == NSDeleteFunctionKey)
    {
        [self deleteSelectedObjects];
    } else if(keyCode == NSPageUpFunctionKey)
    {
        vRect = [self visibleRect];
        vPoint = vRect.origin;
        hiddRx = vPoint.x;
        hiddRy = vPoint.y + vRect.size.height;
        hiddRw = vRect.size.width;
        hiddRh = vRect.size.height;
        hiddRect = NSMakeRect(hiddRx, hiddRy, hiddRw, hiddRh);
        [self scrollRectToVisible: hiddRect];
    } else if(keyCode == NSPageDownFunctionKey)
    {
        vRect = [self visibleRect];
        vPoint = vRect.origin;
        hiddRx = vPoint.x;
        hiddRy = vPoint.y - vRect.size.height;
        hiddRw = vRect.size.width;
        hiddRh = vRect.size.height;
        hiddRect = NSMakeRect(hiddRx, hiddRy, hiddRw, hiddRh);
        [self scrollRectToVisible: hiddRect];
    }
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)drawRect:(NSRect)rect
{
    int          i;
    NSRect       frameRect;
    NSBezierPath *bzp;

    frameRect = [self frame];
    
    [[NSColor whiteColor] set];
    NSRectFill(rect);

    [[NSColor lightGrayColor] set];

    bzp = [NSBezierPath bezierPath];
    [bzp moveToPoint:NSMakePoint(0, zmdRect.origin.y)];
    [bzp lineToPoint:NSMakePoint(frameRect.size.width, zmdRect.origin.y)];
    [bzp lineToPoint:NSMakePoint(rect.size.width, zmdRect.origin.y)];
    [bzp moveToPoint:NSMakePoint(0, zmdRect.origin.y + zmdRect.size.height)];
    [bzp lineToPoint:NSMakePoint(frameRect.size.width, zmdRect.origin.y + zmdRect.size.height)];
    [bzp moveToPoint:NSMakePoint(zmdRect.origin.x, 0)];
    [bzp lineToPoint:NSMakePoint(zmdRect.origin.x, frameRect.size.height)];
    [bzp moveToPoint:NSMakePoint(zmdRect.origin.x + zmdRect.size.width, 0)];
    [bzp lineToPoint:NSMakePoint(zmdRect.origin.x + zmdRect.size.width, frameRect.size.height)];
    [bzp stroke];


    for(i = 0; i < [objects count]; i++)
        [(GRDrawableObject *)[objects objectAtIndex: i] draw];

}

@end



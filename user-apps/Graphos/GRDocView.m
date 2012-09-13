/*
 Project: Graphos
 GRDocView.m

 Copyright (C) 2000-2012 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "GRDocView.h"
#import "Graphos.h"
#import "GRFunctions.h"
#import "GRBezierPath.h"
#import "GRBox.h"
#import "GRBoxEditor.h"
#import "GRText.h"
#import "GRTextEditor.h"
#import "GRCircle.h"
#import "GRCircleEditor.h"
#import "GRPropsEditor.h"

#define UNDO_ACTION_OBJPROPS @"Change Object Properties"

#define ZOOM_FACTORS 8
float zFactors[ZOOM_FACTORS] = {0.25, 0.5, 1, 1.5, 2, 3, 4, 6};

@implementation GRDocView


- (id)initWithFrame:(NSRect)aRect
{
  pageRect = NSMakeRect(0, 0, 695, 942);
  a4Rect = NSMakeRect(50, 50, 595, 842);
  zmdRect = NSMakeRect(50, 50, 595, 842);
  
  self = [super initWithFrame: pageRect];
  if(self)
    {
      NSImage *img;
      NSCursor *cur;
        
      img = [NSImage imageNamed: @"blackarrow.tiff"];
      cur = [[NSCursor alloc] initWithImage: img hotSpot: NSMakePoint(0, 0)];
      [cur setOnMouseEntered: YES];
      [cur setOnMouseExited: YES];
      [self addTrackingRect: [self frame]
	    owner: cur userData: NULL
	    assumeInside: YES];
      [cur release];

      objects = [[NSMutableArray alloc] initWithCapacity: 1];
      delObjects = [[NSMutableArray alloc] initWithCapacity: 1];
      lastObjects = nil;
      shiftclick = NO;
      altclick = NO;
      ctrlclick = NO;
      zIndex = 2;
      zFactor = zFactors[zIndex];
    }
  return self;
}

- (void)dealloc
{
    [objects release];
    [delObjects release];
    [lastObjects release];
    [super dealloc];
}

- (NSDictionary *) objectDictionary
{
  NSMutableDictionary *objsdict;
  NSMutableArray *objectOrder;
  NSString *str = nil;
  id obj;
  int i;
  int p = 0;
  int c = 0;
  int t = 0;
  int b = 0;
  
  objsdict = [NSMutableDictionary dictionaryWithCapacity: 1];
  objectOrder = [NSMutableArray arrayWithCapacity: [objects count]];
  for(i = 0; i < [objects count]; i++)
    {
      obj = [objects objectAtIndex: i];
      NSLog(@"class: %@", [obj className]);
      if([obj isKindOfClass: [GRBezierPath class]])
        {
	  str = [NSString stringWithFormat: @"path%i", p];
	  p++;
        }
      else if([obj isKindOfClass: [GRBox class]])
        {
	  str = [NSString stringWithFormat: @"box%i", b];
	  b++;
        }
      else if([obj isKindOfClass: [GRCircle class]])
        {
	  str = [NSString stringWithFormat: @"circle%i", c];
	  c++;
        }
      else if([obj isKindOfClass: [GRText class]])
        {
	  str = [NSString stringWithFormat: @"text%i", t];
	  t++;
        }
      else
	{
	  [NSException raise:@"Unhandled object type" format:@"%@", [obj class]];
	}
      [objectOrder addObject: str];
      [objsdict setObject: [obj objectDescription] forKey: str];
    }
  [objsdict setValue:[NSNumber numberWithFloat:FILE_FORMAT_VERSION] forKey:@"Version"];
  [objsdict setValue:objectOrder forKey:@"Order"];
  return [NSDictionary dictionaryWithDictionary: objsdict];
}


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
    GRBox *box;
    GRCircle *circle;
    int i;
    float version;
    NSNumber *versionNumber;

    if(!dict)
      return NO;

    version = 0.0;
    versionNumber = [dict objectForKey:@"Version"];
    if (versionNumber)
      version = [versionNumber floatValue];
    NSLog(@"loading file of version: %f", version);

    if (version < 0.3)
      {
	/* loading for files without ordering */

	NSLog(@"Loading old file version, < 0.3");
	keys = [dict allKeys];
	for(i = 0; i < [keys count]; i++)
	  {
	    key = [keys objectAtIndex: i];
	    objdict = [dict objectForKey: key];
	    if(!objdict)
	      return NO;

	    if([key rangeOfString: @"path"].length)
	      {
		bzPath = [[GRBezierPath alloc] initFromData: objdict
						     inView: self zoomFactor: zFactor];
		[objects addObject: bzPath];
		[bzPath release];
		edind = [objects count] -1;
	      }
	    else if([key rangeOfString: @"text"].length)
	      {
		gGRText = [[GRText alloc] initFromData: objdict
						inView: self zoomFactor: zFactor];
		[objects addObject: gGRText];
		[gGRText release];
	      }
	    else if([key rangeOfString: @"box"].length)
	      {
		box = [[GRBox alloc] initFromData: objdict
					   inView: self zoomFactor: zFactor];
		[objects addObject: box];
		[box release];
	      }
	    else if([key rangeOfString: @"circle"].length)
	      {
		circle = [[GRCircle alloc] initFromData: objdict
						 inView: self zoomFactor: zFactor];
		[objects addObject: circle];
		[circle release];
	      }
	    else if ([key isEqualToString:@"Version"])
	      {
		/* skip, already parsed */
	      }
	    else
	      {
		[NSException raise:@"Unsupported object in file." format:@"Key: %@", key]; 
	      }
	  }
      } 
    else
      {
	/* loading of files with encoded ordering */
	NSArray *order;

	NSLog(@"Loading version 0.3 or later, ordered objects");
	order = [dict objectForKey:@"Order"];
	for(i = 0; i < [order count]; i++)
	  {
	    key = [order objectAtIndex: i];
	    objdict = [dict objectForKey: key];
	    if(!objdict)
	      return NO;

	    if([key rangeOfString: @"path"].length)
	      {
		bzPath = [[GRBezierPath alloc] initFromData: objdict
						     inView: self zoomFactor: zFactor];
		[objects addObject: bzPath];
		[bzPath release];
		edind = [objects count] -1;
	      }
	    else if([key rangeOfString: @"text"].length)
	      {
		gGRText = [[GRText alloc] initFromData: objdict
						inView: self zoomFactor: zFactor];
		[objects addObject: gGRText];
		[gGRText release];
	      }
	    else if([key rangeOfString: @"box"].length)
	      {
		box = [[GRBox alloc] initFromData: objdict
					   inView: self zoomFactor: zFactor];
		[objects addObject: box];
		[box release];
	      }
	    else if([key rangeOfString: @"circle"].length)
	      {
		circle = [[GRCircle alloc] initFromData: objdict
						 inView: self zoomFactor: zFactor];
		[objects addObject: circle];
		[circle release];
	      }
	    else
	      {
		[NSException raise:@"Unsupported object in file." format:@"Key: %@", key]; 
	      }
	  }
      }
    return YES;
}

- (void)addPath
{
  GRBezierPath *path;
  GRPropsEditor *objInspector;

  objInspector = [[[NSApplication sharedApplication] delegate] objectInspector];

  path = [[GRBezierPath alloc] initInView: self
			       zoomFactor: zFactor
			   withProperties: [objInspector properties]];

  [objects addObject: path];
  [path release];
  edind = [objects count] -1;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)addTextAtPoint:(NSPoint)p
{
  GRText *gdtxt;
  int i;
  NSUndoManager *uMgr;
  GRPropsEditor *objInspector;

  objInspector = [[[NSApplication sharedApplication] delegate] objectInspector];
    
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
  [uMgr setActionName:@"Add Text"];
    
  [self saveCurrentObjects];
    
  NSLog(@"AddTextAtPoint");
  for(i = 0; i < [objects count]; i++)
    [[[objects objectAtIndex: i] editor] unselect];

  gdtxt = [[GRText alloc] initInView: self
			     atPoint: p
			  zoomFactor: zFactor
		      withProperties: [objInspector properties]
			  openEditor: YES];
  [objects addObject: gdtxt];
  [[gdtxt editor] select];
  [gdtxt release];
  [self setNeedsDisplay: YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)addBox
{
  GRBox *box;
  GRPropsEditor *objInspector;

  objInspector = [[[NSApplication sharedApplication] delegate] objectInspector];

  box = [[GRBox alloc] initInView: self
		       zoomFactor: zFactor
		   withProperties: [objInspector properties]];

  [objects addObject: box];
  [[box editor] select];
  [box release];
  [self setNeedsDisplay: YES];
  edind = [objects count] -1;
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)addCircle
{
  GRCircle *circle;
  GRPropsEditor *objInspector;

  objInspector = [[[NSApplication sharedApplication] delegate] objectInspector];

  circle = [[GRCircle alloc] initInView: self
			     zoomFactor: zFactor
			 withProperties: [objInspector properties]];

  [objects addObject: circle];
  [[circle editor] select];
  [circle release];
  [self setNeedsDisplay: YES];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
  edind = [objects count] -1;
}

- (NSArray *)duplicateObjects:(NSArray *)objs andMoveTo:(NSPoint)p
{
    id obj, duplObj;
    NSMutableArray *duplObjs;
    int i;

    duplObjs = [NSMutableArray arrayWithCapacity: 1];

    for(i = 0; i < [objs count]; i++)
    {
        obj = [objs objectAtIndex: i];
        duplObj = [obj copy];
        [[obj editor] unselect];
        [duplObj selectAsGroup];
        [duplObj moveAddingCoordsOfPoint: p];
        [objects addObject: duplObj];
        [duplObjs addObject: duplObj];
	[duplObj release];
    }
    edind = [objects count] -1;
    [self setNeedsDisplay: YES];

    return duplObjs;
}

- (void)updatePrintInfo: (NSPrintInfo *)pi;
{
  float lm, rm;

  if (pi == nil)
    {
      NSLog(@"invalid printer information");
      return;
    }
  lm = [pi leftMargin];
  rm = [pi rightMargin];
  if (lm <= 0 || rm <= 0 || [pi paperSize].width <= 0 || [pi paperSize].height <= 0)
    {
      NSLog(@"invalid margin / paper size information. %f %f %f %f", lm, rm,[pi paperSize].width, [pi paperSize].height);
      return;
    }
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
    NSUndoManager *uMgr;
    
    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Create Path"];
    
    [self saveCurrentObjects];

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBezierPath class]])
            if(![[obj editor] isdone])
                isneweditor = NO;
    }

    if(isneweditor)
        for(i = 0; i < [objects count]; i++)
        {
            GRObjectEditor *objEdi;
            
            objEdi = [[objects objectAtIndex: i] editor];
            if (![objEdi isSelect])
                [objEdi unselect];
        }

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

- (void)startBoxAtPoint:(NSPoint)p
{
    NSEvent *nextEvent;
    GRBox *box;
    id obj;
    BOOL isneweditor = YES;
    int i;
    NSUndoManager *uMgr;
    
    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Create Box"];
    
    [self saveCurrentObjects];
    
    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBox class]])
            if(![[obj editor] isdone])
                isneweditor = NO;
    }

    if(isneweditor)
        for(i = 0; i < [objects count]; i++)
        {
            GRObjectEditor *objEdi;
            
            objEdi = [[objects objectAtIndex: i] editor];
            if (![objEdi isSelect])
                [objEdi unselect];
        }

    nextEvent = [[self window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    [self verifyModifiersOfEvent: nextEvent];

    if([nextEvent type] != NSLeftMouseDragged)
    {
       NSLog(@"is not left mouse dragged");
        if(isneweditor)
        {
            [self addBox];
            box = [objects objectAtIndex: edind];
            [[box editor] selectForEditing];
            [box setStartAtPoint: p];
            [self setNeedsDisplay: YES];
            return;
        } else
        {
            box = [objects objectAtIndex: edind];
            [[box editor] selectForEditing];
//            if(shiftclick)
//                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [box setEndAtPoint: p];
            [self setNeedsDisplay: YES];
            return;
        }
    } else
    {
       NSLog(@"is left mouse dragged");
        if(isneweditor)
        {
       NSLog(@"is new editor");
            [self addBox];
            box = [objects objectAtIndex: edind];
            [[box editor] selectForEditing];
            [box setStartAtPoint: p];
            [self setNeedsDisplay: YES];
        } else
        {
       NSLog(@"is old editor");
            box = [objects objectAtIndex: edind];
            [[box editor] selectForEditing];
//            if(shiftclick)
//                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [box setEndAtPoint: p];
            [self setNeedsDisplay: YES];
        }

        do
        {
            p = [nextEvent locationInWindow];
            p = [self convertPoint: p fromView: nil];
//            if(shiftclick)
//                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);

            [box setEndAtPoint: p];

            [self setNeedsDisplay: YES];

            nextEvent = [[self window] nextEventMatchingMask:
                        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [self verifyModifiersOfEvent: nextEvent];
        } while([nextEvent type] != NSLeftMouseUp);
        if (isneweditor)
        {
            [[box editor] unselect];
            [[box editor] selectAsGroup];
        }
    }
}

/* this has a lot in common with startBoxAtPoint */
- (void)startCircleAtPoint:(NSPoint)p
{
    NSEvent *nextEvent;
    GRCircle *circle;
    id obj;
    BOOL isneweditor = YES;
    int i;
    NSUndoManager *uMgr;
    
    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Create Circle"];
    
    [self saveCurrentObjects];

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRCircle class]])
            if(![[obj editor] isdone])
                isneweditor = NO;
    }

    if(isneweditor)
        for(i = 0; i < [objects count]; i++)
        {
            GRObjectEditor *objEdi;

            objEdi = [[objects objectAtIndex: i] editor];
            if (![objEdi isSelect])
                [objEdi unselect];
        }

            nextEvent = [[self window] nextEventMatchingMask:
                NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    [self verifyModifiersOfEvent: nextEvent];

    if([nextEvent type] != NSLeftMouseDragged)
    {
        NSLog(@"is not left mouse dragged");
        if(isneweditor)
        {
            [self addBox];
            circle = [objects objectAtIndex: edind];
            [[circle editor] selectForEditing];
            [circle setStartAtPoint: p];
            [self setNeedsDisplay: YES];
            return;
        } else
        {
            circle = [objects objectAtIndex: edind];
            [[circle editor] selectForEditing];
            //            if(shiftclick)
            //                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [circle setEndAtPoint: p];
            [self setNeedsDisplay: YES];
            return;
        }
    } else
    {
        NSLog(@"is left mouse dragged");
        if(isneweditor)
        {
            NSLog(@"is new editor");
            [self addCircle];
            circle = [objects objectAtIndex: edind];
            [[circle editor] selectForEditing];
            [circle setStartAtPoint: p];
            [self setNeedsDisplay: YES];
        } else
        {
            NSLog(@"is old editor");
            circle = [objects objectAtIndex: edind];
            [[circle editor] selectForEditing];
            //            if(shiftclick)
            //                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);
            [circle setEndAtPoint: p];
            [self setNeedsDisplay: YES];
        }

        do
        {
            p = [nextEvent locationInWindow];
            p = [self convertPoint: p fromView: nil];
            //            if(shiftclick)
            //                p = pointApplyingCostrainerToPoint(p, [[bzpath lastPoint] center]);

            [circle setEndAtPoint: p];

            [self setNeedsDisplay: YES];

            nextEvent = [[self window] nextEventMatchingMask:
                NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            [self verifyModifiersOfEvent: nextEvent];
        } while([nextEvent type] != NSLeftMouseUp);
        if (isneweditor)
        {
            [[circle editor] unselect];
            [[circle editor] selectAsGroup];
        }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ObjectSelectionChanged" object:self];
}

- (void)editPathAtPoint:(NSPoint)p
{
    id obj;
    int i;
    NSUndoManager *uMgr;
    
    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Edit Path"];
    
    [self saveCurrentObjectsDeep];

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRBezierPath class]])
        {
            if([obj onPathBorder: p])
            {
                [[obj editor] selectForEditing];
                [self moveControlPointOfEditor: (GRBezierPathEditor *)[obj editor] toPoint: p];
                return;
            } else
            {
                if([self moveBezierHandleOfEditor: (GRBezierPathEditor *)[obj editor] toPoint: p])
                    return;
                else
                    [[obj editor] unselect];
            }
        } else if ([obj isKindOfClass: [GRBox class]] || [obj isKindOfClass: [GRCircle class]])
        {
            if([obj onControlPoint: p])
            {
                [[obj editor] selectForEditing];
                [self moveControlPointOfEditor: (GRBezierPathEditor *)[obj editor] toPoint: p];
                return;
            } else
            {
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
    NSUndoManager *uMgr;
    
    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Edit Text"];
    
    [self saveCurrentObjectsDeep];

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
            }
        }
    }
    [self setNeedsDisplay: YES];
}

/** for keyboard equivalent */
- (void)editSelectedText
{
    id obj;
    int i;

    for(i = 0; i < [objects count]; i++)
    {
        obj = [objects objectAtIndex: i];
        if([obj isKindOfClass: [GRText class]])
        {
            if([obj isSelect])
                [obj edit];
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
    NSUndoManager *uMgr;
    
    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Move Object"];

    [self saveCurrentObjectsDeep];

    nextEvent = [[self window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([nextEvent type] == NSLeftMouseDragged)
    {
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
        } else
        {
            diffp.x = startp.x - p.x;
            diffp.y = startp.y - p.y;
        }
    }
}


- (BOOL)moveControlPointOfEditor:(GRPathEditor *)editor toPoint:(NSPoint)pos
{
    NSPoint p;

    p = [editor moveControlAtPoint: pos];
    if(p.x == pos.x && p.y == pos.y)
        return NO;

    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)moveBezierHandleOfEditor:(GRBezierPathEditor *)editor toPoint:(NSPoint)pos
{
    NSPoint p;

    p = [editor moveBezierHandleAtPoint: pos];
    if(p.x == pos.x && p.y == pos.y)
        return NO;

    [self setNeedsDisplay: YES];
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
                break;
            }
        }
    }
}

- (NSDictionary *)selectionProperties
{
  NSMutableDictionary *propDict;
  int i;
  int selectedObjects;
  int pathObjNum;
  int textObjNum;
  NSNumber *num;
  
  if(![objects count])
    return nil;

  selectedObjects = 0;
  pathObjNum = 0;
  textObjNum = 0;
  propDict = [NSMutableDictionary dictionaryWithCapacity: 1];
  for(i = 0; i < [objects count]; i++)
    {
      id obj;
      obj = [objects objectAtIndex: i];
      
      if([[obj editor] isSelect])
        {
          selectedObjects++;
        
          num = [NSNumber numberWithBool: [obj isStroked]];
          [propDict setObject: num forKey: @"stroked"];
          [propDict setObject: [obj strokeColor] forKey: @"strokecolor"];
          num = [NSNumber numberWithBool: [obj isFilled]];
          [propDict setObject: num forKey: @"filled"];
          [propDict setObject: [obj fillColor] forKey: @"fillcolor"];

          if([obj isKindOfClass: [GRPathObject class]])
            {
              pathObjNum++;
              num = [NSNumber numberWithFloat: [obj flatness]];
              [propDict setObject: num forKey: @"flatness"];
              num = [NSNumber numberWithInt: [obj lineJoin]];
              [propDict setObject: num forKey: @"linejoin"];
              num = [NSNumber numberWithInt: [obj lineCap]];
              [propDict setObject: num forKey: @"linecap"];
              num = [NSNumber numberWithFloat: [obj miterLimit]];
              [propDict setObject: num forKey: @"miterlimit"];
              num = [NSNumber numberWithFloat: [obj lineWidth]];
              [propDict setObject: num forKey: @"linewidth"];
            }
          else if([obj isKindOfClass: [GRText class]])
            {
              textObjNum++;
              [propDict setObject: @"text" forKey: @"type"];
            }
        }
    }
  
  if(selectedObjects == 0)
    return nil;
  
  if (textObjNum + pathObjNum != selectedObjects)
    {
      NSLog(@"Internal error: Help we lost some objects.");
    }
  
  /* we check if the selection is homogeneous or not
     and in case remove the keys that are not common among all objects */
  if (textObjNum > 0 && pathObjNum > 0)
    {
      [propDict removeObjectForKey: @"flatness"];
      [propDict removeObjectForKey: @"linejoin"];
      [propDict removeObjectForKey: @"linecap"];
      [propDict removeObjectForKey: @"miterlimit"];
      [propDict removeObjectForKey: @"linewidth"];
    }
  
  return propDict;
}

- (void)setSelectionProperties: (NSDictionary *)properties;
{
  NSUndoManager *uMgr;
  id obj;
  int i;
  
  uMgr = [self undoManager];
  /* save the method on the undo stack, but stack actions */
  if ([[uMgr undoActionName] isEqualToString: UNDO_ACTION_OBJPROPS] == NO)
    {
      [self saveCurrentObjectsDeep];
      [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
      [uMgr setActionName: UNDO_ACTION_OBJPROPS];
    }
  
  for(i = 0; i < [objects count]; i++)
    {
      obj = [objects objectAtIndex: i];
      if([[obj editor] isSelect])
        {
          NSColor *newColor;
      
          if([obj isKindOfClass: [GRBezierPath class]] || [obj isKindOfClass: [GRBox class]] || [obj isKindOfClass: [GRCircle class]])
            {
              [obj setFlat: [[properties objectForKey: @"flatness"] floatValue]];
              [obj setLineJoin: [[properties objectForKey: @"linejoin"] intValue]];
              [obj setLineCap: [[properties objectForKey: @"linecap"] intValue]];
              [obj setMiterLimit: [[properties objectForKey: @"miterlimit"] floatValue]];
              [obj setLineWidth: [[properties objectForKey: @"linewidth"] floatValue]];
            }
          [obj setStroked: [[properties objectForKey: @"stroked"] boolValue]];
          newColor = (NSColor *)[properties objectForKey: @"strokecolor"];
          [obj setStrokeColor: newColor];
          [obj setFilled: [[properties objectForKey: @"filled"] boolValue]];
          newColor = (NSColor *)[properties objectForKey: @"fillcolor"];
          [obj setFillColor: newColor];
        }
    }
  [self setNeedsDisplay: YES];
}

- (void)moveSelectedObjectsToFront:(id)sender
{
    id obj = nil;
    int i;
    NSUndoManager *uMgr;

    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Move to front"];

    [self saveCurrentObjectsDeep];


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
            break;
        }
    }
    [obj release];
    [self setNeedsDisplay: YES];
}

- (void)moveSelectedObjectsToBack:(id)sender
{
    id obj = nil;
    int i;
    NSUndoManager *uMgr;

    uMgr = [self undoManager];
    /* save the method on the undo stack */
    [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
    [uMgr setActionName:@"Move to back"];

    [self saveCurrentObjects];
    
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
        if((obj == [objects objectAtIndex: i]) && ((i - 1) >= 0)) 
        {
            [objects removeObjectAtIndex: i];
            [objects insertObject: obj atIndex: i - 1];
            break;
        }
    }
    [obj release];
    [self setNeedsDisplay: YES];
}

- (void)unselectOtherObjects:(GRDrawableObject *)anObject
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
  int i;

  i = zIndex;
  if(isout)
    {
      if (i == 0)
	return;
      i--; 
    }
  else
    {
      if (i == ZOOM_FACTORS-1)
	return;
      i++;
    }

  [self zoomOnPoint:p withFactor:i];
}


- (void)zoomOnPoint:(NSPoint)p withFactor:(int)index
{
  float orx, ory, szx, szy;
  NSRect vr;
  NSPoint pp;
  unsigned i;

  zIndex = index;
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

- (IBAction)zoom50:(id)sender
{
  unsigned i;
  NSPoint p;
  NSRect visibleRect;

  zFactor = 0.5;

  i = ZOOM_FACTORS - 1;
  while (i > 0 && zFactor < zFactors[i])
    i--;

  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoom100:(id)sender
{
  unsigned  i;
  NSPoint p;
  NSRect visibleRect;

  zFactor = 1;

  i = ZOOM_FACTORS - 1;
  while (i > 0 && zFactor < zFactors[i])
    i--;

  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoom200:(id)sender
{
  unsigned i;
  NSPoint p;
  NSRect visibleRect;

  zFactor = 2;

  i = ZOOM_FACTORS - 1;
  while (i > 0 && zFactor < zFactors[i])
    i--;

  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoomFitPage:(id)sender
{
  unsigned i;
  NSPoint p;
  NSRect visibleRect;
  NSRect f;

  f = [self frame];
  visibleRect = [self visibleRect];
  i = ZOOM_FACTORS - 1;
  NSLog(@"visible %f, full %f", visibleRect.size.width, f.size.width);
  while (i > 0 && ((visibleRect.size.width < f.size.width * zFactors[i]) || (visibleRect.size.height < f.size.height * zFactors[i])))
    i--;
  NSLog(@"index: %d", i);
  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (IBAction)zoomFitWidth:(id)sender
{
  unsigned i;
  NSPoint p;
  NSRect visibleRect;
  NSRect f;

  f = [self frame];
  visibleRect = [self visibleRect];
  i = ZOOM_FACTORS - 1;
  NSLog(@"visible %f, full %f", visibleRect.size.width, f.size.width);
  while (i > 0 && visibleRect.size.width < f.size.width * zFactors[i])
    i--;
  NSLog(@"index: %d", i);
  visibleRect = [self visibleRect];
  p.x = NSMinX(visibleRect) + NSWidth(visibleRect) / 2;
  p.y = NSMinY(visibleRect) + NSHeight(visibleRect) / 2;

  [self zoomOnPoint:p withFactor:i];
}

- (void)movePageFromHandPoint:(NSPoint)handpos
{
    NSEvent *nextEvent;
    NSPoint p, diffp;
    NSRect r;

    nextEvent = [[self window] nextEventMatchingMask:
        NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    if([nextEvent type] == NSLeftMouseDragged)
    {
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

- (void)delete:(id)sender
{
  NSUndoManager *uMgr;

  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
  [uMgr setActionName:@"Delete"];
  
  [self saveCurrentObjects];
  
  [self deleteSelectedObjects];
}

- (void)cut:(id)sender
{
  NSUndoManager *uMgr;

  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
  [uMgr setActionName:@"Cut"];
  
  [self saveCurrentObjects];
  [self copy: sender];
  [self deleteSelectedObjects];
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
  
  if([objsdesc count])
    {
      types = [NSMutableArray arrayWithObjects: @"GRObjectPboardType", nil];
      pboard = [NSPasteboard generalPasteboard];
      [pboard declareTypes: types owner: self];
      [pboard setString:[objsdesc description] forType: @"GRObjectPboardType"];
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
  NSUndoManager *uMgr;
  
  uMgr = [self undoManager];
  /* save the method on the undo stack */
  [[uMgr prepareWithInvocationTarget: self] restoreLastObjects];
  [uMgr setActionName:@"Paste"];
  
  [self saveCurrentObjects];

  pboard = [NSPasteboard generalPasteboard];
  types = [NSArray arrayWithObject: @"GRObjectPboardType"];
  if([[pboard availableTypeFromArray: types] isEqualToString: @"GRObjectPboardType"])
    {
        descriptions = [[pboard stringForType: @"GRObjectPboardType"] propertyList];

        for(i = 0; i < [descriptions count]; i++)
        {
            objdesc = [descriptions objectAtIndex: i];
            str = [objdesc objectForKey: @"type"];

            obj = nil;
            if([str isEqualToString: @"path"])
                obj = [GRBezierPath alloc];
            else if([str isEqualToString: @"text"])
                obj = [GRText alloc];
            else if([str isEqualToString: @"box"])
                obj = [GRBox alloc];
            else if([str isEqualToString: @"circle"])
                obj = [GRCircle alloc];
            else
                NSLog(@"Unknown object to paste");
            if (obj != nil)
            {
                obj = [obj initFromData: objdesc
                                 inView: self zoomFactor: zFactor];
                [objects addObject: obj];
                [[obj editor] selectAsGroup];
                [obj release];
                [self setNeedsDisplay: YES];
            }
        }
    }
}

/* ----- Undo Methods ----- */

- (NSMutableArray *)deepCopyObjects: (NSMutableArray *)objArray
{
    NSMutableArray *copyArray;
    NSEnumerator *e;
    NSObject *o;

    
    copyArray = [[NSMutableArray arrayWithCapacity:[objArray count]] retain];

    e = [objArray objectEnumerator];
    while ((o = [e nextObject]))
    {
        [copyArray addObject:[[o copy] autorelease]];
    }

    return copyArray;
}

- (void)saveCurrentObjects
{
    if (objects != nil)
    {
        if (lastObjects != nil)
            [lastObjects release];
        lastObjects = [[NSMutableArray arrayWithArray:objects] retain];
    }
}

- (void)saveCurrentObjectsDeep
{
    if (objects != nil)
    {
        if (lastObjects != nil)
            [lastObjects release];
        lastObjects = [self deepCopyObjects: objects];
    }
}


- (void)restoreLastObjects
{
    NSMutableArray *tempObjects;

    /* backup the current status */
    tempObjects = [NSMutableArray arrayWithArray:objects];
    [objects release];
    
    /* re-register for redo */
    [[[self undoManager] prepareWithInvocationTarget: self] restoreLastObjects];

    /* get the last status */
    objects = [lastObjects retain];
    [lastObjects release];
    
    /* set the last status to the backup */
    lastObjects = [tempObjects retain];
    [self setNeedsDisplay: YES];
}

/* ----- Mouse Methods ----- */

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

    if(count == 1)
    {
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
                [self startCircleAtPoint: p];
                break;
            case rectangletool:
                [self startBoxAtPoint: p];
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
    } else
    {
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
    if([commchar isEqualToString: @"d"]) {
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

/* --- overridden for printing --- */
/**
 * override for a custom pagination scheme
 */
- (BOOL) knowsPageRange: (NSRangePointer) range
{
    /* we simply set one page */
    range->location = 1;
    range->length = 1;
    
    return YES;
}

/**
 * override for a custom pagination scheme
 */
- (NSRect ) rectForPage: (int) pageNumber
{
    NSRect pageRec;
    NSSize pageSize;
    NSPrintInfo *pi;
    
    pi = [[[NSDocumentController sharedDocumentController] currentDocument] printInfo];
    
    pageSize = [pi paperSize];    
    pageRec = NSMakeRect(0, 0, pageSize.width, pageSize.height);
    NSLog(@"page rect: %f, %f, %f, %f", pageRec.origin.x, pageRec.origin.y, pageRec.size.width, pageRec.size.height);
    return pageRec;
}

@end



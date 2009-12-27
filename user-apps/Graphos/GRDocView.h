/*
 Project: Graphos
 GRDocView.h

 Copyright (C) 2000-2009 GNUstep Application Project

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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "GRBezierPathEditor.h"


#define PREPAREUNDO(target, method) ({\
    [undoManager beginUndoGrouping]; \
    [[undoManager prepareWithInvocationTarget: target] method]; \
    [undoManager endUndoGrouping]; \
})

#ifndef ASSIGN
#define ASSIGN(object,value)     ({\
    id __value = (id)(value); \
        id __object = (id)(object); \
            if (__value != __object) \
            { \
                if (__value != nil) \
                { \
                    [__value retain]; \
                } \
                object = __value; \
                    if (__object != nil) \
                    { \
                        [__object release]; \
                    } \
            } \
})
#endif

@interface GRDocView : NSView
{
    NSMutableArray *objects, *delObjects;
    int edind;
    BOOL shiftclick, altclick, ctrlclick;

    NSUndoManager *undoManager;
    NSInvocation *doItAgain;

    NSRect pageRect, a4Rect, zmdRect;
    int zIndex;
    float zFactor;
    BOOL isDrawingForPrinting;
}

- (id)initWithFrame:(NSRect)aRect;
- (NSDictionary *) objectDictionary;
- (NSArray *)usedFonts;
- (BOOL)createObjectsFromDictionary:(NSDictionary *)dict;

/**
 * add a GRBezierPath
 */
- (void)addPath;

/**
 * add a GRBox
 */
- (void)addBox;

/**
 * add a GRCircle
 */
- (void)addCircle;

/**
 * add a GRText at the specified point
 */
- (void)addTextAtPoint:(NSPoint)p;

/**
 * make a copy of the objects invoking the object's duplicate method
 */
- (NSArray *)duplicateObjects:(NSArray *)objs andMoveTo:(NSPoint)p;

/**
 * update the view orientation and size according to the new print info object
 */
- (void)updatePrintInfo: (NSPrintInfo *)pi;

- (void)deleteSelectedObjects;
- (void)undoDeleteObjects;
- (void)startDrawingAtPoint:(NSPoint)p;
- (void)selectObjectAtPoint:(NSPoint)p;
- (void)editPathAtPoint:(NSPoint)p;
- (void)editTextAtPoint:(NSPoint)p;

- (void)editSelectedText;

- (void)moveSelectedObjects:(NSArray *)objs startingPoint:(NSPoint)startp;
- (void)undoMoveObjects:(NSArray *)objs moveBackTo:(NSPoint)p;

- (BOOL)moveControlPointOfEditor:(GRBezierPathEditor *)editor toPoint:(NSPoint)pos;
- (BOOL)moveBezierHandleOfEditor:(GRBezierPathEditor *)editor toPoint:(NSPoint)pos;
- (void)subdividePathAtPoint:(NSPoint)p splitIt:(BOOL)split;
- (IBAction)inspectObject: (id)sender;

- (IBAction)moveSelectedObjectsToFront:(id)sender;
- (IBAction)moveSelectedObjectsToBack:(id)sender;
- (void)unselectOtherObjects:(GRDrawableObject *)anObject;
- (void)zoomOnPoint:(NSPoint)p zoomOut:(BOOL)isout;
- (void)movePageFromHandPoint:(NSPoint)handpos;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (void)doUndo;
- (void)doRedo;
- (void)prepareDoItAgainWithSelector:(SEL)selector owner:(id)owner target:(id)target , ...;
- (void)verifyModifiersOfEvent:(NSEvent *)theEvent;

- (BOOL)shiftclick;
- (BOOL)altclick;
- (BOOL)ctrlclick;

@end

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "GRBezierPathEditor.h"


#define PREPAREUNDO(target, method) ({\
    [undoManager beginUndoGrouping]; \
    [[undoManager prepareWithInvocationTarget: target] method]; \
    [undoManager endUndoGrouping]; \
})

// substitution for crappy gnustep macro until I remove them all from the face of earth
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
}

- (id)initWithFrame:(NSRect)aRect;
- (NSDictionary *) objectDictionary;
- (NSArray *)usedFonts;
- (BOOL)createObjectsFromDictionary:(NSDictionary *)dict;
- (void)addPath;
- (void)addBoxAtPoint:(NSPoint)p;
- (void)addTextAtPoint:(NSPoint)p;
- (NSArray *)duplicateObjects:(NSArray *)objs andMoveTo:(NSPoint)p;
- (NSArray *)updatePrintInfo: (NSPrintInfo *)pi;

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
- (void)unselectOtherObjects:(id)anObject;
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

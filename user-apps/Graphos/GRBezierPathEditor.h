#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRBezierControlPoint.h"
#import "GRBezierPath.h"


@class GRDocView;

@interface GRBezierPathEditor : NSObject
{
    GRBezierPath *object;
    BOOL groupSelected;
    BOOL editSelected;
    BOOL isdone;
    BOOL isvalid;
    float zmFactor;
}

- (id)initEditor:(GRBezierPath *)anObject;


- (BOOL)isdone;
- (void)setIsDone:(BOOL)status;

- (void)selectAsGroup;
- (void)selectForEditing;
- (void)unselect;
- (BOOL)isGroupSelected;
- (BOOL)isEditSelected;
- (BOOL)isSelect;

- (void)unselectOtherControls:(GRBezierControlPoint *)cp;

- (void)setIsValid:(BOOL)value;
- (BOOL)isValid;

- (NSPoint)moveControlAtPoint:(NSPoint)p;
- (void)moveControlAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp;
- (NSPoint)moveBezierHandleAtPoint:(NSPoint)p;
- (void)moveBezierHandleAtPoint:(NSPoint)oldp toPoint:(NSPoint)newp;

- (void)draw;

@end


//
//  GRBox.h
//  Graphos
//
//  Created by Riccardo Mottola on Fri Sep 21 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GRBoxEditor.h"

@interface GRBox : NSObject {
    GRDocView *myView;
    NSBezierPath *myPath;
    NSPoint pos;
    NSSize size;
    NSRect bounds;
    float rotation;
    float strokeColor[4], fillColor[4];
    float strokeAlpha, fillAlpha;
    float flatness, miterlimit, linewidth;
    float scalex, scaley;
    int linejoin, linecap;
    BOOL stroked, filled;
    BOOL visible, locked;    
    GRBoxEditor *editor;
    BOOL groupSelected;
    BOOL editSelected;
    BOOL isSelect;
    BOOL isdone;
    BOOL isvalid;
    float zmFactor;  
}

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
      zoomFactor:(float)zf;

- (void)select;

- (void)selectAsGroup;

- (void)unselect;

- (BOOL)isSelect;

- (BOOL)isGroupSelected;

- (void)Draw;

@end

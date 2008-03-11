//
//  GRObjectControlPoint.h
//  Graphos
//
//  Created by Riccardo Mottola on Tue Sep 18 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GRBoxEditor;


@interface GRObjectControlPoint : NSObject {
    BOOL isActiveHandle;
    BOOL isSelect;
    NSPoint center;
    NSRect centerRect;
}

- (id)initAtPoint:(NSPoint)aPoint;

- (void)moveToPoint:(NSPoint)p;

- (NSRect)centerRect;

- (void)select;
- (void)unselect;
- (BOOL)isSelect;
- (BOOL)isActiveHandle;

@end

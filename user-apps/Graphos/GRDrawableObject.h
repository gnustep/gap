//
//  GRDrawableObject.h
//  Graphos
//
//  Created by Riccardo Mottola on Mon Feb 25 2008.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GRDocView;
@class GRObjectEditor;

@interface GRDrawableObject : NSObject
{
    GRDocView *docView;
    GRObjectEditor *editor;
    BOOL visible, locked;
}

- (GRDocView *)view;
- (GRObjectEditor *)editor;

- (BOOL)visible;
- (void)setVisible:(BOOL)value;
- (BOOL)locked;
- (void)setLocked:(BOOL)value;

- (void)draw;

@end

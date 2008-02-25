//
//  GRDrawableObject.m
//  Graphos
//
//  Created by Riccardo Mottola on Mon Feb 25 2008.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import "GRDrawableObject.h"


@implementation GRDrawableObject

- (GRDocView *)view
{
    return docView;
}

- (GRObjectEditor *)editor
{
    return editor;
}

- (BOOL)visible
{
    return visible;
}

- (void)setVisible:(BOOL)value
{
    visible = value;
    if(!visible)
        [editor unselect];
}

- (BOOL)locked
{
    return locked;
}

- (void)setLocked:(BOOL)value
{
    locked = value;
}

- (void)draw
{
}

@end

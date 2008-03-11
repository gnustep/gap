//
//  GRBoxEditor.m
//  Graphos
//
//  Created by Riccardo Mottola on Tue Sep 18 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GRBoxEditor.h"
#import "GRDocView.h"

@implementation GRBoxEditor

- (id)initEditor:(GRBox *)anObject
{
    self = [super init];
    if(self != nil)
    {
        object = anObject;
        groupSelected = NO;
        editSelected = NO;
        isdone = NO;
        isvalid = NO;
    }
    return self;
}

- (BOOL)isdone
{
    return isdone;
}

- (void)setIsDone:(BOOL)status
{
    isdone = status;

}
- (void)select
{
    [self selectAsGroup];
}

- (void)selectAsGroup
{
    if([object locked])
        return;

    if(!groupSelected)
    {
        groupSelected = YES;
        editSelected = NO;
        isvalid = NO;

        [[object view] unselectOtherObjects: object];
    }
}

- (void)selectForEditing
{
    if([object locked])
        return;
    editSelected = YES;
    groupSelected = NO;
    isvalid = NO;
    [[object view] unselectOtherObjects: object];
}


- (void)unselect
{
    int i;

    groupSelected = NO;
    editSelected = NO;
    isvalid = YES;
    isdone = YES;
}

- (BOOL)isSelect
{
    if(editSelected || groupSelected)
        return YES;
    return NO;
}

- (BOOL)isGroupSelected
{
    return groupSelected;
}

- (BOOL)isEditSelected
{
    return editSelected;
}


- (void)draw
{
}

@end

/*
 Project: Graphos
 GRObjectEditor.m

 Copyright (C) 2008-2010 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-02-25

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


#import "GRObjectEditor.h"
#import "GRDocView.h"

@implementation GRObjectEditor

- (id)initEditor:(GRDrawableObject *)anObject
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

- (id)copyWithZone:(NSZone *)zone
{
    GRObjectEditor *objCopy;

    objCopy = (GRObjectEditor *)NSCopyObject(self, 0, zone);
    objCopy->object = nil;
    
    return objCopy;
}


- (void)setObject:(GRDrawableObject *)anObject
{
    object = anObject;
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
        
        [[object view] unselectOtherObjects: (GRDrawableObject *)object];
    }
}

- (void)selectForEditing
{
    if([object locked])
        return;
    editSelected = YES;
    groupSelected = NO;
    isvalid = NO;
    [[object view] unselectOtherObjects: (GRDrawableObject *)object];
}


- (void)unselect
{
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

- (BOOL)isdone
{
    return isdone;
}

- (void)setIsDone:(BOOL)status
{
    isdone = status;
}

- (void)draw
{
}

@end

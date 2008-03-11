//
//  GRBoxEditor.h
//  Graphos
//
//  Created by Riccardo Mottola on Tue Sep 18 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRBox.h"
#import "GRObjectEditor.h"

@interface GRBoxEditor : GRObjectEditor
{
    BOOL groupSelected;
    BOOL editSelected;
    BOOL isdone;
    BOOL isvalid;
}

- (id)initEditor:(GRBox *)anObject;

- (BOOL)isdone;
- (void)setIsDone:(BOOL)status;

- (void)select;

- (void)selectAsGroup;

- (void)selectForEditing;

- (BOOL)isSelect;

- (BOOL)isGroupSelected;

- (void)draw;

@end

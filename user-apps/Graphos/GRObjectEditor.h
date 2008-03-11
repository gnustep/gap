//
//  GRObjectEditor.h
//  Graphos
//
//  Created by Riccardo Mottola on Mon Feb 25 2008.
//  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRDrawableObject.h"

@interface GRObjectEditor : NSObject
{
    GRDrawableObject *object;
}

- (void)unselect;

@end

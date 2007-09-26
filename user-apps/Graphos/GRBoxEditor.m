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

- (id)initInView:(GRDocView *)aView zoomFactor:(float)zf
{
    self = [super init];
    if(self)
    {
        controlPoints = [[NSArray alloc] initWithCapacity: 2];
    }
    return self;
}


@end

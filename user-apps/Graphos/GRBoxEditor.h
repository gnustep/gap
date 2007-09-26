//
//  GRBoxEditor.h
//  Graphos
//
//  Created by Riccardo Mottola on Tue Sep 18 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class GRDocView;

@interface GRBoxEditor : NSObject {
    NSArray *controlPoints;  
}

- (id)initInView:(GRDocView *)aView zoomFactor:(float)zf;

- (void)Draw;

@end

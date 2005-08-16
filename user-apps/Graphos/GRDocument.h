//
//  MyDocument.h
//  Draw
//
//  Created by Riccardo Mottola on Fri Aug 05 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//


#import <AppKit/AppKit.h>
#import "GRDocView.h"

@interface GRDocument : NSDocument
{
	GRDocView *docView;   
}
@end

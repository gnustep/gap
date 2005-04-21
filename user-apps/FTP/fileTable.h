//
//  fileTable.h
//  FTP
//
//  Created by Riccardo Mottola on Tue Apr 12 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface fileTable : NSObject {
    NSArray        *fileStructs;
}

- (void)initData:(NSArray *)fnames;

@end

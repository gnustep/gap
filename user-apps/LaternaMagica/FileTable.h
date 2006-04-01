//
//  FileTable.h
//  LaternaMagica
//
//  Created by Riccardo Mottola on Mon Jan 16 2006.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//
// The Data Source implementation for the TableView

#import <AppKit/AppKit.h>


@interface FileTable : NSObject {
    NSMutableArray *fileNames;
    NSMutableArray *filePaths;
}

- (void)addPath:(NSString *)filename;
- (NSString *)pathAtIndex :(int)index;
- (void)removeObjectAtIndex:(int)index;

@end

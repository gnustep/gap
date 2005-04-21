//
//  fileTable.m
//  FTP
//
//  Created by Riccardo Mottola on Tue Apr 12 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "fileTable.h"
#import "fileElement.h"


@implementation fileTable

- (void)initData:(NSArray *)fnames
{
    int i;
    
    fileStructs = [[NSArray arrayWithArray:fnames] retain];
    
    NSLog(@"names count: %d", [fileStructs count]);
}

- (void)dealloc
{
    [fileStructs release];
    [super dealloc];
}

/* methods implemented to follow the informal NSTableView protocol */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [fileStructs count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theElement;
    
    theElement = NULL;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [fileStructs count]);
    if ([[aTableColumn identifier] isEqualToString:@"filename"])
        theElement = [[fileStructs objectAtIndex:rowIndex] filename];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}

@end

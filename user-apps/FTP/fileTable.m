//
//  fileTable.m
//  FTP
//
//  Created by Riccardo Mottola on Tue Apr 12 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "fileTable.h"


@implementation fileTable

- (void)initData:(NSArray *)names
{
    int i;
    
    fileNames = [[NSArray arrayWithArray:names] retain];
    
    NSLog(@"names count: %d", [fileNames count]);
}

- (void)dealloc
{
    [fileNames release];
    [super dealloc];
}

/* methods implemented to follow the informal NSTableView protocol */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [fileNames count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theElement;
    
    theElement = NULL;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [fileNames count]);
    if ([[aTableColumn identifier] isEqualToString:@"filename"])
        theElement = [fileNames objectAtIndex:rowIndex];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}

@end

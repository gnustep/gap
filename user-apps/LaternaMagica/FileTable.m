//
//  FileTable.m
//  LaternaMagica
//
//  Created by Riccardo Mottola on Mon Jan 16 2006.
//  Copyright (c) 2006 __MyCompanyName__. All rights reserved.
//

#import "FileTable.h"


@implementation FileTable

- (id)init
{
    if (self = [super init])
    {
        NSLog(@"FileTable init");
        fileNames = [[NSMutableArray arrayWithCapacity:5] retain];
        filePaths = [[NSMutableArray arrayWithCapacity:5] retain];
    }
    return self;
}

- (void)dealloc
{
    [fileNames release];
    [filePaths release];
    [super dealloc];
}

- (void)addPath :(NSString*)path
{
    [filePaths addObject:path];
    [fileNames addObject:[path lastPathComponent]];
}

- (NSString *)pathAtIndex :(int)index
{
    return [filePaths objectAtIndex:index];
}

- (void)removeObjectAtIndex:(int)index
{
    [fileNames removeObjectAtIndex:index];
    [filePaths removeObjectAtIndex:index];
}


/* methods implemented to follow the informal NSTableView protocol */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [fileNames count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theElement;

    theElement = nil;

    NSParameterAssert(rowIndex >= 0 && rowIndex < [fileNames count]);
    if ([[aTableColumn identifier] isEqualToString:@"filename"])
        theElement = [fileNames objectAtIndex:rowIndex];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}
@end

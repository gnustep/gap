/*
 Project: FTP

 Copyright (C) 2005 Riccardo Mottola

 Author: Riccardo Mottola

 Created: 2005-04-12

 Table class for file listing

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
 */

#import "fileTable.h"
#import "fileElement.h"


@implementation fileTable

- (void)initData:(NSArray *)fnames
{
    fileStructs = [[NSArray arrayWithArray:fnames] retain];
    
    NSLog(@"names count: %d", [fileStructs count]);
}

- (void)dealloc
{
    [fileStructs release];
    [super dealloc];
}

- (fileElement *)elementAtIndex:(unsigned)index
{
    return [fileStructs objectAtIndex:index];
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

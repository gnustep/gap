/* 
   Project: LaternaMagica
   FileTable.m

   Copyright (C) 2006-2007 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2006-01-16

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
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import "FileTable.h"


@implementation FileTable

- (id)init
{
    if (self = [super init])
    {
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

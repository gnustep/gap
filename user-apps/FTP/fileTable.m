/*
 Project: FTP

 Copyright (C) 2005-2011 Riccardo Mottola

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
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "fileTable.h"
#import "fileElement.h"


@implementation fileTable

- (void)initData:(NSArray *)fnames
{
  int i;

  sortByIdent = nil;
  
  if (fileStructs)
    {
      [fileStructs release];
      [sortedArray release];
    }
  fileStructs = [[NSArray arrayWithArray:fnames] retain];
  sortedArray = [[NSMutableArray arrayWithCapacity: [fileStructs count]] retain];
  for (i = 0; i < [fileStructs count]; i++)
    {
      NSNumber *n;
      NSMutableDictionary *dict;
      fileElement *fe;

      fe = [fileStructs objectAtIndex: i];
      n = [NSNumber numberWithInt: i];
      dict = [NSMutableDictionary dictionary];
      [dict setObject: [fe filename] forKey: @"name"];
      [dict setObject: n forKey: @"row"];
      [sortedArray addObject: dict];
    }
}

- (void)dealloc
{
  [fileStructs release];
  [sortedArray release];
  [super dealloc];
}

- (fileElement *)elementAtIndex:(unsigned)index
{
    return [fileStructs objectAtIndex:index];
}

- (void)sortByIdent:(NSString *)idStr
{
  if ([idStr isEqualToString: sortByIdent])
    {
      NSLog(@"reverse");
    }
  else
    {
      NSLog(@"Sort by: %@", idStr);
    }
  sortByIdent = idStr;
}

/* methods implemented to follow the informal NSTableView protocol */
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [sortedArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    id theElement;
    int originalRow;

    theElement = NULL;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [sortedArray count]);
    originalRow = [[[sortedArray objectAtIndex: rowIndex] objectForKey: @"row"] intValue];
    if ([[aTableColumn identifier] isEqualToString:TAG_FILENAME])
        theElement = [[fileStructs objectAtIndex:originalRow] filename];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}

@end

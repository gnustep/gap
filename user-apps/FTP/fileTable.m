/*
 Project: FTP

 Copyright (C) 2005-2013 Riccardo Mottola

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
#import "AppController.h"

/* we sort the already existing sorted array which contains only the keys to sort on */
NSComparisonResult compareDictElements(id e1, id e2, void *context)
{
  NSString *s1;
  NSString *s2;
  NSComparisonResult r;
  enum sortOrderDef sortOrder;

  s1 = [(NSDictionary *)e1 objectForKey: @"name"];
  s2 = [(NSDictionary *)e2 objectForKey: @"name"];
  sortOrder = *(enum sortOrderDef *)context;

  r = [s1 compare: s2];
  if (sortOrder == descending)
    {
      if (r == NSOrderedAscending)
	r = NSOrderedDescending;
      else if (r == NSOrderedDescending)
	r = NSOrderedAscending;
    }
  return r;
}

@implementation FileTable

- (void)initData:(NSArray *)fnames
{
  NSUInteger i;

  sortByIdent = nil;
  
  if (fileStructs)
    {
      [fileStructs release];
      [sortedArray release];
    }
  fileStructs = [[NSMutableArray arrayWithArray:fnames] retain];
  sortedArray = [[NSMutableArray arrayWithCapacity: [fileStructs count]] retain];
  for (i = 0; i < [fileStructs count]; i++)
    {
      NSNumber *n;
      NSMutableDictionary *dict;
      FileElement *fe;

      fe = [fileStructs objectAtIndex: i];
      n = [NSNumber numberWithInt: i];
      dict = [NSMutableDictionary dictionary];
      [dict setObject: [fe name] forKey: @"name"];
      [dict setObject: n forKey: @"row"];
      [sortedArray addObject: dict];
    }
  sortOrder = undefined;
}

- (void)dealloc
{
  [fileStructs release];
  [sortedArray release];
  [super dealloc];
}

- (void)clear
{
  [fileStructs release];
  fileStructs = nil;
  [sortedArray release];
  sortedArray = nil;
}

- (void)addObject:(FileElement *)object
{
  NSNumber *n;
  NSMutableDictionary *dict;

  /* add the file element to the storage */
  [fileStructs addObject:object];

  /* keep the sorting map array in sync */
  n = [NSNumber numberWithInt: [fileStructs count]];
  dict = [NSMutableDictionary dictionary];
  [dict setObject: [object name] forKey: @"name"];
  [dict setObject: n forKey: @"row"];
  [sortedArray addObject: dict];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  NSUInteger originalRow;

  originalRow = (NSUInteger)[[[sortedArray objectAtIndex: index] objectForKey: @"row"] intValue];

  [fileStructs removeObjectAtIndex:originalRow];
  [sortedArray removeObjectAtIndex:index];
}
- (void)removeObject:(FileElement *)object
{
  NSUInteger index;
  NSNumber *n;
  NSUInteger i;

  index = [fileStructs indexOfObject:object];
  if (index == NSNotFound)
    {
      NSLog(@"Object not found, internal error");
      return;
    }

  n = [NSNumber numberWithInt: index];

  /* remove object from storage */
  [fileStructs removeObject:object];

  /* remove the object from the sorting map array */
  i = 0;
  while (i < [sortedArray count] && ![[[sortedArray objectAtIndex:i] objectForKey:@"row"] isEqual:n])
    i++;
  if (i == [sortedArray count])
    {
      NSLog(@"Object not found in sorted array, internal error");
      return;
    }
  [sortedArray removeObjectAtIndex:i];
}

/** returns the object after resolving sorting */
- (FileElement *)elementAtIndex:(NSUInteger)index
{
  NSUInteger originalRow;

  originalRow = (NSUInteger)[[[sortedArray objectAtIndex: index] objectForKey: @"row"] intValue];
  return [fileStructs objectAtIndex:originalRow];
}

- (void)sortByIdent:(NSString *)idStr
{
  if ([idStr isEqualToString: sortByIdent])
    {
      if (sortOrder == ascending)
	sortOrder = descending;
      else
	sortOrder = ascending;
    }
  else
    {
      NSLog(@"Sort by: %@", idStr);
      sortOrder = ascending;
    }
  sortByIdent = idStr;
  [sortedArray sortUsingFunction:compareDictElements context:&sortOrder];
}



/* methods implemented to follow the informal NSTableView protocol */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [sortedArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id theElement;
    NSInteger originalRow;

    theElement = NULL;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [sortedArray count]);
    originalRow = [[[sortedArray objectAtIndex: rowIndex] objectForKey: @"row"] intValue];
    if ([[aTableColumn identifier] isEqualToString:TAG_FILENAME])
        theElement = [[fileStructs objectAtIndex:originalRow] name];
    else
        NSLog(@"unknown table column ident");
    return theElement;
}

/* --- drag and drop ---  */
- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
  NSPasteboard *pboard;


  pboard = [info draggingPasteboard];
  if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
      NSArray *paths;

      paths = [pboard propertyListForType:NSFilenamesPboardType];
      if ([paths count] > 0)
        {
          if ([[aTableView target] dropValidate:self paths:paths])
            return NSDragOperationEvery;
        }
    }

  return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
  NSPasteboard *pboard;


  pboard = [info draggingPasteboard];
  if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
      NSArray *paths;

      paths = [pboard propertyListForType:NSFilenamesPboardType];
      if ([paths count] > 0)
        {
          [[aTableView target] dropAction:self paths:paths];
        }
    }
  
  return NO;
}


@end


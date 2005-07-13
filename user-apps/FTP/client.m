/*
 Project: FTP

 Copyright (C) 2005 Free Software Foundation

 Author: Riccardo Mottola

 Created: 2005-04-21

 Generic client class, to be subclassed.

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import "client.h"

@implementation client

- (void)dealloc
{
    if (homeDir)
        [homeDir release];
    if (workingDir)
        [workingDir release];
    if (workingDir)
        [workingDir release];
    [super dealloc];
}

- (NSString *)workingDir
{
    return workingDir;
}

- (NSString *)homeDir
{
    return homeDir;
}

- (void)setWorkingDirWithCString:(char *)dir
{
    [self setWorkingDir:[NSString stringWithCString:dir]];
}

- (void)setWorkingDir:(NSString *)dir
{
    if (workingDir)
        [workingDir release];
    workingDir = [[NSString stringWithString:dir] retain];
}

- (void)changeWorkingDir:(NSString *)dir
{
    [self setWorkingDir:dir];
}

- (NSArray *)workDirSplit
{
    NSMutableArray *reversedList;
    NSArray        *list;
    NSEnumerator   *en;
    NSString       *currElement;

    list = [workingDir pathComponents];


    reversedList = [NSMutableArray arrayWithCapacity:[list count]];
    en = [list reverseObjectEnumerator];
    while (currElement = [en nextObject])
            [reversedList addObject:currElement];
    return [reversedList retain];
}

- (NSArray *)dirContents
{
    NSLog(@"override me! dirContents superclass method");
    return nil;
}

- (BOOL)createNewDir:(NSString *)dir
{
    NSLog(@"override me! createNewDir superclass method");
    return NO;
}

- (void)deleteFile:(fileElement *)file beingAt:(int)depth
{
    NSLog(@"override me! deleteFile superclass method");
}


@end

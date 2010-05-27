/*
   Project: FTP

   Copyright (C) 2005-2010 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2005-04-09

   Local filesystem class

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

#include <stdlib.h>

#import "localclient.h"
#import "fileElement.h"

@implementation LocalClient

- (id)init
{
    if (!(self = [super init]))
        return nil;
    homeDir = [NSHomeDirectory() retain];
    return self;
}

/*
 creates a new directory
 tries to guess if the given dir is relative (no starting /) or absolute
 Is this portable to non-unix OS's?
 */
- (BOOL)createNewDir:(NSString *)dir
{
    NSFileManager *fm;
    NSString      *localPath;
    BOOL          isDir;

    fm = [NSFileManager defaultManager];
    if ([dir hasPrefix:@"/"])
    {
        NSLog(@"%@ is an absolute path", dir);
        localPath = dir;
    } else
    {
        NSLog(@"%@ is a relative path", dir);
        localPath = [[self workingDir] stringByAppendingPathComponent:dir];
    }
    if ([fm fileExistsAtPath:localPath isDirectory:&isDir] == YES)
        return isDir;
    if ([fm createDirectoryAtPath:localPath attributes:nil] == NO)
        return NO;
    else
        return YES;
}

- (NSArray *)dirContents
{
    NSFileManager   *fm;
    NSArray         *fileNames;
    NSEnumerator    *en;
    NSString        *fileName;
    NSMutableArray  *listArr;
    fileElement     *aFile;

    fm = [NSFileManager defaultManager];
    fileNames = [fm directoryContentsAtPath:workingDir];
    if (fileNames == nil)
        return nil;

    listArr = [NSMutableArray arrayWithCapacity:[fileNames count]];
    
    en = [fileNames objectEnumerator];
    while ((fileName = [en nextObject]))
    {
        NSString *p;
        NSDictionary *attr;

        p = [workingDir stringByAppendingPathComponent:fileName];
        attr = [fm fileAttributesAtPath :p traverseLink:YES];
        aFile = [[fileElement alloc] initWithFileAttributes:fileName :attr];
        [listArr addObject:aFile];
    }
    return [NSArray arrayWithArray:listArr];
}

- (void)deleteFile:(fileElement *)file beingAt:(int)depth
{
    NSString           *fileName;
    NSString           *localPath;
    NSFileManager      *fm;

    fm = [NSFileManager defaultManager];
    fileName = [file filename];
    localPath = [[self workingDir] stringByAppendingPathComponent:fileName];

    if ([fm removeFileAtPath:(NSString *)localPath handler:nil] == NO)
        NSLog(@"an error occoured during local delete");
}

@end

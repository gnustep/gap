/*
   Project: FTP

   Copyright (C) 2005 Riccardo Mottola

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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include <stdlib.h>

#import "localclient.h"
#import "fileElement.h"

@implementation localclient

- (id)init
{
    if (!(self = [super init]))
        return nil;
    homeDir = [NSHomeDirectory() retain];
    return self;
}

/* RM fixme: when do we release workingDir ? */
- (void)dealloc
{
    [homeDir release];
    [super dealloc];
}


/* RM : fixme put in a better max path limit */
/* path could be malloced form the correct strlen? */
/* all this should be rewritten using NSFileManager */
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
    while (fileName = [en nextObject])
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


@end

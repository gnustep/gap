/*

  TarArchive.h
  Zipper

  Copyright (C) 2012-2013 Free Software Foundation, Inc

  Authors: Dirk Olmes <dirk@xanthippe.ping.de>
           Riccardo Mottola <rm@gnu.org>
           Sebastian Reitenbach <sebastia@l00-bugdead-prods.de>

  This application is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
  or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details

 */

#import <Foundation/NSObject.h>
#import "Archive.h"

@interface TarArchive : Archive
{
}

- (int)expandFiles:(NSArray *)files withPathInfo:(BOOL)usePathInfo toPath:(NSString *)path;
- (NSArray *)listContents;

+ (void)createArchive:(NSString *)archivePath withFiles:(NSArray *)filenames archiveType:(ArchiveType) archiveType;

@end

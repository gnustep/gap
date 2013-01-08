/* 
   Project: LaternaMagica
   FileTable.h

   Copyright (C) 2006-2013 Riccardo Mottola

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

// The Data Source implementation for the TableView

#import <AppKit/AppKit.h>

@class LMImage;

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define NSUInteger unsigned
#define NSInteger int
#endif

@interface FileTable : NSObject
{
  /* files that will not be added */
  NSArray *filesToIgnore;

  NSMutableArray *images;
}

- (BOOL)addPathAndRecurse: (NSString*)path;
- (void)addPath:(NSString *)filename;
- (LMImage *)imageAtIndex :(NSUInteger)index;
- (NSString *)pathAtIndex :(NSUInteger)index;

/** removes an element at given index */
- (void)removeObjectAtIndex:(NSUInteger)index;

/** shuffles the elements randomly */
- (void)scrambleObjects;


@end

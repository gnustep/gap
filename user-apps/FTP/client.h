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

// this enables the output of NSDialogs
#define ENABLE_GUI_MESSAGES 0

#import <Foundation/Foundation.h>

#ifdef ENABLE_GUI_MESSAGES
#import <AppKit/AppKit.h>
#endif

#import "fileElement.h"


@interface client : NSObject
{
    NSString *workingDir;
    NSString *homeDir;
}

- (NSString *)workingDir;
- (void)setWorkingDirWithCString:(char *)dir;
- (void)setWorkingDir:(NSString *)dir;
- (void)changeWorkingDir:(NSString *)dir;
- (BOOL)createNewDir:(NSString *)dir;
- (void)deleteFile:(fileElement *)file beingAt:(int)depth;
- (NSArray *)workDirSplit;
- (NSArray *)dirContents;
- (NSString *)homeDir;
- (void)showAlertDialog:(NSString*)message;
@end



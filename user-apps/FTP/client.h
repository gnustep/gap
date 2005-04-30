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
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#import <Foundation/Foundation.h>


@interface client : NSObject
{
    NSString *workingDir;
    NSString *homeDir;
}

- (NSString *)workingDir;
- (void)setWorkingDirWithCString:(char *)dir;
- (void)setWorkingDir:(NSString *)dir;
- (NSArray *)workDirSplit;
- (NSArray *)dirContents;
- (NSString *)homeDir;
@end



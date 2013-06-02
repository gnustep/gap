/*
   Project: LaternaMagica

   Copyright (C) 2013 Free Software Foundation

   Author: multix

   Created: 2013-01-07 23:53:49 +0100 by multix

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

#import "LMImage.h"

@implementation LMImage

- (id)init
{
  self = [super init];
  if (self)
    {
      path = nil;
      name = nil;
      rotation = 0;
    }
  return self;
}

- (void) dealloc
{
  [path release];
  [name release];
  [super dealloc];
}

- (void) setPath:(NSString *)aPath
{
  [path release];
  path = [aPath retain];
  [name release];
  name = [[path lastPathComponent] retain];
}

- (NSString *)path
{
  return path;
}

- (NSString *)name
{
  return name;
}

- (void) setRotation: (unsigned)r
{
  rotation += r;
  rotation = rotation % 360;
}
- (unsigned) rotation
{
  return rotation;
}

@end

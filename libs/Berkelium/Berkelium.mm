/*
   Project: Berkelium

   Copyright (C) 2012 Free Software Foundation

   Author: Gregory John Casamento,,,

   Created: 2012-06-24 18:56:36 -0400 by heron

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

#import "Berkelium.h"
#include <berkelium/Berkelium.hpp>
#include <iostream>

static BerkeliumKit *_instance = nil;

@implementation BerkeliumKit

/**
 * Return a shared instance of Berkelium...
 */
+ (id) sharedBerkelium
{
  return [[self alloc] init];
}

/**
 * Initialize and return the instance.
 */
- (id) init
{
  if(_instance != nil)
    {
      [self release];
      return _instance;
    }

  if((self = [super init]) != nil)
    {
      _instance = self;
      Berkelium::init(Berkelium::FileString::empty());
    }

  return _instance;
}

/**
 * Cleanup after ourselves.
 */
- (void) dealloc
{
  [_instance release];
  Berkelium::destroy();
  [super dealloc];
}

/**
 * Periodic update of Berkelium... allow the framework to synchronize with 
 * events.
 */
- (void) update: (NSTimer *)timer
{
  Berkelium::update();
}
@end

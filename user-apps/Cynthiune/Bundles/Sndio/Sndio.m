/* Sndio.m - this file is part of Cynthiune
 *
 * Copyright (C) 2002-2004 Wolfgang Sourdeau
 *
 * Author: Wolfgang Sourdeau <wolfgang@contre.com>
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef _REENTRANT
#define _REENTRANT 1
#endif

#import <AppKit/NSApplication.h>

#import <Foundation/NSFileHandle.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSThread.h>

#import <errno.h>
#import <sys/ioctl.h>
#import <sndio.h>

#import <Cynthiune/CynthiuneBundle.h>
#import <Cynthiune/Output.h>

#import "Sndio.h"

#define LOCALIZED(X) _b ([Sndio class], X)
#define DspError(X) \
        NSLog (@"An error occured when sending '%s' ioctl to DSP:%s", \
               X, strerror(errno))

@implementation Sndio : NSObject

+ (NSString *) bundleDescription
{
  return @"Output plug-in for the OpenBSD sndio driver";
}

+ (NSArray *) bundleCopyrightStrings
{
  return [NSArray arrayWithObjects:
                    @"Copyright (C) 2012  Sebastian Reitenbach",
                  nil];
}

+ (BOOL) isThreaded
{
  return YES;
}

- (id) init
{
  if ((self = [super init]))
    {
      parentPlayer = nil;
      //hdl = sio_open(NULL, SIO_PLAY, 0);
      hdl = NULL;
      //par = NULL;
      //sio_initpar(&par);
      stopRequested = NO;
    }

  return self;
}

- (void) setParentPlayer: (id) aPlayer;
{
  parentPlayer = aPlayer;
}

- (BOOL) prepareDeviceWithChannels: (unsigned int) numberOfChannels
                           andRate: (unsigned long) sampleRate
{
  BOOL result = NO;

  NSLog(@"prepareDevice got called");

  if (hdl)
    sio_close(hdl);
  hdl = sio_open(NULL, SIO_PLAY, 0);
  sio_initpar(&par);
  par.pchan = numberOfChannels;
  par.rate = sampleRate;

  if (sio_setpar(hdl, &par))
    {
      NSLog(@"successfully set parameters");
      result = YES;
    }
  sio_start(hdl);
  return result;
}

- (BOOL) openDevice
{
NSLog(@"OpenDevice got called");
  if (hdl)
    {
NSLog(@"OpenDevice got called, hdl was set");
      sio_start(hdl);
      return YES;
    }
  else
    {
NSLog(@"OpenDevice got called, hdl was NULL");
      hdl = sio_open(NULL, SIO_PLAY, 0);
      sio_start(hdl);
      return YES;
    }
}

- (void) closeDevice
{
  while (stopRequested)
    [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.01]];
NSLog(@"close device got called!");
  sio_close(hdl);
  hdl = NULL;
}

- (void) threadLoop
{
  NSAutoreleasePool *pool;
  int bufferSize;
  
  pool = [NSAutoreleasePool new];

  while (!stopRequested)
    {
      bufferSize = [parentPlayer readNextChunk: buffer
				withSize: DEFAULT_BUFFER_SIZE];
      if (bufferSize > 0)
        sio_write(hdl, buffer, bufferSize);
	if ([pool autoreleaseCount] > 50)
	  [pool emptyPool];
    }

  stopRequested = NO;
  [pool release];
}

- (BOOL) startThread
{
  [NSThread detachNewThreadSelector: @selector (threadLoop)
            toTarget: self
            withObject: nil];

  return YES;
}

- (void) stopThread
{
  stopRequested = YES;
}

@end

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

#import <Foundation/NSByteOrder.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSLock.h>

#import <errno.h>
#import <sys/ioctl.h>
#import <sndio.h>

#import <Cynthiune/CynthiuneBundle.h>

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
      hdl = NULL;
      devlock = [NSLock new];
      stopRequested = NO;
    }

  return self;
}

/* FIXME : this is never called */
- (void)dealloc
{
  [devlock release];
  [super dealloc];
}

- (void) setParentPlayer: (id) aPlayer;
{
  parentPlayer = aPlayer;
}

- (BOOL) prepareDeviceWithChannels: (unsigned int) numberOfChannels
                           andRate: (unsigned long) sampleRate
	       	    withEndianness: (Endianness) e;
{
  BOOL result = NO;
  channels = numberOfChannels;
  rate = sampleRate;
  endianness = e;

  NSLog(@"prepareDevice got called, channels: %u sampleRate: %lu, endianness: %i", numberOfChannels, sampleRate, e);

  [devlock lock];
  if (hdl) {
    NSLog(@"prepareDevice: HDL was set, going to close it!");
    sio_close(hdl);
    hdl = NULL;
  } else {
    NSLog(@"prepareDevice: HDL was NULL, just going to open!");
  }
  hdl = sio_open(NULL, SIO_PLAY, 0);
  sio_initpar(&par);
  par.pchan = numberOfChannels;
  par.rate = sampleRate;
  if (e == 0)
    {
      if (NSHostByteOrder() == NS_LittleEndian)
        { 
	  NSLog(@"Native Endianness: LittleEndian");
          par.le = 1;
	}
      else
	{
	  NSLog(@"Native Endianness: BigEndian");
	  par.le = 2;
	}
    }

  if (e == 1)
    par.le = 1;
  if (e == 2)
    par.le = 0;

  if (sio_setpar(hdl, &par))
    {
      NSLog(@"successfully set parameters");
      result = YES;
    } else {
      NSLog(@"NOT successfully set parameters");
    }
NSLog(@"prepareDevice: calling sio_start");
  sio_start(hdl);
  [devlock unlock];
  return result;
}

- (BOOL) openDevice
{
  BOOL result = NO;
NSLog(@"OpenDevice got called");
  result = [self prepareDeviceWithChannels: channels
		andRate: rate
		withEndianness: endianness];
   return result;
}

- (void) closeDevice
{
  while (stopRequested)
    [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.01]];
NSLog(@"close device got called!");
  [devlock lock];
  sio_close(hdl);
  [devlock unlock];
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
      [devlock lock];
      if (bufferSize > 0 && hdl)
        sio_write(hdl, buffer, bufferSize);
      [devlock unlock];
      if ([pool autoreleaseCount] > 50)
	[pool emptyPool];
    }
NSLog(@"threadLoop: stopping thread");
  stopRequested = NO;
  [pool release];
}

- (BOOL) startThread
{
  NSLog(@"startThread called");
  [NSThread detachNewThreadSelector: @selector (threadLoop)
            toTarget: self
            withObject: nil];

  return YES;
}

- (void) stopThread
{
  NSLog(@"stopThread called");
  stopRequested = YES;
}

@end

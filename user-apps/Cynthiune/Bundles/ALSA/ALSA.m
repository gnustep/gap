/* ALSA.m - this file is part of Cynthiune
 *
 * Copyright (C) 2010 Free Software Foundation, Inc.
 *
 * Author: Yavor Doganov <yavor@gnu.org>
 *
 * Cynthiune is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * Cynthiune is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifndef _REENTRANT
#define _REENTRANT 1
#endif

#import <AppKit/AppKit.h>

#import <Cynthiune/CynthiuneBundle.h>
#import <Cynthiune/Output.h>
#import <Cynthiune/utils.h>

#include <alsa/asoundlib.h>

#import "ALSA.h"

#define LOCALIZED(X) _b ([ALSA class], X)

static char *device = "default";

@implementation ALSA
+ (NSString *) bundleDescription
{
  return LOCALIZED (@"Output plug-in for ALSA");
}

+ (NSArray *) bundleCopyrightStrings
{
  return [NSArray arrayWithObjects:
                    LOCALIZED (@"Copyright (C) 2010 Free Software Foundation,"
			       @" Inc."),
		  nil];
}

+ (BOOL) isThreaded
{
  return YES;
}

- (void) setParentPlayer: (id) aPlayer;
{
  parentPlayer = aPlayer;
}

- (id) init
{
  if ((self = [super init]))
    {
      parentPlayer = nil;
      pcm_handle = NULL;
      channels = 0;
      rate = 0;
      stopRequested = NO;
    }

  return self;
}

- (BOOL) openDevice
{
  int err;
  BOOL result = NO;

  if ((err = snd_pcm_open (&pcm_handle, device, SND_PCM_STREAM_PLAYBACK, 0))
      < 0)
    NSRunAlertPanel (LOCALIZED (@"Error"),
		     LOCALIZED (@"Failed to open the ALSA device:\n%s"),
		     LOCALIZED (@"OK"), NULL, NULL, snd_strerror (err));
  else if ((err = snd_pcm_set_params (pcm_handle, SND_PCM_FORMAT_S16,
				      SND_PCM_ACCESS_RW_INTERLEAVED,
				      channels, rate, 1, 100000)) < 0)
    NSRunAlertPanel (LOCALIZED (@"Error"),
		     LOCALIZED (@"Failed to set device parameters:\n%s"),
		     LOCALIZED (@"OK"), NULL, NULL, snd_strerror (err));
  else if ((err = snd_pcm_prepare (pcm_handle)) < 0)
    NSRunAlertPanel (LOCALIZED (@"Error"),
		     LOCALIZED (@"Failed to prepare the ALSA device for "
				@"playing:\n%s"),
		     LOCALIZED (@"OK"), NULL, NULL, snd_strerror (err));
  else
    result = YES;

  return result;
}

- (BOOL) prepareDeviceWithChannels: (unsigned int) numberOfChannels
                           andRate: (unsigned long) sampleRate
{
  channels = numberOfChannels;
  rate = sampleRate;

  return YES;
}

- (void) closeDevice
{
  while (stopRequested)
    [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
  snd_pcm_close (pcm_handle);
}

- (void) threadLoop
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  while (!stopRequested)
    {
      snd_pcm_sframes_t written;
      snd_pcm_uframes_t frames;
      int bufferSize;

      bufferSize = [parentPlayer readNextChunk: buffer
				      withSize: DEFAULT_BUFFER_SIZE];

      if (bufferSize > 0)
	{
	  frames = snd_pcm_bytes_to_frames (pcm_handle, bufferSize);
	  written = snd_pcm_writei (pcm_handle, buffer, frames);

	  if (written < 0)
	    {
	      NSLog (@"Failed writing to the ALSA device:\n"
		     @"%s, trying to recover.\n", snd_strerror (written));
	      snd_pcm_recover (pcm_handle, written, 0);
	    }
	}

      if ([pool autoreleaseCount] > 50)
	[pool emptyPool];
    }

  stopRequested = NO;
  [pool release];
}

- (BOOL) startThread
{
  [NSThread detachNewThreadSelector: @selector(threadLoop)
            toTarget: self
            withObject: nil];

  return YES;
}

- (void) stopThread
{
  stopRequested = YES;
}
@end

/* 
   Project: AudioMixer
   SoundDevice.m

   Sound Device Interface

   Copyright (C) 2011 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2011-05-23 23:55:14 +0200 by Riccardo Mottola


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
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
*/

#include <linux/soundcard.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>

#import <Foundation/Foundation.h>
#import <SoundDevice.h>

// good for GLIBC, others might have int (MUSL?)
#define IOCTL_TYPE unsigned long

@implementation SoundDevice

- (void)dealloc
{
  if (mixerFd > 0)
    close(mixerFd);

  [super dealloc];
}

- (id)init
{
  if ((self = [super init]))
    {
      IOCTL_TYPE tempOutMain;
      IOCTL_TYPE long mask;

      mixerFd = -1;
      tempOutMain = 0;
      isStereo = NO;

      if ((mixerFd = open("/dev/mixer", O_RDWR)) < 0)
	{
	  NSLog(@"opening of mixer failed");
	}


      if (mixerFd)
        {
          isStereo = YES;
          if (ioctl(mixerFd, SOUND_MIXER_READ_STEREODEVS, &mask) < 0)
            {
              NSLog(@"Mixer is Mono");
              isStereo = NO;
            }
          else
            {
              NSLog(@"Mixer is Stereo");
            }
          if (ioctl(mixerFd, SOUND_MIXER_READ_VOLUME, &tempOutMain) < 0)
            {
              NSLog(@"Error reading main output volume");
            }
          NSLog(@"output main: %lu", tempOutMain);

          outMainLeft = tempOutMain & 0xff;
          outMainRight = (tempOutMain >> 8) & 0xff;
          NSLog(@"output main: %d %d", outMainLeft, outMainRight);
        }
    }

  return self;
}
- (int) outMainLeft
{
  return outMainLeft;
}

- (int) outMainRight
{
  return outMainRight;
}

- (int) outMainLevel
{
  int level;

  level = (outMainLeft + outMainRight) / 2;
  return level;
}

- (int) outMainBalance
{
  int balance;

  balance = (outMainRight - outMainLeft);

  return balance;
}

- (void) setMainLevel: (int)lev withBalance: (int)bal
{
  IOCTL_TYPE tempOutMain;
  int scaledBalance;

  scaledBalance = (bal * lev) / 200;
  outMainLeft  = lev - scaledBalance;
  outMainRight = lev + scaledBalance;

  tempOutMain = ((outMainRight & 0xff) << 8) | (outMainLeft & 0xff);
  NSLog(@"output main to set: %d %d -> %lu", outMainLeft, outMainRight, tempOutMain);

  outMainLeft = tempOutMain & 0xff;
  outMainRight = (tempOutMain >> 8) & 0xff;
  NSLog(@"output main calc back: %d %d", outMainLeft, outMainRight);
  if (ioctl(mixerFd, SOUND_MIXER_WRITE_VOLUME, &tempOutMain) < 0)
    {
      NSLog(@"Error setting output volume");
    }

  outMainLeft = tempOutMain & 0xff;
  outMainRight = (tempOutMain >> 8) & 0xff;
  NSLog(@"output main read back: %d %d (%lu)", outMainLeft, outMainRight, tempOutMain);
}

@end

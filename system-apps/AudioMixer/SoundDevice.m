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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#include <soundcard.h>
#include <fcntl.h>
#include <unistd.h>

#import <Foundation/Foundation.h>
#import <SoundDevice.h>


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
      int tempOutMain;

      mixerFd = -1;
      tempOutMain = 0;

      if ((mixerFd = open("/dev/mixer", O_RDWR)) < 0)
	{
	  NSLog(@"opening of mixer failed");
	}


      if (ioctl(mixerFd, MIXER_READ(SOUND_MIXER_VOLUME), &tempOutMain) < 0)
	{
	  NSLog(@"Error reading main output volume");
	}
      NSLog(@"output main: %d", tempOutMain);

      outMainLeft = tempOutMain & 0xff;
      outMainRight = (tempOutMain >> 8) & 0xff;
      NSLog(@"output main: %d %d", outMainLeft, outMainRight);
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

  balance = outMainRight - outMainLeft;

  return balance;
}

- (void) setMainLevel: (int)lev withBalance: (int)bal
{
  int tempOutMain;

  outMainLeft  = lev - (bal/2);
  outMainRight = lev + (bal/2);

  tempOutMain = (outMainLeft & 0xff) | ((outMainRight & 0xff) << 8);
  NSLog(@"output main to set: %d %d", outMainLeft, outMainRight);
  if (ioctl(mixerFd, MIXER_WRITE(SOUND_MIXER_VOLUME), &tempOutMain) < 0)
    {
      NSLog(@"Error setting output volume");
    }

  outMainLeft = tempOutMain & 0xff;
  outMainRight = (tempOutMain >> 8) & 0xff;
  NSLog(@"output main read back: %d %d", outMainLeft, outMainRight);
}

@end

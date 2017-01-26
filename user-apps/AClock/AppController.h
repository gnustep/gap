/*
 Project: AClock
 AppController.h

 Copyright (C) 2003-2017 GNUstep Application Project

 Author: Alexander Malmberg
         Banlu Kemiyatorn 
         Gürkan Sengün
         Ing. Riccardo Mottola <rm@gnu.org>

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


#import <AppKit/AppKit.h>
#import "Clock.h"
#import <math.h>

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4) && !defined(CGFloat)
#define NSUInteger unsigned
#define NSInteger int
#define CGFloat float
#endif

@interface AppController : NSObject
{
  id faceColorW;
  id ampmSwitch;
  id cuckooSwitch;
  id ringSwitch;
  id shadowSwitch;
  id transSlider;
  id handColorW;
  id secColorW;
  id frameColorW;
  id prefPanel;
  id markColorW;
  id freqSlider;
  id freqText;
  id secondSwitch;
  id numberPopUp;
  id alarmWindow;
  id alarmClock;
  id ringSlider;
  id incsVolume;
  id ringText;


  IBOutlet Clock *_clock;
  IBOutlet Clock *bigClock;
  NSTimer *timer;
  BOOL doFloor;
}
- (IBAction) openPreferences: (id)sender;
- (IBAction) setFrameColor: (id)sender;
- (IBAction) setFaceColor: (id)sender;
- (IBAction) setFaceTransparency: (id)sender;
- (IBAction) setShowsAMPM: (id)sender;
- (IBAction) setShadow:(id)sender;
- (IBAction) setSecondHandColor: (id)sender;
- (IBAction) setHandColor: (id)sender;
- (IBAction) setMarkColor: (id)sender;
- (IBAction) setFrequency: (id)sender;
- (IBAction) setSecond: (id)sender;
- (IBAction) setNumberType: (id)sender;
- (IBAction) playCuckoo;
- (IBAction) setCuckoo: (id) sender;
- (IBAction) setRing: (id) sender;
- (IBAction) stopRing: (id)sender;
- (IBAction) setRingLoop: (id) sender;
- (IBAction) setShowsAMPM: (id)sender;
- (IBAction) setIncreasesVolume: (id)sender;
- (IBAction) clockUpdate: (id)sender;

@end

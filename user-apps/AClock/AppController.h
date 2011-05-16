/*
 Project: AClock
 AppController.h

 Copyright (C) 2003-2011 GNUstep Application Project

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


  Clock *_clock;
  Clock *bigClock;
  NSTimer *timer;
  BOOL doFloor;
}
- (void) openPreferences: (id)sender;
- (void) setFrameColor: (id)sender;
- (void) setFaceColor: (id)sender;
- (void) setFaceTransparency: (id)sender;
- (void) setShowsAMPM: (id)sender;
- (void) setShadow:(id)sender;
- (void) setSecondHandColor: (id)sender;
- (void) setHandColor: (id)sender;
- (void) setMarkColor: (id)sender;
- (void) setFrequency: (id)sender;
- (void) setSecond: (id)sender;
- (void) setNumberType: (id)sender;
- (void) playCuckoo;
@end

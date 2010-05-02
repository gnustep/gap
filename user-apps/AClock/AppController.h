/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "Clock.h"
#include <math.h>

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
@end

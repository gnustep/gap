/* PreferencesController 

*/
#include "math.h"
#include "GNUstep.h"
#import "PreferencesController.h"

#define TAG_FULLSCREEN 10
#define TAG_TIMEFORM   11
#define TAG_OVERLAY    12
#define TAG_FONT       14
#define TAG_PICKFONT   15
#define TAG_ANALOG     16
#define TAG_ALBUM      20

#define dfltmgr [NSUserDefaults standardUserDefaults]
#define TABVIEW(tag) [[tabView tabViewItemAtIndex: tag] view]

NSString *DFullScreen = @"FullScreen";
NSString *DStartTime = @"StartTime";
NSString *DStopTime = @"StopTime";
NSString *DAlbum = @"Album";
NSString *DSpeed = @"Speed";
NSString *DShowOverlay = @"ShowOverlay";
NSString *DOverlayInfo = @"OverlayInfo";
NSString *DFontName = @"FontName";
NSString *DAnalogClock = @"AnalogClock";
NSString *DOffKey = @"OffKey";
NSString *DInfoKey = @"InfoKey";
NSString *DBackKey = @"BackKey";
NSString *DSpeedDownKey = @"SpeedDownKey";
NSString *DSpeedUpKey = @"SpeedUpKey";
NSString *DToggleScreenKey = @"ToggleScreenKey";



static PreferencesController *sharedController = nil;

@implementation PreferencesController

+ sharedPreferences
{
  if (sharedController == nil)
    {
      sharedController = [[PreferencesController alloc] init];
    }
  return sharedController;
}

- init
{
  NSArray *defKeys;
  NSArray *defObjs;
  NSUserDefaults *mgr = dfltmgr; 
  [super init];
  
  if ([NSBundle loadNibNamed: @"Preferences" owner: self] == NO)
    {
    NSLog(@"Could not load preferences nib");
    return nil;
    }

  defKeys = [NSArray arrayWithObjects:
		     DFullScreen,
		     DStartTime,
		     DStopTime,
		     DSpeed,
		     DShowOverlay,
		     DOverlayInfo,
		     DFontName,
		     DAnalogClock,
		     DOffKey,
		     DInfoKey,
		     DBackKey,
		     DSpeedDownKey,
		     DSpeedUpKey,
		     DToggleScreenKey,
		     nil];
  
    defObjs = [NSArray arrayWithObjects:
		       [NSNumber numberWithBool: NO],
		       [NSNumber numberWithFloat: 730],
		       [NSNumber numberWithFloat: 2259],
		       [NSNumber numberWithFloat: 120],
	               [NSNumber numberWithBool: NO],
                [NSNumber numberWithInt: 0],
		       @"Helvetica",
	               [NSNumber numberWithBool: NO],
		       @"r",
		       @"y",
		       @"u",
		       @"i",
		       @"o",
		       @"f",
		       nil];
  [mgr registerDefaults: 
	 [NSDictionary dictionaryWithObjects: defObjs forKeys: defKeys]];
  return self;
}

- (IBAction)showPreferences:(id)sender
{
#if 1
  if ([[tabView window] isVisible])
    [[tabView window] orderOut: sender];
  else 
#endif
    {
    [[tabView window] orderFront: sender];
    [self loadValues];
    }
}

- (void) changeFont: (id)sender
{
  font = [sender convertFont: font];
  NSLog(@"Preferences got change font. New %@", font);
  if (font)
    {
      id view;
      [dfltmgr setObject: [font fontName] forKey: DFontName];
      view = [TABVIEW(0) viewWithTag: TAG_FONT];
      [(NSControl *)view setStringValue: [font fontName]];
    }
}

- (void) loadValues
{
  int info, c;
  NSView *view;
  NSForm *form;
  NSString *str;
  NSUserDefaults *mgr = dfltmgr; 
  
  view = [TABVIEW(0) viewWithTag: TAG_FULLSCREEN];
  [(NSButton *)view setState: [mgr integerForKey: DFullScreen]];
  form = [TABVIEW(0) viewWithTag: TAG_TIMEFORM];
  [[form cellAtIndex: 0] setIntValue: [mgr integerForKey: DStartTime]];
  [[form cellAtIndex: 1] setIntValue: [mgr integerForKey: DStopTime]];
  [[form cellAtIndex: 2] setIntValue: [mgr integerForKey: DSpeed]];
  
  info = [mgr integerForKey: DOverlayInfo];
  view = [TABVIEW(0) viewWithTag: TAG_OVERLAY];
  [(NSButton *)[(NSMatrix *)view cellAtRow: 0 column: 0] setState: ((info & MAX_CLK) > 0)];
  [(NSButton *)[(NSMatrix *)view cellAtRow: 1 column: 0] setState: ((info & INFO_WEATHER) > 0)];
  [(NSButton *)[(NSMatrix *)view cellAtRow: 2 column: 0] setState: ((info & INFO_PHOTO) > 0)];  
  
  view = [TABVIEW(0) viewWithTag: TAG_ANALOG];
  c = (info & MAX_CLK);
  if (c > 0)
    [(NSPopUpButton *)view selectItemAtIndex: (c-1)];
  
  str = [mgr stringForKey: DFontName];
  font = [[NSFont fontWithName: str size: 12.0] retain];
  view = [TABVIEW(0) viewWithTag: TAG_FONT];
  [(NSControl *)view setStringValue: str];
  
  view = [TABVIEW(0) viewWithTag: TAG_ANALOG];
  [(NSButton *)view setState: [mgr integerForKey: DAnalogClock]];
  
  form = [TABVIEW(1) viewWithTag: TAG_ALBUM];
  str = [mgr stringForKey: DAlbum];
  if (str == nil)
    str = @"";
  [[form cellAtIndex: 0] setStringValue: str];
}

- (IBAction)setValue: (id)sender
{
  int tag, info, c;
  float value;
  
  tag = [sender tag];
  switch (tag)
    {
    case TAG_FULLSCREEN:
      [dfltmgr setInteger: [sender state] forKey: DFullScreen];
      break;
    case TAG_TIMEFORM:
      if ([sender tag] > 0)
        {
          value = [[sender cellAtIndex: 0] intValue];
          [dfltmgr setInteger: value forKey: DStartTime];
          value = [[sender cellAtIndex: 1] intValue];
          [dfltmgr setInteger: value forKey: DStopTime];
          value = [[sender cellAtIndex: 2] intValue];
          [dfltmgr setInteger: value forKey: DSpeed];
        }
      else
        {
        value = [sender intValue];
        NSLog(@"Got NSForm value from cell");
        }
      break;
    case TAG_OVERLAY:
      info = 0;
      if ([sender tag] > 0)
        {
	int c, type;
          c = ([[sender cellAtRow: 0 column: 0] state] == NSOnState) ? 1 : 0;
          info += ([[sender cellAtRow: 1 column: 0] state] == NSOnState) ? 4 : 0;
          info += ([[sender cellAtRow: 2 column: 0] state] == NSOnState) ? 8 : 0;
	  type = [(NSPopUpButton *)[TABVIEW(0) viewWithTag: TAG_ANALOG] indexOfSelectedItem];
	  if (c)
	    info += (type+1);
          [dfltmgr setInteger: info forKey: DOverlayInfo];
        }
      else
        {
          info = ([sender state] == NSOnState) ? 1 : 0;
          info *= pow(2, [[TABVIEW(0) viewWithTag: TAG_OVERLAY] selectedRow]);
          NSLog(@"Set overlay state to %d", info);
        }
      [dfltmgr setBool: (info) ? YES : NO forKey: DShowOverlay];
      break;
    case TAG_PICKFONT:
      {
        NSFontManager *fmgr = [NSFontManager sharedFontManager];
        [fmgr orderFrontFontPanel: self];
        [fmgr setDelegate: self];
        if (font)
          [fmgr setSelectedFont: font isMultiple: NO];
      }
      break;
    case TAG_ANALOG:
      c = [(NSPopUpButton *)sender indexOfSelectedItem];
      info = [dfltmgr integerForKey: DOverlayInfo];
      if ((info & MAX_CLK))
	{
	info = (info & 0xff00);
	info += (c+1);
	[dfltmgr setInteger: info forKey: DOverlayInfo];
	}
      break;
    case TAG_ALBUM:
      [dfltmgr setObject: [[sender cellAtIndex: 0] stringValue] forKey: DAlbum];
      break;
    default:
      break;
    }
}

- (void) addPreferenceView: (id)theView withName: (NSString *)name
{
  if ([tabView indexOfTabViewItemWithIdentifier: theView] == NSNotFound)
    {
    NSTabViewItem *titem;
    titem = [[NSTabViewItem alloc] initWithIdentifier:  theView];
    [titem setLabel: name];
    [titem setView: theView];
    [tabView addTabViewItem: titem];
    }
}


@end

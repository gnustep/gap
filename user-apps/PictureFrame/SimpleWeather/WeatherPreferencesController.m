/* WeatherPreferencesController 

*/
#include "math.h"
#import "WeatherPreferencesController.h"

#define TAG_ZIP 	10
#define TAG_SOURCE   	11
#define TAG_UNITS	12
#define TAG_WWW		13
#define TAG_WWWARGS	14

#define dfltmgr [NSUserDefaults standardUserDefaults]

NSString *DZipCode = @"ZipCode";
NSString *DWeatherSource = @"WeatherSource";
NSString *DUnits = @"Units";
NSString *DWWW = @"WWW";
NSString *DWWWArgs = @"WWWArgs";

static WeatherPreferencesController *sharedController = nil;

@implementation WeatherPreferencesController

+ sharedPreferences
{
  if (sharedController == nil)
    {
      sharedController = [[WeatherPreferencesController alloc] init];
    }
  return sharedController;
}

- init
{
  NSArray *defKeys;
  NSArray *defObjs;
  NSUserDefaults *mgr = dfltmgr; 
  [super init];
  
  if ([NSBundle loadNibNamed: @"WeatherPreferences" owner: self] == NO)
    {
    NSLog(@"Could not load preferences nib");
    return nil;
    }

  defKeys = [NSArray arrayWithObjects:
		     DZipCode,
		     DWeatherSource,
		     DUnits,
		     DWWW,
		     DWWWArgs,
		     nil];
  
    defObjs = [NSArray arrayWithObjects:
    			@"80305",
			@"NWS",
			@"English",
			@"w3m",
			[NSArray arrayWithObjects: @"-dump_source", nil],
		       nil];
  [mgr registerDefaults: 
	 [NSDictionary dictionaryWithObjects: defObjs forKeys: defKeys]];
  return self;
}

- (IBAction) loadValues: (id)sender
{
  NSView *view;
  NSForm *form;
  NSString *str;
  NSUserDefaults *mgr = dfltmgr; 
  
  str = [mgr stringForKey: DZipCode];
  form = [otherView viewWithTag: TAG_ZIP];
  [[form cellAtIndex: 0] setObjectValue: str];
    
  str = [mgr stringForKey: DWeatherSource];
  view = [otherView viewWithTag: TAG_SOURCE];
  if ([str length] > 0)
    [(NSPopUpButton *)view selectItemWithTitle: str];

  str = [mgr stringForKey: DUnits];
  view = [otherView viewWithTag: TAG_UNITS];
  if ([str length] > 0)
    [(NSPopUpButton *)view selectItemWithTitle: str];
  
  form = [otherView viewWithTag: TAG_WWW];
  if (form)
    {
      str = [mgr stringForKey: DWWW];
      [[form cellAtIndex: 0] setObjectValue: str];
      str = [[mgr stringForKey: DWWWArgs] componentsJoinedByString: @" "];
      [[form cellAtIndex: 1] setObjectValue: str];
    }
  
}

- (IBAction)setValue: (id)sender
{
  int tag;
  NSString *str;
  
  tag = [sender tag];
  switch (tag)
    {
    case TAG_ZIP:
      str = [[sender cellAtIndex: 0] stringValue];
      if ([str length])
	[dfltmgr setObject: str forKey: DZipCode];
      break;
    case TAG_SOURCE:
      str = [(NSPopUpButton *)sender titleOfSelectedItem];
      [dfltmgr setObject: str forKey: DWeatherSource];
      break;
    case TAG_UNITS:
      str = [(NSPopUpButton *)sender titleOfSelectedItem];
      [dfltmgr setObject: str forKey: DUnits];
      break;
    case TAG_WWW:
      str = [[sender cellAtIndex: 0] stringValue];
      if ([str length])
	[dfltmgr setObject: str forKey: DWWW];
      str = [[sender cellAtIndex: 1] stringValue];
      if ([str length] == 0)
	[dfltmgr setObject: [NSArray array]  forKey: DWWWArgs];
      else
	[dfltmgr setObject: [str componentsSeparatedByString: @" "] 
		    forKey: DWWWArgs];
      break;
    default:
      break;
    }
}

- (id) preferenceView
{
  return otherView;
}

- (NSString *) preferenceName
{
  return @"Weather";
}


@end

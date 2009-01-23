/* WeatherView

        Written: Adam Fedor <fedor@qwest.net>
        Date: Jun 2007
*/

#import "WeatherView.h"
#import "WeatherDataParser.h"
#import "WeatherPreferencesController.h"
#include "GNUstep.h"
#include <math.h>

#define dfltmgr [NSUserDefaults standardUserDefaults]

#define DEFAULT_STATION @"KBJC"
#define DEFAULT_FORMAT  @"NWS"
#define DEFAULT_ZIP     @"80305"
#define UPDATE_INTERVAL 500

#define WHITE [NSColor whiteColor]
#define RED   [NSColor colorWithCalibratedRed: 1.0 green: 0.5 blue: 0.5 alpha: 1.0]
#define BLUE  [NSColor colorWithCalibratedRed: 0.5 green: 0.5 blue: 1.0 alpha: 1.0]

typedef struct _finfo_t
{
  NSRect frame;
  NSString *fname;
  NSColor *fcolor;
  int maxlength;
} finfo_t;

/* Define locations and sizes in terms of percent of the size of the frame */
/* Return a decent font size */
static int
p2f(double perc, NSRect frame)
{
  int fsize = perc * NSHeight(frame);
  /* Make it even */
  fsize = 2*ceil((double)fsize/2);
  if (fsize < 12)
    fsize = 12;
  return fsize;
}
static int
p2h (double perc, NSRect frame)
{
  return perc * NSHeight(frame);
}
static int
p2w (double perc, NSRect frame)
{
  return perc * NSWidth(frame);
}

int
WMDrawString(double x, double y, NSString *str, finfo_t finfo, double fsize)
{
  NSPoint point;
  NSDictionary *fdict;
  NSFont *font;
  
  point = NSMakePoint(p2h(x, finfo.frame), p2h(y, finfo.frame));
  fsize = p2f(fsize, finfo.frame);
  font = [NSFont fontWithName: finfo.fname size: fsize];
  
  fdict = [NSDictionary dictionaryWithObjectsAndKeys: font, 
			NSFontAttributeName, 
			finfo.fcolor,
			NSForegroundColorAttributeName,
			nil];
  if (finfo.maxlength && [str length] > finfo.maxlength)
    str = [str substringWithRange: NSMakeRange(0, finfo.maxlength)];
  [str drawAtPoint: point withAttributes: fdict];
  
  return 0;
}  

@implementation WeatherView

- (NSImage *)imageWithName: (NSString *)imageName
{
  NSBundle *bundle;
  NSString *path;
  
  bundle = [NSBundle bundleForClass: [self class]];
  path = [bundle pathForResource: imageName ofType: nil];
  if (path == nil)
    {
      NSLog(@"Failed to find imageWithName: %@", imageName);
      path = [bundle pathForResource: @"na" ofType: @"png"];
      if (path == nil)
        return nil;
    }
  return AUTORELEASE([[NSImage alloc] initWithContentsOfFile: path]);
}


- (void) DrawCurrent
{
  finfo_t finfo;
  NSString *str, *value;
  NSDictionary *dict = [weatherDataParser weatherDictionary];
  
  finfo.fname = [dfltmgr objectForKey: @"FontName"];
  if (finfo.fname == nil)
    finfo.fname = @"Helvetica";
  finfo.fcolor = WHITE;
  finfo.frame = [self frame];
  finfo.maxlength = 18;

  WMDrawString(0, 0.80, @"Current", finfo, 0.16);
  value = [dict objectForKey: @"Temperature"];
  if (value == nil)
    value = @"NA";
  str = [NSString stringWithFormat: @"%@%C", value, 0x02da];
  finfo.maxlength = 4;
  WMDrawString(0.10, 0.53, str, finfo, 0.24);
  value = [dict objectForKey: @"Description"];
  finfo.maxlength = 18;
  WMDrawString(0, 0.40, value, finfo, 0.10);  
  value = [dict objectForKey: @"Wind"];
  str = [NSString stringWithFormat: @"Wind: %@", value];
  finfo.maxlength = 18;
  WMDrawString(0, 0.30, str, finfo, 0.08);
  value = [dict objectForKey: @"Humidity"];
  str = [NSString stringWithFormat: @"Humidity: %@%%", value];
  WMDrawString(0, 0.20, str, finfo, 0.08);
  
#if 0
  value = [dict objectForKey: @"Pressure"];
  str = [NSString stringWithFormat: @"P: %@%%", value];
  WMDrawString(100, 0.20, str, finfo, 0.08);
#endif
  value = [dict objectForKey: @"Heat Index"];
  if (value)
    {
    finfo.fcolor = RED;
    str = [NSString stringWithFormat: @"Heat Index: %@%C", value, 0x02da];
    WMDrawString(0, 0.12, str, finfo, 0.08);
    finfo.fcolor = WHITE;
    }
  else
    {
    value = [dict objectForKey: @"Wind Chill"];
    if (value)
      {
      finfo.fcolor = BLUE;
      str = [NSString stringWithFormat: @"Wind Chill: %@%C", value, 0x02da];
      WMDrawString(0, 0.12, str, finfo, 0.08);
      finfo.fcolor = WHITE;
      }
    }
  value = [dict objectForKey: @"Date"];
  str = [NSString stringWithFormat: @"Last Update: %@", value];
  finfo.maxlength = 35;
  WMDrawString(1.00, 0.03, str, finfo, 0.08);
  value = [dict objectForKey: @"City"];
  WMDrawString(0, 0.03, value, finfo, 0.08);
  
} /* DrawCurrent */

#define SPC 0.80

- (void) DrawForecast
{
  int index, x;
  finfo_t finfo;
  NSString *str, *value;
  NSDictionary *dict = [weatherDataParser weatherDictionary];
  
  finfo.fname = [dfltmgr objectForKey: @"FontName"];
  if (finfo.fname == nil)
    finfo.fname = @"Helvetica";
  finfo.fcolor = WHITE;
  finfo.frame = [self frame];
  finfo.maxlength = 18;
  
  x = 1.0;
  for (index = 1; index < 3; index++)
    {
    NSString *key;
    NSString *imageName;
    NSImage  *image;
    key = [NSString stringWithFormat: @"Forecast%0d", index];
    value = [dict objectForKey: key];
    if (value == nil)
      break;
    if ([value hasPrefix: @"This "] || [value hasPrefix: @"Late "])
      value = [value substringWithRange: NSMakeRange(5, [value length]-5)];
    else if ([value hasPrefix: @"Independance"])
      value = @"Indep Day";
    else if ([value hasPrefix: @"Christmas"])
      value = @"Xmas Day";
    else if ([value length] > 9)
      value = [value substringWithRange: NSMakeRange(0, 9)];
    WMDrawString(x+(index-1)*SPC, 0.80, value, finfo, 0.16);
    
    key = [NSString stringWithFormat: @"Forecast-image%0d", index];
    value = [dict objectForKey: key];
    imageName = [weatherDataParser imageNameForKey: value];
    if (imageName == nil)
      imageName = @"unknown";
     image = [self imageWithName: imageName];
     if (image)
	{
	NSPoint point = NSMakePoint(p2h(x+0.10+(index-1)*SPC, finfo.frame), 
			    p2h(0.40, finfo.frame));

	[image compositeToPoint: point operation: NSCompositeSourceOver];
	}
      else
	NSLog(@"Could not find image %@", imageName);

    key = [NSString stringWithFormat: @"Forecast-description%0d", index];
    value = [dict objectForKey: key];
    WMDrawString(x+(index-1)*SPC, 0.30, value, finfo, 0.08);

    key = [NSString stringWithFormat: @"Forecast-hi%0d", index];
    value = [dict objectForKey: key];
    if (value)
      {
        NSString *low;
        key = [NSString stringWithFormat: @"Forecast-low%0d", index];
        low = [dict objectForKey: key];
        str = [NSString stringWithFormat: @"Hi %@%C/Lo %@%C", 
		value, 0x02da, low, 0x02da];
      }
    else
      {
        key = [NSString stringWithFormat: @"Forecast-temperature%0d", index];
        value = [dict objectForKey: key];
        key = [NSString stringWithFormat: @"Forecast-tempdir%0d", index];
        str = [dict objectForKey: key];
        if (str == nil)
          str = @"";
        else if ([str caseInsensitiveCompare: @"Hi"] == NSOrderedSame)
          finfo.fcolor = RED;
        else if ([str caseInsensitiveCompare: @"Lo"] == NSOrderedSame)
          finfo.fcolor = BLUE;
        str = [NSString stringWithFormat: @"%@ %@%C", str, value, 0x02da];
      }
    WMDrawString(x+(index-1)*SPC, 0.16, str, finfo, 0.12);
    finfo.fcolor = WHITE;
    }    

} /* DrawForecast */

- (void) DrawRadar
{
  NSRect frame;
  NSSize isize;
  NSString *value, *current;
  NSURL *url;
  NSImage *rimage;
  NSPoint point;
  NSDictionary *dict = [weatherDataParser weatherDictionary];
  
  current = [dict objectForKey: @"Description"];
  /* Don't draw the radar if there's not much to show */
  if ([current rangeOfString: @"Clear"].location != NSNotFound 
      || [current rangeOfString: @"Cloud"].location != NSNotFound
      || [current rangeOfString: @"Sun"].location != NSNotFound)
    return;

  value = [dict objectForKey: @"Radar"];
  if (value == nil)
    return;
  url = [NSURL URLWithString: value];
  rimage = [[[NSImage alloc] initWithContentsOfURL: url] autorelease];
  if (rimage == nil)
    return;

  frame = [self frame];
  point = NSMakePoint(p2h(1.10+2*SPC, frame), p2h(0.05, frame)); // Just past forecast
  isize = NSMakeSize(MIN(NSHeight(frame), NSWidth(frame)-point.x), 0 );
  isize.height = isize.width;
  if (isize.width < 100)
    return;
  [rimage setSize: isize];
  [rimage compositeToPoint: point operation: NSCompositeSourceOver];
}

- (void) newWeatherModel
{
  NSString *zip;
  NSString *format;
  zip = [dfltmgr objectForKey: DZipCode];
  if (zip == nil)
    zip = DEFAULT_ZIP;
  format = [dfltmgr objectForKey: DWeatherSource];
  if (format == nil)
    format = DEFAULT_FORMAT;
  if (weatherDataParser)
    {
    NSDictionary *dict = [weatherDataParser weatherDictionary];
    NSString *wformat, *wzip;
    wformat = [dict objectForKey: DWeatherSource];
    wzip = [dict objectForKey: DZipCode];
    if (wformat && [format isEqual: wformat] == NO && wzip && [zip isEqual: wzip] == NO)
      DESTROY(weatherDataParser);
    }
  if (weatherDataParser == nil)
    {  
    weatherDataParser = [[WeatherDataParser alloc] initFromZipCode: zip withFormat: format];
    }
  }

- (id) initWithFrame: (NSRect)frame 
{
  self = [super initWithFrame:frame];
  [self newWeatherModel];
  return self;
}

- (void) updateWeatherData
{
  if (updateTime == nil || [updateTime earlierDate: [NSDate date]] == updateTime)
    {
    [self newWeatherModel];
    [(WeatherDataParser *)weatherDataParser updateWeather];
    ASSIGN(updateTime, [[NSDate date] addTimeInterval: UPDATE_INTERVAL]);
    }
}

- (void)drawRect:(NSRect)rect 
{
  if (weatherDataParser == nil)
    return;
  [self updateWeatherData];
  [self DrawCurrent];
  [self DrawForecast];
  if ([[dfltmgr objectForKey: DShowRadar] boolValue])
    [self DrawRadar];
}

- (id) preferenceController
{
  return [WeatherPreferencesController sharedPreferences];
}


@end

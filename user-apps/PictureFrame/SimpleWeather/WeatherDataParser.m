/* WeatherDataParser

   Written: Adam Fedor <fedor@qwest.net>
   Date: Jun 2007
*/

#import "WeatherDataParser.h"
#import "WeatherPreferencesController.h"
#include "GNUstep.h"

/* WeatherDataParser parses a downloaded html page to find specific
   weather related information.  The information it is looking for is:

   Current Information:
   City
   Location
   Date
   Description - description of the weather (e.g. Cloudy)
   Temperature
   Humidity
   Wind
   Pressure
   Wind Chill
   Heat Index

   Forecast Information:
   Forecast (Day)
   Forecast-image
   Forecast-description
   Forecast-temperature
   Forecast-tempdir (High or Low temperature specification)

   The parsing information comes from a property list that contains an
   array of dictionaries. Each dictionary specifies a string to look
   for or some addtional supported command (for instance, to repeat a
   previous dictionary). The dictionaries use the following keys:

   key    - The key we are looking for (see above)
   left   - the string to look for in the html file that is on the left side 
            of the key
   right  - The string that marks the end (Where to stop reading the info)
   optional:
   repeat - Repeat the next "count" array items until one is not found.
   count  - Goes with the repeat key.
   stripTags - If true, delete any html tags inside the found string
   onFail - If the left/right tag was not found, do the action indicated
            (goto 8 - goto the 8th array item, stop - stop parsing)
   keepRight - Keep the "right" string as part of the found item

*/

#define dfltmgr [NSUserDefaults standardUserDefaults]

#define SCAN_START 0
#define SCAN_RESTART 1
#define SCAN_FROMPREVIOUS 2
#define SCAN_FINISH 3

@interface WeatherDataParser(Private)
- (void) defaultWeatherDict;
- (void) startScanning: (int) flag;
- (NSString *)stripTags: (NSString *)string;
- (BOOL) stringBetweenLeftSide: (NSString *)lstr 
		  andRightSide: (NSString *)rstr 
		     keepRight: (BOOL)keep;
- (void) parseString: (NSString *)wstr;
@end

@implementation WeatherDataParser

- (WeatherDataParser *) weatherDataFromURL: (NSURL *)url 
				withFormat: (NSString *)str
{
  return [[WeatherDataParser alloc] initFromURL: url withFormat: str];
}

- initWithFormat: (NSString *)str
{
  NSBundle *bundle;
  NSString *path;
  
  self = [super init];
  bundle = [NSBundle bundleForClass: [self class]];
  path = [bundle pathForResource: str ofType: @"plist"];
  if (path)
    {
    parserDict = [[NSString stringWithContentsOfFile: path] propertyList];
    }
  else
    {
    NSLog(@"Unable to find property list for format %@", str);
    [self release];
    return nil;
    }
  if (parserDict == nil)
    {
      NSLog(@"Unable to parse property list for path %@", path);
      [self release];
      return nil;
    }
  [self defaultWeatherDict];
  [weatherDict setObject: str forKey: DWeatherSource];
  
  RETAIN(parserDict);
  return self;
}

- initFromZipCode: (NSString *)zip withFormat: (NSString *)str
{
  NSString *surl;
  
  if ([self initWithFormat: str] == nil)
    return nil;
  
  surl = [parserDict objectForKey: @"zipurl"];
  if (surl == nil)
    {
    NSLog(@"Cannot find url in parser dict");
    [self release];
    return nil;
    }
  
  surl = [NSString stringWithFormat: surl, zip];
  wurl = RETAIN([NSURL URLWithString: surl]);
  [self defaultWeatherDict];
  [weatherDict setObject: zip forKey: DZipCode];
  return self;
}

- initFromURL: (NSURL *)url withFormat: (NSString *)str
{
  if ([self initWithFormat: str] == nil)
    return nil;
  ASSIGN(wurl, url);
  return self;
}

#ifdef GNUSTEP
- (NSString *) downloadURL: (NSString *)surl
{
  NSTask *pipeTask;
  NSPipe *newPipe;
  NSFileHandle *readHandle;
  NSData *inData;
  NSString *str;
  NSString *path;
  NSArray *args;
  NSMutableArray *wargs;
  BOOL gotError = NO;
 
  pipeTask = [[NSTask alloc] init];
  newPipe = [NSPipe pipe];
  readHandle = [newPipe fileHandleForReading];
  path = [dfltmgr objectForKey: DWWW];
  args = [dfltmgr objectForKey: DWWWArgs];
  wargs = [args mutableCopy];
  
  str = nil;
  NS_DURING
    [wargs addObject: surl];
    [pipeTask setStandardOutput:newPipe];
    [pipeTask setLaunchPath: path];
    [pipeTask setArguments: wargs];
    [pipeTask launch];
    
    // FIXME: Busy wait sucks, but it's better than waiting forever if the
    // process hangs
    //[pipeTask waitUntilExit];
    { 
      int i;
      for (i = 0; i < 5; i++)
        {
	  [NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 5]];
	  if ([pipeTask isRunning] == NO)
	    break;
	}
      if ([pipeTask isRunning] == YES)
        {
	  [pipeTask terminate];
	  gotError = YES;
	}
    }
  
    if ((inData = [readHandle availableData]) && [inData length]) 
      {
	str = [[NSString alloc] initWithData: inData
				    encoding: NSASCIIStringEncoding];
      }
    if (gotError && str)
      {
	/* Sometimes w3m doesn't quit, but it still got all the data */
	NSRange range = [str rangeOfString: @"</html>"];			
	if (range.location != NSNotFound)
	  gotError = NO;
      }
    if (gotError)
      {
	[NSException raise: NSGenericException 
		    format: @"Hung process reading weather"];
      }
  NS_HANDLER
    /* Failed, possible as this command doesn't exist. Don't try again */
    NSLog(@"Failed to download weather: %@", localException);
  NS_ENDHANDLER
  [pipeTask release];
  return str;
}
#endif

- (void) updateWeather
{
  NSString *weather;
  NSError  *werror;
  werror = nil;

  [self defaultWeatherDict];
#ifdef GNUSTEP
#if 0
  /* FIXME: This doesn't handle redirects */
  weather = [NSString stringWithContentsOfURL: wurl];
#else
  weather = [self downloadURL: [wurl absoluteString]];
#endif
  if (weather == nil || [weather length] == 0)
    {
      NSLog(@"Download failed");
      return;
    }
#else
  weather = [NSString stringWithContentsOfURL: wurl
				     encoding: NSASCIIStringEncoding
					error: &werror];
  if (werror)
    {
    NSLog(@"Download failed! Error - %@ %@",
	  [werror localizedDescription],
	  [[werror userInfo] objectForKey: NSErrorFailingURLStringKey]);
    return;
    }
#endif
  
  /* DEBUG: Save to file */
  [weather writeToFile: [NSHomeDirectory() stringByAppendingPathComponent: @"weather.html"] atomically: NO];
  
  [self parseString: weather];
  
  /* DEBUG: Save to file */
  [weatherDict writeToFile: [NSHomeDirectory() stringByAppendingPathComponent: @"weather.plist"] atomically: NO];
  
  NSLog(@"Got weather update");
}  

- (NSDictionary *) weatherDictionary
{
  return weatherDict;
}

- (NSString *) imageNameForKey: (NSString *)imageKey
{
  NSString *str;
  NSDictionary *dict;
  dict = [parserDict objectForKey: @"WeatherImages"];
  str = [dict objectForKey: imageKey];
  if (str == nil && [imageKey characterAtIndex: [imageKey length]-1] == '0')
    {
      int l = 2;
      if ([imageKey characterAtIndex: [imageKey length]-2] == '0')
        l++;
      NSRange r = NSMakeRange(0, [imageKey length]-l);
      imageKey = [imageKey substringWithRange: r];
      str = [dict objectForKey: imageKey];
    }
  return str;
}

- (void) startScanningString: (NSString *)str flags: (int) flag
{
  switch (flag)
    {
    case SCAN_START:
      TEST_RELEASE(scn);
      scn = [NSScanner scannerWithString: str];
      RETAIN(scn);
      break;
    case SCAN_RESTART:
      [scn setScanLocation: 0];
      break;
    case SCAN_FROMPREVIOUS:
      [scn setScanLocation: scanLocation];
      break;
    case SCAN_FINISH:
      DESTROY(scn);
      break;
    default:
      break;
    }
}

- (BOOL) stringBetweenLeftSide: (NSString *)lstr andRightSide: (NSString *)rstr
		    intoString: (NSString **)sstr keepRight: (BOOL)keep
{
  BOOL ok;
  NSString *tstr;

  scanLocation = [scn scanLocation];
  tstr = [NSString string];
  ok = [scn scanUpToString: lstr intoString: NULL]; /* Find left side */
  ok = [scn scanString: lstr intoString: NULL]; /* Skip it */
  if (ok == NO)
    return NO;
  ok = [scn scanUpToString: rstr intoString: &tstr]; /* get string between. */
  if (ok == NO)
    return NO;
  if ([scn isAtEnd])
    return NO;
  if (keep == NO)
    [scn scanString: rstr intoString: NULL]; /* Skip right side */
  if (sstr)
    *sstr = tstr;
  return YES;
}

- (NSString *) stripTags: (NSString *)string
{
  BOOL ok;
  NSMutableString *output;
  NSScanner *tscn;
  /* First remove <br> and &nbsp; */
  output = [string mutableCopy];
  [output replaceOccurrencesOfString: @"<br>" 
			  withString: @" "
			     options: 0 
			       range: NSMakeRange(0, [output length])];
  [output replaceOccurrencesOfString: @"&nbsp;" 
			  withString: @""
			     options: 0 
			       range: NSMakeRange(0, [output length])];
  /* And returns */
  [output replaceOccurrencesOfString: @"\n" 
			  withString: @""
			     options: 0 
			       range: NSMakeRange(0, [output length])];
  /* Now remove any other <> tags */
  string = AUTORELEASE(output);
  output = [NSMutableString string];
  tscn = [NSScanner scannerWithString: string];
  while ([tscn isAtEnd] == NO)
    {
    NSString *temp = [NSString string];
    ok = [tscn scanUpToString: @"<" intoString: &temp];
    if (ok)
      [output appendString: temp];
    if ([tscn isAtEnd] == NO && [tscn scanString: @"<" intoString: NULL])
      {
      [tscn scanUpToString: @">" intoString: NULL];
      [tscn scanString: @">" intoString: NULL];
      }
    }
  return [output stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) defaultWeatherDict
{
  if (weatherDict == nil)
    {
      weatherDict = RETAIN([NSMutableDictionary dictionaryWithCapacity: 20]);

    /* Defaults in case parsing goes wrong */
    [weatherDict setObject: @"NA" forKey: @"City"];
    [weatherDict setObject: @"" forKey: @"Date"];
    [weatherDict setObject: @"NA" forKey: @"Description"];
    [weatherDict setObject: @"NA" forKey: @"Temperature"];
    [weatherDict setObject: @"0" forKey: @"Humidity"];
    [weatherDict setObject: @"0" forKey: @"Wind"];
    [weatherDict setObject: @"0" forKey: @"Pressure"];
    }
    
}
  
- (void) parseString: (NSString *)wstr
{
  NSArray *parse;
  int i, count, repeat, repeat_index;

  parse = [parserDict objectForKey: @"WeatherData"];
  if (parse == nil || [parse isKindOfClass: [NSArray class]] == NO)
    {
      NSLog(@"Error getting parse information");
      return;
    }
  [self defaultWeatherDict];

  count = [parse count];
  i = repeat = 0;
  [self startScanningString: wstr flags: SCAN_START];
  while (i < count)
    {
      BOOL ok, keepRight;
      int repeat_start;
      NSString *key, *left, *right, *value;
      NSString *onSuccess, *onFail;
      BOOL stripTags;
      NSDictionary *dict;
      dict = [parse objectAtIndex: i];
      key = [dict objectForKey: @"key"];
      if ([key isEqual: @"repeat"])
	{
	  repeat = [[dict objectForKey: @"count"] intValue];
	  i++;
	  repeat_start = i;
	  repeat_index = 1;
	  continue;
	}
      left  = [dict objectForKey: @"left"];
      right = [dict objectForKey: @"right"];
      stripTags = [[dict objectForKey: @"stripTags"] boolValue];
      keepRight = [[dict objectForKey: @"keepRight"] boolValue];
      onSuccess = [dict objectForKey: @"onSuccess"];
      onFail = [dict objectForKey: @"onFail"];
      
      ok = [self stringBetweenLeftSide: left andRightSide: right intoString: &value keepRight: keepRight];
      if (ok == NO)
	{
	  /* Couldn't find this key. Skip it and look for the next one */
	  if (repeat)
	    {
	    /* No more repeats, skip past the repeat keys */
	    i += repeat - 1;
	    repeat = 0;
	    }
	if (onFail && [onFail hasPrefix: @"goto"])
	  {
	  int skip = [[onFail substringWithRange: NSMakeRange(5, [onFail length]-5)] intValue];
	  i += skip - 1;
	  }
	else if (onFail && [onFail isEqual: @"stop"])
	    {
	      NSLog(@"Unable to parse weather data");
	      return;
	    }
	  [self startScanningString: wstr flags: SCAN_FROMPREVIOUS];
	  i++;
	  continue;
	}
      if (stripTags)
	value = [self stripTags: value];
      if ([value length] > 50)
	{
	  /* Too long. Must be an error in the parsing */
	value = [value substringWithRange: NSMakeRange(0, 50)];
	}
      /* Hack for NWS */
      if ([key hasPrefix: @"Forecast-description"])
	{
	NSString *dstr = @"Hi";
	NSRange dir = [value rangeOfString: @"Hi"];
	if (dir.location == NSNotFound)
	  {
	  dir = [value rangeOfString: @"Lo"];
	  dstr = @"Lo";
	  }
	if (dir.location != NSNotFound)
	  {
	  [weatherDict setObject: dstr forKey: [NSString stringWithFormat: @"Forecast-tempdir%0d", repeat_index]];
	  value = [value substringWithRange: NSMakeRange(0, dir.location)];
	  }
	}

      if (repeat)
	{
	  key = [NSString stringWithFormat: @"%@%0d", key, repeat_index];
	}
      [weatherDict setObject: value forKey: key];
      if (onSuccess && [onSuccess isEqual: @"rescan"])
        [self startScanningString: wstr flags: SCAN_RESTART];

      i++;
      if (repeat && (i >= repeat_start+repeat))
	{
	  repeat_index++;
	  i -= repeat;
	}
    }
  [self startScanningString: wstr flags: SCAN_FINISH];
}

@end



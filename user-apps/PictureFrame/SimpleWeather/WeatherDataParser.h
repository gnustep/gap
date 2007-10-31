/* WeatherDataParser

   Written: Adam Fedor <fedor@qwest.net>
   Date: Jun 2007
*/

#import <Foundation/Foundation.h>

@interface WeatherDataParser : NSObject
{
  NSURL *wurl;
  NSDictionary *parserDict;
  NSMutableDictionary *weatherDict;

  /* State info */
  NSScanner *scn;
  int scanLocation;
}

- (WeatherDataParser *) weatherDataFromURL: (NSURL *)url 
				withFormat: (NSString *)str;

- initFromZipCode: (NSString *)zip withFormat: (NSString *)str;
- initFromURL: (NSURL *)url withFormat: (NSString *)str;
- (void) updateWeather;
- (NSDictionary *) weatherDictionary;
- (NSString *) imageNameForKey: (NSString *)imageKey;

@end

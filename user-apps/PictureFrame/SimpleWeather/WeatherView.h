/* WeatherView

        Written: Adam Fedor <fedor@qwest.net>
        Date: Jun 2007
*/

#import <Cocoa/Cocoa.h>
#include <time.h>

@interface WeatherView : NSView 
{
  id weatherDataParser;
  NSDate *updateTime;
  int units;
}

- (id) preferenceController;

@end

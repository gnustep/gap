/* WeatherPreferencesController 

*/

#import <Cocoa/Cocoa.h>

@interface WeatherPreferencesController : NSObject
{
    IBOutlet id otherView;
}

+ sharedPreferences;

- (void) loadValues;
- (IBAction)setValue:(id)sender;
- (id) preferenceView;

@end

extern NSString *DZipCode;
extern NSString *DWeatherSource;
extern NSString *DUnits;
extern NSString *DWWW;
extern NSString *DWWWArgs;

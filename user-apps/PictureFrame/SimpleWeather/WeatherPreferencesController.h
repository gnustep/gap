/* WeatherPreferencesController 

*/

#import <Cocoa/Cocoa.h>

@interface WeatherPreferencesController : NSObject
{
    IBOutlet id otherView;
}

+ sharedPreferences;

- (IBAction) loadValues: (id)sender;
- (IBAction) setValue: (id)sender;
- (id) preferenceView;
- (NSString *) preferenceName;

@end

extern NSString *DZipCode;
extern NSString *DWeatherSource;
extern NSString *DUnits;
extern NSString *DWWW;
extern NSString *DWWWArgs;

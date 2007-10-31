/* PreferencesController 

*/

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSObject
{
    IBOutlet id tabView;    
    NSFont *font;
}

+ sharedPreferences;

- (IBAction)showPreferences:(id)sender;
- (void) loadValues;
- (IBAction)setValue:(id)sender;
- (void) changeFont: (id)sender;
- (void) addPreferenceView: (id)theView withName: (NSString *)name;

@end

extern NSString *DFullScreen;
extern NSString *DStartTime;
extern NSString *DStopTime;
extern NSString *DAlbum;
extern NSString *DSpeed;
extern NSString *DShowOverlay;
extern NSString *DOverlayInfo;
extern NSString *DFontName;

enum {
  INFO_NONE = 0,
  INFO_CLK1 = 1,
  INFO_CLK2 = 2,
  INFO_WEATHER = 4,
  INFO_PHOTO = 8
};
#define MAX_INFO 15
#define MAX_CLK  3

extern NSString *DOffKey;
extern NSString *DInfoKey;
extern NSString *DBackKey;
extern NSString *DSpeedDownKey;
extern NSString *DSpeedUpKey;
extern NSString *DToggleScreenKey;

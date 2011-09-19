/* 
   Project: Charter

   Author: multix

   Created: 2011-09-08 17:49:04 +0200 by multix
   
   Application Controller
*/
 
#import <AppKit/AppKit.h>

@class OKChart;

@interface AppController : NSObject
{
  IBOutlet OKChart *chartView;
  IBOutlet NSPopUpButton *plot;
}


- (IBAction)changePlot:(id)sender;
- (IBAction)changeBackgroundColor: (id)sender;

@end


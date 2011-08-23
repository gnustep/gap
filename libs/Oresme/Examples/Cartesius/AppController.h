/* 
   Project: Cartesius

   Author: Riccardo Mottola

   Created: 2011-08-23 01:18:46 +0200 by multix
   
   Application Controller
*/
 
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class OKCartesius;

@interface AppController : NSObject
{
  IBOutlet OKCartesius *cartesiusView;
  IBOutlet NSPopUpButton *curve;
}

- (IBAction)changeCurve:(id)sender;

@end


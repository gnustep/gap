/* 
   Project: Cartesius

   Author: Riccardo Mottola

   Created: 2011-08-23 01:18:46 +0200 by multix
   
   Application Controller
*/

#import <OresmeKit/OKCartesius.h>

#import "AppController.h"

@implementation AppController

+ (void) initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */
  
  [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) init
{
  if ((self = [super init]))
    {
    }
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (IBAction)changeCurve:(id)sender
{
  NSMutableArray *arrayX, *arrayY;
  int i;
  float x, y;

  NSLog(@"Change curve");
  arrayX = [cartesiusView arrayX];
  arrayY = [cartesiusView arrayY];
  [arrayX removeAllObjects];
  [arrayY removeAllObjects];

  x = 0;
  for (i = 0; i < 12; i++)
    {
      y = pow(x, 2);
      [arrayX addObject: [NSNumber numberWithFloat: x]];
      [arrayY addObject: [NSNumber numberWithFloat: y]];

      x += 1;
    }
  [cartesiusView setNeedsDisplay: YES];
}

- (void) awakeFromNib
{
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotif
{
// Uncomment if your application is Renaissance-based
//  [NSBundle loadGSMarkupNamed: @"Main" owner: self];
}

- (BOOL) applicationShouldTerminate: (id)sender
{
  return YES;
}

- (void) applicationWillTerminate: (NSNotification *)aNotif
{
}

- (BOOL) application: (NSApplication *)application
	    openFile: (NSString *)fileName
{
  return NO;
}

- (void) showPrefPanel: (id)sender
{
}

@end

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

  NSLog(@"Change curve %d", [sender tag]);
  arrayX = [cartesiusView arrayX];
  arrayY = [cartesiusView arrayY];
  [arrayX removeAllObjects];
  [arrayY removeAllObjects];

  /* parabola */
  if ([[sender selectedItem] tag] == 0)
    {
      x = -10;
      for (i = 0; i <= 20; i++)
	{
	  y = 0.5 * pow(x, 2);
	  [arrayX addObject: [NSNumber numberWithFloat: x]];
	  [arrayY addObject: [NSNumber numberWithFloat: y]];

	  x += 1;
	}
      [cartesiusView setVisibleXUnits: 100];
      [cartesiusView setVisibleYUnits: 100];
    }
  /* line */
  else if ([[sender selectedItem] tag] == 1)
    {
      x = -75;
      for (i = 0; i < 15; i++)
	{
	  y = x;
	  [arrayX addObject: [NSNumber numberWithFloat: x]];
	  [arrayY addObject: [NSNumber numberWithFloat: y]];

	  x += 10;
	}
      [cartesiusView setVisibleXUnits: 60];
      [cartesiusView setVisibleYUnits: 60];
    }
  /* sine */
  else if ([[sender selectedItem] tag] == 2)
    {
      x = -6;
      for (i = 0; i < 120; i++)
	{
	  y = sin(x);
	  [arrayX addObject: [NSNumber numberWithFloat: x]];
	  [arrayY addObject: [NSNumber numberWithFloat: y]];

	  x += .1;
	}
      [cartesiusView setVisibleXUnits: 15];
      [cartesiusView setVisibleYUnits: 2];
    }
  /* sinc */
  else if ([[sender selectedItem] tag] == 3)
    {
      x = -25;
      for (i = 0; i < 100; i++)
	{
	  if(x == 0)
	    y = 1;
	  else
	    y = sin(x)/x;
	  [arrayX addObject: [NSNumber numberWithFloat: x]];
	  [arrayY addObject: [NSNumber numberWithFloat: y]];

	  x += 0.5;
	}
      [cartesiusView setVisibleXUnits: 40];
      [cartesiusView setVisibleYUnits: 2];
    }
  [cartesiusView setNeedsDisplay: YES];
}

- (IBAction) changeQuadrantPositioning: (id)sender
{
  NSLog(@"Change quadrant %d", [sender tag]);
  if ([[sender selectedItem] tag] == 0)
    [cartesiusView setQuadrantPositioning: OKQuadrantCentered];
  else if ([[sender selectedItem] tag] == 1)
    [cartesiusView setQuadrantPositioning: OKQuadrantI];
  else if ([[sender selectedItem] tag] == 2)
    [cartesiusView setQuadrantPositioning: OKQuadrantII];
  else if ([[sender selectedItem] tag] == 3)
    [cartesiusView setQuadrantPositioning: OKQuadrantIII];
  else if ([[sender selectedItem] tag] == 4)
    [cartesiusView setQuadrantPositioning: OKQuadrantIV];
  [cartesiusView setNeedsDisplay: YES];
}

- (IBAction) changeBackgroundColor: (id)sender
{
 [cartesiusView setBackgroundColor: [sender color]];
 [cartesiusView setNeedsDisplay: YES];
}

- (IBAction) changeAxisColor: (id)sender
{
 [cartesiusView setAxisColor: [sender color]];
 [cartesiusView setNeedsDisplay: YES];
}

- (IBAction) changeCurveColor: (id)sender
{
 [cartesiusView setCurveColor: [sender color]];
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

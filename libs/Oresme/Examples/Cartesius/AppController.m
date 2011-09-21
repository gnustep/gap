/* 
   Project: Cartesius

   Author: Riccardo Mottola

   Created: 2011-08-23 01:18:46 +0200 by multix
   
   Application Controller
*/

#import <OresmeKit/OKCartesius.h>

#import "AppController.h"

@implementation AppController


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
  NSMutableArray *curve1, *curve2;
  int i;
  float x, y;
  NSPoint p;

  NSLog(@"Change curve %d", [sender tag]);
  curve1 = [cartesiusView curve1];
  curve2 = [cartesiusView curve2];
  [curve1 removeAllObjects];
  [curve2 removeAllObjects];

  /* parabola */
  if ([[sender selectedItem] tag] == 0)
    {
      x = -10;
      for (i = 0; i <= 20; i++)
	{
	  y = 0.5 * pow(x, 2);
	  p = NSMakePoint(x, y);
	  [curve1 addObject: [NSValue valueWithPoint: p]];

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
	  p = NSMakePoint(x, y);
	  [curve1 addObject: [NSValue valueWithPoint: p]];

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
	  p = NSMakePoint(x, y);
	  [curve1 addObject: [NSValue valueWithPoint: p]];

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
	  p = NSMakePoint(x, y);
	  [curve1 addObject: [NSValue valueWithPoint: p]];

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
 [cartesiusView setCurve1Color: [sender color]];
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


- (void) showPrefPanel: (id)sender
{
}

@end

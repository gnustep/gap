/* 
   Project: Charter

   Author: multix

   Created: 2011-09-08 17:49:04 +0200 by multix
   
   Application Controller
*/

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

- (IBAction)changePlot:(id)sender
{
  NSMutableArray *series1;
  unsigned i;
  float v;

  series1 = [chartView seriesAtIndex: 0];
  if ([[sender selectedItem] tag] == 0)
    {
      for (i = 0; i < 6; i++)
	{
	  v = i*i - 4;

	  [series1 addObject: [NSNumber numberWithFloat: v]];
	}
    }

  [chartView setNeedsDisplay: YES];
}

- (IBAction) changeBackgroundColor: (id)sender
{
 [chartView setBackgroundColor: [sender color]];
 [chartView setNeedsDisplay: YES];
}

- (void) awakeFromNib
{
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotif
{
}


@end

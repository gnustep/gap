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

/* 
   Project: Charter

   Author: Riccardo Mottola

   Created: 2011-09-08 17:49:04 +0200 by multix

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import <Foundation/Foundation.h>
#import <AppKit/NSView.h>
#import <OresmeKit/OresmeKit.h>

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
  OKSeries *series1;
  OKSeries *series2;
  int i;
  float v1, v2;

  [chartView removeAllSeries];
  NSLog(@"removed series");
  series1 = [[[OKSeries alloc] init] autorelease];
  [chartView addSeries: series1];
  if ([[sender selectedItem] tag] == 0)
    {
      for (i = 0; i < 6; i++)
	{
	  v1 = i*i - 4;

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	}
      NSLog(@"series 1 calculated");
    }
  else if ([[sender selectedItem] tag] == 1)
    {
      series2 = [[[OKSeries alloc] init] autorelease];
      [chartView addSeries: series2];
      for (i = 0; i < 6; i++)
	{
	  v1 = pow(i, 1.5);
	  v2 = pow(i, 2);

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	  [series2 addObject: [NSNumber numberWithFloat: v2]];
	}
      NSLog(@"series 1 calculated");
    }
  NSLog(@"redisplay");
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
  NSRect rect;
  OKChart *tempChart;
  NSView *superView;

  rect = [chartView frame];
  superView = [chartView superview];
  [chartView release];
  chartView = [[OKLineChart alloc] initWithFrame: rect];
  [superView addSubview: chartView];

}


@end

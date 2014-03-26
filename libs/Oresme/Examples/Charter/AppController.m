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
  OKSeries *series3;
  int i;
  float v1, v2;

  [chartView setYLabelNumberFormatting:OKNumFmtPlain];
  [chartView removeAllSeries];

  series1 = [[OKSeries alloc] init];
  [chartView addSeries: series1];
  [series1 release];
  if ([[sender selectedItem] tag] == 0)
    {
      [series1 setColor: [NSColor blueColor]];
      for (i = 0; i < 6; i++)
	{
	  v1 = i*i - 4;

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	}
    }
  else if ([[sender selectedItem] tag] == 1)
    {
      [series1 setColor: [NSColor purpleColor]];
      series2 = [[OKSeries alloc] init];
      [series2 setColor: [NSColor greenColor]];
      [chartView addSeries: series2];
      [series2 release];
      for (i = 0; i < 6; i++)
	{
	  v1 = pow(i, 1.5)+0.1;
	  v2 = pow(i, 2)+0.2;

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	  [series2 addObject: [NSNumber numberWithFloat: v2]];
	}
    }
  else if ([[sender selectedItem] tag] == 2)
    {
      [series1 setColor: [NSColor purpleColor]];
      series2 = [[OKSeries alloc] init];
      [series2 setColor: [NSColor greenColor]];
      [chartView addSeries: series2];
      [series2 release];
      series3 = [[OKSeries alloc] init];
      [series3 setColor: [NSColor yellowColor]];
      [chartView addSeries: series3];
      [series3 release];

      [series1 addObject: [NSNumber numberWithFloat: 20]];
      [series2 addObject: [NSNumber numberWithFloat: 80]];
      [series3 addObject: [NSNumber numberWithFloat: 100]];
    }
  else if ([[sender selectedItem] tag] == 3)
    {
      [series1 setColor: [NSColor purpleColor]];
      series2 = [[OKSeries alloc] init];
      [series2 setColor: [NSColor greenColor]];
      [chartView addSeries: series2];
      [series2 release];
      [chartView setYLabelNumberFormatting:OKNumFmtKiloMega];
      for (i = 0; i < 64; i++)
	{
	  v1 = sin((i * 10) * 6.2831853 / 180);
	  v2 = cos((i * 10) * 6.2831853 / 180);

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	  [series2 addObject: [NSNumber numberWithFloat: v2]];
	}
    }
  else if ([[sender selectedItem] tag] == 4)
    {
      [series1 setColor: [NSColor purpleColor]];
      series2 = [[OKSeries alloc] init];
      [series2 setColor: [NSColor greenColor]];
      [chartView addSeries: series2];
      [series2 release];
      [chartView setYLabelNumberFormatting:OKNumFmtKiloMega];
      for (i = 0; i < 64; i++)
	{
	  v1 = sin((i * 10) * 6.2831853 / 180) * 3;
	  v2 = cos((i * 10) * 6.2831853 / 180) * 3;

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	  [series2 addObject: [NSNumber numberWithFloat: v2]];
	}

    }
  else if ([[sender selectedItem] tag] == 5)
    {
      [series1 setColor: [NSColor purpleColor]];
      series2 = [[OKSeries alloc] init];
      [series2 setColor: [NSColor greenColor]];
      [chartView addSeries: series2];
      [series2 release];
      [chartView setYLabelNumberFormatting:OKNumFmtKiloMega];
      for (i = 0; i < 64; i++)
	{
	  v1 = sin((i * 10) * 6.2831853 / 180) * 1000;
	  v2 = cos((i * 10) * 6.2831853 / 180) * 1000;

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	  [series2 addObject: [NSNumber numberWithFloat: v2]];
	}
    }

  else if ([[sender selectedItem] tag] == 6)
    {
      [series1 setColor: [NSColor purpleColor]];
      series2 = [[OKSeries alloc] init];
      [series2 setColor: [NSColor greenColor]];
      [chartView addSeries: series2];
      [series2 release];
      [chartView setYLabelNumberFormatting:OKNumFmtKiloMega];
      for (i = 0; i < 64; i++)
	{
	  v1 = sin((i * 10) * 6.2831853 / 180) * 1e6;
	  v2 = cos((i * 10) * 6.2831853 / 180) * 1e6;

	  [series1 addObject: [NSNumber numberWithFloat: v1]];
	  [series2 addObject: [NSNumber numberWithFloat: v2]];
	}
    }
  else if ([[sender selectedItem] tag] == 7)
    {
      [series1 setColor: [NSColor purpleColor]];
      series2 = [[OKSeries alloc] init];
      [series2 setColor: [NSColor greenColor]];
      [chartView addSeries: series2];
      [series2 release];
      for (i = 0; i < 64; i++)
        {
              v1 = sin((i * 10) * 6.2831853 / 180) / 1000;
              v2 = cos((i * 10) * 6.2831853 / 180) / 1000;
              
              [series1 addObject: [NSNumber numberWithFloat: v1]];
              [series2 addObject: [NSNumber numberWithFloat: v2]];
        }
    }
  [chartView setNeedsDisplay: YES];
}

- (IBAction)changeChartType:(id)sender
{
  NSRect rect;
  OKChart *tempChart;
  NSView *superView;

  rect = [chartView frame];
  superView = [chartView superview];

  if ([[sender selectedItem] tag] == 0)
    {
      tempChart = [[OKLineChart alloc] initWithFrame: rect];
      [tempChart setyAxisLabelStyle: OKMinMaxLabels];
    }
  else if ([[sender selectedItem] tag] == 1)
    {
      tempChart = [[OKPieChart alloc] initWithFrame: rect];
      [tempChart setyAxisLabelStyle: OKAllLabels];
    }
  else
    {
      NSLog(@"Unexpected chart type");
      return;
    }
  
  [tempChart setAutoresizingMask:[chartView autoresizingMask]];
  [chartView removeFromSuperview];
  chartView = tempChart;
  [superView addSubview: chartView];
  [self changePlot:plot];
}

- (IBAction)setAxisColor: (id)sender
{
  [chartView setAxisColor:[sender color]];
  [chartView setNeedsDisplay:YES];
}


- (IBAction)setBackgroundColor: (id)sender
{
  [chartView setBackgroundColor:[sender color]];
  [chartView setNeedsDisplay:YES];
}

- (IBAction)setGridStyle: (id)sender
{
  [chartView setGridStyle: [[sender selectedItem] tag]];
  [chartView setNeedsDisplay: YES];
}

- (IBAction) changeSeries1Color: (id)sender
{
  [[chartView seriesAtIndex:0] setColor: [sender color]];
  [chartView setNeedsDisplay: YES];
}

- (IBAction) changeSeries2Color: (id)sender
{
  [[chartView seriesAtIndex:1] setColor: [sender color]];
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
  tempChart = [[OKLineChart alloc] initWithFrame: rect];
  [tempChart setAutoresizingMask:[chartView autoresizingMask]];
  [chartView removeFromSuperview];
  chartView = tempChart;
  [superView addSubview: chartView];

}


@end

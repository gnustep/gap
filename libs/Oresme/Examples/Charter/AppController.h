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


/** -*- mode: objc -*-
   Project: OresmeKit

   Copyright (C) 2011-2017 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2011-09-08 15:09:41 +0200 by Riccardo Mottola

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
   Software Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
*/


#import <Foundation/Foundation.h>

#import "OKChart.h"


/** <p>OKLineChart is a sublcass of [OKChart] which provides drawing
    of Line Charts. Multiple series are supported at the same time.</p>
    <p>Lines are drawn in standard with set of <em>lineWidth</em>.</p>
    <p>Highlighted lines are drawn thicker.<br/>
    The <em>highlighted</em> property of each [OKSeries] is used to
    deterine that.</p>
*/
@interface OKLineChart : OKChart
{
  float minXUnitSize;
  float minYUnitSize;

  float lineWidth;
}

- (float)lineWidth;
- (void)setLineWidth:(float)f;

@end


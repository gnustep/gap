//
//  PRScale.m
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 19 2005.
//  Copyright (c) 2005-2015 Riccardo Mottola. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include <math.h>
#import "PRScale.h"

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#ifndef NSInteger
#define NSInteger int
#endif
#endif

@implementation PRScale

- (NSImage *)filterImage:(NSImage *)image with:(NSArray *)parameters progressPanel:(PRCProgress *)progressPanel
{
    int pixelsX;
    int pixelsY;
    int method;

    /* interpret the parameters */
    pixelsX = [[parameters objectAtIndex:0] intValue];
    pixelsY = [[parameters objectAtIndex:1] intValue];
    method = [[parameters objectAtIndex:2] intValue];
	
    return [self scaleImage:image :pixelsX :pixelsY :method :progressPanel];
}

- (NSString *)actionName
{
    return @"Scale";
}

- (NSImage *)scaleImage :(NSImage *)srcImage :(int)sizeX :(int)sizeY :(int)method :(PRCProgress *)prPanel
{
  NSBitmapImageRep *srcImageRep;
  NSImage *destImage;
  NSBitmapImageRep *destImageRep;
  NSInteger origW, origH;
  NSInteger x, y;
  NSInteger i;
  unsigned char *srcData;
  unsigned char *destData;
  NSInteger srcSamplesPerPixel;
  NSInteger destSamplesPerPixel;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;
  float xRatio, yRatio;
    
    /* get source image representation and associated information */
    srcImageRep = [[srcImage representations] objectAtIndex:0];
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
    
    origW = [srcImageRep pixelsWide];
    origH = [srcImageRep pixelsHigh];

    
    xRatio = (float)origW / (float)sizeX;
    yRatio = (float)origH / (float)sizeY;
    

    destImage = [[NSImage alloc] initWithSize:NSMakeSize(sizeX, sizeY)];
    destSamplesPerPixel = [srcImageRep samplesPerPixel];
    destImageRep = [[NSBitmapImageRep alloc]
                     initWithBitmapDataPlanes:NULL
                     pixelsWide:sizeX
                     pixelsHigh:sizeY
                     bitsPerSample:8
                     samplesPerPixel:destSamplesPerPixel
                     hasAlpha:[srcImageRep hasAlpha]
                     isPlanar:NO
                     colorSpaceName:[srcImageRep colorSpaceName]
                     bytesPerRow:0
                     bitsPerPixel:0];
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    destBytesPerPixel = [destImageRep bitsPerPixel] / 8;

    if (method == NEAREST_NEIGHBOUR)
      {
        for (y = 0; y < sizeY; y++)
            for (x = 0; x < sizeX; x++)
                for (i = 0; i < srcSamplesPerPixel; i++)
                    destData[destBytesPerRow * y + destBytesPerPixel * x + i] = srcData[srcBytesPerRow * (int)(y * yRatio)  + srcBytesPerPixel * (int)(x * xRatio) + i];
      } 
    else if (method == BILINEAR)
      {
	/*
	  w,h : original width and height
	  v1, v2, v3, 4: four original corner values
	  v' : new computed value
          
	  v' = v1(1-w)(1-h) + v2(w)(1-h) + v3(h)(1-w) + v3(w)(h)
	*/
        int v1, v2, v3, v4;
        register int x0, y0;
        
        for (y = 0; y < sizeY-1; y++)
	  for (x = 0; x < sizeX-1; x++)
	    {
	      register float xDiff, yDiff;
	      float xFloat, yFloat;
              
	      xFloat = (float)x * xRatio;
	      yFloat = (float)y * yRatio;
	      x0 = (int)(xFloat);
	      y0 = (int)(yFloat);
	      xDiff = (xFloat - x0);
	      yDiff = (yFloat - y0);
	      for (i = 0; i < srcSamplesPerPixel; i++)
		{
		  v1 = srcData[srcBytesPerRow * y0 + srcBytesPerPixel * x0 + i];
		  v2 = srcData[srcBytesPerRow * y0 + srcBytesPerPixel * (x0+1) + i];
		  v3 = srcData[srcBytesPerRow * (y0+1) + srcBytesPerPixel * x0 + i];
		  v4 = srcData[srcBytesPerRow * (y0+1) + srcBytesPerPixel * (x0+1) + i];

		  destData[destBytesPerRow * y + destBytesPerPixel * x + i] = \
		    (int)(v1*(1-xDiff)*(1-yDiff) + \
			  v2*xDiff*(1-yDiff) + \
			  v3*yDiff*(1-xDiff) + \
			  v4*xDiff*yDiff);
		}
	    }
	/* we left out one pixel at the right and bottom border */
	y = sizeY-1;
	for (x = 0; x < sizeX-1; x++)
	  {
	    register float xDiff, yDiff;
	    float xFloat, yFloat;
                    
	    xFloat = (float)x * xRatio;
	    yFloat = (float)y * yRatio;
	    x0 = (int)(xFloat);
	    y0 = (int)(yFloat);
	    xDiff = (xFloat - x0);
	    yDiff = (yFloat - y0);

	    for (i = 0; i < srcSamplesPerPixel; i++)
	      {
		v1 = srcData[srcBytesPerRow * y0 + srcBytesPerPixel * x0 + i];
		v2 = srcData[srcBytesPerRow * y0 + srcBytesPerPixel * (x0+1) + i];

		destData[destBytesPerRow * y + destBytesPerPixel * x + i] = \
		  (int)(v1*(1-xDiff)*(1-yDiff) + \
			v2*xDiff*(1-yDiff));
	      }
	  }

	x = sizeX-1;
	for (y = 0; y < sizeY-1; y++)
	  {
	    register float xDiff, yDiff;
	    float xFloat, yFloat;
                    
	    xFloat = (float)x * xRatio;
	    yFloat = (float)y * yRatio;
	    x0 = (int)(xFloat);
	    y0 = (int)(yFloat);
	    xDiff = (xFloat - x0);
	    yDiff = (yFloat - y0);
	    for (i = 0; i < srcSamplesPerPixel; i++)
	      { 
		v1 = srcData[srcBytesPerRow * y0 + srcBytesPerPixel * x0 + i];
		v3 = srcData[srcBytesPerRow * (y0+1) + srcBytesPerPixel * x0 + i];

		destData[destBytesPerRow * y + destBytesPerPixel * x + i] = \
		  (int)(v1*(1-xDiff)*(1-yDiff) + \
			v3*yDiff*(1-xDiff));
	      }
	  }
	/* the bottom right corner */
	{
	  register float xDiff, yDiff;
	  float xFloat, yFloat;
                    
	  xFloat = (float)x * xRatio;
	  yFloat = (float)y * yRatio;
	  x0 = (int)(xFloat);
	  y0 = (int)(yFloat);
	  xDiff = (xFloat - x0);
	  yDiff = (yFloat - y0);
	  for (i = 0; i < srcBytesPerPixel; i++)
	    {
	      v1 = srcData[srcBytesPerRow * y0 + srcBytesPerPixel * x0 + i];

	      destData[destBytesPerRow * y + destBytesPerPixel * x + i] = \
		(int)(v1*(1-xDiff)*(1-yDiff));
	    }
	}
      }
    else
      NSLog(@"Unknown scaling method");

    [destImage addRepresentation:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

@end

//
//  PRScale.m
//  PRICE
//
//  Modified for LaternaMagica which does not have PRImage and the progress panel
//
//  Created by Riccardo Mottola on Wed Jan 19 2005.
//  Copyright (c) 2005-2010 Carduus. All rights reserved.
//
// This application is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#include <math.h>
#import "PRScale.h"


@implementation PRScale

- (NSImage *)filterImage:(NSImage *)image with:(NSArray *)parameters progressPanel:(id)progressPanel
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

- (NSImage *)scaleImage :(NSImage *)srcImage :(int)sizeX :(int)sizeY :(int)method :(id)prPanel
{
    NSBitmapImageRep *srcImageRep;
    NSImage *destImage;
    NSBitmapImageRep *destImageRep;
    int origW, origH;
    int x, y;
    int i;
    unsigned char *srcData;
    unsigned char *destData;
    int srcSamplesPerPixel;
    int destSamplesPerPixel;
    int srcBytesPerRow;
    int destBytesPerRow;
    BOOL isColored;
    float xRatio, yRatio;
    
    progressSteps = 0;
    totalProgressSteps = 2;
    progPanel = prPanel;

    /* get source image representation and associated information */
    srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];
    srcBytesPerRow = [srcImageRep bytesPerRow];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    
    origW = [srcImageRep pixelsWide];
    origH = [srcImageRep pixelsHigh];

    
    xRatio = (float)origW / (float)sizeX;
    yRatio = (float)origH / (float)sizeY;
    
    /* check bith depth and color/greyscale image */
    if ([srcImageRep hasAlpha])
    {
        NSLog(@"image scaling not supported for images with alpha channel.");
        if ([srcImageRep samplesPerPixel] == 2)
            return srcImage;
        else
            return srcImage;
    }
    else
    {
        destImage = [[NSImage alloc] initWithSize:NSMakeSize(sizeX, sizeY)];
        if ([srcImageRep samplesPerPixel] == 1)
        {
            destSamplesPerPixel = 1;
            destImageRep = [[NSBitmapImageRep alloc]
                    initWithBitmapDataPlanes:NULL
                                  pixelsWide:sizeX
                                  pixelsHigh:sizeY
                               bitsPerSample:8
                             samplesPerPixel:destSamplesPerPixel
                                    hasAlpha:NO
                                    isPlanar:NO
                              colorSpaceName:NSCalibratedWhiteColorSpace
                                 bytesPerRow:destSamplesPerPixel*sizeX
                                bitsPerPixel:0];
            isColored = NO;
        } else
        {
            destSamplesPerPixel = 3;
            destImageRep = [[NSBitmapImageRep alloc]
                    initWithBitmapDataPlanes:NULL
                                  pixelsWide:sizeX
                                  pixelsHigh:sizeY
                               bitsPerSample:8
                             samplesPerPixel:destSamplesPerPixel
                                    hasAlpha:NO
                                    isPlanar:NO
                              colorSpaceName:NSCalibratedRGBColorSpace
                                 bytesPerRow:destSamplesPerPixel*sizeX
                                bitsPerPixel:0];
            isColored = YES;
        }
    }
    
    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    destBytesPerRow = [destImageRep bytesPerRow];
    
    if (method == NEAREST_NEIGHBOUR)
    {
        for (y = 0; y < sizeY; y++)
            for (x = 0; x < sizeX; x++)
                for (i = 0; i < srcSamplesPerPixel; i++)
                    destData[destSamplesPerPixel * (y * sizeX + x) + i] = srcData[srcBytesPerRow * (int)(y * yRatio)  +srcSamplesPerPixel * (int)(x * xRatio) + i];
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
		  v1 = srcData[srcBytesPerRow * y0 + srcSamplesPerPixel * x0 + i];
		  v2 = srcData[srcBytesPerRow * y0 + srcSamplesPerPixel * (x0+1) + i];
		  v3 = srcData[srcBytesPerRow * (y0+1) + srcSamplesPerPixel * x0 + i];
		  v4 = srcData[srcBytesPerRow * (y0+1) + srcSamplesPerPixel * (x0+1) + i];

		  destData[destSamplesPerPixel * (y * sizeX + x) + i] = \
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
		v1 = srcData[srcBytesPerRow * y0 + srcSamplesPerPixel * x0 + i];
		v2 = srcData[srcBytesPerRow * y0 + srcSamplesPerPixel * (x0+1) + i];

		destData[destSamplesPerPixel * (y * sizeX + x) + i] = \
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
		v1 = srcData[srcBytesPerRow * y0 + srcSamplesPerPixel * x0 + i];
		v3 = srcData[srcBytesPerRow * (y0+1) + srcSamplesPerPixel * x0 + i];

		destData[destSamplesPerPixel * (y * sizeX + x) + i] = \
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
	  for (i = 0; i < srcSamplesPerPixel; i++)
	    {
	      v1 = srcData[srcBytesPerRow * y0 + srcSamplesPerPixel * x0 + i];

	      destData[destSamplesPerPixel * (y * sizeX + x) + i] = \
		(int)(v1*(1-xDiff)*(1-yDiff));
	    }
	}
      } else
      NSLog(@"Unknown scaling method");

    [destImage addRepresentation:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

@end

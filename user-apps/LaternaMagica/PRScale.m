//
//  PRScale.m
//  PRICE
//
//  Created by Riccardo Mottola on Wed Jan 19 2005.
//  Copyright (c) 2005-2009 Carduus. All rights reserved.
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
    
    if (progPanel != nil)
    {
    }

    if (method == NEAREST_NEIGHBOUR)
    {
        for (y = 0; y < sizeY; y++)
            for (x = 0; x < sizeX; x++)
                for (i = 0; i < srcSamplesPerPixel; i++)
                    destData[destSamplesPerPixel * (y * sizeX + x) + i] = srcData[srcBytesPerRow * (int)floor(y * yRatio)  +srcSamplesPerPixel * (int)floor(x * xRatio) + i];
    } else if (method == LINEAR_HV)
    {
        register int v1, v2, v3;
        register int realX, realY;
        register int nextX, nextY;

        for (y = 0; y < sizeY-1; y++)
            for (x = 0; x < sizeX-1; x++)
                for (i = 0; i < srcSamplesPerPixel; i++)
                {
                    realX = (int)floor(x * xRatio);
                    nextX = (int)floor((x+1) * xRatio);
                    realY = (int)floor(y * yRatio);
                    nextY = (int)floor((y+1) * yRatio);
                    v1 = srcData[srcBytesPerRow * realY + srcSamplesPerPixel * realX + i];
                    v2 = srcData[srcBytesPerRow * realY + srcSamplesPerPixel * nextX + i];
                    v3 = srcData[srcBytesPerRow * nextY + srcSamplesPerPixel * realX + i];
                    destData[destSamplesPerPixel * (y * sizeX + x) + i] = \
                        v1 + \
                        (int)((((float)(v2 - v1) / (float)(nextX - realX) * (x * xRatio - (float)realX)) + \
                               ((float)(v3 - v1) / (float)(nextY - realY) * (y * yRatio - (float)realY)))/2);
            }
        // we left out one pixel at the right and bottom border
        // bottom
        y = sizeY-1;
        for (x = 0; x < sizeX-1; x++)
            for (i = 0; i < srcSamplesPerPixel; i++)
            {
                realX = (int)floor(x * xRatio);
                nextX = (int)floor((x+1) * xRatio);
                realY = (int)floor(y * yRatio);
                v1 = srcData[srcBytesPerRow * realY + srcSamplesPerPixel * realX + i];
                v2 = srcData[srcBytesPerRow * realY + srcSamplesPerPixel * nextX + i];
                destData[destSamplesPerPixel * (y * sizeX + x) + i] = \
                    v1 + \
                    (int)((float)(v2 - v1) / (float)(nextX - realX) * (x * xRatio - (float)realX));
            }
        // right
        // x = sizeX-1 at loop exit already.
        for (y = 0; y < sizeY-1; y++)
            for (i = 0; i < srcSamplesPerPixel; i++)
            {
                realX = (int)floor(x * xRatio);
                realY = (int)floor(y * yRatio);
                nextY = (int)floor((y+1) * yRatio);
                v1 = srcData[srcBytesPerRow * realY + srcSamplesPerPixel * realX + i];
                v3 = srcData[srcSamplesPerPixel * (nextY * origW + realX) + i];
                destData[destSamplesPerPixel * (y * sizeX + x) + i] = \
                    v1 + \
                    (int)((float)(v3 - v1) / (float)(nextY - realY) * (y * yRatio - (float)realY));
            }
        // the last pixel, x & y are correct already
        for (i = 0; i < srcSamplesPerPixel; i++)
            destData[destSamplesPerPixel * (y * sizeX + x) + i] = srcData[srcSamplesPerPixel * ((int)floor(y * yRatio) * origW + (int)floor(x * xRatio)) + i];
    } else
        NSLog(@"Unknown scaling method");

    [destImage addRepresentation:destImageRep];
    [destImageRep release];
    [destImage autorelease];
    return destImage;
}

@end

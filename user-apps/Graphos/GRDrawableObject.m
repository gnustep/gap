/*
 Project: Graphos
 GRDrawableObject.h

 Copyright (C) 2008-2013 GNUstep Application Project

 Author: Ing. Riccardo Mottola

 Created: 2008-02-25

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
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import <AppKit/NSGraphics.h>
#import "GRDrawableObject.h"
#import "GRObjectEditor.h"


@implementation GRDrawableObject

- (void)dealloc
{
    [editor release];
    [strokeColor release];
    [fillColor release];
    [super dealloc];
}

/** initializes by using the properties array as defaults */
- (id)initInView:(GRDocView *)aView
      zoomFactor:(CGFloat)zf
      withProperties:(NSDictionary *)properties
{
  self = [super init];
  if(self)
    {
      NSColor *newColor;
      id val;

      NSLog(@"initInView properties of GRDrawableObject");

      docView = aView;
      zmFactor = zf;
      stroked = YES;
      filled = NO;
      visible = YES;
      locked = NO;
      strokeColor = [[[NSColor blackColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
      fillColor = [[[NSColor whiteColor] colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
      
      val = [properties objectForKey: @"stroked"];
      if (val != nil)
	[self setStroked: [val boolValue]];
      newColor = (NSColor *)[properties objectForKey: @"strokecolor"];
      if (newColor != nil)
	[self setStrokeColor: newColor];

      val = [properties objectForKey: @"filled"];
      if (val != nil)
	[self setFilled: [val boolValue]];
      newColor = (NSColor *)[properties objectForKey: @"fillcolor"];
      if (newColor != nil)
	[self setFillColor: newColor];

      val = [properties objectForKey: @"visible"];
      if (val)	
	visible = [val boolValue];
      
      val = [properties objectForKey: @"locked"];
      if (val)
	locked = [val boolValue];
    }
  return self;
}


- (NSDictionary *)objectDescription
{
#ifdef GNUSTEP
    [self subclassResponsibility: _cmd];
#endif
    return nil;
}


- (id)copyWithZone:(NSZone *)zone
{
    GRDrawableObject *objCopy;
    GRObjectEditor *editorCopy;

    objCopy = (GRDrawableObject *)NSCopyObject(self, 0, zone);
    editorCopy = [[self editor] copy];
    [editorCopy setObject: objCopy];
    
    objCopy->docView = [self view];
    objCopy->editor = editorCopy;

    objCopy->strokeColor = [[strokeColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
    objCopy->fillColor = [[fillColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
    
    return objCopy;
}

- (BOOL)objectHitForSelection:(NSPoint)p
{
#ifdef GNUSTEP
    [self subclassResponsibility: _cmd];
#endif
    return NO;
}

- (GRDocView *)view
{
    return docView;
}

- (GRObjectEditor *)editor
{
    return editor;
}

- (BOOL)visible
{
    return visible;
}

- (void)setVisible:(BOOL)value
{
    visible = value;
    if(!visible)
        [editor unselect];
}

- (BOOL)locked
{
    return locked;
}

- (void)setLocked:(BOOL)value
{
    locked = value;
}

- (void)setZoomFactor:(CGFloat)f
{
    zmFactor = f;
}

- (void)setStrokeColor:(NSColor *)c
{
  [strokeColor release];
  strokeColor = [[c colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
}

- (NSColor *)strokeColor
{
    return strokeColor;
}

- (void)setFillColor:(NSColor *)c
{
  [fillColor release];
  fillColor = [[c colorUsingColorSpaceName: NSCalibratedRGBColorSpace] retain];
}

- (NSColor *)fillColor
{
    return fillColor;
}

- (void)setFilled:(BOOL)value
{
    filled = value;
}

- (BOOL)isFilled
{
    return filled;
}

- (void)setStroked:(BOOL)value
{
    stroked = value;
}

- (BOOL)isStroked
{
    return stroked;
}

- (void)draw
{
#ifdef GNUSTEP
    [self subclassResponsibility: _cmd];
#endif
}


@end

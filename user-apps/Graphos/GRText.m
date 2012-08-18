/*
 Project: Graphos
 GRText.m

 Copyright (C) 2000-2012 GNUstep Application Project

 Author: Enrico Sersale (original GDraw implementation)
 Author: Ing. Riccardo Mottola

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


#import "GRText.h"
#import "GRDocView.h"
#import "GRFunctions.h"
#import "Graphos.h"
#import "GRTextEditor.h"

// FIXME should zmfactor really be saved?

@implementation GRText

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
      zoomFactor:(float)zf
  withProperties:(NSDictionary *) properties
      openEditor:(BOOL)openedit
{
  int result;

  self = [super init];
  if(self)
    {
      docView = aView;
      zmFactor = zf;
      pos = NSMakePoint(p.x / zf, p.y / zf);
      rotation = 0;
      scalex = 1;
      scaley = 1;
      stroked = YES;
      filled = NO;
      visible = YES;
      locked = NO;
      strokeColor = [[NSColor blackColor] retain];
      fillColor = [[NSColor whiteColor] retain];
      ASSIGN(str, @"");

      if (properties != nil)
	{
	  NSColor *newColor;
	  id val;
	  
	  val = [properties objectForKey: @"stroked"];
	  if (val != nil)
	    [self setStroked:[val boolValue]];
	  newColor = (NSColor *)[properties objectForKey: @"strokecolor"];
	  if (newColor != nil)
	    [self setStrokeColor: newColor];
	  
	  val = [properties objectForKey: @"filled"];
	  if (val != nil)
	    [self setFilled: (BOOL)[val intValue]];
	  newColor = (NSColor *)[properties objectForKey: @"fillcolor"];
	  if (newColor != nil)
	    [self setFillColor: newColor];
	}
      editor = [[GRTextEditor alloc] initEditor:(GRText*)self];
      if(openedit)
	{
	  [(GRTextEditor *)editor setPoint: pos
				withString: nil
				attributes: nil];
	  result = [(GRTextEditor *)editor runModal];
	  if(result == NSAlertDefaultReturn)
	    [self setString: [[(GRTextEditor *)editor editorView] textString]
		 attributes: [[(GRTextEditor *)editor editorView] textAttributes]];
        }
    }
  return self;
}

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(float)zf
{
    NSMutableParagraphStyle *style;
    NSDictionary *attrs;
    NSString *fontname, *s;
    NSArray *linearr;

    self = [super init];
    if(self)
      {
        float strokeCol[4];
        float fillCol[4];
	float strokeAlpha;
	float fillAlpha;
	id obj;
	
        docView = aView;
        zmFactor = zf;
        editor = [[GRTextEditor alloc] initEditor:self];
        ASSIGN(str, [description objectForKey: @"string"]);
        pos = NSMakePoint([[description objectForKey: @"posx"]  floatValue],
                          [[description objectForKey: @"posy"]  floatValue]);
        fontname = [description objectForKey: @"fontname"];
        fsize = [[description objectForKey: @"fontsize"] floatValue];
        ASSIGN(font, [NSFont fontWithName: fontname size: fsize]);

        align = [[description objectForKey: @"txtalign"] intValue];
        parspace = [[description objectForKey: @"parspace"] floatValue];
        style = [[NSMutableParagraphStyle alloc] init];
        [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
        [style setAlignment: align];
        [style setParagraphSpacing: parspace];
        attrs = [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            style, NSParagraphStyleAttributeName, nil];
        size = [str sizeWithAttributes: attrs];
        scalex = [[description objectForKey: @"scalex"] floatValue];
        scaley = [[description objectForKey: @"scaley"] floatValue];
        rotation = [[description objectForKey: @"rotation"] floatValue];

	obj = [description objectForKey: @"stroked"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];
        stroked = [obj boolValue];
        strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];
        s = [description objectForKey: @"strokecolor"];
        linearr = [s componentsSeparatedByString: @" "];
	if ([linearr count] == 3)
	  {
	    strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    strokeColor = [NSColor colorWithCalibratedRed: strokeCol[0]
				   green: strokeCol[1]
				   blue: strokeCol[2]
				   alpha: strokeAlpha];
	  }
	else
	  {
	    strokeCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    strokeCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    strokeCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    strokeCol[3] = [[linearr objectAtIndex: 3] floatValue];
	    strokeColor = [NSColor colorWithDeviceCyan: strokeCol[0]
				   magenta: strokeCol[1]
				   yellow: strokeCol[2]
				   black: strokeCol[3]
				   alpha: strokeAlpha];
	    strokeColor = [strokeColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	  }
	obj = [description objectForKey: @"filled"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];
        filled = [obj boolValue];
	fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];
        s = [description objectForKey: @"fillcolor"];
        linearr = [s componentsSeparatedByString: @" "];
	if ([linearr count] == 3)
	  {
	    fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    fillColor = [NSColor colorWithCalibratedRed: fillCol[0]
				 green: fillCol[1]
				 blue: fillCol[2]
				 alpha: fillAlpha];
	  }
	else
	  {
	    fillCol[0] = [[linearr objectAtIndex: 0] floatValue];
	    fillCol[1] = [[linearr objectAtIndex: 1] floatValue];
	    fillCol[2] = [[linearr objectAtIndex: 2] floatValue];
	    fillCol[3] = [[linearr objectAtIndex: 3] floatValue];
	    fillColor = [NSColor colorWithDeviceCyan: fillCol[0]
				 magenta: fillCol[1]
				 yellow: fillCol[2]
				 black: fillCol[3]
				 alpha: fillAlpha];
	    fillColor = [fillColor colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
	  }
	obj = [description objectForKey: @"visible"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];
        visible = [obj boolValue];
	obj = [description objectForKey: @"locked"];
	if ([obj isKindOfClass:[NSString class]])
	  obj = [NSNumber numberWithInt:[obj intValue]];
        locked = [obj boolValue];

        zmFactor = [[description objectForKey: @"zmfactor"] floatValue];
        [self setZoomFactor: zf];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  GRText *objCopy;
  
  objCopy = [super copyWithZone:zone];
  
  objCopy->str = [str copy];
  objCopy->font = [font copy];
  
  return objCopy;
}



- (NSDictionary *)objectDescription
{
    NSMutableDictionary *dict;
    NSString *s;
    NSColor *strokeColorCMYK;
    NSColor *fillColorCMYK;
    float strokeCol[3];
    float fillCol[3];
    float strokeAlpha;
    float fillAlpha;

    strokeCol[0] = [strokeColor redComponent];
    strokeCol[1] = [strokeColor greenComponent];
    strokeCol[2] = [strokeColor blueComponent];
    strokeAlpha = [strokeColor alphaComponent];

    fillCol[0] = [fillColor redComponent];
    fillCol[1] = [fillColor greenComponent];
    fillCol[2] = [fillColor blueComponent];
    fillAlpha = [fillColor alphaComponent];

    dict = [NSMutableDictionary dictionaryWithCapacity: 1];
    [dict setObject: @"text" forKey: @"type"];

    [dict setObject: str forKey: @"string"];
    s = [NSString stringWithFormat: @"%.3f", pos.x];
    [dict setObject: s forKey: @"posx"];
    s = [NSString stringWithFormat: @"%.3f", pos.y];
    [dict setObject: s forKey: @"posy"];
    s = [font fontName];
    [dict setObject: s forKey: @"fontname"];
    s = [NSString stringWithFormat: @"%.3f", fsize];
    [dict setObject: s forKey: @"fontsize"];
    s = [NSString stringWithFormat: @"%.3f", parspace];
    [dict setObject: s forKey: @"parspace"];
    s = [NSString stringWithFormat: @"%i", align];
    [dict setObject: s forKey: @"txtalign"];
    s = [NSString stringWithFormat: @"%.3f", scalex];
    [dict setObject: s forKey: @"scalex"];
    s = [NSString stringWithFormat: @"%.3f", scaley];
    [dict setObject: s forKey: @"scaley"];
    s = [NSString stringWithFormat: @"%.3f", rotation];
    [dict setObject: s forKey: @"rotation"];
    [dict setObject: [NSNumber numberWithBool:stroked] forKey: @"stroked"];
    s = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        strokeCol[0], strokeCol[1], strokeCol[2]];
    [dict setObject: s forKey: @"strokecolor"];
    s = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: s forKey: @"strokealpha"];
    [dict setObject: [NSNumber numberWithBool: filled] forKey: @"filled"];
    s = [NSString stringWithFormat: @"%.3f %.3f %.3f",
        fillCol[0], fillCol[1], fillCol[2]];
    [dict setObject: s forKey: @"fillcolor"];
    s = [NSString stringWithFormat: @"%.3f", fillAlpha];
    [dict setObject: s forKey: @"fillalpha"];
    [dict setObject: [NSNumber numberWithBool: visible] forKey: @"visible"];
    [dict setObject: [NSNumber numberWithBool: locked] forKey: @"locked"];
    s = [NSString stringWithFormat: @"%.3f", zmFactor];
    [dict setObject: s forKey: @"zmfactor"];

    return dict;
}

- (NSString *)fontName
{
    return [font fontName];
}

- (void)dealloc
{
    [str release];
    [font release];
    [super dealloc];
}

- (void)setString:(NSString *)aString attributes:(NSDictionary *)attrs
{
    NSParagraphStyle *pstyle;

    ASSIGN(str, aString);
    ASSIGN(font, [attrs objectForKey: NSFontAttributeName]);
    fsize = [font pointSize];
    pstyle = [attrs objectForKey: NSParagraphStyleAttributeName];
    parspace = [pstyle paragraphSpacing];
    align = [pstyle alignment];
    size = [str sizeWithAttributes: attrs];
    [self setZoomFactor: zmFactor];
}

// maybe should be moved into the editor
- (void)edit
{
    NSDictionary *attrs;
    NSMutableParagraphStyle *style;
    int result;

    style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [style setAlignment: align];
    [style setParagraphSpacing: parspace];

    attrs = [NSDictionary dictionaryWithObjectsAndKeys:
        font, NSFontAttributeName,
        style, NSParagraphStyleAttributeName, nil];

    [(GRTextEditor *)editor setPoint: pos
          withString: str
          attributes: attrs];
    result = [(GRTextEditor *)editor runModal];
    if(result == NSAlertDefaultReturn)
        [self setString: [[(GRTextEditor *)editor editorView] textString]
             attributes: [[(GRTextEditor *)editor editorView] textAttributes]];
}

- (BOOL)pointInBounds:(NSPoint)p
{
    if(pointInRect(bounds, p) || pointInRect(selRect, p))
        return YES;
    return NO;
}

- (void)moveAddingCoordsOfPoint:(NSPoint)p
{
    pos.x += p.x;
    pos.y += p.y;
    bounds = NSMakeRect(pos.x, pos.y, size.width, size.height /2);
    selRect = NSMakeRect(pos.x - 3, pos.y - 3, 6, 6);
}

- (void)setZoomFactor:(float)f
{
    NSString *fname;

    pos.x = pos.x / zmFactor * f;
    pos.y = pos.y / zmFactor * f;
    fsize = fsize / zmFactor * f;
    parspace = parspace / zmFactor * f;
    size = NSMakeSize(size.width / zmFactor * f, size.height / zmFactor * f);
    bounds = NSMakeRect(pos.x, pos.y, size.width, size.height /2);
    selRect = NSMakeRect(pos.x - 3, pos.y - 3, 6, 6);
    fname = [font fontName];
    ASSIGN(font, [NSFont fontWithName: fname size: fsize]);
    zmFactor = f;
}

- (void)setScalex:(float)x scaley:(float)y
{
    scalex = x;
    scaley = y;
}

- (void)setRotation:(float)r
{
    rotation = r;
}

- (void)setLocked:(BOOL)value
{
    [super setLocked:value];
    if(!locked)
        [editor unselect];
    else
        [editor selectAsGroup];
}



- (NSBezierPath *) makePathFromString: (NSString *) aString
                              forFont: (NSFont *) aFont
                              atPoint: (NSPoint) aPoint
{
    NSTextView *textview;
    NSGlyph *glyphs;
    NSBezierPath *path;
    NSRange range;
    NSLayoutManager *layoutManager;


    textview = [[NSTextView alloc] init];

    [textview setString: aString];
    [textview setFont: aFont];

    layoutManager = [textview layoutManager];

    range = [layoutManager glyphRangeForCharacterRange:
        NSMakeRange (0, [aString length])
                                  actualCharacterRange: NULL];

    glyphs = (NSGlyph *) malloc (sizeof(NSGlyph) * (range.length * 2));
    [layoutManager getGlyphs: glyphs  range: range];

    
    path = [NSBezierPath bezierPath];

    [path moveToPoint: aPoint];
    [path appendBezierPathWithGlyphs: glyphs
                               count: range.length  inFont: font];

    free (glyphs);
    [textview release];

    return (path);
}

- (void)draw
{
    NSArray *lines;
    NSString *line;
    float baselny;
    int i;
    NSBezierPath *bezp;
    NSMutableParagraphStyle *style;
    NSDictionary *strAttr;
    NSFont *tempFont;

    if(!visible)
        return;

    style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [style setAlignment: align];
    [style setParagraphSpacing: parspace];
    tempFont = [NSFont fontWithName:[font fontName] size:fsize*zmFactor];
    if (filled)
      {
	strAttr = [[NSDictionary dictionaryWithObjectsAndKeys:
				   tempFont, NSFontAttributeName,
				 strokeColor, NSForegroundColorAttributeName,
				 fillColor, NSBackgroundColorAttributeName,
				 style, NSParagraphStyleAttributeName, nil] retain];
      }
    else
      {
	strAttr = [[NSDictionary dictionaryWithObjectsAndKeys:
				   tempFont, NSFontAttributeName,
				 strokeColor, NSForegroundColorAttributeName,
				 style, NSParagraphStyleAttributeName, nil] retain];
      }

    baselny = pos.y;
    bezp = [NSBezierPath bezierPath];
    [bezp setLineWidth:0];
    if([str length] > 0)
    {
        lines = [str componentsSeparatedByString: @"\n"];
        for(i = 0; i < [lines count]; i++)
        {
            line = [lines objectAtIndex: i];
	    
            [line drawAtPoint: NSMakePoint(pos.x, baselny) withAttributes:strAttr];


            if([editor isSelect])
            {
                [[NSColor blackColor] set];
                [bezp moveToPoint:NSMakePoint(pos.x, baselny)];
                [bezp lineToPoint:NSMakePoint(pos.x + bounds.size.width, baselny)];
            }

            baselny -= parspace;
        }

        if([editor isSelect])
        {
            [bezp stroke];
            [[NSColor blackColor] set];
            NSRectFill(selRect);
        }
    }
} 

@end

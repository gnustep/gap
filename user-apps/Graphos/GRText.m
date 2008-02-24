#import "GRText.h"
#import "GRDocView.h"
#import "GRFunctions.h"
#import "Graphos.h"

@implementation GRText

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
      zoomFactor:(float)zf
      openEditor:(BOOL)openedit
{
    int result;

    self = [super init];
    if(self)
    {
        myView = aView;
        zmFactor = zf;
        bzp = [[NSBezierPath bezierPath] retain];
        [bzp setCachesBezierPath: NO];
        pos = NSMakePoint(p.x / zf, p.y / zf);
        rotation = 0;
        scalex = 1;
        scaley = 1;
        stroked = NO;
        filled = YES;
        visible = YES;
        locked = NO;
        strokeColor[0] = 0;
        strokeColor[1] = 0;
        strokeColor[2] = 0;
        strokeColor[3] = 1;
        fillColor[0] = 0;
        fillColor[1] = 0;
        fillColor[2] = 0;
        fillColor[3] = 1;
        strokeAlpha = 1;
        fillAlpha = 1;
        ASSIGN(str, @"");

        if(openedit)
        {
            editor = [[GRTextEditor alloc] initAtPoint: pos
                                            withString: nil
                                              withText: self
                                            attributes: nil];
            result = [[editor editorView] runModal];
            if(result == NSAlertDefaultReturn)
                [self setString: [[editor editorView] textString]
                     attributes: [[editor editorView] textAttributes]];
            [editor release];
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
        myView = aView;
        zmFactor = zf;
        ASSIGN(str, [description objectForKey: @"string"]);
        pos = NSMakePoint([[description objectForKey: @"posx"]  floatValue],
                          [[description objectForKey: @"posy"]  floatValue]);
        fontname = [description objectForKey: @"fontname"];
        fsize = [[description objectForKey: @"fontsize"] floatValue];
        ASSIGN(font, [NSFont fontWithName: fontname size: fsize]);

        align = [[description objectForKey: @"txtalign"] intValue];
        parspace = [[description objectForKey: @"parspace"] floatValue];
        // a cast to get rid of a compiler warning
        style = (NSMutableParagraphStyle *)[NSMutableParagraphStyle defaultParagraphStyle];
        [style setAlignment: align];
        [style setParagraphSpacing: parspace];
        attrs = [NSDictionary dictionaryWithObjectsAndKeys:
            font, NSFontAttributeName,
            style, NSParagraphStyleAttributeName, nil];
        size = [str sizeWithAttributes: attrs];
        scalex = [[description objectForKey: @"scalex"] floatValue];
        scaley = [[description objectForKey: @"scaley"] floatValue];
        rotation = [[description objectForKey: @"rotation"] floatValue];

        stroked = (BOOL)[[description objectForKey: @"stroked"] intValue];
        s = [description objectForKey: @"strokecolor"];
        linearr = [s componentsSeparatedByString: @" "];
        strokeColor[0] = [[linearr objectAtIndex: 0] floatValue];
        strokeColor[1] = [[linearr objectAtIndex: 1] floatValue];
        strokeColor[2] = [[linearr objectAtIndex: 2] floatValue];
        strokeColor[3] = [[linearr objectAtIndex: 3] floatValue];
        strokeAlpha = [[description objectForKey: @"strokealpha"] floatValue];

        filled = (BOOL)[[description objectForKey: @"filled"] intValue];
        s = [description objectForKey: @"fillcolor"];
        linearr = [s componentsSeparatedByString: @" "];
        fillColor[0] = [[linearr objectAtIndex: 0] floatValue];
        fillColor[1] = [[linearr objectAtIndex: 1] floatValue];
        fillColor[2] = [[linearr objectAtIndex: 2] floatValue];
        fillColor[3] = [[linearr objectAtIndex: 3] floatValue];
        fillAlpha = [[description objectForKey: @"fillalpha"] floatValue];

        visible = (BOOL)[[description objectForKey: @"visible"] intValue];
        locked = (BOOL)[[description objectForKey: @"locked"] intValue];

        zmFactor = [[description objectForKey: @"zmfactor"] floatValue];
        [self setZoomFactor: zf];
    }
    return self;
}

- (GRTextEditor *)editor
{
    return editor;
}

- (GRText *)duplicate
{
    GRText *gdtxt;
    NSDictionary *attrs;
    NSMutableParagraphStyle *style;

    // a cast to get rid of a compiler warning
    style = (NSMutableParagraphStyle *)[NSMutableParagraphStyle defaultParagraphStyle];
    [style setAlignment: align];
    [style setParagraphSpacing: parspace];

    attrs = [NSDictionary dictionaryWithObjectsAndKeys:
        font, NSFontAttributeName, style, NSParagraphStyleAttributeName, nil];

    gdtxt = [[[GRText alloc] initInView: myView atPoint: pos
                             zoomFactor: zmFactor openEditor: NO] autorelease];
    [gdtxt setString: str attributes: attrs];
    [gdtxt setScalex: scalex scaley: scaley];
    [gdtxt setRotation: rotation];
    [gdtxt setStroked: stroked];
    [gdtxt setStrokeColor: strokeColor];
    [gdtxt setStrokeAlpha: strokeAlpha];
    [gdtxt setFilled: filled];
    [gdtxt setFillColor: fillColor];
    [gdtxt setFillAlpha: fillAlpha];
    [gdtxt setVisible: visible];
    [gdtxt setLocked: locked];
    [[gdtxt editor] setIsValid: NO];

    return gdtxt;
}

- (NSDictionary *)objectDescription
{
    NSMutableDictionary *dict;
    NSString *s;

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
    s = [NSString stringWithFormat: @"%i", stroked];
    [dict setObject: s forKey: @"stroked"];
    s = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3]];
    [dict setObject: s forKey: @"strokecolor"];
    s = [NSString stringWithFormat: @"%.3f", strokeAlpha];
    [dict setObject: s forKey: @"strokealpha"];
    s = [NSString stringWithFormat: @"%i", filled];
    [dict setObject: s forKey: @"filled"];
    s = [NSString stringWithFormat: @"%.3f %.3f %.3f %.3f",
        fillColor[0], fillColor[1], fillColor[2], fillColor[3]];
    [dict setObject: s forKey: @"fillcolor"];
    s = [NSString stringWithFormat: @"%.3f", fillAlpha];
    [dict setObject: s forKey: @"fillalpha"];
    s = [NSString stringWithFormat: @"%i", visible];
    [dict setObject: s forKey: @"visible"];
    s = [NSString stringWithFormat: @"%i", locked];
    [dict setObject: s forKey: @"locked"];
    s = [NSString stringWithFormat: @"%.3f", zmFactor];
    [dict setObject: s forKey: @"zmfactor"];

    return dict;
}

- (NSString *)psDescription
{
    NSString *pss;

    if(!visible)
        return nil;

    pss = [NSString stringWithFormat:
        @"\n/%@ %.3f sf\nn\n%.3f %.3f m\n(%@)show\n",
        [font fontName], fsize, pos.x, pos.y, str];
    if(stroked)
        pss = [pss stringByAppendingFormat: @"%.3f %.3f %.3f %.3f k\nstroke\n",
            strokeColor[0], strokeColor[1], strokeColor[2], strokeColor[3]];
    if(filled)
        pss = [pss stringByAppendingFormat: @"%.3f %.3f %.3f %.3f k\nfill\n",
            fillColor[0], fillColor[1], fillColor[2], fillColor[3]];

    return pss;
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

- (void)edit
{
    NSDictionary *attrs;
    NSMutableParagraphStyle *style;
    int result;

    // a cast to get rid of a compiler warning
    style = (NSMutableParagraphStyle *)[NSMutableParagraphStyle defaultParagraphStyle];
    [style setAlignment: align];
    [style setParagraphSpacing: parspace];

    attrs = [NSDictionary dictionaryWithObjectsAndKeys:
        font, NSFontAttributeName,
        style, NSParagraphStyleAttributeName, nil];

    editor = [[GRTextEditor alloc] initAtPoint: pos
                                    withString: str attributes: attrs];
    result = [[editor editorView] runModal];
    if(result == NSAlertDefaultReturn)
        [self setString: [[editor editorView] textString]
             attributes: [[editor editorView] textAttributes]];
    [editor release];
    [[NSApp delegate] updateCurrentWindow];
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

- (void)setStroked:(BOOL)value
{
    stroked = value;
}

- (BOOL)isStroked
{
    return stroked;
}

- (void)setStrokeColor:(float *)c
{
    int i;

    for(i = 0; i < 4; i++)
        strokeColor[i] = c[i];
}

- (float *)strokeColor
{
    return strokeColor;
}

- (void)setStrokeAlpha:(float)alpha
{
    strokeAlpha = alpha;
}

- (float)strokeAlpha
{
    return strokeAlpha;
}

- (void)setFilled:(BOOL)value
{
    filled = value;
}

- (BOOL)isFilled
{
    return filled;
}

- (void)setFillColor:(float *)c
{
    int i;

    for(i = 0; i < 4; i++)
        fillColor[i] = c[i];
}

- (float *)fillColor
{
    return fillColor;
}

- (void)setFillAlpha:(float)alpha
{
    fillAlpha = alpha;
}

- (float)fillAlpha
{
    return fillAlpha;
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

    textview = [[NSTextView alloc] init];

    [textview setString: aString];
    [textview setFont: aFont];

    NSLayoutManager *layoutManager;
    layoutManager = [textview layoutManager];

    NSRange range;
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

- (GRDocView *)view
{
    return myView;
}

- (void)draw
{
    NSArray *lines;
    NSString *line;
    float baselny = pos.y;
    NSColor *color;
    int i;
    NSBezierPath *bezp;

    if(!visible)
        return;

    [bzp release];
    bzp = [[self makePathFromString:str forFont:font atPoint:pos] retain];
    
    bezp = [NSBezierPath bezierPath];
    [bezp appendBezierPath:bzp];
    if([str length] > 0) {
        [font set];

        if(stroked) {
            [NSGraphicsContext saveGraphicsState];
            color = [NSColor colorWithDeviceCyan: fillColor[0]
                                         magenta: fillColor[1]
                                          yellow: fillColor[2]
                                           black: fillColor[3]
                                           alpha: fillAlpha];
            color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            [color set];
            [bezp stroke];
            [NSGraphicsContext restoreGraphicsState];
        }
        
        if(filled) {
            [NSGraphicsContext saveGraphicsState];
            color = [NSColor colorWithDeviceCyan: fillColor[0]
                                         magenta: fillColor[1]
                                          yellow: fillColor[2]
                                           black: fillColor[3]
                                           alpha: fillAlpha];
            color = [color colorUsingColorSpaceName: NSCalibratedRGBColorSpace];
            [color set];
            [bezp fill];
            [NSGraphicsContext restoreGraphicsState];
        }

        
        lines = [str componentsSeparatedByString: @"\n"];
        for(i = 0; i < [lines count]; i++)
        {
            line = [lines objectAtIndex: i];

            if([editor isSelect]) {
                [[NSColor blackColor] set];
                [bezp lineToPoint:NSMakePoint(pos.x + bounds.size.width, baselny)];
                [bezp stroke];
            }

            baselny -= parspace;
        }

        if([editor isSelect])
        {
            [[NSColor blackColor] set];
            NSRectFill(selRect);
        }
    }
}

@end

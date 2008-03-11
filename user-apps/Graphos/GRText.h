#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "GRDrawableObject.h"

@class GRDocView;

@interface GRText : GRDrawableObject
{
    NSString *str;
    NSFont *font;
    NSPoint pos;
    float fsize;
    NSTextAlignment align;
    float parspace;
    NSSize size;
    NSRect bounds;
    float scalex, scaley;
    float rotation;
    float strokeColor[4], fillColor[4];
    float strokeAlpha, fillAlpha;
    float zmFactor;
    BOOL stroked, filled;
    NSRect selRect;
}

- (id)initInView:(GRDocView *)aView
         atPoint:(NSPoint)p
                    zoomFactor:(float)zf
                    openEditor:(BOOL)openedit;

- (id)initFromData:(NSDictionary *)description
            inView:(GRDocView *)aView
        zoomFactor:(float)zf;


- (NSString *)psDescription;

- (NSString *)fontName;

- (void)setString:(NSString *)aString attributes:(NSDictionary *)attrs;

- (void)edit;

- (BOOL)pointInBounds:(NSPoint)p;

- (void)moveAddingCoordsOfPoint:(NSPoint)p;

- (void)setZoomFactor:(float)f;

- (void)setScalex:(float)x scaley:(float)y;

- (void)setRotation:(float)r;

- (void)setStroked:(BOOL)value;

- (BOOL)isStroked;

- (void)setStrokeColor:(float *)c;

- (float *)strokeColor;

- (void)setStrokeAlpha:(float)alpha;

- (float)strokeAlpha;

- (void)setFilled:(BOOL)value;

- (BOOL)isFilled;

- (void)setFillColor:(float *)c;

- (float *)fillColor;

- (void)setFillAlpha:(float)alpha;

- (float)fillAlpha;


- (void)draw;


- (NSBezierPath *) makePathFromString: (NSString *) aString
                              forFont: (NSFont *) aFont
                              atPoint: (NSPoint) aPoint;
@end


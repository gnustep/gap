#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#define DIGIT_TYPE @"Digit"

#define DIGIT_FIELD_DIM 40
#define DIGIT_FONT_SIZE 24

@interface DigitSource : NSView
{
  int digit;
}

- initAtPoint:(NSPoint)loc  withDigit:(int)dval;

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag;

- makeDragImages;

- (void)mouseDown:(NSEvent *)theEvent;

@end

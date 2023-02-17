#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "BackView.h"

typedef struct _sdata {
  int sx, sy, ex, ey ;
  int c ;
} sdata;

@interface MandelView:BackView
{
  id	colorButton;
  id	inspectorPanel;
  id	spermCountSlider;
  id	spermWidthSlider;
  id backWell ;
  id Well1 ;
  id Well2 ;
  id Well3 ;
  id Well4 ;
  
  sdata todo[1000] ;
  int stack, max_stack ;
  int best_max_stack ;
  
  long draw_length, best_draw_length ;
  
  double or_x, or_y, or_w, odx, ody ;
  double old_or_x, old_or_y, old_or_w ;
  double best_or_x, best_or_y, best_or_w ;
  int best_lost ;
  
  time_t last_finished ;
  BOOL drawing_mandel, frame_drawn ;
  
  BOOL use_fixed ;
  NSColor *color; 
  
  NSColor *mypal[256] ;
  int cx, cy ;
  double sx, ex, sy, ey, dx, dy ;
  BOOL alreadyInitialized;
  int randCount1, randCount2;
  
  BOOL useColors; 
  CGFloat lineWidth;
  int resolution;
}

extern id SP_sharedInspectorPanel;
extern BOOL SP_useColors; 
extern CGFloat SP_lineWidth;
extern int SP_count;

- inspector:sender;
- setUseColor:sender;
// - sizeTo:(CGFloat)width :(CGFloat)height ;
- (void) oneStep ;
- newWindow ;
// - initFrame:(NSRect *)rect;
- setImageConstraints;

- setColors:sender ;
- giveColorPanel:sender ;

- drawNextBounds ;
// - drawSelf:(const NSRect *)rects :(int)rectCount ;

@end

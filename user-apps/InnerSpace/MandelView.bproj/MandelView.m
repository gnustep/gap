#import <math.h>
#import "MandelView.h"
// #import "Thinker.h"
 
#include "ms_real.h"
#include "ms_real.c"
//
#include "time.h"

//#define steps(a,b,c) mandelbrot(a,b,256)
#define steps(a,b,c) (use_fixed ? mandelbrot(a,b,256) : newsteps(a,b) )
#define RANDINT(n) (random() % (n))
#define RANDFLOAT(f) (((f) * (float)(random() & 0x0ffff)) / (float)0x0ffff)
#define RAND ((float)rand()/(float)RAND_MAX)

float randBetween(float lower, float upper)
{
  float result = 0.0;
  
  if (lower > upper) 
    {
      float temp = 0.0;
      temp = lower; lower = upper; upper = temp;
    }
  result = ((upper - lower) * RAND + lower);
  // printf("upper = %f, lower = %f, result = %f\n",upper,lower,result);

  return result;
}

int newsteps( double x, double y) ;
     


@implementation MandelView

void NSConvertColorToRGB( NSColor *color, CGFloat *red, CGFloat *green, CGFloat *blue)
{
  *red = [color redComponent];
  *green = [color greenComponent];
  *blue = [color blueComponent];
}

NSColor* NSConvertRGBToColor( CGFloat red, CGFloat green, CGFloat blue)
{
  return [NSColor colorWithCalibratedRed: red
				   green: green
				    blue: blue
				   alpha: 1.0];
}

void spreadNSColors( NSColor *col1, NSColor *col2, NSColor **targ, int n ) 
{
    CGFloat cur_rgb[3], rgb_step[3] ;
    NSUInteger i ;

    NSConvertColorToRGB( col2, &(rgb_step[0]), &(rgb_step[1]), &(rgb_step[2]) ) ;
    NSConvertColorToRGB( col1, &(cur_rgb[0]), &(cur_rgb[1]), &(cur_rgb[2]) ) ;

    rgb_step[0] /= (n-1) ;
    rgb_step[1] /= (n-1) ;
    rgb_step[2] /= (n-1) ;

    for( i=0; i<n; i++)
      {
	targ[i] = NSConvertRGBToColor( cur_rgb[0], cur_rgb[1], cur_rgb[2] ) ;
	cur_rgb[0] += rgb_step[0] ;
	cur_rgb[1] += rgb_step[1] ;
	cur_rgb[2] += rgb_step[2] ;
      }
}

void NSSetColor( NSColor *color )
{
  [color set];
}

int newsteps( double x, double y)
{
    register double x1, y1, xs, ys ;
    register int c;

    x1 = x ; y1 = y ;

    xs = x1 * x1 ;
    ys = y1 * y1 ;
    c = 0 ;
    while( (xs + ys < 4.0) && (c < 255) ) {
	y1 = 2 * x1 * y1 + y ;
	x1 = xs - ys + x ;
	c++ ;
	xs = x1 * x1 ;
	ys = y1 * y1 ;
    }
    return c ;
}

/* this routine was taken from mandelspawn 0.7 by Andreas Gustafsson,
gson@niksula.hut.fi */

/*  
    This file is part of MandelSpawn, a network Mandelbrot program.

    Copyright (C) 1990-1993 Andreas Gustafsson

    MandelSpawn is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License, version 1,
    as published by the Free Software Foundation.

    MandelSpawn is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License,
    version 1, along with this program; if not, write to the Free 
    Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

int mandelbrot(parms0, parms1, maxiter )
    double parms0,parms1;
    int maxiter;
{
      register real x_re, x_im;
      register real c_re, c_im;
      register real xresq, ximsq;

      int count;


      c_re = double_to_fixed(parms0);
      c_im = double_to_fixed(parms1);
      x_re = c_re ;
      x_im = c_im ;

      /* The following loop is where the Real Work gets done. */
      count=0;
      while(count < 255)
      {	
	/* 
	  This is the familiar "z := z^2 + c; abort if |z| > 2"
	  Mandelbrot iteration, with the arithmetic operators hidden
	  in macros so that the same code can be compiled for either
	  fixed-point or floating-point arithmetic.
	  The macros (mul_real(), etc.) are defined in ms_real.h. 
	*/
	xresq=mul_real(x_re, x_re);
	ximsq=mul_real(x_im, x_im);
	if(gteq_real(add_real(xresq, ximsq), four_real()))
	  break;
	x_im=add_real(twice_mul_real(x_re, x_im), c_im);
	x_re=add_real(sub_real(xresq, ximsq), c_re);
	count++;
      }
  return count;
}

- (instancetype) initWithFrame: (NSRect)rect
{
  NSRect bounds;
  
  sx = -1.5 ; ex = 1.0 ;
  sy = -1.5 ; ey = 1.5 ;
  
  self = [super initWithFrame:rect];
  if (self == nil)
    return nil;

  bounds = [self bounds];
  [self allocateGState];		// For faster lock/unlockFocus
  
  [inspectorPanel display];
  
  color = [NSColor systemYellowColor];
  alreadyInitialized = NO;
  randCount1 = 100;
  randCount2 = 200;
  
  drawing_mandel = YES ;
  frame_drawn = YES ;
  use_fixed = YES ;
  [self setColors: backWell] ;
  
  
  
  or_w = 2.5 ;
  
  odx = or_w / bounds.size.width ;
  ody = odx ;
  
  or_x = -2.0 ;
  or_y = -1.25 ;
  
  best_lost = 0 ;
  best_max_stack = 0 ;
  best_draw_length = 0 ;
  draw_length = 0 ;
  
  stack = 0 ;
  todo[0].sx = 0 ;
  todo[0].ex = bounds.size.width ;
  todo[0].sy = 0 ;
  todo[0].ey = bounds.size.height ;
  todo[0].c = steps( or_x, or_y, 255 ) ;
  
  return self;
}

- drawRect: (NSRect)rects // :(int)rectCount
{
  // if (!rects || !rectCount) return self;
  [super drawRect: rects]; // :rectCount];
  return self;
}

- (id) setColors: (id)sender
{
    mypal[255] = [backWell color] ;

    spreadNSColors( [Well1 color], [Well2 color], &mypal[0], 83 ) ;
    spreadNSColors( [Well2 color], [Well3 color], &mypal[83], 83 ) ;
    spreadNSColors( [Well3 color], [Well4 color], &mypal[166], 89  ) ;

    spreadNSColors( [Well1 color], [Well2 color], &mypal[0], 16 ) ;
    spreadNSColors( [Well2 color], [Well3 color], &mypal[16], 16 ) ;
    spreadNSColors( [Well3 color], [Well4 color], &mypal[32], 16 ) ;
    spreadNSColors( [Well4 color], [Well1 color], &mypal[48], 16 ) ;
    spreadNSColors( [Well1 color], [Well2 color], &mypal[64], 16 ) ;
    spreadNSColors( [Well2 color], [Well3 color], &mypal[80], 16 ) ;
    spreadNSColors( [Well3 color], [Well4 color], &mypal[96], 16 ) ;
    spreadNSColors( [Well4 color], [Well1 color], &mypal[112], 16 ) ;
    spreadNSColors( [Well1 color], [Well2 color], &mypal[128], 16 ) ;
    spreadNSColors( [Well2 color], [Well3 color], &mypal[128+0], 16 ) ;
    spreadNSColors( [Well3 color], [Well4 color], &mypal[128+16], 16 ) ;
    spreadNSColors( [Well4 color], [Well1 color], &mypal[128+32], 16 ) ;
    spreadNSColors( [Well1 color], [Well2 color], &mypal[128+48], 16 ) ;
    spreadNSColors( [Well2 color], [Well3 color], &mypal[128+64], 16 ) ;
    spreadNSColors( [Well3 color], [Well4 color], &mypal[128+80], 16 ) ;
    spreadNSColors( [Well4 color], [Well1 color], &mypal[128+96], 16 ) ;
    spreadNSColors( [Well1 color], [Well2 color], &mypal[128+112], 15 ) ;

    return self ;
}

- setImageConstraints
{
  [super setImageConstraints];
  
  if (imageRect.origin.x > maxCoord.x ||
      imageRect.origin.y > maxCoord.y)
    {
      imageRect.origin.x = randBetween(0, maxCoord.x);
      imageRect.origin.y = randBetween(0, maxCoord.y);
    }
  
  return self;
}

#define gl_fillbox( x, y, h, w, c ) myfillbox( x, y, h, w, c,p )

#define gl_setpixel(a, b, c)

void myfillbox( int x, int y, int w, int h, int c, NSColor **p )
{
  NSRect myrect2 ;
  NSColor *color = p[c];
  
  NSSetColor(color);
  myrect2 = NSMakeRect( x, y, w, h ) ;
  NSRectFill( myrect2 ) ;
}

void just_do( sdata *s, double or_x, double or_y, double odx, double ody, int *counter, NSColor **p, int resolution, int use_fixed )
{
  double x, y, init_x, init_y ;
  int i,j ;
  
  x = or_x + s->sx * odx ;
  y = or_y + s->sy * ody ;
  init_x = x ; init_y = y ;
  j = s->sx ; i=s->sy ; 
  gl_fillbox( j, i, 1, 1, s->c) ;
  i++ ; y+= ody ;
  for( ; i <= s->ey; i++, y+= ody ) {
    gl_fillbox( j, i, 1, 1, steps( x, y, 255 ) ) ;
  }
  
  j++ ; x+= odx ;
  for( ; j <= s->ex; j++, x+= odx) {
    for( i=s->sy,y=init_y; i<=s->ey; i++,y+=ody) {
      gl_fillbox( j, i,1,1, steps(x,y,255)) ;
    }
  }
}

int clean( sdata *s, double or_x, double or_y, double odx, double ody, int *counter, NSColor **p, int resolution, int use_fixed )
{
  double x, y, init_x, init_y ;
  int i,j, hx1, hy1, hx2, hy2, cur, cur2 ;
  
  x = or_x + s->sx * odx ;
  y = or_y + s->sy * ody ;
  if( (s->ex - s->sx) < 3 ) {
    init_x = x ; init_y = y ;
    j = s->sx ; i=s->sy ; 
    gl_fillbox( j, i, 1, 1, s->c) ;
    i++ ; y+= ody ;
    for( ; i <= s->ey; i++, y+= ody ) {
      gl_fillbox( j, i, 1, 1, steps( x, y, 255 ) ) ;
    }
    j++ ; x+= odx ;
    for( ; j <= s->ex; j++, x+= odx) 
      for( i=s->sy,y=init_y; i<=s->ey; i++,y+=ody) {
	gl_fillbox( j, i,1,1, steps(x,y,255)) ;
      }
    return YES ;
  } else if( (s->ey - s->sy) < 3 ) {
    init_x = x ; init_y = y ;
    j = s->sx ; i=s->sy ; 
    gl_fillbox( j, i, 1, 1, s->c) ;
    j++ ; x+= odx ;
    for( ; j <= s->ex; j++, x+= odx ) {
      gl_fillbox( j, i, 1, 1, steps( x, y, 255 ) ) ;
    }
    i++ ; y+= ody ;
    for( ; i <= s->ey; i++, y+= ody) 
      for( j=s->sx, x=init_x ; j<=s->ex; j++,x+=odx) {
	gl_fillbox( j, i,1,1, steps(x,y,255)) ;
	    }
    return YES ;
  }
  
  hx1 = (s->ex - s->sx) >> 1  ;
  hy1 = (s->ey - s->sy) >> 1 ;
  
  if( hx1 == 0 ) hx1 = 1 ;
  if( hy1 == 0 ) hy1 = 1 ;
  
  hx2 = s->ex - s->sx - hx1  ;
  hy2 = s->ey - s->sy - hy1  ;
  
  
  cur = s[0].c ;
  s[1].c = steps( x + hx1 *odx, y,255) ;
  s[2].c = steps( x + hx1 *odx, y + hy1 * ody,255 ) ;
  s[3].c = steps( x , y + hy1 * ody,255 ) ;
  
  gl_fillbox( s->sx, s->sy, hx1, hy1, cur ) ;
  gl_fillbox( s->sx + hx1, s->sy, hx2+1, hy1, s[1].c ) ;
  gl_fillbox( s->ex - hx2, s->sy+hy1, hx2+1, hy2+1, s[2].c ) ;
  gl_fillbox( s->sx, s->ey-hy2, hx1, hy2+1, s[3].c ) ;
  
  if( (s[1].c != cur) || (s[2].c != cur) || (s[3].c != cur))
    return NO ;
  
  
  /** - */
  j = s->sy ;
  for( i=s->sx+1, x+=odx ; i<s->sx+hx1; i++, x+= odx )  {
    cur2 = steps( x,y,curp1 ) ;
    if( cur != cur2 ) 
      return NO ;
  }
  cur2 = steps( x, y, curp1) ;
  if( cur != cur2 )
    return NO ;
  /** -- */
  for( i++, x+=odx ; i <= s->ex; i++, x+= odx )  {
    cur2 = steps( x, y, curp1) ;
    if( cur != cur2 )
      return NO ;
  }
  
  x -= odx ;
  i-- ;
  /** --| */
  for( j=s->sy ; j < s->sy+hy1; j++, y+= ody ) {
    cur2 = steps( x, y, curp1 ) ;
    if( cur != cur2 )
      return NO ;
  }
  cur2 = steps( x, y, curp1) ;
  if( cur != cur2 )
    return NO ;
  /** --|
      | */
  for( j++, y+= ody ; j <= s->ey; j++, y+= ody ) {
    cur2 = steps( x, y, curp1 ) ;
    if( cur != cur2 )
      return NO ;
  }
  /** --|
      -| */
  y -= ody ;
  j-- ;
  for( i=s->ex ; i >= s->sx+hx1; i--, x-= odx ) {
    cur2 = steps( x, y, curp1 ) ;
    if( cur != cur2 )
      return NO ;
  }
  
  cur2 = steps( x, y, curp1) ;
  if( cur != cur2 )
    return NO ;
  /** --|
      --| */
  for( i--, x-= odx ; i >= s->sx; i--, x-= odx ) {
    cur2 = steps( x, y, curp1 ) ;
    if( cur != cur2 )
      return NO ;
  }
  /** --|
      |--| */
  x += odx ;
  i++ ;
  for( j=s->ey ; j >= s->sy+hy1; j--, y-= ody ) {
    cur2 = steps( x, y, curp1) ;
    if( cur != cur2 )
      return NO ;
  }
  /** |--|
      |--| */
  for( ; j >= s->sy ; j--, y-= ody ) {
    cur2 = steps( x, y, curp1 ) ;
    if( cur != cur2 )
      return NO ;
  }
  return YES ;
}





void sort( sdata *s, int n, int depth )
{
  sdata t ;
  int i, mi ;
  mi = 0 ;
  if( n > 0 ) {
    for( i= (n > depth) ? n-depth:0; i <= n; i++)
      if( s[i].c < s[mi].c)
	mi = i ;
    if( mi != n ) { t = s[mi]; s[mi] = s[n]; s[n] = t ; }
  }
}

- (void) oneStep
{
  double temp ;
  sdata *ctodo ;
  int counter, hx, hy ;
  NSRect bounds = [self bounds];
  
  if( !drawing_mandel ) {
    if( time(NULL) - last_finished > 4 ) {
      drawing_mandel = YES ;
    }
    else if( !frame_drawn ) {
      if( time(NULL) - last_finished > 2 ) 
	[self drawNextBounds] ;
    }
    return;
  }
  
  
  ctodo = todo+stack ;
  counter = 0 ;
  while( (counter < 10) && (stack > -1) && (stack < 990) ) {
    counter++ ;
    ctodo = todo+stack ;
    if( !clean( &todo[stack], or_x, or_y, odx, ody, &counter, mypal, resolution, use_fixed ) ) {
      draw_length++ ;
      hx = (ctodo->ex - ctodo->sx) / 2 ;
      hy = (ctodo->ey - ctodo->sy) / 2 ;
      if( hx == 0 ) hx = 1 ;
      if( hy == 0 ) hy = 1 ;
      
      
      todo[stack+1].sx = ctodo->sx + hx ;
      todo[stack+1].sy = ctodo->sy ;
      todo[stack+1].ex = ctodo->ex ;
      todo[stack+1].ey = ctodo->sy + hy -1 ;
      
      todo[stack+3].sx = ctodo->sx ;
      todo[stack+3].sy = ctodo->sy + hy ;
      todo[stack+3].ex = ctodo->sx + hx -1 ;
      todo[stack+3].ey = ctodo->ey ;
      
      
      todo[stack+2].sx = ctodo->sx + hx ;
      todo[stack+2].sy = ctodo->sy + hy ;
      todo[stack+2].ex = ctodo->ex ;
      todo[stack+2].ey = ctodo->ey ;
      
      todo[stack].sx = ctodo->sx ;
      todo[stack].sy = ctodo->sy ;
      todo[stack].ex = ctodo->sx + hx -1 ;
      todo[stack].ey = ctodo->sy + hy -1 ;
      
      stack+=3 ;
      if( stack > max_stack )
	max_stack = stack ;
      
      sort( todo, stack,  6 ) ;
    } else {
      stack-- ;
      sort( todo, stack, 100 ) ;
    }
  }
  if( stack >= 990 ) {
    just_do( &todo[stack], or_x, or_y, odx, ody, &counter, mypal, resolution, use_fixed ) ;
    stack-- ;
  }
  if( stack < 0 ) {
    
    old_or_x = or_x ;old_or_y = or_y ;
    old_or_w = or_w ;
    last_finished = time(NULL) ;
    drawing_mandel = NO ;
    frame_drawn = NO ;
    
    
    if( best_draw_length == 0 )
      best_draw_length = draw_length ;
    
    
    if( draw_length < best_draw_length / 2 ) {
      drawing_mandel = YES ;
      if( best_lost == 20 ) {
	or_w = 2.5 ;
	or_x = -2.0 ;
	or_y = -1.25 ;
      } else {
	or_x = best_or_x ;
	or_y = best_or_y ;
	or_w = best_or_w ;
	best_lost++ ;
      }
    } else {
      best_lost = 0 ;
      best_or_x = or_x ;
      best_or_y = or_y ;
      best_or_w = or_w ;
    }
    
    or_x = 0.01 * (random() % 100) * or_w + or_x ;
    or_y = 0.01 * (random() % 100) * or_w + or_y ;
    or_w /= 5.0 ;
    
    
    
    odx = or_w / bounds.size.width ;
    ody = odx ;
    temp = or_x + odx ;
    
    if( double_to_fixed( temp ) == double_to_fixed( or_x ) )
      use_fixed = NO ;
    else
      use_fixed = YES ;
    
    stack = 0 ;
    todo[0].sx = 0 ;
    todo[0].ex = bounds.size.width-1 ;
    todo[0].sy = 0 ;
    todo[0].ey = bounds.size.height-1 ;
    todo[0].c = steps( or_x, or_y, 255 ) ;
    max_stack = 0 ;
    draw_length = 0 ;
  }
  return;
}

- drawNextBounds
{
  double oo_pixelwidth ;
  int x, y, w, h ;
  NSRect myrect2 ;
  NSRect bounds = [self bounds];
  
  oo_pixelwidth = (double) bounds.size.width / old_or_w ; 
  x = (or_x - old_or_x) * oo_pixelwidth ;
  y = (or_y - old_or_y) * oo_pixelwidth ;
  w = or_w * bounds.size.width / old_or_w ;
  h = or_w * bounds.size.height / old_or_w ;
  NSSetColor( NSConvertRGBToColor( (float) 0.8, (float)0.8, (float)0.8 )) ;
  myrect2 = NSMakeRect( x, y, w, h ) ;
  NSRectFill( myrect2 ) ;
  
  frame_drawn = YES ;
  return self ;
}

static float randMod(float orig, float by, float min, float max)
{ 
  orig = orig + RANDFLOAT(by * 2.0) - by;
  return (orig < min) ? min : ((orig > max) ? max : orig);
}

- newWindow
{
  NSRect bounds = [self bounds];
  
  or_w = 2.5 ;
  
  odx = or_w / bounds.size.width ;
  ody = odx ;
  
  or_x = -2.0 ;
  or_y = -1.25 ;
  
  stack = 0 ; max_stack = 0 ;
  todo[0].sx = 0 ;
  todo[0].ex = bounds.size.width-1 ;
  todo[0].sy = 0 ;
  todo[0].ey = bounds.size.height-1 ;
  todo[0].c = steps( or_x, or_y, 255 ) ;
  
  best_lost = 0 ;
  best_max_stack = 0 ;
  draw_length = 0 ;
  best_draw_length = 0 ;
  
  return self;
}

/*
- free
{
  return [super free];
}
*/

- setImage: image
{
  return self;
}

/*
- sizeTo:(NXCoord)width :(NXCoord)height
{
  [super sizeTo:width :height];
  
  if (!alreadyInitialized)
    {	
      alreadyInitialized = YES;
    }
  
  [self newWindow];
  return self;
}
*/

- inspector:sender
{
  if (!inspectorPanel)
    {
      // [NXBundle getPath:buf forResource:"mandle" ofType:"nib" inDirectory:[sender moduleDirectory:"Mandel"] withVersion:0];
      // [NXApp loadNibFile:buf owner:self withNames:NO];
      if (![NSBundle loadNibNamed: @"mandle" owner: self])
	{
	  NSLog(@"Failed to load");
	}
    }
  drawing_mandel = YES ;
  frame_drawn = YES ;
  use_fixed = YES ;
  
  [self setColors: backWell ] ;

  return inspectorPanel; 
}

- setLineWidth:sender
{
  return self;
}

- setNumLines:sender
{
  return self;
}

- setUseColor:sender
{
  return self;
}

- giveColorPanel:sender
{
  [NSApp orderFrontColorPanel: self];
  return self ;
}

@end

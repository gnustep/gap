#include "ms_real.h"

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

int mandelbrot(double parms0, double parms1, int maxiter )
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
  count = 0;
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
      if (gteq_real(add_real(xresq, ximsq), four_real()))
	{
	  break;
	}
      
      x_im=add_real(twice_mul_real(x_re, x_im), c_im);
      x_re=add_real(sub_real(xresq, ximsq), c_re);

      count++;
    }
  
  return count;
}

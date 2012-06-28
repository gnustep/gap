/*
   Project: Berkelium

   Copyright (C) 2012 Free Software Foundation

   Author: Gregory John Casamento,,,

   Created: 2012-06-24 18:56:36 -0400 by heron

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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "Berkelium.h"

// C++ includes...
#include <berkelium/WindowDelegate.hpp>
#include <berkelium/Context.hpp>
#include <iostream>

static BOOL _initialized = NO;

class MyDelegate : public Berkelium::WindowDelegate {

 private:
  BerkeliumKit *theView;
  
 public:
  MyDelegate(BerkeliumKit *view) {
    theView = view;
  }
  
  virtual void onPaint(Berkelium::Window* wini,
		       const unsigned char *bitmap_in, const Berkelium::Rect &bitmap_rect,
		       size_t num_copy_rects, const Berkelium::Rect* copy_rects,
		       int dx, int dy, const Berkelium::Rect& scroll_rect) 
  {
    NSImage *image = nil;

    // handle paint events...
    [theView onPaint: image];
  }
};

@implementation BerkeliumKit

/**
 * Initialize and return the instance.
 */
- (id) initFromFrame: (NSRect)frame
{
  if((self = [super init]) != nil)
    {
      if(_initialized == NO)
	{
	  Berkelium::init(Berkelium::FileString::empty());
	  _initialized = YES;
	}
      
      // Add update timer to periodically update the gui...
      _updateTimer = [NSTimer scheduledTimerWithTimeInterval: (NSTimeInterval)0.1 
						      target: self
						    selector: @selector(update:)
						    userInfo: nil
						     repeats: YES];

      Berkelium::Context* context = Berkelium::Context::create();
      _bwindow = Berkelium::Window::create(context);
      delete context;
      
      int width = (int)frame.size.width;
      int height = (int)frame.size.height;
      _bwindow->resize(height, width);

      // Set the delegate...
      MyDelegate *delegate = new MyDelegate((BerkeliumKit *)self);
      _bwindow->setDelegate(delegate);
    }

  return self; 
}

/**
 * Cleanup after ourselves.
 */
- (void) dealloc
{
  [_updateTimer release];
  [_url release];
  Berkelium::destroy();
  [super dealloc];
}

/**
 * Periodic update of Berkelium... allow the framework to synchronize with 
 * events.
 */
- (void) update: (NSTimer *)timer
{
  Berkelium::update();
}

/**
 * Set main frame URL...
 */
- (void) setMainFrameURL: (NSString *)theURL
{
  ASSIGN(_url, theURL);
  std::string url = [_url cString];
  _bwindow->navigateTo(Berkelium::URLString::point_to(url.data(), url.length()));
}

/**
 * return the main frame URL...
 */ 
- (NSString *)mainFrameURL
{
  return _url;
}

- (void) onPaint: (NSImage *)image
{
  NSLog(@"On paint...");
}
@end

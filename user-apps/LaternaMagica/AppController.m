/* 
   Project: LaternaMagica
   AppController.m

   Copyright (C) 2006-2010 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2006-01-16

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

#import "AppController.h"
#import "PRScale.h"


@implementation AppController

- (id) init
{
    if ((self = [super init]))
    {
        // add an observer for the file table view
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:fileListView];
        // add an observer for the window resize
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidResizeNotification object:window];
    }
    return self;
}

- (void)awakeFromNib
{
    NSRect frame;
    
    window = smallWindow;
    view = smallView;

    frame = [[NSScreen mainScreen] frame];
    fullWindow = [[LMWindow alloc] initWithContentRect: frame
                                             styleMask: NSBorderlessWindowMask
                                               backing: NSBackingStoreBuffered
                                                 defer: NO];
    [fullWindow setAutodisplay:YES];
    [fullWindow setExcludedFromWindowsMenu: YES];
    [fullWindow setBackgroundColor: [NSColor blackColor]];

    [smallView setFrame:[scrollView documentVisibleRect]];
    [smallView setImageAlignment:NSImageAlignTopLeft];

    fullView = [[LMFlipView alloc] initWithFrame:[fullWindow frame]];
    [fullView setImageScaling: NSScaleNone];
    [fullView setImageAlignment:NSImageAlignCenter];
    [fullView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    [fullView setController:self];
    

    // avoid replacing the contentview with a NSControl subclass, thus add a subview instead
    [[fullWindow contentView] addSubview: fullView];
    [fullWindow setInitialFirstResponder:fullView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)addFile:(NSString *)filename
{
    [fileListData addPath:filename];
    [fileListView reloadData];
}

- (void)addFiles:(id)sender
{
    NSOpenPanel   *openPanel;
    NSArray       *files;
    NSEnumerator  *e;
    NSString      *filename;
    NSFileManager *fmgr;
    NSDictionary  *attrs;

    openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    if ([openPanel runModalForTypes:NULL] != NSOKButton)
    {
        return;
    }

    files = [openPanel filenames];
    e = [files objectEnumerator];
    fmgr = [NSFileManager defaultManager];
    while ((filename = (NSString*)[e nextObject]))
    {
        attrs = [fmgr fileAttributesAtPath:filename traverseLink:YES];
        if (attrs)
        {
            if ([attrs objectForKey:NSFileType] == NSFileTypeDirectory)
            {
                NSArray      *dirContents;
                NSEnumerator *e2;
                NSString     *filename2;
                NSDictionary  *attrs2;

                dirContents = [fmgr subpathsAtPath:filename];
                e2 = [dirContents objectEnumerator];
                while ((filename2 = (NSString*)[e2 nextObject]))
                {
                    NSString *tempName;
                    NSString *lastPathComponent;

                    lastPathComponent = [filename2 lastPathComponent];
                    tempName = [filename stringByAppendingPathComponent:filename2];
                    attrs2 = [[NSFileManager defaultManager] fileAttributesAtPath:tempName traverseLink:YES];
                    if (attrs2)
                    {
                        if ([attrs2 objectForKey:NSFileType] != NSFileTypeDirectory)
                        {
                            if (!([lastPathComponent isEqualToString:@".gwdir"] || [lastPathComponent isEqualToString:@".DS_Store"]))
                            {
			      /* hide dot files, eventually a preference could be implemented */
			      if (![lastPathComponent hasPrefix: @"."])
                                [self addFile:tempName];
                            }
                        }
                    }
                }
            } else
            { /* not a directory */
                [self addFile:filename];
            }
        } else
        {
            NSLog(@"open panel did not return a valid path");
        }
    }
  [fileListView selectRow: [fileListView numberOfRows]-1 byExtendingSelection: NO];
}

// scale image according to options
- (void)scaleView:(NSImage *) image
{
    NSPoint rectOrigin;
    NSSize rectSize;

    if (image == nil)
      return;
      
    rectSize =  [window frame].size;
    if (scaleToFit)
    {
        NSSize imageSize;
        NSAffineTransform *at;
        float scaleH, scaleW;
        float scale;

        
        imageSize = [image size];

        scaleW = rectSize.width / imageSize.width;
        scaleH =  rectSize.height / imageSize.height;

        if (scaleW < scaleH)
            scale = scaleW;
        else
            scale = scaleH;

        at = [NSAffineTransform transform];
        [at scaleBy:scale];
        [view setFrameSize:[at transformSize:imageSize]];
    } else
    {
        [view setFrameSize:[image size]];
    }
    rectOrigin = NSMakePoint((rectSize.width - [view frame].size.width)/2, (rectSize.height - [view frame].size.height)/2);
    [view setFrameOrigin:rectOrigin];
    [view setNeedsDisplay:YES];
}

- (void)changeImage:(NSString *) file
{
    NSImage *image;

    image = [[NSImage alloc] initByReferencingFile:file];
    [self scaleView:image];
    [view setImage: image];
    [view setNeedsDisplay:YES];
    [[view superview] setNeedsDisplay:YES];
    [window displayIfNeeded];
    [image release];
    [window setTitleWithRepresentedFilename:file];
}

- (IBAction)setScaleToFit:(id)sender
{
    if ([fitButton state] == NSOnState)
    {
        scaleToFit = YES;
        [view setImageScaling:NSScaleToFit];
    } else
    {
        scaleToFit = NO;
        [view setImageScaling:NSScaleNone];
    }
    [scrollView setHasVerticalScroller:!scaleToFit];
    [scrollView setHasHorizontalScroller:!scaleToFit];
    [self scaleView:[view image]];
}

/** method called as a notification from the selection change */
- (void)_selectionDidChange :(NSNotification *)notif
{
    NSTableView *table;
    int         selectedRow;
    
    table = [notif object];
    selectedRow = [table selectedRow];
    if (selectedRow >= 0)
        [self changeImage:[fileListData pathAtIndex:selectedRow]];
}

/** method called as a notification from the window resize
  or if scale preferences changed */
- (void)_windowDidResize :(NSNotification *)notif
{
    [self scaleView: [view image]];
}


- (IBAction)setFullScreen: (id)sender
{
    NSImage *image;

    image = [view image];
    
    /* we choose not to respond to key events if not in fullscreen */
    if ([sender isKindOfClass:[NSEvent class]] && [fullScreenMenuItem state] == NSOffState)
        return;

    /* check the sender and set the other item accordingly */    
    if (sender == fullScreenButton)
        [fullScreenMenuItem setState:[fullScreenButton state]];
    else
    {
        if ([fullScreenMenuItem state] == NSOnState)
            [fullScreenMenuItem setState:NSOffState];
        else
            [fullScreenMenuItem setState:NSOnState];
        [fullScreenButton setState:[fullScreenMenuItem state]];
    }

    if ([fullScreenButton state] == NSOnState)
    {
        [fullWindow setLevel: NSScreenSaverWindowLevel];
        window = fullWindow;
        view = fullView;
    } else
    {
        [fullWindow orderOut:self];
        window = smallWindow;
        view = smallView;
    }
    [self setScaleToFit: self];
    [self scaleView: image];
    [view setImage: image];
    [view setNeedsDisplay:YES];
    [[view superview] setNeedsDisplay:YES];
    [window displayIfNeeded];
    [window makeKeyAndOrderFront: self];
}

- (IBAction)prevImage:(id)sender
{
    int sr;
    int rows;

    rows = [fileListView numberOfRows];
    if (rows > 0)
    {
        sr = [fileListView selectedRow];

        if (sr > 0)
            sr--;
        else
            sr = (rows - 1);

        [fileListView selectRow: sr byExtendingSelection: NO];
    }
}

- (IBAction)nextImage:(id)sender
{
    int sr;
    int rows;

    rows = [fileListView numberOfRows];

    if (rows > 0)
    {
        sr = [fileListView selectedRow];

        if (sr < (rows - 1))
            sr++;
        else
            sr = 0;

        [fileListView selectRow: sr byExtendingSelection: NO];
    }    
}

- (IBAction)removeImage:(id)sender
{
    int sr;
    int rows;

    rows = [fileListView numberOfRows];
    if (rows >= 0)
    {
        sr = [fileListView selectedRow];
        if (sr >= 0)
        {
            [fileListData removeObjectAtIndex: sr];
            [fileListView reloadData];

            rows = [fileListView numberOfRows];
            if (rows > 0)
            {
                // if we remove the last image, the selection changes
                // otherwise no selection change notification is generated
                // and thus we update simply the image
                if (sr >= rows)
                    [fileListView selectRow: rows-1 byExtendingSelection: NO];
                else
                    [self changeImage: [fileListData pathAtIndex: sr]];
            
            } else
            {
                // no image to select, we clear the display
                [view setImage: nil];
                [window setTitle:@"None"]; 
            }
        }
    }
}

- (IBAction)eraseImage:(id)sender
{
    int sr;
    
    sr = [fileListView selectedRow];
    if (sr >= 0)
        if (NSRunAlertPanel(nil, @"Really delete the image from disk?", @"Delete", @"Abort", nil) == NSAlertDefaultReturn)
        {
            NSFileManager *fm;
            
            fm = [NSFileManager defaultManager];
            // TODO should implement a handler and error messages
            [fm removeFileAtPath:[fileListData pathAtIndex:sr] handler:nil];
            
            [self removeImage:self];
        }
}


- (IBAction)rotateImage90:(id)sender
{
    NSImage *srcImage;
    NSBitmapImageRep *srcImageRep;
    NSImage *destImage;
    NSBitmapImageRep *destImageRep;
    int x, y;
    int w, h;
    int s;
    int srcSamplesPerPixel;
    int destSamplesPerPixel;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;

    srcImage = [view image];
    /* get source image representation and associated information */
    srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];

    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;
    destImage = [[NSImage alloc] initWithSize:NSMakeSize(h, w)]; /* we swap h and w */
    destImageRep = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                              pixelsWide:h
                              pixelsHigh:w
                           bitsPerSample:[srcImageRep bitsPerSample]
                         samplesPerPixel:[srcImageRep samplesPerPixel]
                                hasAlpha:[srcImageRep hasAlpha]
                                isPlanar:[srcImageRep isPlanar]
                          colorSpaceName:[srcImageRep colorSpaceName]
                             bytesPerRow:h*destSamplesPerPixel  // we need to set this because otherwise mac > 10.4 will set a padded value
                            bitsPerPixel:0];

    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcSamplesPerPixel * (y * w + x);
            p2 = destData + destSamplesPerPixel * ((w-x-1) * h + y);
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }

    [destImage addRepresentation:destImageRep];
    [destImageRep release];

    [self scaleView:destImage];
    [view setImage: destImage];
    [view setNeedsDisplay:YES];
    [[view superview] setNeedsDisplay:YES];
    [window displayIfNeeded];
    [destImage release];
}

- (IBAction)rotateImage180:(id)sender
{
    NSImage *srcImage;
    NSBitmapImageRep *srcImageRep;
    NSImage *destImage;
    NSBitmapImageRep *destImageRep;
    int x, y;
    int w, h;
    int s;
    int srcSamplesPerPixel;
    int destSamplesPerPixel;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;

    srcImage = [view image];
    /* get source image representation and associated information */
    srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];

    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;

    destImage = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    destImageRep = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                              pixelsWide:w
                              pixelsHigh:h
                           bitsPerSample:[srcImageRep bitsPerSample]
                         samplesPerPixel:[srcImageRep samplesPerPixel]
                                hasAlpha:[srcImageRep hasAlpha]
                                isPlanar:[srcImageRep isPlanar]
                          colorSpaceName:[srcImageRep colorSpaceName]
                             bytesPerRow:w*destSamplesPerPixel
                            bitsPerPixel:0];

    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];

    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcSamplesPerPixel * (y * w + x);
            p2 = destData + srcSamplesPerPixel * ((h-y-1) * w + (w-x-1));
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }

    [destImage addRepresentation:destImageRep];
    [destImageRep release];

    [self scaleView:destImage];
    [view setImage: destImage];
    [window displayIfNeeded];
    [destImage release];
}


- (IBAction)rotateImage270:(id)sender
{
    NSImage *srcImage;
    NSBitmapImageRep *srcImageRep;
    NSImage *destImage;
    NSBitmapImageRep *destImageRep;
    int x, y;
    int w, h;
    int s;
    int srcSamplesPerPixel;
    int destSamplesPerPixel;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;

    srcImage = [view image];
    /* get source image representation and associated information */
    srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];

    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    srcSamplesPerPixel = [srcImageRep samplesPerPixel];
    destSamplesPerPixel = srcSamplesPerPixel;

    destImage = [[NSImage alloc] initWithSize:NSMakeSize(h, w)]; /* we swap h and w */
    destImageRep = [[NSBitmapImageRep alloc]
                initWithBitmapDataPlanes:NULL
                              pixelsWide:h
                              pixelsHigh:w
                           bitsPerSample:[srcImageRep bitsPerSample]
                         samplesPerPixel:[srcImageRep samplesPerPixel]
                                hasAlpha:[srcImageRep hasAlpha]
                                isPlanar:[srcImageRep isPlanar]
                          colorSpaceName:[srcImageRep colorSpaceName]
                             bytesPerRow:h*destSamplesPerPixel
                            bitsPerPixel:0];

    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];

    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + srcSamplesPerPixel * (y * w + x);
            p2 = destData + destSamplesPerPixel * (x * h + (h-y-1));
            for (s = 0; s < srcSamplesPerPixel; s++)
                p2[s] = p1[s];
        }

    [destImage addRepresentation:destImageRep];
    [destImageRep release];

    [self scaleView:destImage];
    [view setImage: destImage];
    [view setNeedsDisplay:YES];
    [[view superview] setNeedsDisplay:YES];
    [window displayIfNeeded];
    [destImage release];
}

- (BOOL)validateMenuItem:(id)sender
{
    /* the menu item returned is not the same object, so we use isEqual */
    if ([sender isEqual:saveAsMenuItem])
    {
        if ([view image] == nil)
            return NO;
    }
    return YES;
}

- (IBAction)saveImageAs:(id)sender
{
    NSImage *srcImage;
    NSBitmapImageRep *srcImageRep;
    NSData *dataOfRep = nil;
    NSDictionary *repProperties;
    NSString *origFileName;
    NSString *filenameNoExtension;
    

    origFileName = [[fileListData pathAtIndex:[fileListView selectedRow]] lastPathComponent];
    filenameNoExtension = [origFileName stringByDeletingPathExtension];
    savePanel = [NSSavePanel savePanel];
    [savePanel setDelegate: self];
    /* if the accessory view comes from a window it needs a retain */
    [savePanel setAccessoryView: [saveOptionsView retain]];

    /* simulate clicks to be sure interface is consistent */
    [jpegCompressionSlider performClick:nil];
    [fileTypePopUp sendAction:@selector(setCompressionType:) to:self];

    if ([savePanel runModalForDirectory:@"" file:filenameNoExtension] ==  NSFileHandlingPanelOKButton)
    {
        NSString *fileName;
        int selItem;

        srcImage = [view image];
        srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];


        fileName = [savePanel filename];
                
        selItem = [fileTypePopUp indexOfSelectedItem];
        if (selItem == 0)
        {
            NSLog(@"Tiff");
            repProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NSTIFFCompressionLZW] forKey:NSImageCompressionMethod];
            dataOfRep = [srcImageRep representationUsingType: NSTIFFFileType properties:repProperties];

        } else if (selItem == 1)
        {
            NSLog(@"Jpeg");
            repProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:[jpegCompressionSlider floatValue]/100] forKey:NSImageCompressionFactor];
            dataOfRep = [srcImageRep representationUsingType: NSJPEGFileType properties:repProperties];
        }
        [dataOfRep writeToFile:fileName atomically:NO];            
    }
}


/* ===== delegates =====*/
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
  [self addFile:filename];
  [fileListView selectRow: [fileListView numberOfRows]-1 byExtendingSelection: NO];
  return YES;
}

/* save panel delegates */
/** change the file type */
- (IBAction)setCompressionType:(id)sender
{
    int selItem;
    
    selItem = [fileTypePopUp indexOfSelectedItem];
    if (selItem == 0)
    {
        NSLog(@"Tiff");
        [jpegCompressionSlider setEnabled:NO];
        [jpegCompressionField setEnabled:NO];
#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_2)
        [savePanel setRequiredFileType:@"tiff"];
#else
        [savePanel setAllowedFileTypes:[NSArray arrayWithObjects: @"tif", @"tiff", nil]];
#endif 
    } else if (selItem == 1)
    {
        NSLog(@"Jpeg");
        [jpegCompressionSlider setEnabled:YES];
        [jpegCompressionField setEnabled:YES];
#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_2)
        [savePanel setRequiredFileType:@"jpg"];
#else
        [savePanel setAllowedFileTypes:[NSArray arrayWithObjects: @"jpg", @"jpeg", nil]];
#endif 
    }
}

/** keep the slider and the text view of the compression level in sync */
- (IBAction)setCompressionLevel:(id)sender
{
    if (sender == jpegCompressionField)
        [jpegCompressionSlider takeFloatValueFrom:sender];
    else
        [jpegCompressionField takeFloatValueFrom:sender];
}

/* exporter */
- (IBAction)exportImages:(id)sender
{
  [exporterPanel makeKeyAndOrderFront:self];
  [exportProgress setDoubleValue: 0.0];
}

- (IBAction)setExportPath:(id)sender
{
  NSOpenPanel *openPanel;
  NSString    *choosenFilePath;
  
  openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  if ([openPanel runModalForTypes:NULL] != NSOKButton)
    {
      return;
    }
  
  choosenFilePath = [openPanel filename];
  [fieldOutputPath setStringValue:choosenFilePath];
}

- (IBAction)execExportImages:(id)sender
{
  int givenHeight;
  int givenWidth;
  NSDictionary *repProperties;
  NSString *origFileName;
  NSString *filenameNoExtension;
  NSImage *srcImage;
  NSBitmapImageRep *srcImageRep;
  NSData *dataOfRep;
  NSString *destFileName;
  NSString *destFileExtension;
  NSString *destFolder;
  int i;
  
  givenHeight = [fieldHeight intValue];
  givenWidth = [fieldWidth intValue];

  destFolder = [fieldOutputPath stringValue];
  
  if ([popupFileType indexOfSelectedItem] == 0)
    destFileExtension = @"tiff";
  else
    destFileExtension = @"jpeg";

  [exportProgress setDoubleValue: 0.0];
  [exporterPanel displayIfNeeded];
  for (i = 0; i < [fileListView numberOfRows]; i++)
    {
      NSString *fullOrigPath;
      int newW, newH;
      double aspectRatio;
      NSBitmapImageRep *scaledImageRep;
      NSAutoreleasePool *pool;

      /* create a local pool to avoid the autorelease to grow too much */
      pool = [[NSAutoreleasePool alloc] init];
      fullOrigPath = [fileListData pathAtIndex:i];
      origFileName = [fullOrigPath lastPathComponent];
      filenameNoExtension = [origFileName stringByDeletingPathExtension];
      

      srcImage = [[NSImage alloc] initByReferencingFile:fullOrigPath];
      srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];

      newW = [srcImageRep size].width;
      newH = [srcImageRep size].height;
      aspectRatio = (double)newW / newH;
      NSLog(@"aspect ratio: %f", aspectRatio);
      switch([popupConstraints indexOfSelectedItem])
	{
	case 0: /* none */
	  break;
	case 1: /* width */
	  newW = givenWidth;
	  newH = givenWidth / aspectRatio;
	  break;
	case 2: /* height */
	  newH = givenHeight;
	  newW = givenHeight * aspectRatio;
	  break;
	case 3: /* both */
	  newW = givenWidth;
	  newH = givenWidth / aspectRatio;
          if (newH > givenHeight)
            {
              newH = givenHeight;
              newW = givenHeight * aspectRatio;
            }
	  break;
	case 4: /* largest side */
	  if ([srcImageRep size].height > [srcImageRep size].width)
	    {
	      newH = givenWidth;
	      newW = givenWidth * aspectRatio;
	    }
	  else
	    {
	      newW = givenWidth;
	      newH = givenWidth / aspectRatio;
	    }
	  break;
	default:
	  NSLog(@"Unexpected constraint selection value.");
	}
      NSLog(@"%d %d", newW, newH);
      if (newW == [srcImageRep size].width)
	{
	  NSLog(@"nothing");
	  scaledImageRep = srcImageRep;
	}
      else
	{
	  NSImage *scaledImage;
	  PRScale *scaleFilter;
	  
	  scaleFilter = [[PRScale alloc] init];
	  scaledImage = [scaleFilter scaleImage:srcImage :newW :newH :LINEAR_HV :nil];
	  [scaleFilter release];
	  scaledImageRep = [NSBitmapImageRep imageRepWithData:[scaledImage TIFFRepresentation]];
	}

      if ([popupFileType indexOfSelectedItem] == 0)
        {
          repProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NSTIFFCompressionLZW] forKey:NSImageCompressionMethod];
          dataOfRep = [scaledImageRep representationUsingType: NSTIFFFileType properties:repProperties];
        }
      else
        {
          float quality;
	  
	  switch ([popupFileQuality indexOfSelectedItem])
	    {
	    case 0:
	      quality = 1.0;
	      break;
	    case 1:
	      quality = 0.75;
	      break;
	    case 2:
	      quality = 0.66;
	      break;
	    case 3:
	      quality = 0.4;
	      break;
	    default:
	      quality = 0.5;
            }
          repProperties = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:quality] forKey:NSImageCompressionFactor];
          dataOfRep = [scaledImageRep representationUsingType: NSJPEGFileType properties:repProperties];
        }
      [srcImage release];

      destFileName = [destFolder stringByAppendingPathComponent:[filenameNoExtension stringByAppendingPathExtension: destFileExtension]];
      NSLog(@"%@", destFileName);
      if (dataOfRep != nil)
        {
          [dataOfRep writeToFile:destFileName atomically:NO];
        }
      [exportProgress setDoubleValue: ((double)(i+1)*100)/(double)[fileListView numberOfRows]];
      [exporterPanel displayIfNeeded];
      [pool release];
    }
}

@end

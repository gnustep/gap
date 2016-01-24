/* 
   Project: LaternaMagica
   AppController.m

   Copyright (C) 2006-2016 Riccardo Mottola

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

#if defined(__MINGW32__)
#define srandom srand
#define random rand
#endif

#include <stdlib.h>
#include <time.h>

#import "AppController.h"
#import "LMImage.h"
#import "PRScale.h"

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4)
#define NSInteger int
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_3
#define NSImageGamma @"NSImageGamma"
#define NSImageEXIFData @"NSImageEXIFData"
#endif
#endif


#define LM_KEY_DESTROYRECYCLE @"DestroyOrRecycle"
#define LM_KEY_ASKDELETING @"AskBeforeDeleting"

@implementation AppController

- (id) init
{
  if ((self = [super init]))
    {
      /* initialize random number generator */
      srandom(time(NULL));
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
    [smallWindow setDelegate:smallView];

    fullView = [[LMFlipView alloc] initWithFrame:[fullWindow frame]];
    [fullView setImageScaling: NSScaleNone];
    [fullView setImageAlignment:NSImageAlignCenter];
    [fullView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    [fullView setController:self];
    

    /* avoid replacing the contentview with a NSControl subclass, thus add a subview instead */
    [[fullWindow contentView] addSubview: fullView];
    [fullWindow setInitialFirstResponder:fullView];
    [fullWindow setDelegate:fullView];

    /* register the file view as drag destionation */
    [fileListView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];

    /* add an observer for the file table view */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_selectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:fileListView];

    /* add an observer for the window resize */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResize:) name:NSWindowDidResizeNotification object:window];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)addFile:(NSString *)filename
{
  if([fileListData addPathAndRecurse:filename])
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
      return;
    
    files = [openPanel filenames];
    e = [files objectEnumerator];
    fmgr = [NSFileManager defaultManager];
    while ((filename = (NSString*)[e nextObject]))
      {
        attrs = [fmgr fileAttributesAtPath:filename traverseLink:YES];
        if (attrs)
          {
            [self addFile:filename];
          }
        else
          {
            NSLog(@"open panel did not return a valid path");
          }
      }
    [fileListView selectRow: [fileListView numberOfRows]-1 byExtendingSelection: NO];
}

// scale image view according to options
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
}

- (void)changeImage:(LMImage *) image
{
  NSImage *nsImage;
  NSImage *img;

  nsImage = [[NSImage alloc] initByReferencingFile:[image path]];
  
  [nsImage autorelease];
  img = nsImage;

  if ([image rotation] > 0)
    {
      NSImage *destImage;

      destImage = [self rotate: nsImage byAngle:[image rotation]];
      img = destImage;
    }
  [self scaleView: img];
  [view setImage: img];

  [view setNeedsDisplay:YES];
  [[view superview] setNeedsDisplay:YES];
  
  /* we don't need to update the full-screen window title */
  [smallWindow setTitleWithRepresentedFilename:[image name]];
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
    [view setNeedsDisplay:YES];
}

/** method called as a notification from the selection change */
- (void)_selectionDidChange :(NSNotification *)notif
{
    NSTableView *table;
    int         selectedRow;
    
    table = [notif object];
    selectedRow = [table selectedRow];
    if (selectedRow >= 0)
        [self changeImage:[fileListData imageAtIndex:selectedRow]];
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

    /* trick for GS so that we don't have order problems with GWorkspace */
    [window makeKeyAndOrderFront: self];

    image = [view image];
    [image retain];
    
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
      [smallView setImage: nil];
        [fullWindow setLevel: NSScreenSaverWindowLevel];
        window = fullWindow;
        view = fullView;
    } else
    {
      [fullView setImage: nil];
        [fullWindow orderOut:self];
        window = smallWindow;
        view = smallView;
    }
    [view setImage: image];
    [image release];
    [self setScaleToFit: self];
    [view setNeedsDisplay:YES];
    [[view superview] setNeedsDisplay:YES];
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

- (IBAction)removeAllImages:(id)sender
{
  NSInteger rows;
  NSInteger i;
  
  rows = [fileListView numberOfRows];
  for (i = (rows  - 1); i >= 0 ; i--)
    [fileListData removeObjectAtIndex: i];
  [fileListView reloadData];
  [view setImage: nil];
  [window setTitle:@"None"];
}

- (IBAction)scrambleList:(id)sender
{
  NSInteger selRow;
  [fileListData scrambleObjects];
  [fileListView reloadData];

  /* we reload the image directly without calling selectRow,
     the selected row did not actually change and no notification triggers */
  selRow = [fileListView selectedRow];
  if (selRow > 0)
    [self changeImage: [fileListData imageAtIndex: (NSUInteger)selRow]];
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
                    [self changeImage: [fileListData imageAtIndex: sr]];
            
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
  BOOL shallErase;
  NSUserDefaults *defaults;
  
  defaults = [NSUserDefaults standardUserDefaults];
  sr = [fileListView selectedRow];
  if (sr >= 0)
    {
      if ([defaults boolForKey:LM_KEY_ASKDELETING])
	{
	  int result;

	  result = NSRunAlertPanel(nil, @"Really delete the image from disk?", @"Delete", @"Abort", nil);
	  shallErase = NO;
	  if (result == NSAlertDefaultReturn)
	    shallErase = YES;
	}
      else
	shallErase = YES;
      if (shallErase)
	{
	  NSWorkspace *ws;
	  NSString *fileOperation;
	  NSInteger opTag;
	  NSString *folder;
	  NSString *file;

	  if ([defaults boolForKey:LM_KEY_DESTROYRECYCLE])
	    fileOperation = NSWorkspaceDestroyOperation;
	  else
	    fileOperation = NSWorkspaceRecycleOperation;

	  folder = [[fileListData pathAtIndex:sr]stringByDeletingLastPathComponent];
	  file = [[fileListData pathAtIndex:sr] lastPathComponent];
	  ws = [NSWorkspace sharedWorkspace];
	  opTag = 1;
	  [ws performFileOperation:fileOperation
			    source:folder
		       destination:nil
			     files:[NSArray arrayWithObject: file]
			       tag:&opTag];
            
	  [self removeImage:self];
	}
    }
}


- (IBAction)rotateImage90:(id)sender
{
  NSImage *destImage;

  LMImage *imageInfo;

  imageInfo = [fileListData imageAtIndex:[fileListView selectedRow]];
  [imageInfo setRotation: 90];

  destImage = [self rotate: [view image] byAngle:90];


  [self scaleView:destImage];
  [view setImage: destImage];
  [view setNeedsDisplay:YES];
  [[view superview] setNeedsDisplay:YES];
}

- (IBAction)rotateImage180:(id)sender
{
  NSImage *destImage;

  LMImage *imageInfo;

  imageInfo = [fileListData imageAtIndex:[fileListView selectedRow]];
  [imageInfo setRotation: 180];

  destImage = [self rotate: [view image] byAngle:180];

  [self scaleView:destImage];
  [view setImage: destImage];
  [view setNeedsDisplay:YES];
  [[view superview] setNeedsDisplay:YES];
}


- (IBAction)rotateImage270:(id)sender
{
  NSImage *destImage;
  
  LMImage *imageInfo;

  imageInfo = [fileListData imageAtIndex:[fileListView selectedRow]];
  [imageInfo setRotation: 270];

  destImage = [self rotate: [view image] byAngle: 270];

  [self scaleView:destImage];
  [view setImage: destImage];
  [[view superview] setNeedsDisplay:YES];
}

- (NSImage *)rotate: (NSImage *)image byAngle:(unsigned)angle
{
  NSBitmapImageRep *srcImageRep;
  NSImage *destImage;
  NSBitmapImageRep *destImageRep;
  NSMutableDictionary *imgProps;
  NSInteger x, y;
  NSInteger w, h;
  NSInteger newW, newH;
  NSInteger srcSamplesPerPixel;
  NSInteger destSamplesPerPixel;
  unsigned char *srcData;
  unsigned char *destData;
  unsigned char *p1, *p2;
  NSSize oldRepSize, newRepSize;
  NSSize oldImgSize, newImgSize;
  register NSInteger srcBytesPerPixel;
  register NSInteger destBytesPerPixel;
  register NSInteger srcBytesPerRow;
  register NSInteger destBytesPerRow;
  
  /* get source image representation and associated information */
  oldImgSize = [image size];
  srcImageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
  oldRepSize = [srcImageRep size];
  w = [srcImageRep pixelsWide];
  h = [srcImageRep pixelsHigh];
  if (angle == 90 || angle == 270)
    {
      newH = w;
      newW = h;
      newImgSize = NSMakeSize(oldImgSize.height, oldImgSize.width);
      newRepSize = NSMakeSize(oldRepSize.height, oldRepSize.width);
    }
  else
    {
      newH = h;
      newW = w;
      newImgSize = oldImgSize;
      newRepSize = oldRepSize;
    }

  srcSamplesPerPixel = [srcImageRep samplesPerPixel];
  destSamplesPerPixel = srcSamplesPerPixel;
  srcBytesPerRow = [srcImageRep bytesPerRow];
  srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;  srcSamplesPerPixel = [srcImageRep samplesPerPixel];

  imgProps = [[NSMutableDictionary alloc] init];
  [imgProps setValue:[srcImageRep valueForProperty:NSImageCompressionMethod] forKey:NSImageCompressionMethod];
  [imgProps setValue:[srcImageRep valueForProperty:NSImageCompressionFactor] forKey:NSImageCompressionFactor];
  [imgProps setValue:[srcImageRep valueForProperty:NSImageEXIFData] forKey:NSImageEXIFData];
  [imgProps setValue:[srcImageRep valueForProperty:NSImageGamma] forKey:NSImageGamma];
  [imgProps setValue:[srcImageRep valueForProperty:NSImageColorSyncProfileData] forKey:NSImageColorSyncProfileData];
  NSLog(@"Properties: %@", imgProps);
  
  destSamplesPerPixel = srcSamplesPerPixel;
  destImage = [[NSImage alloc] initWithSize:newImgSize];
  destImageRep = [[NSBitmapImageRep alloc]
		   initWithBitmapDataPlanes:NULL
				 pixelsWide:newW
				 pixelsHigh:newH
			      bitsPerSample:[srcImageRep bitsPerSample]
			    samplesPerPixel:[srcImageRep samplesPerPixel]
				   hasAlpha:[srcImageRep hasAlpha]
				   isPlanar:[srcImageRep isPlanar]
			     colorSpaceName:[srcImageRep colorSpaceName]
				bytesPerRow:0
			       bitsPerPixel:0];
  [destImageRep setSize:newRepSize];
  [destImageRep setProperty:NSImageEXIFData withValue:[imgProps valueForKey:NSImageEXIFData]];
  [destImageRep setProperty:NSImageColorSyncProfileData withValue:[imgProps valueForKey:NSImageColorSyncProfileData]];
  [destImageRep setProperty:NSImageGamma withValue:[imgProps valueForKey:NSImageGamma]];
  [imgProps release];

  srcData = [srcImageRep bitmapData];
  destData = [destImageRep bitmapData];
  destBytesPerRow = [destImageRep bytesPerRow];
  destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
    
  if (angle == 90)
    {
      for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
	  {
            unsigned s;
            
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * (w-x-1) + destBytesPerPixel * y;
            for (s = 0; s < srcSamplesPerPixel; s++)
	      p2[s] = p1[s];
	  }
    }
  else if (angle == 180)
    {
      for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
	  {
            unsigned s;
            
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * (h-y-1) + destBytesPerPixel * (w-x-1);
            for (s = 0; s < srcSamplesPerPixel; s++)
	      p2[s] = p1[s];
	  }
    }
  else if (angle == 270)
    {
      for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
	  {
            unsigned s;
            
            p1 = srcData + srcBytesPerRow * y  + srcBytesPerPixel * x;
            p2 = destData + destBytesPerRow * x + destBytesPerPixel * (h-y-1);
            for (s = 0; s < srcSamplesPerPixel; s++)
	      p2[s] = p1[s];
	  }
    }
  [destImage addRepresentation:destImageRep];
  [destImageRep release];

  [destImage autorelease];
  return destImage;
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

- (void)updateImageCount
{
  [fieldImageCount setIntValue:(int)[fileListData imageCount]];
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
      int newW, newH;
      double aspectRatio;
      NSBitmapImageRep *scaledImageRep;
      NSAutoreleasePool *pool;
      LMImage *lmImage;

      lmImage = [fileListData imageAtIndex:i];

      /* create a local pool to avoid the autorelease to grow too much */
      pool = [[NSAutoreleasePool alloc] init];
      origFileName = [lmImage name];
      filenameNoExtension = [origFileName stringByDeletingPathExtension];   

      srcImage = [[NSImage alloc] initByReferencingFile:[lmImage path]];
      if ([lmImage rotation] > 0)
        {
          NSImage *rotImage;

          rotImage = [self rotate:srcImage byAngle:[lmImage rotation]];
          [rotImage retain];
          [srcImage release];
          srcImage = rotImage;
        }
      srcImageRep = [[srcImage representations] objectAtIndex:0];;

#if !defined (GNUSTEP) &&  (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_3)
      /* since 10.4 we have different Alpha format position, let's convert it */
      NSMutableDictionary *imgProps;

      if ([srcImageRep bitmapFormat] != 0)
        {
          NSInteger x, y;
          NSInteger w, h;
          BOOL alphaFirst;
          NSImage *destImage;
          NSBitmapImageRep *destImageRep;
          NSInteger           srcBytesPerRow;
          NSInteger           destBytesPerRow;
          NSInteger           srcBytesPerPixel;
          NSInteger           destBytesPerPixel;
          
          NSLog(@"We have a non-standard format, let's try to convert it");
          alphaFirst = [srcImageRep bitmapFormat] & NSAlphaFirstBitmapFormat;

          if ([srcImageRep bitsPerSample] == 8)
            {
              unsigned char    *srcData;
              unsigned char    *destData;
              unsigned char    *p1;
              unsigned char    *p2;

              /* swap Alpha is hopefully only for chunky images */
              if (alphaFirst)
                {
                  imgProps = [[NSMutableDictionary alloc] init];
                  [imgProps setValue:[srcImageRep valueForProperty:NSImageCompressionMethod] forKey:NSImageCompressionMethod];
                  [imgProps setValue:[srcImageRep valueForProperty:NSImageCompressionFactor] forKey:NSImageCompressionFactor];
                  [imgProps setValue:[srcImageRep valueForProperty:NSImageEXIFData] forKey:NSImageEXIFData];
                  
                  w = [srcImageRep pixelsWide];
                  h = [srcImageRep pixelsHigh];

                  srcBytesPerRow = [srcImageRep bytesPerRow];
                  srcBytesPerPixel = [srcImageRep bitsPerPixel] / 8;
                  destImage = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
                  destImageRep = [[NSBitmapImageRep alloc]
                                  initWithBitmapDataPlanes:NULL
                                                pixelsWide:w
                                                pixelsHigh:h
                                             bitsPerSample:8
                                           samplesPerPixel:[srcImageRep samplesPerPixel]
                                                  hasAlpha:[srcImageRep hasAlpha]
                                                  isPlanar:NO
                                            colorSpaceName:[srcImageRep colorSpaceName]
                                               bytesPerRow:0
                                              bitsPerPixel:0];
                  
                  destBytesPerRow = [destImageRep bytesPerRow];
                  destBytesPerPixel = [destImageRep bitsPerPixel] / 8;
                  srcData = [srcImageRep bitmapData];
                  destData = [destImageRep bitmapData];
                  if ([srcImageRep samplesPerPixel] == 2)
                    {
                      for (y = 0; y < h; y++)
                        for (x = 0; x < w; x++)
                          {
                            p1 = srcData + srcBytesPerRow * y + srcBytesPerPixel * x;
                            p2 = destData + destBytesPerRow * y + destBytesPerPixel * x;
                            p2[0] = p1[1];
                            p2[1] = p1[0];
                          }
                    }
                  else
                    {
                      for (y = 0; y < h; y++)
                        for (x = 0; x < w; x++)
                          {
                            p1 = srcData + srcBytesPerRow * y + srcBytesPerPixel * x;
                            p2 = destData + destBytesPerRow * y + destBytesPerPixel * x;
                            p2[0] = p1[1];
                            p2[1] = p1[2];
                            p2[2] = p1[3];
                            p2[3] = p1[0];
                          }
                    }
                  [destImageRep setProperty:NSImageEXIFData withValue:[imgProps objectForKey:NSImageEXIFData]];
                  [destImage addRepresentation:destImageRep];
                  [destImageRep release];
                  [srcImage release];
                  srcImage = destImage;
                  [imgProps release];
                }
            }
          else /* for 16 bit */
            {
            }
        }
#endif

      newW = [srcImageRep pixelsWide];
      newH = [srcImageRep pixelsHigh];
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
	  if ([srcImageRep pixelsHigh] > [srcImageRep pixelsWide])
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
      if (newW == [srcImageRep pixelsWide])
	{
	  NSLog(@"nothing");
	  scaledImageRep = srcImageRep;
	}
      else
	{
	  NSImage *scaledImage;
	  PRScale *scaleFilter;
	  
	  scaleFilter = [[PRScale alloc] init];
	  scaledImage = [scaleFilter scaleImage:srcImage :newW :newH :BILINEAR :nil];
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

/* preferences */
- (IBAction)showPreferences:(id)sender
{
  NSUserDefaults *defaults;

  defaults = [NSUserDefaults standardUserDefaults];

  [destroyOrRecycleButton setState:[defaults boolForKey:LM_KEY_DESTROYRECYCLE] ? NSOnState : NSOffState];
  [askBeforeDeletingButton setState:[defaults boolForKey:LM_KEY_ASKDELETING] ? NSOnState : NSOffState];
  [prefPanel makeKeyAndOrderFront: sender];
}

- (IBAction)savePreferences:(id)sender
{
  NSUserDefaults *defaults;

  defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:[destroyOrRecycleButton state] forKey:LM_KEY_DESTROYRECYCLE];
  [defaults setBool:[askBeforeDeletingButton state] forKey:LM_KEY_ASKDELETING];
  [prefPanel performClose:self];
}

- (IBAction)cancelPreferences:(id)sender
{
  [prefPanel performClose:self];
}

/* printing */
- (void)print:(id)sender
{
  [view print:sender];
}

@end

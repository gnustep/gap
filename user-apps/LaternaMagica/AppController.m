//
//  AppController.m
//  LaternaMagica
//
//  Created by Riccardo Mottola on Mon Jan 16 2006.
//  Copyright (c) 2006-2007 Carduus. All rights reserved.
//

#import "AppController.h"


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
    fullWindow = [[NSWindow alloc] initWithContentRect: frame
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
    

    // avoid replacing the contentview with a NSControl subclass, thus add a subview instead
    [[fullWindow contentView] addSubview: fullView];
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
    if ([openPanel runModalForTypes:NULL] != NSOKButton)
    {
        return;
    }

    files = [openPanel filenames];
    e = [files objectEnumerator];
    fmgr = [NSFileManager defaultManager];
    while ((filename = (NSString*)[e nextObject])) {
        attrs = [fmgr fileAttributesAtPath:filename traverseLink:YES];
        if (attrs)
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

                    tempName = [filename stringByAppendingPathComponent:filename2];
                    attrs2 = [[NSFileManager defaultManager] fileAttributesAtPath:tempName traverseLink:YES];
                    if (attrs2)
                    {
                        if ([attrs2 objectForKey:NSFileType] != NSFileTypeDirectory)
                        {
                            [self addFile:tempName];
                        }
                    }
                }
            } else
            {
                [self addFile:filename];
            }
        else
        {
            NSLog(@"open panel did not return a valid path");
        }
    }
}

// scale image according to options
- (void)scaleView:(NSImage *) image
{
    NSPoint rectOrigin;
    NSSize rectSize;

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

// method called as a notification from the selection change
- (void)_selectionDidChange :(NSNotification *)notif
{
    NSTableView *table;
    int         selectedRow;
    
    table = [notif object];
    selectedRow = [table selectedRow];
    if (selectedRow >= 0)
        [self changeImage:[fileListData pathAtIndex:selectedRow]];
}

// method called as a notification from the window resize
// or if scale preferences changed
- (void)_windowDidResize :(NSNotification *)notif
{
    [self scaleView: [view image]];
}


- (IBAction)setFullScreen :(id)sender
{
    NSImage *image;

    image = [view image];

    // check the sender and set the other item accordingly
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
    [view  setImage: image];
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

    if (rows > 0) {
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
            // TODO should implement a handelr and error messages
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
    int bytesPerPixel;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;

    srcImage = [view image];
    /* get source image representation and associated information */
    srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];

    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    bytesPerPixel = [srcImageRep bitsPerPixel] /8;

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
                             bytesPerRow:0
                            bitsPerPixel:0];

    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];
    
    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + bytesPerPixel * (y * w + x);
            p2 = destData + bytesPerPixel * ((w-x-1) * h + y);
            for (s = 0; s < bytesPerPixel; s++)
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
    int bytesPerPixel;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;

    srcImage = [view image];
    /* get source image representation and associated information */
    srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];

    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    bytesPerPixel = [srcImageRep bitsPerPixel] /8;

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
                             bytesPerRow:0
                            bitsPerPixel:0];

    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];

    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + bytesPerPixel * (y * w + x);
            p2 = destData + bytesPerPixel * ((h-y-1) * w + (w-x-1));
            for (s = 0; s < bytesPerPixel; s++)
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
    int bytesPerPixel;
    unsigned char *srcData;
    unsigned char *destData;
    unsigned char *p1, *p2;

    srcImage = [view image];
    /* get source image representation and associated information */
    srcImageRep = [NSBitmapImageRep imageRepWithData:[srcImage TIFFRepresentation]];

    w = [srcImageRep pixelsWide];
    h = [srcImageRep pixelsHigh];
    bytesPerPixel = [srcImageRep bitsPerPixel] /8;

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
                             bytesPerRow:0
                            bitsPerPixel:0];

    srcData = [srcImageRep bitmapData];
    destData = [destImageRep bitmapData];

    for (y = 0; y < h; y++)
        for (x = 0; x < w; x++)
        {
            p1 = srcData + bytesPerPixel * (y * w + x);
            p2 = destData + bytesPerPixel * (x * h + (h-y-1));
            for (s = 0; s < bytesPerPixel; s++)
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

@end

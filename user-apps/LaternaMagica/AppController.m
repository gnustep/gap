//
//  AppController.m
//  LaternaMagica
//
//  Created by Riccardo Mottola on Mon Jan 16 2006.
//  Copyright (c) 2006 Carduus. All rights reserved.
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
//    [self setScaleToFit:self];
    
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
//    [fullWindow setOneShot:YES];

    [smallView setFrame:[scrollView documentVisibleRect]];
    [smallView setImageAlignment:NSImageAlignTopLeft];

    fullView = [[LMFlipView alloc] initWithFrame:[fullWindow frame]];    
    [fullView setImageAlignment:NSImageAlignCenter];
    [fullView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    [fullView setImageScaling: NSScaleNone];

    // avoid replacing the contentview with a NSControl subclass, thus add a subview instead
    [[fullWindow contentView] addSubview: fullView];
//    [[fullWindow contentView] setAutoresizesSubviews:true];
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
    if ([fullScreenMenuItem state] == NSOnState)
    {
        if (scaleToFit)
        {
            NSSize imageSize;
            NSSize rectSize;
            NSAffineTransform *at;
            float scaleH, scaleW;
            float scale;

            rectSize =  [window frame].size;
            imageSize = [image size];


            scaleW = rectSize.width / imageSize.width;
            scaleH =  rectSize.height / imageSize.height;

            if (scaleW < scaleH)
                scale = scaleW;
            else
                scale = scaleH;
            NSLog(@"scale: %f", scale);
            at = [NSAffineTransform transform];
            [at scaleBy:scale];
            [view setFrameSize:[at transformSize:imageSize]];
        } else
        {
            [view setFrameSize:[image size]];
        }
    } 
    else
    {
        if (scaleToFit)
        {
            NSSize imageSize;
            NSSize rectSize;
            NSAffineTransform *at;
            float scaleH, scaleW;
            float scale;

            rectSize =  [scrollView frame].size;
            imageSize = [image size];


            scaleW = rectSize.width / imageSize.width;
            scaleH =  rectSize.height / imageSize.height;

            if (scaleW < scaleH)
                scale = scaleW;
            else
                scale = scaleH;
            NSLog(@"scale: %f", scale);
            at = [NSAffineTransform transform];
            [at scaleBy:scale];
            [view setFrameSize:[at transformSize:imageSize]];
        } 
        else
        {
            [view setFrameSize:[image size]];
        }
    }
    
    [view setNeedsDisplay:YES];
}

- (void)changeImage:(NSString *) file
{
    NSImage *image;

    image = [[NSImage alloc] initByReferencingFile:file];
    [self scaleView:image];
    [view setImage: image];
    [view setNeedsDisplay:YES];
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
    
    table = [notif object];
    [self changeImage:[fileListData pathAtIndex:[table selectedRow]]];
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
    else {
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
    if (rows > 0)
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
    if (sr > 0)
        if (NSRunAlertPanel(nil, @"Really delete the image from disk?", @"Delete", @"Abort", nil) == NSAlertDefaultReturn)
        {
            NSFileManager *fm;
            
            fm = [NSFileManager defaultManager];
            // TODO should implement a handelr and error messages
            [fm removeFileAtPath:[fileListData pathAtIndex:sr] handler:nil];
            
            [self removeImage:self];
        }
}
@end

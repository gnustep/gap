/* 
   Project: FTP

   Copyright (C) 2005 Riccardo Mottola

   Author: Riccardo Mottola

   Created: 2005-03-30
   
   Application Controller

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
#import "fileElement.h"

@implementation fileTransmitParms
@end

@implementation AppController

+ (void)initialize
{
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    if ((self = [super init]))
    {
    }
    connMode = defaultMode;

    threadRunning = NO;
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)awakeFromNib
{
//  [[NSApp mainMenu] setTitle:@"FTP"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotif
{
    NSArray        *dirList;
    NSUserDefaults *defaults;
    NSString       *readValue;

    /* read the user preferences */
    defaults = [NSUserDefaults standardUserDefaults];
    readValue = [defaults stringForKey:connectionModeKey];

    // if no value was set for the key we set default as mode
    if ([readValue isEqualToString:@"default"] || readValue == nil)
        connMode = defaultMode;
    else if ([readValue isEqualToString:@"port"])
        connMode = portMode;
    else if ([readValue isEqualToString:@"passive"])
        connMode = passiveMode;
    else
        NSLog(@"Unrecognized value in user preferences for %@: %@", connectionModeKey, readValue);
    NSLog(@"%@ maps to %d", connectionModeKey, connMode);
    
    /* set double actions for tables */
    [localView setTarget:self];
    [localView setDoubleAction:@selector(listDoubleClick:)];
    [remoteView setTarget:self];
    [remoteView setDoubleAction:@selector(listDoubleClick:)];
    
    /* startup code */
    local = [[localclient alloc] init];
    [local setWorkingDir:[local homeDir]];
    dirList = [local dirContents];
    [progBar setDoubleValue:0.0];  // reset the progress bar
    
    /* we create a data source and set the tableviews */
    localTableData = [[fileTable alloc] init];
    [localTableData initData:dirList];
    [localView setDataSource:localTableData];
    
    remoteTableData = [[fileTable alloc] init];

    /* we update the path menu */
    [self updatePath :localPath :[local workDirSplit]];
// #### and a release of this array ?!?
}

- (BOOL)applicationShouldTerminate:(id)sender
{
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotif
{
}

- (BOOL)application:(NSApplication *)application openFile:(NSString *)fileName
{
    return NO;
}

/* update the pop-up menu with a new path */
- (void)updatePath :(NSPopUpButton *)path :(NSArray *)pathArray
{
    [path removeAllItems];
    [path addItemsWithTitles:pathArray];
}

/* performs the action of the path pull-down menu
   it navigates upwards the tree
   and works for both the local and remote path */
- (IBAction)changePathFromMenu:(id)sender
{
    client      *theClient;
    NSTableView *theView;
    fileTable   *theTable;
    NSString    *thePath;
    NSArray     *items;
    int         selectedIndex;
    int         i;
    NSArray    *dirList;

    NSLog(@"%@", [sender class]);
    if (sender == localPath)
    {
        theClient = local;
        theView = localView;
        theTable = localTableData;
    } else
    {
        theClient = ftp;
        theView = remoteView;
        theTable = remoteTableData;
    }
    thePath = [NSString string];
    selectedIndex = [sender indexOfItem:[sender selectedItem]];
    items = [sender itemTitles];
    for (i = [items count] - 1; i >= selectedIndex; i--)
        thePath = [thePath stringByAppendingPathComponent: [items objectAtIndex:i]];
    NSLog(@"selected path: %@", thePath);
    [theClient changeWorkingDir:thePath];
    if ((dirList = [theClient dirContents]) == nil)
        return;
    [theTable initData:dirList];
    [theView reloadData];
    
    [self updatePath :sender :[theClient workDirSplit]];
}

/* perform the action of a double click in a table element
   a directory should be opened, a file down or uploaded
   The same method works for local and remote, detecting them */
- (IBAction)listDoubleClick:(id)sender
{
    client        *theClient;
    NSTableView   *theView;
    fileTable     *theTable;
    int           elementIndex;
    fileElement   *fileEl;
    NSString      *thePath;
    NSArray       *dirList;
    NSPopUpButton *thePathMenu;

    if (threadRunning)
    {
        NSLog(@"thread was still running");
        return;
    }
    
    theView = sender;
    NSLog(@"%@", [theView class]);
    if (theView == localView)
    {
        theClient = local;
        theTable = localTableData;
        thePathMenu = localPath;
    } else
    {
        theClient = ftp;
        theTable = remoteTableData;
        thePathMenu = remotePath;
    }

    elementIndex = [sender selectedRow];
    if (elementIndex < 0)
    {
        NSLog(@"error: double click with nothing selected");
        return;
    }
    fileEl = [theTable elementAtIndex:elementIndex];
    NSLog(@"element: %@ %d", [fileEl filename], [fileEl isDir]);
    thePath = [NSString stringWithString:[theClient workingDir]];
    thePath = [thePath stringByAppendingPathComponent: [fileEl filename]];
    if ([fileEl isDir])
    {
        NSLog(@"should cd to %@", thePath);
        [theClient changeWorkingDir:thePath];
        if ((dirList = [theClient dirContents]) == nil)
            return;
        [theTable initData:dirList];
        [theView reloadData];
        [self updatePath :thePathMenu :[theClient workDirSplit]];
    } else
    {
        if (theView == localView)
        {
            NSLog(@"should upload %@", thePath);
            [NSThread detachNewThreadSelector:@selector(performStoreFile:) toTarget:self withObject:nil];
        } else
        {
            NSLog(@"should download %@", thePath);
            [NSThread detachNewThreadSelector:@selector(performRetrieveFile:) toTarget:self withObject:nil];
        }
    }
}

- (void)setInterfaceEnabled:(BOOL)flag
{
    [localView setEnabled:flag];
    [remoteView setEnabled:flag];
    [localPath setEnabled:flag];
    [remotePath setEnabled:flag];
    [buttUpload setEnabled:flag];
    [buttDownload setEnabled:flag];
}

- (void)performRetrieveFile:(id)parameters
{
    fileTransmitParms  *parms;
    NSAutoreleasePool  *pool;

    NSEnumerator  *elemEnum;
    fileElement   *fileEl;
    id            currEl;

    threadRunning = YES;
    [self setInterfaceEnabled:NO];
    parms = (fileTransmitParms *)parameters;
    pool = [[NSAutoreleasePool alloc] init];


    // We should actually do a copy of the selection
    elemEnum = [remoteView selectedRowEnumerator];

    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [remoteTableData elementAtIndex:[currEl intValue]];
        NSLog(@"should download: %@", [fileEl filename]);
        [ftp retrieveFile:fileEl to:local beingAt:0];
    }

    [pool release];
    threadRunning = NO;
    [self setInterfaceEnabled:YES];
}

- (void)performStoreFile:(id)parameters
{
    fileTransmitParms  *parms;
    NSAutoreleasePool  *pool;

    NSEnumerator  *elemEnum;
    fileElement   *fileEl;
    id            currEl;

    threadRunning = YES;
    [self setInterfaceEnabled:NO];
    parms = (fileTransmitParms *)parameters;
    pool = [[NSAutoreleasePool alloc] init];


    // We should actually do a copy of the selection
    elemEnum = [localView selectedRowEnumerator];

    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [localTableData elementAtIndex:[currEl intValue]];
        NSLog(@"should upload: %@", [fileEl filename]);
        [ftp storeFile:fileEl from:local beingAt:0];
    }

    [pool release];
    threadRunning = NO;
    [self setInterfaceEnabled:YES];
}

- (IBAction)downloadButton:(id)sender
{
    if (threadRunning)
    {
        NSLog(@"thread was still running");
        return;
    }

    [NSThread detachNewThreadSelector:@selector(performRetrieveFile:) toTarget:self withObject:nil];
}

- (IBAction)uploadButton:(id)sender
{
    if (threadRunning)
    {
        NSLog(@"thread was still running");
        return;
    }

    [NSThread detachNewThreadSelector:@selector(performStoreFile:) toTarget:self withObject:nil];
}

- (IBAction)localDelete:(id)sender
{
    NSEnumerator  *elemEnum;
    fileElement   *fileEl;
    id            currEl;

    elemEnum = [localView selectedRowEnumerator];
    
    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [localTableData elementAtIndex:[currEl intValue]];
        [local deleteFile:fileEl beingAt:0];
    }
}

- (IBAction)remoteDelete:(id)sender
{
    NSEnumerator  *elemEnum;
    fileElement   *fileEl;
    id            currEl;    

    elemEnum = [remoteView selectedRowEnumerator];

    while ((currEl = [elemEnum nextObject]) != nil)
    {
        fileEl = [remoteTableData elementAtIndex:[currEl intValue]];
        [ftp deleteFile:fileEl beingAt:0];
    }
}

- (void)setTransferBegin:(NSString *)name :(unsigned long long)size
{
    [infoMessage setStringValue:name];
    [progBar setDoubleValue:0];
    gettimeofday(&beginTimeVal, NULL);
    transferSize = size;
    [mainWin displayIfNeeded];
    [mainWin flushWindowIfNeeded];
}

- (void)setTransferProgress:(unsigned long)bytes
{
    struct timeval currTimeVal;
    float    speed;
    NSString *speedStr;
    NSString *sizeStr;
    double   percent;

    gettimeofday(&currTimeVal, NULL);

    if ((currTimeVal.tv_sec - lastTimeVal.tv_sec) > 1.0)
    {
        speed = (float)((double)bytes / (double)(currTimeVal.tv_sec - beginTimeVal.tv_sec));
        percent = ((double)bytes / (double)transferSize) * 100;
        lastTimeVal = currTimeVal;

        [progBar setDoubleValue:percent];
        speedStr = [NSString alloc];
        if (speed < 1024)
            speedStr = [speedStr initWithFormat:@"%3.2fB/s", speed];
        else if (speed < 1024*1024)
            speedStr = [speedStr initWithFormat:@"%3.2fKB/s", speed/1024];
        else
            speedStr = [speedStr initWithFormat:@"%3.2fMB/s", speed/(1024*1024)];
        [infoSpeed setStringValue:speedStr];
        [speedStr release];

        sizeStr = [NSString alloc];
        if (transferSize < 1024)
            sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f B", (float)bytes, (float)transferSize];
        else if (transferSize < 1024*1024)
            sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f KB", (double)bytes/1024, (double)transferSize/1024];
        else
            sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f MB", (double)bytes/(1024*1024), (double)transferSize/(1024*1024)];
        [infoSize setStringValue:sizeStr];
        [sizeStr release];
        [mainWin displayIfNeeded];
        [mainWin flushWindowIfNeeded];
    }
}

- (void)setTransferEnd:(unsigned long)bytes
{
    struct timeval currTimeVal;
    double         deltaT;
    float          speed;
    NSString       *speedStr;
    NSString       *sizeStr;
    double         percent;

    gettimeofday(&currTimeVal, NULL);
    deltaT = (currTimeVal.tv_sec - beginTimeVal.tv_sec)+((double)(currTimeVal.tv_usec - beginTimeVal.tv_usec)/1000000);
    speed = (float)((double)bytes / deltaT);
    NSLog(@"Elapsed time: %f", (float)deltaT);
    percent = ((double)bytes / (double)transferSize) * 100;
    speedStr = [NSString alloc];
    if (speed < 1024)
        speedStr = [speedStr initWithFormat:@"%3.2fB/s", speed];
    else if (speed < 1024*1024)
        speedStr = [speedStr initWithFormat:@"%3.2fKB/s", speed/1024];
    else
        speedStr = [speedStr initWithFormat:@"%3.2fMB/s", speed/(1024*1024)];
    [infoSpeed setStringValue:speedStr];
    [speedStr release];

    sizeStr = [NSString alloc];
    if (transferSize < 1024)
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f B", (float)bytes, (float)transferSize];
    else if (transferSize < 1024*1024)
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f KB", (double)bytes/1024, (double)transferSize/1024];
    else
        sizeStr = [sizeStr initWithFormat:@"%3.2f : %3.2f MB", (double)bytes/(1024*1024), (double)transferSize/(1024*1024)];
    [infoSize setStringValue:sizeStr];
    [sizeStr release];
    
    [progBar setDoubleValue:percent];
    [mainWin displayIfNeeded];
    [mainWin flushWindowIfNeeded];
}

- (IBAction)disconnect:(id)sender
{
    [ftp disconnect];
}

- (IBAction)showPrefPanel:(id)sender
{
    [prefPanel makeKeyAndOrderFront:self];
    switch (connMode)
    {
        case defaultMode:
            [portType selectCellWithTag:0];
            break;
        case portMode:
            [portType selectCellWithTag:1];
            break;
        case passiveMode:
            [portType selectCellWithTag:2];
            break;
        default:
            NSLog(@"Unexpected mode on pref pane setup.");
    }
}

- (IBAction)prefSave:(id)sender
{
    NSUserDefaults *defaults;

    defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"tag... %d", [[portType selectedCell] tag]);
    switch ([[portType selectedCell] tag])
    {
        case 0:
            //default
            NSLog(@"default");
            connMode = defaultMode;
            [ftp setPortDefault];
            [defaults setObject:@"default" forKey:connectionModeKey];
            break;
        case 1:
            //port
            NSLog(@"port");
            connMode = portMode;
            [ftp setPortPort];
            [defaults setObject:@"port" forKey:connectionModeKey];
            break;
        case 2:
            // passive
            NSLog(@"passive");
            connMode = passiveMode;
            [ftp setPortPassive];
            [defaults setObject:@"passive" forKey:connectionModeKey];
            break;
        default:
            NSLog(@"unexpected selection");
    }
    [prefPanel performClose:nil];
}

- (IBAction)prefCancel:(id)sender
{
    [prefPanel performClose:nil];
}

- (IBAction)showFtpLog:(id)sender
{
    [logWin makeKeyAndOrderFront:self];
}

/*
 This routine is called after adding new results to the text view's backing store.
 We now need to scroll the NSScrollView in which the NSTextView sits to the part
 that we just added at the end
 */
- (void)scrollToVisible:(id)ignore {
    [logTextField scrollRangeToVisible:NSMakeRange([[logTextField string] length], 0)];
}

- (IBAction)appendTextToLog:(NSString *)textChunk
{
    /* add the textChunk to the NSTextView's backing store as an attributed string */
    [[logTextField textStorage] appendAttributedString: [[[NSAttributedString alloc]
                             initWithString: textChunk] autorelease]];

    /* setup a selector to be called the next time through the event loop to scroll
       the view to the just pasted text.  We don't want to scroll right now,
       because of a bug in Mac OS X version 10.1 that causes scrolling in the context
       of a text storage update to starve the app of events */
    [self performSelector:@selector(scrollToVisible:) withObject:nil afterDelay:0.0];

}

/* --- connection panel methods --- */
- (IBAction)showConnPanel:(id)sender
{
    [connectPanel makeKeyAndOrderFront:self];
}

- (IBAction)connectConn:(id)sender
{
    NSArray *dirList;
    char    tempStr[1024];
    char    tempStr2[1024];
    
    [connectPanel performClose:nil];
    ftp = [[ftpclient alloc] initWithController:self :connMode];
    [[connAddress stringValue] getCString:tempStr];
    if ([ftp connect:[connPort intValue] :tempStr] < 0)
    {
        NSRunAlertPanel(@"Error", @"Connection failed.\nCheck that you typed the host name correctly.", @"Ok", nil, nil);
        NSLog(@"connection failed in connectConn");
        return;
    }
    if ([connAnon state] == NSOnState)
    {
        strcpy(tempStr, "anonymous");
        strcpy(tempStr2, "user@myhost.com");
    } else
    {
        [[connUser stringValue] getCString:tempStr];
        [[connPass stringValue] getCString:tempStr2];
    }
    if ([ftp authenticate:tempStr :tempStr2] < 0)
    {
        NSRunAlertPanel(@"Error", @"Authentication failed.\nCheck that your username and password are correct.", @"Ok", nil, nil);
        NSLog(@"authentication failed.");
        return;
    } else
    {
        [ftp setWorkingDir:[ftp homeDir]];
        if ((dirList = [ftp dirContents]) == nil)
        return;
        [remoteTableData initData:dirList];
        [remoteView setDataSource:remoteTableData];

        //we update the path menu
        [self updatePath :remotePath :[ftp workDirSplit]];
    }
}

- (IBAction)cancelConn:(id)sender
{
    [connectPanel performClose:nil];
}

- (IBAction)anonymousConn:(id)sender
{
    if ([connAnon state] == NSOnState)
    {
        [connUser setEnabled:NO];
        [connPass setEnabled:NO];
    } else
    {
        [connUser setEnabled:YES];
        [connPass setEnabled:YES];
    }
}

- (connectionModes)connectionMode
{
    return connMode;
}

@end

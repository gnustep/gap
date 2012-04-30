/* SongInspectorController.m - this file is part of Cynthiune
 *
 * Copyright (C) 2005 Wolfgang Sourdeau
 *
 * Author: Wolfgang Sourdeau <wolfgang@contre.com>
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#import <AppKit/NSButton.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSPopUpButton.h>
#import <AppKit/NSTextField.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>

#import <Cynthiune/Format.h>
#import <Cynthiune/NSViewExtensions.h>
#import <Cynthiune/utils.h>

#import "CynthiuneAnimatedImageView.h"

#import "MBResultsPanel.h"
#import "Song.h"
#import "SongInspectorController.h"

#define LOCALIZED(X) NSLocalizedString (X, nil)
#define busyTrmId "c457a4a8-b342-4ec9-8f13-b6bd26c0e400"

static NSNotificationCenter *nc = nil;

NSString *SongInspectorWasShownNotification = @"SongInspectorWasShownNotification";
NSString *SongInspectorWasHiddenNotification = @"SongInspectorWasHiddenNotification";
NSString *SongInspectorDidUpdateSongNotification = @"SongInspectorDidUpdateSongNotification";

static inline char**
MakeQis (char *trmId, Song *song)
{
  const char **qis;

  qis = malloc (7 * sizeof (char *));
  qis[0] = trmId;
  qis[1] = [[song artist] UTF8String];
  qis[2] = [[song album] UTF8String];
  qis[3] = [[song title] UTF8String];
  qis[4] = [[song trackNumber] UTF8String];
  qis[5] = [[[song duration] stringValue] UTF8String];
  qis[6] = NULL;

  return (char **) qis;
}

static inline void
FreeQis (char *qis[])
{
  free (qis[0]);
  free (qis);
}

@implementation SongInspectorController : NSObject

+ (void) initialize
{
  nc = [NSNotificationCenter defaultCenter];
}

+ (SongInspectorController *) songInspectorController
{
  static SongInspectorController *singleton = nil;

  if (!singleton)
    singleton = [self new];

  return singleton;
}

- (id) init
{
  if ((self == [super init]))
    {
      song = nil;

      [NSBundle loadNibNamed: @"SongInspector" owner: self];

      [titleField setDelegate: self];
      [albumField setDelegate: self];
      [trackField setDelegate: self];
      [artistField setDelegate: self];
      [genreField setDelegate: self];
      [yearField setDelegate: self];

      [lookupAnimation addFramesFromImagenames: @"anim-logo-1", @"anim-logo-2",
                       @"anim-logo-3", @"anim-logo-4", @"anim-logo-5",
                       @"anim-logo-6", @"anim-logo-7", @"anim-logo-8", nil];
      [lookupAnimation setInterval: .05];

      threadRunning = NO;
      threadShouldDie = NO;
    }

  return self;
}

/* untestable method */
- (void) dealloc
{
  if (delegate)
    [nc removeObserver: delegate name: nil object: self];
  [super dealloc];
}

- (void) _enableWindowButtons
{
  [resetButton setEnabled: YES];
  [saveButton setEnabled: YES];
}

- (void) _disableWindowButtons
{
  [resetButton setEnabled: NO];
  [saveButton setEnabled: NO];
}

- (void) _setFieldsEditable: (BOOL) editable
{
  [titleField setEditable: editable];
  [albumField setEditable: editable];
  [trackField setEditable: editable];
  [artistField setEditable: editable];
  [genreField setEditable: editable];
  [yearField setEditable: editable];

  if (editable)
    {
      if (!threadRunning)
        {
          [lookupButton setEnabled: YES];
          [lookupButton setImage: [NSImage imageNamed: @"lookup-mb-on"]];
          [lookupAnimation setImage: nil];
          [lookupStatusLabel setStringValue: @""];
        }
    }
  else
    {
      [lookupButton setEnabled: NO];
      [lookupButton setImage: [NSImage imageNamed: @"lookup-mb-off"]];
      [lookupAnimation setImage: [NSImage imageNamed: @"lock"]];
      [lookupStatusLabel setStringValue: @""];
    }

}

- (void) _updateFields
{
  [self _disableWindowButtons];

  if (song)
    {
      [filenameField setStringValue: [song filename]];
      [titleField setStringValue: [song title]];
      [albumField setStringValue: [song album]];
      [trackField setStringValue: [song trackNumber]];
      [artistField setStringValue: [song artist]];
      [genreField setStringValue: [song genre]];
      [yearField setStringValue: [song year]];

      [self _setFieldsEditable: [song songInfosCanBeModified]];
    }
  else
    {
      [filenameField setStringValue: LOCALIZED (@"No song selected")];
      [titleField setStringValue: @""];
      [albumField setStringValue: @""];
      [trackField setStringValue: @""];
      [artistField setStringValue: @""];
      [genreField setStringValue: @""];
      [yearField setStringValue: @""];

      [self _setFieldsEditable: NO];
    }
}

- (void) _updateSelector
{
  id <NSMenuItem> menuItem;
  int count, max;

  max = [pageSelector numberOfItems];
  for (count = 0; count < max; count++)
    {
      menuItem = [pageSelector itemAtIndex: count];
      [menuItem setTitle: LOCALIZED ([menuItem title])];
    }

  [pageSelector sizeToFit];
  [pageSelector centerViewHorizontally];
}

- (void) _updateWidgets
{
  [titleLabel setStringValue: LOCALIZED (@"Title")];
  [albumLabel setStringValue: LOCALIZED (@"Album")];
  [trackLabel setStringValue: LOCALIZED (@"Track")];
  [artistLabel setStringValue: LOCALIZED (@"Artist")];
  [genreLabel setStringValue: LOCALIZED (@"Genre")];
  [yearLabel setStringValue: LOCALIZED (@"Year")];

  [resetButton setTitle: LOCALIZED (@"Reset")];
  [saveButton setTitle: LOCALIZED (@"Save")];

  [resetButton sizeToFit];
  [saveButton sizeToFit];
  [resetButton arrangeViewLeftTo: saveButton];

  [lookupButton setToolTip: LOCALIZED (@"Lookup through MusicBrainz...")];
  [lookupButton setImage: [NSImage imageNamed: @"lookup-mb-off"]];

//   [lookupButton sizeToFit];
//   [lookupButton centerViewHorizontally];

  [inspectorPanel setTitle: LOCALIZED (@"Song Inspector")];
  [inspectorPanel setLevel: NSStatusWindowLevel];
  [inspectorPanel setDelegate: self];
}

- (void) awakeFromNib
{
  [self _updateSelector];
  [self _updateWidgets];
  [self _updateFields];
}

- (void) setDelegate: (id) anObject
{
  if (delegate)
    [nc removeObserver: delegate name: nil object: self];

  delegate = anObject;

  if ([delegate respondsToSelector: @selector(songInspectorWasShown:)])
    [nc addObserver: delegate
	selector: @selector (songInspectorWasShown:)
	name: SongInspectorWasShownNotification
	object: self];
  if ([delegate respondsToSelector: @selector(songInspectorWasHidden:)])
    [nc addObserver: delegate
	selector: @selector (songInspectorWasHidden:)
	name: SongInspectorWasHiddenNotification
	object: self];
  if ([delegate respondsToSelector: @selector(songInspectorDidUpdateSong:)])
    [nc addObserver: delegate
	selector: @selector (songInspectorDidUpdateSong:)
	name: SongInspectorDidUpdateSongNotification
	object: self];
}

- (id) delegate
{
  return delegate;
}

- (void) setSong: (Song *) newSong
{
  if (song != newSong)
    {
      if (threadRunning)
        threadShouldDie = YES;
      SET (song, newSong);
      [self _updateFields];
    }
}

- (Song *) song
{
  return song;
}

/* button actions */
- (void) reset: (id) sender
{
  [self _updateFields];
}

- (void) save: (id) sender
{
  [self _disableWindowButtons];

  [song setTitle: [titleField stringValue]
        artist: [artistField stringValue]
        album: [albumField stringValue]
        genre: [genreField stringValue]
        trackNumber: [trackField stringValue]
        year: [yearField stringValue]];

  [nc postNotificationName: SongInspectorDidUpdateSongNotification
      object: self
      userInfo: [NSDictionary dictionaryWithObject: song
                              forKey: @"song"]];
}

- (char *) _generateTrmId
{

return NULL; 
/*  id <Format> stream;
  trm_t trmGen;
  int size;
  char sig[17];
  unsigned char buffer[4096];
  char *trmId;

  stream = [song openStreamForSong];
  if (stream)
    {
      trmGen = trm_New ();
      trm_SetPCMDataInfo (trmGen,
                          [stream readRate], [stream readChannels], 16);
      trm_SetSongLength (trmGen, [stream readDuration]);
      size = [stream readNextChunk: buffer withSize: 4096];
      while (!trm_GenerateSignature (trmGen, (char *) buffer, size))
        size = [stream readNextChunk: buffer withSize: 4096];

      trm_FinalizeSignature (trmGen, sig, NULL);

      trmId = malloc (37);
      trm_ConvertSigToASCII (trmGen, sig, trmId);
      trm_Delete (trmGen);
      [stream streamClose];
    }
  else
    trmId = NULL;

  return trmId;
*/
}

- (void) updateField: (NSTextField *) field
          withString: (NSString *) string
{
  if (!threadShouldDie)
    [field performSelectorOnMainThread: @selector (setStringValue:)
           withObject: string
           waitUntilDone: NO];
}

- (BOOL) _updateInfoField: (NSTextField *) field
               withString: (NSString *) string
{
  BOOL result;

  if (!string)
    string = @"";

  if (![[field stringValue] isEqualToString: string])
    {
      [field setStringValue: string];
      result = YES;
    }
  else
    result = NO;

  return result;
}

- (void) _updateFieldsWithTrackInfos: (NSDictionary *) trackInfos
{
  BOOL changes;

  changes = [self _updateInfoField: titleField
                  withString: [trackInfos objectForKey: @"title"]];
  changes |= [self _updateInfoField: albumField
                   withString: [trackInfos objectForKey: @"album"]];
  changes |= [self _updateInfoField: trackField
                   withString: [trackInfos objectForKey: @"trackNumber"]];
  changes |= [self _updateInfoField: artistField
                   withString: [trackInfos objectForKey: @"artist"]];
  changes |= [self _updateInfoField: yearField
                   withString: [trackInfos objectForKey: @"year"]];

  if (changes)
    [self _enableWindowButtons];
}

- (void) _updateSongFields: (NSArray *) allTrackInfos
{
  unsigned int numberOfTracks;

  numberOfTracks = [allTrackInfos count];
  [lookupStatusLabel
    setStringValue: [NSString stringWithFormat:
                                LOCALIZED (@"Received %d result(s)"),
                              numberOfTracks]];
  if (numberOfTracks == 1)
    [self _updateFieldsWithTrackInfos: [allTrackInfos objectAtIndex: 0]];
  else if (numberOfTracks > 1)
    [[MBResultsPanel resultsPanel] showPanelForTrackInfos: allTrackInfos
                                   aboveWindow: inspectorPanel
                                   target: self
                                   selector: @selector (_updateFieldsWithTrackInfos:)];
}

/* 
- (NSDictionary *) readMB: (musicbrainz_t) mb
                    track: (int) track
{
  NSMutableDictionary *trackInfos;
  NSString *string;
  char cString[100];
  int releases;

  trackInfos = [NSMutableDictionary new];
  [trackInfos autorelease];

return trackInfos;
}
*/

//  mb_Select1 (mb, MBS_SelectTrack, track);
//  if (mb_GetResultData (mb, MBE_TrackGetTrackName, cString, 100))
//    {
//      string = [NSString stringWithUTF8String: cString];
//      [trackInfos setObject: string forKey: @"title"];
//    }

//  if (mb_GetResultData (mb, MBE_TrackGetArtistName, cString, 100))
//    {
//      string = [NSString stringWithUTF8String: cString];
//      [trackInfos setObject: string forKey: @"artist"];
//    }

//  if (mb_GetResultData (mb, MBE_TrackGetTrackNum, cString, 100))
//    {
//      string = [NSString stringWithUTF8String: cString];
//      [trackInfos setObject: string forKey: @"trackNumber"];
//    }

//  if (mb_Select (mb, MBS_SelectTrackAlbum))
//    {
//      if (mb_GetResultData (mb, MBE_AlbumGetAlbumName, cString, 100))
//        {
//          string = [NSString stringWithUTF8String: cString];
//          [trackInfos setObject: string forKey: @"album"];
//        }
//#ifdef MBE_AlbumGetNumReleaseDates
//      releases = mb_GetResultInt (mb, MBE_AlbumGetNumReleaseDates);
//      if (releases)
//        {
//          mb_Select1 (mb, MBS_SelectReleaseDate, 1);
//          if (mb_GetResultData (mb, MBE_ReleaseGetDate, cString, 100))
//            {
//              *(cString + 4) = 0;
//              string = [NSString stringWithUTF8String: cString];
//              [trackInfos setObject: string forKey: @"year"];
//            }
//          mb_Select (mb, MBS_Back);
//        }
//#endif

//      mb_Select (mb, MBS_Back);
//    }

//  mb_Select (mb, MBS_Rewind);

//  return trackInfos;
//}

/* - (void) _parseMB: (musicbrainz_t) mb
{
  int count, results;
  NSMutableArray *allTrackInfos;

  results = mb_GetResultInt (mb, MBE_GetNumTracks);
  allTrackInfos = [[NSMutableArray alloc] initWithCapacity: results];
  [allTrackInfos autorelease];

  for (count = 0; count < results; count++)
    [allTrackInfos addObject: [self readMB: mb track: count + 1]];

  [self performSelectorOnMainThread: @selector (_updateSongFields:)
        withObject: allTrackInfos
        waitUntilDone: YES];
}
*/

- (void) lookupThread
{

return;
/*
  NSAutoreleasePool *pool;
  char *trmId;
  musicbrainz_t mb;
  char **qis;
  char error[80];

  pool = [NSAutoreleasePool new];

  [self updateField: lookupStatusLabel
        withString: LOCALIZED(@"Generating TRM...")];
  trmId = [self _generateTrmId];
  if (trmId && !threadShouldDie)
    {
      qis = MakeQis (trmId, song);

      if (strcasecmp (trmId, busyTrmId))
        {
          [self updateField: lookupStatusLabel
                withString: LOCALIZED (@"Querying MusicBrainz server...")];
          mb = mb_New ();
          mb_UseUTF8 (mb, YES);
          if (mb_QueryWithArgs (mb, MBQ_TrackInfoFromTRMId, qis))
            [self _parseMB: mb];
          else
            {
//            FIXME: there should be an accurate error message here...
              [self updateField: lookupStatusLabel
                    withString: @""];
              mb_GetQueryError (mb, error, 80);
              NSLog (@"Musicbrainz error: %s (%s)", error, trmId);
            }
          mb_Delete (mb);
        }
      else
        [self updateField: lookupStatusLabel
              withString: LOCALIZED (@"The MusicBrainz server was too busy")];

      FreeQis (qis);
    }

  [self performSelectorOnMainThread: @selector (lookupThreadEnded)
        withObject: nil
        waitUntilDone: NO];

  [pool release];
*/
}

- (void) mbLookup: (id)sender
{
  if (song)
    {
      if (!threadRunning)
        {
          threadRunning = YES;
          [lookupAnimation startAnimation];
          [lookupButton setEnabled: NO];
          [lookupButton setImage: [NSImage imageNamed: @"lookup-mb-off"]];
          [NSThread detachNewThreadSelector: @selector (lookupThread)
                    toTarget: self
                    withObject: nil];
        }
    }
  else
    NSLog (@"how could that method be called?");
}

- (void) lookupThreadEnded
{
  threadRunning = NO;
  threadShouldDie = NO;
  [lookupAnimation stopAnimation];
  if (song && [song songInfosCanBeModified])
    {
      [lookupButton setEnabled: YES];
      [lookupButton setImage: [NSImage imageNamed: @"lookup-mb-on"]];
    }
}

- (void) toggleDisplay
{
  if ([inspectorPanel isVisible])
    [inspectorPanel close];
  else
    [inspectorPanel makeKeyAndOrderFront: self];
}

/* inspector delegate */
- (void) windowDidBecomeKey: (NSNotification*) aNotif
{
  if ([aNotif object] == inspectorPanel)
    [nc postNotificationName: SongInspectorWasShownNotification object: self];
}

- (void) windowWillClose: (NSNotification *) aNotif
{
  if ([aNotif object] == inspectorPanel)
    [nc postNotificationName: SongInspectorWasHiddenNotification object: self];
}

/* textfields delegate */

- (void) controlTextDidChange:(NSNotification *)aNotification
{
  [self _enableWindowButtons];
}

@end

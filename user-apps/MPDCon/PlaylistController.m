/* 
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-12 17:59:14 +0200 by flip
   
   Playlist Controller

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

#include <AppKit/AppKit.h>
#include "PlaylistController.h"
#include "SongRatingCell.h"

/* ---------------------
   - Private Interface -
   ---------------------*/
@interface PlaylistController(Private)
- (void) _doRemove;
- (void) _moveRows: (NSArray *)rows atRow: (NSInteger)row;
- (void) _addSongs: (NSArray *)paths atRow: (NSInteger)row;

- (void) _filterListByString: (NSString *)filterString;
@end

@implementation PlaylistController

/* --------------------------
   - Initialization Methods -
   --------------------------*/

+ (id) sharedPlaylistController
{
  static PlaylistController *_sharedPlaylistController = nil;

  if (! _sharedPlaylistController) 
    {
    _sharedPlaylistController = [[PlaylistController allocWithZone: 
						       [self zone]] init];
    }
  
  return _sharedPlaylistController;
}

- (id) init
{
  self = [self initWithWindowNibName: @"PlaylistViewer"];
  
  if (self) 
    {
      [self setWindowFrameAutosaveName: @"PlaylistViewer"];
    }

  mpdController = [MPDController sharedMPDController];
  
  return self;
}

- (void) dealloc
{
  RELEASE(playlist);
  RELEASE(playlistTimes);
  RELEASE(ratingCol);

  [super dealloc];
}

/* ---------------
   - Gui Methods -
   ---------------*/

- (void) awakeFromNib
{
  NSNotificationCenter *defCenter;

  SongRatingCell *ratingCell;

  ASSIGN(ratingCol, [playlistTable tableColumnWithIdentifier: @"rating"]);

  [playlistTable setAutosaveName: @"PlaylistTable"];
  [playlistTable setAutosaveTableColumns: YES];
  [playlistTable setTarget: self];
  [playlistTable setDoubleAction: @selector(doubleClicked:)];

  [playlistTable registerForDraggedTypes: 
		   [NSArray arrayWithObjects: PlaylistDragType, CollectionDragType, nil]];

  [lengthView setFont: [NSFont systemFontOfSize: 12]];

  defCenter = [NSNotificationCenter defaultCenter];

  [defCenter addObserver: self
		selector: @selector(songChanged:)
	            name: SongChangedNotification
	          object: nil];

  [defCenter addObserver: self
	        selector: @selector(playlistChanged:)
	            name: PlaylistChangedNotification
	          object: nil];

  [defCenter addObserver: self
	        selector: @selector(didNotConnect:)
	            name: DidNotConnectNotification
	          object: nil];

  currentSong = [mpdController getCurrentSongNr];

  ratingCell = [[SongRatingCell alloc] init];
  [ratingCol setDataCell:ratingCell];

  [self playlistChanged: nil];  
}

- (void) removeSongs: (id)sender
{
  switch ([removeSelector indexOfSelectedItem]) 
    {
    case 0:
      [self _doRemove];
      break;
    case 1:
      [mpdController clearPlaylist];
      break;
    }
}

- (void) managePlaylists: (id)sender
{
  [[PlaylistsManagerController sharedPLManagerController] showWindow: self];
}

- (void) doubleClicked: (id)sender
{
  int row;

  if ([playlistTable clickedRow] == -1)
    {
      return;
    }

  row = [playlistTable selectedRow];
  [mpdController playSong: [[playlist objectAtIndex: row] getPos]];
}

- (void) showCurrentSong: (id)sender
{
  int state;

  state = [mpdController getState];
  if ((state == state_PAUSE) || (state == state_PLAY)) 
    {
      if (([playlist count] >= currentSong) &&
          ([[playlist objectAtIndex: currentSong -1] getPos] == currentSong -1))
        {
          [playlistTable scrollRowToVisible: currentSong-1];
          [playlistTable selectRow: currentSong-1 byExtendingSelection: NO];
        }
      else
        {
          NSBeep();
        }
    }
}

- (void) shuffleList: (id)sender
{
  [mpdController shuffleList];
}

- (void) browseCollection: (id)sender
{
  [[CollectionController sharedCollectionController] showWindow: self];
}

- (void) filterList: (id)sender
{
  int selectedRow;
  int selectedPos = -1;
  
  selectedRow = [playlistTable selectedRow];
  
  if (selectedRow != -1)
    {
      selectedPos = [[playlist objectAtIndex: selectedRow] getPos];
    }
 
  [self playlistChanged: nil];
  
  if (selectedPos != -1)
    { 
      int i;
       
      for (i = 0; i < [playlist count]; i++)
        { 
          if ([[playlist objectAtIndex: i] getPos] == selectedPos)
            {
              [playlistTable scrollRowToVisible: i];
              [playlistTable selectRow: i byExtendingSelection: NO];
              break;
            }
        }
    }
}

- (void) clearFilter: (id)sender
{
  [filterField setStringValue: @""];
  
  [self filterList: sender];
  
}

/* --------------------------------
   - TableView dataSource Methods -
   --------------------------------*/

- (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView
{
    return [playlist count];
}

-          (id) tableView: (NSTableView *)tableView 
objectValueForTableColumn: (NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSString *identifier;

  identifier = [tableColumn identifier];

   if ([identifier isEqual: @"pos"])
     {
       return [NSString stringWithFormat: @"%d", [[playlist objectAtIndex: row] getPos]+1];
     }
   else if ([identifier isEqual: @"time"]) 
     {
       return [playlistTimes objectAtIndex: row];
     } 
   else if ([identifier isEqual: @"play"]) 
     {
       if (([[playlist objectAtIndex: row] getPos] == currentSong-1))
	 {
       int mState = [mpdController getState];
       
       if ((mState == state_PAUSE) || (mState == state_PLAY))
         {
    	   return [NSImage imageNamed: @"Current.tiff"];
         }
       else
         {
           return nil;
         }
	 }
       else
	 {
       return nil;
	 }
     } 
   else 
     {
       return [[playlist objectAtIndex: row] valueForKey: identifier];
     }
}


/* ------------------------------
   - TableView dragging Methods -
   ------------------------------*/

- (NSDragOperation) tableView: (NSTableView *)tv
		 validateDrop: (id <NSDraggingInfo>)info
		  proposedRow: (NSInteger)row
	proposedDropOperation: (NSTableViewDropOperation)dropOperation
{
  NSArray *typeArray;
  NSString *availableType;
  NSPasteboard *pboard;
  NSDragOperation dragOperation;
  
  pboard = [info draggingPasteboard];
  typeArray = [NSArray arrayWithObjects: PlaylistDragType, CollectionDragType, nil];
  availableType = [pboard availableTypeFromArray: typeArray];
  dragOperation = NSDragOperationNone;
      
  if (availableType)
    {
      [tv setDropRow: row dropOperation: NSTableViewDropAbove];
      if ([[filterField stringValue] compare: @""] == NSOrderedSame)
        {
          if (([availableType isEqualToString: PlaylistDragType]) ||
             ([availableType isEqualToString: CollectionDragType]))
             {
               dragOperation = NSDragOperationMove;
             }
        }

    }
  return dragOperation;
}

- (BOOL) tableView: (NSTableView *)tv
	acceptDrop: (id <NSDraggingInfo>)info
	       row: (NSInteger)row
     dropOperation: (NSTableViewDropOperation)dropOperation
{
  NSPasteboard *pboard;
  NSArray *objectsList, *typeArray;
  NSString *availableType;
  BOOL accept;
  
  pboard = [info draggingPasteboard];
  typeArray = [NSArray arrayWithObjects: PlaylistDragType, CollectionDragType, nil];
  
  availableType = [pboard availableTypeFromArray: typeArray];
  objectsList = [pboard propertyListForType: availableType];

  if ([objectsList count])
    {
      if ([availableType isEqualToString: PlaylistDragType]) 
	{
	  [self _moveRows: objectsList atRow: row];
      [tv deselectAll: nil];
	}
      else if ([availableType isEqualToString: CollectionDragType])
        {
          [self _addSongs: objectsList atRow: row];
        }
      accept = YES;
    }
  else
    {
      accept = NO;
    }

  return accept;
}


- (BOOL) tableView: (NSTableView *)tv
	 writeRows: (NSArray *)rows
      toPasteboard: (NSPasteboard*)pboard
{
  NSArray *typeArray;
  BOOL accept;
  unsigned int count;
  
  count = [rows count];
  
  if (count > 0)
    {
      accept = YES;
      typeArray = [NSArray arrayWithObjects: PlaylistDragType, nil];
      [pboard declareTypes: typeArray owner: self];
      [pboard setPropertyList: rows forType: PlaylistDragType];
    }
  else
    {
      accept = NO;
    }
  
  return accept;
}

/* ------------------------
   - Notification Methods -
   ------------------------*/

- (void) songChanged: (NSNotification *)aNotif
{
  currentSong = [mpdController getCurrentSongNr];
  [playlistTable reloadData];
}

- (void) playlistChanged: (NSNotification *)aNotif
{
  int length;
  int j;

  AUTORELEASE(playlist);

  playlist = RETAIN([mpdController getPlaylist]);

  if ([[filterField stringValue] compare: @""] != NSOrderedSame)
    {
      [self _filterListByString: [filterField stringValue]];
    }
    
  length=0;

  if ([playlist count] != 0) 
    {
      int i;
      int tSecs, tMins, tHours;
      
      for (i = 0; i < [playlist count]; i++) 
	{
	  length += [[playlist objectAtIndex: i] getTotalTime];
	}
    
    tSecs = (length % 60);
    tMins = (int) (length/60) % 60;
    tHours = (int) length/3600;
    
    [lengthView setStringValue: [NSString stringWithFormat: 
				 _(@"Playlist Length: %d:%02d:%02d"), 
				 tHours, tMins, tSecs]];
    } 
  else 
    {
      [lengthView setStringValue: _(@"Playlist Length: 0:00:00")];
    }

  AUTORELEASE(playlistTimes);

  playlistTimes = [[NSMutableArray alloc] init];

  for (j = 0; j < [playlist count]; j++) 
    {
      int time;
      int tSecs, tMins;
      
      time = [[playlist objectAtIndex: j] getTotalTime];
      
      tSecs = (time % 60);
      tMins = (int) time/60;
      
    [playlistTimes addObject: [NSString stringWithFormat: @"%d:%02d", 
					tMins, tSecs]];
    }
  
  [playlistTable reloadData];
  [playlistTable deselectAll: nil];
}


- (void) didNotConnect: (NSNotification *)aNotif
{
  [[self window] performClose: self];
}

@end

/* -------------------
   - Private Methods -
   -------------------*/

@implementation PlaylistController(Private)
- (void) _doRemove
{
  NSEnumerator *songEnum;
  NSNumber *songNumber;
  int i;

  if ([playlistTable numberOfSelectedRows] == [mpdController getPlaylistLength])
    {
      [mpdController clearPlaylist];
      return;
    }
    
  songEnum = [playlistTable selectedRowEnumerator];

  i = 0;

  while ((songNumber = [songEnum nextObject]) != nil) 
    {
      [mpdController removeSong: [[playlist objectAtIndex: [songNumber intValue]-i] getPos]];
      i++;
    }
  
  [playlistTable deselectAll: self];
}


- (void) _moveRows: (NSArray *)rows atRow: (NSInteger)row
{
  NSUInteger i;

  NSUInteger count = [rows count];
  
  NSUInteger ids[count];
  
  for (i = 0; i < count; i++) {
      ids[i] = [[playlist objectAtIndex: [[rows objectAtIndex: i] intValue]] getID];
  }

  for (i = 0; i < count; i++) {
      if ([[rows objectAtIndex: 0] intValue] < row)
    	  [mpdController moveSongWithID: ids[i] to: row-1];
      else
       	  [mpdController moveSongWithID: ids[i] to: row+i];
  }
 
  [playlistTable reloadData];
}

- (void) _addSongs: (NSArray *)songs atRow: (NSInteger)row
{
  NSUInteger i;
    
  for (i = 0; i < [songs count]; i++) {
      [mpdController addTrack: [songs objectAtIndex: i]];
      [mpdController moveSongNr: [mpdController getPlaylistLength]-1 to: (row+i)];
  }
}

- (void) _filterListByString: (NSString *) fString
{
  NSMutableArray *tmpArray;
  NSUInteger i;
  
  tmpArray = [[NSMutableArray alloc] init];
  
  for (i = 0; i < [playlist count]; i++) {
      if ([[[playlist objectAtIndex: i] getArtist] rangeOfString: fString options: NSCaseInsensitiveSearch].location != NSNotFound)  {
          [tmpArray addObject: [playlist objectAtIndex: i]];
      } else if ([[[playlist objectAtIndex: i] getTitle] rangeOfString: fString options: NSCaseInsensitiveSearch].location != NSNotFound)  {
          [tmpArray addObject: [playlist objectAtIndex: i]];
      } else if ([[[playlist objectAtIndex: i] getAlbum] rangeOfString: fString options: NSCaseInsensitiveSearch].location != NSNotFound)  {
          [tmpArray addObject: [playlist objectAtIndex: i]];
      } else if ([[[playlist objectAtIndex: i] getGenre] rangeOfString: fString options: NSCaseInsensitiveSearch].location != NSNotFound)  {
          [tmpArray addObject: [playlist objectAtIndex: i]];
      }
  }
    
  [playlist release];
  
  playlist = tmpArray;
}

-(void) tableView: (NSTableView*) aTableView
   setObjectValue: (id) anObj
   forTableColumn: (NSTableColumn*) aTableColumn
              row: (NSInteger) rowIndex
{
    if (aTableColumn == ratingCol) {
        id playlistItem;

        /* We can't keep that as an assertion now, as it can easily fail when
         * the broken GNUstep NSTableView lets you edit the string value for the cell.
         */
        if ([anObj isKindOfClass: [NSNumber class]] == NO) {
            NSLog(@"Warning: %@ is not a number value.", anObj);
        }

        playlistItem = [playlist objectAtIndex: rowIndex];
        [playlistItem setRating: [anObj integerValue]];
    }
}
      
@end

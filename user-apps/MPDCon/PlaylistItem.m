/*
   Project: MPDCon

   Copyright (C) 2004

   Author: Daniel Luederwald

   Created: 2004-05-14 11:53:40 +0200 by flip

   PlaylistItem

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

#include "PlaylistItem.h"

/* ----------------------
   - Private Categories -
   ----------------------*/
// inspired/stolen from SOPE
@interface NSObject(StringBindings)
- (NSString *)valueForStringBinding:(NSString *)_key;
@end

@interface NSString(misc)
- (NSString *)stringByReplacingVariablesWithBindings:(id)_bindings;
@end

@implementation PlaylistItem

// MPD itself doesn't provide the ability to retrieve lyrics via the server
// have to use external services to provide that ability
static NSString *LyricsAPIURL=@"http://lyrics.wikia.com/api.php?func=getSong&artist=$ARTIST$&song=$TITLE$&fmt=xml";

/* --------------------------
   - Initialization Methods -
   --------------------------*/

- (id) init
{
  MPDConDB = [SQLiteAdaptor sharedSQLiteAdaptor];
  return self;
}

- (void) dealloc
{
  [artist release];
  [title release];
  [album release];
  [genre release];
  [trackNr release];
  [path release];
  [comment release];
  [composer release];
  [date release];
  [performer release];
  [disc release];
  [lyricsText release];
  [lyricsURL release];

  [super dealloc];
}

/* --------------------
   - Accessor Methods -
   --------------------*/

- (NSString *) getArtist
{
  return artist;
}

- (void) setArtist: (NSString *)newArtist
{
  [artist autorelease];
  artist = [newArtist copy];
}

- (NSString *) getAlbum
{
  return album;
}

- (void) setAlbum: (NSString *)newAlbum
{
  [album autorelease];
  album = [newAlbum copy];
}

- (NSString *) getGenre
{
  return genre;
}

- (void) setGenre: (NSString *)newGenre
{
  [genre autorelease];
  genre = [newGenre copy];
}

- (NSString *) getTitle
{
  return title;
}

- (void) setTitle: (NSString *)newTitle
{
  [title autorelease];
  title = [newTitle copy];
}

- (NSString *) getTrackNr
{
  return trackNr;
}

- (void) setTrackNr: (NSString *)newNr
{
  [trackNr autorelease];
  trackNr = [newNr copy];
}

- (NSString *) getComment
{
  return comment;
}

- (void) setComment: (NSString *)newComment
{
  [comment autorelease];
  comment = [newComment copy];
}

- (NSString *) getComposer
{
  return composer;
}

- (void) setComposer: (NSString *)newComposer
{
  [composer autorelease];
  composer = [newComposer copy];
}

- (NSString *) getDate
{
  return date;
}

- (void) setDate: (NSString *)newDate
{
  [date autorelease];
  date = [newDate copy];
}

- (NSString *) getPerformer
{
  return performer;
}

- (void) setPerformer: (NSString *)newPerformer
{
  [performer autorelease];
  performer = [newPerformer copy];
}

- (NSString *) getDisc
{
  return disc;
}

- (void) setDisc: (NSString *)newDisc
{
  [disc autorelease];
  disc = [newDisc copy];
}

- (int) getElapsedTime
{
  return elapsedTime;
}

- (void) setElapsedTime: (int)newTime
{
  elapsedTime = newTime;
}

- (int) getTotalTime
{
  return totalTime;
}

- (void) setTotalTime: (int)newTime
{
  totalTime = newTime;
}

- (NSString *) getPath
{
  return path;
}

- (void) setPath: (NSString *)newPath
{
  [path autorelease];
  path = [newPath copy];
}

- (NSInteger) getRating
{
  return [MPDConDB getRatingForFile:path];
}

- (void) setRating: (NSInteger)newRating
{
  [MPDConDB setRating: newRating forFile: path];
}

- (NSDictionary *) getLyrics
{
  NSDictionary *lyricsDict;
  NSDictionary *bindings;
  NSString *requestURL;
  NSData *result;
  NSURL *url;
  NSXMLParser *parser;

  lyricsDict = [MPDConDB getLyricsForFile:path];
  if (lyricsDict)
    return lyricsDict;

  bindings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
    [[self getArtist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"ARTIST",
    [[self getTitle] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"TITLE",
      nil];
  requestURL = [LyricsAPIURL stringByReplacingVariablesWithBindings:bindings];
  url = [NSURL URLWithString:requestURL];
  result = [NSData dataWithContentsOfURL:url];
  if (result)
    {
      parser = [[[NSXMLParser alloc] initWithData:result] autorelease];
      [parser setShouldProcessNamespaces:NO];
      [parser setShouldReportNamespacePrefixes:NO];
      [parser setShouldResolveExternalEntities:NO];
      [parser setDelegate:self];
      [parser parse];
      // if we got something from the web, we save it in the DB
      if (![lyricsText isEqual:@"Not found"])
        {
          [self setLyrics: lyricsText withURL: lyricsURL];
        }
    }
  else
    {
      lyricsText = [@"unable to connect to lyrics.wikia.com" copy];
      lyricsURL = [@"http://lyrics.wikia.com" copy];
    }

  lyricsDict =
    [[NSDictionary alloc] initWithObjectsAndKeys:
      lyricsText, @"lyricsText",
      lyricsURL, @"lyricsURL",
      nil];
  
  return lyricsDict;
}
- (void) setLyrics: (NSString *) _lyricsText withURL: (NSString *) _lyricsURL
{
  [MPDConDB setLyrics: _lyricsText withURL: _lyricsURL forFile: path];
}

- (void) setID: (int) newID
{
  ID = newID;
}

- (int) getID
{
  return ID;
}

- (void) setPos: (int) newPos
{
  pos = newPos;
}

- (int) getPos
{
  return pos;
}

/* getLyrics NSXMLParser delegate methods */
- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName
     attributes:(NSDictionary *)attributeDict
{
  element = [NSMutableString string];
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
  if ([elementName isEqualToString:@"lyrics"])
    {
      lyricsText = [element copy];
    }
  else if ([elementName isEqualToString:@"url"])
    {
      lyricsURL = [element copy];
    }
}

- (void) parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
 if(element == nil)
  {
    element = [[NSMutableString alloc] init];
  }

 [element appendString:string];
}
@end

/* ----------------------
   - Private Categories -
   ---------------------*/

@implementation NSObject(StringBindings)
- (NSString *)valueForStringBinding:(NSString *)_key {
  if (_key == nil) return nil;
  return [self valueForKeyPath:_key];
}
@end

@implementation NSString(misc)
- (NSString *)stringByReplacingVariablesWithBindings:(id)_bindings
{
  NSUInteger      len, pos = 0;
  unichar         *wbuf    = NULL;
  NSMutableString *str     = nil;

  str = [self mutableCopy];
  len = [str length];
  wbuf   = malloc(sizeof(unichar) * (len + 4));
  [self getCharacters:wbuf];

  while (pos < len)
    {
      if (pos + 1 == len) /* last entry */
        {
          if (wbuf[pos] == '$') /* found $ without end-char */
            {
              [NSException raise:@"NSStringVariableBindingException"
                 format:@"did not find end of variable for string %@", self];
            }
          break;
        }
      if (wbuf[pos] == '$')
        {
          if (wbuf[pos + 1] == '$')/* found $$ --> $ */
            {
              [str deleteCharactersInRange:NSMakeRange(pos, 1)];

              if (wbuf != NULL)
                {
                  free(wbuf); wbuf = NULL;
                }
              len  = [str length];
              wbuf = malloc(sizeof(unichar) * (len + 4));
              [str getCharacters:wbuf];
            }
          else
            {
              NSUInteger startPos = pos;

              pos += 2; /* wbuf[pos + 1] != '$' */
              while (pos < len)
                {
                  if (wbuf[pos] != '$')
                    pos++;
                  else
                    break;
                }
              if (pos == len) /* end of string was reached */
                {
                  [NSException raise:@"NSStringVariableBindingException"
                     format:@"did not find end of variable for string %@",
                     self];
                }
              else
                {
                  NSString *key;
                  NSString *value;

                  key = [[NSString alloc]
                          initWithCharacters:(wbuf + startPos + 1)
                          length:(pos - startPos - 1)];

                  if ((value = [_bindings valueForStringBinding:key]) == nil)
                    {
                      value = @"";
                    }
                  [key release]; key = nil;

                  [str replaceCharactersInRange:
                         NSMakeRange(startPos, pos - startPos + 1)
                       withString:value];

                  if (wbuf != NULL)
                    {
                      free(wbuf); wbuf = NULL;
                    }
                  len  = [str length];
                  wbuf = malloc(sizeof(unichar) * (len + 4));
                  [str getCharacters:wbuf];

                  pos = startPos - 1 + [value length];
                }
            }
        }
      pos++;
    }
  if (wbuf != NULL)
    {
      free(wbuf); wbuf = NULL;
    }
  {
    id tmp = str;
    str = [str copy];
    [tmp release]; tmp = nil;
  }
  return [str autorelease];
}
@end /* NSString(misc) */

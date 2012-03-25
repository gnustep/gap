/* FLACTags.m - this file is part of Cynthiune
 *
 * Copyright (C) 2006 Wolfgang Sourdeau
 *
 * Author: Wolfgang Sourdeau <Wolfgang@Contre.COM>
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

#define _GNU_SOURCE 1
#import <stdlib.h>
#import <string.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>

#import <Cynthiune/utils.h>

#import <FLAC/all.h>

#import "FLACTags.h"

#define LOCALIZED(X) _b ([FLACTags class], X)

static inline int
keyPositionInArray (const char *key)
{
  unsigned int count;
  signed int result, len;
  const char *keys[] = { "title", "artist", "album", "tracknumber", "genre",
                         "date" };

  result = -1;
  count = 0;
  while (count < 6 && result == -1)
    {
      len = strlen (keys[count]);
      if (strncasecmp (keys[count], key, len) == 0)
        result = count;
      else
        count++;
    }

  return result;
}

static inline void
processComment (FLAC__StreamMetadata_VorbisComment_Entry *vcEntry,
                NSString **arrayOfValues[])
{
  char *key, *value, *equalsign;
  signed int position;

  key = strndup ((char *) vcEntry->entry, vcEntry->length);
  equalsign = strchr (key, '=');
  if (equalsign)
    {
      *equalsign = 0;
      value = equalsign + 1;
      position = keyPositionInArray (key);
      if (position > -1)
        SET (*arrayOfValues[position], [NSString stringWithUTF8String: value]);
    }
  free (key);
}

static FLAC__StreamDecoderWriteStatus
writeCallback (const FLAC__FileDecoder *fileDecoder, const FLAC__Frame *frame,
               const FLAC__int32 * const buffer[], void *clientData)
{
  return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

static void
metadataCallback (const FLAC__FileDecoder *fileDecoder,
                  const FLAC__StreamMetadata *metadata,
                  void *clientData)
{
  unsigned int count;

  if (metadata->type == FLAC__METADATA_TYPE_VORBIS_COMMENT)
    {
      count = 0;
      while (count < metadata->data.vorbis_comment.num_comments)
        {
          processComment (metadata->data.vorbis_comment.comments + count,
                          clientData);
          count++;
        }
    }
}

static void
errorCallback (const FLAC__FileDecoder *fileDecoder,
               FLAC__StreamDecoderErrorStatus status,
               void *clientData)
{
  NSLog (@"FLACTags: received error with status %d", status);
}

@implementation FLACTags : NSObject

+ (NSString *) bundleDescription
{
  return @"A bundle to read/set the tags of FLAC files";
}

+ (NSArray *) bundleCopyrightStrings
{
  return [NSArray arrayWithObject: @"Copyright (C) 2006 Wolfgang Sourdeau"];
}

/* TagsReading protocol */
+ (BOOL) readTitle: (NSString **) title
            artist: (NSString **) artist
             album: (NSString **) album
       trackNumber: (NSString **) trackNumber
             genre: (NSString **) genre
              year: (NSString **) year
        ofFilename: (NSString *) filename
{
  FLAC__FileDecoder *fileDecoder;
  BOOL result;
  NSString **arrayOfValues[] = { title, artist, album, trackNumber,
                                 genre, year };

  fileDecoder = FLAC__file_decoder_new();
  if (fileDecoder)
    {
      FLAC__file_decoder_set_metadata_ignore_all (fileDecoder);
      FLAC__file_decoder_set_metadata_respond (fileDecoder,
                                               FLAC__METADATA_TYPE_VORBIS_COMMENT);
      FLAC__file_decoder_set_metadata_callback (fileDecoder,
                                                metadataCallback);
      FLAC__file_decoder_set_write_callback (fileDecoder, writeCallback);
      FLAC__file_decoder_set_error_callback (fileDecoder, errorCallback);
      FLAC__file_decoder_set_client_data (fileDecoder, arrayOfValues);

      result = (FLAC__file_decoder_set_filename (fileDecoder,
                                                 [filename cString])
                && (FLAC__file_decoder_init (fileDecoder)
                    == FLAC__FILE_DECODER_OK)
                && FLAC__file_decoder_process_until_end_of_metadata
                (fileDecoder));
      FLAC__file_decoder_delete (fileDecoder);
    }
  else
    result = NO;

  return result;
}

@end

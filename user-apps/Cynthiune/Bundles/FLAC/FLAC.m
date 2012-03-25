/* FLAC.m - this file is part of Cynthiune
 *
 * Copyright (C) 2004 Wolfgang Sourdeau
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
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>

#import <FLAC/all.h>

#import <Cynthiune/CynthiuneBundle.h>
#import <Cynthiune/Format.h>
#import <Cynthiune/utils.h>

#import "FLAC.h"

#define LOCALIZED(X) _b ([FLAC class], X)

static FLAC__StreamDecoderWriteStatus
writeCallback (const FLAC__FileDecoder *fileDecoder, const FLAC__Frame *frame,
               const FLAC__int32 * const buffer[], void *clientData)
{
  CFLAC *cStream;
  unsigned int sample, channel;
  unsigned char *bufferPtr;

  cStream = clientData;
  if (cStream->readBuffer)
    free (cStream->readBuffer);
  cStream->readBufferSize = (frame->header.blocksize * cStream->channels
                             * cStream->bitsPerSample / 8);
  cStream->readBuffer = malloc (cStream->readBufferSize);

  bufferPtr = cStream->readBuffer;
  if (cStream->bitsPerSample == 8)
    for (sample = 0; sample < frame->header.blocksize; sample++)
      for (channel = 0; channel < cStream->channels; channel++)
        *bufferPtr++ = buffer[channel][sample];
  else if (cStream->bitsPerSample == 16)
    for (sample = 0; sample < frame->header.blocksize; sample++)
      for (channel = 0; channel < cStream->channels; channel++)
        {
          *bufferPtr++ = buffer[channel][sample] & 0x00FF;
          *bufferPtr++ = (buffer[channel][sample] & 0xff00) >> 8;
        }

  return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

static void
metadataCallback (const FLAC__FileDecoder *fileDecoder,
                  const FLAC__StreamMetadata *metadata,
                  void *clientData)
{
  CFLAC *cStream;

  if (metadata->type == FLAC__METADATA_TYPE_STREAMINFO)
    {
      cStream = clientData;
      cStream->channels = metadata->data.stream_info.channels;
      cStream->rate = metadata->data.stream_info.sample_rate;
      cStream->bitsPerSample = metadata->data.stream_info.bits_per_sample;
      cStream->duration = (metadata->data.stream_info.total_samples
                           / metadata->data.stream_info.sample_rate);
    }
}

static void
errorCallback (const FLAC__FileDecoder *fileDecoder,
               FLAC__StreamDecoderErrorStatus status,
               void *clientData)
{
  NSLog (@"FLAC: received error with status %d", status);
}

@implementation FLAC : NSObject

+ (NSString *) bundleDescription
{
  return @"Extension plug-in for the Free Lossless Audio Codec";
}

+ (NSArray *) bundleCopyrightStrings
{
  return [NSArray arrayWithObjects:
                    @"Copyright (C) 2004  Wolfgang Sourdeau",
                  nil];
}

+ (NSArray *) compatibleTagBundles
{
  return [NSArray arrayWithObjects: @"FLACTags", @"TagLib", nil];
}

+ (NSArray *) acceptedFileExtensions
{
  return [NSArray arrayWithObjects: @"fla", @"flac", nil];
}

+ (BOOL) canTestFileHeaders
{
  return YES;
}

+ (BOOL) streamTestOpen: (NSString *) fileName
{
  FILE *_f;
  char buffer[4];
  BOOL result;

  _f = fopen ([fileName cString], "r");

  if (_f)
    {
      result = (fread (buffer, 1, 4, _f) == 4
                && strncmp (buffer, "fLaC", 4) == 0);
      fclose (_f);
    }
  else
    result = NO;

  return result;
}

- (id) init
{
  if ((self = [super init]))
    {
      duration = 0;
      channels = 0;
      rate = 0;
      position = 0;
      readBuffer = NULL;
      readBufferSize = 0;
    }

  return self;
}

- (BOOL) _initializeFileDecoderWithFilename: (NSString *) fileName
{
  FLAC__file_decoder_set_metadata_ignore_all (fileDecoder);
  FLAC__file_decoder_set_metadata_respond (fileDecoder,
                                           FLAC__METADATA_TYPE_STREAMINFO);
  FLAC__file_decoder_set_metadata_callback (fileDecoder,
                                            metadataCallback);
  FLAC__file_decoder_set_write_callback (fileDecoder, writeCallback);
  FLAC__file_decoder_set_error_callback (fileDecoder, errorCallback);
  FLAC__file_decoder_set_client_data (fileDecoder, self);

  return (FLAC__file_decoder_set_filename (fileDecoder, [fileName cString])
          && (FLAC__file_decoder_init (fileDecoder) == FLAC__FILE_DECODER_OK)
          && FLAC__file_decoder_process_until_end_of_metadata (fileDecoder));
}

- (BOOL) streamOpen: (NSString *) fileName
{
  BOOL result;

  fileDecoder = FLAC__file_decoder_new();

  if (fileDecoder)
    {
      if ([self _initializeFileDecoderWithFilename: fileName])
        result = YES;
      else
        {
          FLAC__file_decoder_delete (fileDecoder);
          fileDecoder = NULL;
          result = NO;
        }
    }
  else
    result = NO;

  return result;
}

- (void) streamClose
{
  FLAC__file_decoder_delete (fileDecoder);
  fileDecoder = NULL;
}

- (int) _processNextChunk: (unsigned char *) buffer
                 withSize: (unsigned int) bufferSize
{
  int readBytes;
  unsigned int maxSize;
  BOOL success;

  success = YES;
  if (position >= readBufferSize)
    {
      position = 0;
      success = FLAC__file_decoder_process_single (fileDecoder);
    }

  if (success)
    {
      if (bitsPerSample == 8)
        {
          maxSize = bufferSize / 2;
          if (maxSize > (readBufferSize - position))
            maxSize = readBufferSize - position;
          convert8to16 (readBuffer + position, buffer, maxSize);
          position += maxSize;
          readBytes = maxSize * 2;
        }
      else if (bitsPerSample == 16)
        {
          maxSize = bufferSize;
          if (maxSize > (readBufferSize - position))
            maxSize = readBufferSize - position;
          memcpy (buffer, readBuffer + position, maxSize);
          position += maxSize;
          readBytes = maxSize;
        }
      else
        readBytes = -1;
    }
  else
    readBytes = -1;

  return readBytes;
}

- (int) readNextChunk: (unsigned char *) buffer
             withSize: (unsigned int) bufferSize
{
  int readBytes;
  FLAC__FileDecoderState state;

  state = FLAC__file_decoder_get_state (fileDecoder);

  if (state == FLAC__FILE_DECODER_OK)
    readBytes = [self _processNextChunk: buffer withSize: bufferSize];
  else if (state == FLAC__FILE_DECODER_END_OF_FILE)
    readBytes = 0;
  else
    readBytes = -1;

  return readBytes;
}

- (BOOL) isSeekable
{
  return YES;
}

- (void) seek: (unsigned int) aPos
{
  FLAC__file_decoder_seek_absolute (fileDecoder, aPos * rate);
}

- (unsigned int) readChannels
{
  return channels;
}

- (unsigned long) readRate
{
  return rate;
}

- (unsigned int) readDuration
{
  return duration;
}

- (void) dealloc
{
  if (readBuffer)
    free (readBuffer);
  if (fileDecoder)
    FLAC__file_decoder_delete (fileDecoder);
  [super dealloc];
}

@end

/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "LyricsInspector.h"
#include "PlaylistItem.h"

// inspired/stolen from SOPE
@interface NSObject(StringBindings)
- (NSString *)valueForStringBinding:(NSString *)_key;
@end
@implementation NSObject(StringBindings)
- (NSString *)valueForStringBinding:(NSString *)_key {
  if (_key == nil) return nil;
  return [self valueForKeyPath:_key];
}
@end

@interface NSString(misc)
- (NSString *)stringByReplacingVariablesWithBindings:(id)_bindings;
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


@implementation LyricsInspector

/* --------------------------
   - Initialization Methods -
   --------------------------*/
static NSString *LyricsAPIURL=@"http://lyrics.wikia.com/api.php?func=getSong&artist=$ARTIST$&song=$TITLE$&fmt=xml";

+ (id) sharedLyricsInspector
{
  static LyricsInspector *_sharedLyricsInspector = nil;

  if (! _sharedLyricsInspector) {
      _sharedLyricsInspector = [[LyricsInspector allocWithZone: [self zone]] init];
  }

  return _sharedLyricsInspector;
}

- (id) init
{
  self = [self initWithWindowNibName: @"LyricsInspector"];

  if (self) {
      [self setWindowFrameAutosaveName: @"LyricsInspector"];
  }
  mpdController = [MPDController sharedMPDController];

  return self;
}

- (void) dealloc
{
  RELEASE(element);
  RELEASE(lyricsURL);

  [super dealloc];
}

/* GUI methods */
- (void) awakeFromNib
{
  NSNotificationCenter *defCenter;
  defCenter = [NSNotificationCenter defaultCenter];
  [defCenter addObserver: self
                selector: @selector(songChanged:)
                    name: SongChangedNotification
                  object: nil];

  [self updateLyrics];
}



/* the method behind the button */
- (void) openURL: (id)sender
{
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: lyricsURL]];
}

/* the delegate methods */
- (void) songChanged:(NSNotification *)aNotif
{
  [self updateLyrics];
}

- (void) updateLyrics
{
  PlaylistItem *currentSong;
  NSDictionary *bindings;
  NSString *requestURL;
  NSURL *url;
  NSData *result;
  NSXMLParser *parser;

  currentSong = [mpdController getCurrentSong];
  [artist setStringValue:[currentSong getArtist]];
  [title setStringValue:[currentSong getTitle]];

  bindings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
    [[currentSong getArtist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"ARTIST",
    [[currentSong getTitle] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"TITLE", 
      nil];
  requestURL = [LyricsAPIURL stringByReplacingVariablesWithBindings:bindings];
  
  url = [NSURL URLWithString:requestURL];
  result = [NSData dataWithContentsOfURL:url];
  parser = [[[NSXMLParser alloc] initWithData:result] autorelease];
  [parser setShouldProcessNamespaces:NO];
  [parser setShouldReportNamespacePrefixes:NO];
  [parser setShouldResolveExternalEntities:NO];
  [parser setDelegate:self];
  [parser parse];
}

/* NSXMLParser delegate methods */
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
  qualifiedName:(NSString *)qName {

  if ([elementName isEqualToString:@"lyrics"])
    {
      [lyricsText setStringValue: element];
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
        element = [[NSMutableString alloc] init];

 [element appendString:string];
}

@end

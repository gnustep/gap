/*
 * Copyright (C) 2003  Stefan Kleine Stegemann
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#include <PDFKit/PDFFontManager.h>

#include <Foundation/NSBundle.h>
#include <Foundation/NSException.h>
#include <Foundation/NSFileManager.h>

#include "XPDFBridge.h"


/* Default fonts and their subsitutes (font names from xpdf's GlobalParams).  */
static struct 
{
   NSString* name;
   NSString* fileName;
   FontType  type;
} FontTab[] =
{
   {@"Courier",               @"n022003l.pfb", Type1Font},
   {@"Courier-Bold",          @"n022004l.pfb", Type1Font},
   {@"Courier-BoldOblique",   @"n022024l.pfb", Type1Font},
   {@"Courier-Oblique",       @"n022023l.pfb", Type1Font},
   {@"Helvetica",             @"n019003l.pfb", Type1Font},
   {@"Helvetica-Bold",        @"n019004l.pfb", Type1Font},
   {@"Helvetica-BoldOblique", @"n019024l.pfb", Type1Font},
   {@"Helvetica-Oblique",     @"n019023l.pfb", Type1Font},
   {@"Symbol",                @"s050000l.pfb", Type1Font},
   {@"Times-Bold",            @"n021004l.pfb", Type1Font},
   {@"Times-BoldItalic",      @"n021024l.pfb", Type1Font},
   {@"Times-Italic",          @"n021023l.pfb", Type1Font},
   {@"Times-Roman",           @"n021003l.pfb", Type1Font},
   {@"ZapfDingbats",          @"d050000l.pfb", Type1Font},
   {nil, nil, UnknownFontType}
};


/* The shared instance of PDFFontManager.  */
static PDFFontManager* sharedPDFFontManager = nil;


/*
 * Non-Public methods.
 */
@interface PDFFontManager(Private)
- (NSString*) _findFontFile: (NSString*)fileName;
- (BOOL) _displayFontForFont: (NSString*)fontName
                    fileName: (NSString**)fileName
                        type: (FontType*)type;
@end


@implementation PDFFontManager

- (id) init
{
   int       i;
   NSString* fontFile;

   if ((self = [super init]))
   {
      fontNames    = [[NSMutableArray alloc] initWithCapacity: 0];

      for (i = 0; FontTab[i].name; i++)
      {
         fontFile = [self _findFontFile: FontTab[i].fileName];
         if (fontFile)
         {
            [self setFontFile: fontFile
                       ofType: FontTab[i].type
                      forFont: FontTab[i].name];
         }
         else
         {
            NSLog(@"WARNING: no font for %@", FontTab[i].name);
         }
      }
   }

   return self;
}


- (void) dealloc
{
   RELEASE(fontNames);

   [super dealloc];
}


+ (PDFFontManager*) sharedManager
{
   if (!sharedPDFFontManager)
   {
      sharedPDFFontManager = [[PDFFontManager alloc] init];
   }

   return sharedPDFFontManager;
}


- (NSArray*) fontNames
{
   return [NSArray arrayWithArray: fontNames];
}


- (NSArray*) defaultFontNames
{
   NSMutableArray* names;
   int             i;

   names = [[NSMutableArray alloc] initWithCapacity: 0];

   for (i = 0; FontTab[i].name; i++)
   {
      [names addObject: [FontTab[i].name copy]];
   }

   return names;
}


- (NSString*) fontFileFor: (NSString*)fontName
{
   NSString* fileName;
   FontType  type;

   if ([self _displayFontForFont: fontName
                        fileName: &fileName
                            type: &type])
   {
      return fileName;
   }

   return nil;
}


- (FontType) fontTypeFor: (NSString*)fontName
{
   NSString* fileName;
   FontType  type;

   if ([self _displayFontForFont: fontName
                        fileName: &fileName
                            type: &type])
   {
      return type;
   }

   return UnknownFontType;   
}


- (void) setFontFile: (NSString*)file 
              ofType: (FontType)type
             forFont: (NSString*)fontName
{
   int i;

   NSAssert([[NSFileManager defaultManager] fileExistsAtPath: file],
            @"font file does no exist");

   PDFFont_AddDisplayFont([fontName cString],
                          [file cString],
                          (type == Type1Font ? T1DisplayFont : TTDisplayFont));

   // ensure that the fontname is in the list of fonts
   for (i = 0; i < [fontNames count]; i++)
   {
      if ([[fontNames objectAtIndex: i] isEqualToString: fontName])
      {
         break;
      }
   }

   if (i >= [fontNames count])
   {
      [fontNames addObject: [fontName copy]];
   }
}

@end



@implementation PDFFontManager(Private)

- (NSString*) _findFontFile: (NSString*)fileName
{
   NSBundle* bundle;
   NSString* pathToFile;
   
   bundle = [NSBundle bundleForClass: [self class]];
   NSAssert(bundle, @"Could not load PDFKit Bundle");

   pathToFile = [bundle pathForResource: [fileName stringByDeletingPathExtension]
                                 ofType: [fileName pathExtension]];

   if (!pathToFile)
   {
      NSLog(@"WARNING: Resource %@ of type %@ not found",
            [fileName stringByDeletingPathExtension],
            [fileName pathExtension]);
   }

   return pathToFile;
}


- (BOOL) _displayFontForFont: (NSString*)fontName
                    fileName: (NSString**)fileName
                        type: (FontType*)type
{
   const char*      _fileName;
   DisplayFontType  _type;
   
   PDFFont_GetDisplayFont([fontName cString],
                          &_fileName,
                          &_type);

   if (_fileName == NULL)
   {
      return NO;
   }

   *fileName = [NSString stringWithCString: _fileName];
   *type = (_type == T1DisplayFont ? Type1Font : TrueTypeFont);

   return YES;
}

@end

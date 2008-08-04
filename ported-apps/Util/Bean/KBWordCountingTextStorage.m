//
//  KBWordCountingTextStorage.m
//  ---------------------------
//
//  Keith Blount 2005
//

#import "KBWordCountingTextStorage.h"

static unichar newLineChar = 0x000a;
static unichar attachmentChar = 0xfffc;

NSString *KBTextStorageStatisticsDidChangeNotification = @"KBTextStorageStatisticsDidChangeNotification";

@implementation KBWordCountingTextStorage

/*************************** Word Count Specific Methods ***************************/

#pragma mark -
#pragma mark Word Count Specific Methods

/*
 *	-wordCountForRange: uses -doubleClickAtIndex: to calculate the word count.
 *	This method was recommended for this purpose by Aki Inoue at Apple.
 *	The docs mention that such methods (actually the docs are talking about -nextWordFromIndex:forward:
 *	in this context) aren't intended for linguistic analysis, but Aki Inoue explained that this was
 *	only because they do not perform linguistic analysis and therefore may not be entirely accurate
 *	for Japanese/Chinese, but should be fine for the majority of purposes.
 *	-wordRangeForCharRange: uses -nextWordAtIndex:forward: to get a rough word range to count,
 *	because using -doubleClickAtIndex: for that method too would require more checks to stop out of bounds
 *	exceptions.
 *	UPDATE 19/09/05: Now both methods use -nextWordAtIndex:, because after extensive tests, it turns out
 *	that -doubleClickAtIndex: is incredibly slow compared to -nextWordAtIndex:.
 */

- (unsigned)wordCountForRange:(NSRange)range
{
	unsigned wc = 0;
	NSCharacterSet *lettersAndNumbers = [NSCharacterSet alphanumericCharacterSet];
	
	int index = range.location;
	int endIndex = NSMaxRange(range);
	while (index < endIndex)
	{
		//int newIndex = NSMaxRange([self doubleClickAtIndex:index]);
		
		// BUG FIX 17/09/06: added MIN() check to ensure that we count nothing that is beyond the edge of the selection.
		int newIndex = MIN(endIndex,[self nextWordFromIndex:index forward:YES]);
		
		NSString *word = [[self string] substringWithRange:NSMakeRange(index, newIndex-index)];
		// Make sure it is a valid word - ie. it must contain letters or numbers, otherwise don't count it
		if ([word rangeOfCharacterFromSet:lettersAndNumbers].location != NSNotFound)
			wc++;

		index = newIndex;
	}
	return wc;
}

- (NSRange)wordRangeForCharRange:(NSRange)charRange
{
	// Leopard fix - if there is no text, we have to return the charRange unchanged.
	if ([self length] == 0)
		return charRange;
	
	NSRange wordRange;
	wordRange.location = [self nextWordFromIndex:charRange.location forward:NO];
	wordRange.length = [self nextWordFromIndex:NSMaxRange(charRange) forward:YES] - wordRange.location;
	return wordRange;
}

- (unsigned)wordCount
{
	return wordCount;
}

/*************************** NSTextStorage Overrides ***************************/

#pragma mark -
#pragma mark NSTextStorage Overrides

// All of these methods are necessary to create a concrete subclass of NSTextStorage

- (id)init
{
	if (self = [super initWithString: nil attributes: nil])
	{
		text = [[NSMutableAttributedString alloc] init];
		wordCount = 0;
	}
	return self;
}

- (id)initWithString:(NSString *)aString
{
	if (self = [super initWithString: aString attributes: nil])
	{
		text = [[NSMutableAttributedString alloc] initWithString:aString];
		wordCount = [self wordCountForRange:NSMakeRange(0,[text length])];
	}
	return self;
}

- (id)initWithString:(NSString *)aString attributes:(NSDictionary *)attributes
{
	if (self = [super initWithString: aString attributes: attributes])
	{
		text = [[NSMutableAttributedString alloc] initWithString:aString attributes:attributes];
		wordCount = [self wordCountForRange:NSMakeRange(0,[text length])];
	}
	return self;
}

- (id)initWithAttributedString:(NSAttributedString *)aString
{
	if (self = [super initWithAttributedString: aString])
	{
		text = [aString mutableCopy];
		wordCount = [self wordCountForRange:NSMakeRange(0,[text length])];
	}
	return self;
}

- (id)initWithAttributedString:(NSAttributedString *)aString wordCount:(unsigned)wc
{
	if (self = [super init])
	{
		text = [aString mutableCopy];
		wordCount = wc;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];	// According to CocoaDev, we need to do this...
	[text release];
	[super dealloc];
}

- (NSString *)string
{
	return [text string];
}

- (NSDictionary *)attributesAtIndex:(unsigned)index effectiveRange:(NSRangePointer)aRange
{
	return [text attributesAtIndex:index effectiveRange:aRange];
}

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{
	int strlen = [aString length];
	int oldWordCount = wordCount;
	
	NSRange wcRange = [self wordRangeForCharRange:aRange];
	wordCount -= [self wordCountForRange:wcRange];
	NSRange changedRange = NSMakeRange(wcRange.location,
									   (wcRange.length - aRange.length) + strlen);

	// UPDATE 13/08/06: word count is updated BEFORE edited:range:changeInLength: is called. The latter method causes the
	// didProcessEditing notifications to get sent, so we must update the word count before then in case any observers
	// of those notifications want to get an accurate word count from us.
	[text replaceCharactersInRange:aRange withString:aString];
	wordCount += [self wordCountForRange:changedRange];

	int lengthChange = strlen - aRange.length;
	[self edited:NSTextStorageEditedCharacters
		   range:aRange
  changeInLength:lengthChange];
	
	// UPDATE 17/03/07: Added a user info dictionary, so that observers can register to find out how many words are typed during any given session.
	[[NSNotificationCenter defaultCenter] postNotificationName:KBTextStorageStatisticsDidChangeNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																[NSNumber numberWithInt:((int)wordCount-oldWordCount)], @"ChangedWordsCount",
																[NSNumber numberWithInt:lengthChange], @"ChangedCharactersCount",
																nil]];
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange
{
	[text setAttributes:attributes range:aRange];
	
	[self edited:NSTextStorageEditedAttributes
		   range:aRange
  changeInLength:0];
}

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)aRange
{
	[text addAttribute:name value:value range:aRange];
	[self edited:NSTextStorageEditedAttributes
		   range:aRange
  changeInLength:0];
}

// the following are additions by James Hoover for Bean ( 20 July 2007 )

//	a text attachment inserted at the start of a paragraph will strip the paragraph's paragraphStyle, since
//				the attachment probably has no style and the rest of the paragraph is changed to match through
//				the fixAttributes... messages. Since this is probably not what the user intended, we overlay the 
//				textAttributes of the following character onto the attachment before it is inserted, in effect
//				reversing the usual behavior 19 July 2007
- (void)replaceCharactersInRange:(NSRange)aRange withAttributedString:(NSAttributedString *)attributedString

{
	//if an attachment is being inserted
	if ([[attributedString string] isEqualToString:[NSString stringWithFormat:@"%C", NSAttachmentCharacter]])
	{
		NSMutableAttributedString *mas = nil;
		//if there are saved typingAttributes (there should be)
		if ([self oldAttributes])
		{
			mas = [attributedString mutableCopy];
			//add the attributes to the attributedString to insert
			if (mas)
			{
				[mas addAttributes:[self oldAttributes] range:NSMakeRange(0,1)];
			}	
		}
		//insert the string with added attributes
		if (mas)
		{
			[super replaceCharactersInRange:aRange withAttributedString:mas];
		}
		//if things didn't work out for some reason, just do the usual thing
		else
		{
			[super replaceCharactersInRange:aRange withAttributedString:attributedString];
		}
		//copies have to be released
		[mas release];
	}			
	//if not an attachment, let super do the usual thing 
	else
	{
		[super replaceCharactersInRange:aRange withAttributedString:attributedString];
	}
}

-(NSDictionary *)oldAttributes {
	return oldAttributes;
}

//	typingAttributes are retained (sent in from the textView's delegate) whenever the insertion point
//			in the textView changes from one location to another with an accompanying change in typingAttributes
- (void)setOldAttributes:(NSDictionary*)someAttributes {
	[someAttributes retain];
	[oldAttributes release];
	oldAttributes = someAttributes;
}

//look for attachment characters isolated from text (that is, in its own paragraph) and make single space, because
//			double space etc. looks bad and might confuse the user
- (void)fixAttachmentAttributeInRange:(NSRange)aRange
{
	//	I'm not sure which is better: 1) looking for attachment or newline characters in shouldChangeText and then setting an accessor here to either skip the following code or not, or 2) to do what I've done here: make a pointer to [self string] and get characterAtIndex
	//	Probably they're about the same, since I think no string is being created in either case, just pointers (assumption based on looking at the GnuStep [x string:] method of NSAttributedString.m, which may be an incorrect assumption 30 July 2007 JH

	int rLoc = aRange.location;
	int rLen = aRange.length;
	//	mutable attributed string length
	int masLen = [self length];
	//	string version of this mutable attributed class
	NSString *s = nil;
	
	//	make attachment single spaced if sandwiched between newLine characters
	
	s = [self string];
	//	prevent out of bounds
	if (rLoc < masLen)
	{
		unichar c = [s characterAtIndex:rLoc];
		// if first inserted chracter is attachment
		if (c == attachmentChar) 
		{
			if (rLoc > 0) //	prevent out of bounds
			{
				unichar p = [s characterAtIndex:rLoc - 1];
				//	if previous character was a newLine
				if (p == newLineChar)
				{
					if (rLoc + rLen < masLen) //	prevent out of bounds
					{
						unichar f = [s characterAtIndex:rLoc + 1];
						{
							//	if following character is newLine
							if (f == newLineChar)
							{
								//	make attachment single spaced
								[self fixLineHeightForImageWithIndex:rLoc];
							}
						}
					}
				}
			}
			//	added so image at loc==0 that is alone in a paragraph will retain single spacing upon being resized (6 Aug 2007 JH) 
			//	special case: attachment is first character
			if (rLoc == 0 && masLen > 1)
			{
				unichar fc = [s characterAtIndex:rLoc + 1]; //	following character
				if (fc == newLineChar)
				{
					//	make attachment single spaced
					[self fixLineHeightForImageWithIndex:rLoc];
				}
			}
		}
		//if first inserted character is newLine
		if (c == newLineChar) 
		{
			if (rLoc > 1) //prevent out of bounds
			{
				unichar pa = [s characterAtIndex:rLoc - 1];
				unichar pb = [s characterAtIndex:rLoc - 2];
				//if newLine + attachment precede
				if (pa == attachmentChar && pb == newLineChar)
				{
					//make attachment single spaced
					[self fixLineHeightForImageWithIndex:rLoc - 1];
				}
			}
			if (rLoc + 2 < masLen) //prevent out of bounds
			{
				unichar pc = [s characterAtIndex:rLoc + 1];
				unichar pd = [s characterAtIndex:rLoc + 2];
				//if attachment + newLine follow
				if (pc == attachmentChar && pd == newLineChar)
				{
					//make attachment single spaced
					[self fixLineHeightForImageWithIndex:rLoc + 1];
				}
			}
			//special case (at beginning of doc)
			if (rLoc == 1)
			{
				unichar pa = [s characterAtIndex:rLoc - 1];
				//if newLine is preceded by attachment at start of doc
				if (pa == attachmentChar)
				{
					//make it single spaced
					[self fixLineHeightForImageWithIndex:rLoc - 1];
				}
			}
		}
	}
	s = nil;
	[super fixAttachmentAttributeInRange:aRange]; 
}

//single spaces the lineHeight of an attachment when it's alone in a paragraph
- (void) fixLineHeightForImageWithIndex:(int)index
{
	NSMutableParagraphStyle *theParagraphStyle = nil;
	NSParagraphStyle *aParagraphStyle = [self attribute:NSParagraphStyleAttributeName atIndex:index effectiveRange:NULL];
	theParagraphStyle = [aParagraphStyle mutableCopy];
	[theParagraphStyle setLineHeightMultiple:1.0];
	// check to prevent nil value error
	if (theParagraphStyle) [self addAttribute:NSParagraphStyleAttributeName value:theParagraphStyle range:NSMakeRange(index, 1)];
	[theParagraphStyle release];
}

@end


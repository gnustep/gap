//
//  KBWordCountingTextStorage.h
//  ---------------------------
//
//  (c) Keith Blount 2005
//
//	A simple text storage subclass that provides a live word count, and ensures that no more
//	attributes than necessary get stripped in -fixAttachmentAttributeInRange:.
//

#import <Cocoa/Cocoa.h>

extern NSString *KBTextStorageStatisticsDidChangeNotification;

@interface KBWordCountingTextStorage : NSTextStorage
{
	NSMutableAttributedString *text;
	NSDictionary *oldAttributes; // JH addition for Bean
	unsigned wordCount;
}

/* Restore text with word count intact */
- (id)initWithAttributedString:(NSAttributedString *)aString wordCount:(unsigned)wc;

/* Word count accessor */
- (unsigned)wordCount;

// additions by James Hoover for Bean :: 20 July 2007 //

/* Used when inserting attachments, to preserve paragraph attributes, etc. */
- (NSDictionary *)oldAttributes;
- (void)setOldAttributes:(NSDictionary*)someAttributes;
- (void) fixLineHeightForImageWithIndex:(int)index;
	
@end

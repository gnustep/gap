/* All Rights reserved */

#include <AppKit/AppKit.h>
#include "GoDocument.h"

@interface GoDocumentInspector : NSObject
{
	GoDocument *_document;

	id blackPlayerButton;
	id inspectorPanel;
	id boardSizeChooser;
	id whitePlayerButton;
	id handicapStepper;
	id handicapText;
	id komiStepper;
	id komiText;
	id turnText;
	id showHistory;
	id revertButton;
	id applyButton;
}
- (void) setShowHistory: (id)sender;
- (void) setPlayer: (id)sender;
- (void) apply: (id)sender;
- (void) revert: (id)sender;
@end

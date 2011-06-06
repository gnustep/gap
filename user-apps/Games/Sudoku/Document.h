#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "SudokuView.h"
#define DOCTYPE  @"sudoku"

@interface Document : NSDocument
{
    SudokuView *sdkview;
    NSArray *lines;
}

- init;

- (NSData *)dataRepresentationOfType:(NSString *)aType;
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType;

- (void)makeWindowControllers;
- (void)windowControllerDidLoadNib:(NSWindowController *)aController;

- (Sudoku *)sudoku;
- (SudokuView *)sudokuView;

- resetPuzzle:(id)sender;
- solvePuzzle:(id)sender;


@end

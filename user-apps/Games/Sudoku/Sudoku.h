
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#define NBCOUNT (8+8+4)

#define EX_COMPLETE @"SudokuCompleted"
#define EX_LOOP     @"SudokuLoop"

#define EX_COMPLETE_FMT @"Sudoku completed."
#define EX_LOOP_FMT     @"Solver entered a loop."

typedef enum {
    FIELD_VALUE = 0,
    FIELD_PUZZLE,
    FIELD_GUESS,
    FIELD_SCORE
} FIELD_TYPE;

typedef struct _field {
    int value, puzzle, guess;

    int x, y;

    void *nbdigits[9];
    int score;

    struct {
	int nx, ny;
    } adj[NBCOUNT];
} field, *fieldptr; 


#define SDK_DIM (9*FIELD_DIM)

typedef struct {
  int x, y, checked;
} seqstruct;

typedef struct {
  int x, y;
  int value;
} cluestruct;

@interface Sudoku : NSObject
{
    field data[9][9];

    seqstruct seq[9*9];

    BOOL success;
    int placed;

    int allclues;
    cluestruct clues[9*9];
}

- init;

- (seqstruct)seq:(int)pos;
- (cluestruct)clue:(int)pos;


- (int)retrX:(int)x Y:(int)y;

- (int)valueX:(int)x Y:(int)y;
- (int)puzzleX:(int)x Y:(int)y;
- (int)guessX:(int)x Y:(int)y;

- (field)fieldX:(int)x Y:(int)y;
- (fieldptr)fieldptrX:(int)x Y:(int)y;


- (int)computescore:(fieldptr)fp;
- (BOOL)completed;

- (NSString *)stateToString:(FIELD_TYPE)what;
- stateFromLineEnumerator:(NSEnumerator *)en what:(FIELD_TYPE)what;

- (BOOL)selectClues;
- (BOOL)find;
- doFind:(NSMutableSet *)seen;

- (NSString *)checkSequence;

- (int)setClues:(int)count;
- (int)clues;

- reset;
- loadSolution;

- copyStateFromSource:(Sudoku *)src;
- guessToClues;
- cluesToPuzzle;

@end

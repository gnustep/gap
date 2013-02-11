#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "Document.h"
#import "BTree.h"

// #define PIECE_WIDTH  48 // must be even
// #define PIECE_HEIGHT 40 // must be even

// used to be constant
#define PIECE_WIDTH  piece_width // must be even
#define PIECE_HEIGHT piece_height // must be even

#define PIECE_WIDTH_SMALL  48 // must be even
#define PIECE_HEIGHT_SMALL 40 // must be even

#define PIECE_WIDTH_MEDIUM  64 // must be even
#define PIECE_HEIGHT_MEDIUM 52 // must be even

#define PIECE_WIDTH_LARGE  80 // must be even
#define PIECE_HEIGHT_LARGE 64 // must be even

// #define BOUNDARY     16
// #define OFFS          8

#define BOUNDARY_SMALL  16
#define OFFS_SMALL       8

#define BOUNDARY_MEDIUM 20
#define OFFS_MEDIUM     10

#define BOUNDARY_LARGE  24
#define OFFS_LARGE      12

#define BOUNDARY \
(piece_width==PIECE_WIDTH_SMALL ? BOUNDARY_SMALL : \
(piece_width==PIECE_WIDTH_MEDIUM ? BOUNDARY_MEDIUM : BOUNDARY_LARGE))

#define OFFS \
(piece_width==PIECE_WIDTH_SMALL ? OFFS_SMALL : \
(piece_width==PIECE_WIDTH_MEDIUM ? OFFS_MEDIUM : OFFS_LARGE))


#define RADSQ        ((CGFloat)(BOUNDARY*BOUNDARY/4))

#define PIECE_BD_WIDTH  (2*BOUNDARY+PIECE_WIDTH)
#define PIECE_BD_HEIGHT (2*BOUNDARY+PIECE_HEIGHT)

#define DIM_MAX      32
#define DIM_MIN       3

enum {
    INNER = -1,
    BORDER,
    OUTER
};
typedef NSInteger BTYPE; 

enum {
    EXTERIOR,
    LEFTIN, LEFTOUT,
    RIGHTIN, RIGHTOUT,
    LOWERIN, LOWEROUT,
    UPPERIN, UPPEROUT,
    CENTER
};
typedef NSInteger PTYPE;

@interface PieceView : NSView
{
    Document *doc;

    NSImage *image, *complete;

    BTree *cluster;
    NSInteger x, y, px, py;
    BTYPE left, right, upper, lower;
    NSInteger padleft, padright, padupper, padlower;

    NSBezierPath *clip, *boundary;

    NSInteger tag;
    NSInteger done;

    NSInteger piece_width, piece_height;
}

+ (id *)checkCluster:(BTree *)theCluster
		dimX:(NSInteger)dimx
		dimY:(NSInteger)dimy;

+ (BTree *)doJoin:(BTree *)cluster and:(BTree *)ccluster
              all:(NSMutableArray *)allClusters;

- (id)initWithImage:(NSImage *)theImage
	       dimX:(NSInteger)dimx
	       dimY:(NSInteger)dimy
                loc:(NSPoint)theLoc
               posX:(NSInteger)posx outOf:(NSInteger)px
               posY:(NSInteger)posy outOf:(NSInteger)py
               left:(BTYPE)bleft
              right:(BTYPE)bright
              upper:(BTYPE)bupper
              lower:(BTYPE)blower;

- setCluster:(BTree *)theCluster;
- (BTree *)cluster;

- setDocument:(Document *)theDocument;
- (Document *)document;

- (NSInteger)setDone:(NSInteger)dflag;

- (void)drawRect:(NSRect)aRect;
- (void)outline:(CGFloat *)delta;

- (void)showInvalid;

- (void)bbox:(NSRect *)bbox;

- (void)shiftView:(CGFloat *)delta;

- (BTYPE)left;
- (BTYPE)right;
- (BTYPE)upper;
- (BTYPE)lower;

- (NSInteger)tag;

- (NSInteger)x;
- (NSInteger)y;

- (PTYPE)classifyPoint:(NSPoint)pt;

- (void)extractFromCluster;
- (void)splitCluster;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)rightMouseDown:(NSEvent *)theEvent;

- (NSString *)toString;

@end


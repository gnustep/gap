/* 
   Project: Sudoku
   Sudoku.m

   Copyright (C) 2007-2011 The Free Software Foundation, Inc

   Author: Marko Riedel

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import "Sudoku.h"
#import "DigitSource.h"

@implementation Sudoku

- (int)computescore:(fieldptr)fp
{
    int d, res = 0;

    for(d=0; d<9; d++){
	if(fp->nbdigits[d] != NULL){
	    res++;
	}
    }
 
    fp->score = res;
    return res;
}

#define RETR(_x, _y) \
(data[_x][_y].puzzle==-1 ? data[_x][_y].guess : data[_x][_y].puzzle)

- (int)retrX:(int)x Y:(int)y
{
  return 
    (data[x][y].puzzle==-1 ? data[x][y].guess : data[x][y].puzzle);
}

- (BOOL)completed
{
  int x, y;
  
  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
      if(RETR(x, y)==-1){
	return NO;
      }
    }
  }
   
  return YES;
}

- init
{
  int x, y, pos;

  allclues = 0;
  for(x=0; x<9; x++)
    {
      for(y=0; y<9; y++)
	{
	  data[x][y].value = -1;
	  data[x][y].guess = -1;
	  data[x][y].puzzle = -1;
	}
    }

    // adjaceny
    for(x=0; x<9; x++){
	for(y=0; y<9; y++){
	    int n = 0;
	    int zx, zy;

	    for(pos=0; pos<9; pos++){
		if(pos!=y){
		    data[x][y].adj[n].nx = x;
		    data[x][y].adj[n].ny = pos;

		    n++;
		}
	    }

	    for(pos=0; pos<9; pos++){
		if(pos!=x){
		    data[x][y].adj[n].nx = pos;
		    data[x][y].adj[n].ny = y;

		    n++;
		}
	    }
      
	    zx = x/3;
	    zy = y/3;
	    for(pos=0; pos<9; pos++){
		int zzx = 3*zx + pos/3, zzy = 3*zy + pos%3; 
		if(zzx!=x && zzy!=y){
		    data[x][y].adj[n].nx = zzx;
		    data[x][y].adj[n].ny = zzy;

		    n++;
		}
	    }

	    assert(n == NBCOUNT);
	}
    }

    return self;
}

- (int)valueX:(int)x Y:(int)y
{
  return data[x][y].value;
}

- (int)puzzleX:(int)x Y:(int)y
{
  return data[x][y].puzzle;
}

- (int)guessX:(int)x Y:(int)y
{
  return data[x][y].guess;
}

- (field)fieldX:(int)x Y:(int)y
{
  return data[x][y];
}

- (fieldptr)fieldptrX:(int)x Y:(int)y
{
  return &(data[x][y]);
}

- (seqstruct)seq:(int)pos
{
  return seq[pos];
}

 
- (cluestruct)clue:(int)pos
{
  return clues[pos];
}


- (NSString *)stateToString:(FIELD_TYPE)what
{
    NSString *res = @"";

    int x, y;
    
    for(y=0; y<9; y++){
        for(x=0; x<9; x++){
	    int outval;
	    if(what==FIELD_VALUE){
		outval = data[x][y].value;
	    }
	    else if(what==FIELD_PUZZLE){
		outval = data[x][y].puzzle;
	    }
	    else if(what==FIELD_GUESS){
		outval = data[x][y].guess;
	    }
	    else{
		[self computescore:&(data[x][y])];
		outval = data[x][y].score;
	    }

            res = 
                [res stringByAppendingFormat:
                         (x>0 ? @" %c" : @"%c"),
                     (outval==-1 ? '.' : 
		      ((what==FIELD_SCORE ? '0' : '1') + outval))];
        }
        res = [res stringByAppendingString:@"\n"];
    }

    return res;
}

- stateFromLineEnumerator:(NSEnumerator *)en what:(FIELD_TYPE)what
{
    int x, y;

    for(y=0; y<9; y++){
	NSString *line = [en nextObject];
	NSArray *fields = 
	  [line componentsSeparatedByString:@" "];
	NSEnumerator *fieldenum = [fields objectEnumerator];

        for(x=0; x<9; x++){
	  NSString *field = [fieldenum nextObject];
	  NSScanner *scn = 
	    [NSScanner scannerWithString:field];

	  int inval = -1;
	  if([field isEqualToString:@"."]==NO){
	    [scn scanInt:&inval];
	  }

	  if(what==FIELD_VALUE){
	    data[x][y].value = inval-1;
	  }
	  else if(what==FIELD_PUZZLE){
	    data[x][y].puzzle = 
	      (inval==-1 ? -1 : inval-1);
	  }
	  else if(what==FIELD_GUESS){
	    data[x][y].guess = 
	      (inval==-1 ? -1 : inval-1);
	  }
	  else{
	    data[x][y].score = inval;
	  }
	}
    }

    // skip separator
    // NSLog(@"sep <%@>", [en nextObject]);
    [en nextObject];
    return self;
}

#define RAND_DIST 35

- (BOOL)selectClues
{
  int pos, x, y, randpl = 0;

  BOOL initial[9][9];
  int present[9];

  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
      initial[x][y] = NO;
    }
  }

  while(randpl<allclues){
    int lx = lrand48()%9, ly = lrand48()%9;

    if(initial[lx][ly]==NO){
      initial[lx][ly] = YES;
      randpl++;
    }
  }

  if(allclues<=RAND_DIST){
    for(x=0; x<9; x++){
      int count = 0;
      for(pos=0; pos<9; pos++){
	if(initial[x][pos]==YES){
	  count++;
	}
      }

      if(count>=8){
	return NO;
      }
    }

    for(y=0; y<9; y++){
      int count = 0;
      for(pos=0; pos<9; pos++){
	if(initial[pos][y]==YES){
	  count++;
	}
      }

      if(count>=8){
	return NO;
      }
    }
      

    for(x=0; x<3; x++){
      for(y=0; y<3; y++){
	int e, f, count = 0;
	
	for(e=0; e<3; e++){
	  for(f=0; f<3; f++){
	    if(initial[3*x+e][3*y+f]==YES){
	      count++;
	    }
	  }
	}
	
	if(count>=8){
	  return NO;
	}
      }
    }
  }

  randpl=0;
  while(randpl<allclues){
    for(x=0; x<9; x++){
      for(y=0; y<9; y++){
	if(initial[x][y]==YES){
	  clues[randpl].x = x;
	  clues[randpl].y = y;
	  clues[randpl].value = data[x][y].value;
	  randpl++;
	}
      }
    }
  }

  for(pos=0; pos<9; pos++){
    present[pos] = 0;
  }


  for(randpl=0; randpl<allclues; randpl++){
    present[clues[randpl].value]++;
  }

  for(pos=0; pos<9; pos++){
    if(!(present[pos])){
      return NO;
    }
  }

  return YES;
}


- (BOOL)find
{
  int x, y, pos;
  const char *marker = "ClueMarker";
  NSAutoreleasePool *pool;
  NSMutableSet *set;

  success = NO;
  placed = allclues;

  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
      data[x][y].x = x;
      data[x][y].y = y;

      data[x][y].value = -1;
      // data[x][y].puzzle = -1;
      // data[x][y].guess = -1;

      for(pos=0; pos<9; pos++){
	  data[x][y].nbdigits[pos] = NULL;
      }
    }
  }

  for(pos=0; pos<9*9; pos++){
    seq[pos].x = -1;
    seq[pos].y = -1;
    seq[pos].checked = 0;
  }

  for(pos=0; pos<allclues; pos++){
    int nb, d;

    x = clues[pos].x; y = clues[pos].y;

    seq[pos].x = x; seq[pos].y = y; 
    seq[pos].checked = 0;

    d = clues[pos].value;
    data[x][y].value = d;
    for(nb=0; nb<NBCOUNT; nb++){
      int 
        nbx = data[x][y].adj[nb].nx,
        nby = data[x][y].adj[nb].ny;

      data[nbx][nby].nbdigits[d] = &marker;
    }
  }

  pool = [NSAutoreleasePool new];
  set = [NSMutableSet setWithCapacity:128];

  NS_DURING

      [self doFind:set];

  NS_HANDLER

      if([[localException name] isEqualToString:EX_COMPLETE]==YES){
	  success = YES;
      }

  NS_ENDHANDLER

      RELEASE(pool);
      
  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
      [self computescore:&(data[x][y])];
    }
  }

  return success;
}

int comparefieldptrs(const void *a, const void *b)
{
  fieldptr 
      ap = *(fieldptr *)a, 
      bp = *(fieldptr *)b;

  if(ap->score < bp->score){
      return +1;
  }
  else if(ap->score > bp->score){
      return -1;
  }
  
  return 0;
}

- doFind:(NSMutableSet *)seen
{
  NSString *dataStr = [self stateToString:FIELD_VALUE];
  int rest;
  fieldptr buf[9*9];
  fieldptr *bPtr;
  int x, y;
  int score;
  int range;
  int mx;
  int pos, d;

  if(placed==9*9){
    // NSLog(@"--\n%@", dataStr);
    // NSLog(@"--\n%@", scoreStr);
 
      [NSException raise:EX_COMPLETE format:EX_COMPLETE_FMT];
      return self; // not reached
  }

    if([seen containsObject:dataStr]==YES){
	[NSException raise:EX_LOOP format:EX_LOOP_FMT];
	return self; // not reached
    }
    [seen addObject:dataStr];

  rest = 9*9-placed;

  bPtr = buf;


  for(x=0; x<9; x++){
      for(y=0; y<9; y++){
	  fieldptr loc = &(data[x][y]);

	  [self computescore:loc];
          if(data[x][y].value == -1){
              *bPtr++ = loc;
          }
      }
  }
  qsort(buf, rest, sizeof(fieldptr), comparefieldptrs);
  // NSLog(@"--\n%@", dataStr);
  // NSLog(@"--\n%@", scoreStr);

  score = buf[0]->score;
  range = 1;
  mx = 0;

  while(range<rest && buf[range]->score==score){
    range++;
  }

  if(range>1){ // permute
    for(mx=range; mx>1; mx--){
      int ind = lrand48() % mx;

      fieldptr tmp;

      tmp = buf[ind];
      buf[ind] = buf[mx-1];
      buf[mx-1] = tmp;
    }
  }
  
  for(pos=0; pos<rest; pos++){
    fieldptr fp = buf[pos];
    int x = fp->x, y = fp->y;

    for(d=0; d<9; d++){
	if(fp->nbdigits[d]==NULL){
	  int nb;

	  seq[placed].x = x;
	  seq[placed].y = y;
	  seq[placed].checked++;

	    placed++;
	    data[x][y].value = d;

	    for(nb=0; nb<NBCOUNT; nb++){
		int nbx = data[x][y].adj[nb].nx,
		    nby = data[x][y].adj[nb].ny;
		if(data[nbx][nby].nbdigits[d] == NULL){
		    data[nbx][nby].nbdigits[d] = buf;
		}
	    }

            [self doFind:seen];
	
	    for(nb=0; nb<NBCOUNT; nb++){
		int nbx = data[x][y].adj[nb].nx,
		    nby = data[x][y].adj[nb].ny;
		if(data[nbx][nby].nbdigits[d] == buf){
		    data[nbx][nby].nbdigits[d] = NULL;
		}
	    }

	    data[x][y].value = -1;
	    placed--;
	}
    }
  }


  // [seen removeObject:dataStr];
  return self;
}

- (int)setClues:(int)count
{
    int prev = allclues;
    allclues = count;
    return prev;
}

- (int)clues
{
    return allclues;
}

- reset
{
  int x, y;

  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
      data[x][y].guess = -1;
    }
  }

  return self;
}  

- loadSolution
{
  int x, y;

  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
	if(data[x][y].puzzle==-1){
	    data[x][y].guess = data[x][y].value;
	}
    }
  }

  return self;    
}

- (NSString *)checkSequence
{
  char buf[9*9+1];
  int pos;
  
  for(pos=0; pos<9*9; pos++){
    buf[pos] = '0' + seq[pos].checked;
  }
  buf[pos] = 0;

  return [NSString stringWithCString:buf];
}

- cluesToPuzzle
{
  int pos;

  for(pos=0; pos<allclues; pos++){
    int x = clues[pos].x, y = clues[pos].y,
      val = clues[pos].value;

    data[x][y].puzzle = val;
  }

  return self;
}

- guessToClues
{
  int pos = 0;

  int x, y;
  
  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
	int val = data[x][y].guess;
	
	if(val!=-1){
	    clues[pos].x = x;
	    clues[pos].y = y;
	    clues[pos].value = val;

	    data[x][y].guess = -1;
	    data[x][y].puzzle = val;

	    pos++;
	}
    }
  }

  allclues = pos;

  return self;
}

- copyStateFromSource:(Sudoku *)src
{
  int x, y;
  int pos;

  for(x=0; x<9; x++){
    for(y=0; y<9; y++){
      data[x][y] = [src fieldX:x Y:y];
    }
  }
  
  for(pos=0; pos<9*9; pos++){
    seq[pos] = [src seq:pos];
  }

  allclues = [src clues];
  for(pos=0; pos<9*9; pos++){
    clues[pos] = [src clue:pos];
  }

  return self;
}

@end

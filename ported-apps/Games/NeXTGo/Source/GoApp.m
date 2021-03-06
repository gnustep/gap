/*
                GNU GO - the game of Go (Wei-Chi)
                Version 1.1   last revised 3-1-89
           Copyright (C) Free Software Foundation, Inc.
                      written by Man L. Li
                      modified by Wayne Iba
                    documented by Bob Webber
                    NeXT version by John Neil
*/
/*
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation - version 1.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License in file COPYING for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

Please report any bug/fix, modification, suggestion to

mail address:   Man L. Li
                Dept. of Computer Science
                University of Houston
                4800 Calhoun Road
                Houston, TX 77004

e-mail address: manli@cs.uh.edu         (Internet)
                coscgbn@uhvax1.bitnet   (BITNET)
                70070,404               (CompuServe)

For the NeXT version, please report any bug/fix, modification, suggestion to

mail address:   John Neil
                Mathematics Department
                Portland State University
                PO Box 751
                Portland, OR  97207

e-mail address: neil@math.mth.pdx.edu  (Internet)
                neil@psuorvm.bitnet    (BITNET)
*/

#include "comment.header"
 
/* Generated by Interface Builder */

/* $Id: GoApp.m,v 1.3 2005/04/06 00:48:05 gcasa Exp $ */

/*
 * $Log: GoApp.m,v $
 * Revision 1.3  2005/04/06 00:48:05  gcasa
 * Fixed server command crash.
 *
 * Revision 1.2  2005/04/06 00:32:58  gcasa
 * Cleaned up the code.
 *
 * Revision 1.1  2003/01/12 04:01:52  gcasa
 * Committing the entire GNU Go and NeXT Go application to the repository.
 * See COPYING file for GNU License.
 *
 * Revision 1.4  1997/11/04 16:50:42  ergo
 * ported to OpenStep
 *
 * Revision 1.3  1997/07/06 19:37:57  ergo
 * actual version
 *
 * Revision 1.5  1997/06/03 23:00:58  ergo
 * changed the appearance of the windows
 *
 * Revision 1.4  1997/05/30 18:44:15  ergo
 * Added an Inspector
 *
 * Revision 1.3  1997/05/04 18:56:53  ergo
 * added time control for moves
 *
 */

#import <AppKit/AppKit.h>
#import <AppKit/NSPrintInfo.h>

/*   the following is included for the definition of fd_set below  */
#include <sys/types.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <sys/time.h>

#include <string.h>
#import "GoApp.h"
#import "Board.h"
#import "ClickCell.h"
#import "GoServer.h"
#include "igs.h"
#include "godict.h"

#include <math.h>

#define CURRENT_VERSION	"Version 3.0"

unsigned char p[19][19], l[19][19], ma[19][19], ml[19][19];
char special_characters[19][19], sgComment[2000], sgNodeName[200];
int hist[19][19], currentMoveNumber;
int rd, lib, play, pass, handicap, MAXX, MAXY;
int currentStone, opposingStone, blackCaptured, whiteCaptured;
int blackTerritory, whiteTerritory, SmartGoGameFlag, initialization;
float black_Score, white_Score;
int blackCapturedKoI, blackCapturedKoJ, whiteCapturedKoI, whiteCapturedKoJ;
int bothSides, neitherSide, blackPassed, whitePassed, manScoreTemp;
BOOL typeOfScoring, manualScoring, AGAScoring;
int opn[9];                               // opening pattern flag
BOOL gameType;
BOOL finished, whiteSide, blackSide, printBold;
gameHistory gameMoves[500];
int lastMove, boardChanged;
BOOL scoringGame, resultsDisplayed;
node *SGgameMoves, *currentNode, *rootNode;
FILE *smartGoInputFile;
char *SGfile, *currentSGfilePosition;
char *IGSStatusText, IGSPasswordText[20], IGSLoginText[20];
GODICT *godict;

char *getpassword(void) {
	return IGSPasswordText;
}

char *getloginname(void) {
	return IGSLoginText;
}

void IGSSendString(char *s) {

	sendstr(s);
	printBold = YES;
	[(GoApp *)NSApp SetIGSStatus:s];

}

void stripChar(char *s, char c) {
	int i, j;

	i = 0;
	while (i < strlen(s)) {
		if (s[i] == c) {
	  		for (j = i; j < strlen(s) - 1; j++)
	    		s[j] = s[j+1];
	  		s[strlen(s) - 1] = 0;
		}
      	else {
	  		i++;
		}
    }
}

int saveNeXTGoFile(const char *fileName)
{
  FILE *NGoFile;
  int i, j;

  if ((NGoFile = fopen(fileName, "w")) == NULL)
    return 1;

  fprintf(NGoFile, "%d\n", handicap);
  fprintf(NGoFile, "%d\n", whiteSide);
  fprintf(NGoFile, "%d\n", blackSide);
  fprintf(NGoFile, "%d\n", MAXX);
  fprintf(NGoFile, "%d\n", MAXY);
  fprintf(NGoFile, "%d\n", currentStone);
  fprintf(NGoFile, "%d\n", opposingStone);
  fprintf(NGoFile, "%d\n", blackCaptured);
  fprintf(NGoFile, "%d\n", whiteCaptured);
  fprintf(NGoFile, "%d\n", blackCapturedKoI);
  fprintf(NGoFile, "%d\n", blackCapturedKoJ);
  fprintf(NGoFile, "%d\n", whiteCapturedKoI);
  fprintf(NGoFile, "%d\n", whiteCapturedKoJ);
  fprintf(NGoFile, "%d\n", bothSides);
  fprintf(NGoFile, "%d\n", neitherSide);
  fprintf(NGoFile, "%d\n", blackPassed);
  fprintf(NGoFile, "%d\n", whitePassed);
  fprintf(NGoFile, "%d\n", lastMove);
  for (i = 0; i < 9; i++)
    fprintf(NGoFile, "%d\n", opn[i]);
  for (i = 0; i < lastMove; i++)
    {
      fprintf(NGoFile, "%d\n", gameMoves[i].numchanges);
      fprintf(NGoFile, "%d\n", gameMoves[i].blackCaptured);
      fprintf(NGoFile, "%d\n", gameMoves[i].whiteCaptured);
      for (j = 0; j < gameMoves[i].numchanges; j++)
	{
	  fprintf(NGoFile, "%d\n", gameMoves[i].changes[j].added);
	  fprintf(NGoFile, "%d\n", gameMoves[i].changes[j].color);
	  fprintf(NGoFile, "%d\n", gameMoves[i].changes[j].x);
	  fprintf(NGoFile, "%d\n", gameMoves[i].changes[j].y);
	}
    }

  fclose(NGoFile);

  return 0;
}

int saveSmartGoFile(const char *fileName)
{
  FILE *NGoFile;
  int i, j;

  if ((NGoFile = fopen(fileName, "w")) == NULL)
    return 1;
  fprintf(NGoFile, "(\n;\nGaMe[1]\nVieW[]\n");
  fprintf(NGoFile, "SiZe[%d]\nKoMi[%3.1f]\nHAndicap[%d]", MAXX,
	  ((handicap == 0)?KOMI:0.5), handicap);
  fprintf(NGoFile,"\nComment[ A game between ");

  if (gameType != LOCAL)
    {
      fprintf(NGoFile, "two people on the network.\n\n");
    }
  else if (neitherSide)
    {
      fprintf(NGoFile,"two human players.\n\n");
    }
  else if (bothSides)
    {
      fprintf(NGoFile,"two computer players.\n\n");
    }
  else
    {
      fprintf(NGoFile,"the computer and a human player.\n\n");
    }

  if (finished)
    {
      fprintf(NGoFile,"        Result:  %s wins by %8.1f.]\n",
	      (black_Score > white_Score)?"Black":"White",
	      fabs(black_Score - white_Score));
    }
  else
    {
      fprintf(NGoFile, "]\n");
    }

  if (handicap > 1)
    {
      int q, half;

      q = (MAXX < 13)?2:3;
      half = (MAXX + 1)/2 - 1;

      switch (handicap) {
      case 2:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c]\n", q+'a', MAXY-q-1+'a',
		MAXX-q-1+'a', q+'a');
	break;
      case 3:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c][%c%c]\n", q+'a', MAXY-q-1+'a',
		MAXX-q-1+'a', q+'a', q+'a', q+'a');
	break;
      case 4:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c][%c%c][%c%c]\n", q+'a',
		MAXY-q-1+'a', MAXX-q-1+'a', q+'a', q+'a', q+'a', MAXX-q-1+'a',
		MAXY-q-1+'a');
	break;
      case 5:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c][%c%c][%c%c][%c%c]\n", q+'a',
		MAXY-q-1+'a', MAXX-q-1+'a', q+'a', q+'a', q+'a', MAXX-q-1+'a',
		MAXY-q-1+'a', half+'a', half+'a');
	break;
      case 6:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c][%c%c][%c%c][%c%c][%c%c]\n",
		q+'a', MAXY-q-1+'a', MAXX-q-1+'a', q+'a', q+'a', q+'a',
		MAXX-q-1+'a', MAXY-q-1+'a', q+'a', half+'a', MAXX-q-1+'a',
		half+'a');
	break;
      case 7:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c][%c%c][%c%c][%c%c][%c%c][%c%c]\n",
		q+'a', MAXY-q-1+'a', MAXX-q-1+'a', q+'a', q+'a', q+'a',
		MAXX-q-1+'a', MAXY-q-1+'a', q+'a', half+'a', MAXX-q-1+'a',
		half+'a', half+'a', half+'a');
	break;
      case 8:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c][%c%c][%c%c][%c%c][%c%c][%c%c][%c%c]\n",
		q+'a', MAXY-q-1+'a', MAXX-q-1+'a', q+'a', q+'a', q+'a',
		MAXX-q-1+'a', MAXY-q-1+'a', q+'a', half+'a', MAXX-q-1+'a',
		half+'a', half+'a', q+'a', half+'a', MAXY-q-1+'a');
	break;
      case 9:
	fprintf(NGoFile, "AddBlack[%c%c][%c%c][%c%c][%c%c][%c%c][%c%c][%c%c][%c%c][%c%c]\n",
		q+'a', MAXY-q-1+'a', MAXX-q-1+'a', q+'a', q+'a', q+'a',
		MAXX-q-1+'a', MAXY-q-1+'a', q+'a', half+'a', MAXX-q-1+'a',
		half+'a', half+'a', q+'a', half+'a', MAXY-q-1+'a', half+'a',
		half+'a');
	break;
      }
    }

  for (i = 0; i < lastMove; i++)
    {
      for (j = 0; j < gameMoves[i].numchanges; j++)
	{
	  if (gameMoves[i].changes[j].added)
	    switch (gameMoves[i].changes[j].color)
	      {
	      case 1:
		if (gameMoves[i].changes[j].x >= 0)
		  {
		    fprintf(NGoFile,";\nWhite[%c%c]\n",
			    gameMoves[i].changes[j].x+'a',
			    gameMoves[i].changes[j].y+'a');
		  }
		else
		  {
		    fprintf(NGoFile, ";\nWhite[tt]\n");
		  }
		break;
	      case 2:
		if (gameMoves[i].changes[j].x >= 0)
		  {
		    fprintf(NGoFile,";\nBlack[%c%c]\n",
			    gameMoves[i].changes[j].x+'a',
			    gameMoves[i].changes[j].y+'a');
		  }
		else
		  {
		    fprintf(NGoFile, ";\nBlack[tt]\n");
		  }
		break;
	      }
	}
    }

  fprintf(NGoFile,")\n\n");
  fclose(NGoFile);

  return 0;
}

@implementation GoApp

+ (void)initialize {

    id defaults;
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"Handicap"];
    [defaults setInteger:19 forKey:@"BoardSize"];
    [defaults setBool:YES forKey:@"BlackSide"];
    [defaults setBool:NO forKey:@"WhiteSide"];
    [defaults setBool:YES forKey:@"ManualScoring"];
    [defaults setBool:NO forKey:@"TypeOfScoring"];
    [defaults setBool:NO forKey:@"AGAScoring"];

    [defaults synchronize];

    return;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
//    NSApplication *theApplication = [notification object];
    id defaults;
    char str[80];

    godict = NULL;
    IGSfont = [ [NSFont fontWithName:@"Ohlfs" size:10] retain];
//    IGSboldFont = [ [NSFont fontWithName:@"Ohlfs" size:10] retain];
    IGSboldFont = [ [NSFont fontWithName:@"Helvetica-Bold" size:10] retain];
    [gameWindow setMiniwindowImage:[ [NSImage imageNamed:@"NeXTGoFile"] retain]];
    strcpy(str, "NeXTGo -- ");
    strcat(str, CURRENT_VERSION);
    [versionString setStringValue:[NSString stringWithCString:CURRENT_VERSION]];
    [gameWindow setTitle:[NSString stringWithCString:str]];
    [[IGSStatus documentView] setFont:IGSfont];
    [[smartGoComments documentView] setFont:IGSfont];
//    [controller initPanel];
	
    lastMove = 0;
    gameType = LOCAL;

    defaults = [NSUserDefaults standardUserDefaults];
    handicap 	= [defaults integerForKey:@"Handicap"];
    MAXX 	= [defaults integerForKey:@"BoardSize"];
    blackSide 	= [defaults boolForKey:@"BlackSide"];
    whiteSide 	= [defaults boolForKey:@"WhiteSide"];
    manualScoring = [defaults boolForKey:@"ManualScoring"];
    typeOfScoring = [defaults boolForKey:@"TypeOfScoring"];
    AGAScoring	= [defaults boolForKey:@"AGAScoring"];

    MAXY = MAXX;
    manScoreTemp = manualScoring;

    [handicapSlider setIntValue:handicap];
    [handicapText setIntValue:handicap];
    [sizeSlider setIntValue:MAXX];
    [sizeText setIntValue:MAXX];
    [BlackPlayer selectCellAtRow:blackSide column:0];
    [WhitePlayer selectCellAtRow:whiteSide column:0];
    [scoringMethod selectCellAtRow:manualScoring column:0];
    [scoringType selectCellAtRow:typeOfScoring column:0];
    [AGAscoringMethodFlag setIntValue:AGAScoring];
    [savePrefsFlag setIntValue:1];

    neitherSide = 0;
    bothSides = 0;
    manScoreTemp = manualScoring;

    if (!blackSide && !whiteSide)
    	neitherSide++;
    if (blackSide && whiteSide)
    	bothSides++;

    [self NewGame:self];

    {
        id newVar = [NSPrintInfo sharedPrintInfo];
        [newVar setHorizontallyCentered:YES];
        [newVar setVerticallyCentered:YES];
    }

    [gameWindow setFrameAutosaveName:@"NeXTGoGameWindow"];
    [gameWindow makeKeyAndOrderFront:self];
    [gameInspector setFrameAutosaveName:@"NeXTGoGameInspector"];
    [gameInspector makeKeyAndOrderFront:self];
    [gameWindow makeKeyAndOrderFront:self];
    [IGSPanel setFrameAutosaveName:@"NeXTGoIGSPanel"];

    SmartGoGameFlag = 0;
	
    CommandSender = nil;
}

- showError: (const char *)errorMessage
{
  NSRunAlertPanel(@"NeXTGo Error", [NSString stringWithCString:errorMessage], @"OK", nil, nil);
  return self;
}

- UserPass:sender
{
  if (SmartGoGameFlag)
    return self;

  [MainGoView passMove];

  return self;
}

- stopGame:sender
{
  if (SmartGoGameFlag)
    return self;

  [MainGoView stop:self];

  return self;
}

- startGame:sender {
	
	if (SmartGoGameFlag)
    	return self;

	[MainGoView go:self];

	return self;
}

- NewGame:sender
{
  int resp;

  if (gameType == IGSGAME)
    {
      NSRunAlertPanel(@"IGS Error", @"You must first close your IGS session before\n\
beginning a new game.", @"OK", nil, nil);
      return self;
    }

  if (SmartGoGameFlag)
    {
      SmartGoGameFlag = 0;
      [smartGoPanel close];
    }

  gameType = LOCAL;

  if ((lastMove > 0) && (!finished))
    {
      resp = NSRunAlertPanel(@"NeXTGo Warning", @"A game is in process.  Do you wish to abandon it?", @"Abandon", @"Cancel", nil);

      if (resp == NSAlertAlternateReturn)
	return self;
    }

  [MainGoView startNewGame];
  [MainGoView display];

  lastMove = 0;

  return self;
}

- SetPreferences:sender {

    
	handicap = [handicapSlider intValue];
	MAXX = MAXY = [sizeSlider intValue];
	blackSide = [BlackPlayer selectedRow];
	whiteSide = [WhitePlayer selectedRow];
	manualScoring = [scoringMethod selectedRow];
	typeOfScoring = [scoringType selectedRow];
	AGAScoring = [AGAscoringMethodFlag intValue];

	neitherSide = 0;
	bothSides = 0;
	manScoreTemp = manualScoring;

	if (!blackSide && !whiteSide)
    	neitherSide++;
	if (blackSide && whiteSide)
    	bothSides++;

	[self NewGame:self];

	[prefPanel close];

	if ([savePrefsFlag intValue]) {
            id defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:handicap forKey:@"Handicap"];
            [defaults setInteger:MAXX forKey:@"BoardSize"];
            [defaults setBool:blackSide forKey:@"BlackSide"];
            [defaults setBool:whiteSide forKey:@"WhiteSide"];
            [defaults setBool:manualScoring forKey:@"ManualScoring"];
            [defaults setBool:typeOfScoring forKey:@"TypeOfScoring"];
            [defaults setBool:AGAScoring forKey:@"AGAScoring"];
	}

	return self;
}

- displayNewSGNode
{
  node *var_list, *current_var;

  [smartGoNodeNumber setIntValue:currentNode->nodenum];
  [[smartGoComments documentView] setString:@""];
  [[smartgoVariants documentView] setString:@""];
  [self AddSGComment:sgComment];
  [self SetSGNodeName:sgNodeName];

  [MainGoView display];
  [MainGoView setblacksPrisoners:blackCaptured];
  [MainGoView setwhitesPrisoners:whiteCaptured];

  for (var_list = currentNode->variants; var_list != NULL;
       var_list = var_list->next_var)
    {
      char var_name[80];

      current_var = var_list;
      while (current_var->properties == NULL)
	{
	  current_var = forwardOneNode(current_var);
	}

      sgNodeName[0] = 0;
      buildToNode(current_var);
      if (boardChanged)
	[MainGoView doClick];
      sprintf(var_name, "%d: %s", current_var->nodenum, sgNodeName);
      [self AddSGVariantName:var_name];
    }

  if (currentNode->variants != NULL)
    {
      sgNodeName[0] = 0;
      sgComment[0] = 0;
      buildToNode(currentNode);
      if (boardChanged)
	[MainGoView doClick];
    }

  return self;
}

- stepSmartGoFile:sender
{
  sgComment[0] = 0;
  sgNodeName[0] = 0;

  currentNode = stepForward(currentNode);

  [self displayNewSGNode];

  return self;
}

- stepBackSmartGoFile:sender
{
  sgComment[0] = 0;
  sgNodeName[0] = 0;

  currentNode = stepBackward(currentNode);

  [self displayNewSGNode];

  return self;
}

- jumpSmartGoFile:sender
{
  sgComment[0] = 0;
  sgNodeName[0] = 0;

  currentNode = jumpForward(currentNode);

  [self displayNewSGNode];

  return self;
}

- jumpBackSmartGoFile:sender
{
  sgComment[0] = 0;
  sgNodeName[0] = 0;

  currentNode = jumpBackward(currentNode);

  [self displayNewSGNode];

  return self;
}

- AddSGComment:(char *)s
{
  NSText *docView = [smartGoComments documentView];

  [docView setString:[[docView string] stringByAppendingString:[NSString stringWithCString:s]]];

  [docView selectAll:docView];
  
  [docView scrollRangeToVisible:[docView selectedRange]];

  return self;
}

- AddSGVariantName:(char *)s
{
  NSText *docView = [smartgoVariants documentView];
  NSString *retstr = @"\n", *aString;

  aString = [[[docView string] stringByAppendingString:retstr] stringByAppendingString:[NSString stringWithCString:s]];
  aString = [aString stringByAppendingString:retstr];

  [docView selectAll:docView];

  [docView scrollRangeToVisible:[docView selectedRange]];

  return self;
}

- SetSGNodeName:(char *)s
{
  [smartGoNodeName setStringValue:[NSString stringWithCString:s]];
  [smartGoNodeName display];

  return self;
}

- openNeXTGoFile:(const char*)aFile
{
    FILE *NGoFile;
    int i, j, t, temp;

    if ((NGoFile = fopen(aFile, "r")) == NULL) {
	return self;
    }

    SmartGoGameFlag = 0;
    fscanf(NGoFile, "%d", &handicap);
    fscanf(NGoFile, "%d", &temp);
    whiteSide = temp;
    fscanf(NGoFile, "%d", &temp);
    blackSide = temp;
    fscanf(NGoFile, "%d", &MAXX);
    fscanf(NGoFile, "%d", &MAXY);
    [MainGoView startNewGame];
    fscanf(NGoFile, "%d", &opposingStone);
    fscanf(NGoFile, "%d", &currentStone);
    fscanf(NGoFile, "%d", &blackCaptured);
    fscanf(NGoFile, "%d", &whiteCaptured);
    fscanf(NGoFile, "%d", &blackCapturedKoI);
    fscanf(NGoFile, "%d", &blackCapturedKoJ);
    fscanf(NGoFile, "%d", &whiteCapturedKoI);
    fscanf(NGoFile, "%d", &whiteCapturedKoJ);
    fscanf(NGoFile, "%d", &bothSides);
    fscanf(NGoFile, "%d", &neitherSide);
    fscanf(NGoFile, "%d", &blackPassed);
    fscanf(NGoFile, "%d", &whitePassed);
    fscanf(NGoFile, "%d", &lastMove);
    for (i = 0; i < 9; i++)
      {
        fscanf(NGoFile, "%d", &t);
	opn[i] = t;
      }
    for (i = 0; i < MAXX; i++)
      for (j = 0; j < MAXY; j++)
	p[i][j] = hist[i][j] = 0;

    for (i = 0; i < lastMove; i++)
      {
	fscanf(NGoFile, "%d", &gameMoves[i].numchanges);
	fscanf(NGoFile, "%d", &gameMoves[i].blackCaptured);
	fscanf(NGoFile, "%d", &gameMoves[i].whiteCaptured);
	gameMoves[i].changes = (struct change *)
	  malloc((size_t)sizeof(struct change)*gameMoves[i].numchanges);
	for (j = 0; j < gameMoves[i].numchanges; j++)
	  {
	    fscanf(NGoFile, "%d", &gameMoves[i].changes[j].added);
	    fscanf(NGoFile, "%d", &gameMoves[i].changes[j].color);
	    fscanf(NGoFile, "%d", &gameMoves[i].changes[j].x);
	    fscanf(NGoFile, "%d", &gameMoves[i].changes[j].y);
	  }
      }

    for (i = 0; i < lastMove; i++)
      for (j = 0; j < gameMoves[i].numchanges; j++)
	{
	  if (gameMoves[i].changes[j].added)
	    {
	      p[gameMoves[i].changes[j].x][gameMoves[i].changes[j].y] =
		gameMoves[i].changes[j].color;
	      hist[gameMoves[i].changes[j].x][gameMoves[i].changes[j].y] = i;
	    }
	  else
	    {
	      p[gameMoves[i].changes[j].x][gameMoves[i].changes[j].y] = 0;
	    }
	}
    blackCaptured = gameMoves[lastMove-1].blackCaptured;
    whiteCaptured = gameMoves[lastMove-1].whiteCaptured;

    [MainGoView refreshIO];

    [MainGoView resetButtons];

    fclose(NGoFile);

    [MainGoView lockFocus];
    [[MainGoView window] flushWindow];
    [MainGoView display];
    [MainGoView unlockFocus];

    // PSWait();

    return self;
}

- initTranslator:sender {
    char filename[MAXPATHLEN+1];
    NSBundle   *bundle;

    bundle = [NSBundle bundleForClass:[self class]];
    strcpy(filename, [[bundle bundlePath] cString] );
    strcat(filename,"/Resources/");
    strcat(filename,DEFDICT);

    if (godict == NULL) {
        godict = load_dict(filename);

      if (godict == NULL)
	{
	  NSRunAlertPanel(@"Translate Error", @"There is a problem opening the dictionary file.", @"OK", nil, nil);
	  return self;
	}
    }

  [translateWindow makeKeyAndOrderFront:self];
  [translateWindow setMiniwindowImage:[NSImage imageNamed:@"NeXTGoFile"]];
  [translateWindow display];
  [translateTerm setStringValue:@""];
  [translateTerm selectText:self];
  [translateButton setEnabled:YES];
  [[translateResults documentView] setString:@""];

  return self;
}

- performTranslate:sender
{
  GODICT *d;
  char term[80];
  extern int termtypes, languages;

  strcpy(term, [[translateTerm stringValue] cString]);
  if (strlen(term) == 0)
    return self;

  termtypes = CD_MISC*[transTypeMISC intValue];
  termtypes += CD_NAME*[transTypeNAME intValue];
  termtypes += CD_CHAM*[transTypeCHAM intValue];
  termtypes += CD_TECH*[transTypeTECH intValue];
  termtypes += CD_POLI*[transTypePOLI intValue];
  termtypes += CD_DIGI*[transTypeDIGI intValue];

  languages = LANG_DG*[transLangDG intValue];
  languages += LANG_CP*[transLangCP intValue];
  languages += LANG_JP*[transLangJP intValue];
  languages += LANG_CH*[transLangCH intValue];
  languages += LANG_RK*[transLangRK intValue];
  languages += LANG_GB*[transLangGB intValue];
  languages += LANG_NL*[transLangNL intValue];
  languages += LANG_GE*[transLangGE intValue];
  languages += LANG_FR*[transLangFR intValue];
  languages += LANG_SV*[transLangSV intValue];

  [[translateResults documentView] setString:@""];
  d = godict;

  while (d != NULL)
    {
      d = search_dict(d,term);
      if (d != NULL)
	{
	  [self translateOutput:d];
	  d = d->dct_next;
	}
    }
  [translateTerm selectText:self];

  return self;
}

- translateOutput:(GODICT *)d
{
  extern int languages;

  printBold = YES;
  [self addTranslateResults:LB_CD];
  switch(d->dct_type)
    {
    case CD_CHAM:
      [self addTranslateResults:MSG_CHAM];
      break;
    case CD_TECH:
      [self addTranslateResults:MSG_TECH];
      break;
    case CD_NAME:
      [self addTranslateResults:MSG_NAME];
      break;
    case CD_POLI:
      [self addTranslateResults:MSG_POLI];
      break;
    case CD_DIGI:
      [self addTranslateResults:MSG_DIGI];
      break;
    default:
      [self addTranslateResults:MSG_MISC];
      break;
    }

  [self addTranslateResults:"\n"];

  if (d->dct_jp && (languages & (LANG_JP)))
    {
      printBold = YES;
      [self addTranslateResults:LB_JP];
      [self addTranslateResults:d->dct_jp];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_ch && (languages & (LANG_CH)))
    {
      printBold = YES;
      [self addTranslateResults:LB_CH];
      [self addTranslateResults:d->dct_ch];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_rk && (languages & (LANG_RK)))
    {
      printBold = YES;
      [self addTranslateResults:LB_RK];
      [self addTranslateResults:d->dct_rk];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_gb && (languages & (LANG_GB)))
    {
      printBold = YES;
      [self addTranslateResults:LB_GB];
      [self addTranslateResults:d->dct_gb];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_nl && (languages & (LANG_NL)))
    {
      printBold = YES;
      [self addTranslateResults:LB_NL];
      [self addTranslateResults:d->dct_nl];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_ge && (languages & (LANG_GE)))
    {
      printBold = YES;
      [self addTranslateResults:LB_GE];
      [self addTranslateResults:d->dct_ge];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_fr && (languages & (LANG_FR)))
    {
      printBold = YES;
      [self addTranslateResults:LB_FR];
      [self addTranslateResults:d->dct_fr];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_fr && (languages & (LANG_SV)))
    {
      printBold = YES;
      [self addTranslateResults:LB_SV];
      [self addTranslateResults:d->dct_sv];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_dg && (languages & (LANG_DG)))
    {
      printBold = YES;
      [self addTranslateResults:LB_DG];
      [self addTranslateResults:"\n"];
      [self addTranslateResults:d->dct_dg];
      [self addTranslateResults:"\n"];
    }
  if (d->dct_cp && (languages & (LANG_CP)))
    {
      printBold = YES;
      [self addTranslateResults:LB_CP];
      [self addTranslateResults:d->dct_cp];
      [self addTranslateResults:"\n"];
    }

  [self addTranslateResults:"\n\n"];

  return self;
}

- addTranslateResults:(char *)s {
    NSString *aString;
    
    NSText *docView = [translateResults documentView];
    aString = [docView string];
    aString = [aString stringByAppendingString:[NSString stringWithCString:s]];
    [docView setFont:IGSfont];
    printBold = NO;
    [docView selectAll:docView];

    [docView scrollRangeToVisible:[docView selectedRange]];

    return self;
}

- openSmartGoFile:(const char*)aFile
{
  	char dispFileName[80];
  	int i, j;
  	struct stat statbuf;

  	if (gameType != LOCAL) {
    	NSRunAlertPanel(@"IGS Error", @"You must first close your IGS session before\n\
		 opening a Smart-Go file.", @"OK", nil, nil);
      	return self;
  	}

    if ((smartGoInputFile = fopen(aFile, "r")) == NULL) {
      		return self;
	}

	SGgameMoves = NULL;
	SmartGoGameFlag = 1;
	initialization = 0;

	[smartGoPanel makeKeyAndOrderFront:self];
    [smartGoPanel setMiniwindowImage:[NSImage imageNamed:@"NeXTGoFile"]];
    [smartGoPanel display];
    [stepForwardButton setEnabled:YES];

	stat(aFile, &statbuf);
		SGfile = (char *) malloc ((size_t)statbuf.st_size+10);
	if (fread(SGfile, statbuf.st_size, 1, smartGoInputFile) != 1) {
			[self showError:"Error on Read"];
			fclose(smartGoInputFile);
			free(SGfile);
			return self;
	}

	fclose(smartGoInputFile);

	[MainGoView startNewGame];
	[MainGoView setMess1:"Smart-Go Playback"];
	j = 0;
	for (i = 0; i < strlen(aFile); i++) {
			if (aFile[i] == '/') {
				j = i;
			}
	}
    for (i = j+1; i < strlen(aFile); i++) {
			dispFileName[i-j-1] = aFile[i];
	}
    dispFileName[strlen(aFile) - j - 1] = 0;

	[MainGoView setMess2:dispFileName];

	rootNode = parse_tree(SGfile);
	MAXX = MAXY = 19;
	currentNode = stepForward(rootNode);
	[self displayNewSGNode];

	// PSWait();

	return self;
}

- IGSSendCommand:sender {
    NSRange aRange;
    int i, blanks = 0;
    NSString *aString;
    if ([ [IGSCommand stringValue] length]) {
        /* first we catch all commands which have a special implementation */
        for (i=0; i< [ [IGSCommand stringValue] length]; i++)
            if ([[IGSCommand stringValue] characterAtIndex:i] == ' ')
                blanks++;
        aString = @"done";
        aRange = [[IGSCommand stringValue] rangeOfString:aString];
        if (!aRange.length + blanks ==
            [[IGSCommand stringValue] length]){
            [IGSCommand selectText:self];
            [self IGSdone:self];
        }
        else {
            aString = @"observe";
            aRange = [[IGSCommand stringValue] rangeOfString:aString];
            if (aRange.length + blanks ==
                [[IGSCommand stringValue] length]){
                [IGSCommand selectText:self];
                [self IGSobserve:self];
            }
            else {
                aString = @"unobserve";
                aRange = [[IGSCommand stringValue] rangeOfString:aString];
                if (aRange.length + blanks ==
                    [[IGSCommand stringValue] length]){
                    [IGSCommand selectText:self];
                    [self IGSunobserve:self];
                }
                else {
                    aString = @"load";
                    aRange = [[IGSCommand stringValue] rangeOfString:aString];
                    if (aRange.length + blanks ==
                        [[IGSCommand stringValue] length]){
                        [IGSCommand selectText:self];
                        [self IGSOpenLoadGame:self];
                    }
                    else {
                        aString = @"quit";
                        aRange = [[IGSCommand stringValue] rangeOfString:aString];
                        if (aRange.length + blanks ==
                            [[IGSCommand stringValue] length]){
                            [IGSCommand selectText:self];
                            [self IGSquit:self];
                        }
                        else {
                            IGSSendString((char *)[[IGSCommand stringValue] cString]);
                            IGSSendString("\n");
                        }
                    }
                }
            }
        }
    }
    else {
        IGSSendString("\n");
    }        

    if (CommandSender != nil) {
	[CommandSender makeKeyAndOrderFront:self];
	CommandSender = nil;
    }
		
    return self;
}

- connect:(GoServer*)server {
	char s[80];

	sethost((char *)[[server serverName] cString]);
	setport([server port]);
	strcpy(IGSLoginText, [ [server login] cString]);
	strcpy(IGSPasswordText,[ [server password] cString]);

	if (SmartGoGameFlag) {
		SmartGoGameFlag = 0;
		[smartGoPanel close];
	}

	[[IGSStatus documentView] setString:@""];
	[IGSPanel makeKeyAndOrderFront:self];
	[IGSPanel setMiniwindowImage:[NSImage imageNamed:@"NeXTGoFile"]];
	[IGSCommand selectText:self];

  if (open_connection())
    {
      [self SetIGSStatus:"Unable to make a connection.\n"];
      gameType = LOCAL;

      NSRunAlertPanel(@"IGS Error", @"I was unable to make a connection.", @"OK", nil, nil);
      [IGSPanel close];

      return self;
    }

  [self SetIGSStatus:"Connection established."];
  sprintf(s, "Logging in as %s\n", IGSLoginText);
  [self SetIGSStatus:s];

  timer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkingNetTraffic:) userInfo:self repeats:YES] retain];

  gameType = IGSGAME;
  finished = YES;
  idle = 1;
  [loadMenuCell setEnabled:YES];
  [observeMenuCell setEnabled:YES];

  initparser();

  return self;
}

- checkNetTraffic {
    fd_set readers;
    struct timeval to;
    int sel;

    to.tv_sec = 0;
    to.tv_usec = 0;

    FD_ZERO(&readers);
    FD_SET(sock, &readers);

    sel = select(sock + 1, &readers, NULL, NULL, &to);
    if (FD_ISSET(sock, &readers))
        incomingserver();

    return self;
}

- SetIGSStatus:(char *)s {
    NSRange selected;
    id docView = [IGSStatus documentView];
    NSString *aString;
    aString = [NSString stringWithCString:s];

    NS_DURING
    if ((0 == [aString length]) ||
        ('\n' != [aString characterAtIndex:([aString length]-1)])) {
        aString = [aString stringByAppendingString:@"\n"];
    }
    NS_HANDLER
#ifdef DEBUG
    NSRunAlertPanel(@"Error Panel", @"%@", @"OK", nil, nil, localException);
#endif
    NS_ENDHANDLER

    [docView selectAll:nil];
    selected = [docView selectedRange];
    selected.location = selected.length;
    selected.length = 0;
    [docView setSelectedRange:selected];
    [docView replaceCharactersInRange:selected withString: aString];
    selected.length = [aString length];
    [docView setFont:IGSfont range:selected];

    if (printBold) {
        [docView setFont:IGSboldFont range:selected];
    }
    [docView scrollRangeToVisible:[docView selectedRange]];

    if (printBold) {
        [IGSCommand selectText:self];  
        printBold = NO;
    }
    //    [IGSCommand selectText:self];  

    return self;
}

- getGoView{
	return MainGoView;
}

- open:sender {
#ifndef __MINGW32__
    id fileTypes;

    NSString *fileType1 = @"nextgo",
             *fileType2 = @"mgt";

    id open = [NSOpenPanel new];

    fileTypes = [NSArray arrayWithObjects:fileType1, fileType2, nil];

    [open setAllowsMultipleSelection:NO];

	if (NSOKButton == [open runModalForTypes:fileTypes]) {
		char * cc = rindex([[open filename] cString],'.');
		cc++;
		if (!strcmp(cc,"mgt")) {
			[self openSmartGoFile:[[open filename] cString] ];
		}
		else {
			[self openNeXTGoFile:[[open filename] cString] ];
		}
		return self;
	}
#endif
	return self;
}

- save:sender {
    char  aString[256] = "";

    id save = [NSSavePanel new];

	strcpy(aString, [[gameWindow title] cString]);
	stripChar(aString, ' ');
	stripChar(aString, '(');
	stripChar(aString, ')');
	stripChar(aString, '*');
		

	/* set the initial format */

	[self setFormat:formatMatrix];

	/* put format box in view */
	[save setAccessoryView:formatMatrix];

	if ((1 == [save runModalForDirectory:@"" file:@""])) {
		if ([[[formatMatrix selectedCell] title] isEqualToString:@"NeXTGo"]) {
      		saveNeXTGoFile([[save filename] cString]);
		//  			PSWait();
		}
		else {
      		saveSmartGoFile([[save filename] cString]);
		//  			PSWait();
		}
	}
	return self;
}

- setFormat:sender
{
	if ([[[sender selectedCell] title] isEqualToString:@"NeXTGo"]) {
            [[NSSavePanel savePanel] setRequiredFileType:@"nextgo"];
	}
	else {
 		[[NSSavePanel savePanel] setRequiredFileType:@"mgt"];
	}
	return self;
}

 
/*
  The following methods are the various commands for the Internet Go Server
  */

- IGSobserve:sender
{
  message mess;
    NSRect frameRect = {{15, 30}, {497, 226}}, scrollRect = {{0, 0},{ 497, 226}};
  NSSize cellSize = {470, 30};
  char str[80];
  int i;

  idle = 0;

  getgames(&mess);
  observeMatrix = [[NSMatrix alloc] initWithFrame:frameRect mode:NSRadioModeMatrix cellClass:[ClickCell class] numberOfRows:0 numberOfColumns:1];
  [observeMatrix setCellSize:cellSize];

  for (i = 0; i < mess.gamecount; i++)
    {
      sprintf(str, "%3d -- %12s [%3s] vs. %12s [%3s] (%3d %d %d %3.1f)",
	      mess.gamelist[i].gnum, mess.gamelist[i].white,
	      mess.gamelist[i].wrank, mess.gamelist[i].black,
	      mess.gamelist[i].brank, mess.gamelist[i].mnum,
	      mess.gamelist[i].bsize, mess.gamelist[i].hcap,
	      mess.gamelist[i].komi);
      [observeMatrix addRow];
      observeCell = [observeMatrix cellAtRow:i column:0];
      [observeCell setStringValue:[NSString stringWithCString:str]];
      [observeCell setAlignment:NSLeftTextAlignment];
    }
  [observeMatrix sizeToCells];

  observeScrollView = [[NSScrollView alloc] initWithFrame:scrollRect];
  [observeScrollView setHasVerticalScroller:YES];
  [observeScrollView setBorderType:NSBezelBorder];
  [observeScrollView setBackgroundColor:[NSColor lightGrayColor]];
  [observeScrollView setDocumentView:observeMatrix];
  [observeBox addSubview:observeScrollView];
  [observeMatrix scrollCellToVisibleAtRow:0 column:0];
  [observeBox display];

  [observeSelPanel makeKeyAndOrderFront:self];

//  [IGSCommand selectText:self];
  idle = 1;

  return self;
}

- cellClicked:theCell
{
  char str[80];
  int n;

  strcpy(str, [[theCell stringValue] cString]);
  sscanf(str, "%3d", &n);

  idle = 0;
  observegame(n);
  idle = 1;

  [unobserveMenuCell setEnabled:YES];
  [observeMenuCell setEnabled:NO];
  [loadMenuCell setEnabled:NO];
  [observeSelPanel close];

  return self;
}

- IGSunobserve:sender {
	
	sendstr("unobserve\n");
	[self SetIGSStatus:"Removing observe\n"];
	[unobserveMenuCell setEnabled:NO];
	[observeMenuCell setEnabled:YES];
	[loadMenuCell setEnabled:YES];
	[MainGoView gameCompleted];
	[MainGoView removeTE];
	
	return self;
}

- IGSOpenLoadGame:sender
{
  [LoadGameWindow makeKeyAndOrderFront:self];
  [LoadGameText selectText:self];

  return self;
}

- IGSLoadGame:sender
{
  idle = 0;
  loadgame((char *)[[LoadGameText stringValue] cString]);
  idle = 1;

  [LoadGameWindow close];

  return self;
}

- IGSdone:sender {
	
	int q;
	
	q = NSRunAlertPanel(@"Save", @"Save the current game to disk ?", @"Save...", @"Dont't save", nil);
	
	if (1==q) 
		[self save:self];
	
	IGSSendString("done\n");
	
	return self;
}

- IGSquit:sender {

	IGSSendString("quit");
	IGSSendString("\n");
	[self IGSunobserve:self];

	[timer invalidate]; [timer release];;
  
	[loadMenuCell setEnabled:NO];
	[observeMenuCell setEnabled:NO];
	[unobserveMenuCell setEnabled:NO];
	[MainGoView removeTE];

	gameType = LOCAL;
	[IGSPanel close];

	return self;
}

- sendCommand:sender 
{
  char buf[256];
  NSString *title = [sender title];

  strncpy(buf, [title cString], [title length]);
  buf[[title length]] = '\n';
  buf[[title length]+1] = '\0';	
  IGSSendString(buf);
  
  return self;
}

- gameCompleted {
	
    [MainGoView gameCompleted];	
    return self;
}

- setCommandSender:(id)aSender {
    CommandSender = aSender;
    return self;
}

- (void)checkingNetTraffic:(NSTimer *)aTimer {
    [[aTimer userInfo] checkNetTraffic];
}

@end

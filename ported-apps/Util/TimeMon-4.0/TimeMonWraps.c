/* stdout generated from TimeMonWraps.psw
   by unix pswrap V1.009 XFree86
 */

#include <DPS/dpsfriends.h>
#include <string.h>
#line 1 "TimeMonWraps.psw"
/* Copyright 1991, 1994, 1997 Scott Hess.  Permission to use, copy, modify,
 * and distribute this software and its documentation for any purpose
 * and without fee is hereby granted, provided that this copyright
 * notice appear in all copies.
 * 
 * Scott Hess makes no representations about the suitability of this
 * software for any purpose.  It is provided "as is" without express
 * or implied warranty.
 */
/* drawInit() initializes DPS, loading default colors for Idle,
 * Nice, User, and System times, plus two routines, _doDrawArc1
 * which draws the time except Nice, and _doDrawArc2 which draws
 * all four times.  drawArc1() executes _doDrawArc1, which drawArc2()
 * executes _doDrawArc2.
 */
#line 25 "stdout"
void drawInit()
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjGeneric obj1;
    DPSBinObjGeneric obj2;
    DPSBinObjGeneric obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    DPSBinObjGeneric obj8;
    DPSBinObjGeneric obj9;
    DPSBinObjGeneric obj10;
    DPSBinObjGeneric obj11;
    DPSBinObjGeneric obj12;
    DPSBinObjGeneric obj13;
    DPSBinObjGeneric obj14;
    DPSBinObjGeneric obj15;
    DPSBinObjGeneric obj16;
    DPSBinObjGeneric obj17;
    DPSBinObjGeneric obj18;
    DPSBinObjGeneric obj19;
    DPSBinObjGeneric obj20;
    DPSBinObjGeneric obj21;
    DPSBinObjGeneric obj22;
    DPSBinObjGeneric obj23;
    DPSBinObjGeneric obj24;
    DPSBinObjGeneric obj25;
    DPSBinObjGeneric obj26;
    DPSBinObjGeneric obj27;
    DPSBinObjGeneric obj28;
    DPSBinObjGeneric obj29;
    DPSBinObjGeneric obj30;
    DPSBinObjGeneric obj31;
    DPSBinObjGeneric obj32;
    DPSBinObjGeneric obj33;
    DPSBinObjGeneric obj34;
    DPSBinObjGeneric obj35;
    DPSBinObjGeneric obj36;
    DPSBinObjGeneric obj37;
    DPSBinObjGeneric obj38;
    DPSBinObjGeneric obj39;
    DPSBinObjGeneric obj40;
    DPSBinObjGeneric obj41;
    DPSBinObjGeneric obj42;
    DPSBinObjGeneric obj43;
    DPSBinObjGeneric obj44;
    DPSBinObjGeneric obj45;
    DPSBinObjGeneric obj46;
    DPSBinObjGeneric obj47;
    DPSBinObjGeneric obj48;
    DPSBinObjGeneric obj49;
    DPSBinObjGeneric obj50;
    DPSBinObjGeneric obj51;
    DPSBinObjGeneric obj52;
    DPSBinObjGeneric obj53;
    DPSBinObjGeneric obj54;
    DPSBinObjGeneric obj55;
    DPSBinObjGeneric obj56;
    DPSBinObjGeneric obj57;
    DPSBinObjGeneric obj58;
    DPSBinObjGeneric obj59;
    DPSBinObjGeneric obj60;
    DPSBinObjGeneric obj61;
    DPSBinObjGeneric obj62;
    DPSBinObjGeneric obj63;
    DPSBinObjGeneric obj64;
    DPSBinObjGeneric obj65;
    DPSBinObjGeneric obj66;
    DPSBinObjGeneric obj67;
    DPSBinObjGeneric obj68;
    DPSBinObjGeneric obj69;
    DPSBinObjGeneric obj70;
    DPSBinObjGeneric obj71;
    DPSBinObjGeneric obj72;
    DPSBinObjGeneric obj73;
    DPSBinObjGeneric obj74;
    DPSBinObjGeneric obj75;
    DPSBinObjGeneric obj76;
    DPSBinObjGeneric obj77;
    DPSBinObjGeneric obj78;
    DPSBinObjGeneric obj79;
    DPSBinObjGeneric obj80;
    DPSBinObjGeneric obj81;
    DPSBinObjGeneric obj82;
    DPSBinObjGeneric obj83;
    DPSBinObjGeneric obj84;
    DPSBinObjGeneric obj85;
    DPSBinObjGeneric obj86;
    DPSBinObjGeneric obj87;
    DPSBinObjGeneric obj88;
    DPSBinObjGeneric obj89;
    DPSBinObjGeneric obj90;
    DPSBinObjGeneric obj91;
    DPSBinObjGeneric obj92;
    DPSBinObjGeneric obj93;
    DPSBinObjGeneric obj94;
    DPSBinObjGeneric obj95;
    DPSBinObjGeneric obj96;
    DPSBinObjGeneric obj97;
    DPSBinObjGeneric obj98;
    DPSBinObjGeneric obj99;
    DPSBinObjGeneric obj100;
    DPSBinObjGeneric obj101;
    DPSBinObjGeneric obj102;
    DPSBinObjGeneric obj103;
    DPSBinObjGeneric obj104;
    DPSBinObjGeneric obj105;
    DPSBinObjGeneric obj106;
    DPSBinObjGeneric obj107;
    DPSBinObjGeneric obj108;
    DPSBinObjGeneric obj109;
    DPSBinObjGeneric obj110;
    DPSBinObjGeneric obj111;
    DPSBinObjGeneric obj112;
    DPSBinObjGeneric obj113;
    DPSBinObjGeneric obj114;
    DPSBinObjGeneric obj115;
    DPSBinObjGeneric obj116;
    DPSBinObjGeneric obj117;
    DPSBinObjGeneric obj118;
    DPSBinObjGeneric obj119;
    DPSBinObjGeneric obj120;
    DPSBinObjGeneric obj121;
    DPSBinObjGeneric obj122;
    DPSBinObjGeneric obj123;
    DPSBinObjGeneric obj124;
    DPSBinObjGeneric obj125;
    DPSBinObjGeneric obj126;
    DPSBinObjGeneric obj127;
    DPSBinObjGeneric obj128;
    DPSBinObjGeneric obj129;
    DPSBinObjGeneric obj130;
    DPSBinObjGeneric obj131;
    DPSBinObjGeneric obj132;
    DPSBinObjGeneric obj133;
    DPSBinObjGeneric obj134;
    DPSBinObjGeneric obj135;
    DPSBinObjGeneric obj136;
    DPSBinObjReal obj137;
    DPSBinObjReal obj138;
    DPSBinObjReal obj139;
    DPSBinObjReal obj140;
    DPSBinObjReal obj141;
    DPSBinObjReal obj142;
    DPSBinObjReal obj143;
    DPSBinObjReal obj144;
    DPSBinObjReal obj145;
    } _dpsQ;
  static _dpsQ _dpsF = {
    DPS_DEF_TOKENTYPE, 20, 1172,
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* Idle */
    {DPS_LITERAL|DPS_ARRAY, 0, 3, 1144},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* Nice */
    {DPS_LITERAL|DPS_ARRAY, 0, 3, 1120},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* User */
    {DPS_LITERAL|DPS_ARRAY, 0, 3, 1096},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* System */
    {DPS_LITERAL|DPS_ARRAY, 0, 3, 1072},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* _doDrawArc1 */
    {DPS_EXEC|DPS_ARRAY, 0, 49, 680},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 14},	/* bind */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* _doDrawArc2 */
    {DPS_EXEC|DPS_ARRAY, 0, 65, 160},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 14},	/* bind */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 62},	/* exch */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* Idle */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 2},	/* aload */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 157},	/* setrgbcolor */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_INT, 0, 0, 360},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 5},	/* arc */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* Nice */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 2},	/* aload */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 157},	/* setrgbcolor */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_LITERAL|DPS_INT, 0, 0, 90},
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 88},	/* index */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 6},	/* arcn */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* User */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 2},	/* aload */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 157},	/* setrgbcolor */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_LITERAL|DPS_INT, 0, 0, 90},
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 88},	/* index */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 6},	/* arcn */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* System */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 2},	/* aload */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 157},	/* setrgbcolor */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_LITERAL|DPS_INT, 0, 0, 90},
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 88},	/* index */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 6},	/* arcn */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_LITERAL|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 62},	/* exch */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* Idle */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 2},	/* aload */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 157},	/* setrgbcolor */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_INT, 0, 0, 360},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 5},	/* arc */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* User */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 2},	/* aload */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 157},	/* setrgbcolor */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_LITERAL|DPS_INT, 0, 0, 90},
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 88},	/* index */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 6},	/* arcn */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* System */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 2},	/* aload */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 157},	/* setrgbcolor */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 107},	/* moveto */
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_LITERAL|DPS_INT, 0, 0, 24},
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* rad */
    {DPS_LITERAL|DPS_INT, 0, 0, 90},
    {DPS_LITERAL|DPS_INT, 0, 0, 4},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 88},	/* index */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 6},	/* arcn */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 66},	/* fill */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 117},	/* pop */
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_INT, 0, 0, 0},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0.333},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0.333},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0.333},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0.667},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0.667},
    {DPS_LITERAL|DPS_REAL, 0, 0, 0.667},
    {DPS_LITERAL|DPS_REAL, 0, 0, 1.0},
    {DPS_LITERAL|DPS_REAL, 0, 0, 1.0},
    {DPS_LITERAL|DPS_REAL, 0, 0, 1.0},
    }; /* _dpsQ */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  {
  static int _dpsT = 1;

  if (_dpsT) {
    static char *_dps_names[] = {
	"Idle",
	(char *) 0 ,
	(char *) 0 ,
	"Nice",
	(char *) 0 ,
	"User",
	(char *) 0 ,
	(char *) 0 ,
	"System",
	(char *) 0 ,
	(char *) 0 ,
	"_doDrawArc1",
	"_doDrawArc2",
	"rad",
	(char *) 0 ,
	(char *) 0 ,
	(char *) 0 ,
	(char *) 0 ,
	(char *) 0 ,
	(char *) 0 ,
	(char *) 0 ,
	(char *) 0 };
    int *_dps_nameVals[22];
    _dps_nameVals[0] = (int *)&_dpsP[0].val.nameVal;
    _dps_nameVals[1] = (int *)&_dpsP[88].val.nameVal;
    _dps_nameVals[2] = (int *)&_dpsP[23].val.nameVal;
    _dps_nameVals[3] = (int *)&_dpsP[3].val.nameVal;
    _dps_nameVals[4] = (int *)&_dpsP[37].val.nameVal;
    _dps_nameVals[5] = (int *)&_dpsP[6].val.nameVal;
    _dps_nameVals[6] = (int *)&_dpsP[102].val.nameVal;
    _dps_nameVals[7] = (int *)&_dpsP[53].val.nameVal;
    _dps_nameVals[8] = (int *)&_dpsP[9].val.nameVal;
    _dps_nameVals[9] = (int *)&_dpsP[118].val.nameVal;
    _dps_nameVals[10] = (int *)&_dpsP[69].val.nameVal;
    _dps_nameVals[11] = (int *)&_dpsP[12].val.nameVal;
    _dps_nameVals[12] = (int *)&_dpsP[16].val.nameVal;
    _dps_nameVals[13] = (int *)&_dpsP[20].val.nameVal;
    _dps_nameVals[14] = (int *)&_dpsP[127].val.nameVal;
    _dps_nameVals[15] = (int *)&_dpsP[111].val.nameVal;
    _dps_nameVals[16] = (int *)&_dpsP[97].val.nameVal;
    _dps_nameVals[17] = (int *)&_dpsP[85].val.nameVal;
    _dps_nameVals[18] = (int *)&_dpsP[78].val.nameVal;
    _dps_nameVals[19] = (int *)&_dpsP[62].val.nameVal;
    _dps_nameVals[20] = (int *)&_dpsP[46].val.nameVal;
    _dps_nameVals[21] = (int *)&_dpsP[32].val.nameVal;

    DPSMapNames(_dpsCurCtxt, 22, (char **) _dps_names, _dps_nameVals);
    _dpsT = 0;
    }
  }


  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,1172);
  DPSSYNCHOOK(_dpsCurCtxt)
}
#line 77 "TimeMonWraps.psw"

    /* These cover for the pre-loaded procedures. */
#line 394 "stdout"
void drawArc1(radius, bdeg, ddeg)
double radius, bdeg, ddeg; 
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjReal obj0;
    DPSBinObjReal obj1;
    DPSBinObjReal obj2;
    DPSBinObjGeneric obj3;
    } _dpsQ;
  static _dpsQ _dpsF = {
    DPS_DEF_TOKENTYPE, 4, 36,
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: bdeg */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: ddeg */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: radius */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* _doDrawArc1 */
    }; /* _dpsQ */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  {
  static int _dpsT = 1;

  if (_dpsT) {
    static char *_dps_names[] = {
	"_doDrawArc1"};
    int *_dps_nameVals[1];
    _dps_nameVals[0] = (int *)&_dpsP[3].val.nameVal;

    DPSMapNames(_dpsCurCtxt, 1, (char **) _dps_names, _dps_nameVals);
    _dpsT = 0;
    }
  }


  _dpsP[2].val.realVal = radius;
  _dpsP[0].val.realVal = bdeg;
  _dpsP[1].val.realVal = ddeg;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,36);
  DPSSYNCHOOK(_dpsCurCtxt)
}
#line 81 "TimeMonWraps.psw"

#line 440 "stdout"
void drawArc2(radius, bdeg, ddeg, ldeg)
double radius, bdeg, ddeg, ldeg; 
{
  typedef struct {
    unsigned char tokenType;
    unsigned char topLevelCount;
    unsigned short nBytes;

    DPSBinObjReal obj0;
    DPSBinObjReal obj1;
    DPSBinObjReal obj2;
    DPSBinObjReal obj3;
    DPSBinObjGeneric obj4;
    } _dpsQ;
  static _dpsQ _dpsF = {
    DPS_DEF_TOKENTYPE, 5, 44,
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: bdeg */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: ddeg */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: ldeg */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: radius */
    {DPS_EXEC|DPS_NAME, 0, 0, 0},	/* _doDrawArc2 */
    }; /* _dpsQ */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  {
  static int _dpsT = 1;

  if (_dpsT) {
    static char *_dps_names[] = {
	"_doDrawArc2"};
    int *_dps_nameVals[1];
    _dps_nameVals[0] = (int *)&_dpsP[4].val.nameVal;

    DPSMapNames(_dpsCurCtxt, 1, (char **) _dps_names, _dps_nameVals);
    _dpsT = 0;
    }
  }


  _dpsP[3].val.realVal = radius;
  _dpsP[0].val.realVal = bdeg;
  _dpsP[1].val.realVal = ddeg;
  _dpsP[2].val.realVal = ldeg;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,44);
  DPSSYNCHOOK(_dpsCurCtxt)
}
#line 84 "TimeMonWraps.psw"

#line 489 "stdout"
void setColor(name, r, g, b)
char *name; float r, g, b; 
{
  typedef struct {
    unsigned char tokenType;
    unsigned char sizeFlag;
    unsigned short topLevelCount;
    unsigned int nBytes;

    DPSBinObjGeneric obj0;
    DPSBinObjReal obj1;
    DPSBinObjReal obj2;
    DPSBinObjReal obj3;
    DPSBinObjGeneric obj4;
    DPSBinObjGeneric obj5;
    DPSBinObjGeneric obj6;
    DPSBinObjGeneric obj7;
    } _dpsQ;
  static _dpsQ _dpsF = {
    DPS_DEF_TOKENTYPE, 0, 8, 72,
    {DPS_LITERAL|DPS_NAME, 0, 0, 64},	/* param name */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: r */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: g */
    {DPS_LITERAL|DPS_REAL, 0, 0, 0},	/* param: b */
    {DPS_LITERAL|DPS_INT, 0, 0, 3},
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 9},	/* array */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 11},	/* astore */
    {DPS_EXEC|DPS_NAME, 0, DPSSYSNAME, 51},	/* def */
    }; /* _dpsQ */
  register DPSContext _dpsCurCtxt = DPSPrivCurrentContext();
  register DPSBinObjRec *_dpsP = (DPSBinObjRec *)&_dpsF.obj0;
  register int _dps_offset = 64;

  _dpsP[0].length = strlen(name);
  _dpsP[1].val.realVal = r;
  _dpsP[2].val.realVal = g;
  _dpsP[3].val.realVal = b;
  _dpsP[0].val.stringVal = _dps_offset;
  _dps_offset += _dpsP[0].length;

  _dpsF.nBytes = _dps_offset+8;
  DPSBinObjSeqWrite(_dpsCurCtxt,(char *) &_dpsF,72);
  DPSWriteStringChars(_dpsCurCtxt, (char *)name, _dpsP[0].length);
  DPSSYNCHOOK(_dpsCurCtxt)
}
#line 87 "TimeMonWraps.psw"


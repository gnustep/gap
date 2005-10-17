/*
 CalcModel.h
 file part of Stepulator
 a RPN calculator for *step

 Riccardo Mottola, 2003-2004 <rmottola@users.sf.net>

 This application is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This application is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU General Public
 License along with this library; if not, write to the Free
 Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import <AppKit/AppKit.h>

#import <math.h>

@interface CalcModel : NSObject
{
    @private double regX;
    @private double regY;
    @private double regZ;
    @private double regT;
}
- (void)dumpRegs;
- (double)getRegX;
- (void)setRegX:(double)x;
- (void)pushRegister;
- (double)popRegister;
- (void)rotateRegister;
- (void)doSwapXY;
- (void)doAdd;
- (void)doSubtract;
- (void)doMultiply;
- (void)doDivide;
- (void)doSqrt;
- (void)doSqr;
- (void)doSin;
- (void)doCos;
- (void)doTan;
- (void)doASin;
- (void)doACos;
- (void)doATan;
- (void)doExp;
- (void)doLn;
- (void)doExp10;
- (void)doLog;
- (void)doXPowY;
- (void)doXRootY;
- (void)doInv;
- (void)doPercent;
- (void)doFact;
@end

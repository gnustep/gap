/*
 CalcController.h
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

#import "CalcModel.h"

#define PI 3.14159265359

@interface CalcController : NSObject
{
    IBOutlet NSTextField *displayField;
    CalcModel *model;
    BOOL hasDot;
    BOOL hasE;
    BOOL isNew;
    BOOL isEditing;
    BOOL fromEnter;
    NSMutableString *displayString;
}
- (void)initInput;
- (void)doFButton;
- (void)doCipherButton;
- (IBAction)butt0:(id)sender;
- (IBAction)butt1:(id)sender;
- (IBAction)butt2:(id)sender;
- (IBAction)butt3:(id)sender;
- (IBAction)butt4:(id)sender;
- (IBAction)butt5:(id)sender;
- (IBAction)butt6:(id)sender;
- (IBAction)butt7:(id)sender;
- (IBAction)butt8:(id)sender;
- (IBAction)butt9:(id)sender;
- (IBAction)buttDot:(id)sender;
- (IBAction)buttE:(id)sender;
- (IBAction)buttEnter:(id)sender;
- (IBAction)buttPlus:(id)sender;
- (IBAction)buttMinus:(id)sender;
- (IBAction)buttDivide:(id)sender;
- (IBAction)buttMultiply:(id)sender;
- (IBAction)buttSqrt:(id)sender;
- (IBAction)buttSqr:(id)sender;
- (IBAction)buttSin:(id)sender;
- (IBAction)buttCos:(id)sender;
- (IBAction)buttTan:(id)sender;
- (IBAction)buttASin:(id)sender;
- (IBAction)buttACos:(id)sender;
- (IBAction)buttATan:(id)sender;
- (IBAction)buttExp:(id)sender;
- (IBAction)buttLn:(id)sender;
- (IBAction)buttExp10:(id)sender;
- (IBAction)buttLog:(id)sender;
- (IBAction)buttXPowY:(id)sender;
- (IBAction)buttXRootY:(id)sender;
- (IBAction)buttPi:(id)sender;
- (IBAction)buttFact:(id)sender;
- (IBAction)buttPercent:(id)sender;
- (IBAction)buttInv:(id)sender;
- (IBAction)buttCanc:(id)sender;
- (IBAction)buttBksp:(id)sender;
- (IBAction)buttRot:(id)sender;
- (IBAction)buttSwapXY:(id)sender;
- (IBAction)buttChangeSign:(id)sender;
@end

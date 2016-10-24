/*
 CalcController.m
 file part of Stepulator
 a RPN calculator for *step

 Riccardo Mottola, 2003-2016 <rm@gnu.org>

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

#import "CalcController.h"

@implementation CalcController

- init
{
  self = [super init];
  if (self)
    {
        model = [CalcModel alloc];
        if (!model)
            NSLog(@"Error allocating model.");
    }
    displayString = [[NSMutableString alloc] initWithCapacity:16];
    [self initInput];
    return self;
}

- (void)awakeFromNib
{
    [buttSqrt setImage:[NSImage imageNamed:@"sqrt"]];
    [buttSqr setImage:[NSImage imageNamed:@"sqr"]];
    [buttBksp setImage:[NSImage imageNamed:@"back_arrow"]];
    [buttExp setImage:[NSImage imageNamed:@"ex"]];
    [buttExp10 setImage:[NSImage imageNamed:@"10x"]];
    [displayField setStringValue:@"0"];
}

- (void)initInput
{
    hasDot = NO;
    hasE = NO;
    isNew = YES;
    isEditing = YES;
    fromEnter = NO;
    [displayString setString:@""];
}

- (void)doFButton
{
    if (isEditing)
        [model setRegX:[displayString doubleValue]];
    [displayString setString:@""];
}

- (void)doCipherButton
{
    if (!isEditing)
    {
        if (!fromEnter)
            [model pushRegister];
        [self initInput];
    }
}

- (IBAction)butt0:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"0"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt1:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"1"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt2:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"2"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt3:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"3"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt4:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"4"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt5:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"5"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt6:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"6"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt7:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"7"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt8:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"8"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)butt9:(id)sender
{
    [self doCipherButton];
    [displayString appendString:@"9"];
    [displayField setStringValue:displayString];
    isNew = NO;
}

- (IBAction)buttDot:(id)sender
{
    [self doCipherButton];
    if (!hasDot && !hasE)
    {
        if (isNew)
            [displayString appendString:@"0"];
        [displayString appendString:@"."];
        [displayField setStringValue:displayString];
        hasDot = YES;
        isNew = NO;
    }
}

- (IBAction)buttE:(id)sender
{
    [self doCipherButton];
    if (!hasE) {
        if (isNew)
            [displayString appendString:@"1"];
        [displayString appendString:@"e"];
        [displayField setStringValue:displayString];
        hasE = YES;
        isNew = NO;
    }
}
- (IBAction)buttEnter:(id)sender
{
    [self doFButton];
    [model pushRegister];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    fromEnter = YES;
    [model dumpRegs];
}

- (IBAction)buttPlus:(id)sender
{
    [self doFButton];
    [model doAdd];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttMinus:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doSubtract];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttDivide:(id)sender
{
    [self doFButton];
    [model doDivide];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttMultiply:(id)sender
{
    [self doFButton];
    [model doMultiply];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
}

- (IBAction)buttSqrt:(id)sender
{
    [self doFButton];
    [model doSqrt];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttSqr:(id)sender
{
    [self doFButton];
    [model doSqr];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttSin:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doSin];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttCos:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doCos];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttTan:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doTan];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttASin:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doASin];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttACos:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doACos];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttATan:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doATan];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttExp:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doExp];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}


- (IBAction)buttLn:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doLn];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttExp10:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doExp10];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttLog:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doLog];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttXPowY:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doXPowY];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttXRootY:(id)sender;
{
    [self doFButton];
    [model dumpRegs];
    [model doXRootY];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttPi:(id)sender
{
    if (isEditing)
    {
        [model setRegX:[displayString doubleValue]];
        [model pushRegister];
    } else
    {
        if (!fromEnter)
            [model pushRegister];
    }
    [self initInput];
    [model setRegX:PI];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttFact:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doFact];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttPercent:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doPercent];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}


- (IBAction)buttInv:(id)sender
{
    [self doFButton];
    [model doInv];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttCanc:(id)sender
{
    [self initInput];
    [displayField setStringValue:@"0"];
}

- (IBAction)buttBksp:(id)sender
{
    unsigned int lastCharPos;
    
    lastCharPos = [displayString length] - 1;
    if ([displayString characterAtIndex:lastCharPos] == '.')
        hasDot = NO;
    if ([displayString characterAtIndex:lastCharPos] == 'e')
        hasE = NO;
    [displayString deleteCharactersInRange:NSMakeRange(lastCharPos, 1)];
    [displayField setStringValue:displayString];
}

- (IBAction)buttRot:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model rotateRegister];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttSwapXY:(id)sender
{
    [self doFButton];
    [model dumpRegs];
    [model doSwapXY];
    [displayString appendFormat:@"%lf", [model getRegX]];
    [displayField setStringValue:displayString];
    isEditing = NO;
    [model dumpRegs];
}

- (IBAction)buttChangeSign:(id)sender
{
    if ([displayString length] > 0)
    {
        if (hasE)
        {
            int k;
            k = 0;
            while (k < [displayString length] && [displayString characterAtIndex:k] != 'e')
                k++;
            if ([displayString characterAtIndex:k] == 'e')
            {
                NSLog(@"found e at %d", k);
                if(k < ([displayString length]-1))
                {
                    NSLog(@"exponent present");
                    if ([displayString characterAtIndex:k+1] == '-')
                        [displayString deleteCharactersInRange:NSMakeRange(k+1, 1)];
                    else
                        [displayString insertString:@"-" atIndex:k+1];
                }
            }
        } else
        {
            if ([displayString characterAtIndex:0] == '-')
                [displayString deleteCharactersInRange:NSMakeRange(0, 1)];
            else
                [displayString insertString:@"-" atIndex:0];
        }
        [displayField setStringValue:displayString];
    }
}

@end

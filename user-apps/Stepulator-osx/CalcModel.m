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

#import "CalcModel.h"

@implementation CalcModel

- (void)dumpRegs
{
    printf ("%f\n %f\n %f\n %f\n\n", regX, regY, regZ, regT);
}

- (double)getRegX
{
    return regX;
}

- (void)setRegX:(double)x
{
    regX = x;
}

- (void) pushRegister
{
    regT = regZ;
    regZ = regY;
    regY = regX;
}

- (double) popRegister
{
    double temp;
    
    temp = regX;
    regX = regY;
    regY = regZ;
    regZ = regT;
    return temp;
}

- (void)rotateRegister
{
    double temp;
    
    temp = regX;
    regX = regY;
    regY = regZ;
    regZ = regT;
    regT = temp;
}

- (void)doSwapXY
{
    double temp;
    
    temp = regX;
    regX = regY;
    regY = temp;
}

- (void)doAdd
{
    double operand1;
    double operand2;
    double result;

    operand2 = [self popRegister];
    operand1 = [self popRegister];
    result = operand1 + operand2;
    [self pushRegister];
    [self setRegX:result];
}

- (void)doSubtract
{
    double operand1;
    double operand2;
    double result;

    operand2 = [self popRegister];
    operand1 = [self popRegister];
    result = operand1 - operand2;
    [self pushRegister];
    [self setRegX:result];
}

- (void)doMultiply
{
    double operand1;
    double operand2;
    double result;

    operand2 = [self popRegister];
    operand1 = [self popRegister];
    result = operand1 * operand2;
    [self pushRegister];
    [self setRegX:result];
}

- (void)doDivide
{
    double operand1;
    double operand2;
    double result;

    operand2 = [self popRegister];
    operand1 = [self popRegister];
    result = operand1 / operand2;
    [self pushRegister];
    [self setRegX:result];
}

- (void)doSqrt
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = sqrt(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doSqr
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = operand*operand;
    [self pushRegister];
    [self setRegX:result];
}

- (void)doSin
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = sin(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doCos
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = cos(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doTan
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = tan(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doASin
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = asin(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doACos
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = acos(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doATan
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = atan(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doExp
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = exp(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doLn
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = log(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doExp10
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = pow(10, operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doLog
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = log10(operand);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doXPowY
{
    double operand1;
    double operand2;
    double result;

    operand2 = [self popRegister];
    operand1 = [self popRegister];
    result = pow(operand1, operand2);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doXRootY
{
    double operand1;
    double operand2;
    double result;

    operand2 = [self popRegister];
    operand1 = [self popRegister];
    result = pow(operand1, 1/operand2);
    [self pushRegister];
    [self setRegX:result];
}

- (void)doInv
{
    double operand;
    double result;
    
    operand = [self popRegister];
    result = 1/operand;
    [self pushRegister];
    [self setRegX:result];
}

- (void)doPercent
{
    double operand1;
    double operand2;
    double result;

    operand2 = [self popRegister];
    operand1 = [self popRegister];
    result = operand1 * (operand2 / 100);
    [self pushRegister];
    [self setRegX:operand1];
    [self pushRegister];
    [self setRegX:result];
}

- (void)doFact
{
    double operand;
    double result;
    double a;
    long int n;
    long int i;
    double f;

    operand = [self popRegister];
    a = floor(operand);
    if (operand == a)
    {
        n = (long int)a;
        f = 1;
        for (i = n; i > 1; i--)
            f *= i;
        result = f;
    } else
    {
        // we could put in here some code to handle fractional x!
    }
    [self pushRegister];
    [self setRegX:result];
}
@end

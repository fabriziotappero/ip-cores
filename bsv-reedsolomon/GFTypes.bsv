//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Abhinav Agarwal, Alfred Man Cheuk Ng
// Contact: abhiag@gmail.com
// 
// Permission is hereby granted, free of charge, to any person 
// obtaining a copy of this software and associated documentation 
// files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------//

//*************************************************************
// Type definitions for use in the Reed-Solomon modules
//-------------------------------------------------------------

import Vector::*;

typedef Bit#(8)	  Byte;            
typedef Byte      Polynomial;
typedef Vector#(n,Byte) Syndrome#(numeric type n);

typedef enum
{  NO_ERROR,
   CORRECTABLE,
   INCORRECTABLE
 } ErrInfo deriving (Bits, Eq);

`include "RSParameters.bsv"

typedef TMul#(T,2) TwoT;     // 2 * T
typedef TAdd#(T,2) TPlusTwo; // T + 2
typedef TDiv#(T,2) HalfT;    // T/2

// -----------------------------------------------------------
// The primitive polynomial defines the Galois field in which 
// Reed-Solomon decoder operates, and all the following		  
// arithmetic operations are defined under.  Changing this 	  
// value cause the whole Reed-Solomon decoder to operate		  
// under the new primitive polynomial.
// primitive_polynomial[i] = Coefficient of x**i for i = 0:7

// -----------------------------------------------------------
Byte    n_param = 8'd255;
Byte    t_param = fromInteger(valueOf(T));
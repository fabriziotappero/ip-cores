// The MIT License
//
// Copyright (c) 2006 Nirav Dave (ndave@csail.mit.edu)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.




import Vector::*;
import ComplexF::*;

typedef enum{// 1 = 6Mbits/s, 2 = 12Mbits/s, 4 = 24Mbits/s
  RNone = 0,
  R1    = 1,
  R2    = 2,
  R4    = 4 
}
 Rate deriving(Eq,Bits);

typedef Bit#(n) Header#(type n);




// Data in the queues between the TX MAC and Controller
typedef struct{
  Rate           rate;
  Bit#(12)       length; //in bytes
}
 TXMAC2ControllerInfo deriving (Eq, Bits);  



// Data in the queues between the TX MAC and Controller
typedef struct{
  Rate           rate;
  Bit#(12)       length; //in bytes
  Bit#(n)        data; 
}
 TXMAC2ControllerData#(type n) deriving (Eq, Bits);  

typedef struct{
  Bit#(n) data;
}
  Data#(type n) deriving (Eq, Bits);

typedef struct{
  Rate    rate;
  Bit#(n) data;
}
  RateData#(type n) deriving (Eq, Bits);

typedef struct{
  Bool    new_message;
  Vector#(n,ComplexF#(16)) data; 
}
MsgComplexFVec#(type n) deriving (Eq, Bits);

typedef Vector#(64,ComplexF#(16)) IFFTData;
typedef Vector#( 4,ComplexF#(16)) Radix4Data;
typedef Vector#( 3,ComplexF#(16)) OmegaData;
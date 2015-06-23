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




import DataTypes::*;

interface ConvEncoder#(type n, type m);
   //inputs
   method Action encode_fromController(Header#(n) fc);
   method Action encode_fromScrambler (RateData#(n) fs);
      
   //outputs
   method ActionValue#(RateData#(m))   getOutput(); 
endinterface

interface Scrambler#(type n);
   //inputs
   method Action fromControl(RateData#(n) x);
   
      //outputs
   method ActionValue#(RateData#(n))  toEncoder(); 
endinterface

interface Interleaver#(type n, type m );
   //inputs
   method Action fromEncoder(RateData#(n) txVec);

   //outputs
   method ActionValue#(RateData#(m))       toMapper(); 
endinterface

interface Mapper#(type n,  type m);
   //inputs
   method Action fromInterleaver(RateData#(n) txVec);

   //outputs
   method ActionValue#(MsgComplexFVec#(m))       toIFFT(); 
endinterface

interface IFFT#(type n);
   //inputs
   method Action                   fromMapper(MsgComplexFVec#(n) x);

   //outputs
   method ActionValue#(MsgComplexFVec#(n))       toCyclicExtender(); 
endinterface

interface CyclicExtender#(type n, type m);
   //inputs
   method Action fromIFFT(MsgComplexFVec#(n) x);

   //outputs
   method ActionValue#(MsgComplexFVec#(m)) toAnalogTX(); 
endinterface

interface Controller#(type inN, type hdrN, type dataN);
   //inputs
   method Action getFromMAC(TXMAC2ControllerInfo x);
   method Action getDataFromMAC(Data#(inN) x); 

   //outputs

   method ActionValue#(Header#(hdrN))            getHeader();
   method ActionValue#(RateData#(dataN))           getData();
endinterface

interface Transmitter#(type inN, type out);
   method Action getFromMAC(TXMAC2ControllerInfo x);
   method Action getDataFromMAC(Data#(inN) x); 

   method ActionValue#(MsgComplexFVec#(out)) toAnalogTX();
endinterface

//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Kermin Fleming, kfleming@mit.edu 
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
import MD6Parameters::*;
import MD6Types::*;
import CompressionFunctionTypes::*;

// The following are magic, externally defined parameters in MD6
// Other important parameters are derived from them.
// These parameters are used solely within the compression 
// function.

function MD6Word s0();
  return truncateLSB(64'h0123456789abcdef);
endfunction

function MD6Word sStar();
  return truncateLSB(64'h7311c2812425cfa0);
endfunction

// These tables are all of size 16. MD6 does not have a definition for 
// Non-size 16 value of MD6_c 
ShiftFactor c64ShiftR[16] = {4,11,10,32,13,3,10,23,22,6,5,12,15,1,18,28};

ShiftFactor c64ShiftL[16] = {5,6,19,4,8,9,24,15,7,3,20,29,13,3,15,14};

ShiftFactor c32ShiftR[16] = {7,13,1,8,15,3,16,13,2,3,13,9,7,10,2,4};

ShiftFactor c32ShiftL[16] = {15,12,3,16,10,7,5,9,4,9,16,12,11,5,1,13};

ShiftFactor c16ShiftR[16] = {7,4,1,7,2,1,5,7,2,1,7,1,2,7,7,8};

ShiftFactor c16ShiftL[16] = {3,5,2,2,4,5,3,4,6,5,4,2,3,2,6,5};

ShiftFactor c8ShiftR[16] = {1,1,2,1,2,3,2,3,1,3,2,2,1,1,4,2};

ShiftFactor c8ShiftL[16] = {3,2,4,3,3,4,1,1,2,4,4,3,4,2,3,3};





// This is the sqrt(6) vector value.  It should probably be longer than this
Bit#(TMul#(16,64)) vectorQ = {
               64'h8b30ed2e9956c6a0,
               64'h0d6f3522631effcb,
               64'h3b72066c7a1552ac,
               64'hc878c1dd04c4b633,
               64'h995ad1178bd25c31, 
               64'h8af8671d3fb50c2c,
               64'h3e7f16bb88222e0d,
               64'h4ad12aae0a6d6031,
               64'h54e5ed5b88e3775d,
               64'h1f8ccf6823058f8a,
               64'h0cd0d63b2c30bc41, 
               64'hdd2e76cba691e5bf,
               64'he8fb23908d9f06f1,
               64'hb60450e9ef68b7c1,
               64'h6432286434aac8e7,
               64'h7311c2812425cfa0};

//This might well be enormous. 
function MD6Word getQWord(Bit#(TLog#(MD6_q)) index);
   Bit#(TLog#(TMul#(MD6_q,MD6_WordWidth))) baseIndex = fromInteger(valueof(MD6_WordWidth))*zeroExtend(index);
   return vectorQ[(baseIndex+fromInteger(valueof(MD6_WordWidth)-1)):baseIndex];
endfunction

function MD6Word extractWord(Bit#(n) bitVector, Bit#(m) index)
  provisos(
            Add#(a,m,TAdd#(m,TLog#(MD6_WordWidth))));
   Bit#(TAdd#(m,TLog#(MD6_WordWidth))) baseIndex = fromInteger(valueof(MD6_WordWidth))*zeroExtend(index);
   return bitVector[(baseIndex+fromInteger(valueof(MD6_WordWidth)-1)):baseIndex];
endfunction


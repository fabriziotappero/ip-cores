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
import Vector::*;

import MD6Parameters::*;
import MD6Types::*;
import CompressionFunctionTypes::*;
import CompressionFunctionParameters::*;


// The following are magic, externally defined parameters in MD6
// Other important parameters are derived from them.
// These parameters are used solely within the compression 
// function.

// This set of functions determines the locations of the filter taps 
// these index into the constant array given in appendix C of the spec.
// TODO: kfleming - these are currently constant functions.
function Integer determineT0();
  Integer returnValue = 0;
  if((valueof(MD6_n) == 89) && (valueof(MD6_c) == 16))
    begin 
      returnValue = 17;
    end
  else if((valueof(MD6_n) == 178) && (valueof(MD6_c) == 32))
    begin
      returnValue = 33;
    end
  else
    begin
      let err = error("T0 not defined");
    end
  return valueof(MD6_n)-returnValue;
endfunction

function Integer determineT1();
  Integer returnValue = 0;
  if((valueof(MD6_n) == 89) && (valueof(MD6_c) == 16))
    begin 
      returnValue = 18;
    end
  else if((valueof(MD6_n) == 178) && (valueof(MD6_c) == 32))
    begin
      returnValue = 35;
    end
  else
    begin
      let err = error("T1 not defined");
    end
  return valueof(MD6_n)-returnValue;
endfunction

function Integer determineT2();
  Integer returnValue = 0;
  if((valueof(MD6_n) == 89) && (valueof(MD6_c) == 16))
    begin
      returnValue = 21;
    end
  else if((valueof(MD6_n) == 178) && (valueof(MD6_c) == 32))
    begin
      returnValue = 49;
    end
  else
    begin
      let err = error("T2 not defined");
    end
  return valueof(MD6_n)-returnValue;
endfunction

function Integer determineT3();
  Integer returnValue = 0;
  if((valueof(MD6_n) == 89) && (valueof(MD6_c) == 16))
    begin
      returnValue = 31;
    end
  else if((valueof(MD6_n) == 178) && (valueof(MD6_c) == 32))
    begin
      returnValue = 53;
    end
  else
    begin
      let err = error("T3 not defined");
    end
  return valueof(MD6_n)-returnValue;
endfunction

function Integer determineT4();
  Integer returnValue = 0;
  if((valueof(MD6_n) == 89) && (valueof(MD6_c) == 16))
    begin
      returnValue = 67;
    end
  else if((valueof(MD6_n) == 178) && (valueof(MD6_c) == 32))
    begin
      returnValue = 111;
    end
  else
    begin
      let err = error("T4 not defined");
    end
  return valueof(MD6_n)-returnValue;
endfunction

function Integer determineT5();
  return 0;
endfunction

// This function returns the shift amounts.  The argument is the step
// index.

function ShiftFactor shiftIndexR(Bit#(4) index);
  if(valueof(MD6_WordWidth) == 64)
    begin 
      return c64ShiftR[index];
    end
  else if(valueof(MD6_WordWidth) == 32)
    begin
      return c32ShiftR[index];
    end
  else if(valueof(MD6_WordWidth) == 16)
    begin
      return c16ShiftR[index];
    end
  else if(valueof(MD6_WordWidth) == 8)
    begin
      return c8ShiftR[index];
    end
  else
    begin
      return 0;
    end
endfunction

function ShiftFactor shiftIndexL(Bit#(4) index);
  if(valueof(MD6_WordWidth) == 64)
    begin 
      return c64ShiftL[index];
    end
  else if(valueof(MD6_WordWidth) == 32)
    begin
      return c32ShiftL[index];
    end
  else if(valueof(MD6_WordWidth) == 16)
    begin
      return c16ShiftL[index];
    end
  else if(valueof(MD6_WordWidth) == 8)
    begin
      return c8ShiftL[index];
    end
  else
    begin
      return 0;
    end
endfunction

function Vector#(MD6_u, MD6Word) makeControlWord(Round rounds, 
                              TreeHeight maxTreeHeight,
                              LastCompression lastCompression,
                              PaddingBits paddingBits,
                              KeyLength keyLength,
                              DigestLength digestLength)
  provisos(Bits#(MD6Word, md6_size));
  Bit#(64) controlWord = {4'b0000,rounds,maxTreeHeight,lastCompression,
          paddingBits,keyLength, digestLength};
  MD6Word controlArray[valueof(MD6_u)];  
  for(Integer i = 0; i < valueof(MD6_u); i = i + 1)
    begin
      controlArray[fromInteger(i)] = controlWord[(i+1)*valueof(md6_size)-1:i*valueof(md6_size)];
    end
  Vector#(MD6_u, MD6Word) controlVector = arrayToVector(controlArray);
  return controlVector;
endfunction
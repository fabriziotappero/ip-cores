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
import FIFOF::*;
import MD6Parameters::*;
import MD6Types::*;
import CompressionFunctionTypes::*;
import CompressionFunctionParameters::*;
import CompressionFunctionLibrary::*;
import Debug::*;
import SGenerator::*;
import Vector::*;

interface MD6ShiftRegister#(numeric type taps);
  method Vector#(taps,MD6Word) getT0;
  method Vector#(taps,MD6Word) getT1;
  method Vector#(taps,MD6Word) getT2;
  method Vector#(taps,MD6Word) getT3;
  method Vector#(taps,MD6Word) getT4;
  method Vector#(taps,MD6Word) getT5;
  method Action write(Vector#(taps,MD6Word) nextValues);
  method Action advance();
//  method Action advanceB();
  interface Vector#(MD6_n, Reg#(MD6Word)) regs;
endinterface


module mkMD6ShiftRegister (MD6ShiftRegister#(taps))
  provisos(Add#(taps,yyy,MD6_n));
  Integer historyLength = valueof(taps);
  Vector#(MD6_n,Reg#(MD6Word)) t0 <- replicateM(mkReg(0));
  // we pulled out a subtraction of history length  
  method Vector#(taps,MD6Word) getT0;
    return takeAt(determineT0,readVReg(t0));
  endmethod 
 
  method Vector#(taps,MD6Word) getT1;
    return  takeAt(determineT1,readVReg(t0));
  endmethod

  method Vector#(taps,MD6Word) getT2;
    return  takeAt(determineT2,readVReg(t0));
  endmethod 

  method Vector#(taps,MD6Word) getT3;
    return  takeAt(determineT3,readVReg(t0));
  endmethod 

  method Vector#(taps,MD6Word) getT4;
    return  takeAt(determineT4,readVReg(t0));
  endmethod  

  method Vector#(taps,MD6Word) getT5;
    return  takeAt(determineT5,readVReg(t0));
  endmethod 

  method Action  write(Vector#(taps,MD6Word) nextword);
    writeVReg(takeAt(valueof(MD6_n)-valueof(taps),t0),nextword);
  endmethod 

  method Action advance();
    for(Integer i = 0; i < valueof(MD6_n); i=i+1)
      begin
//        $display("Advance ShiftState[%d]: %h",i, t0[i]);
      end
    for(Integer i = 0; i < valueof(MD6_n)-valueof(taps); i=i+1)
      begin
        t0[i] <= t0[i+valueof(taps)]; 
      end
  endmethod 

/* This may no longer be necessary
  method Action advanceB();
    for(Integer i = valueof(MD6_n) - valueof(MD6_b); i < valueof(MD6_n) - valueof(taps); i=i+1)
      begin
        //$display("advanceB ShiftState[%d]: %h <= %h",i, t0[i+valueof(taps)],t0[i]);
        t0[i+valueof(taps)] <= t0[i];
      end
  endmethod
*/

  interface regs = t0;
 
endmodule
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
// CSG includes
import Debug::*;

// Local includes
import MD6Parameters::*;
import MD6Types::*;
import CompressionFunctionTypes::*;
import CompressionFunctionParameters::*;

Bool sgenDebug = False;

interface SGenerator;
  method MD6Word getS();
  method Action advanceRound();
  method Action resetS();
endinterface


module mkSGeneratorLogic (SGenerator);
  Reg#(MD6Word) s <- mkReg(s0()); // Grab S0 from parameters
  
  method MD6Word getS();
    return s;
  endmethod

  method Action advanceRound();
    MD6Word sRotate = (s << 1) | zeroExtend(s[valueof(MD6_WordWidth)-1]);
    MD6Word nextS =  sRotate ^ (s & sStar());
    s <= nextS;
    debug(sgenDebug,$display("Advancing s, old s: %h, new s:%h", s, nextS));
  endmethod

  method Action resetS();
    s <= s0();
  endmethod
  
endmodule

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
//BSC Library includes
import Vector::*;

// CSG includes
import Debug::*;

// Local includes
import MD6Parameters::*;
import MD6Types::*;
import CompressionFunctionTypes::*;
import CompressionFunctionParameters::*;

Bool sgenDebug = False;

interface SGenerator#(numeric type size);
  method Vector#(size,MD6Word) getS();
  method Action advanceRound();
  method Action resetS();
endinterface


function MD6Word advanceRoundComb(MD6Word s);
  MD6Word sRotate = (s << 1) | zeroExtend(s[valueof(MD6_WordWidth)-1]);
  MD6Word nextS =  sRotate ^ (s & sStar());
  return nextS;
endfunction 


 

module mkSGeneratorLogic (SGenerator#(size));
  Vector#(size,Reg#(MD6Word)) s = newVector; // Grab S0 from parameters

  function applyN(f,arg,n);
    MD6Word seed = arg;
    for(Integer j =0; j < n; j = j+1)   
      begin
        seed = f(seed);
      end
    return seed;
  endfunction


  for(Integer i = 0; i < valueof(size); i = i+1) 
    begin
      s[i] <- mkReg(applyN(advanceRoundComb,s0(),i));
    end

  method Vector#(size,MD6Word) getS();
    return readVReg(s);
  endmethod

  method Action advanceRound();
    MD6Word seed = s[valueof(size)-1];
    $display("Calling advance Round");
    for(Integer i = 0; i < valueof(size); i = i+1) 
      begin
        MD6Word nextSeed = advanceRoundComb(seed);
        debug(sgenDebug,$display("Size: %d, Advancing s, old s: %h, new s:%h", valueof(size),s[i], nextSeed));
        s[i] <= nextSeed; // How did this work before??
        seed = nextSeed; 
      end
  endmethod

  method Action resetS();
    for(Integer i = 0; i < valueof(size); i = i+1) 
     begin
       s[i] <= applyN(advanceRoundComb,s0(),i);
     end
  endmethod
  
endmodule

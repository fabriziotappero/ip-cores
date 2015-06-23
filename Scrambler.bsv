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




// *************************************************************************
//  Scrambler.bsv 
// *************************************************************************
import DataTypes::*;
import Interfaces::*;

import LibraryFunctions::*;
import FIFO::*;


interface Scrambler#(type n);
   //inputs
   method Action fromControl(RateData#(n) x);

   //outputs
   method ActionValue#(RateData#(n))  toEncoder(); 
endinterface

(* synthesize *)
module mkScrambler_48(Scrambler#(24));
   let _s <- mkScrambler();
   return (_s);
endmodule

module mkScrambler(Scrambler#(n));

  Reg#(Bit#(7))       seqR <- mkRegU;
  FIFO#(RateData#(n)) outQ <- mkFIFO();

  method Action fromControl(RateData#(n) x);
     Bit#(7) headSeq = case (x.rate)
			  R1   : return 7'b1001011;
			  R2   : return 7'b1001011;
			  R4   : return 7'b1001011;
			  RNone: return seqR;
		       endcase;
   
     Bit#(7) scram_seq = headSeq;
   
     Bit#(1) newS;
     Bit#(n) inData  = x.data;
     Bit#(n) outData = 0;
     
     for(Integer i = 0; i < valueOf(n); i = i + 1)
	begin
	   newS = scram_seq[0] ^ scram_seq[3];
	   outData[i] = newS ^ inData[i];
	   scram_seq = {newS,scram_seq[6:1]};
	end       
   
     outQ.enq(RateData{
	rate: x.rate,
	data: outData
	});	     
	
   endmethod

   method ActionValue#(RateData#(n)) toEncoder();
      outQ.deq();
      return(outQ.first());
   endmethod

endmodule

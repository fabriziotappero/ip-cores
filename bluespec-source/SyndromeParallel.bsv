//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2010 Abhinav Agarwal, Alfred Man Cheuk Ng
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

import FIFO::*;
import GFArith::*;
import GFTypes::*;
import Vector::*;

// ---------------------------------------------------------
// Reed-Solomon Syndrome calculator interface 
// ---------------------------------------------------------
interface ISyndrome;
   method Action                         n_in(Byte n_new); // dynamic n (shorten/punctured codeword)
   method Action                         r_in(Byte datum);

   method ActionValue#(Syndrome#(TwoT))  s_out();
endinterface

// ---------------------------------------------------------
// Reed-Solomon Syndrome calculation module 
// ---------------------------------------------------------
(* synthesize *)
module mkSyndromeParallel(ISyndrome);

   Reg#(Syndrome#(32))     syndrome       <- mkReg(replicate(0));
   FIFO#(Byte)             n_q            <- mkSizedFIFO(2);
   Reg#(Byte)              i              <- mkReg(0);
   Reg#(Byte)              block_number   <- mkReg(1);
   
   let n = n_q.first();

   // ------------------------------------------------
   method Action r_in (Byte datum) if (i < n);
      $display ("  [syndrome %d]  r_in (%d): %d", block_number, i, datum);
      Syndrome#(TwoT) syndrome_temp = replicate(0);
      
      for (Byte x = 0; x < fromInteger(valueOf(TwoT)); x = x + 1)
         begin
            syndrome_temp[x] = times_alpha_n(syndrome[x], x + 1);
            syndrome_temp[x] = gf_add(syndrome_temp[x], datum);
         end
      
      syndrome <= syndrome_temp;
      i <= i + 1;
   endmethod

   // ------------------------------------------------
   method ActionValue#(Syndrome#(TwoT)) s_out() if (i == n);
      $display ("  [syndrome %d]  s_out", block_number);
   
      // consider the next n
      n_q.deq(); 
      // reset state
      i <= 0;
      syndrome <= replicate(0);
      // incr block_numer (just for bookkeeping)
      block_number <= block_number + 1;
      return syndrome;
   endmethod
   
   // ------------------------------------------------
   method Action n_in (Byte n_new);
      $display ("  [syndrome %d]  n_in : %d", block_number, n_new);

      n_q.enq(n_new);
   endmethod
   
endmodule




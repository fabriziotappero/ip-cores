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

import GFArith::*;
import GFTypes::*;
import Vector::*;
import GetPut::*;
import FIFO::*;

// ---------------------------------------------------------
// Reed-Solomon error corrector interface 
// ---------------------------------------------------------
interface IErrorCorrector;
   method Action              r_in (Byte datum);
   method Action              e_in (Byte datum);
   method Action              k_in (Byte k_new);
   method Action              no_error_flag_in (Bool no_error);

   method ActionValue#(Byte)  d_out ();
endinterface

// ---------------------------------------------------------
// Reed-Solomon error corrector module 
// ---------------------------------------------------------
(* synthesize *)
module mkErrorCorrector (IErrorCorrector);

   FIFO#(Byte)      r              <- mkSizedFIFO(2);
   FIFO#(Byte)      e              <- mkSizedFIFO(2);
   FIFO#(Byte)      d              <- mkSizedFIFO(2);
   FIFO#(Byte)      k              <- mkSizedFIFO(1);
   FIFO#(Bool)      no_error_flag  <- mkSizedFIFO(1);
   Reg#(Byte)       e_cnt          <- mkReg(0);
   Reg#(Byte)       block_number   <- mkReg(0);

   rule d_no_error (e_cnt < k.first() && no_error_flag.first());
      $display ("  [error corrector %d] No Error processing", block_number);
      r.deq();
      d.enq(r.first());
      if (e_cnt == k.first()-1)
	 begin
	    block_number <= block_number + 1;
            k.deq();
            no_error_flag.deq();
            e_cnt <= 0;
	 end
      else
         e_cnt <= e_cnt + 1;
   endrule

   rule d_corrected (e_cnt < k.first() && !no_error_flag.first());
      $display ("  [error corrector %d]  Correction processing", block_number);
      r.deq();
      e.deq();
      d.enq(r.first() ^ e.first());
      if (e_cnt == k.first()-1)
	 begin
	    block_number <= block_number + 1;
            k.deq();
            no_error_flag.deq();
            e_cnt <= 0;
	 end
      else
         e_cnt <= e_cnt + 1;
   endrule

   // ------------------------------------------------
   method Action r_in (Byte datum);
      $display ("  [error corrector %d]  r_in : %d)", block_number, datum);
      r.enq(datum);
   endmethod

   // ------------------------------------------------
   method Action e_in (Byte datum);
      e.enq(datum);
      $display ("  [error corrector %d]  Valid e_in : %d)", block_number, datum);
   endmethod

   // ------------------------------------------------
   method Action k_in (Byte k_new);
      $display ("  [error corrector %d]  k_in : %d", block_number, k_new);

      k.enq(k_new);
   endmethod

   // ------------------------------------------------
   method Action no_error_flag_in (Bool no_error);
      $display ("  [error corrector %d]  no_error : %d", block_number, no_error);

      no_error_flag.enq(no_error);
   endmethod

   // ------------------------------------------------
   method ActionValue#(Byte) d_out ();
      $display ("  [error corrector %d]  d_out (%d)", block_number, d.first());
      
      d.deq();
      return d.first();
   endmethod

endmodule




//----------------------------------------------------------------------//
// The MIT License 
// 
// Copyright (c) 2008 Alfred Man Cheuk Ng, mcn02@mit.edu 
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
import FIFOF::*;
import FIFOF_::*;

/***
 *
 * This module serves as a simple bluespec wrapper for
 * the verilog based BRAMFIFO.  The imported methods support
 * the standard FIFOF and FIFO classes.  It should be noted that
 * the underlying verilog implementation is gaurded.
 *
 ***/


module mkBRAMFIFO#(Integer count) (FIFO#(fifo_type))
  provisos
          (Bits#(fifo_type, fifo_size));
  FIFOF#(fifo_type) fifo <- mkBRAMFIFOF(count);
 
  method Action enq(fifo_type data);
    fifo.enq(data);
  endmethod 

  method Action deq();
    fifo.deq();
  endmethod 
  
  method fifo_type first();
    return fifo.first();  
  endmethod

  method Action clear();
    fifo.clear();
  endmethod

endmodule

module mkBRAMFIFOF#(Integer count) (FIFOF#(fifo_type))
  provisos
          (Bits#(fifo_type, fifo_size));
  FIFOF_#(fifo_type) fifo <- mkBRAMFIFOF_(count);
  
  method Action enq(fifo_type data) if(fifo.i_notFull);
    fifo.enq(data);
  endmethod 

  method Action deq() if(fifo.i_notEmpty);
    fifo.deq();
  endmethod 
  
  method fifo_type first() if(fifo.i_notEmpty);
    return fifo.first();  
  endmethod

  method Bool notFull;
    return fifo.notFull;
  endmethod

  method Bool notEmpty;
    return fifo.notEmpty;
  endmethod

  method Action clear();
    fifo.clear();
  endmethod
 

endmodule


import "BVI" BRAMFIFOF = module mkBRAMFIFOF_#(Integer count) 
  //interface:
              (FIFOF_#(fifo_type)) 
  provisos
          (Bits#(fifo_type, fifo_size));

  default_clock clk(CLK);

  parameter                   log_data_count = log2(count);
  parameter                   data_count = count;
  parameter                   data_width = valueOf(fifo_size);

  method enq((* reg *)D_IN) enable(ENQ);
  method deq() enable(DEQ);
  method (* reg *)D_OUT first;
  method FULL_N   notFull;
  method FULL_N i_notFull;
  method (* reg *)EMPTY_N   notEmpty;
  method (* reg *)EMPTY_N i_notEmpty;
  method clear() enable(CLR);
  
  schedule deq CF (enq, i_notEmpty, i_notFull) ;
  schedule enq CF (deq, first, i_notEmpty, i_notFull) ;
  schedule (first, notEmpty, notFull) CF
             (first, i_notEmpty, i_notFull, notEmpty, notFull) ;
  schedule (i_notEmpty, i_notFull) CF
              (clear, first, i_notEmpty, i_notFull, notEmpty, notFull) ;
  schedule (clear, deq, enq) SBR clear ;
  schedule first SB (clear, deq) ;
  schedule (notEmpty, notFull) SB (clear, deq, enq) ;


  /*schedule first SB (deq,enq,clear);
  schedule first CF (first,notFull,notEmpty);
   
  schedule notFull SB (deq,enq,clear);
  schedule notFull CF (first,notFull,notEmpty);  

  schedule notEmpty SB (deq,enq,clear);
  schedule notEmpty CF (first,notFull,notEmpty);
  
  schedule deq CF enq; 
  schedule deq SB clear;
  schedule deq C  deq;

  schedule enq CF deq; 
  schedule enq SB clear;
  schedule enq C  enq;
 
  schedule clear C clear;*/
  
endmodule



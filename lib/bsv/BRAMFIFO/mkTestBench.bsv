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

import BRAMFIFO::*;
import FIFOF::*;
import FIFO::*;

/***
 * 
 * This module is a test harness for the BRAMFIFO verilog module.
 * The module compares the behavior of a BRAM based sized FIFO and a 
 * standard sized fifo.  If their behavior differs at any point during the 
 * long pseudo-random test bench, then a failure message is displayed.
 *
 ***/ 


(* synthesize *)
module mkTest (FIFOF#(Bit#(32)));
  FIFOF#(Bit#(32)) gold <- mkBRAMFIFOF(250);
  FIFO#(Bit#(32)) p <- mkSizedFIFO(6);  
  return gold;
endmodule


module mkTestBench ();
  Reg#(Bit#(32)) test_counter <- mkReg(0);

  rule test_counter_rl;
    test_counter <= test_counter + 1;
    if(test_counter > 1000000)
      begin
        $display("PASS");
        $finish;
      end
  endrule

  for(Integer i = 2; i < 4; i = i + 1)
     begin
       FIFO#(Bit#(32)) gold <- mkSizedFIFO(i);
       FIFO#(Bit#(32)) test <- mkBRAMFIFO(i);
       Reg#(Bit#(32)) counter <- mkReg(0);        

       rule count;
         counter <= counter + 1;
       endrule

       rule enq_a(counter % fromInteger(i) == 0);
         gold.enq(counter);
       endrule

       rule enq_b(counter % fromInteger(i) == 0);
         test.enq(counter);
       endrule 
     
       for(Integer j = 2; j < 4; j = j+1)
          begin
            rule deq_check(zeroExtend(counter)%fromInteger(j) == 0);
              if(gold.first() != test.first())
                begin
                  $display("FAIL Not equal! g: %d t: %d i: %d j: %d", gold.first, test.first, i, j);
                end
              else
                begin
                  $display("Match: %d i:%d j:%d", gold.first, i,j);
                end

                gold.deq;
                test.deq; 
               
             endrule 
          end       
     end

endmodule
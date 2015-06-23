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
import GetPut::*;
import GFTypes::*;
import mkReedSolomon::*;

import Transfer::*;

typedef enum{ ReadN, ReadT, ReadD } FPGAState deriving (Eq, Bits);

// ---------------------------------------------------------
// FPGA Reed-Solomon Wrapper module
// ---------------------------------------------------------
(* synthesize *)
module mkfuncunit (ProcSide);
   
   Transfer transfer <- mkTransfer();
   IReedSolomon       decoder <- mkReedSolomon();
   Reg#(FPGAState)    state   <- mkReg(ReadN);
   Reg#(Byte)         n       <- mkReg(0);
   
   rule readN(state == ReadN);
      let inData <- transfer.funcSideGet.get();
      n <= truncate(inData);
      state <= ReadT;

      $display(" [mkFPGAReedSolomon] readN n : %d", inData);
   endrule
   
   rule readT(state == ReadT);
      let inData <- transfer.funcSideGet.get();
      let t = truncate(inData);
      let k = n - 2 * t;
      
      decoder.rs_t_in.put(t);
      decoder.rs_k_in.put(k);
      state <= ReadD;

      $display(" [mkFPGAReedSolomon] readT t : %d", inData);
   endrule   
   
   rule readD(state == ReadD);
      let inData <- transfer.funcSideGet.get();
      decoder.rs_input.put(truncate(inData));
      n <= n - 1;
      if (n == 1) // last element, start to ReadN again
         state <= ReadN;

      $display(" [mkFPGAReedSolomon] readD i : %d, data in : %d", n, inData);
   endrule
   
   rule discardFlag(True);
      let rs_flag <- decoder.rs_flag.get();

      $display(" [mkFPGAReedSolomon] discardFlag flag : %d", rs_flag);
   endrule

   rule enqOut(True);
      let datum <- decoder.rs_output.get();
      transfer.funcSidePut.put(zeroExtend(datum));
      
      $display(" [mkFPGAReedSolomon] enqOut data out : %d", datum);
   endrule
   
   return transfer.procSide();
   
endmodule

/*
Copyright (c) 2008 MIT

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

Author: Myron King
*/
import Memocode08Types ::*;
import ExternalMemory  ::*;
import PLBMasterDummy  ::*;
import Interfaces      ::*;
import StmtFSM         ::*;
import GetPut          ::*;
import Vector          ::*;
import FIFO            ::*;
import Four2OneMerger  ::*;

typedef Bit#(TLog#(RecordsPerMemRequest)) RpmrBits;

module mkEMTB (Empty);
   
   let recwid        = fromInteger(valueOf(RecordWidth));   
   let rpmr          = fromInteger(valueOf(RecordsPerMemRequest));
   RpmrBits rpmr_msk = 0;
   
   PLBMaster dummy       <- mkPLBMasterDummy();
   ExternalMemory extMem <- mkExternalMemory(dummy);
   Reg#(Bit#(32)) count  <- mkReg(0);
   Reg#(int) state       <- mkReg(0);
   Reg#(Bool) need_req   <- mkReg(True);

   rule get_mem((state==0)&&!need_req);
      RpmrBits tr = truncate(count+1);
      if(truncate(count+1)==rpmr_msk)
	 need_req <= True;
      let a <- extMem.read[0].read();
      $display(a);
      count <= count+1;
      if(count+1==8192)
	 state<=1;
   endrule
   
   rule req_mem((state==0)&&need_req);
      extMem.read[0].readReq(count*recwid/8);
      need_req <= False;
   endrule   
   
   rule fin(state==1);
      $finish();
   endrule
   
endmodule


module mk421TB (Empty);
   
   Four2One merger <- mkFour2One();
   Reg#(Bool) started <- mkReg(False);
   
   
   Stmt feeder = 
   (seq
       merger.in[0].put(0);
       merger.in[1].put(0);
       merger.in[2].put(0);
       merger.in[3].put(0);
    
       merger.in[0].put(1);
       merger.in[1].put(2);
       merger.in[2].put(3);
       merger.in[3].put(4);
    
       
       merger.in[0].put(4);
       merger.in[1].put(3);
       merger.in[2].put(2);
       merger.in[3].put(1);
    
       merger.in[0].put(4);
       merger.in[1].put(3);
       merger.in[2].put(1);
       merger.in[3].put(2);
    
    endseq);

   FSM ffsm <- mkFSM(feeder);
   
   rule start (!started);
      $display("start merge");
      ffsm.start();
      started <= True;
   endrule
   
   
   rule get_stuff (True);
      let a <- merger.out.get();
      $display(a);
   endrule
   
endmodule

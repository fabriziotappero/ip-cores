//----------------------------------------------------------------------//
//                          Qualcomm Proprietary                        //
//                     Copyright (c) 2006 Qualcomm Inc.                 //
//                          All rights reserved.                        //
//----------------------------------------------------------------------//
//        File: $RCSfile: NewBRAMFIFO.bsv,v $
//      Author: Alfred Man Cheuk Ng, Abhinav Agarwal
//     Created: 2007-07-13
// Description: FIFO and FIFOF implemented using BRAM, default 4 elements
//
//----------------------------------------------------------------------//
// $Id: NewBRAMFIFO.bsv,v 1.1 2008-06-30 16:02:10 kfleming Exp $
//----------------------------------------------------------------------//

import BRAM::*;
import EHRReg::*;
import FIFO::*;
import FIFOF::*;

// schedule = (notEmpty = first < deq < notFull < enq) C clear 
module mkNewBRAMFIFOF(FIFOF#(a))
   provisos (Bits#(a,asz));
   
   // state elements
   UGBRAM#(Bit#(8), a) bram  <- mkBypassUGBRAM_Full; // 256 elements memory storage
   EHRReg#(2,Bit#(8))  head  <- mkEHRReg(0);         // head pointer
   EHRReg#(2,Bit#(8))  tail  <- mkEHRReg(0);         // tail pointer
   EHRReg#(2,Bool)     over  <- mkEHRReg(False);     // negate everytime either head or tail overthrow
   Wire#(a)            resp  <- mkDWire(?);          //
   
   // signals
   let canDeq = head[0] != tail[0] || over[0];
   let canEnq = head[0] != tail[0] || !over[0];      // cannot enq and deq simutaneously when full
   
   // rules
   rule prefetchHead(True);
      bram.read_req(head[1]);
   endrule
   
   rule getReadresp(True);
      resp <= bram.read_resp;
   endrule
   
   // interface methods
   method Action enq(a x) if (canEnq);
      bram.write(tail[1],x);
      if (tail[1] == maxBound) // max idx, wrap around ptr
         begin
            tail[1] <= 0;
            over[1] <= !over[1];
         end
      else
         tail[1] <= tail[1] + 1;
   endmethod
   
   method a first() if (canDeq);
      return resp;
   endmethod
   
   method Action deq() if (canDeq);
      if (head[0] == maxBound)
         begin
            head[0] <= 0;
            over[0] <= !over[0];
         end
      else
         head[0] <= head[0] + 1;
   endmethod
   
   method Bool notEmpty();
      return canDeq;
   endmethod
   
   method Bool notFull();
      return canEnq;
   endmethod
  
   method Action clear();
      head[0] <= 0;
      tail[1] <= 0;
      over[1] <= False;
   endmethod                                      
   
endmodule

// schedule = (first < deq < enq) C clear 
module mkNewBRAMFIFO(FIFO#(a))
   provisos (Bits#(a,asz));
   
   // state elements
   FIFOF#(a) fifo <- mkNewBRAMFIFOF;

   // interface methods
   method Action enq(a x) = fifo.enq(x);
   method a      first()  = fifo.first; 
   method Action deq()    = fifo.deq;
   method Action clear()  = fifo.clear;
   
endmodule
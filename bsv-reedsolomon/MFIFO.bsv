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

import FIFOF::*;
import RWire::*;

// -------------------------------------------------------------------
// MFIFO Interface: a fifo allow to the value of the first element to be modified 
// -------------------------------------------------------------------

interface MFIFO#(numeric type sz, type a);
   method    Action  enq(a in);
   method    Action  deq();
   method    Action  clear();
   interface Reg#(a) first;
endinterface

interface MFIFOF#(numeric type sz, type a);
   method    Action  enq(a in);
   method    Action  deq();
   method    Action  clear();
   method    Bool    notEmpty();
   method    Bool    notFull();
   interface Reg#(a) first;
endinterface

// ---------------------------------------------------------
// MFIFO module
// ---------------------------------------------------------
// a mfifof of size 1
module mkMFIFOF1 (MFIFOF#(1,a))
   provisos (Bits#(a,a_sz));
   
   Reg#(Maybe#(a)) buffer <- mkReg(tagged Invalid);
   RWire#(a)       upW    <- mkRWire();
   RWire#(Bit#(0)) deqW   <- mkRWire();
   
   rule writeBuffer(isValid(upW.wget())
                    || isValid(deqW.wget()));
      if (isValid(deqW.wget()))
         buffer <= tagged Invalid;
      else
         buffer <= tagged Valid fromMaybe(?,upW.wget());
   endrule
   
   method Action enq(a in) if (!isValid(buffer));
      buffer <= tagged Valid in;
   endmethod
   
   method Action deq() if (isValid(buffer));
      deqW.wset(?);
   endmethod
   
   method Action clear();
      buffer <= tagged Invalid;
   endmethod
   
   method Bool notEmpty();
      return isValid(buffer);
   endmethod
   
   method Bool notFull();
      return !isValid(buffer);
   endmethod
   
   interface Reg first;
      method Action _write(a in) if (isValid(buffer));
         upW.wset(in);
      endmethod
      
      method a _read() if (buffer matches tagged Valid .val);
         return val;
      endmethod
   endinterface

endmodule

// a mfifof of size > 1
module mkMFIFOF (MFIFOF#(sz,a))
   provisos (Add#(2,xxA,sz), // sz >= 2
             Bits#(a,a_sz));
   
   Reg#(Maybe#(a)) buffer <- mkReg(tagged Invalid);
   FIFOF#(a)       fifo   <- mkSizedFIFOF(valueOf(sz)-1);
   RWire#(a)       upW    <- mkRWire();
   RWire#(Bit#(0)) deqW   <- mkRWire();
   
   let isNotEmpty = isValid(buffer) || fifo.notEmpty;
   
   rule writeBuffer(True);
      if (isValid(deqW.wget()))
         buffer <= tagged Invalid;
      else
          if (isValid(upW.wget()))
             buffer <= tagged Valid fromMaybe(?,upW.wget());
          else
             if (!isValid(buffer))
                buffer <= tagged Valid fifo.first();            
      if (!isValid(buffer))
         fifo.deq();
   endrule
   
   method Action enq(a in);
      fifo.enq(in);
   endmethod
   
   method Action deq() if (isNotEmpty); 
      deqW.wset(?);
   endmethod
   
   method Action clear();
      fifo.clear();
      buffer <= tagged Invalid;
   endmethod

   method Bool notEmpty();
      return isNotEmpty;
   endmethod
   
   method Bool notFull();
      return fifo.notFull();
   endmethod

   interface Reg first;
      method Action _write(a in) if (isNotEmpty);
         upW.wset(in);
      endmethod

      method a _read() if (isNotEmpty);
         return isValid(buffer) ? fromMaybe(?,buffer) : fifo.first();
      endmethod
   endinterface
      
endmodule

// a mfifo of size 1
module mkMFIFO1 (MFIFO#(1,a))
   provisos (Bits#(a,a_sz));
   
   MFIFOF#(1,a) fifo <- mkMFIFOF1();
   
   method    Action enq(a in) = fifo.enq(in);
   method    Action deq()     = fifo.deq();
   method    Action clear()   = fifo.clear();
   interface Reg    first     = fifo.first;
endmodule

// a mfifo of size > 1
module mkMFIFO (MFIFO#(sz,a))
   provisos (Add#(2,xxA,sz), // sz >= 2
             Bits#(a,a_sz));
   
   MFIFOF#(sz,a) fifo <- mkMFIFOF();
   
   method    Action enq(a in) = fifo.enq(in);
   method    Action deq()     = fifo.deq();
   method    Action clear()   = fifo.clear();
   interface Reg    first     = fifo.first;
endmodule

// ---------------------------------------------------------
// MFIFO Test module
// ---------------------------------------------------------
//(* synthesize *)
(* execution_order = "updOrDeqFIFO, enqFIFO, incrCounter" *)
module mkMFIFOTest(Empty);
   
   Reg#(Bit#(16))      counter <- mkReg(0);
   MFIFO#(10,Bit#(16)) fifo    <- mkMFIFO();
   Reg#(Bit#(16))      fstElm   = fifo.first;
   
   rule enqFIFO(True);
      $display("enq fifo: %d",counter);
      fifo.enq(counter);
   endrule
   
   rule updOrDeqFIFO(True);
      if ((counter & 16'h0007) == 16'h0007)
         begin
            $display("deq fifo: %d",fstElm);
            fifo.deq();
         end
      else
         begin
            $display("update fifo: %d = %d * 3",fstElm * 3,fstElm);
            fstElm <= fstElm * 3;
         end
   endrule
   
   rule incrCounter(True);
      $display("cycle: %d",counter);
      $display("----------------------------------------------------------");
      if (counter == 1000)
         $finish();
      counter <= counter + 1;
   endrule
   
endmodule
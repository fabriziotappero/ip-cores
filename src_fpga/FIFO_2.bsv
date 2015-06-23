
// The MIT License

// Copyright (c) 2006-2007 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

package FIFO_2;
export FIFO_2(..);

export mkFIFO2;

import FIFOF::*;
import RWire::*;
import List::*;
import Monad::*;

interface FIFO_2 #(type t);
    method Bool has1i();
    method Bool has2i();
    method Bool space1i();
    method Bool space2i();
    method Action enq_1(t x1);
    method Action enq_2(t x1);
    method t first_1();
    method t first_2();
    method Action deq_1();
    method Action deq_2();
    method Action clear();
endinterface: FIFO_2


module mkFIFO2(FIFO_2#(t))
  provisos (Bits#(t, bt));

  function Bool pokeRWire(RWire#(z) x);
    begin
      case (x.wget) matches
           tagged Valid {.a}:  return(True);
           tagged Invalid  :  return(False);
      endcase
    end
  endfunction: pokeRWire

  List#(RWire#(t)) enq;
  enq <- mapM (constFn(mkRWire), upto(0, 1));

  List#(RWire#(Bit#(0))) deq;
  deq <- mapM (constFn(mkRWire), upto(0, 1));

  List#(FIFOF#(t)) fifos;
  fifos <- mapM (constFn(mkFIFOF), upto(0, 1));

  List#(RWire#(t)) fifosr;
  fifosr <- mapM (constFn(mkRWire), upto(0, 1));

  Reg#(Bit#(1)) head();
  mkReg#(0) the_head(head);

  Reg#(Bit#(1)) tail();
  mkReg#(0) the_tail(tail);

  rule doEnq (True);
     let predVals = map(pokeRWire, enq);
     Bit#(1) offset;
     function Bit#(1) foldfunc (Bit#(1) o, Bool x);
         return (x ? o+1 : o);
     endfunction: foldfunc

     offset = foldl(foldfunc, 0, predVals);

     function Action tryEnqr(RWire#(t) rf, RWire#(t) r);
       action
         case (r.wget) matches
              tagged Invalid : noAction;
              tagged Valid .v : rf.wset(v);
         endcase
       endaction
     endfunction: tryEnqr

     let efifo1r =  select(fifosr, ((Bit#(1))'(0)));
     let efifo2r =  select(fifosr, ((Bit#(1))'(1)));

     match {.enq1,.enq2} = tuple2(select(enq, tail + 0), select(enq, tail + 1));

     tryEnqr(efifo1r, enq1);
     tryEnqr(efifo2r, enq2);

     tail <= tail + offset;

  endrule: doEnq

  rule enq1(True);
    action
       let fifo1  = select(fifos , ((Bit#(1))'(0)));
       let fifo1r = select(fifosr, ((Bit#(1))'(0)));
       case (fifo1r.wget) matches
            tagged Invalid : noAction;
            tagged Valid .v : fifo1.enq (v);
       endcase
    endaction
  endrule: enq1

  rule enq2(True);
    action
       let fifo2  = select(fifos , ((Bit#(1))'(1)));
       let fifo2r = select(fifosr, ((Bit#(1))'(1)));
       case (fifo2r.wget) matches
            tagged Invalid : noAction;
            tagged Valid .v : fifo2.enq (v);
       endcase
    endaction
  endrule: enq2

  rule handle_Dequeues (True);
     let predVals =  map(pokeRWire, deq);
     Bit#(1) offset;

     function Bit#(1) foldfunc (Bit#(1) o, Bool x);
         return (x ? o+1 : o);
     endfunction: foldfunc

     offset = foldl(foldfunc, 0, predVals);

     function Action tryDeq(FIFOF#(t) f, RWire#(Bit#(0)) r);
       action
         case (r.wget) matches
              tagged Invalid : noAction;
              tagged Valid .a : f.deq();
        endcase
       endaction
     endfunction: tryDeq

     let dfifo1 =  select(fifos, ((Bit#(1))'(0)));
     let dfifo2 =  select(fifos, ((Bit#(1))'(1)));

     match {.deq1,.deq2} = tuple2(select(deq, head + 0), select(deq, head + 1));

     tryDeq(dfifo1, deq1);
     tryDeq(dfifo2, deq2);

     head <= head + offset;
  endrule: handle_Dequeues

  method enq_1(v) if (((select(fifos,0)).notFull) ||
                      ((select(fifos,1)).notFull)) ;
    action
      let enq1 = select(enq, ((Bit#(1))'(0)));
      enq1.wset(v);
    endaction 

  endmethod: enq_1

  method enq_2(v) if (((select(fifos,0)).notFull) && ((select(fifos,1)).notFull)) ;
    action
      let enq2 =  select(enq, ((Bit#(1))'(1)));
      enq2.wset(v);
    endaction
  endmethod: enq_2

  method deq_1() if (((select(fifos,0)).notEmpty) || ((select(fifos,1)).notEmpty)) ;
    action
      let deq1 =  select(deq, ((Bit#(1))'(0)));
      deq1.wset(?); // PrimUnit;
    endaction
  endmethod: deq_1

  method deq_2() if (((select(fifos,0)).notEmpty) && ((select(fifos,1)).notEmpty)) ;
    action
      let deq2 =  select(deq, ((Bit#(1))'(1)));
      deq2.wset (?); // Unit;
    endaction
  endmethod: deq_2

  method clear() ;
    action
      function Action clearfifo(FIFOF#(t) f);
        action
          f.clear();
        endaction
      endfunction: clearfifo
      List#(Action) lact;

      lact = map(clearfifo, fifos);
      head <= 0;
      tail <= 0;
      joinActions(lact);
    endaction
  endmethod: clear

  method first_1() if ((select(fifos, ((Bit#(1))'(0)))).notEmpty ||
                       (select(fifos, ((Bit#(1))'(1)))).notEmpty) ;
      let dfifo1 =  select(fifos, head + 0);
      return (dfifo1.first);
  endmethod: first_1

  method first_2() if ((select(fifos, ((Bit#(1))'(0)))).notEmpty &&
                      (select(fifos, ((Bit#(1))'(1)))).notEmpty) ;
      let dfifo2 =  select(fifos, head + 1);
      return (dfifo2.first);
  endmethod: first_2

  method has1i() ;
      return ((select(fifos, ((Bit#(1))'(0)))).notEmpty ||
              (select(fifos, ((Bit#(1))'(1)))).notEmpty);
  endmethod: has1i

  method has2i() ;
      return ((select(fifos, ((Bit#(1))'(0)))).notEmpty &&
              (select(fifos, ((Bit#(1))'(1)))).notEmpty);
  endmethod: has2i

  method space1i() ;
      return ((select(fifos, ((Bit#(1))'(0)))).notFull ||
              (select(fifos, ((Bit#(1))'(1)))).notFull);
  endmethod: space1i

  method space2i() ;
      return ((select(fifos, ((Bit#(1))'(0)))).notFull &&
              (select(fifos, ((Bit#(1))'(1)))).notFull);
  endmethod: space2i

endmodule: mkFIFO2


module mkTest(FIFO_2#(Bit#(2)));
  FIFO_2#(Bit#(2)) f();
  mkFIFO2 the_f(f);

  method enq_1();
     return (f.enq_1);
  endmethod: enq_1

  method enq_2();
     return (f.enq_2);
  endmethod: enq_2

  method first_1();
     return (f.first_1);
  endmethod: first_1

  method first_2();
     return (f.first_2);
  endmethod: first_2

  method deq_1();
     return (f.deq_1);
  endmethod: deq_1

  method deq_2();
     return (f.deq_2);
  endmethod: deq_2

  method clear();
     return (f.clear);
  endmethod: clear

  method has1i();
     return (f.has1i);
  endmethod: has1i

  method has2i();
     return (f.has2i);
  endmethod: has2i

  method space1i();
     return (f.space1i);
  endmethod: space1i

  method space2i();
     return (f.space2i);
  endmethod: space2i
endmodule: mkTest

endpackage: FIFO_2


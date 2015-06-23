
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

import FIFO::*;
import RegFile::*;
import GetPut::*;

interface BlueBRAM#(type idx_type, type data_type);

  method Action read_req(idx_type idx);

  method ActionValue#(data_type) read_resp();

  method Action	write(idx_type idx, data_type data);
  
endinterface


interface BlueBRAM_GetPut#(type idx_type, type data_type);
 
  interface Put#(idx_type) read_req;
  interface Get#(data_type) read_resp;
  interface Put#(Tuple2#(idx_type, data_type)) write;

endinterface

module mkBlueBRAM_GetPut (BlueBRAM_GetPut#(idx_type, data_type))
  provisos
          (Bits#(idx_type, idx), 
	   Bits#(data_type, data),
	   Literal#(idx_type),
           Bounded#(idx_type));
  BlueBRAM#(idx_type,data_type) bram <- mkBlueBRAM_Full();

  interface Put read_req;
    method put = bram.read_req;
  endinterface

  interface Get read_resp;
    method get = bram.read_resp;
  endinterface


  interface Put write;
    method Action put(Tuple2#(idx_type, data_type) indata);
      bram.write(tpl_1(indata), tpl_2(indata));
    endmethod
  endinterface

endmodule



module mkBlueBRAM#(Integer low, Integer high) 
  //interface:
              (BlueBRAM#(idx_type, data_type)) 
  provisos
          (Bits#(idx_type, idx), 
	   Bits#(data_type, data),
	   Literal#(idx_type),
           Bounded#(idx_type));
	   
  BlueBRAM#(idx_type, data_type) m <- (valueof(data) == 0) ? 
                                  mkBlueBRAM_Zero() :
				  mkBlueBRAM_NonZero(low, high);

  return m;
endmodule

module mkBlueBRAM_NonZero#(Integer low, Integer high) 
  //interface:
              (BlueBRAM#(idx_type, data_type)) 
  provisos
          (Bits#(idx_type, idx), 
	   Bits#(data_type, data),
	   Literal#(idx_type),
           Bounded#(idx_type));
  RegFile#(idx_type, data_type) arr <- mkRegFileFull();
  FIFO#(data_type) outfifo <- mkSizedFIFO(8);

  method Action read_req(idx_type idx);
    outfifo.enq(arr.sub(idx));
  endmethod

  method ActionValue#(data_type) read_resp();
    outfifo.deq();
    return outfifo.first();
  endmethod 

  method Action	write(idx_type idx, data_type data);  
    arr.upd(idx, data);
  endmethod
endmodule

module mkBlueBRAM_Zero
  //interface:
              (BlueBRAM#(idx_type, data_type)) 
  provisos
          (Bits#(idx_type, idx), 
	   Bits#(data_type, data),
	   Literal#(idx_type));
  
  FIFO#(data_type) q <- mkSizedFIFO(8);

  method Action read_req(idx_type i);
     q.enq(?);
  endmethod

  method Action write(idx_type i, data_type d);
    noAction;
  endmethod

  method ActionValue#(data_type) read_resp();
    q.deq();
    return q.first();
  endmethod

endmodule

module mkBlueBRAM_Full 
  //interface:
              (BlueBRAM#(idx_type, data_type)) 
  provisos
          (Bits#(idx_type, idx), 
	   Bits#(data_type, data),
	   Literal#(idx_type),
           Bounded#(idx_type));


  BlueBRAM#(idx_type, data_type) br <- mkBlueBRAM(0, valueof(TExp#(idx)) - 1);

  return br;

endmodule
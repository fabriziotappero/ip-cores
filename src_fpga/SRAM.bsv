
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

interface SRAM#(type idx_type, type data_type);
 
  method Action read_req(idx_type idx);

  method ActionValue#(data_type) read_resp();

  method Action	write(idx_type idx, data_type data);
  

  method Bit#(18) address_out();
  method Bit#(32) data_out();
  method Action data_in(Bit#(32) data);
  method Bit#(1) data_tri();
  method Bit#(4) we_bytes_out();
  method Bit#(1) we_out();
  method Bit#(1) ce_out();
  method Bit#(1) oe_out();
  method Bit#(1) cen_out();
  method Bit#(1) adv_ld_out();

endinterface


module mkSRAM#(Integer low, Integer high) 
  //interface:
              (SRAM#(idx_type, data_type))
  provisos
          (Bits#(idx_type, idx),
           Bitwise#(idx_type), 
	   Bits#(data_type, data),
           Bitwise#(data_type),
           Literal#(data_type),
	   Literal#(idx_type));
	   
  SRAM#(idx_type, data_type) m <- (valueof(data) == 0) ? 
                                   mkSRAM_Zero() :
				   mkSRAM_NonZero(low, high);

  return m;
endmodule

import "BVI" SRAM = module mkSRAM_NonZero#(Integer low, Integer high) 
  //interface:
              (SRAM#(idx_type, data_type))
  provisos
          (Bits#(idx_type, idx),
           Bitwise#(idx_type), 
	   Bits#(data_type, data),
           Bitwise#(data_type),
           Literal#(data_type),
	   Literal#(idx_type));

  default_clock clk(CLK);
  default_reset rst(RST_N);

  parameter addr_width = valueof(idx);
  parameter data_width = valueof(data);
  parameter lo = low;
  parameter hi = high;

  method DOUT read_resp() ready(DOUT_RDY) enable(DOUT_EN);
  
  method read_req(RD_ADDR) ready(RD_RDY) enable(RD_EN);
  method write(WR_ADDR, WR_VAL) enable(WR_EN);

  // All of these are physical wires and therefore always enabled/ready
  method ADDR_O address_out();
  method DATA_BUS_O data_out();
  method data_in(DATA_BUS_I) enable((*inhigh*) DUMMY_EN) ;
  method DATA_BUS_T data_tri();
  method WE_BYTES_N_O we_bytes_out();
  method WE_N_O we_out();
  method CE_N_O ce_out();
  method OE_N_O oe_out();
  method CEN_N_O cen_out();
  method ADV_LD_N_O adv_ld_out();

  schedule read_req  CF read_resp;
  schedule read_resp CF (read_req, write);
  schedule write     CF read_resp;
  schedule (read_req, write, read_resp) CF (address_out, data_out, data_in, data_tri, 
                                            we_bytes_out, we_out, ce_out, oe_out,
                                            cen_out, adv_ld_out);
  schedule (address_out, data_out, data_in, data_tri, 
            we_bytes_out, we_out, ce_out, oe_out,
            cen_out, adv_ld_out)
           CF 
           (address_out, data_out, data_in, data_tri, 
            we_bytes_out, we_out, ce_out, oe_out,
            cen_out, adv_ld_out, read_req, write, read_resp);

  //It may be dangerous not to have data_in conflict with itself.  
  schedule data_in   C data_in;
  schedule read_req  C (read_req, write);
  schedule read_resp C read_resp;
  schedule write     C (write, read_req);

endmodule

module mkSRAM_Zero
  //interface:
              (SRAM#(idx_type, data_type))
    provisos
          (Bits#(idx_type, idx),
           Bitwise#(idx_type), 
	   Bits#(data_type, data),
           Bitwise#(data_type),
           Literal#(data_type),
	   Literal#(idx_type));
  
  FIFO#(data_type) q <- mkSizedFIFO(4);

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

  method Bit#(18) address_out();
    return ~0;
  endmethod

  method Bit#(32) data_out();
    return ~0;
  endmethod

  method Action data_in(Bit#(32) data);
    noAction;
  endmethod

  method Bit#(1) data_tri();
    return ~0;
  endmethod

  method Bit#(4) we_bytes_out();
    return ~0;
  endmethod

  method Bit#(1) we_out();
    return ~0;
  endmethod

  method Bit#(1) ce_out();
    return ~0;
  endmethod

  method Bit#(1) oe_out();
    return ~0;
  endmethod

  method Bit#(1) cen_out();
    return ~0;
  endmethod

  method Bit#(1) adv_ld_out();  
    return ~0;
  endmethod
endmodule

module mkSRAM_Full 
  //interface:
              (SRAM#(idx_type, data_type))
  provisos
          (Bits#(idx_type, idx),
           Bitwise#(idx_type), 
	   Bits#(data_type, data),
           Bitwise#(data_type),
           Literal#(data_type),
	   Literal#(idx_type));

  SRAM#(idx_type, data_type) br <- mkSRAM(0, valueof(TExp#(idx)) - 1);

  return br;

endmodule


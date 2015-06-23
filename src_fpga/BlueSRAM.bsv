
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
import mkSatCounter::*;
import RegFile::*;

interface BlueSRAM#(type idx_type, type data_type);
 
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




module mkBlueSRAM#(Integer low, Integer high) 
  //interface:
              (BlueSRAM#(idx_type, data_type))
  provisos
          (Bits#(idx_type, idx),
           Bitwise#(idx_type), 
           Add#(idx, xxx, 18),
           Add#(data, yyy, 32),
	   Bits#(data_type, data),
           Bitwise#(data_type),
           Literal#(data_type),
	   Literal#(idx_type), 
           Bounded#(idx_type),
           Eq#(data_type));
	   
  BlueSRAM#(idx_type, data_type) m <- (valueof(data) == 0) ? 
                                   mkBlueSRAM_Zero() :
				   mkBlueSRAM_NonZero(low, high);

  return m;
endmodule


typedef enum {
  READ_REQ,
  WRITE_REQ,
  NOP
}
  RequestType
    deriving(Bits, Eq);
 

module mkBlueSRAM_NonZero#(Integer low, Integer high) 
  //interface:
              (BlueSRAM#(idx_type, data_type))
  provisos
          (Bits#(idx_type, idx),
           Add#(idx, xxx, 18),
           Add#(data, yyy, 32),
           Bitwise#(idx_type), 
	   Bits#(data_type, data),
           Bitwise#(data_type),
           Literal#(data_type),
	   Literal#(idx_type),
           Bounded#(idx_type),
           Eq#(data_type)); 
  FIFO#(data_type) output_fifo <- mkLFIFO();
  SatCounter#(2) counter <- mkSatCounter(2);
  RWire#(RequestType) req_type_wire <- mkRWire();
  RWire#(idx_type)    idx_type_wire <- mkRWire();
  RWire#(data_type)   data_type_wire <- mkRWire();
  RWire#(Bit#(0))     read_req_called <- mkRWire();
  RWire#(Bit#(0))     read_resp_called <- mkRWire();
  Reg#(RequestType)   op_command_pipelined <- mkReg(NOP);
  Reg#(RequestType)   op_command_active <- mkReg(NOP);
  Reg#(data_type)     write_data_pipelined <- mkReg(0);
  Reg#(data_type)     write_data_active <- mkReg(0); 

  rule process_req;
    op_command_active <= op_command_pipelined; 
    write_data_active <= write_data_pipelined;
    if(req_type_wire.wget matches tagged Valid .req)
      begin
        if(idx_type_wire.wget matches tagged Valid .idx)
          begin
            if(data_type_wire.wget matches tagged Valid .val)
              begin
                op_command_pipelined <= req;  
                write_data_pipelined <= val;       
              end 
            else
              begin
                op_command_pipelined <= req;                  
              end
          end
      end
    else
      begin
        // If we had neither request, we should insert a NOP.
        op_command_pipelined <= NOP;
      end
  endrule

  rule adjust_counter;
    if(read_resp_called.wget matches tagged Valid .x)
      begin
        if(read_req_called.wget matches tagged Invalid)
          begin
            counter.up();
          end
      end
    else 
      begin
        if(read_req_called.wget matches tagged Valid .y)
          begin
            counter.down();
          end
      end
  endrule 


  method ActionValue#(data_type) read_resp();
    $display("MemClient BlueSRAM: dequeueing: %h", output_fifo.first());
    read_resp_called.wset(0); 
    output_fifo.deq();
    return output_fifo.first();
  endmethod
  
  method Action read_req(idx_type idx) if (isValid(read_resp_called.wget) || (counter.value > 0));
    $display("MemClient BlueSRAM: ReadReq idx: %h", idx);
    read_req_called.wset(0);
    req_type_wire.wset(READ_REQ);
    idx_type_wire.wset(idx); 
  endmethod

  method Action write(idx_type idx, data_type data);
    $display("MemClient BlueSRAM: Write idx: %h data:%h", idx, data);
    req_type_wire.wset(WRITE_REQ);
    idx_type_wire.wset(idx);
    data_type_wire.wset(data);  
  endmethod
  
  // All of these are physical wires and therefore always enabled/ready
  method Bit#(18) address_out();
    if(idx_type_wire.wget matches tagged Valid .idx)
      begin
        Bit#(18) out_addr = 0;
        out_addr = zeroExtend(pack(idx));
        return out_addr;
      end
    else
      begin
        return 0;
      end
  endmethod

  method Bit#(32) data_out();
    Bit#(32) data = zeroExtend(pack(write_data_active)); 
    return data;    
  endmethod

  method Action data_in(Bit#(32) data);
    if(op_command_active == READ_REQ)
      begin
        data_type internal_data = unpack(truncate(data));
        output_fifo.enq(internal_data);
      end 
  endmethod

  method data_tri();
    if(op_command_active != WRITE_REQ)
      begin
        return ~0;
      end
    else
      begin
        return 0;
      end 
  endmethod

  method we_bytes_out();
    if(req_type_wire.wget matches tagged Valid .req)
      begin
        if(req != WRITE_REQ)
          begin
            return ~0;
          end
        else
          begin
            return 0;
          end 
      end
    else
      begin
        return ~0;
      end   
  endmethod

  method we_out();
    if(req_type_wire.wget matches tagged Valid .req)
      begin
        if(req != WRITE_REQ)
          begin
            return ~0;
          end
        else
          begin
            return 0;
          end 
      end
    else
      begin
        return ~0;
      end     
  endmethod

  method ce_out();
    return 0;
  endmethod

  method oe_out();
    return 0;
  endmethod

  method cen_out();
    return 0;
  endmethod

  method adv_ld_out();
    return 0;
  endmethod

endmodule

module mkBlueSRAM_Zero
  //interface:
              (BlueSRAM#(idx_type, data_type))
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


module mkBlueSRAM_Full 
  //interface:
              (BlueSRAM#(idx_type, data_type))
  provisos
          (Bits#(idx_type, idx),
           Bitwise#(idx_type), 
	   Bits#(data_type, data),
           Add#(idx, xxx, 18),
           Add#(data, yyy, 32),
           Bitwise#(data_type),
           Literal#(data_type),
	   Literal#(idx_type), 
           Bounded#(idx_type),
           Eq#(data_type));

  BlueSRAM#(idx_type, data_type) br <- mkBlueSRAM(0, valueof(TExp#(idx)) - 1);

  return br;

endmodule


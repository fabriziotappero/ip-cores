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

// import standard library
import FIFOF::*;
import RWire::*;

//////////////////////////////////////////////////////////////////////////
// unguarded bram interface

interface UGBRAM#(type idx_type, type data_type);
  (* always_ready *) method Action    read_req(idx_type idx);
                     method data_type read_resp();
  (* always_ready *) method Action    write(idx_type idx, data_type data);
endinterface

//////////////////////////////////////////////////////////////////////////
// guarded bram interface

interface BRAM#(type idx_type, type data_type);
  method Action                  read_req(idx_type idx);
  method ActionValue#(data_type) read_resp();
  method Action                  write(idx_type idx, data_type data);
endinterface


//////////////////////////////////////////////////////////////////////////
// unguarded bram implementations

// the ugbram verilog suggest a bypass one already
import "BVI" UGBRAM = module mkUGBRAM#(Integer low, Integer high)
                         (UGBRAM#(idx_type, data_type))
    provisos
            (Bits#(idx_type, idx),
             Bits#(data_type, data),
             Literal#(idx_type));

    default_clock clk(CLK);
    default_reset rst(RST_N);

    parameter addr_width = valueOf(idx);
    parameter data_width = valueOf(data);
    parameter lo = low;
    parameter hi = high;

    method read_req(READ_A_ADDR) enable(READ_A_ADDR_EN);
    method READ_A_DATA read_resp() ready(READ_A_DATA_RDY);
    method write(WRITE_B_ADDR, WRITE_B_DATA) enable(WRITE_B_EN);

    schedule read_req CF (read_resp, write);
    schedule read_req C read_req;   
    schedule read_resp CF (read_req, write);
    schedule read_resp CF read_resp;   
    schedule write CF (read_req, read_resp);
    schedule write C write;  

endmodule

module mkUGBRAM_Full(UGBRAM#(idx_type, data_type))
    provisos
            (Bits#(idx_type, idx),
             Bits#(data_type, data),
             Literal#(idx_type));

    UGBRAM#(idx_type, data_type) bram <- mkUGBRAM(0, valueOf(TExp#(idx)) - 1);
    return bram;
endmodule

// bypassUGBRAM = if write req and read req to the same addr, read the new data
module mkBypassUGBRAM_Full 
  //interface:
              (UGBRAM#(idx_type, data_type)) 
  provisos
          (Bits#(idx_type, idx), 
	   Bits#(data_type, data),
	   Literal#(idx_type),
           Eq#(idx_type));

   UGBRAM#(idx_type, data_type) bram <- mkUGBRAM(0, valueOf(TExp#(idx)) - 1);
   return bram;

//    Reg#(Maybe#(data_type))       resp    <- mkReg(tagged Invalid); 
//    UGBRAM#(idx_type, data_type)  br      <- mkUGBRAM_Full;
//    RWire#(idx_type)              wr_addr <- mkRWire;
//    RWire#(data_type)             wr_data <- mkRWire;
//    RWire#(idx_type)              rd_addr <- mkRWire;
   
//    rule checkBypass(True);
//       if (isValid(wr_addr.wget) && 
//           isValid(rd_addr.wget) &&
//           fromMaybe(?,wr_addr.wget) == fromMaybe(?,rd_addr.wget))
//          resp <= wr_data.wget;
//       else
//          resp <= tagged Invalid;
      
//       $display("%m checkBypass write_en: %d, write_addr: %d, write_data: %d, read_en: %d, read_addr: %d, bypass: %d",
//                isValid(wr_addr.wget), fromMaybe(?,wr_addr.wget), wr_data.wget,
//                isValid(rd_addr.wget), fromMaybe(?,rd_addr.wget),
//                fromMaybe(?,wr_addr.wget) == fromMaybe(?,rd_addr.wget));
               
//    endrule
   
//    rule checkReadResp(True);
//       let br_resp = br.read_resp;
//       let res = fromMaybe(br_resp,resp);
//       $display("%m bram resp: %d, resp: %d, actual resp: %d",br_resp,resp,res);
//    endrule
   
//    method Action read_req(idx_type idx);
//       br.read_req(idx);
//       rd_addr.wset(idx);
//    endmethod 
   
//    method data_type read_resp();
//       let br_resp = br.read_resp;
//       let res = fromMaybe(br_resp,resp);
//       return res;   
//    endmethod
   
//    method Action write(idx_type idx, data_type data);
//       br.write(idx,data);
//       wr_addr.wset(idx);
//       wr_data.wset(data);
//    endmethod

endmodule

//////////////////////////////////////////////////////////////////////////
// guarded bram implementations

// there is no point to make bypassBRAM if it is guarded because
// the BRAM is assumed to have unknown latency
module mkBRAM#(Integer low, Integer high)
   (BRAM#(idx_type,data_type))
   provisos (Bits#(idx_type, idx), 
             Bits#(data_type, data),
             Literal#(idx_type));
   
   UGBRAM#(idx_type,data_type) ugbram <- mkUGBRAM(low,high);
   FIFOF#(data_type)            rdataQ <- mkSizedFIFOF(2);
   
   rule getResp(True);
      let resp = ugbram.read_resp;
      rdataQ.enq(resp);
   endrule
   
   method Action read_req(idx_type addr) if (rdataQ.notFull);
      ugbram.read_req(addr);
   endmethod
   
   method ActionValue#(data_type) read_resp();
      rdataQ.deq;
      return rdataQ.first;
   endmethod
   
   method Action write(idx_type addr, data_type data);
      ugbram.write(addr,data);
   endmethod
      
endmodule

   
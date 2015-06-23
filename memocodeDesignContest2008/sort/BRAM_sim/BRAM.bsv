// import standard library
import FIFOF::*;
import RegFile::*;
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

// match the verilog behavior, gen a bypass bram
module mkUGBRAM#(Integer low, Integer high)
   (UGBRAM#(idx_type, data_type))
   provisos (Bits#(idx_type, idx),
             Bits#(data_type, data),
             Literal#(idx_type));
   
   RegFile#(idx_type,data_type) regFile <- mkRegFile(fromInteger(low),fromInteger(high));
   
   Reg#(idx_type)               readReg <- mkRegU();   
   
   method Action read_req(idx_type idx);
      readReg <= idx;
   endmethod
      
   method data_type read_resp();
      return regFile.sub(readReg);
   endmethod  
   
   method Action write(idx_type idx, data_type data);
      regFile.upd(idx,data);
   endmethod

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

(* synthesize *)
module mkBRAMTest(Empty);
   FIFOF#(Bit#(0)) reqQ <- mkFIFOF();
   Reg#(Bit#(16)) idx <- mkReg(0);
   UGBRAM#(Bit#(8),Bit#(129)) bram <- mkUGBRAM_Full;
   
   rule putBram(True);
      bram.write(idx[7:0],zeroExtend(idx));
      bram.read_req(idx[7:0]);
      reqQ.enq(?);
      
      //$display("write and read address %d with write value %d",idx[7:0],idx);
   endrule
   
   rule getReadResp(True);
      reqQ.deq();
      let resp = bram.read_resp();
      
      //$display("read response %d",resp);
   endrule
   
   rule incrClock(True);
      idx <= idx + 1;
      //$display("cycle %d",idx);
      if (idx == 5000)
         $finish(0);
   endrule
   
endmodule   
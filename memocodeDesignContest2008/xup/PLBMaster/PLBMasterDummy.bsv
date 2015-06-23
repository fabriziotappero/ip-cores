import RegFile         ::*;
import Interfaces      ::*;
import Types           ::*;
import Memocode08Types ::*;
import Parameters      ::*;
import FIFO            ::*;
import GetPut          ::*;
import Connectable     ::*;
import Memocode08Types ::*;

`define DummyDebug False

module mkPLBMasterDummy(PLBMaster);
   
   Reg#(Bit#(5)) stall   <- mkReg(~0);
   Reg#(Bit#(2)) jitter1  <- mkReg(0);
   Reg#(Bit#(1)) jitter2  <- mkReg(1);
   BlockAddr bank_mask = (fromInteger(valueOf(MemBankSelector))>>2);
   
   RegFile#(Bit#(18), Record)         mem_hi <- mkRegFileFull();
   RegFile#(Bit#(18), Record)         mem_lo <- mkRegFileFullLoad("unsorted.hex");
   Reg#(BlockAddr)           plbMasterCount <- mkReg(0);
   
   FIFO#(PLBMasterCommand) stall_fifo       <- mkFIFO();
   FIFO#(PLBMasterCommand) plbMasterCommand <- mkFIFO();
   
      
   function Tuple2#(Bool,BlockAddr) m(PLBMasterCommand a);
      if (a matches tagged LoadPage .addr)
	 return tuple2(True,addr);
      else
	 return tuple2(False,?);
   endfunction
   
   rule toggle (True);
      jitter1 <= jitter1-1;
      jitter2 <= jitter2-1;
   endrule
   
   rule decr_stall (stall != 0);
      stall <= stall-1;
   endrule
   
   rule xfer (stall==0);
      plbMasterCommand.enq(stall_fifo.first());
      stall_fifo.deq();
      stall <= maxBound;
   endrule
   
   interface Put wordInput;
   method Action put(Record wordInput) if(plbMasterCommand.first matches (tagged StorePage .addr) &&& (jitter1==0));
      let mem = ((addr&bank_mask)!=0) ? mem_hi : mem_lo;
      let idx = (addr>>2) + plbMasterCount;
      mem.upd(truncate(pack(idx)), wordInput);
      if(`DummyDebug) $display("plbMaster put %d", plbMasterCount);
      if(plbMasterCount + 1 == fromInteger(valueOf(RecordsPerMemRequest)))
	 begin
	    plbMasterCommand.deq;
	    plbMasterCount <= 0;
	 end
      else
	 begin
	    plbMasterCount <= plbMasterCount + 1;
	 end
	       
      if(`DummyDebug) $display("%m call put with addr %x mask %x",addr, addr&bank_mask);
   endmethod
   endinterface
   
   
   // using this function m is ugly, but I can't get the damn match syntax to parse
   // correctly inthe rule predicate... FUCK!
   interface Get wordOutput;
   method ActionValue#(Record) get() if(plbMasterCommand.first matches (tagged LoadPage .addr) &&& (jitter2==0));
      let mem = ((addr&bank_mask)!=0) ? mem_hi : mem_lo;
      let idx = (addr>>2) + plbMasterCount;
      let rv  = mem.sub(truncate(pack(idx)));
      if(`DummyDebug) $display("plbMaster get %d", plbMasterCount);
      if(`DummyDebug) $display("%m call get with addr %x mask %x",addr, addr&bank_mask);
      if(plbMasterCount + 1 == fromInteger(valueOf(RecordsPerMemRequest)))
         begin 
            plbMasterCommand.deq;
	    plbMasterCount <= 0;
         end
      else
	 begin
	    plbMasterCount <= plbMasterCount + 1;
	 end
      return rv;
   endmethod
   endinterface

   interface Put plbMasterCommandInput;
      method Action put(PLBMasterCommand command);
	 if(command matches tagged LoadPage .addr)
	    begin
	       if(`DummyDebug) $display("plbMasterCommand load %h", addr);
	    end
	 else if(command matches tagged StorePage .addr) 
	    begin
	       if(`DummyDebug) $display("plbMasterCommand store %h", addr);
	    end
	 else
	    $error();
	 stall_fifo.enq(command);
   endmethod
   endinterface
   
   interface plbMasterWires = ?;     
endmodule

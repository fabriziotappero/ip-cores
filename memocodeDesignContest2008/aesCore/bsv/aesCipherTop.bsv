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

Author: Kermin Fleming
*/

/* This file contains a variety of implemenations of aesCore hardware.  Each 
   module instantiates a parametric number of aesCores.  Basic operation 
   is as follows: start will cause the core to begin streaming out a sequence
   of aes values.  Next will cause the next value in the sequence to appear
   in some arbitrary amount of time (probably less than 12 cycles).  
   Some of the designs also support a seperate 
   clock domain for the aes cores and local control.  The domain crossing is 
   implemented via Bluespec domain crossing library code. */

import FIFO            ::*;
import Vector          ::*;
import StmtFSM         ::*;
import Memocode08Types ::*;
import RegFile         ::*;
import FIFOF           ::*;
import Clocks          ::*;


typedef Bit#(128) AES_block;
typedef Bit#(128) AES_key;
typedef Bit#(8)   Byte;
typedef Bit#(32)  Word;

`define AESDebug False

// This is the top level module used by the sorting control
interface AESCores#(numeric type t);
   method Action start(Bit#(5) end_seq);
   method ActionValue#(AES_block) get_next();
 endinterface

interface AESCoresShuffle#(numeric type t);
   method Action start(Bit#(5) end_seq,Bit#(4) seed, Bit#(4) stride);
   method ActionValue#(AES_block) get_next();
 endinterface

import "BVI" aes_pipelined_cipher_top =  
module mkAESPipeline (AES);
   
   default_clock clk(clk);
   default_reset rst(rst);
   
   method text_out get_result() ready(done);
   method decrypt(text_in, key) ready(ready) enable(ld);
   
   schedule decrypt    CF (get_result);
   schedule get_result CF (decrypt);
      
   schedule decrypt    C decrypt;
   schedule get_result C get_result;

endmodule


module mkAESCorePipelined(AESCores#(1));
   
   Reg#(int)      ptr  <- mkReg(0);
   Reg#(Bit#(2)) iter  <- mkReg(0);
   Reg#(int)    limit  <- mkReg(0);
   Reg#(int)    scount  <- mkReg(0);
   Reg#(int)    rcount <- mkReg(0);

   AES_key key = {8'hB0, 8'h1D, 8'hFA, 8'hCE, 
		  8'h0D, 8'hEC, 8'h0D, 8'hED, 
		  8'h0B, 8'hA1, 8'h1A, 8'hDE, 
		  8'h0E, 8'hFF, 8'hEC, 8'h70};

   AES core <- mkAESPipeline();

   Reg#(Bit#(4)) inflight <- mkReg(0);
   
   FIFO#(Bit#(5)) commandQ <- mkFIFO;
   FIFO#(Bit#(128)) respQ <- mkSizedFIFO(16);   
   FIFO#(Bit#(0)) respTokenQ <- mkSizedFIFO(16);   

   rule startRule(iter == 0);
      if(`AESDebug) $display("Calling start");
      commandQ.deq;
      iter   <= 2;
      limit  <= 1<<commandQ.first();
      rcount <= 1;
      core.decrypt(0, key);
      respTokenQ.enq(?);
   endrule


   rule sendMore(iter>0 && (inflight != 15));
      if(rcount+1 == limit) // We pre-issue some requests.
        begin
         iter  <= iter-1;
         rcount <= 0;
        end
      else
        begin
         rcount <= rcount + 1;
        end
      
      respTokenQ.enq(?);
      core.decrypt(pack(zeroExtend(rcount)), key);
      if(`AESDebug) $display("Count[1] is %d, reading core %d",rcount, ptr);

   endrule

   rule resp;
      respQ.enq(core.get_result());
   endrule

   method Action start(Bit#(5) end_seq);
     commandQ.enq(end_seq);
   endmethod
	
   
   method ActionValue#(AES_block) get_next(); // Must deal with trailing pointer.  We issue too many reqs...
     respQ.deq();
     respTokenQ.deq();
     return respQ.first;
   endmethod
      
endmodule
 
module mkAESCorePipelinedShuffle(AESCoresShuffle#(1));
   
   Reg#(int)      ptr  <- mkReg(0);
   Reg#(Bit#(4))  stride <- mkReg(0);
   Reg#(Bit#(4))  init <- mkReg(0);
   Reg#(Bit#(2)) iter  <- mkReg(0);
   Reg#(Bit#(19))    limit  <- mkReg(0);
   Reg#(Bit#(19))    scount  <- mkReg(0);
   Reg#(Bit#(19))    rcount <- mkReg(0);
  
    
   AES_key key = {8'hB0, 8'h1D, 8'hFA, 8'hCE, 
		  8'h0D, 8'hEC, 8'h0D, 8'hED, 
		  8'h0B, 8'hA1, 8'h1A, 8'hDE, 
		  8'h0E, 8'hFF, 8'hEC, 8'h70};

   AES core <- mkAESPipeline();

   Reg#(Bit#(4)) inflight <- mkReg(0);
   
   FIFO#(Tuple3#(Bit#(5),Bit#(4),Bit#(4))) commandQ <- mkFIFO;
   FIFO#(Bit#(128)) respQ <- mkSizedFIFO(16);   
   FIFO#(Bit#(0)) respTokenQ <- mkSizedFIFO(16);   

   rule startRule(iter == 0);
      if(`AESDebug) $display("Calling start");
      commandQ.deq;
      match {.total,.initNew,.strideNew} = commandQ.first();
      iter   <= 2;
      limit  <= 1<<total;
      rcount <= zeroExtend(initNew)+zeroExtend(strideNew);
      init <= initNew;
      stride <= strideNew;
      core.decrypt(zeroExtend(initNew), key);
      respTokenQ.enq(?);
   endrule


   rule sendMore(iter>0 && (inflight != 15));
      if(rcount+zeroExtend(stride) > limit) // We pre-issue some requests.
        begin
         iter  <= iter-1;
         rcount <= zeroExtend(init);
        end
      else
        begin
         rcount <= rcount + zeroExtend(stride);
        end
      
      respTokenQ.enq(?);
      core.decrypt(pack(zeroExtend(rcount)), key);
      if(`AESDebug) $display("Count[1] is %d, reading core %d",rcount, ptr);

   endrule

   rule resp;
      respQ.enq(core.get_result());
   endrule

   method Action start(Bit#(5) end_seq,Bit#(4) seed, Bit#(4) stride);
     commandQ.enq(tuple3(end_seq,seed,stride));
   endmethod
	
   
   method ActionValue#(AES_block) get_next(); // Must deal with trailing pointer.  We issue too many reqs...
     respQ.deq();
     respTokenQ.deq();
     return respQ.first;
   endmethod
      
endmodule


module mkAESCorePipelinedMCD#(Clock slowClock, Reset slowReset) (AESCores#(1));
   
   Reg#(int)      ptr  <- mkReg(0);
   Reg#(Bit#(2)) iter  <- mkReg(0);
   Reg#(int)    limit  <- mkReg(0);
   Reg#(int)    scount  <- mkReg(0);
   Reg#(int)    rcount <- mkReg(0);

   AES_key key = {8'hB0, 8'h1D, 8'hFA, 8'hCE, 
		  8'h0D, 8'hEC, 8'h0D, 8'hED, 
		  8'h0B, 8'hA1, 8'h1A, 8'hDE, 
		  8'h0E, 8'hFF, 8'hEC, 8'h70};

   AES core <- mkAESPipeline();

   Reg#(Bit#(4)) inflight <- mkReg(0);
     
   SyncFIFOIfc#(Bit#(5)) commandQ <- mkSyncFIFOToCC(2,slowClock,slowReset);
   SyncFIFOIfc#(Bit#(128)) respQ <- mkSyncFIFOFromCC(16,slowClock); 
   SyncFIFOIfc#(Bit#(1)) respTokenQ <- mkSyncFIFOFromCC(16,slowClock); 
  

   rule startRule(iter == 0);
      if(`AESDebug) $display("Calling start");
      commandQ.deq;
      iter   <= 2;
      limit  <= 1<<commandQ.first();
      rcount <= 1;
      core.decrypt(0, key);
      respTokenQ.enq(?);
   endrule


   rule sendMore(iter>0 && (inflight != 15));
      if(rcount+1 == limit) // We pre-issue some requests.
        begin
         iter  <= iter-1;
         rcount <= 0;
        end
      else
        begin
         rcount <= rcount + 1;
        end
      
      respTokenQ.enq(?);
      core.decrypt(pack(zeroExtend(rcount)), key);
      if(`AESDebug) $display("Count[1] is %d, reading core %d",rcount, ptr);

   endrule

   rule resp;
      respQ.enq(core.get_result());
   endrule

   method Action start(Bit#(5) end_seq);
     commandQ.enq(end_seq);
   endmethod
	
   
   method ActionValue#(AES_block) get_next(); // Must deal with trailing pointer.  We issue too many reqs...
     respQ.deq();
     respTokenQ.deq();
     return respQ.first;
   endmethod
      
endmodule



module mkAESCores(AESCores#(num_cores));
   
   Reg#(int)      ptr  <- mkReg(0);
   Reg#(Bit#(2)) iter  <- mkReg(0);
   Reg#(Bit#(19))    limit  <- mkReg(0);
   Reg#(Bit#(19))    count  <- mkReg(0);
   Reg#(Bit#(19))    rcount <- mkReg(0);

   AES_key key = {8'hB0, 8'h1D, 8'hFA, 8'hCE, 
		  8'h0D, 8'hEC, 8'h0D, 8'hED, 
		  8'h0B, 8'hA1, 8'h1A, 8'hDE, 
		  8'h0E, 8'hFF, 8'hEC, 8'h70};

   Vector#(num_cores, AES) cores <- replicateM(mkAES);
   let nc_i = fromInteger(valueOf(num_cores));

   FIFO#(Bit#(5)) commandQ <- mkFIFO;
   FIFO#(Bit#(128)) respQ <- mkFIFO;   
   

   rule startRule(iter == 0);
      if(`AESDebug) $display("Calling start");
      commandQ.deq;
      iter   <= 2;
      limit  <= 1<<commandQ.first();
      count  <= 0;
      rcount <= nc_i;
      ptr <= 0;
      for(int i = 0; i < nc_i; i=i+1)
	 cores[i].decrypt(pack(zeroExtend(i)), key); 
   endrule


   rule respRule(iter > 0);

      if(rcount+1 == limit) // We pre-issue some requests.
        begin
         rcount <= 0;
        end
      else
        begin
         rcount <= rcount + 1;
        end
 
      if(count + 1 == limit)
        begin
          iter  <= iter-1;
          count <= 0;
        end
      else
        begin
          count <= count + 1;
        end

      ptr    <= (ptr+1 == nc_i)?0:(ptr+1); // ptr tells us which aes core to grab data from
      cores[ptr].decrypt(pack(zeroExtend(rcount)), key);
      if(`AESDebug) $display("Count[%d] is %d, reading core %d",nc_i,rcount, ptr);
      respQ.enq(cores[ptr].get_result());
   endrule

   method Action start(Bit#(5) end_seq);
     commandQ.enq(end_seq);
   endmethod
	
   
   method ActionValue#(AES_block) get_next(); // Must deal with trailing pointer.  We issue too many reqs...
     respQ.deq();
     return respQ.first;
   endmethod

endmodule




interface AES;
   method Action    decrypt(AES_block blk, AES_key key);
   method AES_block get_result();
endinterface



module mkAESCoresMCD#(Clock slowClock, Reset slowReset)  (AESCores#(num_cores));
   
   Reg#(int)      ptr  <- mkReg(0);
   Reg#(Bit#(2)) iter  <- mkReg(0);
   Reg#(int)    limit  <- mkReg(0);
   Reg#(int)    count  <- mkReg(0);
   Reg#(int)    rcount <- mkReg(0);

   AES_key key = {8'hB0, 8'h1D, 8'hFA, 8'hCE, 
		  8'h0D, 8'hEC, 8'h0D, 8'hED, 
		  8'h0B, 8'hA1, 8'h1A, 8'hDE, 
		  8'h0E, 8'hFF, 8'hEC, 8'h70};

   Vector#(num_cores, AES) cores <- replicateM(mkAES);
   let nc_i = fromInteger(valueOf(num_cores));

   SyncFIFOIfc#(Bit#(5)) commandQ <- mkSyncFIFOToCC(2,slowClock,slowReset);
   SyncFIFOIfc#(Bit#(128)) respQ <- mkSyncFIFOFromCC(4,slowClock); 
   

   rule startRule(iter == 0);
      if(`AESDebug) $display("Calling start MCD: %d", nc_i);
      commandQ.deq;
      iter   <= 2;
      limit  <= 1<<commandQ.first();
      count  <= 0;
      rcount <= nc_i;
      ptr <= 0;
      for(int i = 0; i < nc_i; i=i+1)
	 cores[i].decrypt(pack(zeroExtend(i)), key); 
   endrule


   rule respRule(iter > 0);

      if(rcount+1 == limit) // We pre-issue some requests.
        begin
         rcount <= 0;
        end
      else
        begin
         rcount <= rcount + 1;
        end
 
      if(count + 1 == limit)
        begin
          iter  <= iter-1;
          count <= 0;
        end
      else
        begin
          count <= count + 1;
        end

      ptr    <= (ptr+1 == nc_i)?0:(ptr+1); // ptr tells us which aes core to grab data from
      cores[ptr].decrypt(pack(zeroExtend(rcount)), key);
      if(`AESDebug) $display("Count[%d] is %d, reading core %d",nc_i,rcount, ptr);
      respQ.enq(cores[ptr].get_result());
   endrule

   method Action start(Bit#(5) end_seq) if(commandQ.notFull);
     commandQ.enq(end_seq);
   endmethod
	
   
   method ActionValue#(AES_block) get_next() if(respQ.notEmpty); // Must deal with trailing pointer.  We issue too many reqs...
     respQ.deq();
     return respQ.first;
   endmethod

endmodule

import "BVI" aes_cipher_top =  
module mkAES (AES);
   
   default_clock clk(clk);
   default_reset rst(rst);
   
   method text_out get_result() ready(bsv_done);
   method decrypt(text_in, key) ready(bsv_done) enable(ld);
   
   schedule decrypt    CF (get_result);
   schedule get_result CF (decrypt);
      
   schedule decrypt    C decrypt;
   schedule get_result C get_result;
      
endmodule

(* synthesize *)
module mkAESCores3(AESCores#(3));
   AESCores#(3) cores <- mkAESCores();
   return cores;
endmodule

(* synthesize *)
module mkAESCores2(AESCores#(2));
   AESCores#(2) cores <- mkAESCores();
   return cores;
endmodule


import "BVI" aes_data_fifo =  
module mkAESDataFIFO#(Clock rdClk, Clock wrClk)   (FIFOF#(Bit#(128)));
   default_clock no_clock;   
   input_clock rd_clk(rd_clk) = rdClk ; // put clock
   input_clock wr_clk(wr_clk) = wrClk ; // get clock
   default_reset rst(rst);	
   
   method enq(din) ready(fullN)  enable(wr_en) clocked_by(wr_clk);    
   method emptyN notEmpty() clocked_by(rd_clk);  
   method fullN notFull() clocked_by(wr_clk);    
   method deq()  ready(emptyN) enable(rd_en) clocked_by(rd_clk);
   method dout first() ready(emptyN) clocked_by(rd_clk); 
   method clear()  enable(clr) clocked_by(rd_clk);
   
   schedule (enq,notFull) CF (deq,first,notEmpty);

   schedule (notFull,first) CF (notFull,first);
   schedule (notEmpty,first) CF (notEmpty,first);

   schedule enq C enq;
   schedule deq C deq;
   schedule notEmpty SB deq;
   schedule first    SB deq;
   schedule notFull  SB enq;

      
endmodule


import "BVI" aes_command_fifo =  
module mkAESCommandFIFO#(Clock rdClk, Clock wrClk)   (FIFOF#(Bit#(5)));
   default_clock no_clock;
   
   input_clock rd_clk(rd_clk) = rdClk ; // put clock
   input_clock wr_clk(wr_clk) = wrClk ; // get clock
   default_reset rst(rst);	
   
   method enq(din) ready(fullN) enable(wr_en) clocked_by(wr_clk);    
   method emptyN notEmpty() clocked_by(rd_clk);  
   method fullN notFull() clocked_by(wr_clk);    
   method deq()  ready(emptyN) enable(rd_en) clocked_by(rd_clk);
   method dout first() ready(emptyN) clocked_by(rd_clk); 
   method clear()  enable(clr) clocked_by(rd_clk);
   
   schedule (enq,notFull) CF (deq,first,notEmpty);

   schedule (notFull,first) CF (notFull,first);
   schedule (notEmpty,first) CF (notEmpty,first); 

   schedule enq C enq; 
   schedule deq C deq;
   schedule notEmpty SB deq;
   schedule first    SB deq;
   schedule notFull  SB enq;

      
endmodule
			

module mkTH();
   Clock clk <- exposeCurrentClock();
   Reset rst <- exposeCurrentReset();
   Clock secondClock <- mkAbsoluteClock(3, 3);
   Reset secondReset <- mkInitialReset(3, clocked_by secondClock);   
   mkTH_mcd(clk,secondClock,rst,secondReset, clocked_by(clk), reset_by(rst));
endmodule

module mkTH_mcd#(Clock fastClock, Clock slowClock,Reset fastReset, Reset slowReset) ();
   

   AESCores#(2) cores3 <- mkAESCores ;	 
   AESCores#(1) cores10 <- mkAESCorePipelined();//mkAESCoresMCD(slowClock,slowReset);	

   Reg#(Bit#(64)) countCycle <- mkReg(0); 
   Reg#(Bool) done <- mkReg(False);
   Reg#(Bit#(5)) logRecords <- mkReg(4);
   Reg#(Bit#(20)) recordCount <- mkReg(0);
   RegFile#(Bit#(18),Bit#(128)) goldenOutput <- mkRegFileFullLoad("code.hex");
   Reg#(Bit#(7)) delay <- mkReg(0);

   rule do_ (!done && logRecords < 19);
      if(`AESDebug) $display("AES lives");
      done <= True;
      recordCount <= 0;
      cores3.start(logRecords);
      cores10.start(logRecords);
      delay <= 100;
   endrule
   
   rule delayDec(delay > 0);
     delay <= delay -1;
   endrule 

   rule countCycleRule;
     countCycle <= countCycle + 1;
   endrule

   rule get (done && recordCount < (1<< logRecords + 1) && delay == 0);
      let r4 <- cores3.get_next();
      let r10 <- cores10.get_next();
      recordCount <= recordCount + 1;
      if(recordCount + 1 == (1<< logRecords + 1))
        begin
          logRecords <= logRecords + 1;
          done <= False;
        end
      let gold = goldenOutput.sub(truncate(recordCount& ((1<<logRecords) - 1)));
      if(`AESDebug) $display("Value obtained at %d", countCycle);

      if(r10 != goldenOutput.sub(truncate(recordCount & ((1<<logRecords) - 1))))
        begin
         
          if(`AESDebug) $display("Cores 10 got %h , expected %h",r10[127:96],gold[127:96]);  
          if(`AESDebug) $display("Cores 10 got %h , expected %h",r10[95:64],gold[95:64]);  
          if(`AESDebug) $display("Cores 10 got %h , expected %h",r10[63:32],gold[63:32]);  
          if(`AESDebug) $display("Cores 10 got %h , expected %h",r10[31:0],gold[31:0]);  
          $finish;
        end
      if(r4 != goldenOutput.sub(truncate(recordCount& ((1<<logRecords) - 1))))
        begin

          if(`AESDebug) $display("Cores 4 got %h , expected %h",r4[127:96],gold[127:96]);  
          if(`AESDebug) $display("Cores 4 got %h , expected %h",r4[95:64],gold[95:64]);  
          if(`AESDebug) $display("Cores 4 got %h , expected %h",r4[63:32],gold[63:32]);  
          if(`AESDebug) $display("Cores 4 got %h , expected %h",r4[31:0],gold[31:0]);  
          $finish;
        end
    
   endrule
   
endmodule

module mkTH_single();
   
   Reg#(Bool) done <- mkReg(False);
   AES crypto <- mkAES();
		    
   AES_block clear_text = {8'h0, 8'h0, 8'h0, 8'h0, 
			   8'h0, 8'h0, 8'h0, 8'h0,
			   8'h0, 8'h0, 8'h0, 8'h0, 
			   8'h0, 8'h0, 8'h0, 8'h1};
   
   AES_key globalkey = {8'hB0, 8'h1D, 8'hFA, 8'hCE, 
			8'h0D, 8'hEC, 8'h0D, 8'hED, 
			8'h0B, 8'hA1, 8'h1A, 8'hDE, 
			8'h0E, 8'hFF, 8'hEC, 8'h70};
   
   Stmt test = 
   seq
      if(`AESDebug) $display("%h", clear_text);
      crypto.decrypt(clear_text, globalkey);
      if(`AESDebug) $display("%h",crypto.get_result());
      $finish();
   endseq;
   
   FSM test_fsm <- mkFSM(test);
   
   rule do_(!done);
      test_fsm.start();
      done <= True;
   endrule
   
endmodule


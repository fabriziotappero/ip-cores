/*
Copyright (c) 2007 MIT

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Author: Myron King
*/


/***************************************************************
 *
 * The module mkControl is responsible for (as it's name would
 * suggest) orchestrating the communication between the various
 * sub-modules in the system, as well as directing their 
 * individual behavior.  The sort tree has a complicated control 
 * protocol which requires that reservations be made for both 
 * the insertion and extraction of data.  In order to avoid 
 * deadlock, guarantees must be made on the availability of data
 * to be inserted or space for the extrated data to be buffered
 * In addition, the first stage of sorting is distinct from all
 * subsequent stages in that the data is organized randomly and
 * no assumptions can be made about ordered sub-streams in 
 * memory. 
 * 
 * the module accepts commands in the form of the length of array
 * to be sorted, through the doSort interface.  the guarded value
 * method finished() returns true upon sort completion.  There is
 * a debug interface msgs which can be used to extract debug
 * messages.
 * 
 * the mkTH module is for testing purposes only
 * 
 ***************************************************************/

import BRAMFIFO        ::*;
import Sort            ::*;
import aesCipherTop    ::*;
import Memocode08Types ::*;
import ExternalMemory  ::*;
import PLBMasterDummy  ::*;
import Interfaces      ::*;
import FIFO            ::*;
import FIFOF           ::*;
import EHRReg          ::*;
import Vector          ::*;
import SortTree64      ::*;
import RegFile         ::*;
import GetPut          ::*;

interface Control;
   method Action doSort(Bit#(5) log_len);
   method Bool   finished();
   interface Get#(Bit#(32)) msgs;
endinterface

typedef 64 KMerges;
typedef Bit#(TLog#(KMerges)) KMask;
typedef Bit#(TAdd#(TLog#(KMerges),1)) KMaskp1;
typedef Bit#(TLog#(RecordsPerMemRequest)) RPMRMask;
typedef Bit#(TAdd#(1,TLog#(RecordsPerMemRequest))) OBuffCap;
typedef Bit#(20) RecAddr;

`define Debug False

(* descending_urgency = "drain_sorter,  write_to_mem" *)
(* descending_urgency = "read_request_a, schedule_read_request" *)
module mkControl#(ExternalMemory extMem, Clock fastClock, Reset fastReset) (Control);


   /*

   Bit#(5) log_sub_stream_lengths[3] = {6,  12,   18};

   RecAddr    num_sub_streams[13][3] = {{1,     0,  0},
					{2,     1,  0},
					{4,     1,  0},
					{8,     1,  0},
					{16,    1,  0},
					{32,    1,  0},
					{64,    1,  0},
					{128,   2,  1},
					{256,   4,  1},
					{512,   8,  1},
					{1024,  16, 1},
					{2048,  32, 1},
					{4096,  64, 1}};

   */
   
   let          sort_tree <- mkSortTree64();
   Clock clk <- exposeCurrentClock;  
   Reset rst <- exposeCurrentReset;
   AESCores#(2) aes_cores <-  mkAESCoresMCD(clk,rst,clocked_by(fastClock),reset_by(fastReset));//mkAESCores();

   Reg#(RecAddr)  nss  <- mkRegU();
   Reg#(RecAddr)  ssl  <- mkRegU();   
   Reg#(RecAddr)  nssl <- mkRegU();
   //let ssl       = (ra_one<<(log_sub_stream_lengths[iter-1]));
   //let nssl      = (ra_one<<(log_sub_stream_lengths[iter]));
   //let nss       = num_sub_streams[log_len-6][iter-1];
   
   
   Reg#(RecAddr) read_req_count  <- mkRegU();
   Reg#(RecAddr) read_res_count  <- mkRegU();
   Reg#(KMask)   res_count       <- mkRegU();
   Reg#(KMask)   read_count      <- mkRegU();
   Reg#(Bool)    read_eos        <- mkRegU();
   Reg#(RecAddr) write_base_addr <- mkRegU();
   Reg#(RecAddr) write_req_count <- mkRegU();
   Reg#(RecAddr) write_count     <- mkRegU();
   Reg#(Bit#(5)) log_len         <- mkRegU();
   Reg#(RecAddr) array_len       <- mkRegU();
   Reg#(Bit#(3)) iter            <- mkReg(~0);
   Reg#(Bool)    last            <- mkReg(False);
   Reg#(Bool)    done            <- mkReg(True);
   Reg#(Bool)    set_next_stage  <- mkReg(False);
   Reg#(RecAddr) set_ptr_count   <- mkRegU();
   Reg#(KMask)   set_count       <- mkRegU();

   Reg#(Bool)     pending_read_req   <- mkReg(False);
   Reg#(KMask)    pending_req_idx            <- mkRegU();
   Reg#(RecAddr)  pending_req_new_base_ptr   <- mkRegU();
   Reg#(Addr)     pending_req_req_addr       <- mkRegU();
   Reg#(RecAddr)  pending_req_new_eos_left   <- mkRegU();
   Reg#(Bool)     pending_req_need_eos       <- mkRegU();
   Reg#(RecAddr)  pending_req_new_req_offset <- mkRegU();
   Reg#(Bit#(5))  pending_req_rs_toks        <- mkRegU();
   Reg#(Bool)     pending_req_is_fin_stage   <- mkRegU();
   
   FIFO#(Bit#(6))      pending_first_res_count <- mkFIFO();
   FIFO#(RecAddr) pending_first_read_res_count <- mkFIFO();
   FIFO#(Bit#(6))      pending_pending_reserve <- mkFIFO();
   
   FIFO#(Tuple2#(KMask, Maybe#(Bit#(128)))) put_rec_fifo <- mkFIFO();
   
   RecAddr ra_one = 1;
   let kmerges   = fromInteger(valueOf(KMerges));
   let rpmr      = fromInteger(valueOf(RecordsPerMemRequest));
   let readpt    = 0;
   let writept   = 0;
   let recwid    = fromInteger(valueOf(RecordWidth));   
   let outbuffsz = 2*rpmr;
   let tok_info  = sort_tree.inStream.getTokInfo();

   KMask kmask         = ~0;
   KMaskp1 kmask1      = ~0;
   RPMRMask rpmr_mask  = ~0;
   Bit#(32) bank_mask  = fromInteger(valueOf(MemBankSelector))>>4;
      
   RegFile#(KMask, RecAddr)   base_ptrs <- mkRegFileFull();
   RegFile#(KMask, RecAddr) req_offsets <- mkRegFileFull();
   RegFile#(KMask, RecAddr) rsp_offsets <- mkRegFileFull();
   RegFile#(KMask, RecAddr)   eos_lefts <- mkRegFileFull();   

   Reg#(Vector#(KMerges, Bool)) finish_stage <- mkReg(replicate(False));
   FIFO#(KMask)                       rdfifo <- mkFIFO();
   FIFO#(Tuple2#(Bool,KMask))         rsfifo <- mkSizedFIFO(1);
   FIFOF#(Bit#(1))                    wrfifo <- mkFIFOF();
   FIFO#(Bit#(1))                     fsfifo <- mkFIFO();
   
   FIFOF#(Bit#(RecordWidth)) out_buff <- mkBRAMFIFOF(2*rpmr);
   Reg#(RPMRMask)        out_buff_cnt <- mkReg(0);
   
   FIFO#(Bit#(32)) msg_queue <- mkFIFO();
   Reg#(int)       msg_state <- mkReg(0);
   Reg#(Bit#(30)) tic_counter <- mkReg(1);
   
   Reg#(Bit#(32)) debug_read_requests <- mkReg(0);
   Reg#(Bit#(32)) debug_write_requests <- mkReg(0);
   Reg#(Bit#(32)) debug_drain_sorter_valid <- mkReg(0);
   Reg#(Bit#(32)) debug_write_to_mem <- mkReg(0);
   Reg#(Bit#(32)) debug_write_to_sort_tree <- mkReg(0);
   Reg#(Bit#(32)) debug_write_eos_to_sort_tree <- mkReg(0);
   Reg#(Bit#(32)) debug_write_eos_from_sort_tree <- mkReg(0);
   Reg#(Bit#(32)) debug_write_eos_first <- mkReg(0);
   Reg#(Bit#(32)) debug_write_eos_second <- mkReg(0);
   Reg#(Bool)     debug_setup_stream_stage <- mkReg(False);
   
   rule tic_toc(True);
      tic_counter <= tic_counter+1;
   endrule
   
   rule debug_stuff0 (tic_counter==0);
      msg_queue.enq(debug_read_requests);
      msg_state <= 1;
   endrule
   
   rule debug_stuff1 (msg_state==1);
      msg_queue.enq(debug_write_requests);
      msg_state <= 2;
   endrule
   
   rule debug_stuff2 (msg_state==2);
      msg_queue.enq(debug_drain_sorter_valid);
      msg_state <= 3;
   endrule
   
   rule debug_stuff3 (msg_state==3);
      msg_queue.enq(debug_write_to_mem);
      msg_state <= 4;
   endrule
   
   rule debug_stuff4 (msg_state==4);
      msg_queue.enq(debug_write_to_sort_tree);
      msg_state <= 5;
   endrule

   rule debug_stuff5 (msg_state==5);
      msg_queue.enq(debug_write_eos_to_sort_tree);
      msg_state <= 6;
   endrule

   rule debug_stuff6 (msg_state==6);
      msg_queue.enq(debug_write_eos_from_sort_tree);
      msg_state <= 7;
   endrule

   rule debug_stuff7 (msg_state==7);
      msg_queue.enq(debug_write_eos_first);
      msg_state <= 8;
   endrule

   rule debug_stuff8 (msg_state==8);
      msg_queue.enq(debug_write_eos_second);
      msg_state <= 9;
   endrule

   
   rule first_stage_reserve_a(!done &&
			      iter==0 &&
			      read_res_count > 0 &&
			      tok_info[res_count] > 1 );
      res_count <= res_count - 1;
      pending_first_res_count.enq(res_count);
      pending_first_read_res_count.enq(truncate(read_res_count));
      if(`Debug) $display("first_stage_reserve %d", res_count);
      // reached the end of a 64 element block, decrement the number
      // of 64 element blocks remaining
      if (res_count == 0) 
         read_res_count <= read_res_count - 1;      
   endrule   
   
   rule first_stage_reserve_b (!done && 
			       iter==0);
      // reserve 1 slot for queue res_count
      // reserve 1 slot for corresponding eos
      sort_tree.inStream.putDeqTok(pending_first_res_count.first(),2); 
      pending_first_res_count.deq(); 
      pending_pending_reserve.enq(pending_first_res_count.first());
   endrule
   
   rule first_stage_reserve_c (!done && 
			       iter==0);
      pending_first_read_res_count.deq();
      pending_pending_reserve.deq();
      // check if we've completed one burst's worth
      if((truncate(pending_pending_reserve.first())&rpmr_mask) == 0)
	 begin   
	    if(`Debug) $display("first_stage_reserve block: %d, idx %d", 
				pending_first_read_res_count.first(),
				pending_pending_reserve.first());
            fsfifo.enq(?);
	 end
   endrule
   
   // once rpmr kmerge slots have been reserved, make a burst request
   rule first_stage_read_req (!done && 
			      iter == 0);
      let new_read_req_count = read_req_count - rpmr;
      fsfifo.deq(); // as long as rsfifo has something
      debug_read_requests <= debug_read_requests+1;
      extMem.read[readpt].readReq(zeroExtend(array_len-read_req_count)*(recwid/32));
      read_req_count <= new_read_req_count;
      if(`Debug) $display("first_stage_read_req %d", new_read_req_count);
   endrule
   
   // get the records returned from memory and feed the sort_tree
   rule first_stage_read_resp (!done && 
			       iter == 0);
      
      // enque data and eos tokens on alterntaing cycles
      read_eos <= !read_eos;
      
      if (read_eos) 
	 begin
            debug_write_eos_first <= debug_write_eos_first + 1;
	    put_rec_fifo.enq(tuple2(read_count, tagged Invalid));
            read_count <= read_count - 1;
	    if(`Debug) $display("first_stage_read_resp eos %d", read_count);
	 end
      else
	 begin
	    let a <- extMem.read[readpt].read();
	    let mask <- aes_cores.get_next();            
	    put_rec_fifo.enq(tuple2(read_count, tagged Valid (a^mask)));
	    if(`Debug) $display("FIRST first_stage_read_resp idx %h, val %h xor %h", 
				read_count, a,a^mask);
	 end
   endrule
   
   rule drain_sorter (True);
      let data <- sort_tree.getRecord();
      if(isValid(data))
	 begin
	    debug_drain_sorter_valid <= debug_drain_sorter_valid+1;
            out_buff.enq(unpack(fromMaybe(?, data)));
	    out_buff_cnt <= out_buff_cnt + 1;
            if (out_buff_cnt == maxBound) // need a new write request
               wrfifo.enq(?);
            if(`Debug) $display("drain_sorter_finish");
	 end
      else
         begin
            debug_write_eos_from_sort_tree <= debug_write_eos_from_sort_tree + 1;
	    // we just dequeued an end of stream token, and
	    // don't need to write that out to memory
            if(`Debug) $display("drain_sorter_finish eos");
         end
   endrule
   
   rule write_command (True);
	 Bit#(AddrWidth) write_addr = zeroExtend(write_base_addr - write_req_count)*(recwid/32);  
	 wrfifo.deq();
	 debug_write_requests <= debug_write_requests+1;
	 extMem.write[writept].writeReq(write_addr);
	 write_req_count <= write_req_count - rpmr;
	 if(`Debug) $display("write_command %h",write_addr);
   endrule
   
   rule write_to_mem (True);
      //TODO: we need to re-encrypt the data on the last pass!
      out_buff.deq();
      debug_write_to_mem <= debug_write_to_mem+1;
      if(last)
	 begin
	    let mask <- aes_cores.get_next();
	    extMem.write[writept].write(out_buff.first()^mask);
	    if(`Debug) $display("LAST write_to_mem write_count %h, write_val %h xor %h",
				write_count,out_buff.first(),out_buff.first()^mask);          
	 end
      else
         begin
	   extMem.write[writept].write(out_buff.first());
	   if(`Debug) $display("write_to_mem write_count %h, write_val %h",
			       write_count,out_buff.first());      
        end
      if(write_count == 1)
	 begin
            write_base_addr <= write_base_addr ^ truncate(bank_mask);
	    write_count     <= array_len;
	    write_req_count <= array_len;
	    set_next_stage  <= True;
            set_ptr_count   <= write_base_addr; // last write this iter
            set_count       <= 63;
	    iter            <= iter+1;
	    finish_stage    <= replicate(False);
            if (`Debug) $display("done array, write_base_addr=%x", write_base_addr);
	    ssl  <= ssl  << 6;
	    nssl <= nssl << 6;
	    nss  <= (nss <= 64) ? 1 : (nss>>6);
	 end
      else
	 write_count <= write_count - 1;
      
   endrule










   
   rule setup_stream_stage(!done && 
                           iter > 0 && 
                           set_next_stage );
      if(!debug_setup_stream_stage)
	 begin
	    set_count <= set_count - 1;      
	    
	    if (set_count == 0)
               set_next_stage <= False;
	    else
	       debug_setup_stream_stage <= True;
	       
	    if(nss==1)
	       begin
		  done <= True;
	       end
	    else
               begin
		  let a = rsp_offsets.sub(set_count);
		  let new_set_ptr_count = set_ptr_count - zeroExtend(ssl);
		  let chk = zeroExtend(63-set_count) >= nss; 
		  // set_ptr_count contains an offset in # records with the
		  // high bit indicating a bank select. (crying out for strong typing!!!)
		  set_ptr_count <= new_set_ptr_count;
		  base_ptrs.upd(set_count,   chk ? 0 : set_ptr_count);
		  req_offsets.upd(set_count, chk ? 0 : zeroExtend(ssl));
		  rsp_offsets.upd(set_count, chk ? 0 : zeroExtend(ssl));
		  eos_lefts.upd(set_count,(nss<kmerges) ? 1 : nss>>6); // number of substream / 64
		  if (`Debug) $display("%d base %x, req_offset %x, rsp_offset %x, eos_left %x",
				       set_count,
				       set_ptr_count,
				       (chk ? 0 : ssl),
				       (chk ? 0 : ssl),
				       ((nss < kmerges) ? 1 : nss>>6));
	       end
	    if(nss<=kmerges)
	       last <= True;
	 end
      else
	 begin
	    debug_setup_stream_stage <= False;
	    // this is OK for all but the largest size
	    // 12 bits
	    Bit#(12) eos_left = truncate(eos_lefts.sub(set_count+1));
	    // 12 bits
	    Bit#(12) bp = truncate(base_ptrs.sub(set_count+1)>>6);
	    // 4 bits  -- 2nd stage, only about 7th bit
	    Bit#(4) req_off  = truncate(req_offsets.sub(set_count+1)>>6);
	    let rv = {req_off, bp, eos_left};
	    //msg_queue.enq(zeroExtend(rv));
	 end
   endrule











   function Bool rdy_for_requests(Bit#(sz) x, Bool y);
      return (x >= rpmr) && !y; // also check for enough for eos
   endfunction
   




   function Tuple2#(Bool,a) first_possible(Tuple2#(Bool,a) fst,
					   Tuple2#(Bool,a) snd);
      return tpl_1(fst) ? fst : snd;
   endfunction
   






   rule schedule_read_request (!done && 
			       iter > 0 &&
			       !set_next_stage &&
			       !pending_read_req);
      Vector#(KMerges, Bool) pred =  zipWith(rdy_for_requests,
                                             sort_tree.inStream.getTokInfo,
                                             finish_stage);      
      Vector#(KMerges, KMask) idxs = genWith(fromInteger);   
      let vec  = zip(pred, idxs);
      let res  = fold(first_possible,vec);
      rsfifo.enq(res);
      match {.bv,.idx}  = res;
      if (`Debug) $display("schedule_read_requests %d, %d", bv, idx);
      if (`Debug) $display("   tok[%d] %d, ",idx,sort_tree.inStream.getTokInfo[idx]);
      if (`Debug) $display("finish[%d] %d, ",idx,finish_stage[idx]);
   endrule
   

// Why do they run when we are setting table?


   rule read_request_a (!done && iter > 0);
      rsfifo.deq();
      match {.bv,.idx}  = rsfifo.first();
      if(bv)
         begin
	    pending_read_req   <= True;
	    let base_ptr       = base_ptrs.sub(idx);
	    let new_base_ptr   = base_ptr - zeroExtend(nssl);
	    let req_offset     = req_offsets.sub(idx);
	    let req_addr       = zeroExtend(base_ptr - req_offset)*(recwid/32);
	    let eos_left       = eos_lefts.sub(idx);
	    let new_eos_left   = eos_left - 1;
	    let need_eos       = req_offset == 0;
	    let new_req_offset = (need_eos) ? zeroExtend(ssl) : req_offset - rpmr;
	    let rs_toks        = (need_eos) ? 1 : rpmr;
	    let is_fin_stage   = eos_left==1;
	    
	    pending_req_idx            <= idx;
      	    pending_req_new_base_ptr   <= new_base_ptr;
	    pending_req_req_addr       <= req_addr;
	    pending_req_new_eos_left   <= new_eos_left;
	    pending_req_need_eos       <= need_eos;
	    pending_req_new_req_offset <= new_req_offset;
	    pending_req_rs_toks        <= rs_toks;
	    pending_req_is_fin_stage   <= is_fin_stage;
            
            if (`Debug) $display("read_requests %d, %d", bv, idx);
	 end   
   endrule
   







   rule read_request_b (!done && iter>0 && pending_read_req);
      pending_read_req <= False;
      let idx            = pending_req_idx;
      let new_base_ptr   = pending_req_new_base_ptr;
      let req_addr       = pending_req_req_addr;
      let new_eos_left   = pending_req_new_eos_left;
      let need_eos       = pending_req_need_eos;
      let new_req_offset = pending_req_new_req_offset;
      let rs_toks        = pending_req_rs_toks;
      let is_fin_stage   = pending_req_is_fin_stage;

      if (need_eos)
         begin
	    finish_stage <= update(finish_stage,idx,is_fin_stage);
	    eos_lefts.upd(idx,new_eos_left);
	    base_ptrs.upd(idx,new_base_ptr);
	    if(`Debug) $display("eos_requests %d is_last_eos %d", 
				idx, is_fin_stage);
         end
      else
         begin
	    debug_read_requests <= debug_read_requests+1;
 	    extMem.read[readpt].readReq(req_addr);
	    if(`Debug) $display("read_requests idx %d, addr %x", 
				idx, req_addr);
         end
      rdfifo.enq(idx);
      req_offsets.upd(idx, new_req_offset);
      sort_tree.inStream.putDeqTok(idx,rs_toks);
      if(`Debug) $display("read_requests idx %d, new_req_offset %x, deqTok %d", 
			  idx, new_req_offset, rs_toks);
   endrule





   
   rule read_resp (!done && 
		   iter > 0 &&
		   !set_next_stage);
      
      let idx            = rdfifo.first();
      let rsp_offset     = rsp_offsets.sub(idx); 
      let need_eos       = rsp_offset == 0;
      let new_rsp_offset = (need_eos) ? zeroExtend(ssl) : rsp_offset - 1;
      
      RPMRMask rpmr_one = 1;
      
      if (((truncate(rsp_offset)&rpmr_mask) == rpmr_one)||need_eos)
	 rdfifo.deq();
      
      rsp_offsets.upd(idx,new_rsp_offset);
      if(need_eos)
         begin
            debug_write_eos_second <= debug_write_eos_second + 1;
	    put_rec_fifo.enq(tuple2(idx, tagged Invalid));
            if(`Debug) $display("read_resps eos %x", idx);            
         end
      else
	 begin
	    let val <- extMem.read[readpt].read();
	    put_rec_fifo.enq(tuple2(idx, tagged Valid val));
            if(`Debug) $display("read_resps idx %x val %x", idx, val);            
	 end
   endrule





   
   rule put_rec (True);
      put_rec_fifo.deq();
      match {.idx, .val} = put_rec_fifo.first();
      if(isValid(val))
	 debug_write_to_sort_tree <= debug_write_to_sort_tree+1;
      else
	 debug_write_eos_to_sort_tree <= debug_write_eos_to_sort_tree+1;
      sort_tree.inStream.putRecord(idx, val);
   endrule

   
   method Action doSort(Bit#(5) len) if (done);
      $display("doSort");
      RecAddr array_sz = 1<<len;
      let num_blocks = array_sz>>6;  // no. 64-record blocks we need for first stage = (2^len / 64)
      let block_sz = 63;             // 64 to go
      read_res_count  <= num_blocks; 
      res_count       <= 63;         
      read_req_count  <= array_sz;
      read_count      <= 63;         
      read_eos        <= False;
      write_count     <= array_sz;
      write_base_addr <= array_sz ^ truncate(bank_mask);
      write_req_count <= array_sz;
      out_buff_cnt    <= 0;
      log_len         <= len;
      iter            <= 0;
      done            <= False;
      array_len       <= array_sz;
      nss             <= array_sz;
      ssl             <= 1;
      nssl            <= 1<<6;
      aes_cores.start(len);
      if(len==6)
	 last <= True;
      else
	 last <= False;
   endmethod

   method Bool finished();
      return done;
   endmethod
   
   interface msgs = fifoToGet(msg_queue);
   
endmodule


module mkTH ();
   
   PLBMaster     plbmaster <- mkPLBMasterDummy;
   ExternalMemory   extMem <- mkExternalMemory(plbmaster); 
   Clock clk <- exposeCurrentClock;  
   Reset rst <- exposeCurrentReset;
   Control             cnt <- mkControl(extMem, clk, rst);
   
   Bit#(32) left_bank = (fromInteger(valueOf(MemBankSelector))>>2);
   Bit#(32) right_bank = 0;
   Bit#(32) bank_masks[13] = {left_bank,
			      right_bank,
			      right_bank,
			      right_bank,
			      right_bank,
			      right_bank,
			      right_bank,
			      left_bank,
			      left_bank,
			      left_bank,
			      left_bank,
			      left_bank,
			      left_bank};
   
   String dump_file_names[13] = {"sorted_array_6.txt",
				 "sorted_array_7.txt",
				 "sorted_array_8.txt",
				 "sorted_array_9.txt",
				 "sorted_array_10.txt",
				 "sorted_array_11.txt",
				 "sorted_array_12.txt",
				 "sorted_array_13.txt",
				 "sorted_array_14.txt",
				 "sorted_array_15.txt",
				 "sorted_array_16.txt",
				 "sorted_array_17.txt",
				 "sorted_array_18.txt"};
   RegFile#(Bit#(18), Record)         resmem <- mkRegFileFullLoad("sorted.hex");

   let recwid        = fromInteger(valueOf(RecordWidth));   
   let rpmr          = fromInteger(valueOf(RecordsPerMemRequest));
   RPMRMask rpmr_msk = 0;
   let log_len       = `LogArrayLen;  // this should be defined at the command line
   let bank_mask     = bank_masks[log_len-6];
   let dump_file     = dump_file_names[log_len-6];
   

   Reg#(Bit#(64)) cycleCnt  <- mkReg(0);
   Reg#(Bit#(64)) startTime <- mkReg(0);
   Reg#(Bit#(32)) count <- mkReg(0);
   Reg#(int) state      <- mkReg(0);
   Reg#(Bool) need_req  <- mkReg(True);
   Reg#(Bit#(18)) output_count <- mkReg(0);
   Reg#(Bit#(18)) req_count <- mkReg(0); 
   let fh               <- mkReg(InvalidFile) ;
   
   rule incrCycle (True);
      cycleCnt <= cycleCnt + 1;
   endrule
   
   rule open_file (state == 0 );
      $display("sorting an array of log_len %d", log_len);
      File lfh <- $fopen( dump_file, "w" ) ;
      if ( lfh == InvalidFile )
	 begin
            $display("cannot open %s", dump_file);
            $finish(0);
	 end
      fh <= lfh;
      state <= 2;
   endrule

   rule disp_msg (True);
      let a <- cnt.msgs.get();
      $display("MESSAGE from control %h",a);
   endrule
   
   rule disp_mem((state==4)&&need_req);
     extMem.read[0].readReq(bank_mask|{zeroExtend(req_count),5'b00});
     req_count <= req_count + 1;
     if(req_count + 1 == (1<<(log_len - 2)))
       begin
         need_req <= False;
       end   
   endrule

   rule check(state == 4);
     let data <- extMem.read[0].read();
     output_count <= output_count + 1;
     if(data != resmem.sub(output_count))
       begin
          $display("Error at %d: got %h expected %h",output_count, data, resmem.sub(output_count));
	  $fwrite(fh, "Error at %d: got %h expected %h",output_count, data, resmem.sub(output_count));
	  $finish;
	  
       end
     if(output_count + 1 == (1<<log_len))
        begin
           $display("PASS Size %d!!!!", log_len);
	   $fwrite(fh, "PASS Size %d!!!!", log_len);
           $finish;
        end
   endrule
   
   rule start_sort(state==2);
      cnt.doSort(log_len);
      state <= 3;
   
      startTime <= startTime + 1;
   endrule
   
   rule disp_orig_a((state==3)&&cnt.finished());
      state <= 4;
      
      $display("Total cycles %d",cycleCnt - startTime);
   endrule
   
   rule finish(state==5);
      $finish;
   endrule   
endmodule


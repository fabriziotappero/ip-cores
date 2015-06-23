// import standard library
import FIFO::*;
import RegFile::*;
import StmtFSM::*;
import Vector::*;

// import self-made library
import BRAM::*;
import VLevelFIFO::*;
 
// implementation of VLevelFIFO with BRAM
module mkBRAMVLevelFIFO (VLevelFIFO#(no_fifo, fifo_sz, data_t))
   provisos (Bits#(data_t,data_sz),
             Add#(TLog#(no_fifo),TLog#(fifo_sz),bram_idx_sz));   

   // instantiate an unguarded 1 cycle latency bram (i.e. the read response will only valid for 1 cycle)  
   UGBRAM#(Bit#(bram_idx_sz), data_t)           ugbram <- mkBypassUGBRAM_Full();
   
   RegFile#(Bit#(TLog#(no_fifo)),Bit#(TLog#(fifo_sz)))  head <- mkRegFileFull();
   RegFile#(Bit#(TLog#(no_fifo)),Bit#(TLog#(fifo_sz)))  tail <- mkRegFileFull();
   Reg#(Bit#(TLog#(no_fifo))) i <- mkReg(0);
   Reg#(Bool)                 finishInit <- mkReg(False);
   
   Reg#(Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))))  usedReg <- mkReg(replicate(0));
   Wire#(Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1))))) usedW   <- mkDWire(replicate(0));
   
   Reg#(Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))))  freeReg <- mkReg(replicate(fromInteger(valueOf(fifo_sz))));
   
   Wire#(Maybe#(Bit#(TLog#(no_fifo)))) enqIdx <- mkDWire(tagged Invalid);
   Wire#(data_t)                       enqVal <- mkDWire(?);
   
   Wire#(Maybe#(Bit#(TLog#(no_fifo)))) deqIdx <- mkDWire(tagged Invalid);

   Wire#(Maybe#(Bit#(TLog#(no_fifo)))) firstIdx <- mkDWire(tagged Invalid);
   
   Wire#(Maybe#(Bit#(TLog#(no_fifo)))) decrFreeIdx <- mkDWire(tagged Invalid);
      
   let enqIdxVal         = fromMaybe(0,enqIdx);
   let deqIdxVal         = fromMaybe(0,deqIdx);
   let firstIdxVal       = fromMaybe(0,firstIdx);
   let decrFreeIdxVal    = fromMaybe(0,decrFreeIdx);
   let deqIdxNEQFirstIdx = deqIdxVal != firstIdxVal;  
   let readResp          = ugbram.read_resp();
   
   // start the initialization processor
   rule initialization(!finishInit);
      head.upd(i,0);
      tail.upd(i,0);
      i <= i + 1;
      if (i == fromInteger(valueOf(no_fifo)-1))
         finishInit <= True;
   endrule
   
   rule updateUsedReg(finishInit && (isValid(enqIdx) || isValid(deqIdx)));
      Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) newUsedReg = newVector();
      
      for (Integer i = 0; i < valueOf(no_fifo); i = i + 1)
         newUsedReg[i] = usedReg[i];
      
      if (isValid(enqIdx))
         newUsedReg[enqIdxVal] = usedReg[enqIdxVal] + 1;

      if (isValid(deqIdx))
         newUsedReg[deqIdxVal] = newUsedReg[deqIdxVal] - 1;

      usedReg <= newUsedReg;
      usedW <= newUsedReg;

//      $display("updateUsedReg");
   endrule
   
   rule updateUsedW(finishInit && !(isValid(enqIdx) || isValid(deqIdx)));
      usedW <= usedReg;
   endrule
   
   rule updateFreeReg(finishInit && (isValid(decrFreeIdx) || isValid(deqIdx)));
      Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) newFreeReg = newVector();

      for (Integer i = 0; i < valueOf(no_fifo); i = i + 1)
         newFreeReg[i] = freeReg[i];               

      if (isValid(decrFreeIdx))
         newFreeReg[decrFreeIdxVal] = freeReg[decrFreeIdxVal] - 1;

      if (isValid(deqIdx))
         newFreeReg[deqIdxVal] = newFreeReg[deqIdxVal] + 1;               

      freeReg <= newFreeReg;

//      $display("updateFreeReg");
   endrule
   
   rule processEnq(finishInit && isValid(enqIdx));
      let tailVal = tail.sub(enqIdxVal);
      tail.upd(enqIdxVal, (tailVal + 1));
      ugbram.write({enqIdxVal,tailVal},enqVal);

//      $display("enq data %d to fifo %d with tailVal %d",data,idx,tailVal);
   endrule
   
   rule processFirstReq(finishInit && isValid(firstIdx));
      let headVal = head.sub(firstIdxVal);
      if (deqIdxNEQFirstIdx || !isValid(deqIdx))
         begin
            ugbram.read_req({firstIdxVal,headVal});
            //$display("first read idx %d headVal %d",firstIdxVal,headVal);
         end
      else // the fifo is dequeued at that cycle, we should read the next head
         begin
            ugbram.read_req({firstIdxVal,headVal+1});
            //$display("first read idx %d headVal+1 %d",firstIdxVal,headVal+1);
         end
   endrule

   rule processDeq(finishInit && isValid(deqIdx));
      let headVal = head.sub(deqIdxVal);
      head.upd(deqIdxVal, (headVal + 1));      
   endrule
   
   // enq is unguarded here, we expect the user to check it before they enq
   method Action enq(Bit#(TLog#(no_fifo)) idx, data_t data) if (finishInit);
      enqIdx <= tagged Valid idx;
      enqVal <= data;      
   endmethod
   
   // deq is unguarded here, we expect the user to check it before they deq
   method Action deq(Bit#(TLog#(no_fifo)) idx) if (finishInit);
      deqIdx <= tagged Valid idx;
      
//      $display("deq fifo %d",idx);
   endmethod
   
   method Action firstReq(Bit#(TLog#(no_fifo)) idx) if (finishInit);
      firstIdx <= tagged Valid idx;
   endmethod
   
   // first is unguarded here, we expecte the user to check it before they call first
   method data_t firstResp() if (finishInit);
      return readResp;
   endmethod
   
   method Action clear() if (finishInit);
      noAction;
   endmethod
   
   // return the usage of each fifo at the beginning of the cycle
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) used() if (finishInit);
      return usedReg;
   endmethod
   
   // return the usage of each fifo at the end of the cycle
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) used2() if (finishInit);
      return usedW;
   endmethod
   
   // return enq credit token available for each fifo
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) free() if (finishInit);
      return freeReg;
   endmethod
   
   // get credit token to enq fifo idx in the future
   // this method is unguarded (i.e. user need to call method free 
   // and check for token availability before calling this action)
   method Action decrFree(Bit#(TLog#(no_fifo)) idx) if (finishInit);
      decrFreeIdx <= tagged Valid idx;
   endmethod
   
endmodule

(* synthesize *)
module mkBRAMVLevelFIFOInstance(VLevelFIFO#(32, 16, Bit#(129)));
   let fifo <- mkBRAMVLevelFIFO();
   return fifo;
endmodule

/*
(* synthesize *)
module mkBRAMVLevelFIFOTest(Empty);
   let fifo <- mkBRAMVLevelFIFOInstance();
   Reg#(Bit#(8)) enqIdx <- mkReg(0);
   Reg#(Bit#(129)) enqData <- mkReg(0);
   Reg#(Bit#(8)) firstIdx <- mkReg(0);
   FIFO#(Bit#(0)) reqQ <- mkFIFO();
   Reg#(Bit#(8)) deqIdx <- mkReg(0);
   Reg#(Bit#(32)) cycleCnt <- mkReg(0);
   let used = fifo.used();
   let free = fifo.free();

   rule enqFifo(free[enqIdx[7:2]] > 0);      
      enqIdx <= enqIdx + 1;
      enqData <= enqData + 1;
      fifo.enq(enqIdx[7:2],enqData);
      fifo.decrFree(enqIdx[7:2]);
      
      $display("enq fifo %d with data %d",enqIdx[7:2],enqData);
   endrule
   
   rule firstFifo(used[deqIdx[7:2]] > 0);
      firstIdx <= firstIdx + 1;
      fifo.firstReq(firstIdx[7:2]);
      reqQ.enq(?);
      
      $display("first req fifo %d",firstIdx[7:2]);
   endrule
   
   rule deqFifo(True);
      reqQ.deq();
      if (used[deqIdx[7:2]] > 0)
         begin
            deqIdx <= deqIdx + 1;
            let deqData = fifo.firstResp();
            fifo.deq(deqIdx[7:2]);
            
            $display("deq fifo %d with data %d",deqIdx[7:2],deqData);
         end
      else
        $display("last first req is not reading valid data");
   endrule
   
   rule displayStat(True);
      for (Integer i = 0; i < 64; i = i + 1)
         $display("%d: used %d, free %d",i,used[i],free[i]);
   endrule
   
   rule countCycle(True);
      cycleCnt <= cycleCnt + 1;
      $display("cycle %d",cycleCnt);
      if (cycleCnt == 5000)
         $finish();
   endrule
   
endmodule
 */
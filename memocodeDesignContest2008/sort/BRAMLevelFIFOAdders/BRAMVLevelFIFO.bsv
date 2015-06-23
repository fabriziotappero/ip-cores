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

//////////////////////////////////////////////////////////////////////////
// Summary
//
// This file describes the implementation of VLevelFIFO which time multiplex
// a single memory instance with one write port and one read port between
// multiple logical fifos. The implementation is parameteric in the following
// ways: 1) the number of logical fifos, 2) the size of each logical fifo,
// 3) the data type stored in the fifo      
//////////////////////////////////////////////////////////////////////////

// import standard library
import DReg::*;
import FIFO::*;
import RegFile::*;
import StmtFSM::*;
import Vector::*;

// import self-made library
import BRAM::*;
import EHRReg::*;
import VLevelFIFO::*;

`define Debug False

// try to update the new value of vec[idx] to f(vec[idx]) 
function Vector#(sz,a) parUpdate (Vector#(sz,a) vec, Bit#(isz) idx, 
                                  function a f (a val));
   Vector#(sz,a) new_vec = newVector();
   for (Integer i = 0; i < valueOf(sz); i = i + 1)
      begin
         if (idx == fromInteger(i))
            new_vec[i] = f(vec[i]);
         else
            new_vec[i] = vec[i];
      end
   return new_vec;
endfunction
   
function Bit#(a) decrBy(Bit#(a) snd, Bit#(a) fst);
   return fst - snd;
endfunction
 
// implementation of VLevelFIFO with BRAM
module mkBRAMVLevelFIFO (VLevelFIFO#(no_fifo, fifo_sz, data_t))
   provisos (Bits#(data_t,data_sz),
             Add#(TLog#(no_fifo),TLog#(fifo_sz),bram_idx_sz));   

   // instantiate an unguarded 1 cycle latency bram (i.e. the read response will only valid for 1 cycle)  
   UGBRAM#(Bit#(bram_idx_sz), data_t)           ugbram <- mkBypassUGBRAM_Full();
   
   RegFile#(Bit#(TLog#(no_fifo)),Bit#(TLog#(fifo_sz)))  head <- mkRegFileFull();
   RegFile#(Bit#(TLog#(no_fifo)),Bit#(TLog#(fifo_sz)))  tail <- mkRegFileFull();
   Reg#(Bit#(TLog#(no_fifo))) i <- mkReg(0);
   Reg#(Bool) finishInit <- mkReg(False);
   
   EHRReg#(2,Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))))  usedReg;
   usedReg <- mkEHRReg(replicate(0));  
   EHRReg#(2,Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))))  freeReg;
   freeReg <- mkEHRReg(replicate(fromInteger(valueOf(fifo_sz))));

   Wire#(Maybe#(Bit#(TLog#(no_fifo))))  enqIdx <- mkDWire(tagged Invalid);
   Wire#(data_t)                        enqVal <- mkDWire(?);
   Reg#(Maybe#(Bit#(TLog#(no_fifo))))   lastEnqIdx <- mkDReg(tagged Invalid);     
   
   Wire#(Maybe#(Bit#(TLog#(no_fifo))))  deqIdx <- mkDWire(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(no_fifo))))   lastDeqIdx <- mkDReg(tagged Invalid);     

   Wire#(Maybe#(Bit#(TLog#(no_fifo))))  firstIdx <- mkDWire(tagged Invalid);
   
   Wire#(Maybe#(Bit#(TLog#(no_fifo))))  decrFreeIdx <- mkDWire(tagged Invalid);
   Wire#(Bit#(TLog#(TAdd#(fifo_sz,1)))) decrFreeAmnt <- mkDWire(?);
      
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
   
   rule processEnq(finishInit && isValid(enqIdx));
      let tailVal = tail.sub(enqIdxVal);
      tail.upd(enqIdxVal, (tailVal + 1));
      ugbram.write({enqIdxVal,tailVal},enqVal);
      lastEnqIdx <= enqIdx;
      
      if(`Debug) $display("%m enq data %d to fifo %d with tailVal %d",enqVal,enqIdxVal,tailVal);
   endrule
    
   // last cycle someone enq, we update the usedReg this cycle (conservative
   rule updateUsedReg (isValid(lastEnqIdx));
      let idx = fromMaybe(?,lastEnqIdx);
      usedReg[0] <= parUpdate(usedReg[0], idx, \+ (1));

      if(`Debug) $display("%m updateUsedReg idx %d old val %d new val %d",idx,usedReg[0][idx], usedReg[1][idx]);
   endrule  
      
   // last cycle someone deq, we update the freeReg this cycle (conservative)
   rule updateFreeReg (isValid(lastDeqIdx));
      let idx = fromMaybe(?,lastDeqIdx);
      freeReg[0] <= parUpdate(freeReg[0], idx, \+ (1));

      if(`Debug) $display("%m updateFreeReg idx %d old val %d new val %d",idx,freeReg[0][idx], freeReg[1][idx]);
   endrule  
   
   rule processDeq(finishInit && isValid(deqIdx));
      let headVal = head.sub(deqIdxVal);
      head.upd(deqIdxVal, (headVal + 1));     
      usedReg[1] <= parUpdate(usedReg[1], deqIdxVal, decrBy(1));
      lastDeqIdx <= deqIdx;

      if(`Debug) $display("%m deq fifo %d",deqIdxVal);
   endrule
   
   rule processFirstReq(finishInit && isValid(firstIdx));
      let headVal = head.sub(firstIdxVal);
      ugbram.read_req({firstIdxVal,headVal});
//       if (deqIdxNEQFirstIdx || !isValid(deqIdx))
//          begin
//             ugbram.read_req({firstIdxVal,headVal});
            
//             if(`Debug) $display("%m first read idx %d headVal %d",firstIdxVal,headVal);
//          end
//       else // the fifo is dequeued at that cycle, we should read the next head
//          begin
//             ugbram.read_req({firstIdxVal,headVal+1});
            
//             if(`Debug) $display("%m first read idx %d headVal+1 %d",firstIdxVal,headVal+1);
//          end
   endrule
           
   rule processDecrFree(finishInit && isValid(decrFreeIdx));             
      freeReg[1] <= parUpdate(freeReg[1], decrFreeIdxVal, decrBy(decrFreeAmnt));
      
      if(`Debug) $display("%m decrFree fifo %d by %d",decrFreeIdxVal,decrFreeAmnt);
   endrule

   // enq is unguarded here, we expect the user to check it before they enq
   method Action enq(Bit#(TLog#(no_fifo)) idx, data_t data) if (finishInit);
      enqIdx <= tagged Valid idx;
      enqVal <= data;      
   endmethod
   
   // deq is unguarded here, we expect the user to check it before they deq
   method Action deq(Bit#(TLog#(no_fifo)) idx)  if (finishInit);
      deqIdx <= tagged Valid idx;    
   endmethod
   
   method Action firstReq(Bit#(TLog#(no_fifo)) idx)  if (finishInit);
      firstIdx <= tagged Valid idx;
   endmethod
   
   // first is unguarded here, we expecte the user to check it before they call first
   method data_t firstResp()  if (finishInit);
      return readResp;
   endmethod
   
   method Action clear()  if (finishInit);
      noAction;
   endmethod
   
   // return the usage of each fifo at the beginning of the cycle
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) used()  if (finishInit);
      return usedReg[0];
   endmethod
   
   // return enq credit token available for each fifo
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) free()  if (finishInit);
      return freeReg[0];
   endmethod
   
   // get credit token to enq fifo idx in the future
   // this method is unguarded (i.e. user need to call method free 
   // and check for token availability before calling this action)
   method Action decrFree(Bit#(TLog#(no_fifo)) idx, Bit#(TLog#(TAdd#(fifo_sz,1))) amnt)  if (finishInit);
      decrFreeIdx  <= tagged Valid idx;
      decrFreeAmnt <= amnt; 
   endmethod
   
endmodule
 
// implementation of VLevelFIFO with BRAM decrFree is always treated as deq one token
module mkDecrOneBRAMVLevelFIFO (VLevelFIFO#(no_fifo, fifo_sz, data_t))
   provisos (Bits#(data_t,data_sz),
             Add#(TLog#(no_fifo),TLog#(fifo_sz),bram_idx_sz));   

   // instantiate an unguarded 1 cycle latency bram (i.e. the read response will only valid for 1 cycle)  
   UGBRAM#(Bit#(bram_idx_sz), data_t)           ugbram <- mkBypassUGBRAM_Full();
   
   RegFile#(Bit#(TLog#(no_fifo)),Bit#(TLog#(fifo_sz)))  head <- mkRegFileFull();
   RegFile#(Bit#(TLog#(no_fifo)),Bit#(TLog#(fifo_sz)))  tail <- mkRegFileFull();
   Reg#(Bit#(TLog#(no_fifo))) i <- mkReg(0);
   Reg#(Bool) finishInit <- mkReg(False);
   
   Reg#(Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))))  usedReg <- mkReg(replicate(0));
   
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
         begin
            Bit#(TLog#(no_fifo)) iVal = fromInteger(i);
            let checkEnqIdx = enqIdxVal == iVal;
            let checkDeqIdx = deqIdxVal == iVal;
            if (isValid(enqIdx) && checkEnqIdx && !(isValid(deqIdx) && checkDeqIdx))
               newUsedReg[i] = usedReg[i] + 1;
            else
               if (isValid(deqIdx) && checkDeqIdx && !(isValid(enqIdx) && checkEnqIdx))
                  newUsedReg[i] = usedReg[i] - 1;
               else
                  newUsedReg[i] = usedReg[i];
         end
      usedReg <= newUsedReg;

      if(`Debug) $display("%m updateUsedReg");
   endrule
   
   rule updateFreeReg(finishInit && (isValid(decrFreeIdx) || isValid(deqIdx)));
      Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) newFreeReg = newVector();
      for (Integer i = 0; i < valueOf(no_fifo); i = i + 1)
         begin
            Bit#(TLog#(no_fifo)) iVal = fromInteger(i);
            let checkDecrFreeIdx      = decrFreeIdxVal == iVal;
            let checkDeqIdx           = deqIdxVal == iVal;
            if (isValid(decrFreeIdx) && checkDecrFreeIdx && !(isValid(deqIdx) && checkDeqIdx))
               newFreeReg[i] = freeReg[i] - 1;
            else
               if (isValid(deqIdx) && checkDeqIdx && !(isValid(decrFreeIdx) && checkDecrFreeIdx))
                  newFreeReg[i] = freeReg[i] + 1;               
               else
                  newFreeReg[i] = freeReg[i];               
         end
      freeReg <= newFreeReg;

      if(`Debug) $display("%m updateFreeReg");
   endrule
   
   rule processEnq(finishInit && isValid(enqIdx));
      let tailVal = tail.sub(enqIdxVal);
      tail.upd(enqIdxVal, (tailVal + 1));
      ugbram.write({enqIdxVal,tailVal},enqVal);

      if(`Debug) $display("%m enq data %d to fifo %d with tailVal %d",enqVal,enqIdxVal,tailVal);
   endrule
   
   rule processFirstReq(finishInit && isValid(firstIdx));
      let headVal = head.sub(firstIdxVal);
      ugbram.read_req({firstIdxVal,headVal});
      
//       if (deqIdxNEQFirstIdx || !isValid(deqIdx))
//          begin
//             ugbram.read_req({firstIdxVal,headVal});
//             if(`Debug) $display("%m first read idx %d headVal %d",firstIdxVal,headVal);
//          end
//       else // the fifo is dequeued at that cycle, we should read the next head
//          begin
//             ugbram.read_req({firstIdxVal,headVal+1});
//             if(`Debug) $display("%m first read idx %d headVal+1 %d",firstIdxVal,headVal+1);
//          end
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
   method Action deq(Bit#(TLog#(no_fifo)) idx)  if (finishInit);
      deqIdx <= tagged Valid idx;
      
      if(`Debug) $display("%m deq fifo %d",idx);
   endmethod
   
   method Action firstReq(Bit#(TLog#(no_fifo)) idx)  if (finishInit);
      firstIdx <= tagged Valid idx;
   endmethod
   
   // first is unguarded here, we expecte the user to check it before they call first
   method data_t firstResp()  if (finishInit);
      return readResp;
   endmethod
   
   method Action clear()  if (finishInit);
      noAction;
   endmethod
   
   // return the usage of each fifo at the beginning of the cycle
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) used()  if (finishInit);
      return usedReg;
   endmethod
   
   // return enq credit token available for each fifo
   method Vector#(no_fifo,Bit#(TLog#(TAdd#(fifo_sz,1)))) free()  if (finishInit);
      return freeReg;
   endmethod
   
   // get credit token to enq fifo idx in the future
   // this method is unguarded (i.e. user need to call method free 
   // and check for token availability before calling this action)
   method Action decrFree(Bit#(TLog#(no_fifo)) idx, Bit#(TLog#(TAdd#(fifo_sz,1))) amnt)  if (finishInit);
      decrFreeIdx <= tagged Valid idx;
   endmethod
   
endmodule
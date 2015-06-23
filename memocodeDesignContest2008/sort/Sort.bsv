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
// Summary:
//
// This file describes the implementations of a level of a merge tree, there
// are two implementations: 1) mkTwoToOneMerger and 2) mkBRAMOneLevelMerger. 
// "mkTwoToOneMerger" is used to instantiate the top level 
// (i.e. the 1st level) of the sort tree. It is a straight forward implementation of 
// a two-to-one merger which merges two sorted streams into a single sorted stream.
// The implementation is parameterized for the width of the each data entry.       
// "mkBRAMOneLevelMerger" is used to instantiate other levels of the sort tree.
// The implementation merges 2n sorted streams into n sorted streams, whereas n is 
// a static parameter. It is obvious that an straight forward implementation 
// will simply have n two-to-one mergers. However, this makes the area of one level 
// roughly grows twice as big as the previous level. Since the performance of 
// is bottlenecked by the top level, we decide to time multiplex a single two-to-one
// merger between the 2n streams. This allows the area of the design grow with the level
// while maintaining roughtly the same performance throughput. One of the biggest challenges
// of the design is to determine which two stream to be merged next. 
// The problem gets tougher with lower level of the sort tree because more streams are available. 
// To solve this problem, we make the scheduler as a parameter to "mkBRAMOneLevelMerger". 
// The scheduler implements the algorithm for picking the next two stream to merge. 
// We have different implementations of the scheduler which have different complexity and 
// take different number of cycles to return the decision. By passing the appropriate scheduler 
// implementations to the same "mkBRAMOneLevelMerger" definition, we can instantiate 
// different levels of the sort tree with roughly the same critical path.                                
//////////////////////////////////////////////////////////////////////////

// import standard librarys
import Connectable::*;
import GetPut::*;
import FIFO::*;
import FIFOF::*;
import StmtFSM::*;
import Vector::*;

// import self-made library
import BRAMVLevelFIFO::*;
import EHRReg::*;
import VLevelFIFO::*;

`define SortDebug0 False
`define SortDebug1 False

//////////////////////////////////////////////////////////////////////////////////////////////
// interfaces definitions

interface InStream#(numeric type k, type tok_t, type record_t);
   // call this method to check the no. credit tokens available for each queue
   method Vector#(k,tok_t)                      getTokInfo();

   // call this method to reserve 'amnt' credit tokens for queue (stream) 'idx' 
   // notes: 1) amnt must be less than tokens implies by getTokInfo
   //        2) caller must guarantee they put amnt records into the sort tree in the future
   method Action                                putDeqTok(Bit#(TLog#(k)) idx, tok_t amnt);

   // call this method to put the data record into the sort tree
   method Action                                putRecord(Bit#(TLog#(k)) idx, record_t record);
endinterface   


interface OutStream#(numeric type k, type tok_t, type record_t);
   // call this method to tell its user no. credit tokens available 
   method Action                           putTokInfo (Vector#(k,tok_t) tokInfo);
      
   // call this method to see how many credit tokens and which queue the user want to reserve   
   // notes: 1) amnt must be less than tokens implies by getTokInfo
   //        2) caller must guarantee they put amnt records into the sort tree in the future      
   method Tuple2#(Bit#(TLog#(k)),tok_t)    getDeqTok();
      
   // call this method to see whether user has record coming out    
   method Tuple2#(Bit#(TLog#(k)),record_t) getRecord();
endinterface   

// define the interface for a k-merge sort (i.e. merge
// k sorted streams into 1 sorted stream)
interface SortTree#(numeric type k, type tok_t, type record_t);

   // the input stream
   interface InStream#(k, tok_t, record_t) inStream;
   
   // the output merged data
   method ActionValue#(record_t)           getRecord();    
endinterface

   
// interface for intermediate levels of the tree
interface SortLevel#(numeric type k, numeric type k_next, 
                    type tok_t, type next_tok_t,
                    type record_t);
   
   // the input stream
   interface InStream#(k, tok_t, record_t)            inStream;
      
   // the output stream
   interface OutStream#(k_next, next_tok_t, record_t) outStream;
      
endinterface



// the scheduler interface, the scheduler try to collect credit tokens information
// from the next level and the current level of the sort and then decide which
// stream to process next  
interface Scheduler#(numeric type k, type tok_t, type next_tok_t);
   // give the scheduler usage information so that it can pick the next to process
   (* always_ready *) method Action putInfo(Vector#(k,next_tok_t) nextTok,
                                            Vector#(k,tok_t)      tok0,
                                            Vector#(k,tok_t)      tok1);
                         
   // return the next stream to be processed, if return tagged Invalid = do nothing
   (* always_ready *) method Maybe#(Bit#(TLog#(k))) getNext();
endinterface 



//////////////////////////////////////////////////////////////////////////
// auxiliary functions

function Bool notValid(Maybe#(a) i);
   return !isValid(i);
endfunction

function Bool largerThan(Bit#(sz) a, Bit#(sz) val);
   return val > a;
endfunction

function Bool and3(Bool a, Bool b, Bool c);
   return a && b && c;
endfunction

function Tuple2#(Bool,a) chooseFirstIfPossible(Tuple2#(Bool,a) fst,
                                               Tuple2#(Bool,a) snd);
   return tpl_1(fst) ? fst : snd;
endfunction

function Bool isSmaller(d_t a, d_t b)
   provisos (Bits#(d_t,d_sz),
             Mul#(8,q_sz,d_sz),
             Add#(1,xxA,d_sz));
   
   Vector#(8,Bit#(q_sz)) aVec = reverse(unpack(pack(a)));
   Vector#(8,Bit#(q_sz)) bVec = reverse(unpack(pack(b)));
   
   function Tuple2#(Bool,Bool) getLargerAndEqual(Tuple2#(Bool,Bool) aTup, Tuple2#(Bool,Bool) bTup);
      return tuple2((tpl_1(aTup) || (tpl_2(aTup) && tpl_1(bTup))), 
                    (tpl_2(aTup) && tpl_2(bTup)));
   endfunction
   
   let res = tpl_1(fold(getLargerAndEqual, 
                        zip(zipWith(\< ,aVec,bVec),
                            zipWith(\== ,aVec,bVec))));
   
   return res;
   
endfunction

//////////////////////////////////////////////////////////////////////////
// Module definitions

//instance Connectable

instance Connectable#(OutStream#(k,tok_t,record_t), InStream#(k,tok_t,record_t));
  module mkConnection#(OutStream#(k,tok_t,record_t) out, 
                       InStream#(k,tok_t,record_t) in) (Empty);
   
   rule connectTokInfo(True);
      out.putTokInfo(in.getTokInfo());
   endrule
   
   rule connectDeqTok(True);
      match {.idx, .amnt} = out.getDeqTok();
      in.putDeqTok(idx,amnt);
   endrule
   
   rule connectRecord(True);
      let tup = out.getRecord();
      in.putRecord(tpl_1(tup),tpl_2(tup));
   endrule
  endmodule
endinstance


// a scheduler which the scheduling decision is return in the same cycle
module mkZeroCycleScheduler (Scheduler#(k_next,Bit#(sz),Bit#(sz_next)))
   provisos (Add#(1,xxA,k_next));
   
   Reg#(Maybe#(Bit#(TLog#(k_next))))  last     <- mkReg(tagged Invalid);

   Wire#(Maybe#(Bit#(TLog#(k_next)))) getNextW <- mkDWire(tagged Invalid); 
   
   method Action putInfo(Vector#(k_next,Bit#(sz_next)) nextTok,
                         Vector#(k_next,Bit#(sz))      tok0,
                         Vector#(k_next,Bit#(sz))      tok1);
      let idx    = fromMaybe(?,last);
      let okNext = map(largerThan(0),nextTok);
      let ok0    = map(largerThan(0),tok0);
      ok0[idx]   = isValid(last) ? False : ok0[idx];
      let ok1    = map(largerThan(0),tok1);   
      let okVec0 = zipWith3(and3,okNext,ok0,ok1);
      Vector#(k_next,Integer) intVec = genVector();
      let vec0   = zip(okVec0,intVec);
      let res0   = fold(chooseFirstIfPossible,vec0);
      let dec    = tpl_1(res0) ? tagged Valid fromInteger(tpl_2(res0)) : 
                                 tagged Invalid;  
      last <= dec;
      getNextW <= dec;

      if(`SortDebug0) $display("%m scheduler choose ok %d idx %d",isValid(dec),fromMaybe(?,dec));
   endmethod
      
   method Maybe#(Bit#(TLog#(k_next))) getNext();
      return getNextW;
   endmethod

endmodule

// a scheduler which the scheduling decision is returned one cycle later
module mkOneCycleScheduler (Scheduler#(k_next,Bit#(sz),Bit#(sz_next)))
   provisos (Add#(1,xxA,k_next));
   
   Reg#(Maybe#(Bit#(TLog#(k_next))))  last     <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sndLast  <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sRes0    <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sRes1    <- mkReg(tagged Invalid);

   Wire#(Maybe#(Bit#(TLog#(k_next)))) getNextW <- mkDWire(tagged Invalid); 
   
   rule choose(True);
      let chk1 = (sRes1 != last) && (sRes1 != sndLast);
      let next = chk1 ? sRes1 : sRes0;
      sndLast <= last;
      last <= next;
      getNextW <= next;
      if(`SortDebug0) $display("%m scheduler choose ok %d idx %d",isValid(next),fromMaybe(?,next));
   endrule   
   
   method Action putInfo(Vector#(k_next,Bit#(sz_next)) nextTok,
                         Vector#(k_next,Bit#(sz))      tok0,
                         Vector#(k_next,Bit#(sz))      tok1);
      let okNext = map(largerThan(2),nextTok);
      let ok0    = map(largerThan(2),tok0);
      let ok1    = map(largerThan(2),tok1);   
      let okVec0 = zipWith3(and3,okNext,ok0,ok1);
      Vector#(k_next,Integer) intVec = genVector();
      let vec0   = zip(okVec0,intVec);
      let res0   = fold(chooseFirstIfPossible,vec0);
      let dec0   = tpl_1(res0) ? tagged Valid fromInteger(tpl_2(res0)) : 
                                 tagged Invalid;  

      let okNext1 = map(largerThan(0),nextTok);
      let ok2     = map(largerThan(0),tok0);
      let ok3     = map(largerThan(0),tok1);   
      let okVec1  = zipWith3(and3,okNext1,ok2,ok3);
      let vec1    = zip(okVec1,intVec);
      let res1    = fold(chooseFirstIfPossible,vec1);
      let dec1    = tpl_1(res1) ? tagged Valid fromInteger(tpl_2(res1)) : 
                                  tagged Invalid;  
   
      sRes0 <= dec0;
      sRes1 <= dec1;
   endmethod
      
   method Maybe#(Bit#(TLog#(k_next))) getNext();
      return getNextW;
   endmethod

endmodule

// a scheduler which the scheduling decision is returned one cycle later
module mkOneCycleScheduler2 (Scheduler#(k_next,Bit#(sz),Bit#(sz_next)))
   provisos (Add#(1,xxA,k_half),
             Div#(k_next,2,k_half),
             Add#(k_half,k_half,k_next));
   
   Reg#(Maybe#(Bit#(TLog#(k_next))))  last     <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sndLast  <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sRes0    <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sRes1    <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sRes2    <- mkReg(tagged Invalid);
   Reg#(Maybe#(Bit#(TLog#(k_next))))  sRes3    <- mkReg(tagged Invalid);
   Reg#(Bool)                         round    <- mkReg(False);
   
   Wire#(Maybe#(Bit#(TLog#(k_next)))) getNextW <- mkDWire(tagged Invalid); 
   
   rule choose(True);
//       let chk2 = (sRes2 != last) && (sRes2 != sndLast);
//       let chk3 = (sRes3 != last) && (sRes3 != sndLast);
//       let next0 = chk2 ? sRes2 : sRes0;
//       let next1 = chk3 ? sRes3 : sRes1;
//       let next3 = isValid(next0) ? next0 : next1;
//       let next4 = isValid(next1) ? next1 : next0;
//       let next = round ? next3 : next4;

      let chk2 = (sRes2 != last) && (sRes2 != sndLast);
      let chk3 = (sRes3 != last) && (sRes3 != sndLast);
      let next0 = chk2 ? sRes2 : sRes0;
      let next1 = chk3 ? sRes3 : sRes1;
      let next  = round ? next0 : next1;

      sndLast <= last;
      last <= next;
      getNextW <= next;
      round <= !round;
      
      if(`SortDebug0) $display("%m scheduler choose ok %d idx %d",isValid(next),fromMaybe(?,next));
   endrule   
   
   method Action putInfo(Vector#(k_next,Bit#(sz_next)) nextTok,
                         Vector#(k_next,Bit#(sz))      tok0,
                         Vector#(k_next,Bit#(sz))      tok1);
//       let okNext = map(largerThan(2),nextTok);
//       let ok0    = map(largerThan(2),tok0);
//       let ok1    = map(largerThan(2),tok1);   
//       let okVec = zipWith3(and3,okNext,ok0,ok1);
      Vector#(k_next,Integer) intVec = genVector();
//       let vec   = zip(okVec,intVec);
//       Vector#(k_half,Tuple2#(Bool,Integer)) vec0 = take(vec);
//       Vector#(k_half,Tuple2#(Bool,Integer)) vec1 = takeTail(vec);
//       let res0   = fold(chooseFirstIfPossible,vec0);
//       let res1   = fold(chooseFirstIfPossible,vec1);
//       let dec0   = tpl_1(res0) ? tagged Valid fromInteger(tpl_2(res0)) : 
//                                  tagged Invalid;  
//       let dec1   = tpl_1(res1) ? tagged Valid fromInteger(tpl_2(res1)) : 
//                                  tagged Invalid;  

      let okNext1 = map(largerThan(0),nextTok);
      let ok2     = map(largerThan(0),tok0);
      let ok3     = map(largerThan(0),tok1);   
      let okVec1  = zipWith3(and3,okNext1,ok2,ok3);
      let vecc    = zip(okVec1,intVec);
      Vector#(k_half,Tuple2#(Bool,Integer)) vec2 = take(vecc);
      Vector#(k_half,Tuple2#(Bool,Integer)) vec3 = takeTail(vecc);
      let res2   = fold(chooseFirstIfPossible,vec2);
      let res3   = fold(chooseFirstIfPossible,vec3);
      let dec2   = tpl_1(res2) ? tagged Valid fromInteger(tpl_2(res2)) : 
                                 tagged Invalid;  
      let dec3   = tpl_1(res3) ? tagged Valid fromInteger(tpl_2(res3)) : 
                                 tagged Invalid;  
   
//      sRes0 <= dec0;
//      sRes1 <= dec1;
      sRes2 <= dec2;
      sRes3 <= dec3;
   endmethod
      
   method Maybe#(Bit#(TLog#(k_next))) getNext();
      return getNextW;
   endmethod

endmodule

// bram time multiplex merger
module [Module] mkBRAMOneLevelMerger#(Bit#(fifo_sz)  dntcare,
                                      function Bool  isEOS(record_t rec),      // is end of stream token?
                                      function val_t extractVal(record_t rec), // extract value from record
                                      function Module#(Scheduler#(k_next,Bit#(TLog#(TAdd#(fifo_sz,1))),next_tok_t))
                                         mkScheduler,
                                      function Module#(VLevelFIFO#(k_next,fifo_sz,record_t)) 
                                         mkBRAMVLevelFIFO)
   (SortLevel#(k, k_next, Bit#(TLog#(TAdd#(fifo_sz,1))), next_tok_t, record_t))
   provisos (Bits#(record_t,r_sz),
             Ord#(val_t),
             Bits#(val_t,val_sz),
             Div#(val_sz,2,h_val_sz),
             Mul#(8,q_val_sz,val_sz),
             Add#(h_val_sz,h_val_sz,val_sz),
             Add#(1,xxB,val_sz),
             Add#(k_next,k_next,k), // k = 2 x k_next
             Add#(xxA,TLog#(k_next),TLog#(k)),
             Bits#(next_tok_t,next_tok_sz),
             Literal#(next_tok_t));
      
   // input queues
   VLevelFIFO#(k_next,fifo_sz,record_t) inFstHalf <- mkBRAMVLevelFIFO();
   VLevelFIFO#(k_next,fifo_sz,record_t) inSndHalf <- mkBRAMVLevelFIFO();
   
   // wire storing the output value
   Wire#(Maybe#(Tuple2#(Bit#(TLog#(k_next)),record_t))) outW <- mkDWire(tagged Invalid);
   
   // wire storing whether the output has been read
   Wire#(Bool)                willDeqW <- mkDWire(False);

   Wire#(Vector#(k_next,next_tok_t)) nextTokW <- mkDWire(?);    
                                
   Wire#(Maybe#(Bit#(TLog#(k_next)))) getDeqTokW <- mkDWire(tagged Invalid);
                                                                
   FIFO#(Bit#(TLog#(k_next))) reqQ <- mkFIFO();
                               
   Scheduler#(k_next,Bit#(TLog#(TAdd#(fifo_sz,1))),next_tok_t) scheduler <- mkScheduler();

   rule feedScheduler(True);
      scheduler.putInfo(nextTokW,inFstHalf.used(),inSndHalf.used());
   endrule

   rule nextToProcess(True);
      let res = scheduler.getNext();
      let idx = fromMaybe(?,res);

      getDeqTokW <= res;
      
      // do the following read anyway...just don't get answer if the chk fail (cut critical path)
      inFstHalf.firstReq(idx);
      inSndHalf.firstReq(idx);
      
      if (isValid(res)) // scheduler said we should do the next thing
         begin
            reqQ.enq(idx);
         end
   endrule   
   
   rule compares(True);
      let in0  = inFstHalf.firstResp();
      let in1  = inSndHalf.firstResp();
      let eos0 = isEOS(in0);
      let eos1 = isEOS(in1);
      let v0   = extractVal(in0);
      let v1   = extractVal(in1);
      let cmp  = isSmaller(v0,v1);
      let idx  = reqQ.first();
      reqQ.deq();
      if (eos0)
         begin
            outW <= tagged Valid tuple2(idx,in1); // always pass in1 data
            if (eos1) 
               begin
                  inFstHalf.deq(idx);
                  inSndHalf.deq(idx);
               end
            else
               begin
                  inSndHalf.deq(idx);
               end
         end
      else
         begin
            if (eos1 || cmp)
               begin
                  outW <= tagged Valid tuple2(idx,in0);
                  inFstHalf.deq(idx);
               end
            else
               begin
                  outW <= tagged Valid tuple2(idx,in1);
                  inSndHalf.deq(idx);
               end                 
         end

      if(`SortDebug0) $display("%m EOS0 %d",eos0);
      if(`SortDebug0) $display("%m EOS1 %d",eos1);
      if(`SortDebug0) $display("%m v0 %d",v0);
      if(`SortDebug0) $display("%m v1 %d",v1);
   endrule
   
   // interface methods 
   interface InStream inStream;
      method Vector#(k,Bit#(TLog#(TAdd#(fifo_sz,1)))) getTokInfo();
         return append(inFstHalf.free(),inSndHalf.free());
      endmethod
      
      // this method is unguarded, so need to check getTokInfo before calling this
      method Action putDeqTok(Bit#(TLog#(k)) idx, Bit#(TLog#(TAdd#(fifo_sz,1))) amnt);
         let m = fromInteger(valueOf(TLog#(k))-1);
         let tidx = truncate(idx);
         if (idx[m:m] == 0)
            inFstHalf.decrFree(tidx,amnt);
         else
            inSndHalf.decrFree(tidx,amnt);
      endmethod
      
      method Action putRecord(Bit#(TLog#(k)) idx, record_t record);
         let m = fromInteger(valueOf(TLog#(k))-1);
         let tidx = truncate(idx);
         if (idx[m:m] == 0)
            inFstHalf.enq(tidx,record);
         else
            inSndHalf.enq(tidx,record);
      endmethod      
   endinterface
                                
   interface OutStream outStream;
      method Action putTokInfo (Vector#(k_next,next_tok_t) nextTok);
         nextTokW <= nextTok;
      endmethod
      
      method Tuple2#(Bit#(TLog#(k_next)),next_tok_t) getDeqTok() if (isValid(getDeqTokW));
         return tuple2(fromMaybe(?,getDeqTokW),1); 
      endmethod

      method Tuple2#(Bit#(TLog#(k_next)),record_t) getRecord() if (isValid(outW));
         return fromMaybe(?,outW);
      endmethod         
   endinterface
                                   
endmodule

// a non-bram version of a 2-to-1 merger. this one spend zero time in scheduling
module mkTwoToOneMerger#(function Bool  isEOS(record_t rec),      // is end of stream token?
                         function val_t extractVal(record_t rec)) // extract value from record
   (SortTree#(2,Bit#(2), record_t))
   provisos (Bits#(record_t,r_sz),
             Ord#(val_t),
             Bits#(val_t,val_sz),
             Add#(1,xxA,val_sz),
             Mul#(8,q_val_sz,val_sz),
             Div#(val_sz,2,h_val_sz),
             Add#(h_val_sz,h_val_sz,val_sz));
   
   // input queues
   Vector#(2,FIFOF#(record_t))              inQ      <- replicateM(mkSizedFIFOF(2));   
   FIFO#(record_t)                          outQ     <- mkSizedFIFO(2);
   
   EHRReg#(2,Vector#(2,Bit#(2)))            freeReg  <- mkEHRReg(replicate(2));

   // wire storing the output value
   Wire#(Maybe#(Tuple2#(Bit#(0),record_t))) outW     <- mkDWire(tagged Invalid);
                                                        
   Wire#(Maybe#(Bit#(1)))                   enqIdx   <- mkDWire(tagged Invalid);
   Wire#(record_t)                          enqVal   <- mkDWire(?);
   
   rule compares(True);
      let in0  = inQ[0].first();
      let in1  = inQ[1].first();
      let eos0 = isEOS(in0);
      let eos1 = isEOS(in1);
      let v0   = extractVal(in0);
      let v1   = extractVal(in1);
      let cmp  = isSmaller(v0, v1);
      Vector#(2,Bit#(2)) newFreeReg = newVector();
      newFreeReg = freeReg[1];
      if (eos0)
         begin
            outQ.enq(in1); // always pass in1 data
            if (eos1) 
               begin
                  inQ[0].deq();
                  newFreeReg[0] = newFreeReg[0] + 1;
                  inQ[1].deq();
                  newFreeReg[1] = newFreeReg[1] + 1;
               end
            else
               begin
                  inQ[1].deq();
                  newFreeReg[1] = newFreeReg[1] + 1;
               end
         end
      else
         begin
            if (eos1 || cmp)
               begin
                  outQ.enq(in0);
                  inQ[0].deq();
                  newFreeReg[0] = newFreeReg[0] + 1;
               end
            else
               begin
                  outQ.enq(in1);
                  inQ[1].deq();
                  newFreeReg[1] = newFreeReg[1] + 1;
               end                 
         end
      
      freeReg[1] <= newFreeReg;

      if(`SortDebug1) $display("%m EOS0 %d",eos0);
      if(`SortDebug1) $display("%m EOS1 %d",eos1);
      if(`SortDebug1) $display("%m v0 %d",v0);
      if(`SortDebug1) $display("%m v1 %d",v1);
      if(`SortDebug1) $display("%m compare newFreeReg0 %x, newFreeReg1 %x",newFreeReg[0],newFreeReg[1]);
   endrule
                            
   rule printState (True);
      if(`SortDebug1) $display("%m freeReg0 %d",freeReg[0][0]);
      if(`SortDebug1) $display("%m freeReg1 %d",freeReg[0][1]);
      if(`SortDebug1) $display("%m inQ0 first %d",inQ[0].first());
      if(`SortDebug1) $display("%m inQ1 first %d",inQ[1].first());
      if(`SortDebug1) $display("%m outQ first %d",outQ.first());
   endrule

   rule processPutRecord(isValid(enqIdx));
      let idx = fromMaybe(?,enqIdx);
      inQ[idx].enq(enqVal);

      if(`SortDebug1) $display("%m processPutRecord to fifo %d, record %x",idx,enqVal);
   endrule
      
   // interface methods 
   interface InStream inStream;
      method Vector#(2,Bit#(2)) getTokInfo();
         return freeReg[0];
      endmethod
      
      // this method is unguarded, so need to check getTokInfo before calling this
      method Action putDeqTok(Bit#(1) idx, Bit#(2) amnt);
         Vector#(2,Bit#(2)) newFreeReg = newVector();
         newFreeReg = freeReg[0];
         newFreeReg[idx] = newFreeReg[idx] - amnt;
         freeReg[0] <= newFreeReg;
         
         if(`SortDebug1) $display("%m putDeqTok newFreeReg0 %x, newFreeReg1 %x",newFreeReg[0],newFreeReg[1]);
      endmethod
      
      method Action putRecord(Bit#(1) idx, record_t record);
         enqIdx <= tagged Valid idx;
         enqVal <= record;
         
         if(`SortDebug1) $display("%m putRecord to fifo %d, record %x",idx,record);
      endmethod
   endinterface
                                
   method ActionValue#(record_t) getRecord();
      outQ.deq();

      if(`SortDebug1) $display("%m getRecord record %x",outQ.first());
      return outQ.first();
   endmethod         
   
endmodule

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

import DReg::*;
import FIFO::*;
import Vector::*;
import VLevelFIFO::*;
import BRAMVLevelFIFO::*;
import Memocode08Types::*;
import LFSR::*;
import FIFOF::*;
import FIFO::*;
import GetPut::*; 

typedef 2 NumberFifos; 
typedef 8 DepthFifos;

typedef enum {
  Initialize,
  Request,
  Transmit
} TesterState deriving(Bits,Eq);


(* synthesize *)
module mkVLevelFIFOInstance(VLevelFIFO#(NumberFifos,DepthFifos,Record));
   let mod <- mkBRAMVLevelFIFO();
   return mod;
endmodule

module mkVLevelFIFOTester (Empty);

  VLevelFIFO#(NumberFifos,DepthFifos,Record) fifo <- mkVLevelFIFOInstance;
  Vector#(NumberFifos,FIFOF#(Record)) expectedVals <- replicateM(mkSizedFIFOF(valueof(DepthFifos)));
  Reg#(Bit#(64)) reqsSent <- mkReg(0);
  Reg#(Bit#(64)) reqsRxed <- mkReg(0);

  rule haltAll;
   Bit#(64) timeCount <- $time;
   if(timeCount > 1010000)
     begin
       if(reqsSent == reqsRxed)
         begin
           $display("PASSED");
           $finish;
         end
       else
         begin
           $display("Expected %d values, got %d", reqsSent, reqsRxed);
         end
     end 
  endrule

 for(Integer i = 0; i < valueof(NumberFifos); i = i + 1)
   begin
     Reg#(TesterState) state <- mkReg(Initialize);
     FIFO#(Bit#(0)) reqQ <- mkFIFO;
     LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
     Reg#(Bit#(32)) counter <- mkReg(0);    
     Wire#(Bool)    isDeqW <- mkDWire(False); 


     rule countUp;
       counter <= counter + 1;
     endrule

     rule init(state == Initialize);
       state <= Request;
       lfsr.seed(fromInteger(i+1+valueof(NumberFifos)));
     endrule


     rule firstFifo((state == Request) && !isDeqW && (fifo.used[fromInteger(i)] > 0) && (counter % fromInteger(32*(i+1)) == 0));
        $display("Calling first fifo %d", i);
        fifo.firstReq(fromInteger(i));
        reqQ.enq(?);
      endrule
   
     rule deqFifo(True);
       isDeqW <= True;    
       reqQ.deq();
       expectedVals[i].deq;
       let deqData = fifo.firstResp();
       fifo.deq(fromInteger(i));
       if(deqData != zeroExtend(expectedVals[i].first))
         begin
           $display("Dequed: [%d] %h != %h",  i, expectedVals[i].first, deqData);
           $finish;
         end
       else 
         begin
           reqsRxed <= reqsRxed + 1;
           $display("Fifo %d had %d values", i, fifo.used[fromInteger(i)]);
         end
     endrule


   end


 // Send data out to the BRAM
 for(Integer i = 0; i < valueof(NumberFifos); i = i + 1)
   begin
     LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
     Reg#(TesterState) state <- mkReg(Initialize);
     Reg#(Bit#(32)) counter <- mkReg(0);    
      
     rule countUp;
       counter <= counter + 1;
     endrule

     rule init(state == Initialize);
       state <= Request;
       lfsr.seed(fromInteger(i+1+valueof(ReadPortNum)));
     endrule

     rule sendRequest((state == Request) && (counter % fromInteger(32*(i+3)) == 0) && fifo.free[fromInteger(i)] > 0);
       Bit#(64) timeCount <- $time;
       if(timeCount < 1000000)
          begin
             if (fifo.free[fromInteger(i)] > 3)
                begin
                   fifo.decrFree(fromInteger(i),4);
                end
             
             reqsSent <= reqsSent+1;
             fifo.enq(fromInteger(i),zeroExtend(lfsr.value));
             lfsr.next();
             expectedVals[i].enq(zeroExtend(lfsr.value));
          end
     endrule
  
     rule haltCheck (expectedVals[i].notEmpty);
       Bit#(64) timeCount <- $time;
       if(timeCount > 11000000)
         begin
           $display("Writer[%d] stalled out", i);
            $finish;
         end 
     endrule 
  end



endmodule


/****
 ****
 ****/
module mkVLevelFIFOTesterFull (Empty);

  VLevelFIFO#(NumberFifos,DepthFifos,Record) fifo <- mkBRAMVLevelFIFO;
  Vector#(NumberFifos,FIFOF#(Record)) expectedVals <- replicateM(mkSizedFIFOF(valueof(DepthFifos)));
  Reg#(Bit#(64)) reqsSent <- mkReg(0);
  Reg#(Bit#(64)) reqsRxed <- mkReg(0);
 


  rule haltAll;
   Bit#(64) timeCount <- $time;
   if(timeCount > 1010000)
     begin
       if(reqsSent == reqsRxed)
         begin
           $display("PASSED");
           $finish;
         end
       else
         begin
           $display("Expected %d values, got %d", reqsSent, reqsRxed);
         end
     end 
  endrule

 for(Integer i = 0; i < valueof(NumberFifos); i = i + 1)
   begin
     Reg#(TesterState) state <- mkReg(Initialize);
     FIFO#(Bit#(0)) reqQ <- mkFIFO;
     LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
     Reg#(Bit#(32)) counter <- mkReg(0);    
     Reg#(Bool) okayToReq <- mkReg(True);
     Wire#(Bool) isDeqW <- mkDWire(False); 

     rule countUp;
       counter <= counter + 1;
     endrule

     rule init(state == Initialize);
       state <= Request;
       lfsr.seed(fromInteger(i+1+valueof(NumberFifos)));
     endrule


     rule firstFifo((state == Request) && !isDeqW && (fifo.used[fromInteger(i)] > 0) && (counter % fromInteger(32*(i+1)) == 0));
//     rule firstFifo((state == Request) && okayToReq && (fifo.used[fromInteger(i)] > 0) && (counter % fromInteger(32*(i+1)) == 0));
        fifo.firstReq(fromInteger(i));
//        okayToReq <= False;
        reqQ.enq(?);
      endrule
   
     rule deqFifo(True);
//     rule deqFifo( !okayToReq && (fifo.used[fromInteger(i)] > 0));
      isDeqW <= True;
      reqQ.deq();
//      okayToReq <= True;
      expectedVals[i].deq;
      let deqData = fifo.firstResp();
      fifo.deq(fromInteger(i));
      if(deqData != zeroExtend(expectedVals[i].first))
        begin
          $display("Dequed: [%d] %h != %h",  i, expectedVals[i].first, deqData);
          $finish;
        end
      else 
        begin
          reqsRxed <= reqsRxed + 1;
          $display("Fifo %d had %d values", i, fifo.used[fromInteger(i)]);
        end
     endrule


   end


 // Send data out to the BRAM
 for(Integer i = 0; i < valueof(NumberFifos); i = i + 1)
   begin
     LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
     Reg#(TesterState) state <- mkReg(Initialize);
     Reg#(Bit#(32)) counter <- mkReg(0);    
     Reg#(Bit#(TLog#(DepthFifos))) toSendCount <- mkReg(0);    
  

     rule countUp;
       counter <= counter + 1;
     endrule

     rule init(state == Initialize);
       state <= Request;
       lfsr.seed(fromInteger(i+1+valueof(ReadPortNum)));
     endrule

     rule sendRequestStart((state == Request) && (toSendCount == 0) && (counter % fromInteger(32*(i+3)) == 0) && (fifo.free[fromInteger(i)] > 0));
       Bit#(64) timeCount <- $time;
       if(timeCount < 1000000)
         begin
           Bit#(TLog#(DepthFifos)) extras = truncate(fromInteger(i));
           toSendCount <= truncate(fromInteger(i));
           $display("Extra send rule: %d", extras);
           fifo.enq(fromInteger(i),zeroExtend(lfsr.value));
           fifo.decrFree(fromInteger(i),1);
           reqsSent <= reqsSent + 1;
           expectedVals[i].enq(zeroExtend(lfsr.value));
         end
     endrule

     rule sendRequest(toSendCount > 0);
       $display("Extra send rule");
       toSendCount <= toSendCount - 1;
       if(toSendCount - 1 == 0)
         begin
           lfsr.next();
         end
        reqsSent <= reqsSent + 1;
       expectedVals[i].enq(zeroExtend(lfsr.value));
       fifo.enq(fromInteger(i),zeroExtend(lfsr.value));
       fifo.decrFree(fromInteger(i),1);
     endrule
  
     rule haltCheck (expectedVals[i].notEmpty);
       Bit#(64) timeCount <- $time;
       if(timeCount > 11000000)
         begin
           $display("Writer[%d] stalled out", i);
            $finish;
         end 
     endrule 
  end



endmodule
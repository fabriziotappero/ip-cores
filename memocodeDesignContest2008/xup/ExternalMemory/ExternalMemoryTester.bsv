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

import ExternalMemory::*;
import Memocode08Types::*;
import Types::*;
import Interfaces::*;
import Parameters::*;
import DebugFlags::*;
import PLBMasterWires::*;
import LFSR::*;
import FIFOF::*;
import FIFO::*;
import GetPut::*;
import Vector::*;

import BRAMInitiatorWires::*;
import PLBMaster::*;
import BRAMFeeder::*;




typedef enum {
  Initialize,
  Request,
  Transmit
} TesterState deriving(Bits,Eq);

interface ExternalMemoryTester;
  interface PLBMasterWires                  plbMasterWires;
  interface BRAMInitiatorWires#(Bit#(14))   bramInitiatorWires;
endinterface



module mkExternalMemoryTester (ExternalMemoryTester);
  
  
  Feeder feeder <- mkBRAMFeeder();
  PLBMaster     plbmaster <- mkPLBMaster;
  ExternalMemory extMem <- mkExternalMemory(plbmaster);

  Vector#(ReadPortNum,FIFO#(Bit#(16))) readTargets <- replicateM(mkFIFO);

  Reg#(Bit#(28)) busCounter <-mkReg(0); // Need to lay off the bus for a bit
  Reg#(Bool) error <- mkReg(False);  

  rule countUp;
    busCounter <= busCounter + 1;
  endrule
  
  rule sendBackResp (busCounter == 0);
   if(error)
     begin
       feeder.ppcMessageInput.put(1);
     end
   error <= False;
  endrule

  for(Integer i = 0; i < valueof(ReadPortNum); i = i + 1)
   begin
     Reg#(TesterState) state <- mkReg(Initialize);
     FIFOF#(Bit#(16)) expectedVals <- mkFIFOF;
     Reg#(Bit#(TLog#(RecordsPerBlock))) transmitCount <- mkReg(0);
      

     rule init(state == Initialize);
       state <= Request;
     endrule

     rule sendRequest;
       extMem.read[i].readReq(zeroExtend(readTargets[i].first) << 4);
       readTargets[i].deq();
       expectedVals.enq(readTargets[i].first);
     endrule
  
     rule transmit;
       transmitCount <= transmitCount + 1;
       if(transmitCount + 1 == 0)
         begin
           expectedVals.deq;
         end
       Record valueTransmitted <- extMem.read[i].read;
       if(valueTransmitted != zeroExtend(expectedVals.first))
         begin
           error <= True;           
         end
     endrule

   end


 for(Integer i = 0; i < valueof(WritePortNum); i = i + 1)
   begin
     LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
     Reg#(TesterState) state <- mkReg(Initialize);
     FIFOF#(Bit#(16)) expectedVals <- mkFIFOF;
     Reg#(Bit#(TLog#(RecordsPerBlock))) transmitCount <- mkReg(0);
      

     rule init(state == Initialize);
       state <= Request;
       lfsr.seed(fromInteger(i+1+valueof(ReadPortNum)));
     endrule

     rule sendRequest (busCounter[27:25] == 0); 
           extMem.write[i].writeReq(zeroExtend(lfsr.value)<<4); // Shift over for 16 byte alignment
           lfsr.next();
           expectedVals.enq(lfsr.value);
     endrule
  
     rule transmit;
       transmitCount <= transmitCount + 1;
       if(transmitCount + 1 == 0)
         begin
           expectedVals.deq;
           readTargets[i].enq(expectedVals.first);
         end
       extMem.write[i].write(zeroExtend(expectedVals.first)); 
     endrule


 
   end


  interface plbMasterWires = plbmaster.plbMasterWires;
  interface bramInitiatorWires = feeder.bramInitiatorWires;


endmodule
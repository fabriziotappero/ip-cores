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
import PLBMasterDummy::*;

typedef enum {
  Initialize,
  Request,
  Transmit
} TesterState deriving(Bits,Eq);




module mkExternalMemoryTestbench (Empty);
  
 Reg#(Bit#(TLog#(TDiv#(TMul#(BlockSize,WordWidth),RecordWidth)))) plbMasterCount <- mkReg(0);
 FIFO#(PLBMasterCommand)              plbMasterCommand <- mkFIFO();
 FIFO#(Record)                        plbWordInput <- mkFIFO();
 FIFO#(Record)                        plbWordOutput <- mkFIFO();



 PLBMaster plbmaster;
 plbmaster = interface PLBMaster;
  interface Put wordInput;
    method Action put(Record wordInput) if(plbMasterCommand.first matches tagged StorePage .addr);
      if(zeroExtend(addr) != wordInput)
        begin         
          $display("Store Value %h != %h", addr, wordInput);
          $finish;
        end
      plbMasterCount <= plbMasterCount + 1;
      if(plbMasterCount + 1 == 0)
        begin 
          plbMasterCommand.deq;
        end
    endmethod
  endinterface
 
  interface Get wordOutput;
    method ActionValue#(Record) get() if(plbMasterCommand.first matches tagged LoadPage .addr);
      $display("PLBMaster Output");
      plbMasterCount <= plbMasterCount + 1;
      if(plbMasterCount + 1 == 0)
        begin 
          $display("plbMaster load command dequed!");
          plbMasterCommand.deq;
        end
      return zeroExtend(addr);
    endmethod
  endinterface

  interface Put plbMasterCommandInput;
    method Action put(PLBMasterCommand command);
      $display("PLB Master got a command: %s", command matches tagged LoadPage .addr?"Load":"Store");
      plbMasterCommand.enq(command);
    endmethod
  endinterface

  interface plbMasterWires = ?;
 endinterface; 

   ExternalMemory extMem <- mkExternalMemory(plbmaster);
  

  rule haltAll;
   Bit#(64) timeCount <- $time;
   if(timeCount > 1000000100)
     begin
       $display("PASSED");
       $finish;
     end 
  endrule

 for(Integer i = 0; i < valueof(ReadPortNum); i = i + 1)
   begin
     LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
     Reg#(TesterState) state <- mkReg(Initialize);
     Reg#(Bit#(32)) counter <- mkReg(0);
     FIFOF#(Bit#(16)) expectedVals <- mkFIFOF;
     Reg#(Bit#(TLog#(RecordsPerBlock))) transmitCount <- mkReg(0);
      
     rule countUp;
       counter <= counter + 1;
     endrule

     rule init(state == Initialize);
       state <= Request;
       lfsr.seed(fromInteger(i+1));
     endrule

     rule sendRequest((state == Request) && (counter % fromInteger(32*(i+1)) == 0)); 
       Bit#(64) timeCount <- $time;
       if(timeCount < 1000000000)
         begin
           extMem.read[i].readReq(zeroExtend(lfsr.value));
           lfsr.next();
           expectedVals.enq(lfsr.value);
         end
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
          $display("Load Value Reader[%d] %h != %h",  i, expectedVals.first, valueTransmitted);
          $finish;
         end
     endrule

     rule haltCheck (expectedVals.notEmpty);
       Bit#(64) timeCount <- $time;
       if(timeCount > 11000000000)
         begin
           $display("Writer[%d] stalled out", i);
            $finish;
         end 
     endrule

   end


 for(Integer i = 0; i < valueof(WritePortNum); i = i + 1)
   begin
     LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
     Reg#(TesterState) state <- mkReg(Initialize);
     Reg#(Bit#(32)) counter <- mkReg(0);
     FIFOF#(Bit#(16)) expectedVals <- mkFIFOF;
     Reg#(Bit#(TLog#(RecordsPerBlock))) transmitCount <- mkReg(0);
      
     rule countUp;
       counter <= counter + 1;
     endrule

     rule init(state == Initialize);
       state <= Request;
       lfsr.seed(fromInteger(i+1+valueof(ReadPortNum)));
     endrule

     rule sendRequest((state == Request) && (counter % fromInteger(32*(i+3)) == 0)); 
       Bit#(64) timeCount <- $time;
       if(timeCount < 1000000000)
         begin
           extMem.write[i].writeReq(zeroExtend(lfsr.value));
           lfsr.next();
           expectedVals.enq(lfsr.value);
         end
     endrule
  
     rule transmit;
       transmitCount <= transmitCount + 1;
       if(transmitCount + 1 == 0)
         begin
           expectedVals.deq;
         end
       extMem.write[i].write(zeroExtend(expectedVals.first)); 
     endrule

     rule haltCheck (expectedVals.notEmpty);
       Bit#(64) timeCount <- $time;
       if(timeCount > 11000000000)
         begin
           $display("Writer[%d] stalled out", i);
            $finish;
         end 
     endrule 
 
   end

endmodule
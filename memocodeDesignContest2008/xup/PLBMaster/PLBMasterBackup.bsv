/*
Copyright (c) 2007 MIT

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

import BRAM::*;
import BRAMInitiatorWires::*;
import GetPut::*;
import FIFO::*;
import FIFOF::*;

import Types::*;
import Interfaces::*;
import Parameters::*;
import DebugFlags::*;

import BRAMInitiator::*;
typedef 128 DataSize;

(* synthesize *)
module mkPLBMasterBackup( PLBMasterBackup );
   FIFO#(ComplexWord) wordOutfifo <- mkFIFO;
   FIFO#(ComplexWord) wordInfifo <- mkFIFO;
   FIFO#(PLBMasterCommand)  plbMasterCommandInfifo <- mkFIFO(); 


  let bufferSize = 129; // use extra space for a flag 
  let minLoadPtrA = 0;
  let maxLoadPtrA = minLoadPtrA + bufferSize;
  let minLoadPtrB = maxLoadPtrA + bufferSize;
  let maxLoadPtrB = minLoadPtrB + bufferSize;
  let minStorePtrA = maxLoadPtrB + bufferSize;
  let maxStorePtrA = minStorePtrA + bufferSize;
  let minStorePtrB = maxStorePtrA + bufferSize;
  let maxStorePtrB = minStorePtrB + bufferSize;

  let ready = True;
  
  let debugF = debug(feederDebug);
  
  Reg#(Bit#(14))  readPtr <- mkReg(minLoadPtrA); 

  Reg#(Bit#(14)) writePtr <- mkReg(minStorePtrA);
  
  Reg#(FeederState) state <- mkReg(FI_InStartCheckRead);
  
  Reg#(Bit#(32)) partialRead <- mkReg(0);   
  Reg#(Bool)     doingLoad <- mkReg(False);
  Reg#(Bool)     doingStore <- mkReg(False);
  Reg#(Bool)     loadBufferA <- mkReg(True);
  Reg#(Bool)     storeBufferA <- mkReg(True);
  Reg#(Bit#(TLog#(DataSize))) count <- mkReg(0);   
  Reg#(Bit#(TSub#(LogBlockElements,(TLog#(DataSize))))) rotations <- mkReg(0);

  BRAMInitiator#(Bit#(14)) bramInit <- mkBRAMInitiator;
  let bram = bramInit.bram;

  rule inWaitCommand(ready && state == FI_command);
      begin  
      rotations <= 0;
      case (plbMasterCommandInfifo.first()) matches
        tagged RowSize .rs: 
           begin
             plbMasterCommandInfifo.deq();
           end
        tagged LoadPage .ba:
           begin
             plbMasterCommandInfifo.deq();
             state <= FI_InStartCheckRead;
             readPtr <= 0;
             if(loadBufferA)
               begin
                 bram.read_req(minLoadPtrA);
               end
             else 
               begin
                 bram.read_req(minLoadPtrB);
               end
           end
        tagged StorePage .ba:
           begin
             plbMasterCommandInfifo.deq();
             doingStore <= True;
             state <= FI_OutStartCheckWrite;
             writePtr <= 0;
             if(storeBufferA)
               begin
                 bram.read_req(minStorePtrA);
               end
             else 
               begin
                 bram.read_req(minStorePtrB);
               end
           end
        default: $display("Illegal command for PLB Master");
      endcase
    end
  endrule
      
    
  rule inStartCheckRead(ready && state == FI_InStartCheckRead);
    debugF($display("BRAM: StartCheckRead"));
    let v <- bram.read_resp();
    if(v != 0)
      begin
        state <= FI_InStartRead;
        if(loadBufferA)
          begin
            readPtr <= 2;
            bram.read_req(minLoadPtrA + 1);
          end
        else 
          begin
            readPtr <= 2;            
            bram.read_req(minLoadPtrB + 1);
          end
      end
    else
      begin
        if(loadBufferA)
          begin
            bram.read_req(minLoadPtrA);
          end
        else 
          begin
            bram.read_req(minLoadPtrB);
          end
      end
  endrule   
  
  rule inStartRead(ready && state == FI_InStartRead);

    let v <- bram.read_resp();
    wordOutfifo.enq(unpack(v));
    readPtr <= readPtr + 1;
    count <= count + 1;
    if(count+1 ==  0)
      begin
        rotations <= rotations + 1;
        if(rotations + 1 == 0)
          begin
            state <= FI_command;
            loadBufferA <= True;
          end
        else
          begin
            loadBufferA <= !loadBufferA;
          end

        if(loadBufferA)
          begin
            bram.write(minLoadPtrA,0);            
          end
        else
          begin
            bram.write(minLoadPtrB,0);            
          end
      end
    else if(loadBufferA)
      begin
        bram.read_req(minLoadPtrA + readPtr);    
      end  
    else
      begin
        bram.read_req(minLoadPtrB + readPtr);    
      end
  
    debugF($display("BRAM: StartRead %h", v));
   
  endrule

    
  rule inStartCheckWrite(ready && state == FI_OutStartCheckWrite);
    debugF($display("BRAM: StartCheckWrite"));
    let v <- bram.read_resp();
    if(v == 0)
      begin
        state <= FI_OutStartWrite;
        writePtr <= 1;
      end
    else
      begin
        if(storeBufferA)
          begin
            bram.read_req(minStorePtrA);
          end
        else 
          begin
            bram.read_req(minStorePtrB);
          end
      end
  endrule
    
  rule inStartWrite(ready && state == FI_OutStartWrite);
    debugF($display("BRAM: StartWrite"));
     $display("BRAM: write [%d] = %h",writePtr+1, wordInfifo.first);
    writePtr <= writePtr + 1;
    count <= count + 1;
    if(count+1 ==  0)
      begin
        rotations <= rotations + 1;
        if(rotations + 1 == 0)
          begin
            state <= FI_OutStartPush;
          end
        else
          begin
            storeBufferA <= !storeBufferA;
          end      
      if(storeBufferA)
        begin
          bram.write(writePtr+minStorePtrA, truncate(pack(wordInfifo.first()))); 
        end
      else
        begin
          bram.write(writePtr+minStorePtrB, truncate(pack(wordInfifo.first()))); 
        end
      wordInfifo.deq();
    end
  endrule  

  rule inStartPush(ready && state == FI_OutStartPush);
    storeBufferA <= True;
    if(storeBufferA)
      begin
        bram.write(minStorePtrA, ~0); 
      end
    else
      begin
        bram.write(minStorePtrB, ~0); 
      end
    state <= FI_command;
  endrule 

  interface Put wordInput = interface Put;
    method Action put(x);
      wordInfifo.enq(x);
      //$display("PLB: got val %h", x);
    endmethod
  endinterface;

  interface Get wordOutput = interface Get;
	method get();
	  actionvalue
            //$display("PLB: sending val %h", wordOutfifo.first());                        
	    wordOutfifo.deq();
	    return wordOutfifo.first();
	  endactionvalue
	endmethod
      endinterface;
  interface Put plbMasterCommandInput = fifoToPut(plbMasterCommandInfifo);

  interface plbBRAMWires = bramInit.bramInitiatorWires;

endmodule


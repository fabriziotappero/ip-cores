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

import PLBMasterWires::*;
import BRAMInitiatorWires::*;
import PLBMaster::*;
import BRAMFeeder::*;
import Interfaces::*;
import Parameters::*;
import FIFO::*;
import GetPut::*;
import Types::*;
import Memocode08Types::*;
import BRAMFIFO::*;

interface BRAMFIFOTester;
  interface PLBMasterWires                  plbMasterWires;
  interface BRAMInitiatorWires#(Bit#(14))   bramInitiatorWires;
endinterface

typedef enum{
  Idle,
  Running, 
  Inputing,
  Outputing
} TesterState deriving (Bits,Eq);


module mkBRAMFIFOTester (BRAMFIFOTester);
  Feeder feeder <- mkBRAMFeeder(); 
  PLBMaster     plbMaster <- mkPLBMaster;

  Reg#(TesterState) state <- mkReg(Idle);
  Reg#(BlockAddr) baseRegLoad <- mkReg(0);
  Reg#(BlockAddr) baseRegStore <- mkReg(0);
  Reg#(Bit#(20)) commandCount <- mkReg(0);
  Reg#(Bit#(20)) maxCommands <- mkReg(0);
  FIFO#(Record) dataFIFO <- mkBRAMFIFO(8);

  rule grabInstruction(state == Idle);
    PPCMessage inst <- feeder.ppcMessageOutput.get;      
    Bit#(5) size = truncate(pack(inst));
    maxCommands <= 1 << (size); // + 1 since we need R/W -2 for 4/bursts +1 for needing two iters
    commandCount <= 0;
    baseRegLoad <= 0;
    baseRegStore <= 0;
    state <= Running;
  endrule  
  
  rule issueCommand(state == Running);
    commandCount <= commandCount + 1;
    if(commandCount + 1 == maxCommands)
      begin
        state <= Idle;
        feeder.ppcMessageInput.put(zeroExtend(pack(maxCommands)));
      end
    
    if(commandCount[1] == 0)
      begin
        baseRegLoad <= baseRegLoad + fromInteger(valueof(BlockSize)); 
        plbMaster.plbMasterCommandInput.put(tagged LoadPage (baseRegLoad));         
        
      end
    else
      begin
        baseRegStore <= baseRegStore + fromInteger(valueof(BlockSize)); 
        plbMaster.plbMasterCommandInput.put(tagged StorePage (baseRegStore));         
      end
  endrule
  
  rule inputing;
     Record data <- plbMaster.wordOutput.get;
     dataFIFO.enq(data);
  endrule 

  rule outputing;
    plbMaster.wordInput.put(dataFIFO.first);
    dataFIFO.deq;
  endrule

  interface plbMasterWires = plbMaster.plbMasterWires;
  interface bramInitiatorWires = feeder.bramInitiatorWires;  

endmodule

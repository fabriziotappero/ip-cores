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

/* This is the top-level sorter module.  It interfaces to the PLB bus, the 
   DSOCM, and the sorter core. Not much functionality, but it does have 
   a cycle timer, and sends periodic messages back to the PPC over the 
   DSOCM 
*/ 

import PLBMasterWires::*;
//import BRAMTargetWires::*;
import BRAMInitiatorWires::*;
import PLBMaster::*;
import BRAMFeeder::*;
//import BRAMModel::*;
import Interfaces::*;
import Parameters::*;
import FIFO::*;
import GetPut::*;
import Types::*;
import Memocode08Types::*;
import mkCtrl::*;
import ExternalMemory::*;
import PLBMaster::*;

interface Sorter;
  interface PLBMasterWires                  plbMasterWires;
  interface BRAMInitiatorWires#(Bit#(14))   bramInitiatorWires;


endinterface


typedef enum {
  Idle,
  Waiting,
  SendingResp
} TopState deriving (Bits,Eq);

module mkSorter#(Clock fastClock, Reset fastReset)(Sorter);
  Feeder feeder <- mkBRAMFeeder();
  PLBMaster     plbMaster <- mkPLBMaster;
  ExternalMemory extMem <- mkExternalMemory(plbMaster);
  Control  controller <- mkControl(extMem, fastClock, fastReset);
    
  Reg#(Bit#(5)) size <- mkReg(0);
  Reg#(Bit#(3)) passes <- mkReg(1);
  Reg#(TopState) state <- mkReg(Idle);
  Reg#(Bit#(31)) counter <- mkReg(0);

  rule getfinished((state == Waiting) && controller.finished);
    state <= SendingResp;
  endrule

  rule countUp(state != Idle);
    counter <= counter + 1;
  endrule

  rule sendCommand(controller.finished && (state == Idle));
    PPCMessage inst <- feeder.ppcMessageOutput.get;          
    controller.doSort(truncate(pack(inst)));
    size <= truncate(pack(inst));
    state <= Waiting;
    counter <= 0;
    passes <= 1;
  endrule

  rule returnPass;
    let msg <- controller.msgs.get;
    passes <= passes + 1;
    //feeder.ppcMessageInput.put(zeroExtend(32'hC000|msg));
  endrule  

 
  rule returnResp(state == SendingResp);
    state <= Idle;
    feeder.ppcMessageInput.put(zeroExtend(counter));
  endrule

  interface plbMasterWires = plbMaster.plbMasterWires;
  interface bramInitiatorWires = feeder.bramInitiatorWires;  
	
endmodule
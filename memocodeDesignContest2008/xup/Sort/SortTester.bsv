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
import FIFOF::*;
import BRAMFIFO::*;
import GetPut::*;
import Types::*;
import Memocode08Types::*;
import Sort::*;
import SortTree64::*;
import Vector::*;

interface SortTester;
  interface PLBMasterWires                  plbMasterWires;
  interface BRAMInitiatorWires#(Bit#(14))   bramInitiatorWires;
endinterface

typedef enum{
  Idle,
  Running, 
  Inputing,
  Outputing
} TesterState deriving (Bits,Eq);


module mkSortTester (SortTester);
   Feeder            feeder       <- mkBRAMFeeder(); 
   PLBMaster         plbMaster    <- mkPLBMaster;
   
   Reg#(TesterState)      state        <- mkReg(Idle);
   Reg#(BlockAddr)        baseRegStore <- mkRegU();
   Reg#(Bit#(64))         timer        <- mkRegU();
   Reg#(Bit#(20))         resCount     <- mkRegU();
   Reg#(Bit#(20))         writeCount   <- mkRegU();
   Reg#(Bool)             eos          <- mkRegU();
   FIFO#(Bit#(20))        resQ         <- mkFIFO();
   FIFOF#(Maybe#(Record)) writeQ       <- mkSizedFIFOF(8);
   let                    sortTree     <- mkSortTree64();
   let                    tok_info      = sortTree.inStream.getTokInfo();

   rule grab_instruction(state == Idle);
      PPCMessage inst <- feeder.ppcMessageOutput.get;      
      Bit#(5) size  = truncate(pack(inst));
      baseRegStore <= 0;
      timer        <= 0;
      resCount     <= (1<<size)<<1;
      writeCount   <= 1<<size; // half res are for eos
      state        <= Running;
      eos          <= False;
   endrule  
   
   rule read_reserve (state == Running &&
                      resCount > 0 &&
                      tok_info[resCount[5:0]] > 0);
      resQ.enq(resCount);
      resCount <= resCount - 1;
   endrule   
      
   rule read_request (True);
      Bit#(20) val = resQ.first();
      Bit#(6)  idx = truncate(val);
      resQ.deq();
      sortTree.inStream.putDeqTok(idx,1);
      if (idx == 1)
         eos <= !eos;
      
      if (!eos) // enq data
         sortTree.inStream.putRecord(idx,tagged Valid zeroExtend({val[19:7],val[5:0]}));
      else // eos
         sortTree.inStream.putRecord(idx,tagged Invalid);      
   endrule

   rule sync_out_stream (state == Running);
      Vector#(1,Bit#(5)) tok = replicate(zeroExtend(pack(writeQ.notFull())));
      sortTree.outStream.putTokInfo(tok);
   endrule
   
   rule drain_sorter_finish (True);
      match {.*,.data} = sortTree.outStream.getRecord();
      writeQ.enq(data);
   endrule
   
   rule write_to_mem (True);
      writeQ.deq();
      if (isValid(writeQ.first()))
         begin
            let data = fromMaybe(?,writeQ.first());
            writeCount <= writeCount - 1;
            plbMaster.wordInput.put(data);            
            if (writeCount[1:0] == 1)
               begin
                  baseRegStore <= baseRegStore + fromInteger(valueof(BlockSize)); 
                  plbMaster.plbMasterCommandInput.put(tagged StorePage (baseRegStore));         
               end
         end
   endrule
   
   rule incrTimer (state == Running);
      timer <= timer + 1;
   endrule
   
   rule finishSort(state == Running && resCount == 0 && writeCount == 0);
      state <= Idle;
      feeder.ppcMessageInput.put(truncate(timer));
   endrule
   
   rule heart_beat(state == Running && timer[19:0] == 1000000);
      feeder.ppcMessageInput.put(0);
   endrule

   interface plbMasterWires = plbMaster.plbMasterWires;
   interface bramInitiatorWires = feeder.bramInitiatorWires;  

endmodule

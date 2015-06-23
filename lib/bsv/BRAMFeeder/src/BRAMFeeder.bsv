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

Author: Michael Pellauer, Nirav Dave
*/

import BRAM::*;
import BRAMInitiatorWires::*;
import GetPut::*;
import FIFO::*;
import FIFOF::*;
//import Types::*;
//import Interfaces::*;
import Debug::*;

import BRAMInitiator::*;

//A message to the PPC
typedef Bit#(32) PPCMessage;


typedef enum{
  FI_Initialize,
  FI_InIdle,	     
  FI_InStartCheckRead,
  FI_InStartRead,
  FI_InStartTake,
  FI_OutStartCheckWrite,
  FI_OutStartWrite,
  FI_OutStartPush,
  FI_CheckLoadStore,
  FI_Load,
  FI_LoadTake,
  FI_Store,
  FI_StorePush,
  FI_command
} FeederState deriving(Eq,Bits);     


interface Feeder;

  interface Put#(PPCMessage) ppcMessageInput;
  interface Get#(PPCMessage) ppcMessageOutput;
  interface BRAMInitiatorWires#(Bit#(14))  bramInitiatorWires;

endinterface

Bool feederDebug = False;

(* synthesize *)
module mkBRAMFeeder(Feeder);

  // Data is held in 2 addr blocks. as
  // Addr n : 1---------22222  <- 1 valid bit (otherwise all zero) 
  //                              2 top bits of payload
  //    n+1 : 333333333333333  <- 3 rest of payload                     
 
  //State

  BRAMInitiator#(Bit#(14)) bramInit <- mkBRAMInitiator;
  let bram = bramInit.bram;
  
  //BRAM#(Bit#(16), Bit#(32)) bram <- mkBRAM_Full();
  
  FIFOF#(PPCMessage)  ppcMesgQ <- mkFIFOF();
  FIFOF#(PPCMessage) ppcInstQ <- mkFIFOF();
  
  let minReadPtr  =   0;
  let maxReadPtr  =  31;
  let minWritePtr =  32;
  let maxWritePtr =  63;

  let ready = True;
  
  let debugF = debug(feederDebug);
  
  Reg#(Bit#(14))  readPtr <- mkReg(minReadPtr); 

  Reg#(Bit#(14)) writePtr <- mkReg(minWritePtr);
  
  Reg#(FeederState) state <- mkReg(FI_InStartCheckRead);
  
  Reg#(Bit#(32)) partialRead <- mkReg(0);
    
  Reg#(Bit#(30)) heartbeat <- mkReg(0);
  
  //Every so often send a message to the PPC indicating we're still alive
  
  rule beat (True);
    
    let newheart = heartbeat + 1;
    
    heartbeat <= newheart;
    
    if (newheart == 0)
      ppcMesgQ.enq(0);
  
  endrule
  
  ///////////////////////////////////////////////////////////
  //Initialize
  ///////////////////////////////////////////////////////////

  //Reg#(Maybe#(Bit#(14))) initReg <- mkReg(Just(0));
    
  //Bool ready = !isJust(initReg);
   
  //rule initBRAM(initReg matches tagged Just .i);
  //  $display("Init");
  //  bram.write(i, 0);
  //  initReg <= (i == maxWritePtr) ? Nothing : Just (i + 1);
  //endrule 
  
  ///////////////////////////////////////////////////////////  
  // In goes to FPGA, Out goes back to PPC
  ///////////////////////////////////////////////////////////
  
  let state_tryread = (ppcInstQ.notFull ? FI_InStartCheckRead: FI_InIdle);
  let state_trywrite = (ppcMesgQ.notEmpty) ? FI_OutStartCheckWrite : FI_InIdle;

  rule inStartIdle(ready && state == FI_InIdle);
    if(state_tryread == FI_InIdle)
      begin
        state <= state_trywrite;
      end
    else
      begin
        state <= state_tryread;
      end
  endrule
  

  rule inStartCheckRead(ready && state == FI_InStartCheckRead);
    debugF($display("BRAM: StartCheckRead"));
    bram.read_req(readPtr);
    state <= FI_InStartRead;
  endrule   
  
  rule inStartRead(ready && state == FI_InStartRead);

    let v <- bram.read_resp();
    Bool valid = (v[31] == 1);
    state <= (valid) ? FI_InStartTake : state_trywrite;

    debugF($display("BRAM: StartRead %h", v));
    if (valid)
      begin
	//$display("BRAM: read fstinst [%d] = %h",readPtr, v);
	partialRead <= v;
	bram.read_req(readPtr+1); //
      end
  endrule

  rule inStartTake(ready && state == FI_InStartTake);
    debugF($display("BRAM: StartTake"));
    let val <- bram.read_resp();

    Bit#(63) pack_i = truncate({partialRead,val});

    PPCMessage i = unpack(truncate(pack_i));//truncate({partialRead,val}));
    
    ppcInstQ.enq(i);
//    $display("BRAM: read sndinst [%d] = %h",readPtr+1, val);
//    $display("BRAM: got PPCMessage %h",pack_i);
//    $display("Getting Inst: %h %h => %h",partialRead, val, {partialRead,val});
    bram.write(readPtr, 0);
    readPtr <= (readPtr + 2 > maxReadPtr) ? minReadPtr : (readPtr + 2);
    state <= state_trywrite;
  endrule    
    
  rule inStartCheckWrite(ready && state == FI_OutStartCheckWrite);
    debugF($display("BRAM: StartCheckWrite"));
    bram.read_req(writePtr);
    state <= FI_OutStartWrite;
  endrule
    
  rule inStartWrite(ready && state == FI_OutStartWrite);
    debugF($display("BRAM: StartWrite"));
    let v <- bram.read_resp();
    Bool valid = (v[31] == 0);
    state <= (valid) ? FI_OutStartPush : state_tryread;
    if (valid) begin
      $display("BRAM: write [%d] = %h",writePtr+1, ppcMesgQ.first);
      bram.write(writePtr+1, ppcMesgQ.first()); 
      ppcMesgQ.deq();
    end
  endrule  

  rule inStartPush(ready && state == FI_OutStartPush);
    debugF($display("BRAM: StartPush"));
      $display("BRAM: write [%d] = %h",writePtr, 32'hFFFFFFFF);
    bram.write(writePtr, 32'hFFFFFFFF);//all 1s
    writePtr <= (writePtr + 2 > maxWritePtr) ? minWritePtr : (writePtr + 2);
    state <= state_tryread;
  endrule 

  //Interface  
  
  interface ppcMessageInput      = fifoToPut(fifofToFifo(ppcMesgQ));
  interface ppcMessageOutput = fifoToGet(fifofToFifo(ppcInstQ));
  
  interface bramInitiatorWires = bramInit.bramInitiatorWires;
   
endmodule


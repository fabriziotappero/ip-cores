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

// Global Imports
import GetPut::*;
import FIFO::*;
import RegFile::*;
import BRAMInitiatorWires::*;
import RegFile::*;
import FIFOF::*;

import BRAM::*;
// Project Imports
import Types::*;
import Interfaces::*;
import Parameters::*;
import DebugFlags::*;

import BRAMInitiator::*;
import PLBMasterWires::*;
import StmtFSM::*;

(* synthesize *)
module mkPLB_backupPPC(BRAMInitiatorWires#(Bit#(14)));
 
  RegFile#(Bit#(20), Bit#(32))  matrixA <- mkRegFileFullLoad("matrixA.hex");
  RegFile#(Bit#(20), Bit#(32))  matrixB <- mkRegFileFullLoad("matrixB.hex");
  RegFile#(Bit#(20), Bit#(32))  matrixC <- mkRegFileFull();  
  RegFile#(Bit#(20), Bit#(32))  scratch <- mkRegFileFull();
  RegFile#(Bit#(20), Bit#(32))  golden  <- mkRegFileFullLoad("golden.hex"); 

  Reg#(Bit#(32))      goldenElementCounter <- mkReg(0); 

  RegFile#(Bit#(16), Bit#(64))     prog <- mkRegFileFullLoad("program.hex");
  Reg#(Bit#(16))               prog_idx <- mkReg(0);

  
  //State

  BRAMInitiator#(Bit#(14)) bramInit <- mkBRAMInitiator;
  let bram = bramInit.bram;
  
  //BRAM#(Bit#(14), Bit#(32))   bram <- mkBRAM_Full();
  
  FIFOF#(Bit#(32))             outQ <- mkFIFOF();
  FIFO#(Bit#(32))               inQ <- mkFIFO();
  FIFO#(Bit#(64))          commandQ <- mkFIFO();
  Reg#(Bit#(30))           baseAddr <- mkRegU;

  let minWritePtr  =   0;
  let maxWritePtr  =  129*2-1;

  let minReadPtr   =  129*2;
  let maxReadPtr   =  129*4-1;

  let burstSize    =  128;

  Reg#(Bit#(14))    readPtr <- mkReg(minReadPtr); 
  Reg#(Bit#(14))   writePtr <- mkReg(minWritePtr);
  



  let incWritePtr  = (writePtr == maxWritePtr) ? minWritePtr : (writePtr + 1);
  let incReadPtr   = (readPtr == maxReadPtr) ? minReadPtr : (readPtr + 1);
  
  let ready = True;
  let debugF = debug(False);
  


  Reg#(Bit#(10))      count <- mkReg(0);
  
  Reg#(Bit#(32))      value <- mkReg(0);
  
  Reg#(Bit#(64)) totalTicks <- mkReg(0);
  Reg#(Bit#(32))  rowOffset <- mkReg(0);  // stored in terms of words
  
  
  function Action readAddr(addr);
    case (addr[21:20]) 
      2'b00:  return (matrixA.sub(addr[19:0]));  
      2'b01:  return (matrixB.sub(addr[19:0]));
      2'b10:  return (matrixC.sub(addr[19:0]));
      2'b11:  return (scratch.sub(addr[19:0]));
    endcase
  endfunction
  
  function Action writeAddr(addr,val);
    action
      case (addr[21:20])
	2'b00:  begin
		  debugF($display("PLB: writing to matA %h",addr[19:0]));
		  matrixA.upd(addr[19:0],val);
		end
	2'b01:  begin
		  debugF($display("PLB: writing to matB %h",addr[19:0]));
		  matrixB.upd(addr[19:0],val);
		end
	2'b10:  begin
		  debugF($display("PLB: writing to matC %h",addr[19:0]));
		  matrixC.upd(addr[19:0],val);
		  let oldval    = matrixC.sub(addr[19:0]);
		  let goldenval = golden.sub(addr[19:0]);
		  
		if ((goldenval != oldval) && (goldenval == val)) // a new correct val
		  begin
                    goldenElementCounter <= goldenElementCounter +1;
                    if (truncate(goldenElementCounter) == 16'hFFFF) // time to announce
		      $display("Correct Value Count: %d @ %d", goldenElementCounter+1,totalTicks);
		    if (goldenElementCounter + 1 ==   (rowOffset * rowOffset))
		      begin
			$display("PASSED @ %d", totalTicks);
			$finish;
		      end
		  end
	      end
      2'b11:  begin
		debugF($display("PLB: writing to scratch %h",addr[19:0]));
		scratch.upd(addr[19:0],val);
	      end
      endcase
    endaction
  endfunction

  
  ///////////////////////////////////////////////////////////  
  // In goes to MEM, Out goes back to FPGA
  ///////////////////////////////////////////////////////////

  Stmt doReadStmt =
    seq
      bram.read_req(readPtr);
      action
        let v <- bram.read_resp();
	value <= v;
	count <= 0;
      endaction    
      if (value != 0)
	seq
	  while(count < burstSize)
	    seq
	      action
		readPtr <= incReadPtr;
		count <= count + 1;
		let v <- bram.read_resp();
                writeAddr(baseAddr+zeroExtend(count), v);
		if (count <burstSize) 
		  bram.read_req(readPtr+1); //
		if (count == burstSize)
		  bram.write(readPtr - burstSize, 0); // take
	      endaction
	    endseq
	endseq
  endseq;
  
  FSM doRead <- mkFSM(doReadStmt); 
  
  Stmt doWriteStmt =
    seq
      bram.read_req(writePtr);
      action
        let v <- bram.read_resp();
	value <= v;
	count <= 0;
      endaction    
      if (value == 0)
	seq
	  while(count < burstSize)
	    seq
	      action
		writePtr <= incWritePtr;
		count <= count + 1;
		if (count <burstSize) 
		  begin
		    let val = readAddr(baseAddr+zeroExtend(count));
		    bram.write(writePtr+1, val); //
		  end
		if (count == burstSize)
		  bram.write(writePtr - burstSize, 32'hFFFFFFFF); // take
	      endaction
	    endseq
	endseq
      commandQ.deq();
    endseq;
  
  FSM doWrite <- mkFSM(doWriteStmt); 
  
  rule doStuff(doRead.done && doWrite.done);
    let inst = unpack(truncate(commandQ.first));
    
    let mload  = translateLoad(inst);
    let mstore = translateStore(inst);
    let mrow   = translateRowSize(inst);
    
    commandQ.deq();
    
    if (isJust(mload))
      begin
	baseAddr <= unJust(mload);
	doRead.start();
      end
    else if (isJust(mstore))
      begin
	baseAddr <= unJust(mstore);
	doWrite.start();	
      end
    else if (isJust(mrow))
      begin
	rowOffset <= zeroExtend(unJust(mrow));
      end
  endrule
  
  rule tick(True);
    totalTicks <= totalTicks +1;
  endrule

  rule doProgRead(prog.sub(prog_idx) != 64'hAAAA_AAAA_AAAA_AAAA);
    let x = prog.sub(prog_idx);
    commandQ.enq(x);
    prog_idx <= prog_idx + 1;
  endrule

  return (bramInit.bramInitiatorWires);
endmodule


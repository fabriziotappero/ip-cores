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

// Project Imports
`include "Common.bsv"

import PLBMasterWires::*;
 

typedef enum
{
  Test,
  Sleep,
  Finish
} TestState
    deriving(Bits, Eq);

(* synthesize *)
module mkPLBMasterMagic (PLBMaster);

  // state for the actual magic memory hardware
  FIFO#(ComplexWord)       wordInfifo <- mkFIFO();
  FIFO#(ComplexWord)       wordOutfifo <- mkFIFO();
  FIFO#(PLBMasterCommand)  plbMasterCommandInfifo <- mkFIFO(); 

  RegFile#(Bit#(20), ComplexWord)  matrixA <- mkRegFileFullLoad("matrixA.hex");
  RegFile#(Bit#(20), ComplexWord)  matrixB <- mkRegFileFullLoad("matrixB.hex");
  RegFile#(Bit#(20), ComplexWord)  matrixC <- mkRegFileFull();  
  RegFile#(Bit#(20), ComplexWord)  scratch <- mkRegFileFull();

  Reg#(Bit#(LogBlockElements)) elementCounter <- mkReg(0);
  Reg#(Bit#(LogBlockSize))     rowCounter <- mkReg(0);  // 0 -> blocksize
  Reg#(Bit#(LogRowSize))       rowOffset <- mkReg(0);   
  Reg#(BlockAddr)             addressOffset <- mkReg(0);       
  

  // State for running the golden test loop
  RegFile#(Bit#(20), ComplexWord)  golden  <- mkRegFileFullLoad("golden.hex"); 
  Reg#(Bit#(32))                   goldenElementCounter <- mkReg(0); 
  Reg#(Bit#(64))                   totalTicks <- mkReg(0);

  rule tick(True);
    totalTicks <= totalTicks +1;
  endrule

  rule rowSize(plbMasterCommandInfifo.first() matches tagged RowSize .rs);   
    debug(plbMasterDebug, $display("PLBMaster: processing RowSize command %d", rs));
    rowOffset <= rs;
    plbMasterCommandInfifo.deq();
  endrule
                          
  rule loadPage(plbMasterCommandInfifo.first() matches tagged LoadPage .ba);
    elementCounter <= elementCounter + 1;
    if(elementCounter == 0)
      begin
        debug(plbMasterDebug, $display("PLBMaster: processing LoadPage command"));
      end
    if(elementCounter + 1 == 0)
       begin
         debug(plbMasterDebug, $display("PLBMaster: finished LoadPage command"));
	 addressOffset <= 0;
	 rowCounter    <= 0;
         plbMasterCommandInfifo.deq();
       end  
    else if(rowCounter + 1 == 0)
      begin //When we get to the end of a row, we need to reset by
	    //shifting the Address Offset to 1 row higher =
	rowCounter <= 0;
        addressOffset <= addressOffset + 1 - unpack(fromInteger(1*valueof(BlockSize))) + (1 << rowOffset);
      end
    else
      begin
        addressOffset <= addressOffset + 1;
        rowCounter <= rowCounter + 1;
      end
                             
     BlockAddr addr = ba + addressOffset;
     // Now that we're done with calculating the address,
     // we can case out our memory space
     //case (addr[23:22]) 
     //  2'b00:  begin $display("PLB: reading matA[%h] => %h"   ,addr[21:2], matrixA.sub(addr[21:2])); end
     //  2'b01:  begin $display("PLB: reading matB[%h] => %h"   ,addr[21:2], matrixB.sub(addr[21:2])); end
     //  2'b10:  begin $display("PLB: reading matC[%h] => %h"   ,addr[21:2], matrixC.sub(addr[21:2])); end
     //  2'b11:  begin $display("PLB: reading scratch[%h] => %h",addr[21:2], scratch.sub(addr[21:2])); end
     //endcase

     case (addr[21:20]) 
       2'b00:  wordOutfifo.enq(matrixA.sub(addr[19:0]));  
       2'b01:  wordOutfifo.enq(matrixB.sub(addr[19:0]));
       2'b10:  wordOutfifo.enq(matrixC.sub(addr[19:0]));
       2'b11:  wordOutfifo.enq(scratch.sub(addr[19:0]));
     endcase

  endrule
  
  rule storePage(plbMasterCommandInfifo.first() matches tagged StorePage .ba);
    elementCounter <= elementCounter + 1;
    if(elementCounter == 0)
      begin
        debug(plbMasterDebug, $display("PLBMaster: processing StorePage command"));
      end
    if(elementCounter + 1 == 0)
      begin
        debug(plbMasterDebug, $display("PLBMaster: finished StorePage command"));
        addressOffset <= 0;
	rowCounter    <= 0;
        plbMasterCommandInfifo.deq();
      end  
    else if(rowCounter + 1 == 0)
      begin 
        addressOffset <= addressOffset + 1 - unpack(fromInteger(valueof(BlockSize))) + (1 << rowOffset);
        rowCounter <= 0;
      end
    else
      begin
        addressOffset <= addressOffset + 1;
	rowCounter <= rowCounter + 1;
      end
                            
    BlockAddr addr = ba + addressOffset;
    // Now that we're done with calculating the address,
    // we can case out our memory space
    case (addr[21:20])
      2'b00:  begin
		debug(plbMasterDebug,$display("PLB: writing to matA %h",addr[19:0]));
		matrixA.upd(addr[19:0],wordInfifo.first());
	      end
      2'b01:  begin
		debug(plbMasterDebug,$display("PLB: writing to matB %h",addr[19:0]));
		matrixB.upd(addr[19:0],wordInfifo.first());
	      end
      2'b10:  begin
		debug(plbMasterDebug,$display("PLB: writing to matC %h",addr[19:0]));
		matrixC.upd(addr[19:0],wordInfifo.first());
		let oldval    = matrixC.sub(addr[19:0]);
		let goldenval = golden.sub(addr[19:0]);
		
		if ((goldenval != oldval) && (goldenval == wordInfifo.first())) // a new correct val
		  begin
                    goldenElementCounter <= goldenElementCounter +1;
                    if (truncate(goldenElementCounter) == 16'hFFFF) // time to announce
		      $display("Correct Value Count: %d @ %d", goldenElementCounter+1,totalTicks);
		    if (goldenElementCounter + 1 ==  (1 << (rowOffset<<1)))
		      begin
			$display("PASSED @ %d", totalTicks);
			$finish;
		      end
		  end
	      end
      2'b11:  begin
		debug(plbMasterDebug,$display("PLB: writing to scratch %h",addr[19:0]));
		scratch.upd(addr[19:0],wordInfifo.first());
	      end
    endcase
    wordInfifo.deq();
  endrule

  rule debugRule (True);
    case (plbMasterCommandInfifo.first()) matches
        tagged LoadPage .i: noAction;
        tagged StorePage .i: noAction;
        tagged RowSize .sz: noAction;
        default:
          $display("PLBMaster: illegal command: %h", plbMasterCommandInfifo.first());
    endcase

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
  interface PLBMasterWires  plbMasterWires = ?; 
endmodule


// The MIT License

// Copyright (c) 2006-2007 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//**********************************************************************
// Frame Buffer
//----------------------------------------------------------------------
//
//
//

package mkFrameBuffer;

import H264Types::*;
import IFrameBuffer::*;
import RegFile::*;
import GetPut::*;
import ClientServer::*;
import FIFO::*;
import FIFOF::*;
import mkRoundRobinMemScheduler::*;
import mkSRAMMemController::*;
import IMemClient::*;
import IMemController::*;
import IMemScheduler::*;
import ISRAMWires::*;
import IVgaController::*;
import SRAM::*;
import BlueSRAM::*;
import BlueBRAM::*;

//-----------------------------------------------------------
// Register file module
//-----------------------------------------------------------

interface FBRFile;
   method Action store( Bit#(FrameBufferSz) addr, Bit#(32) data );
   method Bit#(32) load( Bit#(FrameBufferSz) addr );
endinterface

/*module mkFBRFile( FBRFile );

   RegFile#(Bit#(FrameBufferSz),Bit#(32)) rfile <- mkRegFile(0,frameBufferSize);
   
   method Action store( Bit#(FrameBufferSz) addr, Bit#(32) data );
      rfile.upd( addr, data );
   endmethod
   
   method Bit#(32) load( Bit#(FrameBufferSz) addr );  
      return rfile.sub(addr);
   endmethod
   
endmodule*/


//----------------------------------------------------------------------
// Main module
//----------------------------------------------------------------------

module mkFrameBuffer( IFrameBuffer );

  //-----------------------------------------------------------
  // State

   FIFOF#(FrameBufferLoadReq)  loadReqQ  <- mkFIFOF();
   FIFOF#(FrameBufferLoadResp) loadRespQ <- mkFIFOF();
   FIFOF#(FrameBufferStoreReq) storeReqQ  <- mkFIFOF();

   BlueSRAM#(Bit#(18), Bit#(32)) sram <- mkBlueSRAM_Full();    
   BlueBRAM#(Bit#(18), Bit#(32)) bram <- mkBlueBRAM_Full();

   Reg#(Bit#(4)) outstandingReqs <- mkReg(0);  // We make the true assumption that the memory controller
                                               // only supports 2 outstanding requests per client.
  
   rule read_request ( loadReqQ.first() matches tagged FBLoadReq .addrt );
      if(addrt<frameBufferSize)
	 begin
            bram.read_req(truncate(unpack(addrt)));
	    loadReqQ.deq();
            outstandingReqs <= outstandingReqs + 1;
            $display("FBuff req , addr: %h, outstanding reqs: %d", addrt, outstandingReqs + 1); 
	 end
      else
	 $display( "ERROR FrameBuffer: loading outside range" );
   endrule

   rule read_response;
     Bit#(32) resp_data <- bram.read_resp();
     loadRespQ.enq(FBLoadResp (resp_data));
     outstandingReqs <= outstandingReqs - 1;
     $display("FBuff resp , data: %h  outstanding reqs: %d", resp_data, outstandingReqs - 1);
   endrule
   
   rule storing ( storeReqQ.first() matches tagged FBStoreReq { addr:.addrt,data:.datat} );
      if(addrt<frameBufferSize)
	 begin
	    bram.write(addrt,datat);
	    storeReqQ.deq();
            $display("FBuff, write req addr: %h data: %h", addrt, datat );
	 end
      else
	 $display( "ERROR FrameBuffer: storing outside range" );
   endrule
   
   rule store_full(outstandingReqs > 0); 
     $display("FBuff: StoreQ.notfull(): %b .notempty(): %b",storeReqQ.notFull(),storeReqQ.notEmpty());  
     $display("FBuff: LoadRespQ.notfull(): %b .notempty(): %b",loadRespQ.notFull(),loadRespQ.notEmpty());
     $display("FBuff: LoadReqQ.notfull(): %b .notempty(): %b",loadReqQ.notFull(),loadReqQ.notEmpty());
   endrule

   rule syncing ( loadReqQ.first() matches tagged FBEndFrameSync &&& storeReqQ.first() matches tagged FBEndFrameSync);
    //if(outstandingReqs == 0)
    //  begin
        loadReqQ.deq();
        storeReqQ.deq();
    //  end
   endrule

   
   interface Server server_load;
      interface Put request   = fifoToPut(fifofToFifo(loadReqQ));
      interface Get response  = fifoToGet(fifofToFifo(loadRespQ));
   endinterface
   interface Put server_store = fifoToPut(fifofToFifo(storeReqQ));
 
  interface ISRAMWires sram_controller;
    method Bit#(18) address_out();
      return sram.address_out();       
    endmethod

    method Bit#(32) data_O();
      return sram.data_out();
    endmethod

    method Action data_I(Bit#(32) data);
      sram.data_in(data);
    endmethod

    method Bit#(1) data_T();
      return sram.data_tri();
    endmethod

    method Bit#(4) we_bytes_out();
      return sram.we_bytes_out();
    endmethod

    method Bit#(1) we_out();
      return sram.we_out();
    endmethod

    method Bit#(1) ce_out();
      return sram.ce_out();
    endmethod

    method Bit#(1) oe_out();
      return sram.oe_out();
    endmethod

    method Bit#(1) cen_out();
      return sram.cen_out();
    endmethod

    method Bit#(1) adv_ld_out();
      return sram.adv_ld_out();
    endmethod
  endinterface   

endmodule

endpackage

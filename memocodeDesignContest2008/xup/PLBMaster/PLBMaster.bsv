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

/* This file implements a PLB bus master.  The bus master operates on static 
   sized bursts.  It is written in such a way that read/write bursts may be 
   overlapped, if the bus and target slave support such a feature. There's also
   support for pipelining of read and write requests.  The master is 
   parameterized by BeatsPerBurst (burst length) and BusWord (bus width), 
   which allow it to be used for various applications.   
*/

// Global Imports
import GetPut::*;
import FIFO::*;
import RegFile::*;
import BRAMInitiatorWires::*;
import RegFile::*;
import FIFOF::*;
import Vector::*;

import Types::*;
import Interfaces::*;
import Parameters::*;
import DebugFlags::*;
 
import PLBMasterWires::*;
import Memocode08Types::*;
 
typedef enum {   
  Idle,
  Data,
  WaitForBusy
} StateTransfer 
    deriving(Bits, Eq);
  
typedef enum {   
  Idle,
  RequestingLoad,
  RequestingStore
} StateRequest 
    deriving(Bits, Eq);

(* synthesize *)
module mkPLBMaster (PLBMaster);
  Clock plbClock <- exposeCurrentClock();
  Reset plbReset <- exposeCurrentReset();
  // state for the actual magic memory hardware
  FIFO#(Record)            recordInfifo <- mkFIFO;
  FIFO#(Record)            recordOutfifo <- mkFIFO;
  FIFO#(PLBMasterCommand)  plbMasterCommandInfifo <- mkFIFO(); 

  
  // Output buffer
  RegFile#(Bit#(TAdd#(1,TLog#(BeatsPerBurst))),BusWord)                            storeBuffer <- mkRegFileFull();   

  
  // Input buffer
  RegFile#(Bit#(TAdd#(1,TLog#(BeatsPerBurst))),BusWord)                            loadBuffer <- mkRegFileFull();   

  
  Reg#(Bit#(24))                              rowAddrOffsetLoad <- mkReg(0);
  Reg#(Bit#(24))                              rowAddrOffsetStore <- mkReg(0);  

  Reg#(Bool)                                doingLoad <- mkReg(False);
  Reg#(Bool)                                doingStore <- mkReg(False);

  Bit#(TLog#(TMul#(BeatsPerBurst, WordsPerBeat))) zeroOffset = 0; // Words per Burst
  Reg#(Bool)                                requestingStore <- mkReg(False);
  BlockAddr addressOffset                   = zeroExtend({(requestingStore)?rowAddrOffsetStore:rowAddrOffsetLoad,zeroOffset});
  

  Reg#(StateRequest)                        stateRequest <- mkReg(Idle);
  Reg#(StateTransfer)                       stateLoad <- mkReg(Idle); 
  Reg#(StateTransfer)                       stateStore <- mkReg(Idle); 
  Reg#(Bit#(1))                             request <- mkReg(0);
  Reg#(Bit#(1))                             rnw <- mkReg(0);


  Reg#(Bit#(TLog#(BeatsPerBurst)))              loadDataCount <- mkReg(0);
  Reg#(Bit#(TLog#(BeatsPerBurst)))              storeDataCount <-mkReg(0);// If you change this examine mWrDBus_o
  Reg#(Bit#(TAdd#(1,TLog#(BeatsPerBurst))))      loadDataCount_plus2 <- mkReg(2);
  Reg#(Bit#(TAdd#(1,TLog#(BeatsPerBurst))))      storeDataCount_plus2 <-mkReg(2);  
  
  Reg#(Bool)                                doAckinIdle <- mkReg(False);

  Reg#(Bit#(1))                             rdBurst <- mkReg(0);
  Reg#(Bit#(1))                             wrBurst <- mkReg(0);

  Reg#(Bit#(1))                             storeCounter <- mkReg(0);
  Reg#(Bit#(1))                             loadCounter <- mkReg(0);              

  Reg#(Bit#(TAdd#(1,TLog#(BeatsPerBurst)))) storeBufferWritePointer <- mkReg(0);
  FIFOF#(Bit#(0))                           storeValid <- mkUGFIFOF;//XXX: This could be bad
  Reg#(Bit#(TAdd#(1,TLog#(BeatsPerBurst)))) loadBufferReadPointer <- mkReg(0);
  FIFOF#(Bit#(0))                           loadValid <- mkUGFIFOF;//XXX: This could be bad  


  // Input wires  
  Wire#(Bit#(1)) mRst <- mkBypassWire();
  Wire#(Bit#(1)) mAddrAck <- mkBypassWire();	
  Wire#(Bit#(1)) mBusy <- mkBypassWire(); 	
  Wire#(Bit#(1)) mErr <- mkBypassWire();		
  Wire#(Bit#(1)) mRdBTerm <- mkBypassWire(); 	
  Wire#(Bit#(1)) mRdDAck <- mkBypassWire();
  Wire#(Bit#(64))mRdDBus <- mkBypassWire(); 
  Wire#(Bit#(3)) mRdWdAddr <- mkBypassWire(); 	
  Wire#(Bit#(1)) mRearbitrate <- mkBypassWire(); 
  Wire#(Bit#(1)) mWrBTerm <- mkBypassWire(); 	
  Wire#(Bit#(1)) mWrDAck <- mkBypassWire(); 	
  Wire#(Bit#(1)) mSSize <- mkBypassWire(); 	
  Wire#(Bit#(1)) sMErr <- mkBypassWire(); // on a read, during the data ack		
  Wire#(Bit#(1)) sMBusy <- mkBypassWire();

  //  Outputs


  Bit#(PLBAddrSize) mABus_o = {addressOffset,2'b00}; // Our address Address Bus, we extend to compensate for word 

  
  Bit#(TAdd#(1,TLog#(BeatsPerBurst))) sbuf_addr = {storeCounter,storeDataCount};
  
 
  Bit#(64)mWrDBus_o   = storeBuffer.sub(sbuf_addr);
  Bit#(1) mRequest_o  = request & ~mRst; // Request
  Bit#(1) mBusLock_o  = 1'b0 & ~mRst; // Bus lock
  Bit#(1) mRdBurst_o  = rdBurst & ~mRst; // read burst 
  Bit#(1) mWrBurst_o  = wrBurst & ~mRst; // write burst
  Bit#(1) mRNW_o      = rnw; // Read Not Write
  Bit#(1) mAbort_o    = 1'b0; // Abort
  Bit#(2) mPriority_o = 2'b11;// priority indicator
  Bit#(1) mCompress_o = 1'b0;// compressed transfer
  Bit#(1) mGuarded_o  = 1'b0;// guarded transfer
  Bit#(1) mOrdered_o  = 1'b0;// synchronize transfer
  Bit#(1) mLockErr_o  = 1'b0;// lock erro
  Bit#(4) mSize_o     = 4'b1011; // Burst double word transfer - see PLB p.24
  Bit#(3) mType_o     = 3'b000; // Memory Transfer
  Bit#(8) mBE_o       = 8'b00001111; // 16 word burst
  Bit#(2) mMSize_o    = 2'b00;


  // precompute the next address offset.  Sometimes
  
  
  PLBMasterCommand cmd_in_first = plbMasterCommandInfifo.first();

  let newloadDataCount  =  loadDataCount + 1;
  let newstoreDataCount = storeDataCount + 1;
  let newloadDataCount_plus2  =  loadDataCount_plus2 + 1;
  let newstoreDataCount_plus2 = storeDataCount_plus2 + 1;

  
  rule startPageLoad(cmd_in_first matches tagged LoadPage .ba &&& !doingLoad);
        $display("Start Page");
        plbMasterCommandInfifo.deq();
        $display("Load Page");
        rowAddrOffsetLoad   <= truncate(ba>>(valueof(TLog#(TMul#(BeatsPerBurst, WordsPerBeat))))); // this is the log 
        if (ba[3:0] != 0)
	  $display("ERROR:Address not 64-byte aligned");
        doingLoad <= True;
  endrule

  rule startPageStore(cmd_in_first matches tagged StorePage .ba &&& !doingStore);
    $display("Start Page");
    plbMasterCommandInfifo.deq();
    $display("Store Page");
    rowAddrOffsetStore <= truncate(ba>>(valueof(TLog#(TMul#(BeatsPerBurst, WordsPerBeat))))); // this is the log 
                                                                                             // size of burst addr
    if (ba[3:0] != 0)
      $display("ERROR:Address not 64-byte aligned");
    doingStore <= True;	
  endrule


  rule loadPage_Idle(doingLoad && stateRequest == Idle && stateLoad == Idle);
    // We should not initiate a transfer if the wordOutfifo is not valid
    //$display("loadPage_Idle");  
    requestingStore <= False;
    if(loadValid.notFull())// Check for a spot.       
      begin  
	request <= 1'b1;
	stateRequest <= RequestingLoad;
      end
    else
      begin
	request <= 1'b0;  // Not Sure this is needed
      end 

    rnw <= 1'b1; // We're reading
  endrule


  
  rule loadPage_Requesting(doingLoad && stateRequest == RequestingLoad && stateLoad == Idle);
    // We've just requested the bus and are waiting for an ack
    //$display("loadPage_Requesting");
    if(mAddrAck == 1 )
      begin
        stateRequest <= Idle;
	// Check for error conditions  
	if(mRearbitrate == 1) 
	  begin
	    // Got terminated by the bus
	    $display("Terminated by BUS @ %d",$time);
	    stateLoad <= Idle;
	    rdBurst <= 1'b0; // if we're rearbing this should be off. It may be off anyway? 
	    request <= 1'b0;
	  end 
        else
	  begin
	    //Whew! didn't die yet.. wait for acks to come back
	    stateLoad <= Data;
	    // Not permissible to assert burst until after addrAck p. 35
	    rdBurst <= 1'b1;
	    // Set down request, as we are not request pipelining
	    request <= 1'b0;
	  end
      end
  endrule    

  rule loadPage_Data(doingLoad && stateLoad == Data);
    if(((mRdBTerm == 1) && (loadDataCount_plus2 < (fromInteger(valueof(BeatsPerBurst))))) || (mErr == 1))
      begin
	// We got terminated / Errored 
	rdBurst <= 1'b0;
	loadDataCount <= 0;
 	loadDataCount_plus2 <= 2;   	
	stateLoad <= Idle;             
      end
    else if(mRdDAck == 1)
      begin
	loadDataCount <= newloadDataCount;
        loadDataCount_plus2 <= newloadDataCount_plus2;
        loadBuffer.upd({loadCounter,loadDataCount}, mRdDBus);                   
	if(newloadDataCount == 0)
	  begin
            loadCounter <= loadCounter + 1; // Flip the loadCounter
	    //We're now done reading... what should we do?
            loadValid.enq(0);  // This signifies that the data is valid Nirav could probably remove this
	    doingLoad <= False;
            stateLoad <= Idle;
	  end
	else if(newloadDataCount == maxBound) // YYY: ndave used to ~0
	  begin
	    // Last read is upcoming.  Need to set down the 
	    // rdBurst signal.
	    rdBurst <= 1'b0;
	  end
      end
  endrule



  rule storePage_Idle(doingStore && stateRequest == Idle && stateStore == Idle);
    requestingStore <= True;
    if(storeValid.notEmpty())
      begin
	request <= 1'b1;
	stateRequest <= RequestingStore;
      end
    else
      begin
	request <= 1'b0;
      end
   
    wrBurst <= 1'b1; // Write burst is asserted with the write request
    rnw <= 1'b0; // We're writing
  endrule
  
  rule storePage_Requesting(doingStore && stateRequest == RequestingStore && stateStore == Idle);
    // We've just requested the bus and are waiting for an ack
    if(mAddrAck == 1 )
      begin
        stateRequest <= Idle; 
	// Check for error conditions
	if(mRearbitrate == 1)
	  begin
	    // Got terminated by the bus
	    wrBurst <= 1'b0;
	    request <= 1'b0;
	  end
        else
	  begin
	    // Set down request, as we are not request pipelining
	    request <= 1'b0;
	    // We can be WrDAck'ed at this time p.29 or WrBTerm p.30 
	    if(mWrBTerm == 1)
	      begin  
		wrBurst <= 1'b0;
	      end
            else if(mWrDAck == 1)
	      begin
		storeDataCount <= newstoreDataCount;
    		storeDataCount_plus2 <= newstoreDataCount_plus2;
		stateStore <= Data;
	      end
            else
	      begin
		stateStore <= Data;
	      end                             
	  end
      end
  endrule


  rule storePage_Data(doingStore && stateStore == Data);
    if((mWrBTerm == 1) && (storeDataCount_plus2 < (fromInteger(valueof(BeatsPerBurst)))) || (mErr == 1))
      begin
	// We got terminated / Errored 
	wrBurst <= 1'b0;
	storeDataCount <= 0;
        storeDataCount_plus2 <= 2;
	stateStore <= Idle; // Can't burst for a cycle p. 30             
      end
    else if(mWrDAck == 1)
      begin
	storeDataCount <= newstoreDataCount;                   
	storeDataCount_plus2 <= newstoreDataCount_plus2;
	if(newstoreDataCount == 0)
	  begin
	    //We're now done reading... what should we do?
	    // Data transfer complete
            if(mBusy == 0) 
              begin
                doingStore <= False;
                stateStore <= Idle;
                storeValid.deq();
                storeCounter <= storeCounter + 1;
              end
            else
              begin
                stateStore <= WaitForBusy;
              end
	  end
	else if(newstoreDataCount == maxBound) //YYY: used to be ~0
	  begin
	    // Last read is upcoming.  Need to set down the 
	    // wrBurst signal.
	    wrBurst <= 1'b0;
	  end
      end
  endrule

  rule storePage_WaitForBusy(doingStore && stateStore == WaitForBusy);
    if(mErr == 1)
      begin
	// We got terminated / Errored 
	wrBurst <= 1'b0;
	storeDataCount <= 0; // may not be necessary
        storeDataCount_plus2 <= 2; 
	stateStore <= Idle; // Can't burst for a cycle p. 30             
      end    
    else if(mBusy == 0)
      begin
        storeCounter <= storeCounter + 1;
        doingStore <= False;
        stateStore <= Idle;
        storeValid.deq();
      end
  endrule

  /********
  /* Code For Handling Record Translation
  /*******/

  Reg#(Bit#(DoubleWordWidth)) recordSled <- mkReg(0);




  rule writeStoreData(storeValid.notFull());
    storeBufferWritePointer <= storeBufferWritePointer + 1;
     
    case(storeBufferWritePointer[0]) 
      0: storeBuffer.upd(storeBufferWritePointer, {recordInfifo.first[31:0] ,recordInfifo.first[63:32]});
      1: storeBuffer.upd(storeBufferWritePointer, {recordInfifo.first[95:64],recordInfifo.first[127:96]});
    endcase

    if((storeBufferWritePointer + 1)[0] == 0)
      begin
        recordInfifo.deq;
      end

    Bit#(TLog#(BeatsPerBurst)) bottomValue = 0;
    if(truncate(storeBufferWritePointer + 1) == bottomValue)
      begin
        $display("Store Data finished a flight");
        storeValid.enq(0);
      end
  endrule


  rule wordToRecord(loadValid.notEmpty());
    loadBufferReadPointer <= loadBufferReadPointer + 1;
    Bit#(64) loadValue = loadBuffer.sub(loadBufferReadPointer);
    Bit#(32) loadHigh = loadValue [63:32];
    Bit#(32) loadLow = loadValue [31:0];
    Bit#(TLog#(BeatsPerBurst)) bottomValue = 0;
    if(truncate(loadBufferReadPointer + 1) == bottomValue)
      begin
        $display("Load Data finished a flight");
        loadValid.deq();
      end

    if((loadBufferReadPointer + 1)[0] == 0)
      begin
        recordOutfifo.enq({{loadLow,loadHigh},recordSled});
      end
    else       
      begin
        recordSled <= {loadLow,loadHigh};
      end
  endrule

  interface Put wordInput = fifoToPut(recordInfifo);

  interface Get wordOutput = fifoToGet(recordOutfifo);

  interface Put plbMasterCommandInput = fifoToPut(plbMasterCommandInfifo);


  interface PLBMasterWires  plbMasterWires;
 
    method Bit#(PLBAddrSize) mABus();     // Address Bus
      return mABus_o;   
    endmethod
    method Bit#(8)           mBE();       // Byte Enable
      return mBE_o;    
    endmethod
	
    method Bit#(1)           mRNW();      // Read Not Write
      return mRNW_o;    
    endmethod

    method Bit#(1)           mAbort();    // Abort
      return mAbort_o;    
    endmethod

    method Bit#(1)           mBusLock();  // Bus lock
      return mBusLock_o;    
    endmethod

    method Bit#(1)           mCompress(); // compressed transfer
      return mCompress_o;    
    endmethod

    method Bit#(1)           mGuarded();  // guarded transfer
      return mGuarded_o;    
    endmethod

    method Bit#(1)           mLockErr();  // lock error
      return mLockErr_o;    
    endmethod

    method Bit#(2)           mMSize();    // data bus width?
      return mMSize_o;    
    endmethod

    method Bit#(1)           mOrdered();  // synchronize transfer
      return mOrdered_o;    
    endmethod

    method Bit#(2)           mPriority(); // priority indicator
      return mPriority_o;    
    endmethod

    method Bit#(1)           mRdBurst();  // read burst
      return mRdBurst_o;    
    endmethod

    method Bit#(1)           mRequest();  // bus request
      return mRequest_o;    
    endmethod
	
    method Bit#(4)           mSize();     // transfer size 
      return mSize_o;    
    endmethod

    method Bit#(3)           mType();     // transfer type (dma) 
      return mType_o;    
    endmethod

    method Bit#(1)           mWrBurst();  // write burst
      return mWrBurst_o;    
    endmethod
	
    method Bit#(64)          mWrDBus();   // write data bus
      return mWrDBus_o;    
    endmethod

    method Action plbIN(
      Bit#(1) mRst_in,            // PLB reset
      Bit#(1) mAddrAck_in,	       // Addr Ack
      Bit#(1) mBusy_in,           // Master Busy
      Bit#(1) mErr_in,            // Slave Error
      Bit#(1) mRdBTerm_in,	       // Read burst terminate signal
      Bit#(1) mRdDAck_in,	       // Read data ack
      Bit#(64)mRdDBus_in,	       // Read data bus
      Bit#(3) mRdWdAddr_in,       // Read word address
      Bit#(1) mRearbitrate_in,    // Rearbitrate
      Bit#(1) mWrBTerm_in,	       // Write burst terminate
      Bit#(1) mWrDAck_in,	       // Write data ack
      Bit#(1) mSSize_in, 	       // Slave bus size
      Bit#(1) sMErr_in,	       // Slave error
      Bit#(1) sMBusy_in);	       // Slave busy       
      mRst <= mRst_in;       
      mAddrAck <= mAddrAck_in;	
      mBusy <= mBusy_in;		
      mErr <= mErr_in;		
      mRdBTerm <= mRdBTerm_in;	
      mRdDAck <= mRdDAck_in;	
      mRdDBus <= mRdDBus_in;	
      mRdWdAddr <= mRdWdAddr_in;	
      mRearbitrate <= mRearbitrate_in;
      mWrBTerm <= mWrBTerm_in;	
      mWrDAck <= mWrDAck_in;	
      mSSize <= mSSize_in; 	
      sMErr <= sMErr_in;		
      sMBusy <= sMBusy_in;	
    endmethod
   endinterface
endmodule

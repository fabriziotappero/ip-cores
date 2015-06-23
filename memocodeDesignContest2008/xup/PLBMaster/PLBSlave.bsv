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

// Project Imports
`include "Common.bsv"

import PLBMasterWires::*;

import RegFile::*;


interface PLBSlave;
  interface PLBMasterWires plb;
endinterface  
  

module mkPLBSlave#(PLBMastWires plb) ();

  RegFile#(Bit#(PLBAddrSize), Bit#(32)) rf <- mkRegFileFull();
  Reg#(Bit#(PLBAddrSize)) curAddr <- mkReg(0);
  Reg#(Bit#(8)) transferSize      <- mkReg(0);
 
  Reg#(Bit#(32)) wrValue          <- mkReg(0);

  Reg#(Bool) doingRead            <- mkReg(False);
  Reg#(Bool) doingWrite           <- mkReg(False);

  Reg#(Maybe#(Bit#(32))) readValue <- mkReg(Nothing);
 
  Bit#(PLBAddrSize) mABus     = plb.mABus();     // Address Bus
  Bit#(8)           mBE       = plb.mBE();       // Byte Enable
  Bool           mRNW      = plb.mRNW() == 1;      // Read Not Write
  //Bit#(1)           mAbort    = plb.mAbort();    // Abort
  Bit#(1)           mBusLock  = plb.mBusLock();  // Bus lock
  //Bit#(1)           mCompress = plb.mCompress(); // compressed transfer
  //Bit#(1)           mGuarded  = plb.mGuarded();  // guarded transfer
  //Bit#(1)           mLockErr  = plb.mLockErr();  // lock error
  Bit#(2)           mMSize    = plb.mMSize();    // data bus width?
  Bit#(1)           mOrdered  = plb.mOrdered();  // synchronize transfer
  //Bit#(2)           mPriority = plb.mPriority(); // priority indicator
  Bool           mRdBurst  = plb.mRdBurst() == 1;  // read burst
  Bool           mRequest  = plb.mRequest() == 1;  // bus request
  Bit#(4)           mSize     = plb.mSize();     // transfer size 
  //Bit#(3)           mType     = plb.mType();     // transfer type (dma) 
  Bool           mWrBurst  = plb.mWrBurst() == 1;  // write burst
  Bit#(32)          mWrDBus   = plb.mWrDBus();   // write data bus
  

  rule doMagic(True);
    Bit#(1)  plb_mRst          = 0; // PLB reset
    Bit#(1)  plb_mAddrAck      = 0; // Addr Ack                      //*
    Bit#(1)  plb_mBusy         = 0; // Master Busy
    Bit#(1)  plb_mErr          = 0; // Slave Error
    Bit#(1)  plb_mRdBTerm      = 0; // Read burst terminate signal
    Bit#(1)  plb_mRdDAck       = 1; // Read data ack
    Bit#(32) plb_mRdDBus       = 32'hdeadbeef; // Read data bus
    Bit#(3)  plb_mRdWdAddr     = 0; // Read word address
    Bit#(1)  plb_mRearbitrate  = 0; // Rearbitrate
    Bit#(1)  plb_mWrBTerm      = 0; // Write burst terminate
    Bit#(1)  plb_mWrDAck       = 1; // Write data ack                //*
    Bit#(1)  plb_mSSize        = 0; // Slave bus size
    Bit#(1)  plb_sMErr         = 0; // Slave error
    Bit#(1)  plb_sMBusy        = 0; 
   
    //Get Request
    Bool newRead   =  mRequest && mRNW && mRdBurst && !mWrBurst;
    Bool newWrite  =  mRequest && !mRNW && !mRdBurst && mWrBurst;

    Bool error_Request = mRequest && !(newRead || newWrite);

    if (error_Request)
      $display("ERROR: poorly formatted request");
    
    plb_mAddrAck = pack(newRead || newWrite);  

    plb_mWrDAck =  pack(newWrite || doingWrite); 

    Bool error_wrBurst_dropped_early = (transferSize > 1) && doingWrite && !mWrBurst;
     
    if (error_wrBurst_dropped_early)
      $display("ERROR: wrBurst dropped early");    
    
    if (newRead) 
      transferSize <= mBE + 1;
    else if (newWrite)
      transferSize <= mBE;
    else if (doingRead || doingWrite)
      transferSize <= transferSize - 1; 
    
    if (newRead || newWrite)
      curAddr <= mABus;
    else
      curAddr <= curAddr + 1;
    
    if (newWrite)
      rf.upd(mABus, mWrDBus);
    else if (doingWrite)
      rf.upd(curAddr + 1, mWrDBus);

    if(doingRead)
      readValue <= Just(rf.sub(curAddr));
    else
      readValue <= Nothing;
    
    plb_mRdDBus = case(readValue) matches
		    tagged Nothing: return 32'hdeadbeef;
		    tagged Just .x: return x;
		  endcase;

    
    if (transferSize > 0)
      transferSize <= transferSize - 1;

    if (transferSize == 1)
      doingRead <= False;
    if (transferSize == 1)
      doingWrite <= False;

    if(transferSize == 2 && (doingRead || newRead)) // penultimate read
      begin
	plb_mRdBTerm = 1; // Read burst terminate signal
      end
	
    if(transferSize == 2 && (doingWrite || newWrite))
      plb_mWrBTerm = 1;
      
    //wrComp and rdComp don't exist?     
    
    plb.plbIN(
      plb_mRst,        
      plb_mAddrAck,    
      plb_mBusy,       
      plb_mErr,        
      plb_mRdBTerm,    
      plb_mRdDAck,     
      plb_mRdDBus,     
      plb_mRdWdAddr,    
      plb_mRearbitrate, 
      plb_mWrBTerm,
      plb_mWrDAck, 
      plb_mSSize,  
      plb_sMErr,
      plb_sMBusy
      );

  endrule













endmodule
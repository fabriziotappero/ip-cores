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

import Types::*;
import Parameters::*;
import Interfaces::*;
import DebugFlags::*;
import PLBMasterWires::*;
import RegFile::*;

module mkPLBModel#(PLBMasterWires plb) ();

  RegFile#(Bit#(20), Bit#(32))  matrixA <- mkRegFileFullLoad("invert.hex");
  RegFile#(Bit#(20), Bit#(32))  matrixB <- mkRegFileFull();
  RegFile#(Bit#(20), Bit#(32))  matrixC <- mkRegFileFull();  
  RegFile#(Bit#(20), Bit#(32))  scratch <- mkRegFileFull();

  Reg#(Bit#(PLBAddrSize)) curAddr <- mkReg(0);
  Reg#(Bit#(8)) transferSize      <- mkReg(0);
 
  Reg#(Bit#(32)) wrValue          <- mkReg(0);

  Reg#(Bool) doingRead            <- mkReg(False);
  Reg#(Bool) doingWrite           <- mkReg(False);

  Reg#(Maybe#(Bit#(64))) readValue <- mkReg(Nothing);
 
  Reg#(Bit#(PLBAddrSize)) mABus     <- mkReg(0);
  Reg#(Bit#(8))           mBE       <- mkReg(0);
  Reg#(Bool)              mRNW      <- mkReg(False);
  Reg#(Bit#(1))           mAbort    <- mkReg(0);
  Reg#(Bit#(1))           mBusLock  <- mkReg(0);
  Reg#(Bit#(1))           mCompress <- mkReg(0);
  Reg#(Bit#(1))           mGuarded  <- mkReg(0);
  Reg#(Bit#(1))           mLockErr  <- mkReg(0);
  Reg#(Bit#(2))           mMSize    <- mkReg(0);
  Reg#(Bit#(1))           mOrdered  <- mkReg(0);
  Reg#(Bit#(2))           mPriority <- mkReg(0);
  Reg#(Bool)              mRdBurst  <- mkReg(False);
  Reg#(Bool)              mRequest  <- mkReg(False);
  Reg#(Bit#(4))           mSize     <- mkReg(0);
  Reg#(Bit#(3))           mType     <- mkReg(0);
  Reg#(Bool)              mWrBurst  <- mkReg(False);
  Reg#(Bit#(64))          mWrDBus   <- mkReg(0);
  

  // State for running the golden test loop
  Reg#(Bit#(32))                   goldenElementCounter <- mkReg(0); 
  Reg#(Bit#(64))                   totalTicks <- mkReg(0);
  
   
  rule latch(True);
    mABus     <= plb.mABus();     // Address Bus  
    mBE       <= plb.mBE();       // Byte Enable
    mRNW      <= plb.mRNW() == 1;      // Read Not Write
    mAbort    <= plb.mAbort();    // Abort
    mBusLock  <= plb.mBusLock();  // Bus lock
    mCompress <= plb.mCompress(); // compressed transfer
    mGuarded  <= plb.mGuarded();  // guarded transfer
    mLockErr  <= plb.mLockErr();  // lock error
    mMSize    <= plb.mMSize();    // data bus width?
    mOrdered  <= plb.mOrdered();  // synchronize transfer
    mPriority <= plb.mPriority(); // priority 
    mRdBurst  <= plb.mRdBurst() == 1;  // read burst
    mRequest  <= plb.mRequest() == 1;  // bus request
    mSize     <= plb.mSize();     // transfer size 
    mType     <= plb.mType();     // transfer type (dma) 
    mWrBurst  <= plb.mWrBurst() == 1;  // write burst
    mWrDBus   <= plb.mWrDBus();   // write data bus
  endrule  

  rule doMagic(True);
    Bit#(1)  plb_mRst          = 0; // PLB reset
    Bit#(1)  plb_mAddrAck      = 0; // Addr Ack                      //*
    Bit#(1)  plb_mBusy         = 0; // Master Busy
    Bit#(1)  plb_mErr          = 0; // Slave Error
    Bit#(1)  plb_mRdBTerm      = 0; // Read burst terminate signal
    Bit#(1)  plb_mRdDAck       = 0; // Read data ack
    Bit#(64) plb_mRdDBus       = 64'hcafefeeddeadbeef; // Read data bus
    Bit#(3)  plb_mRdWdAddr     = 0; // Read word address
    Bit#(1)  plb_mRearbitrate  = 0; // Rearbitrate
    Bit#(1)  plb_mWrBTerm      = 0; // Write burst terminate
    Bit#(1)  plb_mWrDAck       = 0; // Write data ack                //*
    Bit#(1)  plb_mSSize        = 0; // Slave bus size
    Bit#(1)  plb_sMErr         = 0; // Slave error
    Bit#(1)  plb_sMBusy        = 0; 
  
    //Terminating Previous Request
    //
    // Technically, it's "correct" for a burst of 1/2
    // We're ignoring this
    
    if(transferSize == 1 && doingRead) // penultimate read
      begin
	plb_mRdBTerm = 1; // Read burst terminate signal
      end
	
    if(transferSize == 1 && doingWrite)
      plb_mWrBTerm = 1;    

    
    //Determine if there's a new request
    
    // new read if mReq + mRNW + we've at just terminated or aren't working
    Bool newRead = mRequest &&  mRNW && (!doingRead || (plb_mRdBTerm ==1));
    // new write if mReq + !mRNW + we've at hust terminated or aren't working
    
    Bool newWrite = mRequest && !mRNW && (!doingWrite || (plb_mWrBTerm ==1));
    
    ///////////////////////////////////////////////////////////////////
    //
    // Read access logic. One cycle Delay
    //
    ///////////////////////////////////////////////////////////////////
    
    //Get Request
    //Bool newRead   =  !doingRead  && mRequest &&  mRNW && !mWrBurst;
    //Bool newWrite  =  !doingWrite && mRequest && !mRNW && mWrBurst;

    plb_mAddrAck = pack(newRead || newWrite);  

    plb_mWrDAck =  pack(newWrite || doingWrite); 

   
    Bool error_wrBurst_dropped_early = (transferSize > 1) && doingWrite && !mWrBurst;
     
    if (error_wrBurst_dropped_early)
      $display("ERROR: wrBurst dropped early");    
    

    if (newRead) 
      transferSize <= mBE + 1;
    else if (newWrite)
      transferSize <= mBE +1;
    else if ((doingRead || doingWrite) && (transferSize > 0))
      transferSize <= transferSize - 1; 
    
    if (newRead || newWrite)
      curAddr <= mABus;
    else
      curAddr <= curAddr + 4;
    
    if (doingWrite)
      begin
	let wAddr = newWrite ? mABus : curAddr;//(curAddr + 4);
        let wData = (wAddr[2] == 0) ? mWrDBus[63:32]:mWrDBus[31:0];
	case (wAddr[23:22])
          2'b00:  begin
	            debug(plbMasterDebug,$display("PLB: writing to matA %h",wAddr[21:2]));
                    debug(plbMasterDebug,$display("PLB: got %h expected %h",wData, ~matrixA.sub( wAddr[21:2])));
                    if(wData != ~matrixA.sub( wAddr[21:2]))
                      begin
                        $finish;
                      end
		    matrixA.upd(wAddr[21:2],wData);
	          end
          2'b01:  begin
		    debug(plbMasterDebug,$display("PLB: writing to matB %h",wAddr[21:2]));
		    $finish;
	          end
          2'b10:  begin
		    debug(plbMasterDebug,$display("PLB: writing to matC %h %h",wAddr[21:2],goldenElementCounter));
                    $finish;
		  end
	  
	  2'b11:  begin
	            debug(plbMasterDebug,$display("PLB: writing to scratch %h",wAddr[21:2]));
		    $finish;
	          end    
	endcase
      end
    
    if(doingRead)
     case (curAddr[23:22]) 
       2'b00:  readValue <= Just({matrixA.sub({curAddr[21:3],1}),(matrixA.sub({curAddr[21:3],0}))});  
       2'b01:  readValue <= Just({matrixB.sub({curAddr[21:3],1}),(matrixB.sub({curAddr[21:3],0}))});
       2'b10:  readValue <= Just({matrixC.sub({curAddr[21:3],1}),(matrixC.sub({curAddr[21:3],0}))}); 
       2'b11:  readValue <= Just({matrixC.sub({curAddr[21:3],1}),(matrixC.sub({curAddr[21:3],0}))});  
     endcase
    else
      readValue <= Nothing;
    
    plb_mRdDBus = case(readValue) matches
		    tagged Nothing: return 64'hfeedcafedeadbeef;
		    tagged Just .x: return x;
		  endcase;
    
    plb_mRdDAck = isJust(readValue) ? 1 : 0;
    
    if (newRead)
      doingRead <= True;
    else if (transferSize == 1)
      doingRead <= False;

    if (newWrite)
      doingWrite <= True;
    else if (transferSize == 1)
      doingWrite <= False;
    
/*    
    if(transferSize == 1 && (doingRead || newRead)) // penultimate read
      begin
	plb_mRdBTerm = 1; // Read burst terminate signal
      end
	
    if(transferSize == 1 && (doingWrite || newWrite))
      plb_mWrBTerm = 1;
*/      
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

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

// Project Imports
import Parameters::*;

`define PLB_CLK_NAME        "mClk"
`define PLB_RST_NAME        "mRst"
`define PLB_COMPRESS_NAME   "mCompress"
`define PLB_ABUS_NAME       "mABus"
`define PLB_BE_NAME         "mBE"
`define PLB_RNW_NAME        "mRNW"
`define PLB_ABORT_NAME      "mAbort"
`define PLB_BUSLOCK_NAME    "mBusLock"
`define PLB_PRESS_NAME      "mpress"
`define PLB_GUARDED_NAME    "mGuarded"
`define PLB_LOCKERR_NAME    "mLockErr"
`define PLB_MSIZE_NAME      "mMSize"
`define PLB_ORDERED_NAME    "mOrdered"
`define PLB_PRIORITY_NAME   "mPriority"
`define PLB_RDBURST_NAME    "mRdBurst"
`define PLB_REQUEST_NAME    "mRequest"
`define PLB_SIZE_NAME       "mSize"
`define PLB_TYPE_NAME       "mType"
`define PLB_WRBURST_NAME    "mWrBurst"
`define PLB_WRDBUS_NAME     "mWrDBus"
`define PLB_MADDRACK_NAME  "mAddrAck"
`define PLB_MBUSY_NAME     "mBusy"
`define PLB_MERR_NAME      "mErr"
`define PLB_MRDBTERM_NAME  "mRdBTerm"
`define PLB_MRDDACK_NAME   "mRdDAck"
`define PLB_MRDDBUS_NAME   "mRdDBus"
`define PLB_MRDWDADDR_NAME  "mRdWdAddr"
`define PLB_MREARBITRATE_NAME  "mRearbitrate"
`define PLB_MWRBTERM_NAME  "mWrBTerm"
`define PLB_MWRDACK_NAME   "mWrDAck"
`define PLB_MSSIZE_NAME    "mSSize"
`define PLB_SMERR_NAME     "sMErr"
`define PLB_SMBUSY_NAME    "sMBusy"


interface PLBMasterWires;

  (* always_ready, prefix="", result=`PLB_ABUS_NAME *)
  method Bit#(PLBAddrSize) mABus();     // Address Bus

  (* always_ready, prefix="", result=`PLB_BE_NAME *)
  method Bit#(8)           mBE();       // Byte Enable

  (* always_ready, prefix="", result=`PLB_RNW_NAME *)
  method Bit#(1)           mRNW();      // Read Not Write

  (* always_ready, prefix="", result=`PLB_ABORT_NAME *)
  method Bit#(1)           mAbort();    // Abort

  (* always_ready, prefix="", result=`PLB_BUSLOCK_NAME *)
  method Bit#(1)           mBusLock();  // Bus lock

  (* always_ready, prefix="", result=`PLB_COMPRESS_NAME *)
  method Bit#(1)           mCompress(); // compressed transfer

  (* always_ready, prefix="", result=`PLB_GUARDED_NAME *)
  method Bit#(1)           mGuarded();  // guarded transfer

  (* always_ready, prefix="", result=`PLB_LOCKERR_NAME *)
  method Bit#(1)           mLockErr();  // lock error

  (* always_ready, prefix="", result=`PLB_MSIZE_NAME *)
  method Bit#(2)           mMSize();    // data bus width?

  (* always_ready, prefix="", result=`PLB_ORDERED_NAME *)
  method Bit#(1)           mOrdered();  // synchronize transfer

  (* always_ready, prefix="", result=`PLB_PRIORITY_NAME *)
  method Bit#(2)           mPriority(); // priority indicator

  (* always_ready, prefix="", result=`PLB_RDBURST_NAME *)
  method Bit#(1)           mRdBurst();  // read burst

  (* always_ready, prefix="", result=`PLB_REQUEST_NAME *)
  method Bit#(1)           mRequest();  // bus request

  (* always_ready, prefix="", result=`PLB_SIZE_NAME *)
  method Bit#(4)           mSize();     // transfer size 

  (* always_ready, prefix="", result=`PLB_TYPE_NAME *)
  method Bit#(3)           mType();     // transfer type (dma) 

  (* always_ready, prefix="", result=`PLB_WRBURST_NAME *)
  method Bit#(1)           mWrBurst();  // write burst

  (* always_ready, prefix="", result=`PLB_WRDBUS_NAME *)
  method Bit#(64)          mWrDBus();   // write data bus

  (* always_ready, prefix="", always_enabled *)
  method Action plbIN(
    (* port=`PLB_RST_NAME *)            Bit#(1) mRst,           // PLB reset
    (* port=`PLB_MADDRACK_NAME *)       Bit#(1) mAddrAck,       // Addr Ack
    (* port=`PLB_MBUSY_NAME *)          Bit#(1) mBusy,          // Master Busy
    (* port=`PLB_MERR_NAME *)           Bit#(1) mErr,           // Slave Error
    (* port=`PLB_MRDBTERM_NAME *)       Bit#(1) mRdBTerm,       // Read burst terminate signal
    (* port=`PLB_MRDDACK_NAME *)        Bit#(1) mRdDAck,        // Read data ack
    (* port=`PLB_MRDDBUS_NAME *)        Bit#(64)mRdDBus,        // Read data bus
    (* port=`PLB_MRDWDADDR_NAME *)      Bit#(3) mRdWdAddr,      // Read word address
    (* port=`PLB_MREARBITRATE_NAME *)   Bit#(1) mRearbitrate,   // Rearbitrate
    (* port=`PLB_MWRBTERM_NAME *)       Bit#(1) mWrBTerm,       // Write burst terminate
    (* port=`PLB_MWRDACK_NAME *)        Bit#(1) mWrDAck,        // Write data ack
    (* port=`PLB_MSSIZE_NAME *)         Bit#(1) mSSize,         // Slave bus size
    (* port=`PLB_SMERR_NAME *)          Bit#(1) sMErr,          // Slave error
    (* port=`PLB_SMBUSY_NAME *)         Bit#(1) sMBusy);        // Slave busy       

     
endinterface

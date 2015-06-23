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

Author: Nirav Dave
*/

module plbmastertester(CLK,
		    RST,
		    
		    plbMasterWires_mABus,
		    
		    plbMasterWires_mBE,
		    
		    plbMasterWires_mRNW,
		    
		    plbMasterWires_mAbort,
		    
		    plbMasterWires_mBusLock,
		    
		    plbMasterWires_mCompress,
		    
		    plbMasterWires_mGuarded,
		    
		    plbMasterWires_mLockErr,
		    
		    plbMasterWires_mMSize,
		    
		    plbMasterWires_mOrdered,
		    
		    plbMasterWires_mPriority,
		    
		    plbMasterWires_mRdBurst,
		    
		    plbMasterWires_mRequest,
		    
		    plbMasterWires_mSize,
		    
		    plbMasterWires_mType,
		    
		    plbMasterWires_mWrBurst,
		    
		    plbMasterWires_mWrDBus,
		    
		    plbMasterWires_mRst,
		    plbMasterWires_mAddrAck,
		    plbMasterWires_mBusy,
		    plbMasterWires_mErr,
		    plbMasterWires_mRdBTerm,
		    plbMasterWires_mRdDAck,
		    plbMasterWires_mRdDBus,
		    plbMasterWires_mRdWdAddr,
		    plbMasterWires_mRearbitrate,
		    plbMasterWires_mWrBTerm,
		    plbMasterWires_mWrDAck,
		    plbMasterWires_mSSize,
		    plbMasterWires_sMErr,
		    plbMasterWires_sMBusy,
		    bramInitiatorWires_bramRST,
		    bramInitiatorWires_bramAddr,
		    bramInitiatorWires_bramDout,
		    bramInitiatorWires_bramWEN,
		    bramInitiatorWires_bramEN,
		    bramInitiatorWires_bramCLK,
		    bramInitiatorWires_bramDin);
  input  CLK;
  input  RST;
  
  // value method plbMasterWires_mABus
  output [31 : 0] plbMasterWires_mABus;
  
  // value method plbMasterWires_mBE
  output [7 : 0] plbMasterWires_mBE;
  
  // value method plbMasterWires_mRNW
  output plbMasterWires_mRNW;
  
  // value method plbMasterWires_mAbort
  output plbMasterWires_mAbort;
  
  // value method plbMasterWires_mBusLock
  output plbMasterWires_mBusLock;
  
  // value method plbMasterWires_mCompress
  output plbMasterWires_mCompress;
  
  // value method plbMasterWires_mGuarded
  output plbMasterWires_mGuarded;
  
  // value method plbMasterWires_mLockErr
  output plbMasterWires_mLockErr;
  
  // value method plbMasterWires_mMSize
  output [1 : 0] plbMasterWires_mMSize;
  
  // value method plbMasterWires_mOrdered
  output plbMasterWires_mOrdered;
  
  // value method plbMasterWires_mPriority
  output [1 : 0] plbMasterWires_mPriority;
  
  // value method plbMasterWires_mRdBurst
  output plbMasterWires_mRdBurst;
  
  // value method plbMasterWires_mRequest
  output plbMasterWires_mRequest;
  
  // value method plbMasterWires_mSize
  output [3 : 0] plbMasterWires_mSize;
  
  // value method plbMasterWires_mType
  output [2 : 0] plbMasterWires_mType;
  
  // value method plbMasterWires_mWrBurst
  output plbMasterWires_mWrBurst;
  
  // value method plbMasterWires_mWrDBus
  output [63 : 0] plbMasterWires_mWrDBus;
   
  // action method plbMasterWires_plbIN
  input  plbMasterWires_mRst;
  input  plbMasterWires_mAddrAck;
  input  plbMasterWires_mBusy;
  input  plbMasterWires_mErr;
  input  plbMasterWires_mRdBTerm;
  input  plbMasterWires_mRdDAck;
  input  [63 : 0] plbMasterWires_mRdDBus;
  input  [2 : 0] plbMasterWires_mRdWdAddr;
  input  plbMasterWires_mRearbitrate;
  input  plbMasterWires_mWrBTerm;
  input  plbMasterWires_mWrDAck;
  input  plbMasterWires_mSSize;
  input  plbMasterWires_sMErr;
  input  plbMasterWires_sMBusy;
  
  // action method bramTargetWires_bramIN
  output  [31 : 0] bramInitiatorWires_bramAddr;
  output  [31 : 0] bramInitiatorWires_bramDout;
  output  [3 : 0] bramInitiatorWires_bramWEN;
  output  bramInitiatorWires_bramEN;
  output  bramInitiatorWires_bramCLK;    
  output  bramInitiatorWires_bramRST;

  // value method bramTargetWires_bramOUT
  input [31 : 0] bramInitiatorWires_bramDin;
   
  wire [13:0] bramInitiatorWires_bramAddr_our;
  assign bramInitiatorWires_bramAddr = {16'h00000,bramInitiatorWires_bramAddr_our, 2'b00};
  // signals for module outputs
  wire [31 : 0] bramTargetWires_dinBRAM,plbMasterWires_mABus;

  wire [63 : 0]	plbMasterWires_mWrDBus;
  wire [7 : 0] plbMasterWires_mBE;
  wire [3 : 0] plbMasterWires_mSize;
  wire [2 : 0] plbMasterWires_mType;
  wire [1 : 0] plbMasterWires_mMSize, plbMasterWires_mPriority;
  wire plbMasterWires_mAbort,
       plbMasterWires_mBusLock,
       plbMasterWires_mCompress,
       plbMasterWires_mGuarded,
       plbMasterWires_mLockErr,
       plbMasterWires_mOrdered,
       plbMasterWires_mRNW,
       plbMasterWires_mRdBurst,
       plbMasterWires_mRequest,
       plbMasterWires_mWrBurst;

wire RST_N;
assign RST_N = ~RST;

mkPLBMasterTester  m(
	        .CLK(CLK),
	        .RST_N(RST_N),
		.plbMasterWires_mABus(plbMasterWires_mABus),
		.plbMasterWires_mBE(plbMasterWires_mBE),
		.plbMasterWires_mRNW(plbMasterWires_mRNW),
		.plbMasterWires_mAbort(plbMasterWires_mAbort),
		.plbMasterWires_mBusLock(plbMasterWires_mBusLock),
		.plbMasterWires_mCompress(plbMasterWires_mCompress),
		.plbMasterWires_mGuarded(plbMasterWires_mGuarded),
		.plbMasterWires_mLockErr(plbMasterWires_mLockErr),
		.plbMasterWires_mMSize(plbMasterWires_mMSize),
		.plbMasterWires_mOrdered(plbMasterWires_mOrdered),
		.plbMasterWires_mPriority(plbMasterWires_mPriority),
		.plbMasterWires_mRdBurst(plbMasterWires_mRdBurst),
		.plbMasterWires_mRequest(plbMasterWires_mRequest),
		.plbMasterWires_mSize(plbMasterWires_mSize),
		.plbMasterWires_mType(plbMasterWires_mType),
		.plbMasterWires_mWrBurst(plbMasterWires_mWrBurst),
		.plbMasterWires_mWrDBus(plbMasterWires_mWrDBus),
		.plbMasterWires_mRst(plbMasterWires_mRst),
		.plbMasterWires_mAddrAck(plbMasterWires_mAddrAck),
		.plbMasterWires_mBusy(plbMasterWires_mBusy),
		.plbMasterWires_mErr(plbMasterWires_mErr),
		.plbMasterWires_mRdBTerm(plbMasterWires_mRdBTerm),
		.plbMasterWires_mRdDAck(plbMasterWires_mRdDAck),
		.plbMasterWires_mRdDBus(plbMasterWires_mRdDBus),
		.plbMasterWires_mRdWdAddr(plbMasterWires_mRdWdAddr),
		.plbMasterWires_mRearbitrate(plbMasterWires_mRearbitrate),
		.plbMasterWires_mWrBTerm(plbMasterWires_mWrBTerm),
		.plbMasterWires_mWrDAck(plbMasterWires_mWrDAck),
		.plbMasterWires_mSSize(plbMasterWires_mSSize),
		.plbMasterWires_sMErr(plbMasterWires_sMErr),
		.plbMasterWires_sMBusy(plbMasterWires_sMBusy),
		.bramInitiatorWires_bramAddr(bramInitiatorWires_bramAddr_our),
		.bramInitiatorWires_bramDout(bramInitiatorWires_bramDout),
		.bramInitiatorWires_bramWEN(bramInitiatorWires_bramWEN),
		.bramInitiatorWires_bramEN(bramInitiatorWires_bramEN),
	        .bramInitiatorWires_bramCLK(bramInitiatorWires_bramCLK),
		.bramInitiatorWires_bramRST(bramInitiatorWires_bramRST),
		.bramInitiatorWires_din(bramInitiatorWires_bramDin)
		);

endmodule
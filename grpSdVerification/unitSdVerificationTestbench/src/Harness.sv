// SDHC-SC-Core
// Secure Digital High Capacity Self Configuring Core
// 
// (C) Copyright 2010, Rainer Kastl
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS  "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// File        : Harness.sv
// Owner       : Rainer Kastl
// Description : Verification harness for SDHC-SC-Core
// Links       : 
// 

`ifndef HARNESS_SV
`define HARNESS_SV

`include "SdCardModel.sv";
`include "WishboneBFM.sv";
`include "SdBFM.sv";
`include "SdCoreTransactionBFM.sv";
`include "SdCoreTransactionSeqGen.sv";
`include "SdCoreTransferFunction.sv";
`include "SdCoreChecker.sv";

class Harness;

	SdCoreTransactionBFM TransBfm;
	WbBFM WbBfm;
	SdBFM SdBfm;
	SdCoreTransactionSeqGen TransSeqGen;
	SdCoreTransferFunction TransFunc;
	SdCardModel Card;
	SdCoreChecker Checker;
	Logger Log;

	extern function new(virtual ISdBus SdBus, virtual IWishboneBus WbBus);
	extern task start();

endclass

function Harness::new(virtual ISdBus SdBus, virtual IWishboneBus WbBus);
	Log = new();
	
	TransSeqGen = new();
	TransBfm = new();
	WbBfm = new(WbBus);
	SdBfm = new(SdBus);

	TransFunc = new();
	Checker = new();
endfunction

task Harness::start();

	assert(Card.randomize()) else Log.error("Error randomizing card");

	// create Mailboxes
	TransSeqGen.TransOutMb[0] = new(1);
	TransSeqGen.TransOutMb[1] = new(1);
	TransBfm.WbTransOutMb = new(1);
	WbBfm.TransOutMb = new(1);
	TransBfm.SdTransOutMb = new(1);
	Card.ram.RamActionOutMb = new(1);
	TransFunc.ExpectedResultOutMb = new(1);
	Card.SdTransOutMb = new(1);
	Card.SdTransInMb = new(1);

	// todo: remove
	Card.bfm = SdBfm;

	// connect Mailboxes
	TransFunc.TransInMb = TransSeqGen.TransOutMb[0];
	TransBfm.SdTransInMb = TransSeqGen.TransOutMb[1];
	WbBfm.TransInMb = TransBfm.WbTransOutMb;
	TransBfm.WbTransInMb = WbBfm.TransOutMb;
	Checker.SdTransInMb = TransBfm.SdTransOutMb;
	Checker.RamActionInMb = Card.ram.RamActionOutMb;
	Checker.ExpectedResultInMb = TransFunc.ExpectedResultOutMb;
	SdBfm.SendTransMb = Card.SdTransOutMb;
	SdBfm.ReceivedTransMb = Card.SdTransInMb;

	// start threads
	TransSeqGen.start();
	TransBfm.start();
	WbBfm.start();
	SdBfm.start();
	TransFunc.start();
	Card.start();
	Checker.start();
	
endtask

`endif
 

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
// File        : SdVerificationTestbench.sv
// Owner       : Rainer Kastl
// Description : Testbench for verification of SDHC-SC-Core
// Links       : 
// 

`ifndef SDVERIFICATIONTESTBENCH
`define SDVERIFICATIONTESTBENCH

`define cWishboneWidth 32
const integer cWishboneWidth = 32;
const logic   cAsserted = 1;
const logic   cNegated  = 0;
const logic   cDontCare = 'X;

typedef logic [2:0] aCTI;
const aCTI ClassicCycle = "000";

`include "Harness.sv";
`include "SdCardModel.sv";

program Test(ISdBus SdBus, IWishboneBus WbBus);
	initial begin
		SdCardModel card;
		Harness harness;
		Logger log;

		log = new();
		card = new();
		harness = new(SdBus, WbBus);
		harness.Card = card;

		harness.start();
		#20ms;

		log.terminate();
    end	
endprogram

module Testbed();
	logic Clk = 0;
	logic RstSync = 1;

	ISdBus CardInterface();
	IWishboneBus IWbBus();	

	SdTop top(
			IWbBus.CLK_I,
			IWbBus.RST_I,
			IWbBus.CYC_O,
			IWbBus.LOCK_O,
			IWbBus.STB_O,
			IWbBus.WE_O,
			IWbBus.CTI_O,
			IWbBus.BTE_O,
			IWbBus.SEL_O,
			IWbBus.ADR_O,
			IWbBus.DAT_O,
			IWbBus.DAT_I,
			IWbBus.ACK_I,
			IWbBus.ERR_I,
			IWbBus.RTY_I,
			Clk,
			RstSync,
			CardInterface.Cmd,
			CardInterface.SClk,
			CardInterface.Data);

	always #5 Clk <= ~Clk;
	always #7 IWbBus.CLK_I <= ~IWbBus.CLK_I;

	initial begin
		#20 RstSync <= 0;
		#28 IWbBus.RST_I <= 0;
	end

	Test tb(CardInterface, IWbBus);

endmodule

`endif

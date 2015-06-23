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
// File        : TbdSd.sv
// Owner       : Rainer Kastl
// Description : 
// Links       : 
// 

`ifndef SDVERIFICATIONTESTBENCH
`define SDVERIFICATIONTESTBENCH

`include "SdCardModel.sv";

program Test(ISdBus SdBus);
	initial begin
	SdBusTransToken token;
	SdBFM SdBfm = new(SdBus);
	SdCardModel card = new();
	assert(card.randomize());
	card.bfm = SdBfm;

    fork
		begin // generator
		end

        begin // monitor
	    end

        begin // driver for SdCardModel
			card.run();
		end

	join;

    $display("%t : Test completed.", $time);
    end	
endprogram

module Testbed();
	logic Clk = 0;
	logic nResetAsync = 0;

	ISdBus CardInterface();

	TbdSd top(
			Clk,
			nResetAsync,
			CardInterface.Cmd,
			CardInterface.SClk,
			CardInterface.Data);

	always #5 Clk <= ~Clk;

	initial begin
		#10 nResetAsync <= 1;
	end

	Test tb(CardInterface);

endmodule

`endif

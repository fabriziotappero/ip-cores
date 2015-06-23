/*
Author: Sebastien Riou (acapola)
Creation date: 22:53:00 08/29/2010 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/TxCoreTestBench.v $				 

This file is under the BSD licence:
Copyright (c) 2011, Sebastien Riou

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
The names of contributors may not be used to endorse or promote products derived from this software without specific prior written permission. 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
`default_nettype none
`timescale 1ns / 1ps

module tb_TxCore;
parameter PARITY	= 1;
parameter CLK_PERIOD = 10;//should be %2
	// Inputs
	reg [7:0] dataIn;
	reg loadDataIn;
	reg [12:0] clocksPerBit;
	reg stopBit2;
	wire oddParity=0; //if 1, parity bit is such that data+parity have an odd number of 1
   wire msbFirst=0;  //if 1, bits will be send in the order startBit, b7, b6, b5...b0, parity
	reg clk;
	reg nReset;

	// Outputs
	wire serialOut;
	wire run;
	wire full;
   wire stopBits;

	// Instantiate the Unit Under Test (UUT)
	TxCore #(.PARITY_POLARITY(PARITY)) uut (
		.serialOut(serialOut), 
		.run(run), 
		.full(full), 
      .stopBits(stopBits),
		.dataIn(dataIn), 
		.clocksPerBit(clocksPerBit),
		.stopBit2(stopBit2),
		.oddParity(oddParity),
      .msbFirst(msbFirst),
	   .loadDataIn(loadDataIn), 
		.clk(clk), 
		.nReset(nReset)
	);
	
	//test bench signals
	reg tbClock;
	reg tbBitCounter;

	initial begin
		tbClock=0;
		tbBitCounter=0;
		// Initialize Inputs
		dataIn = 0;
		loadDataIn = 0;
		clocksPerBit = 8;
		stopBit2=0;
		clk = 0;
		nReset = 0;
		#(CLK_PERIOD*10);     
		nReset = 1;
		#(CLK_PERIOD*10);
		// Add stimulus here
		dataIn = 8'b1000_0000;
		loadDataIn = 1;
		wait(full==1);
		wait(full==0);
		//loadDataIn=0;
		dataIn = 8'b0111_1111;
		//loadDataIn = 1;
		wait(full==1);
		wait(full==0);
		loadDataIn=0;
	end
	
	initial begin
		// timeout
		#10000;        
		$finish;
	end
	
	always 
		#1	tbClock =  ! tbClock;
	always
		#(CLK_PERIOD/2) clk =  ! clk;
      
endmodule
`default_nettype wire


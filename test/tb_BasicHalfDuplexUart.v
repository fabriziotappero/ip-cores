/*
Author: Sebastien Riou (acapola)
Creation date: 19:45:19 10/31/2010 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/tb_BasicHalfDuplexUart.v $				 

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

module tb_BasicHalfDuplexUart;

	// Inputs
	reg [7:0] txData;
	reg [12:0] clocksPerBit;
	reg stopBit2;
	reg startTx;
	reg ackFlags;
	reg clk;
	reg nReset;

	// Outputs
	wire [7:0] rxData;
	wire overrunErrorFlag;
	wire dataOutReadyFlag;
	wire frameErrorFlag;
	wire run;
	wire rxStartBit;
	wire txFull;
	wire isTx;

	// Bidirs
	wire serialLine;

	// Instantiate the Unit Under Test (UUT)
	BasicHalfDuplexUart uut (
		.rxData(rxData), 
		.overrunErrorFlag(overrunErrorFlag), 
		.dataOutReadyFlag(dataOutReadyFlag), 
		.frameErrorFlag(frameErrorFlag), 
		.run(run), 
		.rxStartBit(rxStartBit), 
		.txFull(txFull), 
		.isTx(isTx), 
		.serialLine(serialLine), 
		.txData(txData), 
		.clocksPerBit(clocksPerBit), 
		.stopBit2(stopBit2), 
		.startTx(startTx), 
		.ackFlags(ackFlags), 
		.clk(clk), 
		.nReset(nReset)
	);

	initial begin
		// Initialize Inputs
		txData = 0;
		clocksPerBit = 0;
		stopBit2 = 0;
		startTx = 0;
		ackFlags = 0;
		clk = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule
`default_nettype wire


/*
Author: Sebastien Riou (acapola)
Creation date: 23:57:02 08/31/2010 

$LastChangedDate: 2011-03-07 14:17:52 +0100 (Mon, 07 Mar 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 18 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/Uart.v $				 

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

/*
Half duplex UART with 1 byte buffer
*/
module BasicHalfDuplexUart
#(//parameters to override
	parameter DIVIDER_WIDTH = 1,
	parameter CLOCK_PER_BIT_WIDTH = 13,	//allow to support default speed of ISO7816
	//invert the polarity of the output or not
	parameter IN_POLARITY = 1'b0,
	parameter PARITY_POLARITY = 1'b1,
	//default conventions
	parameter START_BIT = 1'b0,
	parameter STOP_BIT1 = 1'b1,
	parameter STOP_BIT2 = 1'b1
)
(
    output wire [7:0] rxData,
    output wire overrunErrorFlag,	//new data has been received before dataOut was read
    output wire dataOutReadyFlag,	//new data available
    output wire frameErrorFlag,		//bad parity or bad stop bits
    output wire txRun,					//tx is started
    output wire endOfRx,           //one cycle pulse: 1 during last cycle of last stop bit of rx
    output wire rxRun,					//rx is definitely started, one of the three flag will be set
    output wire rxStartBit,			//rx is started, but we don't know yet if real rx or just a glitch
    output wire txFull,
    output wire isTx,              //1 only when tx is ongoing. Indicates the direction of the com line.
    output wire endOfTx,           //one cycle pulse: 1 during last cycle of last stop bit of tx
    
	 input wire serialIn,				//signals to merged into a inout signal according to "isTx"
	 output wire serialOut,
	 output wire comClk,
	 
    input wire [DIVIDER_WIDTH-1:0] clkPerCycle,
	 input wire [7:0] txData,
	 input wire [CLOCK_PER_BIT_WIDTH-1:0] clocksPerBit,			
	 input wire stopBit2,//0: 1 stop bit, 1: 2 stop bits
	 input wire oddParity, //if 1, parity bit is such that data+parity have an odd number of 1
    input wire msbFirst,  //if 1, bits order is: startBit, b7, b6, b5...b0, parity
	 input wire startTx,
	 input wire ackFlags,
	 input wire clk,
    input wire nReset
    );

wire rxSerialIn = isTx ? STOP_BIT1 : serialIn;
wire loadDataIn;
wire txStopBits;
assign isTx = txRun & ~txStopBits;
assign loadDataIn = startTx & ~rxStartBit & (~rxRun | endOfRx);

reg [CLOCK_PER_BIT_WIDTH-1:0] safeClocksPerBit;
reg safeStopBit2;
reg safeOddParity;
reg safeMsbFirst;
always @(posedge clk, negedge nReset) begin
	if(~nReset) begin
		/*safeClocksPerBit<=clocksPerBit;
		safeStopBit2<=stopBit2;
		safeOddParity<=oddParity;
		safeMsbFirst<=msbFirst;*/
		safeClocksPerBit<={CLOCK_PER_BIT_WIDTH{1'b0}};
		safeStopBit2<=1'b0;
		safeOddParity<=1'b0;
		safeMsbFirst<=1'b0;
	end else if(endOfRx|endOfTx|~(rxRun|rxStartBit|txRun)) begin
		safeClocksPerBit<=clocksPerBit;
		safeStopBit2<=stopBit2;
		safeOddParity<=oddParity;
		safeMsbFirst<=msbFirst;
	end
end

wire stopBit;
// Instantiate the module
RxCoreSelfContained #(
		.DIVIDER_WIDTH(DIVIDER_WIDTH),
		.CLOCK_PER_BIT_WIDTH(CLOCK_PER_BIT_WIDTH)
		)
	rxCore (
    .dataOut(rxData), 
    .overrunErrorFlag(overrunErrorFlag), 
    .dataOutReadyFlag(dataOutReadyFlag), 
    .frameErrorFlag(frameErrorFlag), 
    .endOfRx(endOfRx),
    .run(rxRun), 
    .startBit(rxStartBit), 
	 .stopBit(stopBit),
    .clkPerCycle(clkPerCycle),
    .clocksPerBit(safeClocksPerBit), 
    .stopBit2(safeStopBit2), 
    .oddParity(safeOddParity),
    .msbFirst(safeMsbFirst),
	 .ackFlags(ackFlags), 
    .serialIn(rxSerialIn), 
    .comClk(comClk), 
    .clk(clk), 
    .nReset(nReset)
    );
TxCore #(.DIVIDER_WIDTH(DIVIDER_WIDTH),
			.CLOCK_PER_BIT_WIDTH(CLOCK_PER_BIT_WIDTH)
		)
	txCore (
	.serialOut(serialOut), 
	.run(txRun),
	.endOfTx(endOfTx),
	.full(txFull), 
   .stopBits(txStopBits),
	.dataIn(txData), 
	.clkPerCycle(clkPerCycle),
	.clocksPerBit(safeClocksPerBit),
	.stopBit2(safeStopBit2),
   .oddParity(safeOddParity),
   .msbFirst(safeMsbFirst),
	.loadDataIn(loadDataIn), 
	.comClk(comClk), 
   .clk(clk), 
   .nReset(nReset)
);

endmodule
`default_nettype wire

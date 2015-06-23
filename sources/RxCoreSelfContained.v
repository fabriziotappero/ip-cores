/*
Author: Sebastien Riou (acapola)
Creation date: 23:57:02 08/31/2010 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/RxCoreSelfContained.v $				 

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

module RxCoreSelfContained
#(//parameters to override
	parameter DIVIDER_WIDTH = 1,
	parameter CLOCK_PER_BIT_WIDTH = 13,	//allow to support default speed of ISO7816
	parameter PRECISE_STOP_BIT = 0, //if 1, stopBit signal goes high exactly at start of stop bit instead of middle of parity bit
	//default conventions
	parameter START_BIT = 1'b0,
	parameter STOP_BIT1 = 1'b1,
	parameter STOP_BIT2 = 1'b1
)
(
    output wire [7:0] dataOut,
    output wire overrunErrorFlag,	//new data has been received before dataOut was read
    output wire dataOutReadyFlag,	//new data available
    output wire frameErrorFlag,		//bad parity or bad stop bits
    output wire endOfRx,				//one cycle pulse: 1 during last cycle of last stop bit
    output wire run,					//rx is definitely started, one of the three flag will be set
    output wire startBit,				//rx is started, but we don't know yet if real rx or just a glitch
	 output wire stopBit,				//rx is over but still in stop bits
	 input wire [DIVIDER_WIDTH-1:0] clkPerCycle,
	 input wire [CLOCK_PER_BIT_WIDTH-1:0] clocksPerBit,			
	 input wire stopBit2,//0: 1 stop bit, 1: 2 stop bits
	 input wire oddParity, //if 1, parity bit is such that data+parity have an odd number of 1
    input wire msbFirst,  //if 1, bits order is: startBit, b7, b6, b5...b0, parity
	 input wire ackFlags,
	 input wire serialIn,
    input wire comClk,//not used yet
    input wire clk,
    input wire nReset
    );

wire [CLOCK_PER_BIT_WIDTH-1:0] bitClocksCounter;
wire bitClocksCounterEarlyMatch;
wire bitClocksCounterMatch;
wire [CLOCK_PER_BIT_WIDTH-1:0] bitClocksCounterCompare;
wire bitClocksCounterInc;
wire bitClocksCounterClear;
wire bitClocksCounterInitVal;
wire dividedClk;
Counter #(	.DIVIDER_WIDTH(DIVIDER_WIDTH),
				.WIDTH(CLOCK_PER_BIT_WIDTH),
				.WIDTH_INIT(1)) 
		bitClocksCounterModule(
				.counter(bitClocksCounter),
				.earlyMatch(bitClocksCounterEarlyMatch),
				.match(bitClocksCounterMatch),
				.dividedClk(dividedClk),
				.divider(clkPerCycle),
				.compare(bitClocksCounterCompare),
				.inc(bitClocksCounterInc),
				.clear(bitClocksCounterClear),
				.initVal(bitClocksCounterInitVal),
				.clk(clk),
				.nReset(nReset));

RxCore #(	.CLOCK_PER_BIT_WIDTH(CLOCK_PER_BIT_WIDTH),
				.PRECISE_STOP_BIT(PRECISE_STOP_BIT)
				)
	rxCore (
    .dataOut(dataOut), 
    .overrunErrorFlag(overrunErrorFlag), 
    .dataOutReadyFlag(dataOutReadyFlag), 
    .frameErrorFlag(frameErrorFlag), 
    .endOfRx(endOfRx),
    .run(run), 
    .startBit(startBit),
    .stopBit(stopBit),
    .clocksPerBit(clocksPerBit), 
    .stopBit2(stopBit2), 
    .oddParity(oddParity),
    .msbFirst(msbFirst),
	 .ackFlags(ackFlags), 
    .serialIn(serialIn), 
    .clk(clk), 
    .nReset(nReset),
	.bitClocksCounterEarlyMatch(bitClocksCounterEarlyMatch),
   .bitClocksCounterMatch(bitClocksCounterMatch),
	.bitClocksCounterCompare(bitClocksCounterCompare),
	.bitClocksCounterInc(bitClocksCounterInc),
	.bitClocksCounterClear(bitClocksCounterClear),
	.bitClocksCounterInitVal(bitClocksCounterInitVal),
	.bitClocksCounter(bitClocksCounter)
    );

endmodule
`default_nettype wire

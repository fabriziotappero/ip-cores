/*
Author: Sebastien Riou (acapola)
Creation date: 21:16:10 08/29/2010 

$LastChangedDate: 2011-03-07 14:17:52 +0100 (Mon, 07 Mar 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 18 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/TxCore.v $				 

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

module TxCore
#(//parameters to override
	parameter DIVIDER_WIDTH = 1,
	parameter CLOCK_PER_BIT_WIDTH = 13,//allow to support default speed of ISO7816
	//default conventions
	parameter START_BIT = 1'b0,
	parameter STOP_BIT1 = 1'b1
)
(
    output wire comClk,
    output wire serialOut,
    output wire run,
	 output reg endOfTx,
    output wire full,
    output wire stopBits, //1 during stop bits
    input wire [7:0] dataIn,
    input wire [DIVIDER_WIDTH-1:0] clkPerCycle,
	 input wire [CLOCK_PER_BIT_WIDTH-1:0] clocksPerBit,			
	 input wire loadDataIn,   //evaluated only when full=0, when full goes to one, dataIn has been read
    input wire stopBit2,//0: 1 stop bit, 1: 2 stop bits
    input wire oddParity, //if 1, parity bit is such that data+parity have an odd number of 1
    input wire msbFirst,  //if 1, bits will be send in the order startBit, b7, b6, b5...b0, parity
	 input wire clk,
    input wire nReset
    );

//constant definition for state
localparam IDLE_STATE = 0;
localparam START_STATE = 1;
localparam SEND_DATA_STATE = 2;
localparam SEND_PARITY_STATE = 3;
localparam SEND_STOP1_STATE = 4;
localparam SEND_STOP2_STATE = 5;

localparam IDLE_BIT = ~START_BIT;
localparam STOP_BIT2 = STOP_BIT1;

wire [CLOCK_PER_BIT_WIDTH-1:0] bitClocksCounter;
wire bitClocksCounterEarlyMatch;
wire bitClocksCounterMatch;
reg [CLOCK_PER_BIT_WIDTH-1:0] bitClocksCounterCompare;
reg bitClocksCounterInc;
reg bitClocksCounterClear;
wire bitClocksCounterInitVal;
Counter #(	.DIVIDER_WIDTH(DIVIDER_WIDTH),
				.WIDTH(CLOCK_PER_BIT_WIDTH),
				.WIDTH_INIT(1)) 
		bitClocksCounterModule(
				.counter(bitClocksCounter),
				.earlyMatch(bitClocksCounterEarlyMatch),
				.match(bitClocksCounterMatch),
				.dividedClk(comClk),
				.divider(clkPerCycle),
				.compare(bitClocksCounterCompare),
				.inc(bitClocksCounterInc),
				.clear(bitClocksCounterClear),
				.initVal(bitClocksCounterInitVal),
				.clk(clk),
				.nReset(nReset));

reg [2:0] nextState;
reg [2:0] bitCounter;
reg [7:0] dataBuffer;

reg parityBit;

wire internalOut;
wire dataBit;
//after a tx operation, during the first cycle in IDLE_STATE, run bit must be still set 
//(it is entered one cycle before the completion of the operation, so we use bitClocksCounter[0]
//to implement this behavior)
assign run = (nextState == IDLE_STATE) ? bitClocksCounter[0] : 1'b1;
assign full = (nextState != IDLE_STATE);
assign stopBits = (nextState == SEND_STOP1_STATE)|(nextState == SEND_STOP2_STATE)|((nextState == IDLE_STATE) & bitClocksCounter[0]);

assign serialOut = internalOut;
wire [2:0] bitIndex = msbFirst ? 7-bitCounter : bitCounter;
assign dataBit = dataBuffer[bitIndex];
wire [0:5] bitSel;
assign bitSel = {IDLE_BIT, START_BIT, dataBit, parityBit, STOP_BIT1, STOP_BIT2};
assign internalOut = bitSel[nextState];

assign bitClocksCounterInitVal=0;

always @(*) begin
   case(nextState)
      START_STATE:    
         bitClocksCounterCompare = clocksPerBit-1'b1;
      SEND_STOP2_STATE:    
         bitClocksCounterCompare = clocksPerBit-1'b1;
      default: 
         bitClocksCounterCompare = clocksPerBit;
   endcase
end

always @(nextState) begin
	case(nextState)
		IDLE_STATE: begin
			bitClocksCounterInc = 0;
			bitClocksCounterClear = 1;
		end
		default: begin
			bitClocksCounterInc = 1;
			bitClocksCounterClear = 0;		
		end
	endcase
end

always @(posedge clk, negedge nReset) begin
	if(~nReset) begin
		nextState <= #1 IDLE_STATE;
		bitCounter <= #1 0;
		endOfTx <= #1 1'b0;
	end else begin
		case(nextState)
			IDLE_STATE: begin
				if(loadDataIn) begin
					dataBuffer <= #1 dataIn;
					parityBit <= #1 oddParity;
					nextState <= #1 START_STATE;
				end
			end
			START_STATE: begin
				if(bitClocksCounterMatch) begin
					nextState <= #1 SEND_DATA_STATE;
				end
			end
			SEND_DATA_STATE: begin
				if(bitClocksCounterMatch) begin
					bitCounter <= #1 (bitCounter + 1'b1) & 3'b111;
					parityBit <= #1 parityBit ^ dataBit;
					if(bitCounter == 7)
						nextState <= #1 SEND_PARITY_STATE;
				end
			end
			SEND_PARITY_STATE: begin
				if(bitClocksCounterMatch) begin
					if(stopBit2)
						nextState <= #1 SEND_STOP1_STATE;
					else
						nextState <= #1 SEND_STOP2_STATE;//if single stop bit, we skip STOP1 state
				end
			end
			SEND_STOP1_STATE: begin
				if(bitClocksCounterMatch)
					nextState <= #1 SEND_STOP2_STATE;
			end
			SEND_STOP2_STATE: begin
				if(bitClocksCounterEarlyMatch)
					endOfTx <= #1 1'b1;
				if(bitClocksCounterMatch) begin
               nextState <= #1 IDLE_STATE;
					endOfTx <= #1 1'b0;
				end
         end
			default: nextState <= #1 IDLE_STATE;
		endcase
	end

end

endmodule
`default_nettype wire

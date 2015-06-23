/*
Author: Sebastien Riou (acapola)
Creation date: 23:57:02 08/31/2010 

$LastChangedDate: 2011-03-07 14:17:52 +0100 (Mon, 07 Mar 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 18 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/RxCore.v $				 

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

module RxCore
#(//parameters to override
parameter CLOCK_PER_BIT_WIDTH = 13,	//allow to support default speed of ISO7816
parameter PRECISE_STOP_BIT = 0, //if 1, stopBit signal goes high exactly at start of stop bit instead of middle of parity bit
//default conventions (nothing to do with iso7816's convention, this is configured dynamically by the inputs)
parameter START_BIT = 1'b0,
parameter STOP_BIT1 = 1'b1,
parameter STOP_BIT2 = 1'b1
)
(
   output reg [7:0] dataOut,
   output reg overrunErrorFlag,	//new data has been received before dataOut was read
   output reg dataOutReadyFlag,	//new data available
   output reg frameErrorFlag,		//bad parity or bad stop bits
   output reg endOfRx,				//one cycle pulse: 1 during last cycle of last stop bit
   output reg run,					//rx is definitely started, one of the three flag will be set
   output wire startBit,			//rx is started, but we don't know yet if real rx or just a glitch
	output reg stopBit,				//rx is over but still in stop bits
	input wire [CLOCK_PER_BIT_WIDTH-1:0] clocksPerBit,			
	input wire stopBit2,//0: 1 stop bit, 1: 2 stop bits
	input wire oddParity, //if 1, parity bit is such that data+parity have an odd number of 1
   input wire msbFirst,  //if 1, bits order is: startBit, b7, b6, b5...b0, parity
	input wire ackFlags,
	input wire serialIn,
	input wire clk,
   input wire nReset,
	//to connect to an instance of Counter.v (see RxCoreSelfContained.v for example)
	output reg [CLOCK_PER_BIT_WIDTH-1:0] bitClocksCounterCompare,
	output reg bitClocksCounterInc,
	output reg bitClocksCounterClear,
	output wire bitClocksCounterInitVal,
   input wire bitClocksCounterEarlyMatch,
	input wire bitClocksCounterMatch,
	input wire [CLOCK_PER_BIT_WIDTH-1:0] bitClocksCounter
    );

//constant definition for states
localparam IDLE_STATE = 	3'b000;
localparam START_STATE = 	3'b001;
localparam DATA_STATE = 	3'b011;
localparam PARITY_STATE = 	3'b010;
localparam STOP1_STATE = 	3'b110;
localparam STOP2_STATE = 	3'b111;
localparam END_STATE = 		3'b101;
localparam END2_STATE =    3'b100;

localparam IDLE_BIT = ~START_BIT;

reg [2:0] nextState;

reg [2:0] bitCounter;
wire [2:0] bitIndex = msbFirst ? 7-bitCounter : bitCounter;
reg parityBit;

wire internalIn;
wire parityError;

assign startBit = (nextState == START_STATE);
//assign stopBit = (nextState == STOP1_STATE) | (nextState == STOP2_STATE);
assign internalIn = serialIn;
assign parityError= parityBit ^ internalIn ^ 1'b1;
reg flagsSet;

assign bitClocksCounterInitVal=(nextState==IDLE_STATE);
always @(nextState, clocksPerBit, run, bitClocksCounterMatch) begin
	case(nextState)
		IDLE_STATE: begin
			bitClocksCounterCompare = (clocksPerBit/2);
			bitClocksCounterInc = run & ~bitClocksCounterMatch;//stop when reach 0
			bitClocksCounterClear = ~run;
		end
		START_STATE: begin
			bitClocksCounterCompare = (clocksPerBit/2);
			bitClocksCounterInc = 1;
			bitClocksCounterClear = 0;
		end
		STOP2_STATE: begin
         //make the rx operation is one cycle shorter, 
         //since we detect the start bit at least one cycle later it starts.
			bitClocksCounterCompare = clocksPerBit-1'b1;
			bitClocksCounterInc = 1;
			bitClocksCounterClear = 0;
		end
		default: begin
			bitClocksCounterCompare = clocksPerBit;
			bitClocksCounterInc = 1;
			bitClocksCounterClear = 0;		
		end
	endcase
end

always @(posedge clk, negedge nReset) begin
	if(~nReset) begin
		nextState <= #1 IDLE_STATE;
		bitCounter <= #1 0;
		parityBit <= #1 0;
		overrunErrorFlag <= #1 0;
		dataOutReadyFlag <= #1 0;
		frameErrorFlag <= #1 0;
		run <= #1 0;
      endOfRx <= #1 0;
		stopBit<= #1 0;
	end else begin	
		case(nextState)
			IDLE_STATE: begin
				if(bitClocksCounterEarlyMatch)
               endOfRx <= #1 1'b1;
            if(bitClocksCounterMatch) begin
               endOfRx <= #1 0;
					stopBit <= #1 0;
				end
            if(ackFlags) begin
					//overrunErrorFlag is auto cleared at PARITY_STATE
					//meanwhile, it prevent dataOutReadyFlag to be set by the termination of the lost byte
					dataOutReadyFlag <= #1 0;
					frameErrorFlag <= #1 0;
				end
				if(START_BIT == internalIn) begin
					if(frameErrorFlag | overrunErrorFlag) begin
						//wait clear from outside
						if(bitClocksCounterMatch) begin
                     //endOfRx <= #1 0;
							run <= #1 0;
                  end
					end else begin
						parityBit <= #1 ~oddParity;
						run <= #1 0;
						nextState <= #1 START_STATE;
					end
				end else begin
					if(bitClocksCounterMatch) begin
                  //endOfRx <= #1 0;
						run <= #1 0;
               end
				end
			end
			START_STATE: begin
				if(ackFlags) begin
					dataOutReadyFlag <= #1 0;
					frameErrorFlag <= #1 0;
				end
				if(bitClocksCounterMatch) begin
					if(START_BIT != internalIn) begin
						nextState <= #1 IDLE_STATE;
					end else begin
						run <= #1 1;
						nextState <= #1 DATA_STATE;
					end
				end
			end
			DATA_STATE: begin
				if(ackFlags) begin
					dataOutReadyFlag <= #1 0;
					frameErrorFlag <= #1 0;
				end
				if(bitClocksCounterMatch) begin
					if(dataOutReadyFlag) begin
						overrunErrorFlag <= #1 1;
					end else
						dataOut[bitIndex] <= #1 internalIn;			
					parityBit <= #1 parityBit ^ internalIn;
					bitCounter <= #1 (bitCounter + 1'b1) & 3'b111;
					if(bitCounter == 7)
						nextState <= #1 PARITY_STATE;
				end
			end
			PARITY_STATE: begin
				if(bitClocksCounterMatch) begin
					if(~overrunErrorFlag) begin
						frameErrorFlag <= #1 parityError;
						dataOutReadyFlag <= #1 ~parityError;
					end else if(ackFlags) begin
						frameErrorFlag <= #1 0;
					end
					flagsSet=1;
					if(PRECISE_STOP_BIT==0) stopBit <= #1 1;
					if(stopBit2)
						nextState <= #1 STOP1_STATE;
					else
						nextState <= #1 STOP2_STATE;
				end else if(ackFlags) begin
					dataOutReadyFlag <= #1 0;
					frameErrorFlag <= #1 0;
				end
			end
			STOP1_STATE: begin
				if(ackFlags) begin
					dataOutReadyFlag <= #1 0;
				end
				if(bitClocksCounterMatch) begin
					if(STOP_BIT1 != internalIn) begin
						frameErrorFlag <= #1 parityError;
					end else if(ackFlags) begin
						frameErrorFlag <= #1 0;
					end
					nextState <= #1 STOP2_STATE;
				end else if(ackFlags) begin
					frameErrorFlag <= #1 0;
				end
				if(PRECISE_STOP_BIT!=0) begin
					if(bitClocksCounter==(bitClocksCounterCompare/2)) begin
						stopBit <= #1 1;
					end
				end
			end
			STOP2_STATE: begin
				if(ackFlags) begin
					dataOutReadyFlag <= #1 0;
				end
            if(bitClocksCounterMatch) begin
					if(STOP_BIT2 != internalIn) begin
						frameErrorFlag <= #1 1;
					end else if(ackFlags) begin
						frameErrorFlag <= #1 0;
					end
					nextState <= #1 IDLE_STATE;
				end else if(ackFlags) begin
					frameErrorFlag <= #1 0;
				end
				if(PRECISE_STOP_BIT!=0) begin
					if(bitClocksCounter==(bitClocksCounterCompare/2)) begin
						stopBit <= #1 1;
					end
				end
			end
			default: nextState <= #1 IDLE_STATE;
		endcase
	end
end

endmodule
`default_nettype wire

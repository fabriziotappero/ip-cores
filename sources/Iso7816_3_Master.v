/*
Author: Sebastien Riou (acapola)
Creation date: 17:16:40 01/09/2011 

$LastChangedDate: 2011-03-07 14:17:52 +0100 (Mon, 07 Mar 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 18 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/Iso7816_3_Master.v $				 

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
module Iso7816_3_Master(
    input wire nReset,
    input wire clk,
	 input wire [15:0] clkPerCycle,//not supported yet
	 input wire startActivation,//Starts activation sequence
	 input wire startDeactivation,//Starts deactivation sequence
    input wire [7:0] dataIn,
    input wire nWeDataIn,
	 input wire [12:0] cyclesPerEtu,
    output reg [7:0] dataOut,
    input wire nCsDataOut,
    output wire [7:0] statusOut,
    input wire nCsStatusOut,
	 output reg isActivated,//set to high by activation sequence, set to low by deactivation sequence
	 output wire useIndirectConvention,
	 output wire tsError,//high if TS character is wrong
	 output wire tsReceived,
	 output wire atrIsEarly,//high if TS received before 400 cycles after reset release
	 output wire atrIsLate,//high if TS is still not received after 40000 cycles after reset release
	 //ISO7816 signals
    //inout wire isoSio,//not synthesisable on FPGA :-S
	 output wire isTx,
	 input wire isoSioIn,
	 output wire isoSioOut,
	 output wire isoClk,
	 output reg isoReset,
	 output reg isoVdd
    );

wire txRun,txPending, rxRun, rxStartBit, overrunErrorFlag, frameErrorFlag, bufferFull;
assign {txRun, txPending, rxRun, rxStartBit, isTx, overrunErrorFlag, frameErrorFlag, bufferFull} = statusOut;

//wire serialOut;
//not synthesisable on FPGA :-S
//assign isoSio = isTx ? serialOut : 1'bz;
//pullup(isoSio);
wire comClk;

wire stopBit2=1'b1;//0: 1 stop bit, 1: 2 stop bits 
wire msbFirst = useIndirectConvention;//if 1, bits order is: startBit, b7, b6, b5...b0, parity
wire oddParity = 1'b0;//if 1, parity bit is such that data+parity have an odd number of 1
wire sioHighValue = ~useIndirectConvention;//apply only to data bits

wire [7:0] uart_dataOut;
wire [7:0] uart_dataIn = sioHighValue ? dataIn : ~dataIn;
always @(*) dataOut = sioHighValue ? uart_dataOut : ~uart_dataOut;


	HalfDuplexUartIf #(
		.DIVIDER_WIDTH(1'b1),
		.CLOCK_PER_BIT_WIDTH(4'd13)
		)
	uart (
		.nReset(nReset), 
		.clk(clk),
		.clkPerCycle(1'b0),
		.dataIn(uart_dataIn), 
		.nWeDataIn(nWeDataIn), 
		.clocksPerBit(cyclesPerEtu), 
		.stopBit2(stopBit2), 
		.oddParity(oddParity), 
      .msbFirst(msbFirst),  
	   .dataOut(uart_dataOut), 
		.nCsDataOut(nCsDataOut), 
		.statusOut(statusOut), 
		.nCsStatusOut(nCsStatusOut), 
		.serialIn(isoSioIn),
		.serialOut(isoSioOut),
		.comClk(comClk)
	);
	
	reg isoClkEn;
	assign isoClk = isoClkEn ? comClk : 1'b0;
	
reg [16:0] resetCnt;
reg waitTs;
assign tsReceived = ~waitTs;
reg [7:0] ts;
assign atrIsEarly = ~waitTs & (resetCnt<(16'h100+16'd400));
assign atrIsLate = resetCnt>(16'h100+16'd40000);
assign useIndirectConvention = ~waitTs & (ts==8'h3F);
assign tsError = ~waitTs & (ts!=8'h3B) & (ts!=8'h3F);
always @(posedge comClk, negedge nReset) begin
	if(~nReset) begin
		isoClkEn <= 1'b0;
		resetCnt<=16'b0;
		waitTs<=1'b1;
		isoReset <= 1'b0;
		isoVdd <= 1'b0;
		isActivated <= 1'b0;
	end else if(isActivated) begin
		if(waitTs) begin
			if(statusOut[0]) begin
				waitTs<=1'b0;
				case(dataOut)
					8'h3B: ts<=dataOut;
					8'h03: ts<=8'h3F;//03 is 3F written LSB first and complemented
					default: ts<=dataOut;
				endcase
			end
			resetCnt<=resetCnt+1'b1;
		end
		if(startDeactivation) begin
			isoVdd <= 1'b0;
			isoClkEn <= 1'b0;
			isoReset <= 1'b0;
			resetCnt<=16'b0;
			isActivated <= 1'b0;
		end
	end else begin
		if(startActivation) begin
			waitTs <= 1'b1;
			isoVdd <= 1'b1;
			isoClkEn <= 1'b1;
			if(16'h100 == resetCnt) begin
				isActivated <=1'b1;
				isoReset <=1'b1;
			end else
				resetCnt<=resetCnt + 1'b1;
		end else begin
			resetCnt<=16'b0;
		end
	end
end
endmodule
`default_nettype wire

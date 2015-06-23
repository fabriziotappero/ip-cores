/*
Author: Sebastien Riou (acapola)
Creation date: 22:22:43 01/10/2011 

$LastChangedDate: 2011-03-07 14:17:52 +0100 (Mon, 07 Mar 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 18 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/tsAnalyzer.v $				 

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

module TsAnalyzer(
	input wire nReset,
	input wire isoReset,
	input wire isoClk,
	input wire isoVdd,
	input wire isoSio,
	input wire endOfRx,
	input wire [7:0] rxData,//assumed to be sent lsb first, high level coding logical 1.
	output wire isActivated,
	output wire tsReceived,
	output wire tsError,
	output wire atrIsEarly,//high if TS received before 400 cycles after reset release
	output wire atrIsLate,//high if TS is still not received after 40000 cycles after reset release
	output wire useIndirectConvention,
	output reg [7:0] ts
	);

	
reg [8:0] tsCnt;//counter to start ATR 400 cycles after reset release

reg [16:0] resetCnt;
reg waitTs;
assign tsReceived = ~waitTs;
assign atrIsEarly = ~waitTs & (resetCnt<(16'h100+16'd400));
assign atrIsLate = resetCnt>(16'h100+16'd40000);
assign useIndirectConvention = ~waitTs & (ts==8'h3F);
assign tsError = ~waitTs & (ts!=8'h3B) & (ts!=8'h3F);

assign isActivated = isoReset & isoVdd;
wire fsm_nReset=nReset & isoReset & isoVdd;
always @(posedge isoClk, negedge fsm_nReset) begin
	if(~fsm_nReset) begin
		resetCnt<=16'b0;
		waitTs<=1'b1;
	end else if(isActivated) begin
		if(waitTs) begin
			if(endOfRx) begin
				waitTs<=1'b0;
				case(rxData)
					8'h3B: ts<=rxData;
					8'h03: ts<=8'h3F;//03 is 3F written LSB first and complemented
					default: ts<=rxData;
				endcase
			end
			resetCnt<=resetCnt+1'b1;
		end
	end else begin
		//if(isoVdd & isoReset) begin
			resetCnt<=resetCnt + 1'b1;
		//end else begin
		//	resetCnt<=16'b0;
		//end
	end
end
		
endmodule
`default_nettype wire


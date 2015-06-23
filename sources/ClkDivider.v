/*
Author: Sebastien Riou (acapola)
Creation date: 18:05:27 01/09/2011 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/ClkDivider.v $				 

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
/*
Basic clock divider

if divider=0
	dividedClk=clk
else
	F(dividedClk)=F(clk)/(divider*2)
	dividedClk has a duty cycle of 50%	

WARNING:	
	To change divider on the fly:
		1. set it to 0 at least for one cycle
		2. set it to the new value.
*/
module ClkDivider
#(//parameters to override
	parameter DIVIDER_WIDTH = 16
)
(
	input wire nReset,
	input wire clk,									// input clock
	input wire [DIVIDER_WIDTH-1:0] divider,	// divide factor
	output wire dividedClk,						// divided clock
	output wire divideBy1,
	output wire match,
	output wire risingMatch,
	output wire fallingMatch
	); 

	
	reg out;//internal divided clock
	reg [DIVIDER_WIDTH-1:0] cnt;
  
	// if divider=0, dividedClk = clk.
	assign divideBy1 = |divider ? 1'b0 : 1'b1;
	assign dividedClk = divideBy1 ? clk : out;
	
	assign match = (cnt==(divider-1));
	assign risingMatch = match & ~out;
	assign fallingMatch = match & out;
	
	always @(posedge clk, negedge nReset)
	begin
		if(~nReset | divideBy1) begin
			cnt <= 0;
			out <= 1'b0;
		end else if(~divideBy1)	begin
			if(match) begin
				cnt <= 0;
				out <= ~out;
			end else begin
				cnt <= cnt + 1'b1;
			end
		end
	end

endmodule
`default_nettype wire

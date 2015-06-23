/*
Author: Sebastien Riou (acapola)
Creation date: 23:57:02 08/31/2010 

$LastChangedDate: 2011-01-29 13:16:17 +0100 (Sat, 29 Jan 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 11 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/sources/Counter.v $				 

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
A counter with increment and clear operation
*/
module Counter
#(//parameters to override
	parameter DIVIDER_WIDTH = 16,
	parameter WIDTH = 8,
	parameter WIDTH_INIT = 1
)
(
    output reg [WIDTH-1:0] counter,
    output wire earlyMatch,
	 output reg match,
	 output wire dividedClk,
	 input wire [DIVIDER_WIDTH-1:0] divider,	// clock divide factor
	 input wire [WIDTH-1:0] compare,
	 input wire inc,
	 input wire clear,
	 input wire [WIDTH_INIT-1:0] initVal,
	 input wire clk,
    input wire nReset
    );

wire divideBy1;
wire divMatch;
wire divRisingMatch;
wire divFallingMatch;

ClkDivider #(.DIVIDER_WIDTH(DIVIDER_WIDTH))
	clkDivider(
		.nReset(nReset),
		.clk(clk),
		.divider(divider),
		.dividedClk(dividedClk),
		.divideBy1(divideBy1),
		.match(divMatch),
		.risingMatch(divRisingMatch),
		.fallingMatch(divFallingMatch)
		);

wire [WIDTH-1:0] nextCounter = counter+1'b1;

wire doInc = divideBy1 ? inc :inc & divRisingMatch;
wire doEarlyMatch = divideBy1 ? (compare == nextCounter) : (compare == counter) & divRisingMatch;

reg earlyMatchReg;
assign earlyMatch = divideBy1 ? earlyMatchReg : doEarlyMatch;

always @(posedge clk, negedge nReset) begin
	if(~nReset) begin
		counter <= 0;//initVal;
      earlyMatchReg <= 0;
		match <= 0;
	end else begin
		if(clear) begin
			counter <= initVal;
		end else if(doInc) begin
			if(compare == counter)
				counter <= initVal;
			else
				counter <= nextCounter;
		end
		if(doEarlyMatch)
			earlyMatchReg <= 1;
		else begin
			earlyMatchReg <= 0;
		end
      match <= divideBy1 ? earlyMatchReg : doEarlyMatch;
	end					
end

endmodule
`default_nettype wire

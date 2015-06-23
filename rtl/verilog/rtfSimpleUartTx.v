// ============================================================================
//	(C) 2011,2013  Robert Finch
//  All rights reserved.
//	robfinch@<remove>finitron.ca
//
//	rtfSimpleUartTx.v
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//		Simple uart transmitter core.
//		Features:
//			Fixed format 1 start - 8 data - 1 stop bits
//
//
//   	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|WISHBONE Datasheet
//	|WISHBONE SoC Architecture Specification, Revision B.3
//	|
//	|Description:						Specifications:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|General Description:				simple serial UART transmitter
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported Cycles:					SLAVE,WRITE
//	|									SLAVE,BLOCK WRITE
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Data port, size:					8 bit
//	|Data port, granularity:			8 bit
//	|Data port, maximum operand size:	8 bit
//	|Data transfer ordering:			Undefined
//	|Data transfer sequencing:			Undefined
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Clock frequency constraints:		none
//  |      Baud Generates by X16 or X8 CLK_I depends on baud8x pin
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported signal list and			Signal Name		WISHBONE equiv.
//	|cross reference to equivalent		ack_o			ACK_O
//	|WISHBONE signals					
//	|									clk_i			CLK_I
//	|                                   rst_i           RST_I 
//	|									dat_i[7:0]		DAT_I()
//	|									cyc_i			CYC_I
//	|									stb_i			STB_I
//	|									we_i			WE_I
//	|
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Special requirements:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//
//	REF: Spartan3 - 4
//	30 LUTs / 23 slices / 165MHz
//============================================================================ */

module rtfSimpleUartTx(
	// WISHBONE SoC bus interface
	input rst_i,		// reset
	input clk_i,		// clock
	input cyc_i,		// cycle valid
	input stb_i,		// strobe
	output ack_o,		// transfer done
	input we_i,			// write transmitter
	input [7:0] dat_i,	// data in
	//--------------------
	input cs_i,			// chip select
	input baud16x_ce,	// baud rate clock enable
    input tri0 baud8x,       // switches to mode baudX8
	input cts,			// clear to send
	output txd,			// external serial output
	output reg empty, 	// buffer is empty
    output reg txc          // tx complete flag
);

reg [9:0] tx_data;	// transmit data working reg (raw)
reg [7:0] fdo;		// data output
reg [7:0] cnt;		// baud clock counter
reg rd;

wire isX8;
buf(isX8, baud8x);
reg  modeX8;

assign ack_o = cyc_i & stb_i & cs_i;
assign txd = tx_data[0];

always @(posedge clk_i)
	if (ack_o & we_i) fdo <= dat_i;

// set full / empty status
always @(posedge clk_i)
	if (rst_i) empty <= 1;
	else begin
	if (ack_o & we_i) empty <= 0;
	else if (rd) empty <= 1;
	end

`define CNT_FINISH (8'h9F)
always @(posedge clk_i)
	if (rst_i) begin
		cnt <= `CNT_FINISH;
		rd <= 0;
		tx_data <= 10'h3FF;
        txc <= 1'b1;
        modeX8 <= 1'b0;
	end
	else begin

		rd <= 0;

		if (baud16x_ce) begin

			// Load next data ?
			if (cnt==`CNT_FINISH) begin
                modeX8 <= isX8;
				if (!empty && cts) begin
					tx_data <= {1'b1,fdo,1'b0};
					rd <= 1;
                    cnt <= modeX8;
                    txc <= 1'b0;
				end
                else
                    txc <= 1'b1;
			end
			// Shift the data out. LSB first.
			else begin
                cnt[7:1] <= cnt[7:1] + cnt[0];
                cnt[0] <= ~cnt[0] | (modeX8);

                if (cnt[3:0]==4'hF)
                    tx_data <= {1'b1,tx_data[9:1]};
            end
		end
	end

endmodule

/* ============================================================================
	2011  Robert Finch
	robfinch@<remove>sympatico.ca

	rtfSimpleUartTx.v

    This source code is available for evaluation and validation purposes
    only. This copyright statement and disclaimer must remain present in
    the file.


	NO WARRANTY.
    THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
    EXPRESS OR IMPLIED. The user must assume the entire risk of using the
    Work.

    IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
    INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
    THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.

    IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
    IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
    REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
    LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
    AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
    LOSSES RELATING TO SUCH UNAUTHORIZED USE.


		Simple uart transmitter core.
		Features:
			Fixed format 1 start - 8 data - 1 stop bits


   	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|WISHBONE Datasheet
	|WISHBONE SoC Architecture Specification, Revision B.3
	|
	|Description:						Specifications:
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|General Description:				simple serial UART transmitter
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|Supported Cycles:					SLAVE,WRITE
	|									SLAVE,BLOCK WRITE
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|Data port, size:					8 bit
	|Data port, granularity:			8 bit
	|Data port, maximum operand size:	8 bit
	|Data transfer ordering:			Undefined
	|Data transfer sequencing:			Undefined
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|Clock frequency constraints:		none
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|Supported signal list and			Signal Name		WISHBONE equiv.
	|cross reference to equivalent		ack_o			ACK_O
	|WISHBONE signals					
	|									clk_i			CLK_I
	|                                   rst_i           RST_I 
	|									dat_i[7:0]		DAT_I()
	|									cyc_i			CYC_I
	|									stb_i			STB_I
	|									we_i			WE_I
	|
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|Special requirements:
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


	REF: Spartan3 - 4
	30 LUTs / 23 slices / 165MHz
============================================================================ */

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
	input cts,			// clear to send
	output txd,			// external serial output
	output reg empty	// buffer is empty
);

reg [9:0] tx_data;	// transmit data working reg (raw)
reg [7:0] fdo;		// data output
reg [7:0] cnt;		// baud clock counter
reg rd;

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


always @(posedge clk_i)
	if (rst_i) begin
		cnt <= 8'h00;
		rd <= 0;
		tx_data <= 10'h3FF;
	end
	else begin

		rd <= 0;

		if (baud16x_ce) begin

			cnt <= cnt + 1;
			// Load next data ?
			if (cnt==8'h9F) begin
				cnt <= 0;
				if (!empty && cts) begin
					tx_data <= {1'b1,fdo,1'b0};
					rd <= 1;
				end
			end
			// Shift the data out. LSB first.
			else if (cnt[3:0]==4'hF)
				tx_data <= {1'b1,tx_data[9:1]};

		end
	end

endmodule

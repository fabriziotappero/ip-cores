/* ============================================================================
	2011  Robert Finch
	robfinch@<remove>sympatico.ca

	rtfSimpleUartRx.v

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


	Simple UART receiver core
		Features:
			false start bit detection
			framing error detection
			overrun state detection
			resynchronization on every character
			fixed format 1 start - 8 data - 1 stop bits
			uses 16x clock rate
			
		This core may be used as a standalone peripheral
	on a SoC bus if all that is desired is recieve
	capability. It requires a 16x baud rate clock.
	
   	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|WISHBONE Datasheet
	|WISHBONE SoC Architecture Specification, Revision B.3
	|
	|Description:						Specifications:
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|General Description:				simple serial UART receiver
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|Supported Cycles:					SLAVE,READ
	|									SLAVE,BLOCK READ
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
	|									dat_o(7:0)		DAT_O()
	|									cyc_i			CYC_I
	|									stb_i			STB_I
	|									we_i			WE_I
	|
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	|Special requirements:
	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	Ref: Spartan3 -4
	27 LUTs / 24 slices / 170 MHz
============================================================================ */

`define IDLE	0
`define CNT		1

module rtfSimpleUartRx(
	// WISHBONE SoC bus interface
	input rst_i,			// reset
	input clk_i,			// clock
	input cyc_i,			// cycle is valid
	input stb_i,			// strobe
	output ack_o,			// data is ready
	input we_i,				// write (this signal is used to qualify reads)
	output [7:0] dat_o,		// data out
	//------------------------
	input cs_i,				// chip select
	input baud16x_ce,		// baud rate clock enable
	input clear,			// clear reciever
	input rxd,				// external serial input
	output reg data_present,	// data present in fifo
	output reg frame_err,		// framing error
	output reg overrun			// receiver overrun
);

// variables
reg [3:0] rxdd;			// synchronizer flops
reg [7:0] cnt;			// sample bit rate counter
reg [9:0] rx_data;		// working receive data register
reg state;				// state machine
reg wf;					// buffer write
reg [7:0] dat;

assign ack_o = cyc_i & stb_i & cs_i;
assign dat_o = ack_o ? dat : 8'b0;

// update data register
always @(posedge clk_i)
	if (wf) dat <= rx_data[8:1];

// on a read clear the data present status
// but set the status when the data register
// is updated by the receiver		
always @(posedge clk_i)
	if (wf) data_present <= 1;
	else if (ack_o & ~we_i) data_present <= 0;


// Three stage synchronizer to synchronize incoming data to
// the local clock (avoids metastability).
always @(posedge clk_i)
	rxdd <= {rxdd[2:0],rxd};

always @(posedge clk_i) begin
	if (rst_i) begin
		state <= `IDLE;
		wf <= 1'b0;
		overrun <= 1'b0;
	end
	else begin

		// Clear write flag
		wf <= 1'b0;

		if (clear) begin
			wf <= 1'b0;
			state <= `IDLE;
			overrun <= 1'b0;
		end

		else if (baud16x_ce) begin

			case (state)

			// Sit in the idle state until a start bit is
			// detected.
			`IDLE:
				// look for start bit
				if (~rxdd[3])
					state <= `CNT;

			`CNT:
				begin
					// End of the frame ?
					// - check for framing error
					// - write data to read buffer
					if (cnt==8'h97)
						begin	
							frame_err <= ~rxdd[3];
							if (!data_present)
								wf <= 1'b1;
							else
								overrun <= 1'b1;
						end
					// Switch back to the idle state a little
					// bit too soon.
					if (cnt==8'h9D)
						state <= `IDLE;

					// On start bit check make sure the start
					// bit is low, otherwise go back to the
					// idle state because it's a false start.
					if (cnt==8'h07 && rxdd[3])
						state <= `IDLE;

					if (cnt[3:0]==4'h7)
						rx_data <= {rxdd[3],rx_data[9:1]};
				end

			endcase
		end
	end
end


// bit rate counter
always @(posedge clk_i)
	if (baud16x_ce) begin
		if (state == `IDLE)
			cnt <= 0;
		else
			cnt <= cnt + 1;
	end

endmodule


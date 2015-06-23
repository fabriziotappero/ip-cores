// ============================================================================
//	(C) 2011,2013  Robert Finch
//  All rights reserved.
//	robfinch@<remove>finitron.ca
//
//	rtfSimpleUartRx.v
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
//	Simple UART receiver core
//		Features:
//			false start bit detection
//			framing error detection
//			overrun state detection
//			resynchronization on every character
//			fixed format 1 start - 8 data - 1 stop bits
//			uses 16x clock rate
//			
//		This core may be used as a standalone peripheral
//	on a SoC bus if all that is desired is recieve
//	capability. It requires a 16x baud rate clock.
//	
//   	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|WISHBONE Datasheet
//	|WISHBONE SoC Architecture Specification, Revision B.3
//	|
//	|Description:						Specifications:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|General Description:				simple serial UART receiver
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported Cycles:					SLAVE,READ
//	|									SLAVE,BLOCK READ
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Data port, size:					8 bit
//	|Data port, granularity:			8 bit
//	|Data port, maximum operand size:	8 bit
//	|Data transfer ordering:			Undefined
//	|Data transfer sequencing:			Undefined
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Clock frequency constraints:		none
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Supported signal list and			Signal Name		WISHBONE equiv.
//	|cross reference to equivalent		ack_o			ACK_O
//	|WISHBONE signals					
//	|									clk_i			CLK_I
//	|                                   rst_i           RST_I
//	|									dat_o(7:0)		DAT_O()
//	|									cyc_i			CYC_I
//	|									stb_i			STB_I
//	|									we_i			WE_I
//	|
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//	|Special requirements:
//	+- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//	Ref: Spartan3 -4
//	27 LUTs / 24 slices / 170 MHz
//==============================================================================

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
    input tri0 baud8x,       // switches to mode baudX8
	input clear,			// clear reciever
	input rxd,				// external serial input
	output reg data_present,	// data present in fifo
	output reg frame_err,		// framing error
	output reg overrun			// receiver overrun
);

//0 - simple sampling at middle of symbol period
//>0 - sampling of 3 middle ticks of sumbol perion and results as majority
parameter SamplerStyle = 0;

// variables
reg [7:0] cnt;			// sample bit rate counter
reg [9:0] rx_data;		// working receive data register
reg state;				// state machine
reg wf;					// buffer write
reg [7:0] dat;

wire isX8;
buf(isX8, baud8x);
reg modeX8;

assign ack_o = cyc_i & stb_i & cs_i;
assign dat_o = ack_o ? dat : 8'b0;

// update data register
always @(posedge clk_i)
	if (wf) dat <= rx_data[8:1];

// on a read clear the data present status
// but set the status when the data register
// is updated by the receiver		
always @(posedge clk_i)
    if (rst_i)
        data_present <= 0;
    else if (wf) 
        data_present <= 1;
	else if (ack_o & ~we_i) data_present <= 0;


// Three stage synchronizer to synchronize incoming data to
// the local clock (avoids metastability).
reg [5:0] rxdd          /* synthesis ramstyle = "logic" */; // synchronizer flops
reg rxdsmp;             // majority samples
reg rdxstart;           // for majority style sample solid 3tik-wide sample
reg [1:0] rxdsum;
always @(posedge clk_i)
if (baud16x_ce) begin
	rxdd <= {rxdd[4:0],rxd};
    if (SamplerStyle == 0) begin
        rxdsmp <= rxdd[3];
        rdxstart <= rxdd[4]&~rxdd[3];
    end
    else begin
        rxdsum[1] <= rxdsum[0];
        rxdsum[0] <= {1'b0,rxdd[3]} + {1'b0,rxdd[4]} + {1'b0,rxdd[5]};
        rxdsmp <= rxdsum[1];
        rdxstart <= (rxdsum[0] == 2'b00) & ((rxdsum[1] == 2'b11));
    end
end


`define CNT_FRAME  (8'h97)
`define CNT_FINISH (8'h9D)

always @(posedge clk_i) begin
	if (rst_i) begin
		state <= `IDLE;
		wf <= 1'b0;
		overrun <= 1'b0;
        frame_err <= 1'b0;
	end
	else begin

		// Clear write flag
		wf <= 1'b0;

		if (clear) begin
			wf <= 1'b0;
			state <= `IDLE;
			overrun <= 1'b0;
            frame_err <= 1'b0;
		end

		else if (baud16x_ce) begin

			case (state)

			// Sit in the idle state until a start bit is
			// detected.
			`IDLE:
				// look for start bit
				if (rdxstart)
					state <= `CNT;

			`CNT:
				begin
					// End of the frame ?
					// - check for framing error
					// - write data to read buffer
					if (cnt==`CNT_FRAME)
						begin	
							frame_err <= ~rxdsmp;
                            overrun <= data_present;
							if (!data_present)
								wf <= 1'b1;
                            state <= `IDLE;
						end
					// Switch back to the idle state a little
					// bit too soon.
					//if (cnt==`CNT_FINISH) begin
					//	state <= `IDLE;
                    //end

					// On start bit check make sure the start
					// bit is low, otherwise go back to the
					// idle state because it's a false start.
					if (cnt==8'h07 && rxdsmp)
						state <= `IDLE;

					if (cnt[3:0]==4'h7)
						rx_data <= {rxdsmp,rx_data[9:1]};
				end

			endcase
		end
	end
end


// bit rate counter
always @(posedge clk_i)
	if (baud16x_ce) begin
		if (state == `IDLE) begin
			cnt <= modeX8;
            modeX8 <= isX8;
        end
        else begin
            cnt[7:1] <= cnt[7:1] + cnt[0];
            cnt[0] <= ~cnt[0] | (modeX8);
        end
	end

endmodule


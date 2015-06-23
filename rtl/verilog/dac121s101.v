//=============================================================================
//  dac121s101
//  - DAC (digital to analogue) converter interface core
//
//
//	2010 Robert T Finch
//	robfinch<remove>@FPGAfield.ca
//
//
//	This source code is available only for veiwing, testing and evaluation
//	purposes. Any commercial use requires a license. This copyright
//	statement and disclaimer must remain present in the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//	EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//	Work.
//
//	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//	IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//	REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//	LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//	AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//	LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//  Webpack 9.2i xc3s1200e 4fg320
//  38 slices / 71 LUTs / 183.824 MHz
//  36 ff's
//
//=============================================================================

module dac121s101(rst_i, clk_i, cyc_i, stb_i, ack_o, we_i, dat_i, sclk, sync, d);
parameter pClkFreq=60000000;
parameter pPrescale=pClkFreq/50000000 + 1;	//2x freq
// states
parameter IDLE=4'd0;
parameter LOAD=4'd1;
parameter SHIFT=4'd2;
parameter TERM=4'd3;

// SYSCON
input rst_i;
input clk_i;

input cyc_i;
input stb_i;
input we_i;
output ack_o;
input [15:0] dat_i;

output sclk;
output sync;
output d;

// Registered outputs
reg sclk;
reg sync;

reg [1:0] state;
reg pe_sclk;
reg [7:0] ps_cnt;	// prescale counter
reg [3:0] cnt;		// shift bit counter
reg [15:0] dd;
reg ack;

assign ack_o = cyc_i & stb_i & ack;


// Prescale the system clock
// The DAC has a max clock frequency of 30MHz.
//
always @(posedge clk_i)
if (rst_i) begin
	ps_cnt <= 8'd1;
	sclk <= 1'b0;
	pe_sclk <= 1'b0;
end
else begin
	pe_sclk <= 1'b0;
	if (ps_cnt==pPrescale) begin
		ps_cnt <= 8'd1;
		sclk <= !sclk;
		pe_sclk <= sclk==1'b0;
	end
	else
		ps_cnt <= ps_cnt + 8'd1;
end


always @(posedge clk_i)
if (rst_i) begin
	ack <= 1'b0;
	sync <= 1'b1;
	dd <= 16'h0000;
	cnt <= 4'd0;
	state <= IDLE;
end
else begin

	if (!cyc_i || !stb_i)
		ack <= 1'b0;

	case(state)
	IDLE:
		if (cyc_i & stb_i & we_i) begin
			state <= LOAD;
			dd[11:0] <= dat_i[13:0];
			dd[15:12] <= 4'b0000;
			ack <= 1'b1;
		end
	LOAD:
		if (pe_sclk) begin
			sync <= 1'b0;
			cnt <= 4'd0;
			state <= SHIFT;
		end
	SHIFT:
		if (pe_sclk) begin
			dd <= {dd[14:0],1'b0};
			cnt <= cnt + 4'd1;
			if (cnt==4'd15)
				state <= TERM;
		end
	TERM:
		if (pe_sclk) begin
			sync <= 1'b1;
			state <= IDLE;
		end
	default:
		state <= IDLE;
	endcase
end

assign d = dd[15];

endmodule

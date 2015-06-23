`include "irda_defines.v"
module irda_sir_encoder (clk, wb_rst_i, fast_mode, fast_enable, sir_enc_o, stx_pad_o, tx_select);
// The encoder encoder in normal power mode (not low power).
// The fast_enable signal should work 
input		clk;
input		wb_rst_i;
input		fast_mode;
input		fast_enable;
input		tx_select;
input		stx_pad_o;

output	sir_enc_o;

reg	[3:0] cnt16;
reg			latch;
reg			sir_enc_o;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		cnt16 <= #1 0;
		latch <= #1 0;
		sir_enc_o <= #1 0;
	end else if (fast_mode) begin
		cnt16 <= #1 0;
		latch <= #1 0;
		sir_enc_o <= #1 0;
	end else if (tx_select && fast_enable) begin
		cnt16 <= #1 cnt16 + 1;
		if (cnt16==0)
			latch <= #1 stx_pad_o;
		case (cnt16)
			8,9,10 : sir_enc_o <= #1 latch ? 0 : 1; // high on '0', low on '1'
			default : sir_enc_o <= #1 0;
		endcase				
	end
end

endmodule

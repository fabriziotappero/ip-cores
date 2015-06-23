`include "irda_defines.v"
module irda_sir_decoder (clk, wb_rst_i, rx_pad_i, negate_rx, fast_enable, sir_dec_o, tx_select, fast_mode);

input		clk;
input		wb_rst_i;
input		rx_pad_i;
input		negate_rx;
input		fast_enable;
input		tx_select;
input		fast_mode;

output	sir_dec_o;
reg		sir_dec_o;

reg	[3:0] cnt16;
reg		zero;

wire 		rx_i = rx_pad_i ^ negate_rx;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		zero 			 <= #1 0;
		cnt16 		 <= #1 0;
		sir_dec_o 	 <= #1 1;
	end else if (fast_mode) begin
		zero 			 <= #1 0;
		cnt16 		 <= #1 0;
		sir_dec_o 	 <= #1 1;
	end else if (~tx_select && fast_enable) begin
		cnt16 <= #1 cnt16 + 1;
		if (cnt16==15)	begin
			sir_dec_o 	 <= #1 ~zero;
			zero 			 <= #1 0;
		end else
		  zero <= #1 zero | rx_i;
	end
end


endmodule

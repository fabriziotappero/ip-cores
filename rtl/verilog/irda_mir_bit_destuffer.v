`include "irda_defines.v"
module irda_mir_bit_destuffer (clk, wb_rst_i, bds_i, bds_restart, mir_rxbit_enable, std_is_good_bit,
		bds_is_data_bit, bds_o);
	
input			clk;
input			wb_rst_i;
input			bds_i;			// the input bit from ST detector
input			bds_restart;	// restart signal for bds logic
input			mir_rxbit_enable;
input			std_is_good_bit; // is the bit on bds_i a new data bit?

output		bds_is_data_bit; // is the bit on bds_o is the new data bit
output		bds_o;				// destuffeed output

reg	[2:0]	ones_counter;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ones_counter <= #1 0;
	else
	if (bds_restart)
		ones_counter <= #1 0;
	else if (mir_rxbit_enable) begin
		if (! bds_i)
			ones_counter <= #1 0;
		else
		if (std_is_good_bit)
			ones_counter <= #1 ones_counter + 1;
	end
end

// bds_is_data_bit output
assign bds_is_data_bit = (ones_counter != 5);

// module output is passed without additional logic from the input
// the the level should check bds_is_data_bit for masking
assign bds_o = bds_i;

endmodule

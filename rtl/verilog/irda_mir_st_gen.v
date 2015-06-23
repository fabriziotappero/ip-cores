`include "irda_defines.v"
module irda_mir_st_gen (clk, wb_rst_i, st_restart, st_shift, mir_txbit_enable, st_out);
input			clk;
input			wb_rst_i;
input			st_restart;	// restart the generator
input			st_shift;	// move to next bit
input			mir_txbit_enable;
output		st_out;

reg		[2:0]	st_state;
reg				st_out;

// STA (start) and STO (stop) sequence signal generator
// The sequence is 8'b01111110

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		st_state <= #1 0;
	else
	if (mir_txbit_enable)
		if (st_restart)
			st_state <= #1 0;
		else
		if (st_shift)
			st_state <= #1 st_state + 1;
end

always @(st_state)
	case (st_state)
		3'd0, 3'd7							: st_out <= #1 0;
		3'd1,3'd2,3'd3,3'd4,3'd5,3'd6	: st_out <= #1 1;
	endcase

endmodule

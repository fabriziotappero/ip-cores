`include "irda_defines.v"
module irda_mir_decoder (clk, wb_rst_i, fast_enable, mir_mode, tx_select, rx_pad_i, negate_rx, mir_dec_o);

input		clk;
input		wb_rst_i;
input		fast_enable;
input		mir_mode;
input		tx_select;
input		negate_rx;
input		rx_pad_i;

output	mir_dec_o;
reg		mir_dec_o;

// the FSM

parameter st0=0, st1=1, st2=2, st3=3;
reg	[1:0] state;
reg	zero; // zero output (a high condition was encountered in the four bits)

wire 	rx_i = rx_pad_i ^ negate_rx;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		zero <= #1 0;
		state <= #1 st0;
		mir_dec_o <= #1 0;
	end else if (mir_mode && ~tx_select && fast_enable) begin
		case (state)
			st0 : begin 
						zero <= #1 zero | rx_i; 
						state <= #1 st1;
					end
			st1 : begin
						zero <= #1 zero | rx_i;
						state <= #1 st2;
					end
			st2 : begin
						zero <= #1 zero | rx_i;
						state <= #1 st3;
					end
			st3 : begin
						mir_dec_o <= #1 ! (zero | rx_i);
						zero <= #1 0;
						state <= #1 st0;
					end
		endcase
	end
end

endmodule

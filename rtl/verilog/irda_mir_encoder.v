`include "irda_defines.v"
module irda_mir_encoder (clk, wb_rst_i, mir_tx_o, mir_mode, mir_tx_encoded_o, fast_enable, tx_select);

input			clk;
input			wb_rst_i;
input			mir_tx_o;
input			fast_enable;
input			mir_mode;
input			tx_select;
output		mir_tx_encoded_o;

reg			mir_tx_encoded_o;

reg			latch;

// Bit encoder FSM
// there are 4 phases in each bit
// on the third phase the bit is determined by high state for logic '0' and low for '1'

parameter st0=0, st1=1, st2=2, st3=3;
reg	[1:0]	state;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		latch <= #1 0;
		mir_tx_encoded_o <= #1 0;
		state <= #1 st0;
	end else if (mir_mode && tx_select && fast_enable) begin
		case (state)
			st0 : 
				begin
					latch <= #1 mir_tx_o;
					state <= #1 st1;
					mir_tx_encoded_o <= #1 0;
				end
			st1 :
				begin
					state <= #1 st2;
					mir_tx_encoded_o <= #1 0;
				end
			st2 :
				begin
					state <= #1 st3;
					mir_tx_encoded_o <= #1 latch ? 0 : 1;
				end
			st3 :
				begin
					state <= #1 st0;
					mir_tx_encoded_o <= #1 0;
				end
		endcase
	end
end

endmodule

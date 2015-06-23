`include "irda_defines.v"
module irda_mir_break_det (clk, wb_rst_i, mir_rxbit_enable, rx_i, brd_o);
// break (brd_o) is asserted when count of 7 consequitive '1' is reached

input		clk;
input		wb_rst_i;
input		mir_rxbit_enable;
input		rx_i;  // input stream

output	brd_o;  // when break is detected the brd_o signal is asserted for one clock

reg		brd_o;
//reg		break_detected; // internal flag

reg	[2:0] counter8;

// FSM parameters and registers
parameter st_no_break = 0, st_break_detected = 1, st_break_hold = 2;
reg [1:0] break_state;
reg [1:0] next_state;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		counter8 <= #1 0;
	end else if (mir_rxbit_enable) begin
		if (rx_i == 0) begin  // no break
			counter8 <= #1 0;
		end else
			counter8 <= #1 counter8 + 1;
	end
end
	
// break detector FSM
always @(posedge clk or posedge wb_rst_i)
	if (wb_rst_i)
		break_state <= #1 st_no_break;
	else if (mir_rxbit_enable)
		break_state <= #1 next_state;


always @(break_state or counter8 or rx_i)
	case (break_state)
		st_no_break			:	if ((counter8 == 7) /*&& (rx_i == 1)*/)
										next_state <= #1 st_break_detected;
		st_break_detected :	next_state <= #1 st_break_hold;
		st_break_hold		:	if (rx_i == 0)
										next_state <= #1 st_no_break;
		default : next_state <= #1 st_no_break;
	endcase

// brd_o is asserted for one clock when state is st_break_detected
always @(break_state)
	case (break_state)
		st_break_detected : brd_o <= #1 1;
		default : brd_o <= #1 0;
	endcase
	
endmodule

`include "irda_defines.v"
module irda_fir_bit_sync (clk, wb_rst_i, bs_restart, rx_i, fast_enable, fir_rx4_enable, fir_rx8_enable, bs_o);
// synchronizes to bit level. the 40Mhz clock is used to sample on the third clock of each bit
// syncronyzation starts on bs_restart

input		clk;
input		wb_rst_i;
input		bs_restart;
input		rx_i;		// input from the led
input		fast_enable; // 40Mhz clock
input 	fir_rx4_enable;
input 	fir_rx8_enable;

output	bs_o;	// bit output

//reg		bs_o; // synchronised to 4Mhz clock output
reg 		bs_o_tmp; // temporary register for non-syncronised to 4Mhz signal

// Bit synchronizer FSM

parameter st0=0, st1=1, st2=2, st3=3, st4=4, st5=5, st6=6, st7=7, st8=8, st9=9;

reg	[3:0]	state;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		state 		<= #1 st0;
		bs_o_tmp 	<= #1 0;
	end else if (bs_restart) begin
		state 	<= #1 st0;
		bs_o_tmp	<= #1 0;
	end else if (fast_enable) begin
	case (state)
		st0 : if (rx_i==0) state <= #1 st1;
		st1 : if (rx_i==1) state <= #1 st2;
		st2 : if (rx_i==1) state <= #1 st3; else state <= #1 st0;
		st3 : if (rx_i==1) begin
					state		<= #1 st4;
					bs_o_tmp <= #1 1;
				end else
					state <= #1 st0;
		st4 : state <= #1 st5;
		st5 : state <= #1 st6;
		st6 : state <= #1 st7;
		st7 : state <= #1 st8;
		st8 : begin
					state		<= #1 st9;
					bs_o_tmp <= #1 rx_i;
				end
		st9 : state <= #1 st5;
		default :
			state <= #1 st0;
	endcase
	end
end

reg phase; // rx4 clock phase (1 - this rx8 had rx4 asserted, 0 - there was only rx8)

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		phase <= #1 0;
	else if (fir_rx8_enable)
		if (fir_rx4_enable)
			phase <= #1 1;
		else
			phase <= #1 0;
end

// delay bs_o_tmp for one rx8 clock
reg	bs_o_tmp_delayed;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		bs_o_tmp_delayed <= #1 0;
	else if (fir_rx8_enable)
		bs_o_tmp_delayed <= #1 bs_o_tmp;
end

/// decide if to work with delayed signal or not 
reg	work_delayed;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		work_delayed<= #1 0;
	else if (fast_enable)
		 if ( (state == st3) && (rx_i== 1) )
			 if (phase) // first bit is not in sync with rx4
				 work_delayed <= #1 1;
			 else
				 work_delayed <= #1 0;
end


assign bs_o = work_delayed ? bs_o_tmp_delayed : bs_o_tmp ;		

endmodule

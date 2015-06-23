`include "irda_defines.v"
module  irda_mir_bit_stuffer (clk, wb_rst_i, bs_restart, 
										// stuffer_shift_i,
										stuffer_i, mir_txbit_enable,
										shift_req_o, stuffer_o);

input 		clk;
input 		wb_rst_i;
input 		bs_restart;
//input		stuffer_shift_i;
input 		stuffer_i;
input 		mir_txbit_enable;
output 		shift_req_o;
output 		stuffer_o;

reg [2:0] 	counter;
reg 			shift_req_o;
reg 			insert_zero;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		shift_req_o <= #1 0;
		counter <= #1 0;
		insert_zero <= #1 0;
	end else
	  if (mir_txbit_enable)
		 if (bs_restart) begin
			 shift_req_o <= #1 0;
			 counter <= #1 0;
			 insert_zero <= #1 0;
		 end else	begin
			 //			if (stuffer_shift_i)
			 if (stuffer_o==1)
				if (counter==4) begin
					counter <= #1 0;
					insert_zero <= #1 1;
					shift_req_o <= #1 0;
				end else begin // input is 1 but count of 5 is not reached yet
					counter <= #1 counter + 1;
					shift_req_o <= #1 1;
					insert_zero <= #1 0;
				end
			 else begin // input is 0 - reset counter
				 counter <= #1 0;
				 shift_req_o <= #1 1;
				 insert_zero <= #1 0;
			 end
			 //			else begin // stuffer_shift_i == 0
			 //				shift_req_o <= #1 0;
			 //			end
		 end
end

assign stuffer_o = insert_zero ? 0 : stuffer_i;

endmodule

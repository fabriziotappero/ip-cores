`include "irda_defines.v"
module irda_sip_gen (clk, wb_rst_i, mir_sip_o, fir_sip_o, sip_end_i, sip_gen_o);

parameter 	 high_clocks=320;
parameter 	 low_clocks=1420;
parameter 	 sip_end_clocks=200; // 1 us

input 		 clk;
input 		 wb_rst_i;
input 		 mir_sip_o;		// mir mode sip request
input 		 fir_sip_o;		// fir mode sip request
output 		 sip_end_i;	// end of sip generation signal
output 		 sip_gen_o;  // the SIP signal output

reg 			 sip_end_i;
reg 			 sip_gen_o;

reg [10:0] 	 sip_counter;
reg 			 sip_delay;

wire 			 sip_req; // request for SIP after rise detection
wire 			 sip_o = mir_sip_o | fir_sip_o;
// rise detection for sip_o input
always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i)
		sip_delay <= #1 0;
	else
		sip_delay <= #1 ~sip_o;
end

assign sip_req = sip_delay & sip_o;

reg	[1:0]	state;

parameter st_idle=0, st_high=1, st_low=2, st_send_end=3;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		sip_end_i 		<= #1 0;
		sip_counter 	<= #1 0;
		sip_gen_o 		<= #1 0;
		state 			<= #1 st_idle;
	end else if (sip_req) begin /// start the SIP 
		state 			<= #1 st_high; // Enter high state
		sip_counter 	<= #1 high_clocks; 
	end else
	case (state)
		st_idle :
			begin
				sip_end_i <= #1 0;
				sip_gen_o <= #1 0;
			end
		st_high :
			begin
				sip_gen_o <= #1 1;
				if (sip_counter != 0)
					sip_counter <= #1 sip_counter - 1;
				else begin
					state 			<= #1 st_low;
					sip_counter 	<= #1 low_clocks;
				end
			end
		st_low :
			begin
				sip_gen_o <= #1 0;
				if (sip_counter != 0)
					sip_counter <= #1 sip_counter - 1;
				else begin
					state 			<= #1 st_send_end;
					sip_end_i 		<= #1 1;
					sip_counter 	<= #1 sip_end_clocks;
				end
			end
		st_send_end :
			begin
				sip_gen_o <= #1 0;
				if (sip_counter != 0)
					sip_counter <= #1 sip_counter - 1;
				else begin
					state 			<= #1 st_idle;
					sip_end_i 		<= #1 0;
					sip_counter 	<= #1 0;
				end
			end
		default :
			state <= #1 st_idle;
	endcase

end

endmodule

`include "irda_defines.v"
module irda_fir_4ppm_encoder (clk, wb_rst_i, ppm_restart, fir_tx8_enable, 
		 txdout, ppm_o);

input		clk;
input		wb_rst_i;
input		ppm_restart;
input		fir_tx8_enable;
input		txdout; // input to the module is output from the CRC module

output	ppm_o;

reg			ppm_o;


reg	buffer;
reg	[1:0] dbp;
reg	[2:0]	ppm_state;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		buffer <= #1 0;
		dbp <= #1 0;
		ppm_state <= #1 0;
		ppm_o <= #1 0;
	end else if (fir_tx8_enable) begin
		if (ppm_restart) begin
			buffer <= #1 txdout;
			ppm_state <= #1 1;
		end else
		case (ppm_state)
			0:	ppm_o <= #1 0; // comes here after reset and out only on ppm_restart
			1: ppm_state <= #1 2;
			2: begin
					ppm_state <= #1 3;
					dbp <= #1 {txdout, buffer};
					case ({txdout, buffer})
						2'b00 : ppm_o <= #1 1; 
						default : ppm_o <= #1 0;
					endcase
				end
			3: begin
					ppm_state <= #1 4;
					case (dbp)
						2'b01 :ppm_o <= #1 1; 
						default : ppm_o <= #1 0;
					endcase
				end
			4: begin
					ppm_state <= #1 5;
					buffer <= #1 txdout;
					case (dbp)
						2'b10 :ppm_o <= #1 1; 
						default : ppm_o <= #1 0;
					endcase
				end
			5: begin
					ppm_state <= #1 2;
					case (dbp)
						2'b11 :ppm_o <= #1 1; 
						default : ppm_o <= #1 0;
					endcase
				end
			default : ppm_state <= #1 0;
		endcase
	end
end
endmodule


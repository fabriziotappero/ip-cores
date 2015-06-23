`include "irda_defines.v"
module irda_fir_4ppm_decoder (clk, wb_rst_i, fir_rx8_enable, ppmd_restart,
				fd_o, fd_data_bit, ppmd_o, ppmd_bad_chip);
input		clk;
input		wb_rst_i;
input		ppmd_restart;
input		fir_rx8_enable;
input		fd_o;
input 	fd_data_bit;

output	ppmd_o;
output	ppmd_bad_chip;

reg	[2:0]	in_buffer;
reg			out_buffer;
reg			ppmd_o;
reg			ppmd_bad_chip;

reg	[1:0] dbp; // decoded signal
always @(in_buffer or fd_o)
	case ( {in_buffer, fd_o} )
		4'b1000 : dbp = 2'b00;
		4'b0100 : dbp = 2'b01;
		4'b0010 : dbp = 2'b10;
		4'b0001 : dbp = 2'b11;
		default : dbp = 2'b00;
	endcase // case( {in_buffer, fd_o} )

reg 			ppmd_bad_chip_tmp;
always @(in_buffer or fd_o)
	case ( {in_buffer, fd_o} )
		4'b1000,	4'b0100, 
		4'b0010, 4'b0001 : ppmd_bad_chip_tmp = 0;
		default : ppmd_bad_chip_tmp = 1;
	endcase // case( {in_buffer, fd_o} )

reg [1:0] 	state;

always @(posedge clk or posedge wb_rst_i)
begin
	if (wb_rst_i) begin
		ppmd_o <= #1 0;
		out_buffer <= #1 0;
		in_buffer <= #1 0;
		ppmd_bad_chip <= #1 0;
		state <= #1 0;
	end else if (fd_data_bit) begin
		if (ppmd_restart) begin
			state 			  <= #1 1;
			out_buffer 		  <= #1 0;
			in_buffer[2] 	  <= #1 fd_o;
			ppmd_bad_chip 	  <= #1 0;
			ppmd_o 			  <= #1 0;
		end else	if (fir_rx8_enable) begin
			case (state) 
				0: begin
					state 			  <= #1 1;
					in_buffer[2] 	  <= #1 fd_o;
				end
				1: begin
					state <= #1 2;
					ppmd_o <= #1 out_buffer;
					in_buffer[1] <= #1 fd_o;
				end
				2: begin
					state <= #1 3;
					in_buffer[0] <= #1 fd_o;
				end
				3: begin
					ppmd_o <= #1 dbp[0];
					out_buffer <= #1 dbp[1];
					state <= #1 0;
					ppmd_bad_chip <= #1 ppmd_bad_chip_tmp;
				end
				default: state <= #1 0;
			endcase // case(state)
		end // if (fir_rx8_enable)
	end // if (fd_data_bit)
end // always @ (posedge clk or posedge wb_rst_i)


endmodule // irda_fir_4ppm_decoder

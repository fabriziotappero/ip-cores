`include "irda_defines.v"
module irda_wb_router (
	// Inputs to the core
	fast_mode, wb_stb_i, wb_cyc_i,  wb_we_i, wb_dat_i, wb_addr_i,
	// outputs to fast mode
	f_wb_stb_i, f_wb_cyc_i,  f_wb_we_i, f_wb_dat_i, f_wb_addr_i,
	// outputs to uart
	u_wb_stb_i, u_wb_cyc_i,  u_wb_we_i, u_wb_dat_i, u_wb_addr_i,

	// outputs from fast mode
	f_wb_ack_o, f_wb_dat_o,
	// outputs from uart
	u_wb_ack_o, u_wb_dat_o,
	// outputs to wishbone
	wb_ack_o, wb_dat_o
	);

	// Inputs to the core
input				fast_mode;
input				wb_stb_i;
input				wb_cyc_i;
input				wb_we_i;
input [31:0]	wb_dat_i;
input [3:0]		wb_addr_i;

	// outputs to fast mode
output			f_wb_stb_i;
output			f_wb_cyc_i;
output			f_wb_we_i;
output [31:0]	f_wb_dat_i;
output [3:0]	f_wb_addr_i;

	// outputs to uart
output			u_wb_stb_i;
output			u_wb_cyc_i;
output			u_wb_we_i;
output [7:0]	u_wb_dat_i;
output [2:0]	u_wb_addr_i;

	// outputs from fast mode
input				f_wb_ack_o;
input [31:0]	f_wb_dat_o;

	// outputs from uart
input				u_wb_ack_o;
input [7:0]		u_wb_dat_o;

	// outputs to wishbone
output			wb_ack_o;
output [31:0]	wb_dat_o;

//
// the mux assignments
//

	// outputs to fast mode
assign f_wb_stb_i 	= fast_mode ? wb_stb_i : 0;
assign f_wb_cyc_i 	= fast_mode ? wb_cyc_i : 0;
assign f_wb_we_i 		=  fast_mode ? wb_we_i  : 0;
assign f_wb_dat_i 	= fast_mode ? wb_dat_i : 32'b0;
assign f_wb_addr_i 	= fast_mode ? wb_addr_i : 4'b0;

	// outputs to uart
// the check for zeros is when we write into MASTER register
assign u_wb_stb_i 	= (~fast_mode) ? wb_stb_i : 0;
assign u_wb_cyc_i 	= (~fast_mode) ? wb_cyc_i : 0;
assign u_wb_we_i 		= (~fast_mode && wb_addr_i[3]==0) ? wb_we_i  : 0;
assign u_wb_dat_i 	= (~fast_mode) ? wb_dat_i : 8'b0;
assign u_wb_addr_i 	= (~fast_mode) ? wb_addr_i : 3'b0;

	// outputs to wishbone
assign wb_ack_o 		= fast_mode ? f_wb_ack_o : u_wb_ack_o;
assign wb_dat_o 		= fast_mode ? f_wb_dat_o : {24'b0, u_wb_dat_o};

endmodule

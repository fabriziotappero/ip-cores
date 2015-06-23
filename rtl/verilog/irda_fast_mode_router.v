`include "irda_defines.v"
  
module irda_fast_mode_router (/*AUTOARG*/
// Outputs
rxfifo_add, f_ifdlr, rxfifo_dat_i, 
// Inputs
fir_mode, fir_rxfifo_add, mir_rxfifo_add, fir_ifdlr_o, mir_ifdlr_o, 
fir_rxfifo_dat_i, mir_rxfifo_dat_i
) ;

input 								fir_mode;

input 								fir_rxfifo_add;
input 								mir_rxfifo_add;
output 								rxfifo_add;

input [15:0] 						fir_ifdlr_o;
input [15:0] 						mir_ifdlr_o;
output [15:0] 						f_ifdlr;

input [`IRDA_FIFO_WIDTH-1:0] 	fir_rxfifo_dat_i;
input [`IRDA_FIFO_WIDTH-1:0] 	mir_rxfifo_dat_i;
output [`IRDA_FIFO_WIDTH-1:0] rxfifo_dat_i;

wire [`IRDA_FIFO_WIDTH-1:0] 	fir_rxfifo_dat_i;
wire [`IRDA_FIFO_WIDTH-1:0] 	mir_rxfifo_dat_i;
wire [`IRDA_FIFO_WIDTH-1:0] 	rxfifo_dat_i;

wire [15:0] 						fir_ifdlr_o;
wire [15:0] 						mir_ifdlr_o;
wire [15:0] 						f_ifdlr;

assign 								rxfifo_add 		= fir_mode ? fir_rxfifo_add 	  : mir_rxfifo_add;
assign 								f_ifdlr 			= fir_mode ? fir_ifdlr_o 		  : mir_ifdlr_o;
assign 								rxfifo_dat_i 	= fir_mode ? fir_rxfifo_dat_i   : mir_rxfifo_dat_i;

endmodule

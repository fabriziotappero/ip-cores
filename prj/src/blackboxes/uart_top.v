

`include "uart_defines.v"

module uart_top	(
	wb_clk_i, 
	
	// Wishbone signals
	wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_sel_i,
	int_o, // interrupt request

	// UART	signals
	// serial input/output
	stx_pad_o, srx_pad_i,

	// modem signals
	rts_pad_o, cts_pad_i, dtr_pad_o, dsr_pad_i, ri_pad_i, dcd_pad_i
`ifdef UART_HAS_BAUDRATE_OUTPUT
	, baud_o
`endif
	);

parameter 							 uart_data_width = `UART_DATA_WIDTH;
parameter 							 uart_addr_width = `UART_ADDR_WIDTH;

input 								 wb_clk_i;

// WISHBONE interface
input 								 wb_rst_i;
input [uart_addr_width-1:0] 	 wb_adr_i;
input [uart_data_width-1:0] 	 wb_dat_i;
output [uart_data_width-1:0] 	 wb_dat_o;
input 								 wb_we_i;
input 								 wb_stb_i;
input 								 wb_cyc_i;
input [3:0]							 wb_sel_i;
output 								 wb_ack_o;
output 								 int_o;

// UART	signals
input 								 srx_pad_i;
output 								 stx_pad_o;
output 								 rts_pad_o;
input 								 cts_pad_i;
output 								 dtr_pad_o;
input 								 dsr_pad_i;
input 								 ri_pad_i;
input 								 dcd_pad_i;

// optional baudrate output
`ifdef UART_HAS_BAUDRATE_OUTPUT
output	baud_o;
`endif


endmodule



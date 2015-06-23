`include "irda_defines.v"
`include "timescale.v"

module irda_top_sir_only (wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o,
	wb_we_i, wb_stb_i, wb_cyc_i,
	wb_ack_o, int_o,	tx_pad_o, rx_pad_i);

parameter 							irda_addr_width = 4;
parameter 							irda_data_width = 8;

input 								wb_clk_i;
input 								wb_rst_i;
input [irda_addr_width-1:0] 	wb_adr_i;
input [irda_data_width-1:0] 	wb_dat_i;
output [irda_data_width-1:0] 	wb_dat_o;
input 								wb_we_i;
input 								wb_stb_i;
input 								wb_cyc_i;
output 								wb_ack_o;
output 								int_o;
output 								tx_pad_o;
input 								rx_pad_i;

wire [7:0] 						wb_dat_i;
wire [7:0] 						wb_dat_o;
wire [3:0] 							wb_adr_i;

wire [7:1] 							master;

// Master Control Register
irda_master_register master_reg(/*AUTOINST*/
										  // Outputs
										  .master (master[7:1]),
										  .mir_mode(),
										  .mir_half(),
										  .fir_mode(),
										  .fast_mode(),
										  .tx_select(tx_select),
										  .loopback_enable(),
										  .use_dma(),
										  .negate_tx(negate_tx),
										  .negate_rx(negate_rx),
										  // Inputs
										  .wb_clk_i(wb_clk_i),
										  .wb_rst_i(wb_rst_i),
										  .wb_adr_i(wb_adr_i[3:0]),
										  .wb_dat_i(wb_dat_i[7:1]),
										  .wb_we_i(wb_we_i),
										  .wb_stb_i(wb_stb_i),
										  .wb_cyc_i(wb_cyc_i));

// UART module

uart_top	uart(
		.wb_clk_i(		wb_clk_i	),
		.wb_rst_i(		wb_rst_i	),
		.wb_adr_i(		wb_adr_i),
		.wb_dat_i(		wb_dat_i	),
		.wb_dat_o(		wb_dat_o	),
		.wb_sel_i(4'b0),
		.wb_we_i(		wb_we_i	),
		.wb_stb_i(		wb_stb_i	),
		.wb_cyc_i(		wb_cyc_i ),
		.wb_ack_o(		wb_ack_o	),
		.int_o(			int_o		),
		.stx_pad_o(		stx_pad_o),
		.srx_pad_i(		srx_pad_i),
		.rts_pad_o(	  ),
		.cts_pad_i(	  ),
		.dtr_pad_o(	  ),     // not needed in IrDA
		.dsr_pad_i(	  ),
		.ri_pad_i(	  ),
		.dcd_pad_i(	  ),
		.baud_o(baud_o)
	);

// SIR mode bit encoder
irda_sir_encoder sir_enc(
		.clk(				wb_clk_i			),
		.wb_rst_i(		wb_rst_i		),
		.fast_mode(		1'b0	),
		.fast_enable(	baud_o	),
		.sir_enc_o(		sir_enc_o	),
		.tx_select(		tx_select	),
		.stx_pad_o(		stx_pad_o	)
	);

// SIR mode bit decoder
irda_sir_decoder sir_dec(
		.clk(				wb_clk_i		),
		.wb_rst_i(		wb_rst_i		),
		.rx_pad_i(		rx_pad_i		),
		.negate_rx(		negate_rx	),
		.fast_enable(	baud_o	), // from UART
		.sir_dec_o(		srx_pad_i	),
		.tx_select(		tx_select	),
		.fast_mode(		1'b0	)
	);

// output mux
irda_out_mux out_mux(
		.clk(				wb_clk_i			), 
		.wb_rst_i(		wb_rst_i		), 
		.sir_enc_o(		sir_enc_o	),
		.mir_enc_o(		1'b0),
		.fir_tx_o(		1'b0		),
		.sip_gen_o(		1'b0	), 
		.fast_mode(		1'b0	),
		.tx_select(		tx_select	), 
		.mir_mode(		1'b0		),
		.negate_tx(		negate_tx	),
		.tx_pad_o(		tx_pad_o		)
	);

endmodule

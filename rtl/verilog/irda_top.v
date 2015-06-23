`include "irda_defines.v"
`include "timescale.v"

module irda_top (wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i,
	wb_ack_o, int_o, dma_req_t_o, dma_ack_t_i, dma_req_r_o, dma_ack_r_i,
	tx_pad_o, rx_pad_i);

parameter 							irda_addr_width = 4;
parameter 							irda_data_width = 32;

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
output 								dma_req_t_o;  // request to fill transmitter
input 								dma_ack_t_i;
output 								dma_req_r_o;  // request to empty receiver
input 								dma_ack_r_i;
output 								tx_pad_o;
input 								rx_pad_i;

wire [31:0] 						wb_dat_i;
wire [31:0] 						f_wb_dat_i;
wire [7:0] 							u_wb_dat_i;
wire [31:0] 						wb_dat_o;
wire [31:0] 						f_wb_dat_o;
wire [7:0] 							u_wb_dat_o;
wire [3:0] 							wb_adr_i;
wire [3:0] 							f_wb_addr_i;
wire [2:0] 							u_wb_addr_i;

wire [7:1] 							master;
wire [6:0] 							f_ier;
wire [7:0] 							f_iir;
wire [7:0] 							f_fcr;
wire [1:0] 							f_lcr;
wire [15:0] 						f_ofdlr;
wire [15:0] 						mir_ifdlr_o;
wire [15:0] 						fir_ifdlr_o;
wire [15:0] 						f_ifdlr;
wire [`IRDA_F_CDR_WIDTH-1:0] 	f_cdr;

wire [`IRDA_FIFO_WIDTH-1:0] 	fir_rxfifo_dat_i;
wire [`IRDA_FIFO_WIDTH-1:0] 	mir_rxfifo_dat_i;
wire [`IRDA_FIFO_WIDTH-1:0] 	rxfifo_dat_i;

wire [`IRDA_FIFO_WIDTH-1:0] 	txfifo_dat_i;
wire [`IRDA_FIFO_WIDTH-1:0] 	txfifo_dat_o;
wire [`IRDA_FIFO_WIDTH-1:0] 	rxfifo_dat_o;
wire [`IRDA_FIFO_POINTER_W:0] txfifo_count;
wire [`IRDA_FIFO_POINTER_W:0] rxfifo_count;
wire [2:0] 							fir_state;
wire [2:0] 							mir_state;


// WISHBONE bus interface
irda_wb wb(
			.clk(			wb_clk_i		),
			.wb_rst_i(	wb_rst_i	),
			.wb_stb_i(	f_wb_stb_i	),
			.wb_cyc_i(	f_wb_cyc_i	),
			.wb_we_i(	f_wb_we_i	),
			.wb_ack_o(	f_wb_ack_o	),
			.we_i(		we_i			),
			.re_i(		re_i			)
		);

// Master Control Register
irda_master_register master_reg(/*AUTOINST*/
										  // Outputs
										  .master (master[7:1]),
										  .mir_mode(mir_mode),
										  .mir_half(mir_half),
										  .fir_mode(fir_mode),
										  .fast_mode(fast_mode),
										  .tx_select(tx_select),
										  .loopback_enable(loopback_enable),
										  .use_dma(use_dma),
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

// Registers I/O
irda_reg regs(
			.clk(			wb_clk_i				),
			.wb_rst_i(	wb_rst_i	   	),
			.wb_addr_i(	f_wb_addr_i		),
			.wb_dat_i(	f_wb_dat_i		),
			.f_wb_we_i(	f_wb_we_i		),
			.f_ifdlr(	f_ifdlr			),
			.f_iir(		f_iir				),
			.rxfifo_dat_o(rxfifo_dat_o	),
			.f_ier(		f_ier				),
			.f_fcr(		f_fcr				),
			.f_lcr(		f_lcr				),
			.f_ofdlr(	f_ofdlr			),
			.f_cdr(		f_cdr				),
			.txfifo_add(txfifo_add		),
			.f_wb_dat_o(f_wb_dat_o		),
			.en_reload(	en_reload		),
			.f_iir_read(f_iir_read		),
			.rxfifo_remove(rxfifo_remove),
			.re_i(re_i)
		);

// Transmitter fifo
irda_fifo tx_fifo(
			.clk(				wb_clk_i				),
			.wb_rst_i(		wb_rst_i			),
			.fifo_clear(	f_fcr[6]			), // clear TX fifo bit
			.fifo_dat_i(	wb_dat_i			),
			.fifo_add(		txfifo_add		),
			.fifo_remove(	txfifo_remove	),
			.fifo_dat_o(	txfifo_dat_o	),
			.fifo_overrun(	txfifo_overrun	),
			.fifo_underrun(txfifo_underrun),
			.fifo_count(	txfifo_count	)
		);

// Generator of enable signals for FIR and MIR logic
irda_fast_enable_gen f_en_gen(
			.clk(					wb_clk_i				),
			.wb_rst_i(			wb_rst_i			),
			.f_cdr(				f_cdr				),
			.tx_select(			tx_select		),
			.loopback_enable(	loopback_enable),
			.en_reload(			en_reload		),
			.mir_mode(			mir_mode			),
			.mir_half(			mir_half			),
			.fir_mode(			fir_mode			),
			.mir_txbit_enable(mir_txbit_enable	),
			.mir_rxbit_enable(mir_rxbit_enable	),
			.fir_tx8_enable(	fir_tx8_enable	),
			.fir_tx4_enable(	fir_tx4_enable	),
			.fir_rx8_enable(	fir_rx8_enable	),
			.fir_rx4_enable(	fir_rx4_enable	),
			.fast_enable(		fast_enable		) // 40Mhz enable signal
		);

// MIR mode transmitter

wire count_mode = f_lcr[1];

irda_mir_tx mir_tx(
			.clk(					wb_clk_i				),
			.wb_rst_i(			wb_rst_i			),
			.mir_txbit_enable(mir_txbit_enable	),
			.count_mode(		count_mode		),
			.f_fcr(				f_fcr				),
			.f_ofdlr(			f_ofdlr			),
			.mir_tx_o(			mir_tx_o			),
			.sip_end_i(			sip_end_i		),
			.sip_o(				mir_sip_o		),
			.data_o(          data_o         ),
			.data_available(	data_available	),
			.dc_restart(		dc_restart		),
			.next_data(			next_data		)
		);

// MIR bit encoder
irda_mir_encoder mir_enc(
		.clk(					wb_clk_i					),
		.wb_rst_i(			wb_rst_i				),
		.mir_tx_o(			mir_tx_o				),
		.mir_mode(			mir_mode				),
		.mir_tx_encoded_o(mir_tx_encoded_o	), // the encoded output
		.fast_enable(		fast_enable			),
		.tx_select(			tx_select			)
	);

//	Next data bit controller for MIR/FIR modes
irda_data_ctrl d_c(
		.clk(						wb_clk_i					),
		.wb_rst_i(				wb_rst_i				),
		.dc_restart(			dc_restart			),
		.dc_restart_fir(		dc_restart_fir		),
		.next_data(				next_data			),
		.next_data_fir(		next_data_fir		),
		.txfifo_count	(		txfifo_count		),
		.txfifo_dat_o(			txfifo_dat_o		),
		.data_available(		data_available		),
		.txfifo_remove(		txfifo_remove		),
		.data_o(					data_o				),
		.mir_txbit_enable(	mir_txbit_enable	),
		.fir_tx4_enable(		fir_tx4_enable		),
		.fir_mode(				fir_mode				),
		.mir_mode(				mir_mode				)
	 );

// Receiver fifo
irda_fifo rx_fifo(
			.clk(				wb_clk_i				),
			.wb_rst_i(		wb_rst_i			),
			.fifo_clear(	f_fcr[2]			), // clear RX fifo bit
			.fifo_dat_i(	rxfifo_dat_i	),
			.fifo_add(		rxfifo_add		),
			.fifo_remove(	rxfifo_remove	),
			.fifo_dat_o(	rxfifo_dat_o	),
			.fifo_overrun(	rxfifo_overrun	),
			.fifo_underrun(rxfifo_underrun),
			.fifo_count(	rxfifo_count	)
		);

// MIR MODE RECEIVER
irda_mir_rx mir_rx(
		.clk(					wb_clk_i					),
		.wb_rst_i(			wb_rst_i				),
		.rx_i(				mir_dec_o			), // from mir_dec
		.mir_rxbit_enable(mir_rxbit_enable	),
		.mir_rx_restart(  f_fcr[2]				),
		.rxfifo_dat_i(		mir_rxfifo_dat_i	),
		.rxfifo_add(		mir_rxfifo_add		),
		.mir_crc_error(	mir_crc_error		),
		.mir_ifdlr_o (		mir_ifdlr_o 	  	),
		.mir_sto_detected(mir_sto_detected	),
		.mir_rx_error(		mir_rx_error		)
	);

// MIR bit decoder
irda_mir_decoder mir_dec(
		.clk(					wb_clk_i					),
		.wb_rst_i(			wb_rst_i				),
		.fast_enable(		fast_enable			),
		.mir_mode(			mir_mode				),
		.tx_select(			tx_select			),
		.rx_pad_i(			rx_pad_i				),
		.negate_rx(			negate_rx			),
		.mir_dec_o(			mir_dec_o			)
	);

// FIR MODE TRANSMITTER
irda_fir_tx fir_tx(
		.clk(					wb_clk_i					),
		.wb_rst_i(			wb_rst_i				),
		.fir_tx8_enable(	fir_tx8_enable		),
		.fir_tx4_enable(	fir_tx4_enable		),
		.count_mode(		count_mode			),
		.f_fcr(				f_fcr					),
		.f_ofdlr(			f_ofdlr				),
		.sip_o(				fir_sip_o			),
		.sip_end_i(			sip_end_i			),
		.fir_tx_o(			fir_tx_o				),
		.data_available(	data_available		),
		.data_o(				data_o				),
		.dc_restart_fir(	dc_restart_fir		),
		.next_data_fir(	next_data_fir		)
	);

// SIP signal generator
irda_sip_gen sip_gen(
		.clk(					wb_clk_i				),
		.wb_rst_i(			wb_rst_i				),
//		.fast_enable(		fast_enable			),
		.mir_sip_o(			mir_sip_o			),
		.fir_sip_o(			fir_sip_o			),
		.sip_end_i(			sip_end_i			),
		.sip_gen_o(			sip_gen_o			)
	);


// FIR Receiver
irda_fir_rx fir_rx(
		.clk(					wb_clk_i					),
		.wb_rst_i(			wb_rst_i				),
		.fast_enable(		fast_enable			),
		.fir_rx8_enable(	fir_rx8_enable		),
		.fir_rx_restart(	f_fcr[2]		),
		.fir_rx4_enable(	fir_rx4_enable		),
		.rx_pad_i(			rx_pad_i				),
		.negate_rx(			negate_rx			),				 
		.fir_ifdlr_o(		fir_ifdlr_o			),
		.fir_sto_detected(fir_sto_detected	),
		.crc32_error(		crc32_error			),
		.fir_rx_error(		fir_rx_error		),
		.rxfifo_dat_i(		fir_rxfifo_dat_i	),
		.rxfifo_add(		fir_rxfifo_add		)
	);

// UART module

//Uart  module is not yet well inserted into the code
uart_top	uart(
		.wb_clk_i(		wb_clk_i			),
		.wb_rst_i(		wb_rst_i		),
		.wb_adr_i(		u_wb_addr_i ),
		.wb_dat_i(		u_wb_dat_i	),
		.wb_dat_o(		u_wb_dat_o	),
		.wb_we_i(		u_wb_we_i	),
		.wb_stb_i(		u_wb_stb_i	),
		.wb_cyc_i(		u_wb_cyc_i	),
		.wb_ack_o(		u_wb_ack_o	),
		.int_o(			u_int_o		),
		.stx_pad_o(		stx_pad_o	),
		.srx_pad_i(		srx_pad_i	),
		.rts_pad_o(	  ),
		.cts_pad_i(	  ),
		.dtr_pad_o(	  ),     // not needed in IrDA
		.dsr_pad_i(	  ),
		.ri_pad_i(	  ),
		.dcd_pad_i(	  )
	);

// SIR mode bit encoder
irda_sir_encoder sir_enc(
		.clk(				wb_clk_i			),
		.wb_rst_i(		wb_rst_i		),
		.fast_mode(		fast_mode	),
		.fast_enable(	fast_enable	),
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
		.fast_enable(	fast_enable	),
		.sir_dec_o(		srx_pad_i	),
		.tx_select(		tx_select	),
		.fast_mode(		fast_mode	)
	);

// IrDA WISHBONE routing based on mode (fast/slow)
irda_wb_router wb_router(
		// Inputs to the core
		.fast_mode(			fast_mode	),
		.wb_stb_i(			wb_stb_i		),
		.wb_cyc_i(			wb_cyc_i		),
		.wb_we_i(			wb_we_i		),
		.wb_dat_i(			wb_dat_i		), //5
		.wb_addr_i(			wb_adr_i	),
		// outputs to fast mode
		.f_wb_stb_i(		f_wb_stb_i	),
		.f_wb_cyc_i(		f_wb_cyc_i	),
		.f_wb_we_i(			f_wb_we_i	),
		.f_wb_dat_i(		f_wb_dat_i	), // 10
		.f_wb_addr_i(		f_wb_addr_i	),
		// outputs to uart
		.u_wb_stb_i(		u_wb_stb_i	),
		.u_wb_cyc_i(		u_wb_cyc_i	),
		.u_wb_we_i(			u_wb_we_i	),
		.u_wb_dat_i(		u_wb_dat_i	), // 15
		.u_wb_addr_i(		u_wb_addr_i	),
		// outputs from fast mode
		.f_wb_ack_o(		f_wb_ack_o	),
		.f_wb_dat_o(		f_wb_dat_o	),
		// outputs from uart
		.u_wb_ack_o(		u_wb_ack_o	), //20
		.u_wb_dat_o(		u_wb_dat_o	),
		// outputs to wishbone
		.wb_ack_o(			wb_ack_o		),
		.wb_dat_o(			wb_dat_o		) //24
	);

// Fast mode signals router
irda_fast_mode_router fast_mode_router (/*AUTOINST*/
													 // Outputs
													 .rxfifo_add(rxfifo_add),
													 .f_ifdlr(f_ifdlr[15:0]),
													 .rxfifo_dat_i(rxfifo_dat_i[`IRDA_FIFO_WIDTH-1:0]),
													 // Inputs
													 .fir_mode(fir_mode),
													 .fir_rxfifo_add(fir_rxfifo_add),
													 .mir_rxfifo_add(mir_rxfifo_add),
													 .fir_ifdlr_o(fir_ifdlr_o[15:0]),
													 .mir_ifdlr_o(mir_ifdlr_o[15:0]),
													 .fir_rxfifo_dat_i(fir_rxfifo_dat_i[`IRDA_FIFO_WIDTH-1:0]),
													 .mir_rxfifo_dat_i(mir_rxfifo_dat_i[`IRDA_FIFO_WIDTH-1:0]));


// Interrupts subsystem
irda_interrupts ints(
		.clk(							wb_clk_i					),
		.wb_rst_i(					wb_rst_i				),
		.f_ier(						f_ier					),
		.rxfifo_trigger_level(	f_fcr[1:0]			),
		.txfifo_trigger_level(	f_fcr[5:4]			), //5
		.rxfifo_count(				rxfifo_count		),
		.u_int_o(					u_int_o				),
		.int_o(						int_o					),
		.f_iir(						f_iir					),
		.fir_sto_detected(		fir_sto_detected	), //10
		.mir_sto_detected(		mir_sto_detected	),
		.crc32_error(				crc32_error			),
		.mir_crc_error(			mir_crc_error		),
		.rxfifo_overrun(			rxfifo_overrun		),
		.rx_error(		mir_rx_error|fir_rx_error	), //15
		.txfifo_count(				txfifo_count		),
		.txfifo_underrun(			txfifo_underrun	),
		.fir_state(					fir_state			),
		.mir_state(					mir_state			),
		.mir_mode(					mir_mode				), //20
		.f_iir_read(				f_iir_read			),
		.use_dma(					use_dma				),
		.dma_req_t_o(				dma_req_t_o			),
		.dma_ack_t_i(				dma_ack_t_i			),
		.dma_req_r_o(				dma_req_r_o			), //25
		.dma_ack_r_i(				dma_ack_r_i			)
	);


// output mux
irda_out_mux out_mux(
		.clk(				wb_clk_i			), 
		.wb_rst_i(		wb_rst_i		), 
		.sir_enc_o(		sir_enc_o	),
		.mir_enc_o(		mir_tx_encoded_o),
		.fir_tx_o(		fir_tx_o		),
		.sip_gen_o(		sip_gen_o	), 
		.fast_mode(		fast_mode	),
		.tx_select(		tx_select	), 
		.mir_mode(		mir_mode		),
		.negate_tx(		negate_tx	),
		.tx_pad_o(		tx_pad_o		)
	);

endmodule

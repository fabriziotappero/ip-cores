/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

module soc_for_linux(
	input clk_i,
	input rst_i,
	
	//ssram interface
	output [18:0] ssram_address,
	output ssram_oe_n,
	output ssram_writeen_n,
	output ssram_byteen0_n,
	output ssram_byteen1_n,
	output ssram_byteen2_n,
	output ssram_byteen3_n,
	
	inout [31:0] ssram_data,
	
	output ssram_clk,
	//output ssram_mode,
	//output ssram_zz,
	output ssram_globalw_n,
	output ssram_advance_n,
	output ssram_adsp_n,
	output ssram_adsc_n,
	output ssram_ce1_n,
	output ssram_ce2,
	output ssram_ce3_n,
	
	//sd interface
	output sd_clk_o,
	inout sd_cmd_io,
	inout sd_dat_io,
	
	//serial interface
	input uart_rxd,
	input uart_rts,
	output uart_txd,
	output uart_cts,
	
	//debug
	output [5:0] sd_debug,
	output [7:0] pc_debug
);

assign pc_debug = 8'd0;

/*
MASTER ao68000 		connected with SLAVES: ssram, serial_txd
MASTER sd 			connected with SLAVES: ssram
MASTER early_boot	connected with SLAVES: sd

Address space:
SLAVE sd: 			0x30000000 - 0x30000003 /not used - point to point connection/
SLAVE ssram: 		0x00000000 - 0x00100000
SLAVE serial_txt:	0x38000000 - 0x38000000
*/


/***********************************************************************************************************************
 * MASTER ao68000
 **********************************************************************************************************************/

//------------------------------------- global wires
//output
wire ao68000_cyc_o;
wire [31:2] ao68000_adr_o;
wire [31:0] ao68000_dat_o;
wire [3:0] ao68000_sel_o;
wire ao68000_stb_o;
wire ao68000_we_o;

ao68000 m_ao68000(
	//****************** WISHBONE
	.CLK_I(clk_i),
	.reset_n((early_boot_loading_finished_o == 1'b1) ? 1'b1 : 1'b0),

	.CYC_O(ao68000_cyc_o),
	.ADR_O(ao68000_adr_o),
	.DAT_O(ao68000_dat_o),
	.DAT_I( ssram_dat_o ),
	.SEL_O(ao68000_sel_o),
	.STB_O(ao68000_stb_o),
	.WE_O(ao68000_we_o),

	.ACK_I( (ao68000_adr_o[31:2] == 30'h38000000) ? serial_txd_ack_o : ssram_ack_o ),
	.ERR_I(1'b0),
	.RTY_I(timer_rty_o),

	// TAG_TYPE: TGC_O
	.SGL_O(),
	.BLK_O(),
	.RMW_O(),

	// TAG_TYPE: TGA_O
	.CTI_O(),
	.BTE_O(),

	// TAG_TYPE: TGC_O
	.fc_o(),

	//****************** OTHER
	/* interrupt acknowlege:
	 * ACK_I: interrupt vector on DAT_I[7:0]
	 * ERR_I: spurious interrupt
	 * RTY_I: autovector
	 */
	.ipl_i( {2'b00, timer_interrupt_o} ),
	.reset_o(),
	.blocked_o()
);

/***********************************************************************************************************************
 * SLAVE timer
 **********************************************************************************************************************/

//------------------------------------- global wires
//output
wire timer_interrupt_o;
wire timer_rty_o;

//input

timer m_timer(
	.CLK_I(clk_i),
	.RST_I(rst_i),
	
	.ADR_I(ao68000_adr_o),
	.CYC_I(ao68000_cyc_o),
	.STB_I(ao68000_stb_o),
	.WE_I(ao68000_we_o),
	
	.RTY_O(timer_rty_o),
	.interrupt_o(timer_interrupt_o)
);

/***********************************************************************************************************************
 * SLAVE ssram
 **********************************************************************************************************************/

//------------------------------------- global wires
//output
wire [31:0] ssram_dat_o;
wire ssram_ack_o;

//input


ssram m_ssram(
	.CLK_I(clk_i),
	.RST_I(rst_i),
	
	//slave
	.DAT_O(ssram_dat_o),
	.DAT_I((early_boot_loading_finished_o == 1'b1) ? ao68000_dat_o : sd_dat_o),
	.ACK_O(ssram_ack_o),
	
	.CYC_I((early_boot_loading_finished_o == 1'b1) ? 
		( (ao68000_adr_o[31:2] >= 30'h0 && ao68000_adr_o[31:2] < 30'h00080000) ? ao68000_cyc_o : 1'b0 ) :
		sd_cyc_o
	),
	.ADR_I((early_boot_loading_finished_o == 1'b1) ? ao68000_adr_o[20:2] : sd_adr_o[20:2]),
	.STB_I((early_boot_loading_finished_o == 1'b1) ? 
		( (ao68000_adr_o[31:2] >= 30'h0 && ao68000_adr_o[31:2] < 30'h00080000) ? ao68000_stb_o : 1'b0 ) :
		sd_stb_o
	),
	.WE_I((early_boot_loading_finished_o == 1'b1) ? ao68000_we_o : sd_we_o),
	.SEL_I((early_boot_loading_finished_o == 1'b1) ? ao68000_sel_o : sd_sel_o),
	
	//ssram interface
	.ssram_address(ssram_address),
	.ssram_oe_n(ssram_oe_n),
	.ssram_writeen_n(ssram_writeen_n),
	.ssram_byteen0_n(ssram_byteen0_n),
	.ssram_byteen1_n(ssram_byteen1_n),
	.ssram_byteen2_n(ssram_byteen2_n),
	.ssram_byteen3_n(ssram_byteen3_n),
	
	.ssram_data(ssram_data),
	
	.ssram_clk(ssram_clk),
	.ssram_mode(), //ssram_mode),
	.ssram_zz(), //ssram_zz),
	.ssram_globalw_n(ssram_globalw_n),
	.ssram_advance_n(ssram_advance_n),
	.ssram_adsp_n(ssram_adsp_n),
	.ssram_adsc_n(ssram_adsc_n),
	.ssram_ce1_n(ssram_ce1_n),
	.ssram_ce2(ssram_ce2),
	.ssram_ce3_n(ssram_ce3_n)
);

/***********************************************************************************************************************
 * MASTER and SLAVE sd
 **********************************************************************************************************************/

//------------------------------------- global wires: master
//output
wire sd_cyc_o;
wire [31:0] sd_dat_o;
wire sd_stb_o;
wire sd_we_o;
wire [31:2] sd_adr_o;
wire [3:0] sd_sel_o;

//input

//------------------------------------- global wires: slave
//output
wire [31:0] sd_slave_dat_o;
wire sd_ack_o;

sd m_sd(
	.CLK_I(clk_i),
	.RST_I(rst_i),
	
	.CYC_O(sd_cyc_o),
	.DAT_O(sd_dat_o),
	.STB_O(sd_stb_o),
	.WE_O(sd_we_o),
	.ADR_O(sd_adr_o),
	.SEL_O(sd_sel_o),
	
	.DAT_I(ssram_dat_o),
	.ACK_I( (early_boot_loading_finished_o == 1'b1) ? 1'b0 : ssram_ack_o),
	.ERR_I(1'b0),
	.RTY_I(1'b0),

	// TAG_TYPE: TGC_O
	.SGL_O(),
	.BLK_O(),
	.RMW_O(),

	// TAG_TYPE: TGA_O
	.CTI_O(),
	.BTE_O(),
	
	//slave
	.slave_DAT_O(sd_slave_dat_o),
	.slave_DAT_I(early_boot_dat_o),
	.ACK_O(sd_ack_o),
	.ERR_O(),
	.RTY_O(),
	
	.CYC_I(early_boot_cyc_o),
	.ADR_I(early_boot_adr_o[3:2]),
	.STB_I(early_boot_stb_o),
	.WE_I(early_boot_we_o),
	.SEL_I(early_boot_sel_o),
	
	
	//sd bus 1-bit interface
	.sd_clk_o(sd_clk_o),
	.sd_cmd_io(sd_cmd_io),
	.sd_dat_io(sd_dat_io),
	
	.debug_leds(sd_debug)
);

/***********************************************************************************************************************
 * SLAVE serial_txd
 **********************************************************************************************************************/

//------------------------------------- global wires
//output
wire serial_txd_ack_o;

//input

serial_txd m_serial_txd(
	.CLK_I(clk_i),
	.RST_I(rst_i),
	
	//slave
	.DAT_I( (ao68000_adr_o[31:2] == 30'h38000000) ? 
		(
			(ao68000_sel_o[3] == 1'b1) ? ao68000_dat_o[31:24] :
			(ao68000_sel_o[2] == 1'b1) ? ao68000_dat_o[23:16] :
			(ao68000_sel_o[1] == 1'b1) ? ao68000_dat_o[15:8] :
			(ao68000_sel_o[0] == 1'b1) ? ao68000_dat_o[7:0] :
			8'hFF
		) :
		8'hFE ),
	.ACK_O(serial_txd_ack_o),
	
	.CYC_I( (ao68000_adr_o[31:2] == 30'h38000000) ? ao68000_cyc_o : 1'b0 ),
	.STB_I( (ao68000_adr_o[31:2] == 30'h38000000) ? ao68000_stb_o : 1'b0 ),
	.WE_I( ao68000_we_o ),
	
	//serial interface
	.uart_rxd(uart_rxd),
	.uart_rts(uart_rts),
	.uart_txd(uart_txd),
	.uart_cts(uart_cts)
);

/***********************************************************************************************************************
 * MASTER early_boot
 **********************************************************************************************************************/

//------------------------------------- global wires
//output
wire early_boot_cyc_o;
wire [31:0] early_boot_dat_o;
wire early_boot_stb_o;
wire early_boot_we_o;
wire [31:2] early_boot_adr_o;
wire [3:0] early_boot_sel_o;

wire early_boot_loading_finished_o;

//input

early_boot m_early_boot(
	.CLK_I(clk_i),
	.RST_I(rst_i),
	
	.CYC_O(early_boot_cyc_o),
	.DAT_O(early_boot_dat_o),
	.STB_O(early_boot_stb_o),
	.WE_O(early_boot_we_o),
	.ADR_O(early_boot_adr_o),
	.SEL_O(early_boot_sel_o),
	
	.DAT_I(sd_slave_dat_o),
	.ACK_I(sd_ack_o),
	.ERR_I(1'b0),
	.RTY_I(1'b0),
	
	//****************** OTHER
	.loading_finished_o(early_boot_loading_finished_o)
);

endmodule


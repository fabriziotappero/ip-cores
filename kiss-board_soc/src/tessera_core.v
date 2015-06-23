
`timescale 1ps/1ps

//
// Address map
//
`define APP_ADDR_DEC_W	8
`define APP_ADDR_SRAM	`APP_ADDR_DEC_W'h00

`define APP_ADDR_FLASH	`APP_ADDR_DEC_W'h04
`define APP_ADDR_DECP_W  4
`define APP_ADDR_PERIP  `APP_ADDR_DEC_W'h9
`define APP_ADDR_VGA	`APP_ADDR_DEC_W'h97
`define APP_ADDR_ETH	`APP_ADDR_DEC_W'h92
`define APP_ADDR_AUDIO	`APP_ADDR_DEC_W'h9d
`define APP_ADDR_UART	`APP_ADDR_DEC_W'h90
`define APP_ADDR_PS2	`APP_ADDR_DEC_W'h94
`define APP_ADDR_RES1	`APP_ADDR_DEC_W'h9e
`define APP_ADDR_RES2	`APP_ADDR_DEC_W'h9f
`define APP_ADDR_FAKEMC	4'h6

// 0x0000_0000 - 0x3fff_ffff RAM (1GByte)
	//0x00xx_xxxx(0x0000_0000-0x001f_ffff) Cached External_SDRAM0 CS0 BANK0(2Mbyte)
	//0x00xx_xxxx(0x002f_0000-0x003f_ffff) Cached External_SDRAM0 CS0 BANK1(2Mbyte)
	//0x00xx_xxxx(0x0040_0000-0x005f_ffff) Cached External_SDRAM0 CS0 BANK2(2Mbyte)
	//0x00xx_xxxx(0x0060_0000-0x007f_ffff) Cached External_SDRAM0 CS0 BANK3(2Mbyte)
	//0x00xx_xxxx(0x0080_0000-0x009f_ffff) Cached External_SDRAM0 CS1 BANK0(2Mbyte)
	//0x00xx_xxxx(0x00af_0000-0x00bf_ffff) Cached External_SDRAM0 CS1 BANK1(2Mbyte)
	//0x00xx_xxxx(0x00c0_0000-0x00df_ffff) Cached External_SDRAM0 CS1 BANK2(2Mbyte)
	//0x00xx_xxxx(0x00d0_0000-0x00ff_ffff) Cached External_SDRAM0 CS1 BANK3(2Mbyte)

	//0x01xx_xxxx(0x0100_0000-0x011f_ffff) Cached External_SDRAM1 CS0 BANK0(2Mbyte)
	//0x01xx_xxxx(0x012f_0000-0x013f_ffff) Cached External_SDRAM1 CS0 BANK1(2Mbyte)
	//0x01xx_xxxx(0x0140_0000-0x015f_ffff) Cached External_SDRAM1 CS0 BANK2(2Mbyte)
	//0x01xx_xxxx(0x0160_0000-0x017f_ffff) Cached External_SDRAM1 CS0 BANK3(2Mbyte)
	//0x01xx_xxxx(0x0180_0000-0x019f_ffff) Cached External_SDRAM1 CS1 BANK0(2Mbyte)
	//0x01xx_xxxx(0x01af_0000-0x01bf_ffff) Cached External_SDRAM1 CS1 BANK1(2Mbyte)
	//0x01xx_xxxx(0x01c0_0000-0x01df_ffff) Cached External_SDRAM1 CS1 BANK2(2Mbyte)
	//0x01xx_xxxx(0x01d0_0000-0x01ff_ffff) Cached External_SDRAM1 CS1 BANK3(2Mbyte)

	//0x02xx_xxxx(0x0200_0000-0x02ff_ffff) Cached None

	//0x03xx_xxxx(0x0300_0000-0x03ff_ffff) Cached None

	//0x04xx_xxxx(0x0400_0000-0x041f_ffff) Cached External_FLASH(2MByte) ( FPGA-CODE + PROGRAM-CODE )
	//0x04xx_xxxx(0x0420_0000-0x043f_ffff) Cached External_FLASH(2MByte) image
	//0x04xx_xxxx(0x0440_0000-0x045f_ffff) Cached External_FLASH(2MByte) image
	//0x04xx_xxxx(0x0460_0000-0x047f_ffff) Cached External_FLASH(2MByte) image
	//0x04xx_xxxx(0x0480_0000-0x049f_ffff) Cached External_FLASH(2MByte) image
	//0x04xx_xxxx(0x04a0_0000-0x04bf_ffff) Cached External_FLASH(2MByte) image
	//0x04xx_xxxx(0x04c0_0000-0x04df_ffff) Cached External_FLASH(2MByte) image
	//0x04xx_xxxx(0x04d0_0000-0x04ff_ffff) Cached External_FLASH(2MByte) image

	//....

// 0x4000_0000 - 0x7fff_ffff Resevved(1GByte)
	//....

// 0x8000_0000 - 0xefff_ffff DEVICE,etc
	//	0x90xx_xxxx(0x9000_0000-0x90ff_ffff) Uncached 16MB UART16550 Controller 0-15
	//	....

// 0xf000_0000 - 0xffff_ffff ROM(256MByte)
	//	....

module tessera_core (
	//
	sys_or1200_res,
	sys_or1200_clk,
	sys_wb_res,
	sys_wb_clk,
	sys_mem_res,
	sys_mem_clk,
	sys_sdram_res,
	sys_sdram_clk,
	sys_vga_res,
	sys_vga_clk,
	sys_clmode,
	//
	jtag_tms,
	jtag_tck,
	jtag_trst,
	jtag_tdi,
	jtag_tdo_o,
	jtag_tdo_oe,
	//
	uart_stx,
	uart_srx,
	uart_rts,
	uart_cts,
	uart_dtr,
	uart_dsr,
	uart_ri,
	uart_dcd,
	//
	mem_cs2_n,
	mem_cs2_g_n,
	mem_cs2_dir,
	mem_cs2_rstdrv,
	mem_cs2_int,
	mem_cs2_iochrdy,
	mem_cs1_n,
	mem_cs1_rst_n,
	mem_cs1_rdy,
	mem_cs0_n,
	mem_we_n,
	mem_oe_n,
	mem_a,
	mem_d_o,
	mem_d_oe,
	mem_d_i,
	//
	sdram0_clk,
	sdram0_cke,
	sdram0_cs_n,
	sdram0_ras_n,
	sdram0_cas_n,
	sdram0_we_n,
	sdram0_dqm,
	sdram0_ba,
	sdram0_a,
	sdram0_d_i,
	sdram0_d_oe,
	sdram0_d_o,
	//
	sdram1_clk,
	sdram1_cke,
	sdram1_cs_n,
	sdram1_ras_n,
	sdram1_cas_n,
	sdram1_we_n,
	sdram1_dqm,
	sdram1_ba,
	sdram1_a,
	sdram1_d_i,
	sdram1_d_oe,
	sdram1_d_o,
	//
	vga_clk,
	vga_hsync,
	vga_vsync,
	vga_blank,
	vga_d,
	//
	option
);
	// system
	input		sys_or1200_res;
	input		sys_or1200_clk;
	input		sys_wb_res;
	input		sys_wb_clk;
	input		sys_mem_res;
	input		sys_mem_clk;
	input		sys_sdram_res;
	input		sys_sdram_clk;
	input		sys_vga_res;
	input		sys_vga_clk;
	input	[1:0]	sys_clmode;
	// debug
	input		jtag_tms;
	input		jtag_tck;
	input		jtag_trst;
	input		jtag_tdi;
	output		jtag_tdo_o;
	output		jtag_tdo_oe;
	// uart
	output		uart_stx;
	input		uart_srx;
	output		uart_rts;
	input		uart_cts;
	output		uart_dtr;
	input		uart_dsr;
	input		uart_ri;
	input		uart_dcd;
	// flash
	//output		flash_rstn;
	//output		flash_cen;
	//output		flash_oen;
	//output		flash_wen;
	//input		flash_rdy;
	//inout	[7:0]	flash_d; // IO
	//output	[22:0]	flash_a;
	//output		flash_a_oe;
	output		mem_cs2_n;
	output		mem_cs2_g_n;
	output		mem_cs2_dir;
	output		mem_cs2_rstdrv;
	input		mem_cs2_int;
	input		mem_cs2_iochrdy;
	output		mem_cs1_n;
	output		mem_cs1_rst_n;
	input		mem_cs1_rdy;
	output		mem_cs0_n;
	output		mem_we_n;
	output		mem_oe_n;
	output	[22:0]	mem_a;
	output	[7:0]	mem_d_o;
	output	[7:0]	mem_d_oe;
	input	[7:0]	mem_d_i;
	// sdram0
	output		sdram0_clk;
	output		sdram0_cke;
	output	[1:0]	sdram0_cs_n;
	output		sdram0_ras_n;
	output		sdram0_cas_n;
	output		sdram0_we_n;
	output	[1:0]	sdram0_dqm;
	output	[1:0]	sdram0_ba;
	output	[12:0]	sdram0_a;
	input	[15:0]	sdram0_d_i;
	output	[15:0]	sdram0_d_oe;
	output	[15:0]	sdram0_d_o;
	// sdram1
	output		sdram1_clk;
	output		sdram1_cke;
	output	[1:0]	sdram1_cs_n;
	output		sdram1_ras_n;
	output		sdram1_cas_n;
	output		sdram1_we_n;
	output	[1:0]	sdram1_dqm;
	output	[1:0]	sdram1_ba;
	output	[12:0]	sdram1_a;
	input	[15:0]	sdram1_d_i;
	output	[15:0]	sdram1_d_oe;
	output	[15:0]	sdram1_d_o;
	// vga
	output		vga_clk;
	output		vga_hsync;
	output		vga_vsync;
	output		vga_blank;
	output	[23:0]	vga_d;
	// test
	input		option;

// Interrupt signals
	wire	[19:0]	pic_ints;
	wire		uart_int;
	wire		dma_a_int;
	wire		dma_b_int;

// Misc signal
	// VGA
	wire		vram_dma_req;
	wire	[31:0]	vram_dma_address;
	wire		vram_dma_ack;
	wire		vram_dma_exist;
	wire	[15:0]	vram_dma_data;
	// Debug
	wire		dbg_stall;
	wire	[31:0]	dbg_dat_dbg;
	wire	[31:0]	dbg_adr;
	wire	[3:0]	dbg_lss;
	wire	[1:0]	dbg_is;
	wire	[10:0]	dbg_wp;
	wire		dbg_bp;
	wire	[31:0]	dbg_dat_risc;
	wire	[2:0]	dbg_op;

// WishBone Master signals
	// RiscInstractionMaster
	wire		wb_rim_cyc_o;
	wire	[31:0]	wb_rim_adr_o;
	wire	[31:0]	wb_rim_dat_i;
	wire	[31:0]	wb_rim_dat_o;
	wire	[3:0]	wb_rim_sel_o;
	wire		wb_rim_ack_i;
	wire		wb_rim_err_i;
	wire		wb_rim_rty_i;
	wire		wb_rim_we_o;
	wire		wb_rim_stb_o;
	wire		wb_rim_cab_o;
	// RiscDataMaster
	wire		wb_rdm_cyc_o;
	wire	[31:0]	wb_rdm_adr_o;
	wire	[31:0]	wb_rdm_dat_i;
	wire	[31:0]	wb_rdm_dat_o;
	wire	[3:0]	wb_rdm_sel_o;
	wire		wb_rdm_ack_i;
	wire		wb_rdm_err_i;
	wire		wb_rdm_rty_i;
	wire		wb_rdm_we_o;
	wire		wb_rdm_stb_o;
	wire		wb_rdm_cab_o;
	// DebugMaster
	wire	[31:0]	wb_dm_adr_o;
	wire	[31:0]	wb_dm_dat_i;
	wire	[31:0]	wb_dm_dat_o;
	wire	[3:0]	wb_dm_sel_o;
	wire		wb_dm_we_o;
	wire		wb_dm_stb_o;
	wire		wb_dm_cyc_o;
	wire		wb_dm_cab_o;
	wire		wb_dm_ack_i;
	wire		wb_dm_err_i;
	// TICMaster
	wire		wb_ticm_cyc_o;
	wire	[31:0]	wb_ticm_adr_o;
	wire	[31:0]	wb_ticm_dat_i;
	wire	[31:0]	wb_ticm_dat_o;
	wire	[3:0]	wb_ticm_sel_o;
	wire		wb_ticm_ack_i;
	wire		wb_ticm_err_i;
	wire		wb_ticm_rty_i;
	wire		wb_ticm_we_o;
	wire		wb_ticm_stb_o;
	wire		wb_ticm_cab_o;
	// DMA Master0
	wire		wb_dma0m_cyc_o;
	wire	[31:0]	wb_dma0m_adr_o;
	wire	[31:0]	wb_dma0m_dat_i;
	wire	[31:0]	wb_dma0m_dat_o;
	wire	[3:0]	wb_dma0m_sel_o;
	wire		wb_dma0m_ack_i;
	wire		wb_dma0m_err_i;
	wire		wb_dma0m_rty_i;
	wire		wb_dma0m_we_o;
	wire		wb_dma0m_stb_o;
	wire		wb_dma0m_cab_o;
	// DMA Master1
	//wire		wb_dma1m_cyc_o;
	//wire	[31:0]	wb_dma1m_adr_o;
	//wire	[31:0]	wb_dma1m_dat_i;
	//wire	[31:0]	wb_dma1m_dat_o;
	//wire	[3:0]	wb_dma1m_sel_o;
	//wire		wb_dma1m_ack_i;
	//wire		wb_dma1m_err_i;
	//wire		wb_dma1m_rty_i;
	//wire		wb_dma1m_we_o;
	//wire		wb_dma1m_stb_o;
	//wire		wb_dma1m_cab_o;

// WishBone Slave signals
	// small SRAM0
	wire		wb_ram0s_cyc_i;
	wire		wb_ram0s_stb_i;
	wire		wb_ram0s_cab_i;
	wire	[31:0]	wb_ram0s_adr_i;
	wire	[3:0]	wb_ram0s_sel_i;
	wire		wb_ram0s_we_i;
	wire	[31:0]	wb_ram0s_dat_i;
	wire	[31:0]	wb_ram0s_dat_o;
	wire		wb_ram0s_ack_o;
	wire		wb_ram0s_err_o;
	// small SRAM1
	wire		wb_ram1s_cyc_i;
	wire		wb_ram1s_stb_i;
	wire		wb_ram1s_cab_i;
	wire	[31:0]	wb_ram1s_adr_i;
	wire	[3:0]	wb_ram1s_sel_i;
	wire		wb_ram1s_we_i;
	wire	[31:0]	wb_ram1s_dat_i;
	wire	[31:0]	wb_ram1s_dat_o;
	wire		wb_ram1s_ack_o;
	wire		wb_ram1s_err_o;
	// FlashSlave
	wire		wb_flashs_cyc_i;
	wire		wb_flashs_stb_i;
	wire		wb_flashs_cab_i;
	wire	[31:0]	wb_flashs_adr_i;
	wire	[3:0]	wb_flashs_sel_i;
	wire		wb_flashs_we_i;
	wire	[31:0]	wb_flashs_dat_i;
	wire	[31:0]	wb_flashs_dat_o;
	wire		wb_flashs_ack_o;
	wire		wb_flashs_err_o;
	// Uart0Slave
	wire		wb_uarts_cyc_i;
	wire		wb_uarts_stb_i;
	wire		wb_uarts_cab_i;
	wire	[31:0]	wb_uarts_adr_i;
	wire	[3:0]	wb_uarts_sel_i;
	wire		wb_uarts_we_i;
	wire	[31:0]	wb_uarts_dat_i;
	wire	[31:0]	wb_uarts_dat_o;
	wire		wb_uarts_ack_o;
	wire		wb_uarts_err_o;
	// sdram0Slave
	wire		wb_sdram0s_cyc_i;
	wire		wb_sdram0s_stb_i;
	wire		wb_sdram0s_cab_i;
	wire	[31:0]	wb_sdram0s_adr_i;
	wire	[3:0]	wb_sdram0s_sel_i;
	wire		wb_sdram0s_we_i;
	wire	[31:0]	wb_sdram0s_dat_i;
	wire	[31:0]	wb_sdram0s_dat_o;
	wire		wb_sdram0s_ack_o;
	wire		wb_sdram0s_err_o;
	// sdram1Slave
	wire		wb_sdram1s_cyc_i;
	wire		wb_sdram1s_stb_i;
	wire		wb_sdram1s_cab_i;
	wire	[31:0]	wb_sdram1s_adr_i;
	wire	[3:0]	wb_sdram1s_sel_i;
	wire		wb_sdram1s_we_i;
	wire	[31:0]	wb_sdram1s_dat_i;
	wire	[31:0]	wb_sdram1s_dat_o;
	wire		wb_sdram1s_ack_o;
	wire		wb_sdram1s_err_o;
	// VGASlave
	wire		wb_vgas_cyc_i; 
	wire		wb_vgas_stb_i; 
	wire	[3:0]	wb_vgas_sel_i; 
	wire		wb_vgas_we_i;
	wire	[31:0]	wb_vgas_adr_i; 
	wire	[31:0]	wb_vgas_dat_i; 
	wire		wb_vgas_cab_i;
	wire	[31:0]	wb_vgas_dat_o; 
	wire		wb_vgas_ack_o; 
	wire		wb_vgas_err_o;
	// DMA0Slave
	wire		wb_dma0s_cyc_i;
	wire		wb_dma0s_stb_i;
	wire	[3:0]	wb_dma0s_sel_i;
	wire		wb_dma0s_we_i;
	wire	[31:0]	wb_dma0s_adr_i;
	wire	[31:0]	wb_dma0s_dat_i;
	wire		wb_dma0s_cab_i;
	wire	[31:0]	wb_dma0s_dat_o;
	wire		wb_dma0s_ack_o;
	wire		wb_dma0s_err_o;
	// DMA1Slave
//	wire		wb_dma1s_cyc_i;
//	wire		wb_dma1s_stb_i;
//	wire	[3:0]	wb_dma1s_sel_i;
//	wire		wb_dma1s_we_i;
//	wire	[31:0]	wb_dma1s_adr_i;
//	wire	[31:0]	wb_dma1s_dat_i;
//	wire		wb_dma1s_cab_i;
//	wire	[31:0]	wb_dma1s_dat_o;
//	wire		wb_dma1s_ack_o;
//	wire		wb_dma1s_err_o;

///////////////////////////////////////////////////////////////////////////////
// Interrupt table
///////////////////////////////////////////////////////////////////////////////
	assign pic_ints[19:0] = {
	      1'b0,		// INT19 I2C Controller 0, Digital Camera Controller 0
	      1'b0,		// INT18 TDM Controller 0
	      1'b0,		// INT17 HDLC Controller 0
	      1'b0,		// INT16 Firewire Controller 0
	      1'b0,		// INT15 IDE Controller 0
	      1'b0,		// INT14 Audio Controller 0
	      1'b0,		// INT13 USB Host Controller 0
	      1'b0,		// INT12 USB Func Controller 0
	      1'b0,		// INT11 General-Purpose DMA 0
	      1'b0,		// INT10 PCI Controller 0
	      1'b0,		// INT9  IrDA Controller 0
	      1'b0,		// INT8  Graphics Controller 0
	      1'b0,		// INT7  PWM/Timer/Counter Controller 0
	      1'b0,		// INT6  Traffic COP 0, Real-Time Clock 0
	      1'b0,		// INT5  PS/2 Controller 0
	      dma_b_int,	// INT4  Ethernet Controller 0
	      dma_a_int,	// INT3  General-Purpose I/O 0
	      uart_int,		// INT2  UART16550 Controller 0
	      1'b0,		// INT1  Reserved
	      1'b0		// INT0  Reserved
	};
///////////////////////////////////////////////////////////////////////////////
// Bus control
///////////////////////////////////////////////////////////////////////////////
//
// remap register
//
	reg		prefix_flash;
	always @(posedge sys_wb_clk or posedge sys_wb_res)
		if (sys_wb_res)                                                                   prefix_flash <= #1 1'b1;
		else if (wb_rim_cyc_o &&(wb_rim_adr_o[31:32-`APP_ADDR_DEC_W] == `APP_ADDR_FLASH)) prefix_flash <= #1 1'b0;
// re-map Control(for Instraction Address)
// prefix = 1, 0x00xx_xxxx -> 0x04xx_xxxx
// prefix = 0, through
	wire	[31:0]	wb_rif_adr;
	assign wb_rif_adr = prefix_flash ? {`APP_ADDR_FLASH, wb_rim_adr_o[31-`APP_ADDR_DEC_W:0]}: wb_rim_adr_o;
//
// FAKEMC
//
	wire		wb_rdm_ack;
	assign wb_rdm_ack_i = (wb_rdm_adr_o[31:28] == `APP_ADDR_FAKEMC) && wb_rdm_cyc_o && wb_rdm_stb_o ? 1'b1 : wb_rdm_ack;
///////////////////////////////////////////////////////////////////////////////
// WishBone Master&Slave Device
///////////////////////////////////////////////////////////////////////////////
//
// or1200
//
	assign wb_rim_rty_i = 1'b0; // not support
	assign wb_rdm_rty_i = 1'b0; // not support
	or1200_top i_or1200_top (
		// system
		.rst_i(		sys_or1200_res),
		.clk_i(		sys_or1200_clk),
		.clmode_i(	sys_clmode),
		.iwb_clk_i(	sys_wb_clk),
		.iwb_rst_i(	sys_wb_res),
		// wishbone instruction
		.iwb_cyc_o(	wb_rim_cyc_o),
		.iwb_adr_o(	wb_rim_adr_o),
		.iwb_dat_i(	wb_rim_dat_i),
		.iwb_dat_o(	wb_rim_dat_o),
		.iwb_sel_o(	wb_rim_sel_o),
		.iwb_ack_i(	wb_rim_ack_i),
		.iwb_err_i(	wb_rim_err_i),
		.iwb_rty_i(	wb_rim_rty_i),
		.iwb_we_o(	wb_rim_we_o),
		.iwb_stb_o(	wb_rim_stb_o),
		.iwb_cab_o(	wb_rim_cab_o),
		// wishbone data
		.dwb_clk_i(	sys_wb_clk),
		.dwb_rst_i(	sys_wb_res),
		.dwb_cyc_o(	wb_rdm_cyc_o),
		.dwb_adr_o(	wb_rdm_adr_o),
		.dwb_dat_i(	wb_rdm_dat_i),
		.dwb_dat_o(	wb_rdm_dat_o),
		.dwb_sel_o(	wb_rdm_sel_o),
		.dwb_ack_i(	wb_rdm_ack_i),
		.dwb_err_i(	wb_rdm_err_i),
		.dwb_rty_i(	wb_rdm_rty_i),
		.dwb_we_o(	wb_rdm_we_o),
		.dwb_stb_o(	wb_rdm_stb_o),
		.dwb_cab_o(	wb_rdm_cab_o),
		// debug
		.dbg_stall_i(	dbg_stall),
		.dbg_dat_i(	dbg_dat_dbg),
		.dbg_adr_i(	dbg_adr),
		.dbg_ewt_i(	1'b0),
		.dbg_lss_o(	dbg_lss),
		.dbg_is_o(	dbg_is),
		.dbg_wp_o(	dbg_wp),
		.dbg_bp_o(	dbg_bp),
		.dbg_dat_o(	dbg_dat_risc),
		.dbg_ack_o(	),// not used
		.dbg_stb_i(	dbg_op[2]),
		.dbg_we_i(	dbg_op[0]),
		// power management
		.pm_clksd_o( 	),// not used
		.pm_cpustall_i(	1'b0),
		.pm_dc_gate_o(	),// not used
		.pm_ic_gate_o(	),// not used
		.pm_dmmu_gate_o(),// not used
		.pm_immu_gate_o(),// not used
		.pm_tt_gate_o(	),// not used
		.pm_cpu_gate_o(	),// not used
		.pm_wakeup_o(	),// not used
		.pm_lvolt_o(	),// not used
		// interrupts
		.pic_ints_i(	pic_ints)
	);
//
// debug controller
//
`ifdef DBG_IF_MODEL
	assign jtag_tdo_oe = 1'b1;
	dbg_if_model i_dbg_if_model  (
		// JTAG pins
		.tms_pad_i(	jtag_tms),
		.tck_pad_i(	jtag_tck),
		.trst_pad_i(	jtag_trst),
		.tdi_pad_i(	jtag_tdi),
		.tdo_pad_o(	jtag_tdo), 
		// Boundary Scan signals
		.capture_dr_o(	),// not used 
		.shift_dr_o(	),// not used
		.update_dr_o(	),// not used
		.extest_selected_o(),// not used
		.bs_chain_i(	1'b0 ),
		// RISC signals
		.risc_clk_i(	sys_or1200_clk),// wb_clk?
		.risc_data_i(	dbg_dat_risc ),
		.risc_data_o(	dbg_dat_dbg ),
		.risc_addr_o(	dbg_adr ),
		.wp_i(		dbg_wp ),
		.bp_i(		dbg_bp ),
		.opselect_o(	dbg_op ),
		.lsstatus_i(	dbg_lss ),
		.istatus_i(	dbg_is ),
		.risc_stall_o(	dbg_stall ),
		.reset_o(	),// not used
		// WISHBONE common
		.wb_clk_i(	sys_wb_clk ),
		.wb_rst_i(	sys_wb_res ),
		// WISHBONE master interface
		.wb_adr_o(	wb_dm_adr_o ),
		.wb_dat_i(	wb_dm_dat_i ),
		.wb_dat_o(	wb_dm_dat_o ),
		.wb_sel_o(	wb_dm_sel_o ),
		.wb_we_o(	wb_dm_we_o  ),
		.wb_stb_o(	wb_dm_stb_o ),
		.wb_cyc_o(	wb_dm_cyc_o ),
		.wb_cab_o(	wb_dm_cab_o ),
		.wb_ack_i(	wb_dm_ack_i ),
		.wb_err_i(	wb_dm_err_i )
	);
`else
	dbg_top i_dbg_top  (
		// JTAG pins
		.tms_pad_i(	jtag_tms),
		.tck_pad_i(	jtag_tck),
		.trst_pad_i(	jtag_trst),
		.tdi_pad_i(	jtag_tdi),
		.tdo_pad_o(	jtag_tdo_o),
		.tdo_padoen_o(	jtag_tdo_oe),
		// Boundary Scan signals
		.capture_dr_o(	),// not used 
		.shift_dr_o(	),// not used
		.update_dr_o(	),// not used
		.extest_selected_o(),// not used
		.bs_chain_i(	1'b0),
		.bs_chain_o(	),// not used
		// RISC signals
		.risc_clk_i(	sys_or1200_clk),// wb_clk
		.risc_addr_o(	dbg_adr),
		.risc_data_i(	dbg_dat_risc),
		.risc_data_o(	dbg_dat_dbg),
		.wp_i(		dbg_wp),
		.bp_i(		dbg_bp),
		.opselect_o(	dbg_op),
		.lsstatus_i(	dbg_lss),
		.istatus_i(	dbg_is),
		.risc_stall_o(	dbg_stall),
		.reset_o(	), // not used
		// WISHBONE common
		.wb_clk_i(	sys_wb_clk),
		.wb_rst_i(	sys_wb_res),
		// WISHBONE master interface
		.wb_adr_o(	wb_dm_adr_o),
		.wb_dat_i(	wb_dm_dat_i),
		.wb_dat_o(	wb_dm_dat_o),
		.wb_sel_o(	wb_dm_sel_o),
		.wb_we_o(	wb_dm_we_o),
		.wb_stb_o(	wb_dm_stb_o),
		.wb_cyc_o(	wb_dm_cyc_o),
		.wb_cab_o(	wb_dm_cab_o),
		.wb_ack_i(	wb_dm_ack_i),
		.wb_err_i(	wb_dm_err_i)
	);
`endif
//
// tic controller
//
	assign wb_ticm_rty_i = 1'b0; // not support rty
	tessera_tic i_tessera_tic (
		.wb_rst(	sys_wb_res),
		.wb_clk(	sys_wb_clk),
		.wb_cyc_o(	wb_ticm_cyc_o),
		.wb_adr_o(	wb_ticm_adr_o),
		.wb_dat_i(	wb_ticm_dat_i),
		.wb_dat_o(	wb_ticm_dat_o),
		.wb_sel_o(	wb_ticm_sel_o),
		.wb_ack_i(	wb_ticm_ack_i),
		.wb_err_i(	wb_ticm_err_i),
		.wb_rty_i(	wb_ticm_rty_i),
		.wb_we_o(	wb_ticm_we_o),
		.wb_stb_o(	wb_ticm_stb_o),
		.wb_cab_o(	wb_ticm_cab_o)
	);
//
// DMA controler(only use softDMA)
//
	assign wb_dma0m_rty_i = 1'b0; /* not support singal */
	//assign wb_dma1m_rty_i = 1'b0; /* not support singal */
	assign wb_dma0m_cab_o = 1'b0; /* not support singal */
	//assign wb_dma1m_cab_o = 1'b0; /* not support singal */
	wb_dma_top #(
		// rf_addr:integer
		4'h9, // modify WDMA_REG_SEL(wb_dma_defines.v),so always select register_file to not-use pass-through mode.
		// pri_sel:2'
		2'd0,
		// ch_count:integer
		1,
		// chX_conf(0-30)
		4'h1,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
		4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
		4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,
		4'h0
	) i_wb_dma_top (
		//
		.clk_i(		sys_wb_clk),
		.rst_i(		sys_wb_res),
	// Slave0
		.wb0m_data_i(	wb_dma0s_dat_i),	// this is slave port
		.wb0m_data_o(	wb_dma0s_dat_o),	// this is slave port
		.wb0_addr_i(	wb_dma0s_adr_i),
		.wb0_sel_i(	wb_dma0s_sel_i),
		.wb0_we_i(	wb_dma0s_we_i),
		.wb0_cyc_i(	wb_dma0s_cyc_i),
		.wb0_stb_i(	wb_dma0s_stb_i),
		.wb0_ack_o(	wb_dma0s_ack_o),
		.wb0_err_o(	wb_dma0s_err_o),
		.wb0_rty_o(	/* open */),
	// Master0
		.wb0s_data_i(	wb_dma0m_dat_i),	 // this is master port 
		.wb0s_data_o(	wb_dma0m_dat_o),	 // this is master port
		.wb0_addr_o(	wb_dma0m_adr_o),
		.wb0_sel_o(	wb_dma0m_sel_o),
		.wb0_we_o(	wb_dma0m_we_o),
		.wb0_cyc_o(	wb_dma0m_cyc_o),
		.wb0_stb_o(	wb_dma0m_stb_o),
		.wb0_ack_i(	wb_dma0m_ack_i),
		.wb0_err_i(	wb_dma0m_err_i),
		.wb0_rty_i(	wb_dma0m_rty_i),
	// Slave1(not-used)
		.wb1m_data_i(	32'h0000_0000),		// this is slave port
		.wb1m_data_o(	/* open */),		// this is slave port
		.wb1_addr_i(	32'h0000_0000),
		.wb1_sel_i(	4'b0000),
		.wb1_we_i(	1'b0),
		.wb1_cyc_i(	1'b0),
		.wb1_stb_i(	1'b0),
		.wb1_ack_o(	/* open */),
		.wb1_err_o(	/* open */),
		.wb1_rty_o(	/* open */),
	// Master1
		//.wb1s_data_i(	wb_dma1m_dat_i),	// this is master port
		//.wb1s_data_o(	wb_dma1m_dat_o),	// this is master port
		//.wb1_addr_o(	wb_dma1m_adr_o),
		//.wb1_sel_o(	wb_dma1m_sel_o),
		//.wb1_we_o(	wb_dma1m_we_o),
		//.wb1_cyc_o(	wb_dma1m_cyc_o),
		//.wb1_stb_o(	wb_dma1m_stb_o),
		//.wb1_ack_i(	wb_dma1m_ack_i),
		//.wb1_err_i(	wb_dma1m_err_i),
		//.wb1_rty_i(	wb_dma1m_rty_i),
		.wb1s_data_i(	32'h0000_0000),		// this is master port
		.wb1s_data_o(	/* open */),		// this is master port
		.wb1_addr_o(	/* open */),
		.wb1_sel_o(	/* open */),
		.wb1_we_o(	/* open */),
		.wb1_cyc_o(	/* open */),
		.wb1_stb_o(	/* open */),
		.wb1_ack_i(	1'b1),
		.wb1_err_i(	1'b0),
		.wb1_rty_i(	1'b0),
	// RealDMA port(not-used)
		.dma_req_i(	1'b0),
		.dma_ack_o(	/* open */),
		.dma_nd_i(	1'b0),
		.dma_rest_i(	1'b0),
		//
		.inta_o(	dma_a_int),
		.intb_o(	dma_b_int)
	);

///////////////////////////////////////////////////////////////////////////////
// WishBone SlaveOnly Device
///////////////////////////////////////////////////////////////////////////////
//
// flash controller(WinshBoneSlave,LGPL)
//	flash_top i_flash_top (
//		// system
//		.wb_clk_i(	sys_wb_clk),
//		.wb_rst_i(	sys_wb_res),
//		// wishbone
//		.wb_dat_i(	wb_flashs_dat_i),
//		.wb_dat_o(	/*wb_flashs_dat_o*/),
//		.wb_adr_i(	wb_flashs_adr_i),
//		.wb_sel_i(	wb_flashs_sel_i),
//		.wb_we_i(	wb_flashs_we_i),
//		.wb_cyc_i(	wb_flashs_cyc_i),
//		.wb_stb_i(	wb_flashs_stb_i),
//		.wb_ack_o(	/*wb_flashs_ack_o*/),
//		.wb_err_o(	wb_flashs_err_o),
//		// external
//		.flash_rstn(	flash_rstn),
//		.cen(		/* flash_cen */),
//		.oen(		/* flash_oen */),
//		.wen(		/* flash_wen */),
//		.rdy(		flash_rdy),
//		.d(		flash_d),
//		.a(		/* flash_a */),
//		.a_oe(		flash_a_oe)
//	);
	tessera_mem i_tessera_mem (
		//
		.sys_wb_res(		sys_wb_res),
		.sys_wb_clk(		sys_wb_clk),
		//
		.sys_mem_res(		sys_mem_res),
		.sys_mem_clk(		sys_mem_clk),
		//
		.wb_cyc_i(		wb_flashs_cyc_i),
		.wb_stb_i(		wb_flashs_stb_i),
		.wb_adr_i(		wb_flashs_adr_i),
		.wb_sel_i(		wb_flashs_sel_i),
		.wb_we_i(		wb_flashs_we_i),
		.wb_dat_i(		wb_flashs_dat_i),
		.wb_cab_i(		wb_flashs_cab_i),
		.wb_dat_o(		wb_flashs_dat_o),
		.wb_ack_o(		wb_flashs_ack_o),
		.wb_err_o(		wb_flashs_err_o),
		//
		.mem_cs2_n(		mem_cs2_n),
		.mem_cs2_g_n(		mem_cs2_g_n),
		.mem_cs2_dir(		mem_cs2_dir),
		.mem_cs2_rstdrv(	mem_cs2_rstdrv),
		.mem_cs2_int(		mem_cs2_int),
		.mem_cs2_iochrdy(	mem_cs2_iochrdy),
		.mem_cs1_n(		mem_cs1_n),
		.mem_cs1_rst_n(		mem_cs1_rst_n),
		.mem_cs1_rdy(		mem_cs1_rdy),
		.mem_cs0_n(		mem_cs0_n),
		.mem_we_n(		mem_we_n),
		.mem_oe_n(		mem_oe_n),
		.mem_a(			mem_a),
		.mem_d_o(		mem_d_o),
		.mem_d_oe(		mem_d_oe),
		.mem_d_i(		mem_d_i)
	);
//
// sdram0 controller(WishBoneSlave,DMAport)
//
	tessera_sdram i0_tessera_sdram (
		// system
		.sys_wb_res(	sys_wb_res),
		.sys_wb_clk(	sys_wb_clk),
		.sys_sdram_res(	sys_sdram_res),
		.sys_sdram_clk(	sys_sdram_clk),
		// wishbone
		.wb_cyc_i(	wb_sdram0s_cyc_i),
		.wb_stb_i(	wb_sdram0s_stb_i),
		.wb_adr_i(	wb_sdram0s_adr_i),
		.wb_sel_i(	wb_sdram0s_sel_i),
		.wb_we_i(	wb_sdram0s_we_i),
		.wb_dat_i(	wb_sdram0s_dat_i),
		.wb_cab_i(	wb_sdram0s_cab_i),
		.wb_dat_o(	wb_sdram0s_dat_o),
		.wb_ack_o(	wb_sdram0s_ack_o),
		.wb_err_o(	wb_sdram0s_err_o),
		// DMA for Video
		.dma_req(	1'b0),
		.dma_address(	32'h0000_0000),
		.dma_ack(	/* open */),
		.dma_exist(	/* open */),
		.dma_data(	/* open */),
		//.dma_req(	vram_dma_req),
		//.dma_address(	vram_dma_address),
		//.dma_ack(	vram_dma_ack),
		//.dma_exist(	vram_dma_exist),
		//.dma_data(	vram_dma_data),
		// external
		.sdram_clk(	sdram0_clk),
		.sdram_cke(	sdram0_cke),
		.sdram_cs_n(	sdram0_cs_n),
		.sdram_ras_n(	sdram0_ras_n),
		.sdram_cas_n(	sdram0_cas_n),
		.sdram_we_n(	sdram0_we_n),
		.sdram_dqm(	sdram0_dqm),
		.sdram_ba(	sdram0_ba),
		.sdram_a(	sdram0_a),
		.sdram_d_i(	sdram0_d_i),
		.sdram_d_oe(	sdram0_d_oe),
		.sdram_d_o(	sdram0_d_o),
		//
		.option(	option)
	);

//
// sdram1 controller(WishBoneSlave,DMAport)
//
	//reg	[7:0]	sys_sdram_res_z;
	//always @(negedge sys_sdram_clk) sys_sdram_res_z <= {sys_sdram_res_z[6:0],sys_sdram_res};
	tessera_sdram i1_tessera_sdram (
		// system
		.sys_wb_res(	sys_wb_res),
		.sys_wb_clk(	sys_wb_clk),
		.sys_sdram_res(	sys_sdram_res),
		//.sys_sdram_res(	sys_sdram_res_z[7]),
		.sys_sdram_clk(	sys_sdram_clk),
		// wishbone 
		.wb_cyc_i(	wb_sdram1s_cyc_i),
		.wb_stb_i(	wb_sdram1s_stb_i),
		.wb_adr_i(	wb_sdram1s_adr_i),
		.wb_sel_i(	wb_sdram1s_sel_i),
		.wb_we_i(	wb_sdram1s_we_i),
		.wb_dat_i(	wb_sdram1s_dat_i),
		.wb_cab_i(	wb_sdram1s_cab_i),
		.wb_dat_o(	wb_sdram1s_dat_o),
		.wb_ack_o(	wb_sdram1s_ack_o),
		.wb_err_o(	wb_sdram1s_err_o),
		// DMA for Video
		//.dma_req(	1'b0),
		//.dma_address(	32'h0000_0000),
		//.dma_ack(	/* open */),
		//.dma_exist(	/* open */),
		//.dma_data(	/* open */),
		.dma_req(	vram_dma_req),
		.dma_address(	vram_dma_address),
		.dma_ack(	vram_dma_ack),
		.dma_exist(	vram_dma_exist),
		.dma_data(	vram_dma_data),
		// external
		.sdram_clk(	sdram1_clk),
		.sdram_cke(	sdram1_cke),
		.sdram_cs_n(	sdram1_cs_n),
		.sdram_ras_n(	sdram1_ras_n),
		.sdram_cas_n(	sdram1_cas_n),
		.sdram_we_n(	sdram1_we_n),
		.sdram_dqm(	sdram1_dqm),
		.sdram_ba(	sdram1_ba),
		.sdram_a(	sdram1_a),
		.sdram_d_i(	sdram1_d_i),
		.sdram_d_oe(	sdram1_d_oe),
		.sdram_d_o(	sdram1_d_o),
		//
		.option(	option)
	);
//
// sram internal(WishBoneSlave)
//
//	tessera_ram_vect i0_tessra_ram_int( // exception&.icm
//		// system
//		.sys_wb_res(	sys_wb_res),
//		.sys_wb_clk(	sys_wb_clk),
//		// wishbone
//		.wb_cyc_i(	wb_ram0s_cyc_i),
//		.wb_stb_i(	wb_ram0s_stb_i),
//		.wb_adr_i(	wb_ram0s_adr_i),
//		.wb_sel_i(	wb_ram0s_sel_i),
//		.wb_we_i(	wb_ram0s_we_i),
//		.wb_dat_i(	wb_ram0s_dat_i),
//		.wb_cab_i(	wb_ram0s_cab_i),
//		.wb_dat_o(	wb_ram0s_dat_o),
//		.wb_ack_o(	wb_ram0s_ack_o),
//		.wb_err_o(	wb_ram0s_err_o)
//	);
	tessera_ram_tiny i0_tessra_ram_int( // only exception
		// system
		.sys_wb_res(	sys_wb_res),
		.sys_wb_clk(	sys_wb_clk),
		// wishbone
		.wb_cyc_i(	wb_ram0s_cyc_i),
		.wb_stb_i(	wb_ram0s_stb_i),
		.wb_adr_i(	wb_ram0s_adr_i),
		.wb_sel_i(	wb_ram0s_sel_i),
		.wb_we_i(	wb_ram0s_we_i),
		.wb_dat_i(	wb_ram0s_dat_i),
		.wb_cab_i(	wb_ram0s_cab_i),
		.wb_dat_o(	wb_ram0s_dat_o),
		.wb_ack_o(	wb_ram0s_ack_o),
		.wb_err_o(	wb_ram0s_err_o)
	);

//
// sram internal(WishBoneSlave)
//
//	tessera_ram_data i1_tessra_ram_int( // data&bss
//		// system
//		.sys_wb_res(	sys_wb_res),
//		.sys_wb_clk(	sys_wb_clk),
//		// wishbone
//		.wb_cyc_i(	wb_ram1s_cyc_i),
//		.wb_stb_i(	wb_ram1s_stb_i),
//		.wb_adr_i(	wb_ram1s_adr_i),
//		.wb_sel_i(	wb_ram1s_sel_i),
//		.wb_we_i(	wb_ram1s_we_i),
//		.wb_dat_i(	wb_ram1s_dat_i),
//		.wb_cab_i(	wb_ram1s_cab_i),
//		.wb_dat_o(	wb_ram1s_dat_o),
//		.wb_ack_o(	wb_ram1s_ack_o),
//		.wb_err_o(	wb_ram1s_err_o)
//	);
	assign wb_ram1s_dat_o	= 32'h0000_0000;
	assign wb_ram1s_ack_o	= 1'b0;
	assign wb_ram1s_err_o	= 1'b0;

// uart(WishBoneSlave,interrupt,LGPL)
//
	assign wb_uarts_err_o = 1'b0; // not support signal
	uart_top #(
		32,	// 32bit data width(bigendian byte access)
		5	// address width
	) i_uart_top (
		// system
		.wb_clk_i(	sys_wb_clk), 
		.wb_rst_i(	sys_wb_res),
		// wishbone
		.wb_adr_i(	wb_uarts_adr_i[4:0]),
		.wb_dat_i(	wb_uarts_dat_i),
		.wb_dat_o(	wb_uarts_dat_o),
		.wb_we_i(	wb_uarts_we_i),
		.wb_stb_i(	wb_uarts_stb_i),
		.wb_cyc_i(	wb_uarts_cyc_i),
		.wb_ack_o(	wb_uarts_ack_o),
		.wb_sel_i(	wb_uarts_sel_i),
		// interrupt
		.int_o(		uart_int),
		// external
		.stx_pad_o(	uart_stx),
		.srx_pad_i(	uart_srx),
		.rts_pad_o(	uart_rts),
		.cts_pad_i(	uart_cts),
		.dtr_pad_o(	uart_dtr),
		.dsr_pad_i(	uart_dsr),
		.ri_pad_i(	uart_ri),
		.dcd_pad_i(	uart_dcd)
	);
//
// vga controller(WishBoneSlave,DMAport)
//
	wire		testtest;
	tessera_vga i_tessera_vga (
		// system
		.sys_wb_res(	sys_wb_res),
		.sys_wb_clk(	sys_wb_clk),
		.sys_dma_res(	sys_sdram_res),
		.sys_dma_clk(	sys_sdram_clk),
		.sys_vga_res(	sys_vga_res),
		.sys_vga_clk(	sys_vga_clk),
		// wishbone
		.wb_cyc_i(	wb_vgas_cyc_i),
		.wb_stb_i(	wb_vgas_stb_i),
		.wb_adr_i(	wb_vgas_adr_i),
		.wb_sel_i(	wb_vgas_sel_i),
		.wb_we_i(	wb_vgas_we_i),
		.wb_dat_i(	wb_vgas_dat_i),
		.wb_cab_i(	wb_vgas_cab_i),
		.wb_dat_o(	wb_vgas_dat_o),
		.wb_ack_o(	wb_vgas_ack_o),
		.wb_err_o(	wb_vgas_err_o),
		.wb_busy(	testtest),
		// dma
		.dma_req(	vram_dma_req),
		.dma_address(	vram_dma_address),
		.dma_ack(	vram_dma_ack),
		.dma_exist(	vram_dma_exist),
		.dma_data(	vram_dma_data),
		// vga
		.vga_clk(	vga_clk),
		.vga_hsync(	vga_hsync),
		.vga_vsync(	vga_vsync),
		.vga_blank(	vga_blank),
		.vga_rgb(	vga_d)
	);
///////////////////////////////////////////////////////////////////////////////
// WishBone Switcher
///////////////////////////////////////////////////////////////////////////////
//
// Instantiation of the Traffic COP
//
	tc_top #(
		8,			//
		8'h00,			// bound target0a(InternalRAM0)
		8,			//
		8'h01,			// bound target0b(InternalRAM1)
		8,			//
		8'h02,			// bound target0c(SDRAM)
		8,			//
		8'h03,			// bound target0d(SDRAM)
		8,			//
		8'h04,			// swB->swC1 bound target1(FLASH)
		4,			//
		4'h9,			//
		8,			//
		8'h97,			// swB->swC2 bound target2(VGA)
		8'h92,			// swB->swC3 bound target3(Reserved:ETH)
		8'h9d,			// swB->swC4 bound target4(Reserved:AUDIO)
		8'h90,			// swB->swC5 bound target5(UART0)
		8'h94,			// swB->swC6 bound target6(Reserved:PS2)
		8'h9e,			// swB->swC7 bound target7(Reserved)
		8'h9f			// swB->swC8 bound target8(Reserved)
	) i_tc_top (
		// WISHBONE common
		.wb_clk_i(	sys_wb_clk),
		.wb_rst_i(	sys_wb_res),
	// Master ports
		// WISHBONE Initiator 0(park,why is ?????)
		.i0_wb_cyc_i(	1'b0),
		.i0_wb_stb_i(	1'b0),
		.i0_wb_cab_i(	1'b0),
		.i0_wb_adr_i(	32'h0000_0000),
		.i0_wb_sel_i(	4'b0000),
		.i0_wb_we_i(	1'b0),
		.i0_wb_dat_i(	32'h0000_0000),
		.i0_wb_dat_o(	/* open */),
		.i0_wb_ack_o(	/* open */),
		.i0_wb_err_o(	/* open */),
		// WISHBONE Initiator 1			DMA0
		.i1_wb_cyc_i(	wb_dma0m_cyc_o),
		.i1_wb_stb_i(	wb_dma0m_stb_o),
		.i1_wb_cab_i(	wb_dma0m_cab_o),
		.i1_wb_adr_i(	wb_dma0m_adr_o),
		.i1_wb_sel_i(	wb_dma0m_sel_o),
		.i1_wb_we_i(	wb_dma0m_we_o),
		.i1_wb_dat_i(	wb_dma0m_dat_o),
		.i1_wb_dat_o(	wb_dma0m_dat_i),
		.i1_wb_ack_o(	wb_dma0m_ack_i),
		.i1_wb_err_o(	wb_dma0m_err_i),
		// WISHBONE Initiator 2			DMA1
		//.i2_wb_cyc_i(	wb_dma1m_cyc_o),
		//.i2_wb_stb_i(	wb_dma1m_stb_o),
		//.i2_wb_cab_i(	wb_dma1m_cab_o),
		//.i2_wb_adr_i(	wb_dma1m_adr_o),
		//.i2_wb_sel_i(	wb_dma1m_sel_o),
		//.i2_wb_we_i(	wb_dma1m_we_o),
		//.i2_wb_dat_i(	wb_dma1m_dat_o),
		//.i2_wb_dat_o(	wb_dma1m_dat_i),
		//.i2_wb_ack_o(	wb_dma1m_ack_i),
		//.i2_wb_err_o(	wb_dma1m_err_i),
		.i2_wb_cyc_i(	1'b0),
		.i2_wb_stb_i(	1'b0),
		.i2_wb_cab_i(	1'b0),
		.i2_wb_adr_i(	32'h0000_0000),
		.i2_wb_sel_i(	4'b0000),
		.i2_wb_we_i(	1'b0),
		.i2_wb_dat_i(	32'h0000_0000),
		.i2_wb_dat_o(	/* open */),
		.i2_wb_ack_o(	/* open */),
		.i2_wb_err_o(	/* open */),
		// WISHBONE Initiator 3			Debug
		.i3_wb_cyc_i(	wb_dm_cyc_o),
		.i3_wb_stb_i(	wb_dm_stb_o),
		.i3_wb_cab_i(	wb_dm_cab_o),
		.i3_wb_adr_i(	wb_dm_adr_o),
		.i3_wb_sel_i(	wb_dm_sel_o),
		.i3_wb_we_i(	wb_dm_we_o),
		.i3_wb_dat_i(	wb_dm_dat_o),
		.i3_wb_dat_o(	wb_dm_dat_i),
		.i3_wb_ack_o(	wb_dm_ack_i),
		.i3_wb_err_o(	wb_dm_err_i),
		// WISHBONE Initiator 4			RiscData
		.i4_wb_cyc_i(	wb_rdm_cyc_o),
		.i4_wb_stb_i(	wb_rdm_stb_o),
		.i4_wb_cab_i(	wb_rdm_cab_o),
		.i4_wb_adr_i(	wb_rdm_adr_o),
		.i4_wb_sel_i(	wb_rdm_sel_o),
		.i4_wb_we_i(	wb_rdm_we_o),
		.i4_wb_dat_i(	wb_rdm_dat_o),
		.i4_wb_dat_o(	wb_rdm_dat_i),
		.i4_wb_ack_o(	wb_rdm_ack),	// triger FAKEMC control signal
		.i4_wb_err_o(	wb_rdm_err_i),
		// WISHBONE Initiator 5			RiscInstraction			
		.i5_wb_cyc_i(	wb_rim_cyc_o),
		.i5_wb_stb_i(	wb_rim_stb_o),
		.i5_wb_cab_i(	wb_rim_cab_o),
		.i5_wb_adr_i(	wb_rif_adr),	// triger remap control signal
		.i5_wb_sel_i(	wb_rim_sel_o),
		.i5_wb_we_i(	wb_rim_we_o),
		.i5_wb_dat_i(	wb_rim_dat_o),
		.i5_wb_dat_o(	wb_rim_dat_i),
		.i5_wb_ack_o(	wb_rim_ack_i),
		.i5_wb_err_o(	wb_rim_err_i),
		// WISHBONE Initiator 6			(Reserved)
		.i6_wb_cyc_i(	1'b0),
		.i6_wb_stb_i(	1'b0),
		.i6_wb_cab_i(	1'b0),
		.i6_wb_adr_i(	32'h0000_0000),
		.i6_wb_sel_i(	4'b0000),
		.i6_wb_we_i(	1'b0),
		.i6_wb_dat_i(	32'h0000_0000),
		.i6_wb_dat_o(	/* open */),
		.i6_wb_ack_o(	/* open */),
		.i6_wb_err_o(	/* open */),
		// WISHBONE Initiator 7			Tic
		.i7_wb_cyc_i(	wb_ticm_cyc_o),
		.i7_wb_stb_i(	wb_ticm_stb_o),
		.i7_wb_cab_i(	wb_ticm_cab_o),
		.i7_wb_adr_i(	wb_ticm_adr_o),
		.i7_wb_sel_i(	wb_ticm_sel_o),
		.i7_wb_we_i(	wb_ticm_we_o),
		.i7_wb_dat_i(	wb_ticm_dat_o),
		.i7_wb_dat_o(	wb_ticm_dat_i),
		.i7_wb_ack_o( 	wb_ticm_ack_i),
		.i7_wb_err_o(	wb_ticm_err_i),
	// Slave ports
		// WISHBONE Target 0c(HighPriority)	ram0
		.t0_wb_cyc_o(	wb_ram0s_cyc_i),
		.t0_wb_stb_o(	wb_ram0s_stb_i),
		.t0_wb_cab_o(	wb_ram0s_cab_i),
		.t0_wb_adr_o(	wb_ram0s_adr_i),
		.t0_wb_sel_o(	wb_ram0s_sel_i),
		.t0_wb_we_o(	wb_ram0s_we_i),
		.t0_wb_dat_o(	wb_ram0s_dat_i),
		.t0_wb_dat_i(	wb_ram0s_dat_o),
		.t0_wb_ack_i(	wb_ram0s_ack_o),
		.t0_wb_err_i(	wb_ram0s_err_o),
		// WISHBONE Target 0d(HighPriority)	ram1
		.t0b_wb_cyc_o(	wb_ram1s_cyc_i),
		.t0b_wb_stb_o(	wb_ram1s_stb_i),
		.t0b_wb_cab_o(	wb_ram1s_cab_i),
		.t0b_wb_adr_o(	wb_ram1s_adr_i),
		.t0b_wb_sel_o(	wb_ram1s_sel_i),
		.t0b_wb_we_o(	wb_ram1s_we_i),
		.t0b_wb_dat_o(	wb_ram1s_dat_i),
		.t0b_wb_dat_i(	wb_ram1s_dat_o),
		.t0b_wb_ack_i(	wb_ram1s_ack_o),
		.t0b_wb_err_i(	wb_ram1s_err_o),
		// WISHBONE Target 0a(HighPriority)	sdram0
		.t0c_wb_cyc_o(	wb_sdram0s_cyc_i),
		.t0c_wb_stb_o(	wb_sdram0s_stb_i),
		.t0c_wb_cab_o(	wb_sdram0s_cab_i),
		.t0c_wb_adr_o(	wb_sdram0s_adr_i),
		.t0c_wb_sel_o(	wb_sdram0s_sel_i),
		.t0c_wb_we_o(	wb_sdram0s_we_i),
		.t0c_wb_dat_o(	wb_sdram0s_dat_i),
		.t0c_wb_dat_i(	wb_sdram0s_dat_o),
		.t0c_wb_ack_i(	wb_sdram0s_ack_o),
		.t0c_wb_err_i(	wb_sdram0s_err_o),
		// WISHBONE Target 0b(HighPriority)	sdram1
		.t0d_wb_cyc_o(	wb_sdram1s_cyc_i),
		.t0d_wb_stb_o(	wb_sdram1s_stb_i),
		.t0d_wb_cab_o(	wb_sdram1s_cab_i),
		.t0d_wb_adr_o(	wb_sdram1s_adr_i),
		.t0d_wb_sel_o(	wb_sdram1s_sel_i),
		.t0d_wb_we_o(	wb_sdram1s_we_i),
		.t0d_wb_dat_o(	wb_sdram1s_dat_i),
		.t0d_wb_dat_i(	wb_sdram1s_dat_o),
		.t0d_wb_ack_i(	wb_sdram1s_ack_o),
		.t0d_wb_err_i(	wb_sdram1s_err_o),
		// WISHBONE Target 1			rom
		.t1_wb_cyc_o(	wb_flashs_cyc_i),
		.t1_wb_stb_o(	wb_flashs_stb_i),
		.t1_wb_cab_o(	wb_flashs_cab_i),
		.t1_wb_adr_o(	wb_flashs_adr_i),
		.t1_wb_sel_o(	wb_flashs_sel_i),
		.t1_wb_we_o(	wb_flashs_we_i),
		.t1_wb_dat_o(	wb_flashs_dat_i),
		.t1_wb_dat_i(	wb_flashs_dat_o),
		.t1_wb_ack_i(	wb_flashs_ack_o),
		.t1_wb_err_i(	wb_flashs_err_o),
		// WISHBONE Target 2			vga
		.t2_wb_cyc_o(	wb_vgas_cyc_i),
		.t2_wb_stb_o(	wb_vgas_stb_i),
		.t2_wb_cab_o(	wb_vgas_cab_i),
		.t2_wb_adr_o(	wb_vgas_adr_i),
		.t2_wb_sel_o(	wb_vgas_sel_i),
		.t2_wb_we_o(	wb_vgas_we_i),
		.t2_wb_dat_o(	wb_vgas_dat_i),
		.t2_wb_dat_i(	wb_vgas_dat_o),
		.t2_wb_ack_i(	wb_vgas_ack_o),
		.t2_wb_err_i(	wb_vgas_err_o),
		// WISHBONE Target 3			(EtherMAC-reserved)
		.t3_wb_cyc_o(	/* open */),
		.t3_wb_stb_o(	/* open */),
		.t3_wb_cab_o(	/* open */),
		.t3_wb_adr_o(	/* open */),
		.t3_wb_sel_o(	/* open */),
		.t3_wb_we_o(	/* open */),
		.t3_wb_dat_o(	/* open */),
		.t3_wb_dat_i(	32'h0000_0000),
		.t3_wb_ack_i(	1'b0),
		.t3_wb_err_i(	1'b1),
		// WISHBONE Target 4			(AUDIO-reserved)
		.t4_wb_cyc_o(	/* open */),
		.t4_wb_stb_o(	/* open */),
		.t4_wb_cab_o(	/* open */),
		.t4_wb_adr_o(	/* open */),
		.t4_wb_sel_o(	/* open */),
		.t4_wb_we_o(	/* open */),
		.t4_wb_dat_o(	/* open */),
		.t4_wb_dat_i(	32'h0000_0000),
		.t4_wb_ack_i(	1'b0),
		.t4_wb_err_i(	1'b1),
		// WISHBONE Target 5			UART
		.t5_wb_cyc_o(	wb_uarts_cyc_i),
		.t5_wb_stb_o(	wb_uarts_stb_i),
		.t5_wb_cab_o(	wb_uarts_cab_i),
		.t5_wb_adr_o(	wb_uarts_adr_i),
		.t5_wb_sel_o(	wb_uarts_sel_i),
		.t5_wb_we_o(	wb_uarts_we_i),
		.t5_wb_dat_o(	wb_uarts_dat_i),
		.t5_wb_dat_i(	wb_uarts_dat_o),
		.t5_wb_ack_i(	wb_uarts_ack_o),
		.t5_wb_err_i(	wb_uarts_err_o),
		// WISHBONE Target 6			(PS2-reserved)
		.t6_wb_cyc_o(	/* open */),
		.t6_wb_stb_o(	/* open */),
		.t6_wb_cab_o(	/* open */),
		.t6_wb_adr_o(	/* open */),
		.t6_wb_sel_o(	/* open */),
		.t6_wb_we_o(	/* open */),
		.t6_wb_dat_o(	/* open */),
		.t6_wb_dat_i(	32'h0000_0000),
		.t6_wb_ack_i(	1'b0),
		.t6_wb_err_i(	1'b1),
		// WISHBONE Target 7			(reserved)
		.t7_wb_cyc_o(	/* open */),
		.t7_wb_stb_o(	/* open */),
		.t7_wb_cab_o(	/* open */),
		.t7_wb_adr_o(	/* open */),
		.t7_wb_sel_o(	/* open */),
		.t7_wb_we_o(	/* open */),
		.t7_wb_dat_o(	/* open */),
		.t7_wb_dat_i(	32'h0000_0000),
		.t7_wb_ack_i(	1'b0),
		.t7_wb_err_i(	1'b1),
		// WISHBONE Target 8			DMA
		.t8_wb_cyc_o(	wb_dma0s_cyc_i),
		.t8_wb_stb_o(	wb_dma0s_stb_i),
		.t8_wb_cab_o(	wb_dma0s_cab_i),
		.t8_wb_adr_o(	wb_dma0s_adr_i),
		.t8_wb_sel_o(	wb_dma0s_sel_i),
		.t8_wb_we_o(	wb_dma0s_we_i),
		.t8_wb_dat_o(	wb_dma0s_dat_i),
		.t8_wb_dat_i(	wb_dma0s_dat_o),
		.t8_wb_ack_i(	wb_dma0s_ack_o),
		.t8_wb_err_i(	wb_dma0s_err_o)
	);

endmodule

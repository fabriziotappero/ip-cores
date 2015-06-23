
`timescale 1ps/1ps

module tessera_top (
	//
	sys_reset_n,
	sys_init_n,
	sys_clk0,
	sys_clk1,
	sys_clk2,
	sys_clk3,
	//
//	jtag_tms,
//	jtag_tck,
//	jtag_trst,
//	jtag_tdi,
//	jtag_tdo,
	//
	uart_txd,
	uart_rxd,
	uart_rts_n,
	uart_cts_n,
	uart_dtr_n,
	uart_dsr_n,
	uart_dcd_n,
	uart_ri_n,
	//
	mem_cs2_rstdrv,
	mem_cs2_int,
	mem_cs2_dir,
	mem_cs2_g_n,
	mem_cs2_n,
	mem_cs2_iochrdy,
	mem_cs1_rst_n,
	mem_cs1_n,
	mem_cs1_rdy,
	mem_cs0_n,
	mem_we_n,
	mem_oe_n,
	mem_a,
	mem_d,
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
	sdram0_d,
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
	sdram1_d,
	//
	vga_clkp,
	vga_clkn,
	vga_hsync,
	vga_vsync,
	vga_blank,
	vga_d,
	// misc
	misc_gpio,
	misc_tp
);
	//
	input		sys_reset_n;
	output		sys_init_n;
	input		sys_clk0;	// XT 20MHz(pos)
	input		sys_clk1;	// XT 20MHz(neg)
	input		sys_clk2;	// XT 6MHz(pos)
	input		sys_clk3;	// XT 6MHz(neg)
	//
//	input		jtag_tms;
//	input		jtag_tck;
//	input		jtag_trst;
//	input		jtag_tdi;
//	output		jtag_tdo;
	//
	output		uart_txd;
	input		uart_rxd;
	output		uart_rts_n;
	input		uart_cts_n;
	output		uart_dtr_n;
	input		uart_dsr_n;
	input		uart_dcd_n;
	input		uart_ri_n;
	//
	output		mem_cs2_rstdrv;
	input		mem_cs2_int;
	output		mem_cs2_dir;
	output		mem_cs2_g_n;
	output		mem_cs2_n;
	input		mem_cs2_iochrdy;
	output		mem_cs1_rst_n;
	output		mem_cs1_n;
	input		mem_cs1_rdy;
	output		mem_cs0_n;
	output		mem_we_n;
	output		mem_oe_n;
	output	[22:0]	mem_a;
	inout	[7:0]	mem_d;
	//	
	output		sdram0_clk;
	output		sdram0_cke;
	output	[1:0]	sdram0_cs_n;
	output		sdram0_ras_n;
	output		sdram0_cas_n;
	output		sdram0_we_n;
	output	[1:0]	sdram0_dqm;
	output	[1:0]	sdram0_ba;
	output	[12:0]	sdram0_a;
	inout	[15:0]	sdram0_d;
	//
	output		sdram1_clk;
	output		sdram1_cke;
	output	[1:0]	sdram1_cs_n;
	output		sdram1_ras_n;
	output		sdram1_cas_n;
	output		sdram1_we_n;
	output	[1:0]	sdram1_dqm;
	output	[1:0]	sdram1_ba;
	output	[12:0]	sdram1_a;
	inout	[15:0]	sdram1_d;
	//
	output		vga_clkp;
	output		vga_clkn;
	output		vga_hsync;
	output		vga_vsync;
	output		vga_blank;
	output	[23:0]	vga_d;
	// misc
	input	[3:0]	misc_gpio;
	output		misc_tp;

	// JTAG OE control
//	wire		jtag_tdo_oe;
//	wire		jtag_tdo_o;
//	assign jtag_tdo = (jtag_tdo_oe) ? jtag_tdo_o: 1'bz;

	// OE control PAD for SDRAM
	wire	[15:0]	sdram0_d_oe;
	wire	[15:0]	sdram0_d_o;
	wire	[15:0]	sdram1_d_oe;
	wire	[15:0]	sdram1_d_o;
	assign sdram0_d[15] = (sdram0_d_oe[15]) ? sdram0_d_o[15]: 1'bz;
	assign sdram0_d[14] = (sdram0_d_oe[14]) ? sdram0_d_o[14]: 1'bz;
	assign sdram0_d[13] = (sdram0_d_oe[13]) ? sdram0_d_o[13]: 1'bz;
	assign sdram0_d[12] = (sdram0_d_oe[12]) ? sdram0_d_o[12]: 1'bz;
	assign sdram0_d[11] = (sdram0_d_oe[11]) ? sdram0_d_o[11]: 1'bz;
	assign sdram0_d[10] = (sdram0_d_oe[10]) ? sdram0_d_o[10]: 1'bz;
	assign sdram0_d[9]  = (sdram0_d_oe[9] ) ? sdram0_d_o[9] : 1'bz;
	assign sdram0_d[8]  = (sdram0_d_oe[8] ) ? sdram0_d_o[8] : 1'bz;
	assign sdram0_d[7]  = (sdram0_d_oe[7] ) ? sdram0_d_o[7] : 1'bz;
	assign sdram0_d[6]  = (sdram0_d_oe[6] ) ? sdram0_d_o[6] : 1'bz;
	assign sdram0_d[5]  = (sdram0_d_oe[5] ) ? sdram0_d_o[5] : 1'bz;
	assign sdram0_d[4]  = (sdram0_d_oe[4] ) ? sdram0_d_o[4] : 1'bz;
	assign sdram0_d[3]  = (sdram0_d_oe[3] ) ? sdram0_d_o[3] : 1'bz;
	assign sdram0_d[2]  = (sdram0_d_oe[2] ) ? sdram0_d_o[2] : 1'bz;
	assign sdram0_d[1]  = (sdram0_d_oe[1] ) ? sdram0_d_o[1] : 1'bz;
	assign sdram0_d[0]  = (sdram0_d_oe[0] ) ? sdram0_d_o[0] : 1'bz;
	assign sdram1_d[15] = (sdram1_d_oe[15]) ? sdram1_d_o[15]: 1'bz;
	assign sdram1_d[14] = (sdram1_d_oe[14]) ? sdram1_d_o[14]: 1'bz;
	assign sdram1_d[13] = (sdram1_d_oe[13]) ? sdram1_d_o[13]: 1'bz;
	assign sdram1_d[12] = (sdram1_d_oe[12]) ? sdram1_d_o[12]: 1'bz;
	assign sdram1_d[11] = (sdram1_d_oe[11]) ? sdram1_d_o[11]: 1'bz;
	assign sdram1_d[10] = (sdram1_d_oe[10]) ? sdram1_d_o[10]: 1'bz;
	assign sdram1_d[9]  = (sdram1_d_oe[9] ) ? sdram1_d_o[9] : 1'bz;
	assign sdram1_d[8]  = (sdram1_d_oe[8] ) ? sdram1_d_o[8] : 1'bz;
	assign sdram1_d[7]  = (sdram1_d_oe[7] ) ? sdram1_d_o[7] : 1'bz;
	assign sdram1_d[6]  = (sdram1_d_oe[6] ) ? sdram1_d_o[6] : 1'bz;
	assign sdram1_d[5]  = (sdram1_d_oe[5] ) ? sdram1_d_o[5] : 1'bz;
	assign sdram1_d[4]  = (sdram1_d_oe[4] ) ? sdram1_d_o[4] : 1'bz;
	assign sdram1_d[3]  = (sdram1_d_oe[3] ) ? sdram1_d_o[3] : 1'bz;
	assign sdram1_d[2]  = (sdram1_d_oe[2] ) ? sdram1_d_o[2] : 1'bz;
	assign sdram1_d[1]  = (sdram1_d_oe[1] ) ? sdram1_d_o[1] : 1'bz;
	assign sdram1_d[0]  = (sdram1_d_oe[0] ) ? sdram1_d_o[0] : 1'bz;

	// OE control PAD for MEM-BUS
	wire	[7:0]	mem_d_oe;
	wire	[7:0]	mem_d_o;
	assign mem_d[7]	= (mem_d_oe[7]) ? mem_d_o[7]: 1'bz;
	assign mem_d[6] = (mem_d_oe[6]) ? mem_d_o[6]: 1'bz;
	assign mem_d[5] = (mem_d_oe[5]) ? mem_d_o[5]: 1'bz;
	assign mem_d[4] = (mem_d_oe[4]) ? mem_d_o[4]: 1'bz;
	assign mem_d[3] = (mem_d_oe[3]) ? mem_d_o[3]: 1'bz;
	assign mem_d[2] = (mem_d_oe[2]) ? mem_d_o[2]: 1'bz;
	assign mem_d[1] = (mem_d_oe[1]) ? mem_d_o[1]: 1'bz;
	assign mem_d[0] = (mem_d_oe[0]) ? mem_d_o[0]: 1'bz;
	

// PLL_A
	//wire		sys_pll_a_clk;
	//wire		sys_pll_a_locked;
	//pllx7per8_20to17_50	i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx1_20to20		i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx5per4_20to25	i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx3per2_20to30	i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx7per4_20to35	i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk),.locked(sys_pll_a_locked));
	//pllx2_20to40		i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx5per2_20to50	i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx3_20to60		i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx7per2_20to70	i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx4_20to80		i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
	//pllx6_20to120		i_pll_a (.inclk0(sys_clk0),.c0(sys_pll_a_clk));
// PLL_B
	//wire		sys_pll_b_clk;
	//wire		sys_pll_b_locked;
	//pllx7per8_20to17_50	i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk),.locked(sys_pll_b_locked));
	//pllx1_20to20		i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx5per4_20to25	i_pll_c (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx3per2_20to30	i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx7per4_20to35	i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx2_20to40		i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx5per2_20to50	i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx3_20to60		i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx7per2_20to70	i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx4_20to80		i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));
	//pllx6_20to120		i_pll_b (.inclk0(sys_clk0),.c0(sys_pll_b_clk));

	wire	[1:0]	sys_clmode;
	wire		sys_or1200_clk;
	wire		sys_wb_clk;
	wire		sys_mem_clk;
	wire		sys_sdram_clk;
	wire		sys_vga_clk;
	wire		sys_pll_locked;

//////////////////////////////////////////////
// Single PLL
// ExternalPin
//	sys_clk0: OpenRiscCPU,WinsBoneBus,VGA,Flash,SDRAM
//	sys_clk1: not use
//	sys_clk2: not use
//	sys_clk3: not use
//////////////////////////////////////////////
// CLOCK SPEC:[CPU][WB][FLASH][SDRAM][VGA]
`define CLOCK_25_25_50_50_25
//`define CLOCK_30_30_50_50_25
//`define CLOCK_25_25_60_60_25
//`define CLOCK_35_35_70_70_35

//`define CLOCK_40_20_40_40_40
//`define CLOCK_35_17P5_35_35_35

// x1
`ifdef CLOCK_25_25_50_50_25
	wire		sys_pll_a_clk;
	wire		sys_pll_b_clk;
	//wire		sys_pll_b_clk_div;
	pll_20to25AND50 i_pll (.inclk0(sys_clk0),.c0(sys_pll_a_clk),.c1(sys_pll_b_clk),.locked(sys_pll_locked));
	//div		i_div (.clock(sys_pll_b_clk),.q(sys_pll_b_clk_div));
	assign sys_clmode	= 2'b00;
	assign sys_or1200_clk	= sys_pll_a_clk;
	assign sys_wb_clk	= sys_pll_a_clk;
	assign sys_mem_clk	= sys_pll_b_clk;
	assign sys_sdram_clk	= sys_pll_b_clk;
	assign sys_vga_clk	= sys_pll_a_clk; // VESA 800x525(-4) just 60Hz at 25MHz
`endif
`ifdef CLOCK_30_30_50_50_25
	wire		sys_pll_a_clk;
	wire		sys_pll_b_clk;
	wire		sys_pll_b_clk_div;
	pll_20to30AND50 i_pll (.inclk0(sys_clk0),.c0(sys_pll_a_clk),.c1(sys_pll_b_clk),.locked(sys_pll_locked));
	div		i_div (.clock(sys_pll_b_clk),.q(sys_pll_b_clk_div));
	assign sys_clmode	= 2'b00;
	assign sys_or1200_clk	= sys_pll_a_clk;
	assign sys_wb_clk	= sys_pll_a_clk;
	assign sys_mem_clk	= sys_pll_b_clk;
	assign sys_sdram_clk	= sys_pll_b_clk;
	assign sys_vga_clk	= sys_pll_b_clk_div; // VESA 800x525(-4) just 60Hz at 25MHz,not related clock,but skew is ok.
`endif
`ifdef CLOCK_25_25_60_60_25
	wire		sys_pll_a_clk;
	wire		sys_pll_b_clk;
	//wire		sys_pll_b_clk_div;
	pll_20to25AND60 i_pll (.inclk0(sys_clk0),.c0(sys_pll_a_clk),.c1(sys_pll_b_clk),.locked(sys_pll_locked));
	//div		i_div (.clock(sys_pll_b_clk),.q(sys_pll_b_clk_div));
	assign sys_clmode	= 2'b00;
	assign sys_or1200_clk	= sys_pll_a_clk;
	assign sys_wb_clk	= sys_pll_a_clk;
	assign sys_mem_clk	= sys_pll_b_clk;
	assign sys_sdram_clk	= sys_pll_b_clk;
	assign sys_vga_clk	= sys_pll_a_clk; // VESA 800x525(-4) just 60Hz at 25MHz
`endif
`ifdef CLOCK_35_35_70_70_35
	wire		sys_pll_a_clk;
	wire		sys_pll_b_clk;
	//wire		sys_pll_b_clk_div;
	pll_20to35AND70 i_pll (.inclk0(sys_clk0),.c0(sys_pll_a_clk),.c1(sys_pll_b_clk),.locked(sys_pll_locked));
	//div		i_div (.clock(sys_pll_b_clk),.q(sys_pll_b_clk_div));
	assign sys_clmode	= 2'b00;
	assign sys_or1200_clk	= sys_pll_a_clk;
	assign sys_wb_clk	= sys_pll_a_clk;
	assign sys_mem_clk	= sys_pll_b_clk;
	assign sys_sdram_clk	= sys_pll_b_clk;
	assign sys_vga_clk	= sys_pll_a_clk; // VESA 800x525(-4) just 60Hz at 25MHz
`endif

// x2
`ifdef CLOCK_40_20_40_40_40
	wire		sys_pll_a_clk;
	wire		sys_pll_b_clk;
	//wire		sys_pll_b_clk_div;
	//wire		sys_pll_0_locked;
	//wire		sys_pll_1_locked;
	pll_20to20AND40 i_pll (.inclk0(sys_clk0),.c0(sys_pll_a_clk),.c1(sys_pll_b_clk),.locked(sys_pll_locked));
	//assign sys_pll_locked	= sys_pll_0_locked || sys_pll_1_locked;
	//div		i_div (.clock(sys_pll_b_clk),.q(sys_pll_b_clk_div));
	assign sys_clmode	= 2'b01;
	assign sys_or1200_clk	= sys_pll_b_clk; // related clock
	assign sys_wb_clk	= sys_pll_a_clk; // related clock
	assign sys_mem_clk	= sys_pll_b_clk;
	assign sys_sdram_clk	= sys_pll_b_clk;
	assign sys_vga_clk	= sys_pll_b_clk; // VGA illegal size((800+480-32 )x521) near 60Hz at 40MHz
`endif
`ifdef CLOCK_35_17P5_35_35_35
	wire		sys_pll_a_clk;
	wire		sys_pll_b_clk;
	//wire		sys_pll_b_clk_div;
	wire		sys_pll_0_locked;
	wire		sys_pll_1_locked;
	pll_20to17P5AND35 i_pll (.inclk0(sys_clk0),.c0(sys_pll_a_clk),.c1(sys_pll_b_clk),.locked(sys_pll_locked));
	assign sys_clmode	= 2'b01;
	assign sys_or1200_clk	= sys_pll_b_clk; // related clock
	assign sys_wb_clk	= sys_pll_a_clk; // related clock
	assign sys_mem_clk	= sys_pll_b_clk;
	assign sys_sdram_clk	= sys_pll_b_clk;
	assign sys_vga_clk	= sys_pll_b_clk; // VGA illegal size((800+480-192 )x521) near 60Hz at 35MHz
`endif

//////////////////////////////////////////////
// ExternalPin
//	sys_clk0: OpenRiscCPU,WinsBoneBus
//	sys_clk1: not use
//	sys_clk2: VGA,Flash,SDRAM(need external OSC)
//	sys_clk3: not use
//////////////////////////////////////////////
`ifdef CLOCK_DOUBLE_40_20_75_75_25
	wire		sys_pll_0_locked;
	wire		sys_pll_1_locked;
	pll_Xto40AND20 i_pll_0 (
		.inclk0(	sys_clk0),		// Reference
		.c0(		sys_pll_a_clk),		// OpenRisc CPU	:40MHz
		.c1(		sys_pll_b_clk),		// WishBone BUS	:20MHz
		.locked(	sys_pll_0_locked)
	);
	pll_Xto80AND25 i_pll_1 (
		.inclk0(	sys_clk2),		// Reference
		.c0(		sys_pll_c_clk),		// Flash,SDRAM	:75MHz
		.c1(		sys_pll_d_clk),		// VGA		:25MHz
		.locked(	sys_pll_1_locked)
	);
	assign sys_clmode	= 2'b01;
	assign sys_or1200_clk	= sys_pll_a_clk;
	assign sys_wb_clk	= sys_pll_b_clk;
	assign sys_mem_clk	= sys_pll_c_clk;
	assign sys_sdram_clk	= sys_pll_c_clk;
	assign sys_vga_clk	= sys_pll_d_clk;
	assign sys_pll_locked	= sys_pll_0_locked || sys_pll_1_locked;
`endif

// Reset
	//wire		sys_reset;
	//assign sys_reset = (!sys_reset_n) || (!sys_pll_locked);
	reg		sys_reset;
	always @(negedge sys_or1200_clk) sys_reset = (!sys_reset_n) || (!sys_pll_locked);

// OR1200 Clock and ResetRelease
// WishBone Clock and ResetRelease
	reg	[1:0]	sys_or1200_res_mt;
	reg		sys_or1200_res;
	reg	[1:0]	sys_wb_res_mt;
	reg		sys_wb_res;
	//always @(posedge sys_or1200_clk) sys_or1200_res_mt <= {sys_or1200_res_mt[0],sys_reset};
	//always @(negedge sys_or1200_clk) sys_or1200_res    <= #1 sys_or1200_res_mt[1];
	always @(negedge sys_or1200_clk) sys_or1200_res <= sys_wb_res;						// neg release

	always @(posedge sys_wb_clk) sys_wb_res_mt <= {sys_wb_res_mt[0],sys_reset};
	always @(negedge sys_wb_clk) sys_wb_res    <= sys_wb_res_mt[1];						// neg release

// External-Memory-Bus Clock and ResetRelease
	reg	[1:0]	sys_mem_res_mt;
	reg		sys_mem_res;
	always @(posedge sys_mem_clk) sys_mem_res_mt <= {sys_mem_res_mt[0],sys_reset};
	always @(negedge sys_mem_clk) sys_mem_res    <= sys_mem_res_mt[1];					// neg release

// SDRAM Clock and ResetRelease
	reg	[1:0]	sys_sdram_res_mt;
	reg		sys_sdram_res;
	always @(posedge sys_sdram_clk) sys_sdram_res_mt <= {sys_sdram_res_mt[0],sys_reset};
	always @(negedge sys_sdram_clk) sys_sdram_res    <= sys_sdram_res_mt[1];				// neg release

// VGA Clock and ResetRelease
	reg	[1:0]	sys_vga_res_mt;
	reg		sys_vga_res;
	always @(posedge sys_vga_clk) sys_vga_res_mt <= {sys_vga_res_mt[0],sys_reset};
	always @(negedge sys_vga_clk) sys_vga_res    <= sys_vga_res_mt[1];					// neg release

// sdram re-sync

	//50MHz(retiming 100MHz))
	//reg	[1:0]	dummy_a;
	//reg	[1:0]	dummy_b;
	//wire		local_sdram1_clk;
	//wire		local_sdram0_clk;
	//reg		sync1_sdram1_clk;
	//reg		sync1_sdram0_clk;
	//reg		sync2_sdram1_clk;
	//reg		sync2_sdram0_clk;
	//reg	[15:0]	snap1_sdram1_d;
	//reg	[15:0]	snap1_sdram0_d;
	//reg	[15:0]	snap2_sdram1_d;
	//reg	[15:0]	snap2_sdram0_d;
	//assign sdram1_clk = sync2_sdram1_clk;
	//assign sdram0_clk = sync2_sdram0_clk;
	//always @(negedge sys_pll_b_clk) dummy_a <= {dummy_a[0],misc_gpio[0]};
	//always @(negedge sys_pll_b_clk) dummy_b <= {dummy_b[0],misc_gpio[1]};
	//always @(negedge sys_pll_b_clk) sync1_sdram1_clk <= local_sdram1_clk && dummy_a[1];	// negedge its dummy to insert other ff
	//always @(negedge sys_pll_b_clk) sync1_sdram0_clk <= local_sdram0_clk && dummy_b[1];	// negedge its dummy to insert other ff
	//always @(posedge sys_pll_b_clk) sync2_sdram1_clk <= sync1_sdram1_clk;			// posedge
	//always @(posedge sys_pll_b_clk) sync2_sdram0_clk <= sync1_sdram0_clk;			// posedge
	//always @(posedge sys_pll_b_clk) snap1_sdram1_d  <= sdram1_d;				// posedge
	//always @(posedge sys_pll_b_clk) snap1_sdram0_d  <= sdram0_d;				// posedge
	//always @(negedge sys_pll_b_clk) snap2_sdram1_d  <= snap1_sdram1_d;			// negedge
	//always @(negedge sys_pll_b_clk) snap2_sdram0_d  <= snap1_sdram0_d;			// negedge

// simple snap
	wire		local_sdram1_clk;
	wire		local_sdram0_clk;
	reg	[15:0]	snap2_sdram1_d;
	reg	[15:0]	snap2_sdram0_d;
	assign sdram1_clk = !local_sdram1_clk;							// global signal,may be fast
	assign sdram0_clk = !local_sdram0_clk;							// global signal,may be fast
	always @(posedge sdram1_clk) snap2_sdram1_d  <= sdram1_d;				// to snap,same sdram_clk(sdram1_clk->sys_sdram_clk)
	always @(posedge sdram0_clk) snap2_sdram0_d  <= sdram0_d;				// to snap,same sdram_clk(sdram0_clk->sys_sdram_clk)
	
	// 25MHz(retiming 50MHz)
	//reg	[1:0]	dummy;
	//wire		local_vga_clk;
	//reg		sync1_vga_clkp;
	//reg		sync1_vga_clkn;
	//reg		sync2_vga_clkp;
	//reg		sync2_vga_clkn;
	//always @(negedge sys_pll_a_clk) dummy <= {dummy[0],misc_gpio[2]};
	//always @(negedge sys_pll_a_clk) sync1_vga_clkp <= local_vga_clk && dummy[1];		// negedge its dummy to insert other ff
	//always @(negedge sys_pll_a_clk) sync1_vga_clkn <= (!local_vga_clk) && dummy[1];		// negedge its dummy to insert other ff
	//always @(posedge sys_pll_a_clk) sync2_vga_clkp <= sync1_vga_clkp;			// posedge
	//always @(posedge sys_pll_a_clk) sync2_vga_clkn <= sync1_vga_clkn;			// posedge
	//assign vga_clkp = sync2_vga_clkp;
	//assign vga_clkn = sync2_vga_clkn;

// simple snap
	wire		local_vga_clk;
	assign vga_clkp = !local_vga_clk;
	assign vga_clkn = 1'b0;
	//assign vga_clkn = local_vga_clk;

// bus mode
	//assign sys_clmode = 2'b00;
	//assign sys_clmode = 2'b01;
	// clmode=2'b00=>DIV=1,so impliment is SAME-CLK! WBCLK=CPUCLK.
	// same-posedge-phase is ok....
	// clmode=2'b01=>DIV=2,WBCLK=(1/2)CPUCLK
	// clmode=2'b10=>NA
	// clmode=2'b11=>DIV=4,WBCLK=(1/4)CPUCLK

	//wire	[1:0]	local_sdram0_cs_n;
	//wire	[1:0]	local_sdram1_cs_n;
	
	tessera_core i_tessera_core (
		// system
		.sys_or1200_res(	sys_or1200_res||sys_reset),
		.sys_or1200_clk(	sys_or1200_clk),
		.sys_wb_res(		sys_wb_res||sys_reset),
		.sys_wb_clk(		sys_wb_clk),
		.sys_mem_res(		sys_mem_res||sys_reset),
		.sys_mem_clk(		sys_mem_clk),
		.sys_sdram_res(		sys_sdram_res||sys_reset),
		.sys_sdram_clk(		sys_sdram_clk),
		.sys_vga_res(		sys_vga_res||sys_reset),
		.sys_vga_clk(		sys_vga_clk),
		//
		.sys_clmode(	sys_clmode),
		// jtag(not-used)
		.jtag_tms(	1'b0/*jtag_tms*/),
		.jtag_tck(	1'b0/*jtag_tck*/),
		.jtag_trst(	1'b0/*jtag_trst*/),
		.jtag_tdi(	1'b0/*jtag_tdi*/),
		.jtag_tdo_o(	/* not used *//*jtag_tdo_o*/),
		.jtag_tdo_oe(	/* not used *//*jtag_tdo_oe*/),
		// uart
		.uart_stx(	uart_txd),
		.uart_srx(	uart_rxd),
		.uart_rts(	uart_rts_n),
		.uart_cts(	uart_cts_n),
		.uart_dtr(	uart_dtr_n),
		.uart_dsr(	uart_dsr_n),
		.uart_ri(	uart_ri_n),
		.uart_dcd(	uart_dcd_n),
		// mem-bus
		.mem_cs2_n(	mem_cs2_n),
		.mem_cs2_g_n(	mem_cs2_g_n),
		.mem_cs2_dir(	mem_cs2_dir),
		.mem_cs2_rstdrv(mem_cs2_rstdrv),
		.mem_cs2_int(	mem_cs2_int),
		.mem_cs2_iochrdy(mem_cs2_iochrdy),
		.mem_cs1_n(	mem_cs1_n),
		.mem_cs1_rst_n(	mem_cs1_rst_n),
		.mem_cs1_rdy(	mem_cs1_rdy),
		.mem_cs0_n(	mem_cs0_n),
		.mem_we_n(	mem_we_n),
		.mem_oe_n(	mem_oe_n),
		.mem_a(		mem_a),
		.mem_d_o(	mem_d_o),
		.mem_d_oe(	mem_d_oe),
		.mem_d_i(	mem_d),
		// sdram0
		//.sdram0_clk(	sdram0_clk),
		.sdram0_clk(	local_sdram0_clk),	// phase-shift
		.sdram0_cke(	sdram0_cke),
		.sdram0_cs_n(	sdram0_cs_n),
		.sdram0_ras_n(	sdram0_ras_n),
		.sdram0_cas_n(	sdram0_cas_n),
		.sdram0_we_n(	sdram0_we_n),
		.sdram0_dqm(	sdram0_dqm),
		.sdram0_ba(	sdram0_ba),
		.sdram0_a(	sdram0_a),
		//.sdram0_d_i(	sdram0_d),
		.sdram0_d_i(	snap2_sdram0_d),	// pre-register
		.sdram0_d_oe(	sdram0_d_oe),
		.sdram0_d_o(	sdram0_d_o),
		// sdram1
		//.sdram1_clk(	sdram1_clk),
		.sdram1_clk(	local_sdram1_clk),	// phase-shift
		.sdram1_cke(	sdram1_cke),
		.sdram1_cs_n(	sdram1_cs_n),
		.sdram1_ras_n(	sdram1_ras_n),
		.sdram1_cas_n(	sdram1_cas_n),
		.sdram1_we_n(	sdram1_we_n),
		.sdram1_dqm(	sdram1_dqm),
		.sdram1_ba(	sdram1_ba),
		.sdram1_a(	sdram1_a),
		//.sdram1_d_i(	sdram1_d),
		.sdram1_d_i(	snap2_sdram1_d),	// pre-register
		.sdram1_d_oe(	sdram1_d_oe),
		.sdram1_d_o(	sdram1_d_o),
		// vga
		.vga_clk(	local_vga_clk),
		.vga_hsync(	vga_hsync),
		.vga_vsync(	vga_vsync),
		.vga_blank(	vga_blank),
		.vga_d(		vga_d),
		// tet
		.option(	misc_gpio[0])
	);

// not-fix(output-pin-clamp)
	//
	assign sys_init_n	= 1'b1; // to re-config
	//
	assign misc_tp		= 1'b0;	// LED on:0 off:1
	//
	//assign sdram0_cs_n[0]	= local_sdram0_cs_n[0];
	//assign sdram0_cs_n[1]	= 1'b1;
	//
	//assign sdram1_cs_n[0]	= local_sdram1_cs_n[0];
	//assign sdram1_cs_n[1]	= 1'b1;

endmodule

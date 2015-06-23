`include "minsoc_defines.v"
`include "or1200_defines.v"

`include "gpio_defines.v"

module minsoc_top (
   clk,reset

   //JTAG ports
`ifdef GENERIC_TAP
   , jtag_tdi,jtag_tms,jtag_tck,
   jtag_tdo,jtag_vref,jtag_gnd
`endif

   //SPI ports
`ifdef START_UP
   , spi_flash_mosi, spi_flash_miso, spi_flash_sclk, spi_flash_ss
`endif
     
   //UART ports
`ifdef UART
   , uart_stx,uart_srx
`endif

	// Ethernet ports
`ifdef ETHERNET
	, eth_col, eth_crs, eth_trste, eth_tx_clk,
	eth_tx_en, eth_tx_er, eth_txd, eth_rx_clk,
	eth_rx_dv, eth_rx_er, eth_rxd, eth_fds_mdint,
	eth_mdc, eth_mdio
`endif

	// GPIO ports
`ifdef GPIO
    `ifdef GPIO_HAS_INPUT_PINS
	     ,i_pins
	 `endif	  
	 `ifdef GPIO_HAS_OUTPUT_PINS
		  ,o_pins
	 `endif
	 `ifdef GPIO_HAS_BIDIR_PINS
		  ,io_pins
	 `endif
`endif	
);

//
// I/O Ports
//

   input         clk;
   input         reset;

//
// SPI controller external i/f wires
//
`ifdef START_UP
output spi_flash_mosi;
input spi_flash_miso;
output spi_flash_sclk;
output [1:0] spi_flash_ss;
`endif

//
// UART
//
`ifdef UART
   output        uart_stx;
   input         uart_srx;
`endif

//
// Ethernet
//
`ifdef ETHERNET
output			eth_tx_er;
input			eth_tx_clk;
output			eth_tx_en;
output	[3:0]		eth_txd;
input			eth_rx_er;
input			eth_rx_clk;
input			eth_rx_dv;
input	[3:0]		eth_rxd;
input			eth_col;
input			eth_crs;
output			eth_trste;
input			eth_fds_mdint;
inout			eth_mdio;
output			eth_mdc;
`endif

//
// GPIO
//
`ifdef GPIO
    `ifdef GPIO_HAS_INPUT_PINS
        input [`GPIO_NUM_INPUT-1:0] i_pins;
	 `endif	  
	 `ifdef GPIO_HAS_OUTPUT_PINS
        output [`GPIO_NUM_OUTPUT-1:0] o_pins;
	 `endif
	 `ifdef GPIO_HAS_BIDIR_PINS
        inout [`GPIO_NUM_BIDIR-1:0] io_pins;
	 `endif
`endif

//
// JTAG
//
`ifdef GENERIC_TAP
   input         jtag_tdi;
   input         jtag_tms;
   input         jtag_tck;
   output        jtag_tdo;
   output	 jtag_vref;
   output	 jtag_gnd;


assign jtag_vref = 1'b1;
assign jtag_gnd = 1'b0;
`endif

wire rstn;

`ifdef POSITIVE_RESET
assign rstn = ~reset;
`elsif NEGATIVE_RESET
assign rstn = reset;
`endif

//
// Internal wires
//

//
// Debug core master i/f wires
//
wire 	[31:0]		wb_dm_adr_o;
wire 	[31:0] 		wb_dm_dat_i;
wire 	[31:0] 		wb_dm_dat_o;
wire 	[3:0]		wb_dm_sel_o;
wire			wb_dm_we_o;
wire 			wb_dm_stb_o;
wire			wb_dm_cyc_o;
wire			wb_dm_ack_i;
wire			wb_dm_err_i;

//
// Debug <-> RISC wires
//
wire	[3:0]		dbg_lss;
wire	[1:0]		dbg_is;
wire	[10:0]		dbg_wp;
wire			dbg_bp;
wire	[31:0]		dbg_dat_dbg;
wire	[31:0]		dbg_dat_risc;
wire	[31:0]		dbg_adr;
wire			dbg_ewt;
wire			dbg_stall;
wire	[2:0]		dbg_op;     //dbg_op[0] = dbg_we //dbg_op[2] = dbg_stb  (didn't change for backward compatibility with DBG_IF_MODEL
wire            	dbg_ack;

//
// RISC instruction master i/f wires
//
wire 	[31:0]		wb_rim_adr_o;
wire			wb_rim_cyc_o;
wire 	[31:0]		wb_rim_dat_i;
wire 	[31:0]		wb_rim_dat_o;
wire 	[3:0]		wb_rim_sel_o;
wire			wb_rim_ack_i;
wire			wb_rim_err_i;
wire			wb_rim_rty_i = 1'b0;
wire			wb_rim_we_o;
wire			wb_rim_stb_o;
wire	[31:0]		wb_rif_dat_i;
wire			wb_rif_ack_i;

//
// RISC data master i/f wires
//
wire 	[31:0]		wb_rdm_adr_o;
wire			wb_rdm_cyc_o;
wire 	[31:0]		wb_rdm_dat_i;
wire 	[31:0]		wb_rdm_dat_o;
wire 	[3:0]		wb_rdm_sel_o;
wire			wb_rdm_ack_i;
wire			wb_rdm_err_i;
wire			wb_rdm_rty_i = 1'b0;
wire			wb_rdm_we_o;
wire			wb_rdm_stb_o;

//
// RISC misc
//
wire	[19:0]		pic_ints;

//
// Flash controller slave i/f wires
//
wire 	[31:0]		wb_fs_dat_i;
wire 	[31:0]		wb_fs_dat_o;
wire 	[31:0]		wb_fs_adr_i;
wire 	[3:0]		wb_fs_sel_i;
wire			wb_fs_we_i;
wire			wb_fs_cyc_i;
wire			wb_fs_stb_i;
wire			wb_fs_ack_o;
wire			wb_fs_err_o;

//
// SPI controller slave i/f wires
//
wire 	[31:0]		wb_sp_dat_i;
wire 	[31:0]		wb_sp_dat_o;
wire 	[31:0]		wb_sp_adr_i;
wire 	[3:0]		wb_sp_sel_i;
wire			wb_sp_we_i;
wire			wb_sp_cyc_i;
wire			wb_sp_stb_i;
wire			wb_sp_ack_o;
wire			wb_sp_err_o;

//
// SPI controller external i/f wires
//
wire spi_flash_mosi;
wire spi_flash_miso;
wire spi_flash_sclk;
wire [1:0] spi_flash_ss;

//
// SRAM controller slave i/f wires
//
wire 	[31:0]		wb_ss_dat_i;
wire 	[31:0]		wb_ss_dat_o;
wire 	[31:0]		wb_ss_adr_i;
wire 	[3:0]		wb_ss_sel_i;
wire			wb_ss_we_i;
wire			wb_ss_cyc_i;
wire			wb_ss_stb_i;
wire			wb_ss_ack_o;
wire			wb_ss_err_o;

//
// Ethernet core master i/f wires
//
wire 	[31:0]		wb_em_adr_o;
wire 	[31:0] 		wb_em_dat_i;
wire 	[31:0] 		wb_em_dat_o;
wire 	[3:0]		wb_em_sel_o;
wire			wb_em_we_o;
wire 			wb_em_stb_o;
wire			wb_em_cyc_o;
wire			wb_em_ack_i;
wire			wb_em_err_i;

//
// Ethernet core slave i/f wires
//
wire	[31:0]		wb_es_dat_i;
wire	[31:0]		wb_es_dat_o;
wire	[31:0]		wb_es_adr_i;
wire	[3:0]		wb_es_sel_i;
wire			wb_es_we_i;
wire			wb_es_cyc_i;
wire			wb_es_stb_i;
wire			wb_es_ack_o;
wire			wb_es_err_o;

//
// Ethernet external i/f wires
//
wire			eth_mdo;
wire			eth_mdoe;

//
// UART16550 core slave i/f wires
//
wire	[31:0]		wb_us_dat_i;
wire	[31:0]		wb_us_dat_o;
wire	[31:0]		wb_us_adr_i;
wire	[3:0]		wb_us_sel_i;
wire			wb_us_we_i;
wire			wb_us_cyc_i;
wire			wb_us_stb_i;
wire			wb_us_ack_o;
wire			wb_us_err_o;

//
// UART external i/f wires
//
wire			uart_stx;
wire			uart_srx;

//
// GPIO core slave i/f wires
//
wire	[31:0]		wb_gpio_dat_i;
wire	[31:0]		wb_gpio_dat_o;
wire	[31:0]		wb_gpio_adr_i;
wire	[3:0]		wb_gpio_sel_i;
wire			wb_gpio_we_i;
wire			wb_gpio_cyc_i;
wire			wb_gpio_stb_i;
wire			wb_gpio_ack_o;
wire			wb_gpio_err_o;

//
// Interface to GPIO core - Device specific core
//
wire [`GPIO_IOS:0]	ext_pad_o;
wire [`GPIO_IOS:0]	ext_pad_i;
wire [`GPIO_IOS:0]	ext_pad_oe_o;

//
// Reset debounce
//
reg			rst_r;
reg			wb_rst;

//
// Global clock
//
wire			wb_clk;

//
// Reset debounce
//
always @(posedge wb_clk or negedge rstn)
	if (~rstn)
		rst_r <= 1'b1;
	else
		rst_r <= #1 1'b0;

//
// Reset debounce
//
always @(posedge wb_clk)
	wb_rst <= #1 rst_r;

//
// Clock Divider
//
minsoc_clock_manager #
(
   .divisor(`CLOCK_DIVISOR)
)
clk_adjust (
	.clk_i(clk),
	.clk_o(wb_clk)
);

//
// Unused WISHBONE signals
//
assign wb_us_err_o = 1'b0;
assign wb_fs_err_o = 1'b0;
assign wb_sp_err_o = 1'b0;

//
// Unused interrupts
//
assign pic_ints[`APP_INT_RES1] = 'b0;
assign pic_ints[`APP_INT_RES2] = 'b0;
assign pic_ints[`APP_INT_RES3] = 'b0;
assign pic_ints[`APP_INT_PS2] = 'b0;

//
// Ethernet tri-state
//
`ifdef ETHERNET
assign eth_mdio = eth_mdoe ? eth_mdo : 1'bz;
assign eth_trste = `ETH_RESET;
`endif


//
// RISC Instruction address for Flash
//
// Until first access to real Flash area,
// CPU instruction is fixed to jump to the Flash area.
// After Flash area is accessed, CPU instructions 
// come from the tc_top (wishbone "switch").
//
`ifdef START_UP
reg jump_flash;
reg [3:0] rif_counter;
reg [31:0] rif_dat_int;
reg rif_ack_int;

always @(posedge wb_clk or negedge rstn)
begin
	if (!rstn) begin
		jump_flash <= #1 1'b1;
		rif_counter <= 4'h0;
		rif_ack_int <= 1'b0;
	end
	else begin
		rif_ack_int <= 1'b0;

		if (wb_rim_cyc_o && (wb_rim_adr_o[31:32-`APP_ADDR_DEC_W] == `APP_ADDR_FLASH))
			jump_flash <= #1 1'b0;
		
		if ( jump_flash == 1'b1 ) begin
			if ( wb_rim_cyc_o && wb_rim_stb_o && ~wb_rim_we_o ) begin
				rif_counter <= rif_counter + 1'b1;
				rif_ack_int <= 1'b1;
			end
		end
	end
end

always @ (rif_counter)
begin
	case ( rif_counter )
		4'h0: rif_dat_int = { `OR1200_OR32_MOVHI , 5'h01 , 4'h0 , 1'b0 , `APP_ADDR_FLASH , 8'h00 };
		4'h1: rif_dat_int = { `OR1200_OR32_ORI , 5'h01 , 5'h01 , 16'h0000 };
		4'h2: rif_dat_int = { `OR1200_OR32_JR , 10'h000 , 5'h01 , 11'h000 };
		4'h3: rif_dat_int = { `OR1200_OR32_NOP , 10'h000 , 16'h0000 };
		default: rif_dat_int = 32'h0000_0000;
	endcase
end

assign wb_rif_dat_i = jump_flash ? rif_dat_int : wb_rim_dat_i;

assign wb_rif_ack_i = jump_flash ? rif_ack_int : wb_rim_ack_i;

`else
assign wb_rif_dat_i = wb_rim_dat_i;
assign wb_rif_ack_i = wb_rim_ack_i;
`endif


//
// TAP<->dbg_interface
//      
wire jtag_tck;
wire debug_tdi;
wire debug_tdo;
wire capture_dr;
wire shift_dr;
wire pause_dr;
wire update_dr;   

wire debug_select;
wire test_logic_reset;

//
// Instantiation of the development i/f
//
adbg_top dbg_top  (

	// JTAG pins
      .tck_i	( jtag_tck ),
      .tdi_i	( debug_tdi ),
      .tdo_o	( debug_tdo ),
      .rst_i	( test_logic_reset ),		//cable without rst

	// Boundary Scan signals
      .capture_dr_i ( capture_dr ),
      .shift_dr_i  ( shift_dr ),
      .pause_dr_i  ( pause_dr ),
      .update_dr_i ( update_dr ),

      .debug_select_i( debug_select ),
	// WISHBONE common
      .wb_clk_i   ( wb_clk ),

      // WISHBONE master interface
      .wb_adr_o  ( wb_dm_adr_o ),
      .wb_dat_i  ( wb_dm_dat_i ),
      .wb_dat_o  ( wb_dm_dat_o ),
      .wb_sel_o  ( wb_dm_sel_o ),
      .wb_we_o   ( wb_dm_we_o  ),
      .wb_stb_o  ( wb_dm_stb_o ),
      .wb_cyc_o  ( wb_dm_cyc_o ),
      .wb_ack_i  ( wb_dm_ack_i ),
      .wb_err_i  ( wb_dm_err_i ),
      .wb_cti_o  ( ),
      .wb_bte_o  ( ),
   
      // RISC signals
      .cpu0_clk_i  ( wb_clk ),
      .cpu0_addr_o ( dbg_adr ),
      .cpu0_data_i ( dbg_dat_risc ),
      .cpu0_data_o ( dbg_dat_dbg ),
      .cpu0_bp_i   ( dbg_bp ),
      .cpu0_stall_o( dbg_stall ),
      .cpu0_stb_o  ( dbg_op[2] ),
      .cpu0_we_o   ( dbg_op[0] ),
      .cpu0_ack_i  ( dbg_ack ),
      .cpu0_rst_o  ( )

);

//
// JTAG TAP controller instantiation
//
`ifdef GENERIC_TAP
tap_top tap_top(
	 // JTAG pads
	 .tms_pad_i(jtag_tms), 
	 .tck_pad_i(jtag_tck), 
	 .trstn_pad_i(rstn), 
	 .tdi_pad_i(jtag_tdi), 
	 .tdo_pad_o(jtag_tdo), 
	 .tdo_padoe_o( ),

	 // TAP states
	 .test_logic_reset_o( test_logic_reset ),
	 .run_test_idle_o(),
	 .shift_dr_o(shift_dr),
	 .pause_dr_o(pause_dr), 
	 .update_dr_o(update_dr),
	 .capture_dr_o(capture_dr),
	 
	 // Select signals for boundary scan or mbist
	 .extest_select_o(), 
	 .sample_preload_select_o(),
	 .mbist_select_o(),
	 .debug_select_o(debug_select),
	 
	 // TDO signal that is connected to TDI of sub-modules.
	 .tdi_o(debug_tdi), 
	 
	 // TDI signals from sub-modules
	 .debug_tdo_i(debug_tdo),    // from debug module
	 .bs_chain_tdo_i(1'b0), // from Boundary Scan Chain
	 .mbist_tdo_i(1'b0)     // from Mbist Chain
);
`elsif FPGA_TAP
`ifdef ALTERA_FPGA
altera_virtual_jtag tap_top(
	.tck_o(jtag_tck),
	.debug_tdo_o(debug_tdo),
	.tdi_o(debug_tdi),
	.test_logic_reset_o(test_logic_reset),
	.run_test_idle_o(),
	.shift_dr_o(shift_dr),
	.capture_dr_o(capture_dr),
	.pause_dr_o(pause_dr),
	.update_dr_o(update_dr),
	.debug_select_o(debug_select)
);
`elsif XILINX_FPGA
minsoc_xilinx_internal_jtag tap_top(
	.tck_o( jtag_tck ),
	.debug_tdo_i( debug_tdo ),
	.tdi_o( debug_tdi ),

	.test_logic_reset_o( test_logic_reset ),
	.run_test_idle_o( ),

	.shift_dr_o( shift_dr ),
	.capture_dr_o( capture_dr ),
	.pause_dr_o( pause_dr ),
	.update_dr_o( update_dr ),
	.debug_select_o( debug_select )
);
`endif // !FPGA_TAP

`endif // !GENERIC_TAP

//
// Instantiation of the OR1200 RISC
//
or1200_top or1200_top (

	// Common
	.rst_i		( wb_rst ),
	.clk_i		( wb_clk ),
`ifdef OR1200_CLMODE_1TO2
	.clmode_i	( 2'b01 ),
`else
`ifdef OR1200_CLMODE_1TO4
	.clmode_i	( 2'b11 ),
`else
	.clmode_i	( 2'b00 ),
`endif
`endif

	// WISHBONE Instruction Master
	.iwb_clk_i	( wb_clk ),
	.iwb_rst_i	( wb_rst ),
	.iwb_cyc_o	( wb_rim_cyc_o ),
	.iwb_adr_o	( wb_rim_adr_o ),
	.iwb_dat_i	( wb_rif_dat_i ),
	.iwb_dat_o	( wb_rim_dat_o ),
	.iwb_sel_o	( wb_rim_sel_o ),
	.iwb_ack_i	( wb_rif_ack_i ),
	.iwb_err_i	( wb_rim_err_i ),
	.iwb_rty_i	( wb_rim_rty_i ),
	.iwb_we_o	( wb_rim_we_o  ),
	.iwb_stb_o	( wb_rim_stb_o ),

	// WISHBONE Data Master
	.dwb_clk_i	( wb_clk ),
	.dwb_rst_i	( wb_rst ),
	.dwb_cyc_o	( wb_rdm_cyc_o ),
	.dwb_adr_o	( wb_rdm_adr_o ),
	.dwb_dat_i	( wb_rdm_dat_i ),
	.dwb_dat_o	( wb_rdm_dat_o ),
	.dwb_sel_o	( wb_rdm_sel_o ),
	.dwb_ack_i	( wb_rdm_ack_i ),
	.dwb_err_i	( wb_rdm_err_i ),
	.dwb_rty_i	( wb_rdm_rty_i ),
	.dwb_we_o	( wb_rdm_we_o  ),
	.dwb_stb_o	( wb_rdm_stb_o ),

	// Debug
	.dbg_stall_i	( dbg_stall ),
	.dbg_dat_i	( dbg_dat_dbg ),
	.dbg_adr_i	( dbg_adr ),
	.dbg_ewt_i	( 1'b0 ),
	.dbg_lss_o	( dbg_lss ),
	.dbg_is_o	( dbg_is ),
	.dbg_wp_o	( dbg_wp ),
	.dbg_bp_o	( dbg_bp ),
	.dbg_dat_o	( dbg_dat_risc ),
	.dbg_ack_o	( dbg_ack ),
	.dbg_stb_i	( dbg_op[2] ),
	.dbg_we_i	( dbg_op[0] ),

	// Power Management
	.pm_clksd_o	( ),
	.pm_cpustall_i	( 1'b0 ),
	.pm_dc_gate_o	( ),
	.pm_ic_gate_o	( ),
	.pm_dmmu_gate_o	( ),
	.pm_immu_gate_o	( ),
	.pm_tt_gate_o	( ),
	.pm_cpu_gate_o	( ),
	.pm_wakeup_o	( ),
	.pm_lvolt_o	( ),

	// Interrupts
	.pic_ints_i	( pic_ints )
);

//
// Startup OR1k
//
`ifdef START_UP
OR1K_startup OR1K_startup0
(
    .wb_adr_i(wb_fs_adr_i[6:2]),
    .wb_stb_i(wb_fs_stb_i),
    .wb_cyc_i(wb_fs_cyc_i),
    .wb_dat_o(wb_fs_dat_o),
    .wb_ack_o(wb_fs_ack_o),
    .wb_clk(wb_clk),
    .wb_rst(wb_rst)
);

spi_flash_top #
(
   .divider(0),
   .divider_len(2)
)
spi_flash_top0
(
   .wb_clk_i(wb_clk), 
   .wb_rst_i(wb_rst),
   .wb_adr_i(wb_sp_adr_i[4:2]),
   .wb_dat_i(wb_sp_dat_i), 
   .wb_dat_o(wb_sp_dat_o),
   .wb_sel_i(wb_sp_sel_i),
   .wb_we_i(wb_sp_we_i),
   .wb_stb_i(wb_sp_stb_i), 
   .wb_cyc_i(wb_sp_cyc_i),
   .wb_ack_o(wb_sp_ack_o), 

   .mosi_pad_o(spi_flash_mosi),
   .miso_pad_i(spi_flash_miso),
   .sclk_pad_o(spi_flash_sclk),
   .ss_pad_o(spi_flash_ss)
);
`else
assign wb_fs_dat_o = 32'h0000_0000;
assign wb_fs_ack_o = 1'b0;
assign wb_sp_dat_o = 32'h0000_0000;
assign wb_sp_ack_o = 1'b0;
`endif

//
// Instantiation of the SRAM controller
//
minsoc_onchip_ram_top # 
(
    .adr_width(`MEMORY_ADR_WIDTH)     //16 blocks of 2048 bytes memory 32768
)
onchip_ram_top (

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE slave
	.wb_dat_i	( wb_ss_dat_i ),
	.wb_dat_o	( wb_ss_dat_o ),
	.wb_adr_i	( wb_ss_adr_i ),
	.wb_sel_i	( wb_ss_sel_i ),
	.wb_we_i	( wb_ss_we_i  ),
	.wb_cyc_i	( wb_ss_cyc_i ),
	.wb_stb_i	( wb_ss_stb_i ),
	.wb_ack_o	( wb_ss_ack_o ),
	.wb_err_o	( wb_ss_err_o )
);

//
// Instantiation of the UART16550
//
`ifdef UART
uart_top uart_top (

	// WISHBONE common
	.wb_clk_i	( wb_clk ), 
	.wb_rst_i	( wb_rst ),

	// WISHBONE slave
	.wb_adr_i	( wb_us_adr_i[4:0] ),
	.wb_dat_i	( wb_us_dat_i ),
	.wb_dat_o	( wb_us_dat_o ),
	.wb_we_i	( wb_us_we_i  ),
	.wb_stb_i	( wb_us_stb_i ),
	.wb_cyc_i	( wb_us_cyc_i ),
	.wb_ack_o	( wb_us_ack_o ),
	.wb_sel_i	( wb_us_sel_i ),

	// Interrupt request
	.int_o		( pic_ints[`APP_INT_UART] ),

	// UART signals
	// serial input/output
	.stx_pad_o	( uart_stx ),
	.srx_pad_i	( uart_srx ),

	// modem signals
	.rts_pad_o	( ),
	.cts_pad_i	( 1'b0 ),
	.dtr_pad_o	( ),
	.dsr_pad_i	( 1'b0 ),
	.ri_pad_i	( 1'b0 ),
	.dcd_pad_i	( 1'b0 )
);
`else
assign wb_us_dat_o = 32'h0000_0000;
assign wb_us_ack_o = 1'b0;
`endif


//
// Instantiation of the GPIO
//
`ifdef GPIO
gpio_top #( .gw(`GPIO_IOS + 1) )
gpio_top_inst (

	// WISHBONE common
	.wb_clk_i	( wb_clk ), 
	.wb_rst_i	( wb_rst ),

	// WISHBONE slave
	.wb_adr_i	( wb_gpio_adr_i[4:0] ),
	.wb_dat_i	( wb_gpio_dat_i ),
	.wb_dat_o	( wb_gpio_dat_o ),
	.wb_we_i	   ( wb_gpio_we_i  ),
	.wb_stb_i	( wb_gpio_stb_i ),
	.wb_cyc_i	( wb_gpio_cyc_i ),
	.wb_ack_o	( wb_gpio_ack_o ),
	.wb_sel_i	( wb_gpio_sel_i ),

	// Interrupt request
	.wb_inta_o		( pic_ints[`APP_INT_GPIO] ),

	// GPIO external signals
	.ext_pad_o	( ext_pad_o ),
	.ext_pad_i	( ext_pad_i ),
	.ext_padoe_o( ext_pad_oe_o )

);

minsoc_spartan_3a_starter_kit_ios #( .gpio_num(`GPIO_IOS + 1),
	 `ifdef GPIO_HAS_INPUT_PINS
	     .i_line_num(`GPIO_NUM_INPUT),
	 `endif	  
	 `ifdef GPIO_HAS_OUTPUT_PINS
        .o_line_num(`GPIO_NUM_OUTPUT),
	 `endif	  
	 `ifdef GPIO_HAS_BIDIR_PINS
	     .io_line_num(`GPIO_NUM_BIDIR)
	 `endif						 
) minsoc_spartan_3a_starter_kit_ios_inst_0 (
    .ext_pad_o( ext_pad_o ),
    .ext_pad_oe( ext_pad_oe_o ),
    .ext_pad_i( ext_pad_i ),
	 `ifdef GPIO_HAS_INPUT_PINS
	     .i_pins( i_pins ),
	 `else
	     .i_pins( ),
	 `endif	  
	 `ifdef GPIO_HAS_OUTPUT_PINS
	     .o_pins( o_pins ),
	 `else
	     .o_pins( ),
	 `endif
	 `ifdef GPIO_HAS_BIDIR_PINS
	     .io_pins( io_pins )
	 `else
	     .io_pins( )
	 `endif
); 												 
												 
`else
assign wb_gpio_dat_o = 32'h0000_0000;
assign wb_gpio_ack_o = 1'b0;
`endif



//
// Instantiation of the Ethernet 10/100 MAC
//
`ifdef ETHERNET
eth_top eth_top (

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE slave
	.wb_dat_i	( wb_es_dat_i ),
	.wb_dat_o	( wb_es_dat_o ),
	.wb_adr_i	( wb_es_adr_i[11:2] ),
	.wb_sel_i	( wb_es_sel_i ),
	.wb_we_i	( wb_es_we_i  ),
	.wb_cyc_i	( wb_es_cyc_i ),
	.wb_stb_i	( wb_es_stb_i ),
	.wb_ack_o	( wb_es_ack_o ),
	.wb_err_o	( wb_es_err_o ), 

	// WISHBONE master
	.m_wb_adr_o	( wb_em_adr_o ),
	.m_wb_sel_o	( wb_em_sel_o ),
	.m_wb_we_o	( wb_em_we_o  ), 
	.m_wb_dat_o	( wb_em_dat_o ),
	.m_wb_dat_i	( wb_em_dat_i ),
	.m_wb_cyc_o	( wb_em_cyc_o ), 
	.m_wb_stb_o	( wb_em_stb_o ),
	.m_wb_ack_i	( wb_em_ack_i ),
	.m_wb_err_i	( wb_em_err_i ), 

	// TX
	.mtx_clk_pad_i	( eth_tx_clk ),
	.mtxd_pad_o	( eth_txd ),
	.mtxen_pad_o	( eth_tx_en ),
	.mtxerr_pad_o	( eth_tx_er ),

	// RX
	.mrx_clk_pad_i	( eth_rx_clk ),
	.mrxd_pad_i	( eth_rxd ),
	.mrxdv_pad_i	( eth_rx_dv ),
	.mrxerr_pad_i	( eth_rx_er ),
	.mcoll_pad_i	( eth_col ),
	.mcrs_pad_i	( eth_crs ),
  
	// MIIM
	.mdc_pad_o	( eth_mdc ),
	.md_pad_i	( eth_mdio ),
	.md_pad_o	( eth_mdo ),
	.md_padoe_o	( eth_mdoe ),

	// Interrupt
	.int_o		( pic_ints[`APP_INT_ETH] )
);
`else
assign wb_es_dat_o = 32'h0000_0000;
assign wb_es_ack_o = 1'b0;

assign wb_em_adr_o = 32'h0000_0000;
assign wb_em_sel_o = 4'h0;
assign wb_em_we_o = 1'b0;
assign wb_em_dat_o = 32'h0000_0000;
assign wb_em_cyc_o = 1'b0;
assign wb_em_stb_o = 1'b0;
`endif

//
// Instantiation of the Traffic COP
//
minsoc_tc_top #(`APP_ADDR_DEC_W,
	 `APP_ADDR_SRAM,
	 `APP_ADDR_DEC_W,
	 `APP_ADDR_FLASH,
	 `APP_ADDR_DECP_W,
	 `APP_ADDR_PERIP,
	 `APP_ADDR_DEC_W,
	 `APP_ADDR_SPI,
	 `APP_ADDR_ETH,
	 `APP_ADDR_AUDIO,
	 `APP_ADDR_UART,
	 `APP_ADDR_PS2,
	 `APP_ADDR_GPIO,
	 `APP_ADDR_RES2
	) tc_top (

	// WISHBONE common
	.wb_clk_i	( wb_clk ),
	.wb_rst_i	( wb_rst ),

	// WISHBONE Initiator 0
	.i0_wb_cyc_i	( 1'b0 ),
	.i0_wb_stb_i	( 1'b0 ),
	.i0_wb_adr_i	( 32'h0000_0000 ),
	.i0_wb_sel_i	( 4'b0000 ),
	.i0_wb_we_i	( 1'b0 ),
	.i0_wb_dat_i	( 32'h0000_0000 ),
	.i0_wb_dat_o	( ),
	.i0_wb_ack_o	( ),
	.i0_wb_err_o	( ),

	// WISHBONE Initiator 1
	.i1_wb_cyc_i	( wb_em_cyc_o ),
	.i1_wb_stb_i	( wb_em_stb_o ),
	.i1_wb_adr_i	( wb_em_adr_o ),
	.i1_wb_sel_i	( wb_em_sel_o ),
	.i1_wb_we_i	( wb_em_we_o  ),
	.i1_wb_dat_i	( wb_em_dat_o ),
	.i1_wb_dat_o	( wb_em_dat_i ),
	.i1_wb_ack_o	( wb_em_ack_i ),
	.i1_wb_err_o	( wb_em_err_i ),

	// WISHBONE Initiator 2
	.i2_wb_cyc_i	( 1'b0 ),
	.i2_wb_stb_i	( 1'b0 ),
	.i2_wb_adr_i	( 32'h0000_0000 ),
	.i2_wb_sel_i	( 4'b0000 ),
	.i2_wb_we_i	( 1'b0 ),
	.i2_wb_dat_i	( 32'h0000_0000 ),
	.i2_wb_dat_o	( ),
	.i2_wb_ack_o	( ),
	.i2_wb_err_o	( ),

	// WISHBONE Initiator 3
	.i3_wb_cyc_i	( wb_dm_cyc_o ),
	.i3_wb_stb_i	( wb_dm_stb_o ),
	.i3_wb_adr_i	( wb_dm_adr_o ),
	.i3_wb_sel_i	( wb_dm_sel_o ),
	.i3_wb_we_i	( wb_dm_we_o  ),
	.i3_wb_dat_i	( wb_dm_dat_o ),
	.i3_wb_dat_o	( wb_dm_dat_i ),
	.i3_wb_ack_o	( wb_dm_ack_i ),
	.i3_wb_err_o	( wb_dm_err_i ),

	// WISHBONE Initiator 4
	.i4_wb_cyc_i	( wb_rdm_cyc_o ),
	.i4_wb_stb_i	( wb_rdm_stb_o ),
	.i4_wb_adr_i	( wb_rdm_adr_o ),
	.i4_wb_sel_i	( wb_rdm_sel_o ),
	.i4_wb_we_i	( wb_rdm_we_o  ),
	.i4_wb_dat_i	( wb_rdm_dat_o ),
	.i4_wb_dat_o	( wb_rdm_dat_i ),
	.i4_wb_ack_o	( wb_rdm_ack_i ),
	.i4_wb_err_o	( wb_rdm_err_i ),

	// WISHBONE Initiator 5
	.i5_wb_cyc_i	( wb_rim_cyc_o ),
	.i5_wb_stb_i	( wb_rim_stb_o ),
	.i5_wb_adr_i	( wb_rim_adr_o ),
	.i5_wb_sel_i	( wb_rim_sel_o ),
	.i5_wb_we_i	( wb_rim_we_o  ),
	.i5_wb_dat_i	( wb_rim_dat_o ),
	.i5_wb_dat_o	( wb_rim_dat_i ),
	.i5_wb_ack_o	( wb_rim_ack_i ),
	.i5_wb_err_o	( wb_rim_err_i ),

	// WISHBONE Initiator 6
	.i6_wb_cyc_i	( 1'b0 ),
	.i6_wb_stb_i	( 1'b0 ),
	.i6_wb_adr_i	( 32'h0000_0000 ),
	.i6_wb_sel_i	( 4'b0000 ),
	.i6_wb_we_i	( 1'b0 ),
	.i6_wb_dat_i	( 32'h0000_0000 ),
	.i6_wb_dat_o	( ),
	.i6_wb_ack_o	( ),
	.i6_wb_err_o	( ),

	// WISHBONE Initiator 7
	.i7_wb_cyc_i	( 1'b0 ),
	.i7_wb_stb_i	( 1'b0 ),
	.i7_wb_adr_i	( 32'h0000_0000 ),
	.i7_wb_sel_i	( 4'b0000 ),
	.i7_wb_we_i	( 1'b0 ),
	.i7_wb_dat_i	( 32'h0000_0000 ),
	.i7_wb_dat_o	( ),
	.i7_wb_ack_o	( ),
	.i7_wb_err_o	( ),

	// WISHBONE Target 0
	.t0_wb_cyc_o	( wb_ss_cyc_i ),
	.t0_wb_stb_o	( wb_ss_stb_i ),
	.t0_wb_adr_o	( wb_ss_adr_i ),
	.t0_wb_sel_o	( wb_ss_sel_i ),
	.t0_wb_we_o	( wb_ss_we_i  ),
	.t0_wb_dat_o	( wb_ss_dat_i ),
	.t0_wb_dat_i	( wb_ss_dat_o ),
	.t0_wb_ack_i	( wb_ss_ack_o ),
	.t0_wb_err_i	( wb_ss_err_o ),

	// WISHBONE Target 1
	.t1_wb_cyc_o	( wb_fs_cyc_i ),
	.t1_wb_stb_o	( wb_fs_stb_i ),
	.t1_wb_adr_o	( wb_fs_adr_i ),
	.t1_wb_sel_o	( wb_fs_sel_i ),
	.t1_wb_we_o	( wb_fs_we_i  ),
	.t1_wb_dat_o	( wb_fs_dat_i ),
	.t1_wb_dat_i	( wb_fs_dat_o ),
	.t1_wb_ack_i	( wb_fs_ack_o ),
	.t1_wb_err_i	( wb_fs_err_o ),

	// WISHBONE Target 2
	.t2_wb_cyc_o	( wb_sp_cyc_i ),
	.t2_wb_stb_o	( wb_sp_stb_i ),
	.t2_wb_adr_o	( wb_sp_adr_i ),
	.t2_wb_sel_o	( wb_sp_sel_i ),
	.t2_wb_we_o	( wb_sp_we_i  ),
	.t2_wb_dat_o	( wb_sp_dat_i ),
	.t2_wb_dat_i	( wb_sp_dat_o ),
	.t2_wb_ack_i	( wb_sp_ack_o ),
	.t2_wb_err_i	( wb_sp_err_o ),

	// WISHBONE Target 3
	.t3_wb_cyc_o	( wb_es_cyc_i ),
	.t3_wb_stb_o	( wb_es_stb_i ),
	.t3_wb_adr_o	( wb_es_adr_i ),
	.t3_wb_sel_o	( wb_es_sel_i ),
	.t3_wb_we_o	( wb_es_we_i  ),
	.t3_wb_dat_o	( wb_es_dat_i ),
	.t3_wb_dat_i	( wb_es_dat_o ),
	.t3_wb_ack_i	( wb_es_ack_o ),
	.t3_wb_err_i	( wb_es_err_o ),

	// WISHBONE Target 4
	.t4_wb_cyc_o	( ),
	.t4_wb_stb_o	( ),
	.t4_wb_adr_o	( ),
	.t4_wb_sel_o	( ),
	.t4_wb_we_o	( ),
	.t4_wb_dat_o	( ),
	.t4_wb_dat_i	( 32'h0000_0000 ),
	.t4_wb_ack_i	( 1'b0 ),
	.t4_wb_err_i	( 1'b1 ),
	
	// WISHBONE Target 5
	.t5_wb_cyc_o	( wb_us_cyc_i ),
	.t5_wb_stb_o	( wb_us_stb_i ),
	.t5_wb_adr_o	( wb_us_adr_i ),
	.t5_wb_sel_o	( wb_us_sel_i ),
	.t5_wb_we_o	( wb_us_we_i  ),
	.t5_wb_dat_o	( wb_us_dat_i ),
	.t5_wb_dat_i	( wb_us_dat_o ),
	.t5_wb_ack_i	( wb_us_ack_o ),
	.t5_wb_err_i	( wb_us_err_o ),

	// WISHBONE Target 6
	.t6_wb_cyc_o	( ),
	.t6_wb_stb_o	( ),
	.t6_wb_adr_o	( ),
	.t6_wb_sel_o	( ),
	.t6_wb_we_o	( ),
	.t6_wb_dat_o	( ),
	.t6_wb_dat_i	( 32'h0000_0000 ),
	.t6_wb_ack_i	( 1'b0 ),
	.t6_wb_err_i	( 1'b1 ),

	// WISHBONE Target 7
	.t7_wb_cyc_o	( wb_gpio_cyc_i ),
	.t7_wb_stb_o	( wb_gpio_stb_i ),
	.t7_wb_adr_o	( wb_gpio_adr_i ),
	.t7_wb_sel_o	( wb_gpio_sel_i ),
	.t7_wb_we_o	   ( wb_gpio_we_i  ),
	.t7_wb_dat_o	( wb_gpio_dat_i ),
	.t7_wb_dat_i	( wb_gpio_dat_o ),
	.t7_wb_ack_i	( wb_gpio_ack_o ),
	.t7_wb_err_i	( wb_gpio_err_o ),

	// WISHBONE Target 8
	.t8_wb_cyc_o	( ),
	.t8_wb_stb_o	( ),
	.t8_wb_adr_o	( ),
	.t8_wb_sel_o	( ),
	.t8_wb_we_o	( ),
	.t8_wb_dat_o	( ),
	.t8_wb_dat_i	( 32'h0000_0000 ),
	.t8_wb_ack_i	( 1'b0 ),
	.t8_wb_err_i	( 1'b1 )
);

//initial begin
//  $dumpvars(0);
//  $dumpfile("dump.vcd");
//end

endmodule

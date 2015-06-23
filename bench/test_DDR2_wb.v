`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UPT
// Engineer: Oana Boncalo & Alexandru Amaricai
// 
// Create Date:    19:05:16 03/22/2013 
// Design Name: 
// Module Name:    test_DDR2_wb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test_DDR2_wb#
  (
   parameter BANK_WIDTH              = 2,       
                                       // # of memory bank addr bits.
   parameter CKE_WIDTH               = 1,       
                                       // # of memory clock enable outputs.
   parameter CLK_WIDTH               = 2,       
                                       // # of clock outputs.
   parameter COL_WIDTH               = 10,       
                                       // # of memory column bits.
   parameter CS_NUM                  = 1,       
                                       // # of separate memory chip selects.
   parameter CS_WIDTH                = 1,       
                                       // # of total memory chip selects.
   parameter CS_BITS                 = 0,       
                                       // set to log2(CS_NUM) (rounded up).
   parameter DM_WIDTH                = 8,       
                                       // # of data mask bits.
   parameter DQ_WIDTH                = 64,       
                                       // # of data width.
   parameter DQ_PER_DQS              = 8,       
                                       // # of DQ data bits per strobe.
   parameter DQS_WIDTH               = 8,       
                                       // # of DQS strobes.
   parameter DQ_BITS                 = 6,       
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
   parameter DQS_BITS                = 3,       
                                       // set to log2(DQS_WIDTH).
   parameter ODT_WIDTH               = 1,       
                                       // # of memory on-die term enables.
   parameter ROW_WIDTH               = 13,       
                                       // # of memory row and # of addr bits.
   parameter ADDITIVE_LAT            = 0,       
                                       // additive write latency.
   parameter BURST_LEN               = 4,       
                                       // burst length (in double words).
   parameter BURST_TYPE              = 0,       
                                       // burst type (=0 seq; =1 interleaved).
   parameter CAS_LAT                 = 3,       
                                       // CAS latency.
   parameter ECC_ENABLE              = 0,       
                                       // enable ECC (=1 enable).
   parameter APPDATA_WIDTH           = 128,       
                                       // # of usr read/write data bus bits.
   parameter MULTI_BANK_EN           = 1,       
                                       // Keeps multiple banks open. (= 1 enable).
   parameter TWO_T_TIME_EN           = 1,       
                                       // 2t timing for unbuffered dimms.
   parameter ODT_TYPE                = 1,       
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
   parameter REDUCE_DRV              = 0,       
                                       // reduced strength mem I/O (=1 yes).
   parameter REG_ENABLE              = 0,       
                                       // registered addr/ctrl (=1 yes).
   parameter TREFI_NS                = 7800,       
                                       // auto refresh interval (ns).
   parameter TRAS                    = 40000,       
                                       // active->precharge delay.
   parameter TRCD                    = 15000,       
                                       // active->read/write delay.
   parameter TRFC                    = 105000,       
                                       // refresh->refresh, refresh->active delay.
   parameter TRP                     = 15000,       
                                       // precharge->command delay.
   parameter TRTP                    = 7500,       
                                       // read->precharge delay.
   parameter TWR                     = 15000,       
                                       // used to determine write->precharge.
   parameter TWTR                    = 7500,       
                                       // write->read delay.
   parameter HIGH_PERFORMANCE_MODE   = "TRUE",       
                              // # = TRUE, the IODELAY performance mode is set
                              // to high.
                              // # = FALSE, the IODELAY performance mode is set
                              // to low.
   parameter SIM_ONLY                = 0,       
                                       // = 1 to skip SDRAM power up delay.
   parameter DEBUG_EN                = 0,       
                                       // Enable debug signals/controls.
                                       // When this parameter is changed from 0 to 1,
                                       // make sure to uncomment the coregen commands
                                       // in ise_flow.bat or create_ise.bat files in
                                       // par folder.
   parameter CLK_PERIOD              = 8000,       
                                       // Core/Memory clock period (in ps).
   parameter RST_ACT_LOW             = 0        
                                       // =1 for active low reset, =0 for active high.
   )
	(
	input sysClk,
	input sysRst,  //Asynchronous PLL reset
	//output outSysClk,
	
	input [7:0] sw,
	output [7:0] leds,
	
	inout  [DQ_WIDTH-1:0]              ddr2_dq,
   output [ROW_WIDTH-1:0]             ddr2_a,
   output [BANK_WIDTH-1:0]            ddr2_ba,
   output                             ddr2_ras_n,
   output                             ddr2_cas_n,
   output                             ddr2_we_n,
   output [CS_WIDTH-1:0]              ddr2_cs_n,
   output [ODT_WIDTH-1:0]             ddr2_odt,
   output [CKE_WIDTH-1:0]             ddr2_cke,
   output [DM_WIDTH-1:0]              ddr2_dm,
	inout  [DQS_WIDTH-1:0]             ddr2_dqs,
   inout  [DQS_WIDTH-1:0]             ddr2_dqs_n,
   output [CLK_WIDTH-1:0]             ddr2_ck,
   output [CLK_WIDTH-1:0]             ddr2_ck_n
    );
	//chipscope ila and icon connecting signals
	wire [35:0] control;
	wire [327:0] data;
	wire [7:0] trig0;
	
	//wishbone signals
	 wire 								cyc_wb;
	 wire									stb_wb;
	 wire	[30:0] 						address_wb;
	 wire	[(APPDATA_WIDTH/8)-1:0]	sel_wb; //write mask	 
	 wire	[APPDATA_WIDTH-1:0]		wr_data_wb; // write data
	 wire									we_wb;
	 wire   [2:0]						cti_wb;
	 wire   [1:0]						bte_wb;
	 //to wishbone from memory interface
	 wire									ack_mem, err_mem, rty_mem;
	 wire [APPDATA_WIDTH-1:0]		rd_data_wb; // rd data
	 wire [3:0]							wb_state;
	 wire	[2:0]							state;
	 wire [3:0]							state_master;
	 wire									phy_init_done;
	 wire 								clk0_tb, rst0_tb;
	 wire									sysClk_bufg;
	 
 
   DDR2_Mem #
  (
   .BANK_WIDTH (BANK_WIDTH),       
                                       // # of memory bank addr bits.
   .CKE_WIDTH  (CKE_WIDTH),       
                                       // # of memory clock enable outputs.
   .CLK_WIDTH (CLK_WIDTH),       
                                       // # of clock outputs.
   .COL_WIDTH (COL_WIDTH),       
                                       // # of memory column bits.
   .CS_NUM (CS_NUM),       
                                       // # of separate memory chip selects.
   .CS_WIDTH (CS_WIDTH),       
                                       // # of total memory chip selects.
   .CS_BITS (CS_BITS),       
                                       // set to log2(CS_NUM) (rounded up).
   .DM_WIDTH (DM_WIDTH),       
                                       // # of data mask bits.
   .DQ_WIDTH (DQ_WIDTH),       
                                       // # of data width.
   .DQ_PER_DQS (DQ_PER_DQS),       
                                       // # of DQ data bits per strobe.
   .DQS_WIDTH (DQS_WIDTH),       
                                       // # of DQS strobes.
   .DQ_BITS (DQ_BITS),       
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
   .DQS_BITS (DQS_BITS),       
                                       // set to log2(DQS_WIDTH).
   .ODT_WIDTH (ODT_WIDTH),       
                                       // # of memory on-die term enables.
   .ROW_WIDTH (ROW_WIDTH),       
                                       // # of memory row and # of addr bits.
   .ADDITIVE_LAT (ADDITIVE_LAT),       
                                       // additive write latency.
   .BURST_LEN (BURST_LEN),       
                                       // burst length (in double words).
   .BURST_TYPE (BURST_TYPE),       
                                       // burst type (=0 seq; =1 interleaved).
   .CAS_LAT (CAS_LAT),       
                                       // CAS latency.
   .ECC_ENABLE (ECC_ENABLE),       
                                       // enable ECC (=1 enable).
   .APPDATA_WIDTH (APPDATA_WIDTH),       
                                       // # of usr read/write data bus bits.
   .MULTI_BANK_EN (MULTI_BANK_EN),       
                                       // Keeps multiple banks open. (= 1 enable).
   .TWO_T_TIME_EN  (TWO_T_TIME_EN),       
                                       // 2t timing for unbuffered dimms.
   .ODT_TYPE  (ODT_TYPE),       
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
   .REDUCE_DRV (REDUCE_DRV),       
                                       // reduced strength mem I/O (=1 yes).
   .REG_ENABLE (REG_ENABLE),       
                                       // registered addr/ctrl (=1 yes).
   .TREFI_NS (TREFI_NS),       
													// auto refresh interval (ns).
   .TRAS (TRAS),       
                                       // active->precharge delay.
   .TRCD (TRCD),       
                                       // active->read/write delay.
   .TRFC  (TRFC),       
                                       // refresh->refresh, refresh->active delay.
   .TRP (TRP),       
                                       // precharge->command delay.
   .TRTP (TRTP),       
                                       // read->precharge delay.
   .TWR (TWR),       
                                       // used to determine write->precharge.
   .TWTR (TWTR),       
                                       // write->read delay.
   .HIGH_PERFORMANCE_MODE  (HIGH_PERFORMANCE_MODE),       
                              // # = TRUE, the IODELAY performance mode is set
                              // to high.
                              // # = FALSE, the IODELAY performance mode is set
                              // to low.
   .SIM_ONLY (SIM_ONLY),       
                                       // = 1 to skip SDRAM power up delay.
   .DEBUG_EN (DEBUG_EN),       
                                       // Enable debug signals/controls.
                                       // When this parameter is changed from 0 to 1,
                                       // make sure to uncomment the coregen commands
                                       // in ise_flow.bat or create_ise.bat files in
                                       // par folder.
   .CLK_PERIOD (CLK_PERIOD),       
                                       // Core/Memory clock period (in ps).
   .RST_ACT_LOW (RST_ACT_LOW)        
                                       // =1 for active low reset, =0 for active high.
   )
	test_ddr2_mem_wb
	(
	.sysClk (sysClk),
	.sysRst (sysRst),  //Asynchronous PLL reset
	.clk0 (clk0_tb),
	.rst0 (rst0_tb),
	
	.ddr2_dq (ddr2_dq),
   .ddr2_a (ddr2_a),
   .ddr2_ba (ddr2_ba),
   .ddr2_ras_n (ddr2_ras_n),
   .ddr2_cas_n (ddr2_cas_n),
   .ddr2_we_n (ddr2_we_n),
   .ddr2_cs_n (ddr2_cs_n),
   .ddr2_odt (ddr2_odt),
   .ddr2_cke (ddr2_cke),
   .ddr2_dm (ddr2_dm),
	.ddr2_dqs (ddr2_dqs),
   .ddr2_dqs_n (ddr2_dqs_n),
   .ddr2_ck (ddr2_ck),
   .ddr2_ck_n (ddr2_ck_n),
	//wishbone if signals
	 .cyc_wb (cyc_wb),
	 .stb_wb (stb_wb),
	 .address_wb (address_wb),
	 .sel_wb (sel_wb), //write mask	 
	 .wr_data_wb (wr_data_wb), // write data
	 .we_wb (we_wb),
	 .cti_wb (cti_wb),
	 .bte_wb (bte_wb),
	 //to wishbone from memory interface
	 .ack_mem (ack_mem), 
	 .err_mem (err_mem), 
	 .rty_mem (rty_mem),
	 .rd_data_wb (rd_data_wb), // rd data
	 .wb_state (wb_state),
	 .state (state),
	 .phy_init_done_o (phy_init_done)
    );
	
	//only for test purposes
	wishbone_master_mock #(
    .APPDATA_WIDTH (APPDATA_WIDTH)  )
	 master_test_wb
	(
    .clk (clk0_tb), 
	 .rst (rst0_tb),
   
	 .cyc_wb (cyc_wb),
	 .stb_wb (stb_wb),
	 .address_wb (address_wb),
	 .sel_wb (sel_wb), //write mask	 
	 .wr_data_wb (wr_data_wb), // write data
	 .we_wb (we_wb),
	 .cti_wb (cti_wb),
	 .bte_wb (bte_wb),
	 //to wishbone from memory interface
	 .ack_mem (ack_mem), 
	 .err_mem (err_mem), 
	 .rty_mem (rty_mem),
	 .rd_data_mem (rd_data_wb),
	 .state (state_master)
	 );
	 

endmodule

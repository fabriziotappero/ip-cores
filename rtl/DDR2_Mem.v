`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UPT
// Engineer: Oana Boncalo & Alexandru Amaricai
// 
// Create Date:    17:25:32 11/26/2012 
// Design Name: 
// Module Name:    DDR2_Mem 
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
module DDR2_Mem #
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
	input sysRst,  //Asynchronous reset
	input sysClk,
	output clk0,
	output rst0,
	output clkTFT10, 
	output clkTFT10_180,

	
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
   output [CLK_WIDTH-1:0]             ddr2_ck_n,
//rd/wr command signals from bus
//address, data & data mask from bus if
//wishbone if signals
	 input 									cyc_wb,
	 input									stb_wb,
	 input	[30:0] 						address_wb,
	 input	[(APPDATA_WIDTH/8)-1:0]	sel_wb, //write mask	 
	 input	[APPDATA_WIDTH-1:0]		wr_data_wb, // write data
	 input									we_wb,
	 input 	[2:0]							cti_wb,
	 input   [1:0]							bte_wb,
	 //to wishbone from memory interface
	 output									ack_mem, err_mem, rty_mem,
	 output	[APPDATA_WIDTH-1:0]		rd_data_wb, // rd data
	 output [3:0] 						   wb_state,
	 output reg [2:0]						state,
	 output phy_init_done_o
	 
    );
	 
	localparam IDLE  = 3'b000;
	localparam WR_OP_D0 = 3'b001;
	localparam WR_OP_D1 = 3'b010;
	localparam RD_OP  = 3'b011;
	localparam WAIT_RD_RSP  = 3'b100;
	localparam WAIT_END_OF_RD_RSP  = 3'b101;
	localparam RD_COUNTER_TIMEOUT  = 3'b110;

	localparam WR_IDLE_FIRST_DATA = 2'b00;
	localparam WR_SECOND_DATA     = 2'b01;
	localparam WR_THIRD_DATA      = 2'b10;
	localparam WR_FOURTH_DATA     = 2'b11;
	
	
	wire clk0_125;
	wire clk0Phase90;
	wire clk0Div2;
	wire outSysClk1;
	wire outSysClk2;
	wire clk200;
	wire locked;
	
	//reset logic signal
	wire async_rst;
	wire pll_rst;

	wire [30:0] address;
	wire [2:0]	cmd;
	wire 	af_we;
	wire 	wd_we;
	wire [127:0]	wr_data;
	wire [16:0]		wr_mask;
	wire [127:0]	rd_data;
	wire	rd_valid;
	wire	wd_fifo_full;
	wire	a_fifo_full;
	wire	phy_init_done;
	wire clk_tb;
	wire rts_tb;
	wire  rd_cmd;
	wire  wr_cmd;
	wire end_op;
	wire [30:0] bus_if_addr;
	reg  [30:0] test_addr_cnt;

	//data for write
	wire [(APPDATA_WIDTH/8)-1:0]         wr_mask_data;
	wire [(APPDATA_WIDTH/16)-1:0]        wr_mask_data_fall;
	wire [(APPDATA_WIDTH/16)-1:0]        wr_mask_data_rise;
	reg [1:0]                            wr_state;
	reg [(APPDATA_WIDTH/2)-1:0]          wr_data_fall
                                       /* synthesis syn_maxfan = 2 */;
	reg [(APPDATA_WIDTH/2)-1:0]          wr_data_rise
                                        /* synthesis syn_maxfan = 2 */;
	//data for write
	wire  [APPDATA_WIDTH-1:0]         bus_if_wr_data;
	wire  [(APPDATA_WIDTH/8)-1:0]     bus_if_wr_mask_data;
	//data from memory if to request the second 128 bit data word
	wire 										 req_wd;
	wire 										 idelay_ctrl_rdy;

	//rd/wr command signals from bus
	//address, data & data mask from bus if
	wire  [30:0] 							 wb_bus_if_addr;
	wire  [APPDATA_WIDTH-1:0]         bus_if_wr_data0, bus_if_wr_data1;
	wire  [(APPDATA_WIDTH/8)-1:0]     bus_if_wr_mask_data0, bus_if_wr_mask_data1;
	wire 									    mem_rd_cmd; 
	wire										 mem_wr_cmd;
	wire [APPDATA_WIDTH-1:0]          bus_if_rd_data;
	reg   [4:0]								 counter;
	wire										 rd_failed;
	
	assign phy_init_done_o = phy_init_done;
	
//global reset logic 
debounceRst global_rst_logic(
    .clk (sysClk),
    .noisyRst (sysRst),
	 .PLLLocked (locked),
    .cleanPLLRst (pll_rst),
	 .cleanAsyncRst (async_rst)
    );
	 


clkGenPLL clkGen(
	.sysClk (sysClk),
	.sysRst (pll_rst),  //Asynchronous PLL reset
	.clk0_125 (clk0_125), //125 Mhz
	.clk0Phase90 (clk0Phase90), //125 MHz clk200 with 90 degree phase
	.clk0Div2 (clk0Div2), //62.5 MHz
	.clk200 (clk200),   //200 MHz clk
	.clkTFT10 (clkTFT10),
	.clkTFT10_180(clkTFT10_180),
	.locked (locked)
    );
	BUFG u_bufg_clk0
    (
     .O (clk0_bufg),
     .I (clk0_125)
     );

  BUFG u_bufg_clk90
    (
     .O (clk90_bufg),
     .I (clk0Phase90)
     );

  BUFG u_bufg_clk200
    (
     .O (clk200_bufg),
     .I (clk200)
     );

   BUFG u_bufg_clkdiv0
    (
     .O (clkdiv0_bufg),
     .I (clk0Div2)
     );

 MEMCtrl #
  (
   .BANK_WIDTH (BANK_WIDTH),       
                                       // # of memory bank addr bits.
   .CKE_WIDTH (CKE_WIDTH),       
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
   .DQS_WIDTH  (DQS_WIDTH),       
                                       // # of DQS strobes.
   .DQ_BITS (DQ_BITS),       
                                       // set to log2(DQS_WIDTH*DQ_PER_DQS).
   .DQS_BITS (DQS_BITS),       
                                       // set to log2(DQS_WIDTH).
   .ODT_WIDTH (ODT_WIDTH),       
                                       // # of memory on-die term enables.
   .ROW_WIDTH (ROW_WIDTH),       
                                       // # of memory row and # of addr bits.
   .ADDITIVE_LAT(ADDITIVE_LAT),       
                                       // additive write latency.
   .BURST_LEN (BURST_LEN),       
                                       // burst length (in double words).
   .BURST_TYPE(BURST_TYPE),       
                                       // burst type (=0 seq; =1 interleaved).
   .CAS_LAT (CAS_LAT),       
                                       // CAS latency.
   .ECC_ENABLE (ECC_ENABLE),       
                                       // enable ECC (=1 enable).
   .APPDATA_WIDTH (APPDATA_WIDTH),       
                                       // # of usr read/write data bus bits.
   .MULTI_BANK_EN (MULTI_BANK_EN),       
                                       // Keeps multiple banks open. (= 1 enable).
   .TWO_T_TIME_EN (TWO_T_TIME_EN),       
                                       // 2t timing for unbuffered dimms.
   .ODT_TYPE (ODT_TYPE),       
                                       // ODT (=0(none),=1(75),=2(150),=3(50)).
   .REDUCE_DRV (REDUCE_DRV),       
                                       // reduced strength mem I/O (=1 yes).
   .REG_ENABLE (REDUCE_DRV),       
                                       // registered addr/ctrl (=1 yes).
   .TREFI_NS (TREFI_NS),       
                                       // auto refresh interval (ns).
   .TRAS (TRAS),       
                                       // active->precharge delay.
   .TRCD (TRCD),       
                                       // active->read/write delay.
   .TRFC (TRFC),       
                                       // refresh->refresh, refresh->active delay.
   .TRP (TRP),       
                                       // precharge->command delay.
   .TRTP (TRTP),       
                                       // read->precharge delay.
   .TWR (TWR),       
                                       // used to determine write->precharge.
   .TWTR (TWTR),       
                                       // write->read delay.
   .HIGH_PERFORMANCE_MODE (HIGH_PERFORMANCE_MODE),       
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
	mig_if
  (
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
	
	//pll & reset
  	
	.sys_rst_n (async_rst), //debounced asynchronous reset signal
   .phy_init_done (phy_init_done),
   .locked (locked),
   .rst0_tb (rst0_tb),
   .clk0 (clk0_bufg),
   .clk0_tb (clk0_tb), 
   .clk90 (clk90_bufg),
   .clkdiv0 (clkdiv0_bufg),
   .clk200 (clk200_bufg),
	
	//testbench
   .app_wdf_afull (wd_fifo_full),
   .app_af_afull (a_fifo_full),
   .rd_data_valid (rd_valid),
   .app_wdf_wren (wd_we),
   .app_af_wren (af_we),
   .app_af_addr (address),
   .app_af_cmd (cmd),
   .rd_data_fifo_out (rd_data),
   .app_wdf_data (wr_data),
   .app_wdf_mask_data (wr_mask)	
   );
	
	assign clk0 = clk0_tb;
	assign rst0 = rst0_tb;
//wishbone bus interface
DDR2_mem_wb_if #
  (
   .APPDATA_WIDTH (128)     // # of usr read/write data bus bits.                                 
	)
	test_ddr2_wb_if
	(
	 .clk (clk0_tb),
	 .rst (rst0_tb),  
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
	 
	 //signals to/from memory user interface
	 .bus_if_addr (wb_bus_if_addr),
	 .bus_if_wr_data0 (bus_if_wr_data0), 
	 .bus_if_wr_data1 (bus_if_wr_data1),
	 .bus_if_wr_mask_data0 (bus_if_wr_mask_data0), 
	 .bus_if_wr_mask_data1 (bus_if_wr_mask_data1),
	 .mem_rd_cmd (mem_rd_cmd), 
	 .mem_wr_cmd (mem_wr_cmd), 
	 .rd_valid (rd_valid),
	 .end_op (end_op),
	 .bus_if_rd_data (bus_if_rd_data),
	 .app_wdf_afull (wd_fifo_afull),
    .app_af_afull (a_fifo_afull),
	 .phy_init_done (phy_init_done),
	 .rd_failed (rd_failed),
	 .wb_state (wb_state)
    );	

// synthesizable test bench provided for wotb designs
  ddr2_user_if_top #
     (
      .BANK_WIDTH        (BANK_WIDTH),
      .COL_WIDTH         (COL_WIDTH),
      .DM_WIDTH          (DM_WIDTH),
      .DQ_WIDTH          (DQ_WIDTH),
      .ROW_WIDTH         (ROW_WIDTH),
      .ECC_ENABLE        (ECC_ENABLE),
      .APPDATA_WIDTH     (APPDATA_WIDTH),
      .BURST_LEN         (BURST_LEN)
      )
   u_user_if_top
     (
      .clk0              (clk0_tb),
      .rst0              (rst0_tb),
      .app_af_afull      (a_fifo_full),
      .app_wdf_afull     (wd_fifo_full),
      .rd_data_valid     (rd_valid),
      .rd_data_fifo_out  (rd_data),
      .phy_init_done     (phy_init_done),
		.rd_cmd				 (rd_cmd),
		.wr_cmd				 (wr_cmd),
		.bus_if_addr       (bus_if_addr), 
		.end_op				 (end_op),
		.req_wd            (req_wd),
		.bus_if_wr_mask_data(bus_if_wr_mask_data),
		.bus_if_wr_data    (bus_if_wr_data),
      .app_af_wren       (af_we),
      .app_af_cmd        (cmd),
      .app_af_addr       (address),
      .app_wdf_wren      (wd_we),
      .app_wdf_data      (wr_data),
      .app_wdf_mask_data (wr_mask),
      .error             (error),
      .error_cmp         (error_cmp)
      );
		

	assign rd_failed = (state == RD_COUNTER_TIMEOUT)? 1'b1: 1'b0;
	
	always @(posedge clk0_tb)
	begin
		if (rst0_tb)
			begin
				state <= 0;
			end
		else
			begin
				case (state)
					IDLE:
						begin
							//check if memory if is available for commands
							//i.e. initialization done & ready for WR
							if (mem_wr_cmd)
								state <= WR_OP_D0;
							else if (mem_rd_cmd)
								state <= RD_OP;
						end
					RD_OP:
						begin
							if (end_op)
								state <= WAIT_RD_RSP;
							else
								state <= RD_OP;
						end
					WAIT_RD_RSP:
						begin
							if (rd_valid)
								state <= WAIT_END_OF_RD_RSP;
							else if (counter == 0)
								state <= RD_COUNTER_TIMEOUT;
						end
					 WAIT_END_OF_RD_RSP:
							if (!rd_valid)
								state <= IDLE;
							else
								state <= WAIT_END_OF_RD_RSP;
					 WR_OP_D0:
						begin 
							//signal for first data word latch and data byte en and address 
							//generate bus ack/request for second data
							if (req_wd) //this is wd_fifo_we
								state <= WR_OP_D1;
							else
								state <= WR_OP_D0;
						end
					 WR_OP_D1:
						begin 
							//signal for second data word latch and then wait for 
							//end of operation
							if (end_op)
								state <= RD_OP;
							else
								state <= WR_OP_D1;	
						end
					RD_COUNTER_TIMEOUT:
						begin
							state <= IDLE;
						end
				endcase
			end
	end
	assign bus_if_rd_data = rd_data;
	
	//latch address from wishbone if
	always @(posedge clk0_tb)
	begin
		if (rst0_tb)
			test_addr_cnt <= 0;
		else 
			if (wr_cmd)
				test_addr_cnt <= wb_bus_if_addr;		
	end
	assign bus_if_addr = test_addr_cnt;
	
	//timeout counter fro RD
	always @(posedge clk0_tb)
	begin
		if (rst0_tb)
			counter <= 0;
		else 
			if (state == RD_OP)
				counter <= 24;		
			else if (state == WAIT_RD_RSP)
				counter <= counter -  1'b1;
	end
	
  //generate data for write
  //***************************************************************************
  // DATA generation for WRITE DATA FIFOs & for READ DATA COMPARE
  //***************************************************************************

  assign bus_if_wr_data      = {wr_data_fall, wr_data_rise};
  assign bus_if_wr_mask_data = {wr_mask_data_fall, wr_mask_data_rise};

  //*****************************************************************
  // For now, don't vary data masks
  //*****************************************************************

  assign wr_mask_data_rise = {(APPDATA_WIDTH/8){1'b0}};
  assign wr_mask_data_fall = {(APPDATA_WIDTH/8){1'b0}};

  //*****************************************************************
  // Write data logic
  //*****************************************************************

  // write data generation
  //synthesis attribute max_fanout of wr_data_fall is 2
  //synthesis attribute max_fanout of wr_data_rise is 2
  always @(posedge clk0_tb) begin
    if (rst0_tb) begin
      wr_state <= WR_IDLE_FIRST_DATA;
    end else begin
      case (wr_state)
        WR_IDLE_FIRST_DATA:
          if (req_wd) begin
            wr_state <= WR_SECOND_DATA;
          end
        WR_SECOND_DATA:
            if (end_op) //begin
					wr_state <= WR_IDLE_FIRST_DATA;
      endcase
    end
  end
  
  //get data from memory if
	 always @(*) 
	 begin
		wr_data_rise = {(APPDATA_WIDTH/2){1'bx}};
		wr_data_fall = {(APPDATA_WIDTH/2){1'bx}};
		case (wr_state)
		  WR_IDLE_FIRST_DATA:
			 begin
				wr_data_rise = bus_if_wr_data0[(APPDATA_WIDTH/2)-1:0];
				wr_data_fall = bus_if_wr_data0[APPDATA_WIDTH-1:(APPDATA_WIDTH/2)];
			 end
		  WR_SECOND_DATA:
			 begin
				wr_data_rise = bus_if_wr_data1[(APPDATA_WIDTH/2)-1:0];
				wr_data_fall = bus_if_wr_data1[APPDATA_WIDTH-1:(APPDATA_WIDTH/2)];
			 end
		endcase
	 end
	
	assign wr_cmd = ((state == WR_OP_D0) && !end_op)? 1'b1:1'b0;
	assign rd_cmd = ((state == RD_OP) && !end_op)? 1'b1:1'b0;
	
	
endmodule

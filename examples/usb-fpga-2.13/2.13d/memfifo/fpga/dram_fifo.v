/*!
   memfifo -- implementation of EZ-USB slave FIFO's (input and output) a FIFO using the DDR3 SDRAM for ZTEX USB-FPGA Modules 2.13
   Copyright (C) 2009-2014 ZTEX GmbH.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/
/* 
   Implements a huge FIFO  from all SDRAM.
*/  

module fifo_512x128 #(
	parameter ALMOST_EMPTY_OFFSET1 = 13'h0020,    // Sets the almost empty threshold
	parameter ALMOST_EMPTY_OFFSET2 = 13'h0006,    // Sets the almost empty threshold
        parameter ALMOST_FULL_OFFSET1 = 13'h0020,     // Sets almost full threshold
        parameter ALMOST_FULL_OFFSET2 = 13'h0006,     // Sets almost full threshold
        parameter FIRST_WORD_FALL_THROUGH = "TRUE"   // Sets the FIFO FWFT to FALSE, TRUE
    ) (
        input RST,                     // 1-bit input: Reset
	// input signals
        input [127:0] DI,               // 64-bit input: Data input
        output FULL,                    // 1-bit output: Full flag
        output ALMOSTFULL1,       	// 1-bit output: Almost full flag
        output ALMOSTFULL2,       	// 1-bit output: Almost full flag
        output WRERR,                   // 1-bit output: Write error
        input WRCLK,                    // 1-bit input: Rising edge write clock.
        input WREN,                     // 1-bit input: Write enable
	// output signals
	output [127:0] DO,
	output EMPTY,                   // 1-bit output: Empty flag
        output ALMOSTEMPTY1,            // 1-bit output: Almost empty flag
        output ALMOSTEMPTY2,            // 1-bit output: Almost empty flag
        output RDERR,                   // 1-bit output: Read error
        input RDCLK,                    // 1-bit input: Read clock
        input RDEN                      // 1-bit input: Read enable
    );

    FIFO36E1 #(
	.ALMOST_EMPTY_OFFSET(ALMOST_EMPTY_OFFSET1),
        .ALMOST_FULL_OFFSET(ALMOST_FULL_OFFSET1),
        .DATA_WIDTH(72),
        .DO_REG(1),
        .EN_ECC_READ("TRUE"),
        .EN_ECC_WRITE("TRUE"),
        .EN_SYN("FALSE"),
        .FIFO_MODE("FIFO36_72"), 
        .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH),
        .INIT(72'h000000000000000000),
        .SIM_DEVICE("7SERIES"), 
        .SRVAL(72'h000000000000000000)
    )
    U (
      .DBITERR(),
      .ECCPARITY(),
      .SBITERR(),
      .DO(DO[127:64]),
      .DOP(),
      .ALMOSTEMPTY(ALMOSTEMPTY1),
      .ALMOSTFULL(ALMOSTFULL1),
      .EMPTY(EMPTY_U),
      .FULL(FULL_U),
      .RDCOUNT(),
      .RDERR(RDERR_U),
      .WRCOUNT(),
      .WRERR(WRERR_U),
      .INJECTDBITERR(1'b0),
      .INJECTSBITERR(1'b0),
      .RDCLK(RDCLK),
      .RDEN(RDEN),
      .REGCE(1'b0),
      .RST(RST),
      .RSTREG(1'b0),
      .WRCLK(WRCLK),
      .WREN(WREN),
      .DI(DI[127:64]),
      .DIP(4'd0)
   );

    FIFO36E1 #(
	.ALMOST_EMPTY_OFFSET(ALMOST_EMPTY_OFFSET2),
        .ALMOST_FULL_OFFSET(ALMOST_FULL_OFFSET2),
        .DATA_WIDTH(72),
        .DO_REG(1),
        .EN_ECC_READ("TRUE"),
        .EN_ECC_WRITE("TRUE"),
        .EN_SYN("FALSE"),
        .FIFO_MODE("FIFO36_72"), 
        .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH),
        .INIT(72'h000000000000000000),
        .SIM_DEVICE("7SERIES"), 
        .SRVAL(72'h000000000000000000)
    )
    L (
      .DBITERR(),
      .ECCPARITY(),
      .SBITERR(),
      .DO(DO[63:0]),
      .DOP(),
      .ALMOSTEMPTY(ALMOSTEMPTY2),
      .ALMOSTFULL(ALMOSTFULL2),
      .EMPTY(EMPTY_L),
      .FULL(FULL_L),
      .RDCOUNT(),
      .RDERR(RDERR_L),
      .WRCOUNT(),
      .WRERR(WRERR_L),
      .INJECTDBITERR(1'b0),
      .INJECTSBITERR(1'b0),
      .RDCLK(RDCLK),
      .RDEN(RDEN),
      .REGCE(1'b0),
      .RST(RST),
      .RSTREG(1'b0),
      .WRCLK(WRCLK),
      .WREN(WREN),
      .DI(DI[63:0]),
      .DIP(4'd0)
   );
   
   assign EMPTY = EMPTY_U || EMPTY_L;
   assign FULL = FULL_U || FULL_L;
   assign RDERR = RDERR_U || RDERR_L;
   assign WRERR = WRERR_U || WRERR_L;
   
endmodule


module dram_fifo # (
	// fifo parameters, see "7 Series Memory Resources" user guide (ug743)
	parameter ALMOST_EMPTY_OFFSET1 = 13'h0010,      // Sets the almost empty threshold
	parameter ALMOST_EMPTY_OFFSET2 = 13'h0001,      // Sets the almost empty threshold
        parameter ALMOST_FULL_OFFSET1 = 13'h0010,       // Sets almost full threshold
        parameter ALMOST_FULL_OFFSET2 = 13'h0001,       // Sets almost full threshold
        parameter FIRST_WORD_FALL_THROUGH = "TRUE",  	// Sets the FIFO FWFT to FALSE, TRUE
        // clock dividers for PLL outputs not used for memory interface, VCO frequency is 1200 MHz
      	parameter CLKOUT2_DIVIDE = 1,
      	parameter CLKOUT3_DIVIDE = 1,
      	parameter CLKOUT4_DIVIDE = 1,
      	parameter CLKOUT5_DIVIDE = 1,
      	parameter CLKOUT2_PHASE = 0.0,
      	parameter CLKOUT3_PHASE = 0.0,
      	parameter CLKOUT4_PHASE = 0.0,
      	parameter CLKOUT5_PHASE = 0.0
    ) (
	input fxclk_in,					// 48 MHz input clock pin
        input reset,
        output reset_out,				// reset output
      	output clkout2, clkout3, clkout4, clkout5,	// PLL clock outputs not used for memory interface
        
	// ddr3 pins
	inout [15:0] ddr3_dq,
	inout [1:0] ddr3_dqs_n,
	inout [1:0] ddr3_dqs_p,
	output [13:0] ddr3_addr,
	output [2:0] ddr3_ba,
	output ddr3_ras_n,
	output ddr3_cas_n,
	output ddr3_we_n,
        output ddr3_reset_n,
	output [0:0] ddr3_ck_p,
        output [0:0] ddr3_ck_n,
	output [0:0] ddr3_cke,
        output [1:0] ddr3_dm,
	output [0:0] ddr3_odt,
        
	// input fifo interface, see "7 Series Memory Resources" user guide (ug743)
        input [127:0] DI,               // 64-bit input: Data input
        output FULL,                    // 1-bit output: Full flag
        output ALMOSTFULL1,       	// 1-bit output: Almost full flag
        output ALMOSTFULL2,       	// 1-bit output: Almost full flag
        output WRERR,                   // 1-bit output: Write error
        input WRCLK,                    // 1-bit input: Rising edge write clock.
        input WREN,                     // 1-bit input: Write enable

	// output fifo interface, see "7 Series Memory Resources" user guide (ug743)
	output [127:0] DO,
	output EMPTY,                   // 1-bit output: Empty flag
        output ALMOSTEMPTY1,            // 1-bit output: Almost empty flag
        output ALMOSTEMPTY2,            // 1-bit output: Almost empty flag
        output RDERR,                   // 1-bit output: Read error
        input RDCLK,                    // 1-bit input: Read clock
        input RDEN,                     // 1-bit input: Read enable
        
	// free memory
	output [APP_ADDR_WIDTH:0] mem_free_out,

	// for debugging
	output [9:0] status
    );

    localparam APP_DATA_WIDTH = 128;	
    localparam APP_MASK_WIDTH = 16;
    localparam APP_ADDR_WIDTH = 24;

    wire pll_fb, clk200_in, clk67_in, clk200, clk67, uiclk, fxclk;
    
    wire mem_reset, ui_clk_sync_rst, init_calib_complete;
    reg reset_buf;

// memory control
    reg [7:0] wr_cnt, rd_cnt;
    reg [APP_ADDR_WIDTH-1:0] mem_wr_addr, mem_rd_addr;
    reg [APP_ADDR_WIDTH:0] mem_free;
    reg rd_mode, wr_mode_buf;
    wire wr_mode;

// fifo control
    wire infifo_empty, infifo_almost_empty, outfifo_almost_full, infifo_rden;
    wire [APP_DATA_WIDTH-1:0] infifo_do;
    reg [5:0] outfifo_pending;
    reg [9:0] rd_cnt_dbg;

// debug
    wire infifo_err_w, outfifo_err_w;
    reg infifo_err, outfifo_err, outfifo_err_uf;

// memory interface    
    reg [APP_ADDR_WIDTH-1:0] app_addr;
    reg [2:0] app_cmd;
    reg app_en, app_wdf_wren;
    wire app_rdy, app_wdf_rdy, app_rd_data_valid;
    reg [APP_DATA_WIDTH-1:0] app_wdf_data;
    wire [APP_DATA_WIDTH-1:0] app_rd_data;

    BUFG fxclk_buf (
	.I(fxclk_in),
	.O(fxclk) 
    );

    PLLE2_BASE #(
    	.BANDWIDTH("LOW"),
      	.CLKFBOUT_MULT(25),       // f_VCO = 1200 MHz (valid: 800 .. 1600 MHz)
      	.CLKFBOUT_PHASE(0.0),
      	.CLKIN1_PERIOD(0.0),
      	.CLKOUT0_DIVIDE(18),	// 66.666 MHz
      	.CLKOUT1_DIVIDE(6),	// 200 MHz
      	.CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),
      	.CLKOUT3_DIVIDE(CLKOUT3_DIVIDE),
      	.CLKOUT4_DIVIDE(CLKOUT4_DIVIDE),
      	.CLKOUT5_DIVIDE(CLKOUT5_DIVIDE),
      	.CLKOUT0_DUTY_CYCLE(0.5),
      	.CLKOUT1_DUTY_CYCLE(0.5),
      	.CLKOUT2_DUTY_CYCLE(0.5),
      	.CLKOUT3_DUTY_CYCLE(0.5),
      	.CLKOUT4_DUTY_CYCLE(0.5),
      	.CLKOUT5_DUTY_CYCLE(0.5),
      	.CLKOUT0_PHASE(0.0),
      	.CLKOUT1_PHASE(0.0),
      	.CLKOUT2_PHASE(CLKOUT2_PHASE),
      	.CLKOUT3_PHASE(CLKOUT3_PHASE),
      	.CLKOUT4_PHASE(CLKOUT4_PHASE),
      	.CLKOUT5_PHASE(CLKOUT5_PHASE),
      	.DIVCLK_DIVIDE(1),
      	.REF_JITTER1(0.0),
      	.STARTUP_WAIT("FALSE")
    )
    dram_fifo_pll_inst (
      	.CLKIN1(fxclk),
      	.CLKOUT0(clk67),
      	.CLKOUT1(clk200),   
      	.CLKOUT2(clkout2),   
      	.CLKOUT3(clkout3),   
      	.CLKOUT4(clkout4),   
      	.CLKOUT5(clkout5),   
      	.CLKFBOUT(pll_fb),
      	.CLKFBIN(pll_fb),
      	.PWRDWN(1'b0),
      	.RST(1'b0)
    );
    
    fifo_512x128 #(
	.ALMOST_EMPTY_OFFSET1(13'h0026),
	.ALMOST_EMPTY_OFFSET2(13'h0006),
	.ALMOST_FULL_OFFSET1(ALMOST_FULL_OFFSET1),
	.ALMOST_FULL_OFFSET2(ALMOST_FULL_OFFSET2),
        .FIRST_WORD_FALL_THROUGH("TRUE")
    ) infifo (
	.RST(reset_buf),
	// output
	.DO(infifo_do),
	.EMPTY(infifo_empty),
	.ALMOSTEMPTY1(infifo_almost_empty),
	.ALMOSTEMPTY2(),
	.RDERR(infifo_err_w),
	.RDCLK(uiclk),
	.RDEN(infifo_rden),
	// input
        .DI(DI),
	.FULL(FULL),
        .ALMOSTFULL1(ALMOSTFULL1),
        .ALMOSTFULL2(ALMOSTFULL2),
        .WRERR(WRERR),
        .WRCLK(WRCLK),
        .WREN(WREN)
    );

    fifo_512x128 #(
	.ALMOST_FULL_OFFSET1(13'h0044),
	.ALMOST_FULL_OFFSET2(13'h0004),
	.ALMOST_EMPTY_OFFSET1(ALMOST_EMPTY_OFFSET1),
	.ALMOST_EMPTY_OFFSET2(ALMOST_EMPTY_OFFSET2),
        .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH)
    ) outfifo (
	.RST(reset_buf),
	// output
	.DO(DO),
	.EMPTY(EMPTY),
	.ALMOSTEMPTY1(ALMOSTEMPTY1),
	.ALMOSTEMPTY2(ALMOSTEMPTY2),
	.RDERR(RDERR),
	.RDCLK(RDCLK),
	.RDEN(RDEN),
	// input
        .DI(app_rd_data),
	.FULL(),
        .ALMOSTFULL1(outfifo_almost_full),
        .ALMOSTFULL2(),
        .WRERR(outfifo_err_w),
        .WRCLK(uiclk),
        .WREN(app_rd_data_valid)
    );

    mig_7series_0 # (
   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
   .BANK_WIDTH                    (3),
                                     // # of memory Bank Address bits.
   .CK_WIDTH                      (1),
                                     // # of CK/CK# outputs to memory.
   .COL_WIDTH                     (10),
                                     // # of memory Column Address bits.
   .CS_WIDTH                      (1),
                                     // # of unique CS outputs to memory.
   .nCS_PER_RANK                  (1),
                                     // # of unique CS outputs per rank for phy
   .CKE_WIDTH                     (1),
                                     // # of CKE outputs to memory.
   .DATA_BUF_ADDR_WIDTH           (5),
   .DQ_CNT_WIDTH                  (4),
                                     // = ceil(log2(DQ_WIDTH))
   .DQ_PER_DM                     (8),
   .DM_WIDTH                      (2),
                                     // # of DM (data mask)
   .DQ_WIDTH                      (16),
                                     // # of DQ (data)
   .DQS_WIDTH                     (2),
   .DQS_CNT_WIDTH                 (1),
                                     // = ceil(log2(DQS_WIDTH))
   .DRAM_WIDTH                    (8),
                                     // # of DQ per DQS
   .ECC                           ("OFF"),
   .DATA_WIDTH                    (16),
   .ECC_TEST                      ("OFF"),
   .PAYLOAD_WIDTH                 (16),
   .nBANK_MACHS                   (4),
   .RANKS                         (1),
                                     // # of Ranks.
   .ODT_WIDTH                     (1),
                                     // # of ODT outputs to memory.
   .ROW_WIDTH                     (14),
                                     // # of memory Row Address bits.
   .ADDR_WIDTH                    (28),
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
   .USE_CS_PORT                   (0),
                                     // # = 1, When Chip Select (CS#) output is enabled
                                     //   = 0, When Chip Select (CS#) output is disabled
                                     // If CS_N disabled, user must connect
                                     // DRAM CS_N input(s) to ground
   .USE_DM_PORT                   (1),
                                     // # = 1, When Data Mask option is enabled
                                     //   = 0, When Data Mask option is disbaled
                                     // When Data Mask option is disabled in
                                     // MIG Controller Options page, the logic
                                     // related to Data Mask should not get
                                     // synthesized
   .USE_ODT_PORT                  (1),
                                     // # = 1, When ODT output is enabled
                                     //   = 0, When ODT output is disabled
   .PHY_CONTROL_MASTER_BANK       (0),
                                     // The bank index where master PHY_CONTROL resides,
                                     // equal to the PLL residing bank

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   .AL                            ("0"),
                                     // DDR3 SDRAM:
                                     // Additive Latency (Mode Register 1).
                                     // # = "0", "CL-1", "CL-2".
                                     // DDR2 SDRAM:
                                     // Additive Latency (Extended Mode Register).
   .nAL                           (0),
                                     // # Additive Latency in number of clock
                                     // cycles.
   .BURST_MODE                    ("8"),
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
   .BURST_TYPE                    ("SEQ"),
                                     // DDR3 SDRAM: Burst Type (Mode Register 0).
                                     // DDR2 SDRAM: Burst Type (Mode Register).
                                     // # = "SEQ" - (Sequential),
                                     //   = "INT" - (Interleaved).
   .CL                            (7),
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     // DDR2 SDRAM: CAS Latency (Mode Register).
   .CWL                           (6),
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     // DDR2 SDRAM: Can be ignored
   .OUTPUT_DRV                    ("HIGH"),
                                     // Output Driver Impedance Control (Mode Register 1).
                                     // # = "HIGH" - RZQ/7,
                                     //   = "LOW" - RZQ/6.
   .RTT_NOM                       ("40"),
                                     // RTT_NOM (ODT) (Mode Register 1).
                                     // # = "DISABLED" - RTT_NOM disabled,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
                                     //   = "40"  - RZQ/6.
   .RTT_WR                        ("OFF"),
                                     // RTT_WR (ODT) (Mode Register 2).
                                     // # = "OFF" - Dynamic ODT off,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
   .ADDR_CMD_MODE                 ("1T" ),
                                     // # = "1T", "2T".
   .REG_CTRL                      ("OFF"),
                                     // # = "ON" - RDIMMs,
                                     //   = "OFF" - Components, SODIMMs, UDIMMs.
   .CA_MIRROR                     ("OFF"),
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   .CLKIN_PERIOD                  (15000),
                                     // Input Clock Period
   .CLKFBOUT_MULT                 (12),
                                     // write PLL VCO multiplier
   .DIVCLK_DIVIDE                 (1),
                                     // write PLL VCO divisor
   .CLKOUT0_DIVIDE                (1),
                                     // VCO output divisor for PLL output clock (CLKOUT0)
   .CLKOUT1_DIVIDE                (2),
                                     // VCO output divisor for PLL output clock (CLKOUT1)
   .CLKOUT2_DIVIDE                (32),
                                     // VCO output divisor for PLL output clock (CLKOUT2)
   .CLKOUT3_DIVIDE                (8),
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Memory Timing Parameters. These parameters varies based on the selected
   // memory part.
   //***************************************************************************
   .tCKE                          (5000),
                                     // memory tCKE paramter in pS.
   .tFAW                          (40000),
                                     // memory tRAW paramter in pS.
   .tPRDI                         (1_000_000),
                                     // memory tPRDI paramter in pS.
   .tRAS                          (35000),
                                     // memory tRAS paramter in pS.
   .tRCD                          (13750),
                                     // memory tRCD paramter in pS.
   .tREFI                         (7800000),
                                     // memory tREFI paramter in pS.
   .tRFC                          (160000),
                                     // memory tRFC paramter in pS.
   .tRP                           (13750),
                                     // memory tRP paramter in pS.
   .tRRD                          (7500),
                                     // memory tRRD paramter in pS.
   .tRTP                          (7500),
                                     // memory tRTP paramter in pS.
   .tWTR                          (7500),
                                     // memory tWTR paramter in pS.
   .tZQI                          (128_000_000),
                                     // memory tZQI paramter in nS.
   .tZQCS                         (64),
                                     // memory tZQCS paramter in clock cycles.

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   .SIM_BYPASS_INIT_CAL           ("OFF"),
                                     // # = "OFF" -  Complete memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence
   .SIMULATION                    ("FALSE"),
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
   .BYTE_LANES_B0                 (4'b1111),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B1                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B2                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B3                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .BYTE_LANES_B4                 (4'b0000),
                                     // Byte lanes used in an IO column.
   .DATA_CTL_B0                   (4'b0011),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B1                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B2                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B3                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   .DATA_CTL_B4                   (4'b0000),
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane

   .PHY_0_BITLANES                (48'hFFF_CFF_3DF_2FF),
   .PHY_1_BITLANES                (48'h000_000_000_000),
   .PHY_2_BITLANES                (48'h000_000_000_000),
   .CK_BYTE_MAP                   (144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_02),
   .ADDR_MAP                      (192'h000_000_037_025_03A_024_035_03B_039_027_031_026_023_034_036_038),
   .BANK_MAP                      (36'h033_02A_032),
   .CAS_MAP                       (12'h020),
   .CKE_ODT_BYTE_MAP              (8'h00),
   .CKE_MAP                       (96'h000_000_000_000_000_000_000_02B),
   .ODT_MAP                       (96'h000_000_000_000_000_000_000_030),
   .CS_MAP                        (120'h000_000_000_000_000_000_000_000_000_000),
   .PARITY_MAP                    (12'h000),
   .RAS_MAP                       (12'h021),
   .WE_MAP                        (12'h022),
   .DQS_BYTE_MAP                  (144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_01),
   .DATA0_MAP                     (96'h016_018_014_019_010_017_011_013),
   .DATA1_MAP                     (96'h003_002_005_004_001_006_000_007),
   .DATA2_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA3_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA4_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA5_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA6_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA7_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA8_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA9_MAP                     (96'h000_000_000_000_000_000_000_000),
   .DATA10_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA11_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA12_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA13_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA14_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA15_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA16_MAP                    (96'h000_000_000_000_000_000_000_000),
   .DATA17_MAP                    (96'h000_000_000_000_000_000_000_000),
   .MASK0_MAP                     (108'h000_000_000_000_000_000_000_009_012),
   .MASK1_MAP                     (108'h000_000_000_000_000_000_000_000_000),

   .SLOT_0_CONFIG                 (8'b0000_0001),
                                     // Mapping of Ranks.
   .SLOT_1_CONFIG                 (8'b0000_0000),
                                     // Mapping of Ranks.
   .MEM_ADDR_ORDER                ("BANK_ROW_COLUMN"),
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   .IBUF_LPWR_MODE                ("OFF"),
                                     // to phy_top
   .DATA_IO_IDLE_PWRDWN           ("ON"),
                                     // # = "ON", "OFF"
   .DATA_IO_PRIM_TYPE             ("HR_LP"),
                                     // # = "HP_LP", "HR_LP", "DEFAULT"
   .CKE_ODT_AUX                   ("FALSE"),
   .USER_REFRESH                  ("OFF"),
   .WRLVL                         ("ON"),
                                     // # = "ON" - DDR3 SDRAM
                                     //   = "OFF" - DDR2 SDRAM.
   .ORDERING                      ("NORM"),
                                     // # = "NORM", "STRICT", "RELAXED".
   .CALIB_ROW_ADD                 (16'h0000),
                                     // Calibration row address will be used for
                                     // calibration read and write operations
   .CALIB_COL_ADD                 (12'h000),
                                     // Calibration column address will be used for
                                     // calibration read and write operations
   .CALIB_BA_ADD                  (3'h0),
                                     // Calibration bank address will be used for
                                     // calibration read and write operations
   .TCQ                           (100),
   .IODELAY_GRP                   ("MIG_7SERIES_0_IODELAY_MIG"),
                                     // It is associated to a set of IODELAYs with
                                     // an IDELAYCTRL that have same IODELAY CONTROLLER
                                     // clock frequency.
   .SYSCLK_TYPE                   ("NO_BUFFER"),
                                     // System clock type DIFFERENTIAL or SINGLE_ENDED
   .REFCLK_TYPE                   ("NO_BUFFER"),
                                     // Reference clock type DIFFERENTIAL or SINGLE_ENDED
   .CMD_PIPE_PLUS1                ("ON"),
                                     // add pipeline stage between MC and PHY
   .DRAM_TYPE                       ("DDR3"),
   .CAL_WIDTH                     ("HALF"),
   .STARVE_LIMIT                  (2),
                                     // # = 2,3,4.
   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   .REFCLK_FREQ                   (200.0),
                                     // IODELAYCTRL reference clock frequency
   .DIFF_TERM_REFCLK              ("TRUE"),
                                     // Differential Termination for idelay
                                     // reference clock input pins
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   .tCK                           (3000),
                                     // memory tCK paramter.
                                     // # = Clock Period in pS.
   .nCK_PER_CLK                   (4),
                                     // # of memory CKs per fabric CLK
   .DIFF_TERM_SYSCLK              ("TRUE"),
                                     // Differential Termination for System
                                     // clock input pins

   
   //***************************************************************************
   // Debug parameters
   //***************************************************************************
   .DEBUG_PORT                      ("OFF"),
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
      
   .RST_ACT_LOW                   (1)
                                     // =1 for active low reset,
                                     // =0 for active high.
   )
//***************************************************************************
// end of section copied from mig_7series_0.voe
//***************************************************************************
    mem0 (
// Memory interface ports
	.ddr3_dq(ddr3_dq),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_dqs_p(ddr3_dqs_p),
        .ddr3_addr(ddr3_addr),
        .ddr3_ba(ddr3_ba),
        .ddr3_ras_n(ddr3_ras_n),
        .ddr3_cas_n(ddr3_cas_n),
        .ddr3_we_n(ddr3_we_n),
        .ddr3_reset_n(ddr3_reset_n),
        .ddr3_ck_p(ddr3_ck_p[0]),
        .ddr3_ck_n(ddr3_ck_n[0]),
        .ddr3_cke(ddr3_cke[0]),
	.ddr3_dm(ddr3_dm),
        .ddr3_odt(ddr3_odt[0]),
// Application interface ports
        .app_addr( {1'b0, app_addr, 3'b000} ),	
        .app_cmd(app_cmd),
        .app_en(app_en),
        .app_rdy(app_rdy),
        .app_wdf_rdy(app_wdf_rdy), 
        .app_wdf_data(app_wdf_data),
        .app_wdf_mask({ APP_MASK_WIDTH {1'b0} }),
        .app_wdf_end(app_wdf_wren), // always the last word in 4:1 mode 
        .app_wdf_wren(app_wdf_wren),
        .app_rd_data(app_rd_data),
        .app_rd_data_end(app_rd_data_end),
        .app_rd_data_valid(app_rd_data_valid),
        .app_sr_req(1'b0), 
        .app_sr_active(),
        .app_ref_req(1'b0),
        .app_ref_ack(),
        .app_zq_req(1'b0),
        .app_zq_ack(),
        .ui_clk(uiclk),
        .ui_clk_sync_rst(ui_clk_sync_rst),
        .init_calib_complete(init_calib_complete),
        .sys_rst(!reset),
// clocks inputs
        .sys_clk_i(clk67),
        .clk_ref_i(clk200)
    );

    assign mem_reset = reset || ui_clk_sync_rst || !init_calib_complete;
    assign reset_out = reset_buf;
    assign wr_mode = wr_mode_buf && app_wdf_rdy && !infifo_empty;
    assign infifo_rden = app_rdy && wr_mode && !rd_mode;
    
    assign status[0] = init_calib_complete;
    assign status[1] = app_rdy;
    assign status[2] = app_wdf_rdy;
    assign status[3] = app_rd_data_valid;
    assign status[4] = infifo_err;
    assign status[5] = outfifo_err;
    assign status[6] = outfifo_err_uf;
    assign status[7] = wr_mode;
    assign status[8] = rd_mode;
    assign status[9] = !reset;
    
    assign mem_free_out = mem_free;

    always @ (posedge uiclk)
    begin
// reset
	reset_buf <= mem_reset;

	// used for debuggig only
	if ( reset_buf ) outfifo_err <= 1'b0;
	else if ( outfifo_err_w ) outfifo_err <= 1'b1;
	if ( reset_buf ) infifo_err <= 1'b0;
	else if ( infifo_err_w ) infifo_err <= 1'b1;

	// memory interface --> outfifo
	if ( reset_buf )
	begin
	    outfifo_err_uf <= 1'b0;
	    outfifo_pending <= 6'd0;
	end else if ( app_rd_data_valid && !(rd_mode && app_rdy) ) 
	begin
	    if ( outfifo_pending != 6'd0 ) 
	    begin
		outfifo_pending = outfifo_pending - 6'd1;
	    end else 
	    begin
	        outfifo_err_uf <= 1'b1;
	    end
	end else if ( (!app_rd_data_valid) && rd_mode && app_rdy ) 
	begin
	    outfifo_pending = outfifo_pending + 6'd1;
	end
	
	// wr_mode
	if ( reset_buf )
	begin
	    wr_mode_buf <= 1'b0;
	end else if ( infifo_empty || (!app_wdf_rdy) || wr_cnt[7] || ( mem_free[APP_ADDR_WIDTH:1] == {APP_ADDR_WIDTH{1'b0}} ) )     //  at maximum 128 words
	begin
	    wr_mode_buf <= 1'b0;
	end else if ( (!rd_mode) && !infifo_almost_empty && (mem_free[APP_ADDR_WIDTH:5] != {(APP_ADDR_WIDTH-4){1'b0}}) )  // at least 32 words
	begin
	    wr_mode_buf <= 1'b1;
	end

	// rd_mode
	if ( reset_buf )
	begin
	    rd_mode <= 1'b0;
	end else if ( rd_mode || outfifo_almost_full || (outfifo_pending == 6'd31) || rd_cnt[7] || ( mem_free[APP_ADDR_WIDTH-1:0] == {(APP_ADDR_WIDTH){1'b1}}) || mem_free[APP_ADDR_WIDTH] )	 //  at maximum 128 words )
	begin
	    rd_mode <= 1'b0;
	end else if ( (!wr_mode_buf) && (outfifo_pending == 6'd0) && (mem_free[APP_ADDR_WIDTH-1:5] != {(APP_ADDR_WIDTH-5){1'b1}}) )  // at least 32 words
	begin
	    rd_mode <= 1'b1;
	end

	if ( reset_buf )
	begin
    	    rd_cnt_dbg <= 10'd0;
    	end else if ( app_rd_data_valid )
	begin
    	    rd_cnt_dbg <= rd_cnt_dbg + 1;
    	end;
	
// command generator
	if ( reset_buf )
	begin
	    app_en <= 1'b0;
	    mem_wr_addr <= {APP_ADDR_WIDTH{1'b0}};
	    mem_rd_addr <= {APP_ADDR_WIDTH{1'b0}};
  	    mem_free <= {1'b1, {APP_ADDR_WIDTH{1'b0}}};
	    wr_cnt <= 8'd0;
	    rd_cnt <= 8'd0;
	end else if ( app_rdy )
	begin
	    if ( rd_mode )
	    begin
		app_cmd <= 3'b001;
		app_en <= 1'b1;
		app_addr <= mem_rd_addr;
		mem_rd_addr <= mem_rd_addr + 1;
	        rd_cnt <= rd_cnt + 1;
		wr_cnt <= 8'd0;
	        mem_free <= mem_free + 1;
	    end else if ( wr_mode )
	    begin
		app_cmd <= 3'b000;
		app_en <= 1'b1;
		app_addr <= mem_wr_addr;
		app_wdf_data <= infifo_do;
//		app_wdf_data <= { 8{mem_wr_addr[15:0]} };
//		app_wdf_data <= { {7{mem_wr_addr[15:0]}},  infifo_do[71:64], infifo_do[7:0] };
		mem_wr_addr <= mem_wr_addr + 1;
		mem_free <= mem_free - 1;
		wr_cnt <= wr_cnt + 1;
		rd_cnt <= 8'd0;
	    end else
	    begin
		app_en <= 1'b0;
		wr_cnt <= 8'd0;
		rd_cnt <= 8'd0;
	    end
	end

	if ( reset_buf )
	begin
	    app_wdf_wren <= 1'b0;
//   infifo_rden <= 1'b0;
	end else if ( app_rdy && (!rd_mode) && wr_mode )
	begin
	    app_wdf_wren <= 1'b1;
//   infifo_rden <= 1'b1;
	end else 
	begin
	    if ( app_wdf_rdy ) app_wdf_wren <= 1'b0;
//   infifo_rden <= 1'b0;
	end
	

    end

endmodule

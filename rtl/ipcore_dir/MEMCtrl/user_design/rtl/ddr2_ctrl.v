//*****************************************************************************
// DISCLAIMER OF LIABILITY
//
// This file contains proprietary and confidential information of
// Xilinx, Inc. ("Xilinx"), that is distributed under a license
// from Xilinx, and may be used, copied and/or disclosed only
// pursuant to the terms of a valid license agreement with Xilinx.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
// ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
// LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
// MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
// does not warrant that functions included in the Materials will
// meet the requirements of Licensee, or that the operation of the
// Materials will be uninterrupted or error-free, or that defects
// in the Materials will be corrected. Furthermore, Xilinx does
// not warrant or make any representations regarding use, or the
// results of the use, of the Materials in terms of correctness,
// accuracy, reliability or otherwise.
//
// Xilinx products are not designed or intended to be fail-safe,
// or for use in any application requiring fail-safe performance,
// such as life-support or safety devices or systems, Class III
// medical devices, nuclear facilities, applications related to
// the deployment of airbags, or any other applications that could
// lead to death, personal injury or severe property or
// environmental damage (individually and collectively, "critical
// applications"). Customer assumes the sole risk and liability
// of any use of Xilinx products in critical applications,
// subject only to applicable laws and regulations governing
// limitations on product liability.
//
// Copyright 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: 3.6.1
//  \   \         Application: MIG
//  /   /         Filename: ddr2_ctrl.v
// /___/   /\     Date Last Modified: $Date: 2010/11/26 18:26:02 $
// \   \  /  \    Date Created: Wed Aug 30 2006
//  \___\/\___\
//
//
//Device: Virtex-5
//Design Name: DDR/DDR2
//Purpose:
//   This module is the main control logic of the memory interface. All
//   commands are issued from here according to the burst, CAS Latency and the
//   user commands.
//Reference:
//Revision History:
//   Rev 1.2 - Fixed auto refresh to activate bug. KP 11-19-2007
//   Rev 1.3 - For Dual Rank parts support CS logic modified. KP. 05/08/08
//   Rev 1.4 - AUTO_REFRESH_WAIT state modified for Auto Refresh flag asserted
//             immediately after calibration is completed. KP. 07/28/08
//   Rev 1.5 - Assignment of bank_valid_r is modified to fix a bug in 
//             Bank Management logic. PK. 10/29/08
//*****************************************************************************

`timescale 1ns/1ps

module ddr2_ctrl #
  (
   // Following parameters are for 72-bit RDIMM design (for ML561 Reference
   // board design). Actual values may be different. Actual parameters values
   // are passed from design top module MEMCtrl module. Please refer to
   // the MEMCtrl module for actual values.
   parameter BANK_WIDTH    = 2,
   parameter COL_WIDTH     = 10,
   parameter CS_BITS       = 0,
   parameter CS_NUM        = 1,
   parameter ROW_WIDTH     = 14,
   parameter ADDITIVE_LAT  = 0,
   parameter BURST_LEN     = 4,
   parameter CAS_LAT       = 5,
   parameter ECC_ENABLE    = 0,
   parameter REG_ENABLE    = 1,
   parameter TREFI_NS      = 7800,
   parameter TRAS          = 40000,
   parameter TRCD          = 15000,
   parameter TRRD          = 10000,
   parameter TRFC          = 105000,
   parameter TRP           = 15000,
   parameter TRTP          = 7500,
   parameter TWR           = 15000,
   parameter TWTR          = 10000,
   parameter CLK_PERIOD    = 3000,
   parameter MULTI_BANK_EN = 1,
   parameter TWO_T_TIME_EN = 0,
   parameter DDR_TYPE      = 1
   )
  (
   input                   clk,
   input                   rst,
   input [2:0]             af_cmd,
   input [30:0]            af_addr,
   input                   af_empty,
   input                   phy_init_done,
   output                  ctrl_ref_flag,
   output                  ctrl_af_rden,
   output reg              ctrl_wren,
   output reg              ctrl_rden,
   output [ROW_WIDTH-1:0]  ctrl_addr,
   output [BANK_WIDTH-1:0] ctrl_ba,
   output                  ctrl_ras_n,
   output                  ctrl_cas_n,
   output                  ctrl_we_n,
   output [CS_NUM-1:0]     ctrl_cs_n
   );

  // input address split into various ranges
  localparam ROW_RANGE_START     = COL_WIDTH;
  localparam ROW_RANGE_END       = ROW_WIDTH + ROW_RANGE_START - 1;
  localparam BANK_RANGE_START    = ROW_RANGE_END + 1;
  localparam BANK_RANGE_END      = BANK_WIDTH + BANK_RANGE_START - 1;
  localparam CS_RANGE_START      = BANK_RANGE_START + BANK_WIDTH;
  localparam CS_RANGE_END        = CS_BITS + CS_RANGE_START - 1;
  // compare address (for determining bank/row hits) split into various ranges
  // (compare address doesn't include column bits)
  localparam CMP_WIDTH            = CS_BITS + BANK_WIDTH + ROW_WIDTH;
  localparam CMP_ROW_RANGE_START  = 0;
  localparam CMP_ROW_RANGE_END    = ROW_WIDTH + CMP_ROW_RANGE_START - 1;
  localparam CMP_BANK_RANGE_START = CMP_ROW_RANGE_END + 1;
  localparam CMP_BANK_RANGE_END   = BANK_WIDTH + CMP_BANK_RANGE_START - 1;
  localparam CMP_CS_RANGE_START   = CMP_BANK_RANGE_END + 1;
  localparam CMP_CS_RANGE_END     = CS_BITS + CMP_CS_RANGE_START-1;

  localparam BURST_LEN_DIV2      = BURST_LEN / 2;
  localparam OPEN_BANK_NUM       = 4;
  localparam CS_BITS_FIX         = (CS_BITS == 0) ? 1 : CS_BITS;

  // calculation counters based on clock cycle and memory parameters
  // TRAS: ACTIVE->PRECHARGE interval - 2
  localparam integer TRAS_CYC = (TRAS + CLK_PERIOD)/CLK_PERIOD;
  // TRCD: ACTIVE->READ/WRITE interval - 3 (for DDR2 factor in ADD_LAT)
  localparam integer TRRD_CYC = (TRRD + CLK_PERIOD)/CLK_PERIOD;
  localparam integer TRCD_CYC = (((TRCD + CLK_PERIOD)/CLK_PERIOD) >
                                 ADDITIVE_LAT )?
             ((TRCD+CLK_PERIOD)/ CLK_PERIOD) - ADDITIVE_LAT : 0;
  // TRFC: REFRESH->REFRESH, REFRESH->ACTIVE interval - 2
  localparam integer TRFC_CYC = (TRFC + CLK_PERIOD)/CLK_PERIOD;
  // TRP: PRECHARGE->COMMAND interval - 2
   // for precharge all add 1 extra clock cycle
  localparam integer TRP_CYC =  ((TRP + CLK_PERIOD)/CLK_PERIOD) +1;
  // TRTP: READ->PRECHARGE interval - 2 (Al + BL/2 + (max (TRTP, 2tck))-2
  localparam integer TRTP_TMP_MIN = (((TRTP + CLK_PERIOD)/CLK_PERIOD) >= 2)?
                                     ((TRTP + CLK_PERIOD)/CLK_PERIOD) : 2;
  localparam integer TRTP_CYC = TRTP_TMP_MIN + ADDITIVE_LAT
                                + BURST_LEN_DIV2 - 2;
  // TWR: WRITE->PRECHARGE interval - 2
  localparam integer WR_LAT = (DDR_TYPE > 0) ? CAS_LAT + ADDITIVE_LAT - 1 : 1;
  localparam integer TWR_CYC = ((TWR + CLK_PERIOD)/CLK_PERIOD) +
             WR_LAT + BURST_LEN_DIV2 ;
  // TWTR: WRITE->READ interval - 3 (for DDR1, TWTR = 2 clks)
  // DDR2 = CL-1 + BL/2 +TWTR
  localparam integer TWTR_TMP_MIN = ((TWTR + CLK_PERIOD) % CLK_PERIOD)?((TWTR + CLK_PERIOD)/CLK_PERIOD) + 1:(TWTR + CLK_PERIOD)/CLK_PERIOD;
  localparam integer TWTR_CYC = (DDR_TYPE > 0) ? (TWTR_TMP_MIN + (CAS_LAT -1)
                                 + BURST_LEN_DIV2 ): 2;

  //  TRTW: READ->WRITE interval - 3
  //  DDR1: CL + (BL/2)
  //  DDR2: (BL/2) + 2. Two more clocks are added to
  //  the DDR2 counter to account for the delay in
  //  arrival of the DQS during reads (pcb trace + buffer
  //  delays + memory parameters).
  localparam TRTW_CYC = (DDR_TYPE > 0) ? BURST_LEN_DIV2 + 4 :
             (CAS_LAT == 25) ? 2 + BURST_LEN_DIV2 : CAS_LAT + BURST_LEN_DIV2;

  localparam integer CAS_LAT_RD = (CAS_LAT == 25) ? 2 : CAS_LAT;

  // Make sure all values >= 0 (some may be = 0)
  localparam TRAS_COUNT = (TRAS_CYC > 0) ? TRAS_CYC : 0;
  localparam TRCD_COUNT = (TRCD_CYC > 0) ? TRCD_CYC : 0;
  localparam TRRD_COUNT = (TRRD_CYC > 0) ? TRRD_CYC : 0;
  localparam TRFC_COUNT = (TRFC_CYC > 0) ? TRFC_CYC : 0;
  localparam TRP_COUNT  = (TRP_CYC > 0)  ? TRP_CYC  : 0;
  localparam TRTP_COUNT = (TRTP_CYC > 0) ? TRTP_CYC : 0;
  localparam TWR_COUNT  = (TWR_CYC > 0)  ? TWR_CYC  : 0;
  localparam TWTR_COUNT = (TWTR_CYC > 0) ? TWTR_CYC : 0;
  localparam TRTW_COUNT = (TRTW_CYC > 0) ? TRTW_CYC : 0;

  // Auto refresh interval
  localparam TREFI_COUNT = ((TREFI_NS * 1000)/CLK_PERIOD) - 1;

  // memory controller states
  localparam   CTRL_IDLE                =     5'h00;
  localparam   CTRL_PRECHARGE           =     5'h01;
  localparam   CTRL_PRECHARGE_WAIT      =     5'h02;
  localparam   CTRL_AUTO_REFRESH        =     5'h03;
  localparam   CTRL_AUTO_REFRESH_WAIT   =     5'h04;
  localparam   CTRL_ACTIVE              =     5'h05;
  localparam   CTRL_ACTIVE_WAIT         =     5'h06;
  localparam   CTRL_BURST_READ          =     5'h07;
  localparam   CTRL_READ_WAIT           =     5'h08;
  localparam   CTRL_BURST_WRITE         =     5'h09;
  localparam   CTRL_WRITE_WAIT          =     5'h0A;
  localparam   CTRL_PRECHARGE_WAIT1     =     5'h0B;


  reg [CMP_WIDTH-1:0]                      act_addr_r;
  wire [30:0]                              af_addr_r;
  reg [30:0]                               af_addr_r1;
  reg [30:0]                               af_addr_r2;
  reg [30:0]                               af_addr_r3;
  wire [2:0]                               af_cmd_r;
  reg [2:0]                                af_cmd_r1;
  reg [2:0]                                af_cmd_r2;
  reg                                      af_valid_r;
  reg                                      af_valid_r1;
  reg                                      af_valid_r2;
  reg [CS_BITS_FIX :0]                     auto_cnt_r;
  reg                                      auto_ref_r;
  reg [(OPEN_BANK_NUM*CMP_WIDTH)-1:0]      bank_cmp_addr_r;
  reg [OPEN_BANK_NUM-1:0]                  bank_hit;
  reg [OPEN_BANK_NUM-1:0]                  bank_hit_r;
  reg [OPEN_BANK_NUM-1:0]                  bank_hit_r1;
  reg [OPEN_BANK_NUM-1:0]                  bank_valid_r;
  reg                                      bank_conflict_r;
  reg                                      conflict_resolved_r;
  reg                                      ctrl_af_rden_r;
  reg                                      conflict_detect_r;
  wire                                     conflict_detect;
  reg                                      cs_change_r;
  reg                                      cs_change_sticky_r;
  reg [ROW_WIDTH-1:0]                      ddr_addr_r;
  wire [ROW_WIDTH-1:0]                     ddr_addr_col;
  wire [ROW_WIDTH-1:0]                     ddr_addr_row;
  reg [BANK_WIDTH-1:0]                     ddr_ba_r;
  reg                                      ddr_cas_n_r;
  reg [CS_NUM-1:0]                         ddr_cs_n_r;
  reg                                      ddr_ras_n_r;
  reg                                      ddr_we_n_r;
  reg [4:0]                                next_state;
  reg                                      no_precharge_wait_r;
  reg                                      no_precharge_r;
  reg                                      no_precharge_r1;
  reg                                      phy_init_done_r;
  reg [4:0]                                precharge_ok_cnt_r;
  reg                                      precharge_ok_r;
  reg [4:0]                                ras_cnt_r;
  reg [3:0]                                rcd_cnt_r;
  reg                                      rcd_cnt_ok_r;
  reg [2:0]                                rdburst_cnt_r;
  reg                                      rdburst_ok_r;
  reg                                      rdburst_rden_ok_r;
  reg                                      rd_af_flag_r;
  wire                                     rd_flag;
  reg                                      rd_flag_r;
  reg [4:0]                                rd_to_wr_cnt_r;
  reg                                      rd_to_wr_ok_r;
  reg                                      ref_flag_r;
  reg [11:0]                               refi_cnt_r;
  reg                                      refi_cnt_ok_r;
  reg                                      rst_r
                                           /* synthesis syn_preserve = 1 */;
  reg                                      rst_r1
                                           /* synthesis syn_maxfan = 10 */;
  reg [7:0]                                rfc_cnt_r;
  reg                                      rfc_ok_r;
  reg [3:0]                                row_miss;
  reg [3:0]                                row_conflict_r;
  reg [3:0]                                rp_cnt_r;
  reg                                      rp_cnt_ok_r;
  reg [CMP_WIDTH-1:0]                      sb_open_add_r;
  reg [4:0]                                state_r;
  reg [4:0]                                state_r1;
  wire                                     sm_rden;
  reg                                      sm_rden_r;
  reg [2:0]                                trrd_cnt_r;
  reg                                      trrd_cnt_ok_r;
  reg [2:0]                                two_t_enable_r;
  reg [CS_NUM-1:0]                         two_t_enable_r1;
  reg [2:0]                                wrburst_cnt_r;
  reg                                      wrburst_ok_r;
  reg                                      wrburst_wren_ok_r;
  wire                                     wr_flag;
  reg                                      wr_flag_r;
  reg [4:0]                                wr_to_rd_cnt_r;
  reg                                      wr_to_rd_ok_r;

  // XST attributes for local reset "tree"
  // synthesis attribute shreg_extract of rst_r is "no";
  // synthesis attribute shreg_extract of rst_r1 is "no";
  // synthesis attribute equivalent_register_removal of rst_r is "no"

  //***************************************************************************

  // sm_rden is used to assert read enable to the address FIFO
  assign sm_rden = ((state_r == CTRL_BURST_WRITE) ||
                    (state_r == CTRL_BURST_READ)) ;

  // assert read flag to the adress FIFO
  assign ctrl_af_rden = sm_rden || rd_af_flag_r;

  // local reset "tree" for controller logic only. Create this to ease timing
  // on reset path. Prohibit equivalent register removal on RST_R to prevent
  // "sharing" with other local reset trees (caution: make sure global fanout
  // limit is set to large enough value, otherwise SLICES may be used for
  // fanout control on RST_R.
  always @(posedge clk) begin
    rst_r  <= rst;
    rst_r1 <= rst_r;
  end

  //*****************************************************************
  // interpret commands from Command/Address FIFO
  //*****************************************************************

  assign wr_flag = (af_valid_r2) ? ((af_cmd_r2 == 3'b000) ? 1'b1 : 1'b0): 1'b0;
  assign rd_flag = (af_valid_r2) ? ((af_cmd_r2 == 3'b001) ? 1'b1 : 1'b0): 1'b0;

  always @(posedge clk) begin
    rd_flag_r <= rd_flag;
    wr_flag_r <= wr_flag;
  end

  //////////////////////////////////////////////////
  // The data from the address FIFO is fetched and
  // stored in two register stages. The data will be
  // pulled out of the second register stage whenever
  // the state machine can handle new data from the
  // address FIFO.

  // This flag is asserted when there is no
  // cmd & address in the pipe. When there is
  // valid cmd & addr from the address FIFO the
  // af_valid signals will be asserted. This flag will
  // be set the cycle af_valid_r is de-asserted.
  always @(posedge clk) begin
    // for simulation purposes - to force CTRL_AF_RDEN low during reset
    if (rst_r1)
      rd_af_flag_r <= 1'd0;
    else if((ctrl_af_rden_r) ||
            (rd_af_flag_r && (af_valid_r || af_valid_r1)))
         rd_af_flag_r <= 1'd0;
    else if (~af_valid_r1 || ~af_valid_r)
         rd_af_flag_r <= 1'd1;

  end

  // First register stage for the cmd & add from the FIFO.
  // The af_valid_r signal gives the status of the data
  // in this stage. The af_valid_r will be asserted when there
  // is valid data. This register stage will be updated
  // 1. read to the FIFO and the FIFO not empty
  // 2. After write and read states
  // 3. The valid signal is not asserted in the last stage.
  always @(posedge clk) begin
    if (rst_r1)begin
      af_valid_r <= 1'd0;
    end else begin
      if (ctrl_af_rden_r || sm_rden_r || ~af_valid_r1
          || ~af_valid_r2)begin
        af_valid_r <= ctrl_af_rden_r;
      end
    end
  end

  // The output register in the FIFO is used. The addr
  // and command are already registered in the FIFO.
  assign af_addr_r = af_addr;
  assign af_cmd_r = af_cmd;

  // Second register stage for the cmd & add from the FIFO.
  // The af_valid_r1 signal gives the status of the data
  // in this stage. The af_valid_r will be asserted when there
  // is valid data. This register stage will be updated
  // 1. read to the FIFO and the FIFO not empty and there
  // is no valid data on this stage
  // 2. After write and read states
  // 3. The valid signal is not asserted in the last stage.
  always@(posedge clk) begin
    if (rst_r1)begin
      af_valid_r1 <= 1'd0;
      af_addr_r1 <= {31{1'bx}};
      af_cmd_r1 <= {3{1'bx}};
    end else if (~af_valid_r1 || sm_rden_r ||
                  ~af_valid_r2) begin
      af_valid_r1 <= af_valid_r;
      af_addr_r1 <= af_addr_r;
      af_cmd_r1 <= af_cmd_r;
    end
  end

  // The state machine uses the address and command in this
  // register stage. The data is fetched from the second
  // register stage whenever the state machine can accept new
  // addr. The conflict flags are also generated based on the
  // second register stage and updated when the new address
  // is loaded for the state machine.
  always@(posedge clk) begin
    if (rst_r1)begin
      af_valid_r2 <= 1'd0;
      af_addr_r2 <= {31{1'bx}};
      af_cmd_r2 <= {3{1'bx}};
      bank_hit_r <= {OPEN_BANK_NUM{1'bx}};
      bank_conflict_r <= 1'bx;
      row_conflict_r <= 4'bx;
    end else if(sm_rden || ~af_valid_r2)begin
      af_valid_r2 <= af_valid_r1;
      af_addr_r2 <= af_addr_r1;
      af_cmd_r2 <= af_cmd_r1;
      if(MULTI_BANK_EN)begin
        bank_hit_r <= bank_hit;
        row_conflict_r <= row_miss;
        bank_conflict_r <= (~(|bank_hit));
      end else begin
        bank_hit_r <= {OPEN_BANK_NUM{1'b0}};
        bank_conflict_r <= 1'd0;
        row_conflict_r[0] <= (af_addr_r1[CS_RANGE_END:ROW_RANGE_START]
                              != sb_open_add_r[CMP_WIDTH-1:0]);
      end
    end
  end // always@ (posedge clk)

  //detecting cs change for multi chip select case
  generate
    if(CS_NUM > 1) begin: gen_cs_change
       always @(posedge clk) begin
          if(sm_rden || ~af_valid_r2)begin
            cs_change_r <= af_addr_r1[CS_RANGE_END:CS_RANGE_START] !=
                       af_addr_r2[CS_RANGE_END:CS_RANGE_START] ;
            cs_change_sticky_r <=
             af_addr_r1[CS_RANGE_END:CS_RANGE_START] !=
             af_addr_r2[CS_RANGE_END:CS_RANGE_START] ;
          end else
            cs_change_r <= 1'd0;
       end
    end // block: gen_cs_change
    else begin: gen_cs_0
       always @(posedge clk) begin
          cs_change_r <= 1'd0;
          cs_change_sticky_r <= 1'd0;
       end
    end
 endgenerate

  assign conflict_detect = (MULTI_BANK_EN) ?
                           ((|(row_conflict_r[3:0] & bank_hit_r[3:0]))
                            | bank_conflict_r) & af_valid_r2 :
                           row_conflict_r[0] & af_valid_r2;

  always @(posedge clk) begin
    conflict_detect_r <= conflict_detect;
    sm_rden_r <= sm_rden;
    af_addr_r3 <= af_addr_r2;
    ctrl_af_rden_r <= ctrl_af_rden & ~af_empty;
  end

  // conflict resolved signal. When this signal is asserted
  // the conflict is resolved. The address to be compared
  // for the conflict_resolved_r will be stored in act_add_r
  // when the bank is opened.
  always @(posedge clk) begin
   conflict_resolved_r <= (act_addr_r ==
                           af_addr_r2[CS_RANGE_END:ROW_RANGE_START]);
    if((state_r == CTRL_ACTIVE))
      act_addr_r <= af_addr_r2[CS_RANGE_END:ROW_RANGE_START];
  end

  //***************************************************************************
  // Bank management logic
  // Semi-hardcoded for now for 4 banks
  // will keep multiple banks open if MULTI_BANK_EN is true.
  //***************************************************************************

  genvar bank_i;
  generate // if multiple bank option chosen
    if(MULTI_BANK_EN) begin: gen_multi_bank_open

      for (bank_i = 0; bank_i < OPEN_BANK_NUM;
           bank_i = bank_i + 1) begin: gen_bank_hit1
        // asserted if bank address match + open bank entry is valid
        always @(*) begin
          bank_hit[bank_i]
            = ((bank_cmp_addr_r[(CMP_WIDTH*(bank_i+1))-1:
                                (CMP_WIDTH*bank_i)+ROW_WIDTH] ==
                af_addr_r1[CS_RANGE_END:BANK_RANGE_START]) &&
               bank_valid_r[bank_i]);
          // asserted if row address match (no check for bank entry valid, rely
          // on this term to be used in conjunction with BANK_HIT[])
          row_miss[bank_i]
            = (bank_cmp_addr_r[(CMP_WIDTH*bank_i)+ROW_WIDTH-1:
                               (CMP_WIDTH*bank_i)] !=
               af_addr_r1[ROW_RANGE_END:ROW_RANGE_START]);
        end
      end

      always @(posedge clk) begin
        no_precharge_wait_r  <= bank_valid_r[3] & bank_conflict_r;
        bank_hit_r1 <= bank_hit_r;
      end

      always@(*)
        no_precharge_r = ~bank_valid_r[3] & bank_conflict_r;

      always@(posedge clk)
        no_precharge_r1 <= no_precharge_r;


      always @(posedge clk) begin
        // Clear all bank valid bits during AR (i.e. since all banks get
        // precharged during auto-refresh)
        if ((state_r1 == CTRL_AUTO_REFRESH)) begin
          bank_valid_r    <= {OPEN_BANK_NUM{1'b0}};
          bank_cmp_addr_r <= {(OPEN_BANK_NUM*CMP_WIDTH-1){1'b0}};
        end else begin
          if (state_r1 == CTRL_ACTIVE) begin
            // 00 is always going to have the latest bank and row.
            bank_cmp_addr_r[CMP_WIDTH-1:0]
              <= af_addr_r3[CS_RANGE_END:ROW_RANGE_START];
            // This indicates the bank was activated
            bank_valid_r[0] <= 1'b1;

            case ({bank_hit_r1[2:0]})
              3'b001: begin
                bank_cmp_addr_r[CMP_WIDTH-1:0]
                  <= af_addr_r3[CS_RANGE_END:ROW_RANGE_START];
                // This indicates the bank was activated
                bank_valid_r[0] <= 1'b1;
              end
              3'b010: begin //(b0->b1)
                bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH]
                  <= bank_cmp_addr_r[CMP_WIDTH-1:0];
                bank_valid_r[1] <= bank_valid_r[0];
              end
              3'b100:begin //(b0->b1, b1->b2)
                bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH]
                  <= bank_cmp_addr_r[CMP_WIDTH-1:0];
                bank_cmp_addr_r[(3*CMP_WIDTH)-1:2*CMP_WIDTH]
                  <= bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH];
                bank_valid_r[1] <= bank_valid_r[0];
                bank_valid_r[2] <= bank_valid_r[1];
              end
              default: begin //(b0->b1, b1->b2, b2->b3)
                bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH]
                  <= bank_cmp_addr_r[CMP_WIDTH-1:0];
                bank_cmp_addr_r[(3*CMP_WIDTH)-1:2*CMP_WIDTH]
                  <= bank_cmp_addr_r[(2*CMP_WIDTH)-1:CMP_WIDTH];
                bank_cmp_addr_r[(4*CMP_WIDTH)-1:3*CMP_WIDTH]
                  <= bank_cmp_addr_r[(3*CMP_WIDTH)-1:2*CMP_WIDTH];
                bank_valid_r[1] <= bank_valid_r[0];
                bank_valid_r[2] <= bank_valid_r[1];
                bank_valid_r[3] <= bank_valid_r[2];
              end
            endcase
          end
        end
      end
    end else begin: gen_single_bank_open // single bank option
      always @(posedge clk) begin
        no_precharge_r       <= 1'd0;
        no_precharge_r1      <= 1'd0;
        no_precharge_wait_r  <= 1'd0;
        if (rst_r1)
          sb_open_add_r <= {CMP_WIDTH{1'b0}};
        else if (state_r == CTRL_ACTIVE)
          sb_open_add_r <= af_addr_r2[CS_RANGE_END:ROW_RANGE_START];
      end
    end
  endgenerate

  //***************************************************************************
  // Timing counters
  //***************************************************************************

  //*****************************************************************
  // Write and read enable generation for PHY
  //*****************************************************************

  // write burst count. Counts from (BL/2 to 1).
  // Also logic for controller write enable.
  always @(posedge clk) begin
    if (state_r == CTRL_BURST_WRITE) begin
      wrburst_cnt_r <= BURST_LEN_DIV2;
    end else if (wrburst_cnt_r >= 3'd1)
      wrburst_cnt_r <= wrburst_cnt_r - 1;
  end // always @ (posedge clk)


  always @(posedge clk) begin
    if (rst_r1) begin
      ctrl_wren   <= 1'b0;
    end else if (state_r == CTRL_BURST_WRITE) begin
      ctrl_wren   <= 1'b1;
    end else if (wrburst_wren_ok_r)
      ctrl_wren   <= 1'b0;
  end


  always @(posedge clk) begin
    if ((state_r == CTRL_BURST_WRITE)
        && (BURST_LEN_DIV2 > 2))
      wrburst_ok_r <= 1'd0;
    else if ((wrburst_cnt_r <= 3'd3) ||
             (BURST_LEN_DIV2 <= 2))
      wrburst_ok_r <= 1'b1;
  end

  // flag to check when wrburst count has reached
  // a value of 1. This flag is used in the ctrl_wren
  // logic
  always @(posedge clk) begin
     if(wrburst_cnt_r == 3'd2)
       wrburst_wren_ok_r <=1'b1;
     else
       wrburst_wren_ok_r <= 1'b0;
  end


  // read burst count. Counts from (BL/2 to 1)
  always @(posedge clk) begin
   if (state_r == CTRL_BURST_READ) begin
      rdburst_cnt_r <= BURST_LEN_DIV2;
    end else if (rdburst_cnt_r >= 3'd1)
      rdburst_cnt_r <= rdburst_cnt_r - 1;
  end // always @ (posedge clk)


   always @(posedge clk) begin
    if (rst_r1) begin
      ctrl_rden   <= 1'b0;
    end else if (state_r == CTRL_BURST_READ) begin
      ctrl_rden   <= 1'b1;
    end else if (rdburst_rden_ok_r)
      ctrl_rden   <= 1'b0;
   end

  // the rd_burst_ok_r signal will be asserted one cycle later
  // in multi chip select cases if the back to back read is to
  // different chip selects. The cs_changed_sticky_r signal will
  // be asserted only for multi chip select cases.
  always @(posedge clk) begin
    if ((state_r == CTRL_BURST_READ)
        && (BURST_LEN_DIV2 > 2))
      rdburst_ok_r <= 1'd0;
    else if ((rdburst_cnt_r <=( 3'd3 - cs_change_sticky_r)) ||
             (BURST_LEN_DIV2 <= 2))
      rdburst_ok_r <= 1'b1;
  end

  // flag to check when rdburst count has reached
  // a value of 1. This flag is used in the ctrl_rden
  // logic
  always @(posedge clk) begin
     if (rdburst_cnt_r == 3'd2)
       rdburst_rden_ok_r <= 1'b1;
     else
       rdburst_rden_ok_r <= 1'b0;
  end


  //*****************************************************************
  // Various delay counters
  // The counters are checked for value of <= 3 to determine the
  // if the count values are reached during different commands.
  // It is checked for 3 because
  // 1. The counters are loaded during the state when the command
  //    state is reached (+1)
  // 2. After the <= 3 condition is reached the sm takes two cycles
  //    to transition to the new command state (+2)
  //*****************************************************************

  // tRP count - precharge command period
  always @(posedge clk) begin
    if (state_r == CTRL_PRECHARGE)
      rp_cnt_r <= TRP_COUNT;
    else if (rp_cnt_r != 4'd0)
      rp_cnt_r <= rp_cnt_r - 1;
  end

  always @(posedge clk) begin
    if (state_r == CTRL_PRECHARGE)
      rp_cnt_ok_r <= 1'd0;
    else if (rp_cnt_r <= 4'd3)
      rp_cnt_ok_r <= 1'd1;
  end

  // tRFC count - refresh-refresh, refresh-active
  always @(posedge clk) begin
    if (state_r == CTRL_AUTO_REFRESH)
      rfc_cnt_r <= TRFC_COUNT;
    else if (rfc_cnt_r != 8'd0)
      rfc_cnt_r <= rfc_cnt_r - 1;
  end

  always @(posedge clk) begin
    if (state_r == CTRL_AUTO_REFRESH)
      rfc_ok_r <= 1'b0;
    else if(rfc_cnt_r <= 8'd3)
      rfc_ok_r <= 1'b1;
  end

  // tRCD count - active to read/write
  always @(posedge clk) begin
    if (state_r == CTRL_ACTIVE)
      rcd_cnt_r <= TRCD_COUNT;
    else if (rcd_cnt_r != 4'd0)
      rcd_cnt_r <= rcd_cnt_r - 1;
  end

  always @(posedge clk) begin
    if ((state_r == CTRL_ACTIVE)
        && (TRCD_COUNT > 2))
      rcd_cnt_ok_r <= 1'd0;
    else if (rcd_cnt_r <= 4'd3)
      rcd_cnt_ok_r <= 1;
  end

  // tRRD count - active to active
  always @(posedge clk) begin
    if (state_r == CTRL_ACTIVE)
      trrd_cnt_r <= TRRD_COUNT;
    else if (trrd_cnt_r != 3'd0)
      trrd_cnt_r <= trrd_cnt_r - 1;
  end

  always @(posedge clk) begin
    if (state_r == CTRL_ACTIVE)
      trrd_cnt_ok_r <= 1'd0;
    else if (trrd_cnt_r <= 3'd3)
      trrd_cnt_ok_r <= 1;
  end

  // tRAS count - active to precharge
  always @(posedge clk) begin
    if (state_r == CTRL_ACTIVE)
      ras_cnt_r <= TRAS_COUNT;
    else if (ras_cnt_r != 5'd0)
      ras_cnt_r <= ras_cnt_r - 1;
  end

  // counter for write to prcharge
  // read to precharge and
  // activate to precharge
  // precharge_ok_cnt_r is added with trtp count,
  // there can be cases where the sm can go from
  // activate to read and the act->pre count time
  // would not have been satisfied. The rd->pre
   // time is very less. wr->pre time is almost the
   // same as act-> pre
  always @(posedge clk) begin
    if (rst_r1)
      precharge_ok_cnt_r <= 5'd0;	    
    else if (state_r == CTRL_BURST_READ) begin
      // assign only if the cnt is < TRTP_COUNT
      if (precharge_ok_cnt_r < TRTP_COUNT)
        precharge_ok_cnt_r <= TRTP_COUNT;
    end else if (state_r == CTRL_BURST_WRITE)
      precharge_ok_cnt_r <= TWR_COUNT;
    else if (state_r == CTRL_ACTIVE)
      if (precharge_ok_cnt_r <= TRAS_COUNT)
        precharge_ok_cnt_r <= TRAS_COUNT;
      else
        precharge_ok_cnt_r <= precharge_ok_cnt_r - 1;
    else if (precharge_ok_cnt_r != 5'd0)
      precharge_ok_cnt_r <= precharge_ok_cnt_r - 1;
  end

  always @(posedge clk) begin
    if ((state_r == CTRL_BURST_READ) ||
        (state_r == CTRL_BURST_WRITE)||
        (state_r == CTRL_ACTIVE))
      precharge_ok_r <= 1'd0;
    else if(precharge_ok_cnt_r <= 5'd3)
      precharge_ok_r <=1'd1;
  end

  // write to read counter
  // write to read includes : write latency + burst time + tWTR
  always @(posedge clk) begin
    if (rst_r1)
      wr_to_rd_cnt_r <= 5'd0;
    else if (state_r == CTRL_BURST_WRITE)
      wr_to_rd_cnt_r <= (TWTR_COUNT);
    else if (wr_to_rd_cnt_r != 5'd0)
      wr_to_rd_cnt_r <= wr_to_rd_cnt_r - 1;
  end

  always @(posedge clk) begin
    if (state_r == CTRL_BURST_WRITE)
      wr_to_rd_ok_r <= 1'd0;
    else if (wr_to_rd_cnt_r <= 5'd3)
      wr_to_rd_ok_r <= 1'd1;
  end

  // read to write counter
  always @(posedge clk) begin
    if (rst_r1)
      rd_to_wr_cnt_r <= 5'd0;
    else if (state_r == CTRL_BURST_READ)
      rd_to_wr_cnt_r <= (TRTW_COUNT);
    else if (rd_to_wr_cnt_r != 5'd0)
      rd_to_wr_cnt_r <= rd_to_wr_cnt_r - 1;
  end

  always @(posedge clk) begin
    if (state_r == CTRL_BURST_READ)
      rd_to_wr_ok_r <= 1'b0;
    else if (rd_to_wr_cnt_r <= 5'd3)
      rd_to_wr_ok_r <= 1'b1;
  end

  always @(posedge clk) begin
     if(refi_cnt_r == (TREFI_COUNT -1))
       refi_cnt_ok_r <= 1'b1;
     else
       refi_cnt_ok_r <= 1'b0;
  end

  // auto refresh interval counter in refresh_clk domain
  always @(posedge clk) begin
    if ((rst_r1) || (refi_cnt_ok_r))  begin
      refi_cnt_r <= 12'd0;
    end else begin
      refi_cnt_r <= refi_cnt_r + 1;
    end
  end // always @ (posedge clk)

  // auto refresh flag
  always @(posedge clk) begin
    if (refi_cnt_ok_r) begin
      ref_flag_r <= 1'b1;
    end else begin
      ref_flag_r <= 1'b0;
    end
  end // always @ (posedge clk)

  assign ctrl_ref_flag = ref_flag_r;

  //refresh flag detect
  //auto_ref high indicates auto_refresh requirement
  //auto_ref is held high until auto refresh command is issued.
  always @(posedge clk)begin
    if (rst_r1)
      auto_ref_r <= 1'b0;
    else if (ref_flag_r)
      auto_ref_r <= 1'b1;
    else if (state_r == CTRL_AUTO_REFRESH)
      auto_ref_r <= 1'b0;
  end


  // keep track of which chip selects got auto-refreshed (avoid auto-refreshing
  // all CS's at once to avoid current spike)
  always @(posedge clk)begin
    if (rst_r1 || (state_r1 == CTRL_PRECHARGE))
      auto_cnt_r <= 'd0;
    else if (state_r1 == CTRL_AUTO_REFRESH)
      auto_cnt_r <= auto_cnt_r + 1;
  end

  // register for timing purposes. Extra delay doesn't really matter
  always @(posedge clk)
    phy_init_done_r <= phy_init_done;

  always @(posedge clk)begin
    if (rst_r1) begin
      state_r    <= CTRL_IDLE;
      state_r1 <= CTRL_IDLE;
    end else begin
      state_r    <= next_state;
      state_r1 <= state_r;
    end
  end

  //***************************************************************************
  // main control state machine
  //***************************************************************************

  always @(*) begin
    next_state = state_r;
    (* full_case, parallel_case *) case (state_r)
      CTRL_IDLE: begin
        // perform auto refresh as soon as we are done with calibration.
        // The calibration logic does not do any refreshes.
        if (phy_init_done_r)
          next_state = CTRL_AUTO_REFRESH;
      end

      CTRL_PRECHARGE: begin
        if (auto_ref_r)
          next_state = CTRL_PRECHARGE_WAIT1;
        // when precharging an LRU bank, do not have to go to wait state
        // since we can't possibly be activating row in same bank next
        // disabled for 2t timing. There needs to be a gap between cmds
        // in 2t timing
        else if (no_precharge_wait_r && !TWO_T_TIME_EN)
          next_state = CTRL_ACTIVE;
        else
          next_state = CTRL_PRECHARGE_WAIT;
      end

      CTRL_PRECHARGE_WAIT:begin
        if (rp_cnt_ok_r)begin
          if (auto_ref_r)
            // precharge again to make sure we close all the banks
            next_state = CTRL_PRECHARGE;
          else
            next_state = CTRL_ACTIVE;
        end
      end

      CTRL_PRECHARGE_WAIT1:
        if (rp_cnt_ok_r)
          next_state = CTRL_AUTO_REFRESH;

      CTRL_AUTO_REFRESH:
        next_state = CTRL_AUTO_REFRESH_WAIT;

      CTRL_AUTO_REFRESH_WAIT:
      //staggering Auto refresh for multi
      // chip select designs. The SM waits
      // for the rfc time before issuing the
      // next auto refresh.
        if (auto_cnt_r < (CS_NUM))begin
           if (rfc_ok_r )
              next_state = CTRL_AUTO_REFRESH;
           end else if (rfc_ok_r)begin
              if(auto_ref_r)
                // MIG 2.3: For deep designs if Auto Refresh
                // flag asserted immediately after calibration is completed
                next_state = CTRL_PRECHARGE;
              else if  ( wr_flag || rd_flag)
                next_state = CTRL_ACTIVE;
            end

      CTRL_ACTIVE:
        next_state = CTRL_ACTIVE_WAIT;

      CTRL_ACTIVE_WAIT: begin
        if (rcd_cnt_ok_r) begin
          if ((conflict_detect_r && ~conflict_resolved_r) ||
              auto_ref_r) begin
            if (no_precharge_r1 && ~auto_ref_r && trrd_cnt_ok_r)
              next_state = CTRL_ACTIVE;
            else  if(precharge_ok_r)
              next_state = CTRL_PRECHARGE;
          end else if ((wr_flag_r) && (rd_to_wr_ok_r))
            next_state = CTRL_BURST_WRITE;
          else if ((rd_flag_r)&& (wr_to_rd_ok_r))
            next_state = CTRL_BURST_READ;
        end
      end

      // beginning of write burst
      CTRL_BURST_WRITE: begin
        if (BURST_LEN_DIV2 == 1) begin
          // special case if BL = 2 (i.e. burst lasts only one clk cycle)
          if (wr_flag)
            // if we have another non-conflict write command right after the
            // current write, then stay in this state
            next_state = CTRL_BURST_WRITE;
          else
            // otherwise, if we're done with this burst, and have no write
            // immediately scheduled after this one, wait until write-read
            // delay has passed
            next_state = CTRL_WRITE_WAIT;
        end else
          // otherwise BL > 2, and we  have at least one more write cycle for
          // current burst
          next_state = CTRL_WRITE_WAIT;
        // continuation of write burst (also covers waiting after write burst
        // has completed for write-read delay to pass)
      end

      CTRL_WRITE_WAIT: begin
        if ((conflict_detect) || auto_ref_r) begin
          if (no_precharge_r && ~auto_ref_r && wrburst_ok_r)
            next_state = CTRL_ACTIVE;
          else if (precharge_ok_r)
            next_state = CTRL_PRECHARGE;
        end else if (wrburst_ok_r && wr_flag)
          next_state = CTRL_BURST_WRITE;
        else if ((rd_flag) && (wr_to_rd_ok_r))
          next_state = CTRL_BURST_READ;
      end

      CTRL_BURST_READ: begin
        if (BURST_LEN_DIV2 == 1) begin
          // special case if BL = 2 (i.e. burst lasts only one clk cycle)
          if (rd_flag)
            next_state = CTRL_BURST_READ;
          else
            next_state = CTRL_READ_WAIT;
        end else
          next_state = CTRL_READ_WAIT;
      end

      CTRL_READ_WAIT: begin
        if ((conflict_detect) || auto_ref_r)begin
          if (no_precharge_r && ~auto_ref_r && rdburst_ok_r)
            next_state = CTRL_ACTIVE;
          else if (precharge_ok_r)
            next_state = CTRL_PRECHARGE;
        // for burst of 4 in multi chip select
        // if there is a change in cs wait one cycle before the
        // next read command. cs_change_r will be asserted.
        end else if (rdburst_ok_r  && rd_flag && ~cs_change_r)
          next_state = CTRL_BURST_READ;
        else if (wr_flag && (rd_to_wr_ok_r))
          next_state = CTRL_BURST_WRITE;
      end
    endcase
  end

  //***************************************************************************
  // control signals to memory
  //***************************************************************************

  always @(posedge clk) begin
     if ((state_r == CTRL_AUTO_REFRESH) ||
         (state_r == CTRL_ACTIVE) ||
         (state_r == CTRL_PRECHARGE)) begin
       ddr_ras_n_r <= 1'b0;
       two_t_enable_r[0] <= 1'b0;
     end else begin
       if (TWO_T_TIME_EN)
         ddr_ras_n_r <= two_t_enable_r[0] ;
       else
         ddr_ras_n_r <= 1'd1;
       two_t_enable_r[0] <= 1'b1;
     end
  end

  always @(posedge clk)begin
    if ((state_r == CTRL_BURST_WRITE) ||
        (state_r == CTRL_BURST_READ) ||
        (state_r == CTRL_AUTO_REFRESH)) begin
      ddr_cas_n_r <= 1'b0;
      two_t_enable_r[1] <= 1'b0;
    end else begin
      if (TWO_T_TIME_EN)
        ddr_cas_n_r <= two_t_enable_r[1];
      else
        ddr_cas_n_r <= 1'b1;
      two_t_enable_r[1] <= 1'b1;
    end
  end

  always @(posedge clk) begin
    if ((state_r == CTRL_BURST_WRITE) ||
        (state_r == CTRL_PRECHARGE)) begin
      ddr_we_n_r <= 1'b0;
      two_t_enable_r[2] <= 1'b0;
    end else begin
      if(TWO_T_TIME_EN)
        ddr_we_n_r <= two_t_enable_r[2];
      else
        ddr_we_n_r <= 1'b1;
      two_t_enable_r[2] <= 1'b1;
    end
  end

  // turn off auto-precharge when issuing commands (A10 = 0)
  // mapping the col add for linear addressing.
  generate
    if (TWO_T_TIME_EN) begin: gen_addr_col_two_t
      if (COL_WIDTH == ROW_WIDTH-1) begin: gen_ddr_addr_col_0
        assign ddr_addr_col = {af_addr_r3[COL_WIDTH-1:10], 1'b0,
                               af_addr_r3[9:0]};
      end else begin
        if (COL_WIDTH > 10) begin: gen_ddr_addr_col_1
          assign ddr_addr_col = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}},
                                 af_addr_r3[COL_WIDTH-1:10], 1'b0,
                                 af_addr_r3[9:0]};
        end else begin: gen_ddr_addr_col_2
          assign ddr_addr_col = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}}, 1'b0,
                               af_addr_r3[COL_WIDTH-1:0]};
        end
      end
    end else begin: gen_addr_col_one_t
      if (COL_WIDTH == ROW_WIDTH-1) begin: gen_ddr_addr_col_0_1
        assign ddr_addr_col = {af_addr_r2[COL_WIDTH-1:10], 1'b0,
                               af_addr_r2[9:0]};
      end else begin
        if (COL_WIDTH > 10) begin: gen_ddr_addr_col_1_1
          assign ddr_addr_col = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}},
                                 af_addr_r2[COL_WIDTH-1:10], 1'b0,
                                 af_addr_r2[9:0]};
        end else begin: gen_ddr_addr_col_2_1
          assign ddr_addr_col = {{(ROW_WIDTH-COL_WIDTH-1){1'b0}}, 1'b0,
                                 af_addr_r2[COL_WIDTH-1:0]};
        end
      end
    end
  endgenerate

  // Assign address during row activate
  generate
    if (TWO_T_TIME_EN)
      assign ddr_addr_row = af_addr_r3[ROW_RANGE_END:ROW_RANGE_START];
    else
      assign ddr_addr_row = af_addr_r2[ROW_RANGE_END:ROW_RANGE_START];
  endgenerate


  always @(posedge clk)begin
    if ((state_r == CTRL_ACTIVE) ||
        ((state_r1 == CTRL_ACTIVE) && TWO_T_TIME_EN))
      ddr_addr_r <= ddr_addr_row;
    else if ((state_r == CTRL_BURST_WRITE) ||
             (state_r == CTRL_BURST_READ)  ||
             (((state_r1 == CTRL_BURST_WRITE) ||
               (state_r1 == CTRL_BURST_READ)) &&
              TWO_T_TIME_EN))
      ddr_addr_r <= ddr_addr_col;
    else if (((state_r == CTRL_PRECHARGE)  ||
              ((state_r1 == CTRL_PRECHARGE) && TWO_T_TIME_EN))
             && auto_ref_r) begin
      // if we're precharging as a result of AUTO-REFRESH, precharge all banks
      ddr_addr_r <= {ROW_WIDTH{1'b0}};
      ddr_addr_r[10] <= 1'b1;
    end else if ((state_r == CTRL_PRECHARGE) ||
                 ((state_r1 == CTRL_PRECHARGE) && TWO_T_TIME_EN))
      // if we're precharging to close a specific bank/row, set A10=0
      ddr_addr_r <= {ROW_WIDTH{1'b0}};
    else
      ddr_addr_r <= {ROW_WIDTH{1'bx}};
  end

  always @(posedge clk)begin
    // whenever we're precharging, we're either: (1) precharging all banks (in
    // which case banks bits are don't care, (2) precharging the LRU bank,
    // b/c we've exceeded the limit of # of banks open (need to close the LRU
    // bank to make room for a new one), (3) we haven't exceed the maximum #
    // of banks open, but we trying to open a different row in a bank that's
    // already open
    if (((state_r == CTRL_PRECHARGE)  ||
         ((state_r1 == CTRL_PRECHARGE) && TWO_T_TIME_EN)) &&
        bank_conflict_r && MULTI_BANK_EN)
      // When LRU bank needs to be closed
      ddr_ba_r <= bank_cmp_addr_r[(3*CMP_WIDTH)+CMP_BANK_RANGE_END:
                                  (3*CMP_WIDTH)+CMP_BANK_RANGE_START];
    else begin
      // Either precharge due to refresh or bank hit case
      if (TWO_T_TIME_EN)
        ddr_ba_r <= af_addr_r3[BANK_RANGE_END:BANK_RANGE_START];
      else
        ddr_ba_r <= af_addr_r2[BANK_RANGE_END:BANK_RANGE_START];
    end
  end

  // chip enable generation logic
  generate
    // if only one chip select, always assert it after reset
    if (CS_BITS == 0) begin: gen_ddr_cs_0
      always @(posedge clk)
        if (rst_r1)
          ddr_cs_n_r[0] <= 1'b1;
        else
          ddr_cs_n_r[0] <= 1'b0;
    // otherwise if we have multiple chip selects
      end else begin: gen_ddr_cs_1
      if(TWO_T_TIME_EN) begin: gen_2t_cs
         always @(posedge clk)
           if (rst_r1)
             ddr_cs_n_r <= {CS_NUM{1'b1}};
           else if ((state_r1 == CTRL_AUTO_REFRESH)) begin
             // if auto-refreshing, only auto-refresh one CS at any time (avoid
             // beating on the ground plane by refreshing all CS's at same time)
             ddr_cs_n_r <= {CS_NUM{1'b1}};
             ddr_cs_n_r[auto_cnt_r] <= 1'b0;
           end else if (auto_ref_r && (state_r1 == CTRL_PRECHARGE)) begin
             ddr_cs_n_r <= {CS_NUM{1'b0}};
           end else if ((state_r1 == CTRL_PRECHARGE) && ( bank_conflict_r
                    && MULTI_BANK_EN))begin
                  // precharging the LRU bank
                  ddr_cs_n_r <= {CS_NUM{1'b1}};
                  ddr_cs_n_r[bank_cmp_addr_r[(3*CMP_WIDTH)+CMP_CS_RANGE_END:
                  (3*CMP_WIDTH)+CMP_CS_RANGE_START]] <= 1'b0;
           end else begin
          // otherwise, check the upper address bits to see which CS to assert
             ddr_cs_n_r <= {CS_NUM{1'b1}};
             ddr_cs_n_r[af_addr_r3[CS_RANGE_END:CS_RANGE_START]] <= 1'b0;
           end // else: !if(((state_r == CTRL_PRECHARGE)  ||...
        end else begin: gen_1t_cs // block: gen_2t_cs
         always @(posedge clk)
           if (rst_r1)
             ddr_cs_n_r <= {CS_NUM{1'b1}};
           else if ((state_r == CTRL_AUTO_REFRESH) ) begin
             // if auto-refreshing, only auto-refresh one CS at any time (avoid
             // beating on the ground plane by refreshing all CS's at same time)
             ddr_cs_n_r <= {CS_NUM{1'b1}};
             ddr_cs_n_r[auto_cnt_r] <= 1'b0;
           end else if (auto_ref_r && (state_r == CTRL_PRECHARGE) ) begin
             ddr_cs_n_r <= {CS_NUM{1'b0}};
           end else if ((state_r == CTRL_PRECHARGE)  &&
                 (bank_conflict_r && MULTI_BANK_EN))begin
                  // precharging the LRU bank
                  ddr_cs_n_r <= {CS_NUM{1'b1}};
                  ddr_cs_n_r[bank_cmp_addr_r[(3*CMP_WIDTH)+CMP_CS_RANGE_END:
                  (3*CMP_WIDTH)+CMP_CS_RANGE_START]] <= 1'b0;
           end else begin
          // otherwise, check the upper address bits to see which CS to assert
             ddr_cs_n_r <= {CS_NUM{1'b1}};
             ddr_cs_n_r[af_addr_r2[CS_RANGE_END:CS_RANGE_START]] <= 1'b0;
           end // else: !if(((state_r == CTRL_PRECHARGE)  ||...
        end // block: gen_1t_cs
    end
  endgenerate

  // registring the two_t timing enable signal.
  // This signal will be asserted (low) when the
  // chip select has to be asserted.
  always @(posedge clk)begin
     if(&two_t_enable_r)
        two_t_enable_r1 <= {CS_NUM{1'b1}};
     else
        two_t_enable_r1 <= {CS_NUM{1'b0}};
  end

  assign ctrl_addr  = ddr_addr_r;
  assign ctrl_ba    = ddr_ba_r;
  assign ctrl_ras_n = ddr_ras_n_r;
  assign ctrl_cas_n = ddr_cas_n_r;
  assign ctrl_we_n  = ddr_we_n_r;
  assign ctrl_cs_n  = (TWO_T_TIME_EN) ?
                      (ddr_cs_n_r | two_t_enable_r1) :
                      ddr_cs_n_r;

endmodule


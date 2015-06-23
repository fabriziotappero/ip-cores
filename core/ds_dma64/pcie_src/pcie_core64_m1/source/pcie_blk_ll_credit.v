
//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : V5-Block Plus for PCI Express
// File       : pcie_blk_ll_credit.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: Rx Credit Calculation. This module will compute the credit
//--  availability of the various queue types.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`ifndef Tcq
  `define Tcq 1 
`endif

module pcie_blk_ll_credit
//{{{ Module Port/Parameters
#(
       parameter C_STREAMING          = 0,
       parameter C_CALENDAR_STREAMING = 4, 
       parameter C_CALENDAR_LEN       = 9,
       parameter C_CALENDAR_SUB_LEN   = 12,
       //RxStream=68, TxCpl=08, SUB_SEQ=FF
       parameter C_CALENDAR_SEQ       = 72'h68_08_68_2C_68_08_68_0C_FF, //S Tc S T1 S Tc S T2 F
       //CPLLim: tPHl=20,tNPHl=24,tCHl=28,tPDl=2C,tNPDl=30,tCDl=34
       //RFC:    rPHa=40,rPHr=60,rNPHa=44,rNPHr=64,rPDa=4C,rPDr=6C
       parameter C_CALENDAR_SUB_SEQ   = 96'h40_60_44_64_4C_6C_20_24_28_2C_30_34,
       parameter MPS                  = 3'b101,
       parameter LEGACY_EP            = 0,
       //These parameters are only used for SV assertions, and are set via
       //defparams via "board.v".
       parameter BFM_INIT_FC_PH       = 0,
       parameter BFM_INIT_FC_PD       = 0,
       parameter BFM_INIT_FC_NPH      = 0,
       parameter BFM_INIT_FC_NPD      = 0,
       parameter BFM_INIT_FC_CPLH     = 0,
       parameter BFM_INIT_FC_CPLD     = 0
)
(
       // PCIe Block clock and reset
       input  wire         clk,
       input  wire         rst_n,
       // PCIe Block Management Interface
       output reg   [6:0]  mgmt_stats_credit_sel,
       input  wire [11:0]  mgmt_stats_credit,
       // PCIe Soft Macro Trn Interface
       output reg   [7:0]  trn_pfc_ph_cl   = 0,
       output reg   [7:0]  trn_pfc_nph_cl  = 0,
       output reg   [7:0]  trn_pfc_cplh_cl = 0,
       output reg          trn_pfc_cplh_cl_upd = 0,
       output reg  [11:0]  trn_pfc_pd_cl   = 0,
       output reg  [11:0]  trn_pfc_npd_cl  = 0,
       output reg  [11:0]  trn_pfc_cpld_cl = 0,
       input               trn_lnk_up_n,
       output reg   [7:0]  trn_rfc_ph_av          = 0,
       output reg  [11:0]  trn_rfc_pd_av          = 0,
       output reg   [7:0]  trn_rfc_nph_av         = 0,
       output wire [11:0]  trn_rfc_npd_av,
       output wire  [7:0]  trn_rfc_cplh_av,
       output wire [11:0]  trn_rfc_cpld_av,
       // I/O to Rx Arb, for Streaming Credit Data
       input  wire         trn_rcpl_streaming_n,
       output reg   [7:0]  rx_ch_credits_received     = 0,
       output reg          rx_ch_credits_received_inc = 0,
       // I/O for Tx Cpl Data
       output reg   [7:0]  tx_ch_credits_consumed     = 0,
       // I/O for Tx PD 
       output reg  [11:0]  tx_pd_credits_available    = 0,
       output reg  [11:0]  tx_pd_credits_consumed     = 0,
       output reg  [11:0]  tx_npd_credits_available   = 0,
       output reg  [11:0]  tx_npd_credits_consumed    = 0,
       output reg  [11:0]  tx_cd_credits_available    = 0,
       output wire [11:0]  tx_cd_credits_consumed,
       input  wire         clear_cpl_count,
       output reg          pd_credit_limited          = 1, 
       output reg          npd_credit_limited         = 1, 
       output reg          cd_credit_limited          = 1,
       input  wire         l0_stats_cfg_transmitted
); 
//}}}
//{{{ Functions, Regs, Wires, Parameters

reg  [11:0] reg_ph_alloc  = 0;
reg  [11:0] reg_nph_alloc = 0;
reg  [11:0] reg_pd_alloc  = 0;
reg  [11:0] reg_recvd     = 0;
reg   [6:0] mgmt_stats_credit_sel_d = 0;
wire        service_stream;
reg         service_rxrcd_ch        = 0;
wire        service_txcpl;
reg         service_txcon_pd        = 0;
reg         service_txcon_npd       = 0;
reg         service_txcon_cd        = 0;
reg         service_txcon_ch        = 0;
reg         service_txcon_pd_d      = 0;
reg         service_txcon_npd_d     = 0;
reg         service_txcon_cd_d      = 0;
reg         service_txlim_ph        = 0;
reg         service_txlim_nph       = 0;
reg         service_txlim_ch        = 0;
reg         service_txlim_pd        = 0;
reg         service_txlim_npd       = 0;
reg         service_txlim_cd        = 0;
reg         service_txlim_ph_d      = 0;
reg         service_txlim_nph_d     = 0;
reg         service_txlim_ch_d      = 0;
reg         service_txlim_pd_d      = 0;
reg         service_txlim_npd_d     = 0;
reg         service_txlim_cd_d      = 0;
reg         service_rxall_ph        = 0;
reg         service_rxrcd_ph        = 0;
reg         service_rxall_nph       = 0;
reg         service_rxrcd_nph       = 0;
reg         service_rxall_pd        = 0;
reg         service_rxrcd_pd        = 0;
reg         service_rxall_ph_d      = 0;
reg         service_rxall_nph_d     = 0;
reg         service_rxall_pd_d      = 0;
reg         service_rxrcd_ph_d      = 0;
reg         service_rxrcd_nph_d     = 0;
reg         service_rxrcd_pd_d      = 0;
reg         service_rxrcd_ph_d2     = 0;
reg         service_rxrcd_nph_d2    = 0;
reg         service_rxrcd_pd_d2     = 0;
reg         trn_pfc_ph_cl_upd       = 0;
reg         trn_pfc_nph_cl_upd      = 0;
reg         trn_pfc_pd_cl_upd       = 0;
reg         trn_pfc_npd_cl_upd      = 0;
reg         trn_pfc_cpld_cl_upd     = 0;
reg         pd_credit_limited_upd   = 0;
reg         npd_credit_limited_upd  = 0;
reg         cd_credit_limited_upd   = 0;
reg  [11:0] tx_cd_credits_consumed_int   = 0;
reg  [11:0] tx_cd_credits_consumed_all   = 0;
reg  [11:0] tx_cd_credits_consumed_trn   = 0;
reg  [11:0] tx_cd_credits_consumed_diff  = 0;
reg  [11:0] l0_stats_cfg_transmitted_cnt = 0;
reg  [11:0] mgmt_stats_credit_d          = 0;


wire  [7:0] cal_seq_out;
wire  [1:0] cal_tag_out;
wire  [6:0] cal_sub_seq_out;
wire  [6:0] cal_seq_init_out;

wire  [7:0] old_cal_seq_out;
wire  [1:0] old_cal_tag_out;
wire  [6:0] old_cal_sub_seq_out;

reg   [3:0] cal_addr   = (C_CALENDAR_LEN     - 1)%16;
wire        cal_enable;
reg   [4:0] initial_header_read_cntr = 0;
reg         initial_header_read = 1;
integer     i,j;

assign trn_rfc_npd_av  = 0;
assign trn_rfc_cplh_av = 0;
assign trn_rfc_cpld_av = 0;

// ==============================
// VC
localparam VC0            = 2'b00;
// ==============================
// Channel
localparam CREDIT_SEL_PH  = 3'b000;
localparam CREDIT_SEL_NPH = 3'b001;
localparam CREDIT_SEL_CH  = 3'b010;
localparam CREDIT_SEL_PD  = 3'b011;
localparam CREDIT_SEL_NPD = 3'b100;
localparam CREDIT_SEL_CD  = 3'b101;
`define CREDIT_SEL_PH   3'h0
`define CREDIT_SEL_NPH  3'h1
`define CREDIT_SEL_CH   3'h2
`define CREDIT_SEL_PD   3'h3
`define CREDIT_SEL_NPD  3'h4
`define CREDIT_SEL_CD   3'h5
// ==============================
// Credit Type Information
localparam CREDIT_TX_CONS  = 2'b00;
localparam CREDIT_TX_LIM   = 2'b01;
localparam CREDIT_RX_ALLO  = 2'b10;
localparam CREDIT_RX_RCVD  = 2'b11;
`define CREDIT_TX_CONS   3'h0
`define CREDIT_TX_LIM    3'h1
`define CREDIT_RX_ALLO   3'h2
`define CREDIT_RX_RCVD   3'h3
// ==============================


function integer numsrl (input integer length);
  begin
    if (length%16 == 0) numsrl = length/16;
    else                numsrl = (length[31:4]+1);
  end
endfunction

function integer parsecal (input integer index, input reg [127:0] CAL_SEQ,
                           input integer CAL_LEN, input integer numsrl);
  integer g;
  begin
    for (g=0; g<numsrl*16; g=g+1)
      if (g>=CAL_LEN)
        parsecal[g] = 0;
      else
        parsecal[g] = CAL_SEQ[index + g*8];
  end
endfunction

function integer tagcal (input integer index, input reg [127:0] CAL_SEQ,
                         input integer CAL_LEN, input integer numsrl);
  integer g;
  reg [5:0] S;
  begin
     for (g=0; g<numsrl*16; g=g+1) begin
      S[5] = CAL_SEQ[g*8+7];
      S[4] = CAL_SEQ[g*8+6];
      S[3] = CAL_SEQ[g*8+5];
      S[2] = CAL_SEQ[g*8+4];
      S[1] = CAL_SEQ[g*8+3];
      S[0] = CAL_SEQ[g*8+2];
      if (g>=CAL_LEN)
        tagcal[g] = 0;
      else if ((S[5:0] == { `CREDIT_TX_CONS , `CREDIT_SEL_PD }) ||
               (S[5:0] == { `CREDIT_TX_LIM ,  `CREDIT_SEL_PD }))
        tagcal[g] = 1;      //PD  = 11
      else if ((S[5:0] == { `CREDIT_TX_CONS , `CREDIT_SEL_NPD }) ||
               (S[5:0] == { `CREDIT_TX_LIM ,  `CREDIT_SEL_NPD }))
        tagcal[g] = index;  //NPD = 10
      else if ((S[5:0] == { `CREDIT_TX_CONS , `CREDIT_SEL_CD }) ||
               (S[5:0] == { `CREDIT_TX_LIM ,  `CREDIT_SEL_CD }))
        tagcal[g] = !index; //CD  = 01 
      else
        tagcal[g] = 0;      //everything else = 00 
     end
  end
endfunction

//}}}

//{{{ Instantiate SRLs for Calendar
parameter number_srls     = numsrl(C_CALENDAR_LEN);
parameter number_srls_sub = numsrl(C_CALENDAR_SUB_LEN);
parameter [number_srls*16-1:0]     CALTAGINIT1 = tagcal(1, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls*16-1:0]     CALTAGINIT0 = tagcal(0, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls*16-1:0]     CALINIT7    = parsecal(7, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls*16-1:0]     CALINIT6    = parsecal(6, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls*16-1:0]     CALINIT5    = parsecal(5, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls*16-1:0]     CALINIT4    = parsecal(4, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls*16-1:0]     CALINIT3    = parsecal(3, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls*16-1:0]     CALINIT2    = parsecal(2, C_CALENDAR_SEQ,C_CALENDAR_LEN,number_srls);
parameter [number_srls_sub*16-1:0] CALSUBINIT6 = parsecal(6, C_CALENDAR_SUB_SEQ,C_CALENDAR_SUB_LEN,number_srls_sub);
parameter [number_srls_sub*16-1:0] CALSUBINIT5 = parsecal(5, C_CALENDAR_SUB_SEQ,C_CALENDAR_SUB_LEN,number_srls_sub);
parameter [number_srls_sub*16-1:0] CALSUBINIT4 = parsecal(4, C_CALENDAR_SUB_SEQ,C_CALENDAR_SUB_LEN,number_srls_sub);
parameter [number_srls_sub*16-1:0] CALSUBINIT3 = parsecal(3, C_CALENDAR_SUB_SEQ,C_CALENDAR_SUB_LEN,number_srls_sub);
parameter [number_srls_sub*16-1:0] CALSUBINIT2 = parsecal(2, C_CALENDAR_SUB_SEQ,C_CALENDAR_SUB_LEN,number_srls_sub);

parameter CAL_SUB_ADDR = (C_CALENDAR_SUB_LEN - 1)%16;

always @(posedge clk) begin
   if (~rst_n) begin
     cal_addr                 <= #`Tcq (C_CALENDAR_LEN - 1)%16;
   end else if (!cal_enable) begin
     cal_addr                 <= #`Tcq cal_addr - 1;
   end
end

always @(posedge clk) begin
   if (~rst_n) begin
     initial_header_read      <= #`Tcq 1;
     initial_header_read_cntr <= #`Tcq 'h0;
   end else begin
     if (initial_header_read_cntr < 'd16) begin
       initial_header_read_cntr <= #`Tcq initial_header_read_cntr + 1;
       initial_header_read      <= #`Tcq 1;
     end else begin
       initial_header_read      <= #`Tcq 0;
     end
   end
end

assign cal_enable = !((!pd_credit_limited  && (cal_tag_out[1:0]==2'b11)) ||
                      (!npd_credit_limited && (cal_tag_out[1:0]==2'b10) && LEGACY_EP) ||
                      (!cd_credit_limited  && (cal_tag_out[1:0]==2'b01)));

assign cal_seq_out[1:0]     = 2'b00;
assign cal_sub_seq_out[1:0] = 2'b00;


assign old_cal_seq_out[1:0]     = 2'b00;
assign old_cal_sub_seq_out[1:0] = 2'b00;


// old SRL, left for comparison
//synthesis translate_off
genvar j_srl;
generate for (j_srl=0; j_srl<number_srls; j_srl=j_srl+1) begin: old_srl_gen
    SRL16E #(.INIT(CALTAGINIT1[15:0])) srl_cal_tag1
     (.D(old_cal_tag_out[1]),.Q(old_cal_tag_out[1]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
    SRL16E #(.INIT(CALTAGINIT0[15:0])) srl_cal_tag0
     (.D(old_cal_tag_out[0]),.Q(old_cal_tag_out[0]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
    SRL16E #(.INIT(CALINIT7[15:0])) srl_cal7 
     (.D(old_cal_seq_out[7]),.Q(old_cal_seq_out[7]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
    SRL16E #(.INIT(CALINIT6[15:0])) srl_cal6
     (.D(old_cal_seq_out[6]),.Q(old_cal_seq_out[6]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
    SRL16E #(.INIT(CALINIT5[15:0])) srl_cal5
     (.D(old_cal_seq_out[5]),.Q(old_cal_seq_out[5]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
    SRL16E #(.INIT(CALINIT4[15:0])) srl_cal4
     (.D(old_cal_seq_out[4]),.Q(old_cal_seq_out[4]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
    SRL16E #(.INIT(CALINIT3[15:0])) srl_cal3
     (.D(old_cal_seq_out[3]),.Q(old_cal_seq_out[3]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
    SRL16E #(.INIT(CALINIT2[15:0])) srl_cal2
     (.D(old_cal_seq_out[2]),.Q(old_cal_seq_out[2]),.CLK(clk),.CE(cal_enable),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]));
end
endgenerate
//synthesis translate_on


genvar i_srl;
generate for (i_srl=0; i_srl<number_srls; i_srl=i_srl+1) begin: srl_gen
    my_SRL16E #(.INIT(CALTAGINIT1[15:0])) srl_cal_tag1
     (.D(cal_tag_out[1]),.Q(cal_tag_out[1]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]),
      .RST_N(rst_n));
    my_SRL16E #(.INIT(CALTAGINIT0[15:0])) srl_cal_tag0
     (.D(cal_tag_out[0]),.Q(cal_tag_out[0]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]), 
      .RST_N(rst_n));
    my_SRL16E #(.INIT(CALINIT7[15:0])) srl_cal7 
     (.D(cal_seq_out[7]),.Q(cal_seq_out[7]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]), 
      .RST_N(rst_n));
    my_SRL16E #(.INIT(CALINIT6[15:0])) srl_cal6
     (.D(cal_seq_out[6]),.Q(cal_seq_out[6]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]), 
      .RST_N(rst_n));
    my_SRL16E #(.INIT(CALINIT5[15:0])) srl_cal5
     (.D(cal_seq_out[5]),.Q(cal_seq_out[5]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]), 
      .RST_N(rst_n));
    my_SRL16E #(.INIT(CALINIT4[15:0])) srl_cal4
     (.D(cal_seq_out[4]),.Q(cal_seq_out[4]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]), 
      .RST_N(rst_n));
    my_SRL16E #(.INIT(CALINIT3[15:0])) srl_cal3
     (.D(cal_seq_out[3]),.Q(cal_seq_out[3]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]), 
      .RST_N(rst_n));
    my_SRL16E #(.INIT(CALINIT2[15:0])) srl_cal2
     (.D(cal_seq_out[2]),.Q(cal_seq_out[2]),.CLK(clk),.CE(cal_enable & rst_n),
      .A3(cal_addr[3]),.A2(cal_addr[2]),.A1(cal_addr[1]),.A0(cal_addr[0]), 
      .RST_N(rst_n));
end
endgenerate


/*
0000_0000_0000_0000  6

1111_1101_1111_1011  5
0000_1110_0001_1100  4

0011_0000_0110_0000  3
0101_0110_1010_1101  2
OOOO_OOOO_OOOO_OOOO  1 
OOOO_OOOO_OOOO_OOOO  0

2222 3312 2223 3122
048c 0440 48c0 4404 
      
1234 5671 2345 6712

20 PHli
24 NPHli
28 CHli
2c PDli
30 PHli
34 CDli
14 ConCD

*/

    assign cal_seq_init_out[6] = 0;
//    assign cal_seq_init_out[5] = 1;

    my_SRL16E #(.INIT(16'b1111_1101_1111_1011)) srl_init_cal5
     (.D(cal_seq_init_out[5]),.Q(cal_seq_init_out[5]),.CLK(clk),.CE(1'b1),
      .A3(1'b1),.A2(1'b1),.A1(1'b1),.A0(1'b1), .RST_N(rst_n));

    my_SRL16E #(.INIT(16'b0000_1110_0001_1100)) srl_init_cal4
     (.D(cal_seq_init_out[4]),.Q(cal_seq_init_out[4]),.CLK(clk),.CE(1'b1),
      .A3(1'b1),.A2(1'b1),.A1(1'b1),.A0(1'b1), .RST_N(rst_n));

    my_SRL16E #(.INIT(16'b0011_0000_0110_0000)) srl_init_cal3
     (.D(cal_seq_init_out[3]),.Q(cal_seq_init_out[3]),.CLK(clk),.CE(1'b1),
      .A3(1'b1),.A2(1'b1),.A1(1'b1),.A0(1'b1), .RST_N(rst_n));

    my_SRL16E #(.INIT(16'b0101_0110_1010_1101)) srl_init_cal2
     (.D(cal_seq_init_out[2]),.Q(cal_seq_init_out[2]),.CLK(clk),.CE(1'b1),
      .A3(1'b1),.A2(1'b1),.A1(1'b1),.A0(1'b1), .RST_N(rst_n));

    assign cal_seq_init_out[1] = 0;
    assign cal_seq_init_out[0] = 0;



// old SRL, left for comparison
//synthesis translate_off
genvar j_ssrl;
generate for (j_ssrl=0; j_ssrl<number_srls_sub; j_ssrl=j_ssrl+1) begin: old_sub_srl_gen

    SRL16E #(.INIT(CALSUBINIT6[15:0])) srl_sub_cal6
     (.D(old_cal_sub_seq_out[6]),.Q(old_cal_sub_seq_out[6]),.CLK(clk),.CE(cal_seq_out[7]),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]));
    SRL16E #(.INIT(CALSUBINIT5[15:0])) srl_sub_cal5
     (.D(old_cal_sub_seq_out[5]),.Q(old_cal_sub_seq_out[5]),.CLK(clk),.CE(cal_seq_out[7]),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]));
    SRL16E #(.INIT(CALSUBINIT4[15:0])) srl_sub_cal4
     (.D(old_cal_sub_seq_out[4]),.Q(old_cal_sub_seq_out[4]),.CLK(clk),.CE(cal_seq_out[7]),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]));
    SRL16E #(.INIT(CALSUBINIT3[15:0])) srl_sub_cal3
     (.D(old_cal_sub_seq_out[3]),.Q(old_cal_sub_seq_out[3]),.CLK(clk),.CE(cal_seq_out[7]),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]));
    SRL16E #(.INIT(CALSUBINIT2[15:0])) srl_sub_cal2
     (.D(old_cal_sub_seq_out[2]),.Q(old_cal_sub_seq_out[2]),.CLK(clk),.CE(cal_seq_out[7]),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]));
end
endgenerate
//synthesis translate_on



genvar i_ssrl;
generate for (i_ssrl=0; i_ssrl<number_srls_sub; i_ssrl=i_ssrl+1) begin: sub_srl_gen
    my_SRL16E #(.INIT(CALSUBINIT6[15:0])) srl_sub_cal6
     (.D(cal_sub_seq_out[6]),.Q(cal_sub_seq_out[6]),.CLK(clk),.CE(cal_seq_out[7] & rst_n),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]), .RST_N(rst_n));
    my_SRL16E #(.INIT(CALSUBINIT5[15:0])) srl_sub_cal5
     (.D(cal_sub_seq_out[5]),.Q(cal_sub_seq_out[5]),.CLK(clk),.CE(cal_seq_out[7] & rst_n),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]), .RST_N(rst_n));
    my_SRL16E #(.INIT(CALSUBINIT4[15:0])) srl_sub_cal4
     (.D(cal_sub_seq_out[4]),.Q(cal_sub_seq_out[4]),.CLK(clk),.CE(cal_seq_out[7] & rst_n),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]), .RST_N(rst_n));
    my_SRL16E #(.INIT(CALSUBINIT3[15:0])) srl_sub_cal3
     (.D(cal_sub_seq_out[3]),.Q(cal_sub_seq_out[3]),.CLK(clk),.CE(cal_seq_out[7] & rst_n),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]), .RST_N(rst_n));
    my_SRL16E #(.INIT(CALSUBINIT2[15:0])) srl_sub_cal2
     (.D(cal_sub_seq_out[2]),.Q(cal_sub_seq_out[2]),.CLK(clk),.CE(cal_seq_out[7] & rst_n),
      .A3(CAL_SUB_ADDR[3]),.A2(CAL_SUB_ADDR[2]),.A1(CAL_SUB_ADDR[1]),.A0(CAL_SUB_ADDR[0]), .RST_N(rst_n));
end
endgenerate



//}}}
//{{{ Parse Calendar & Trigger for Service of Streaming or Tx Cpl Credit Data
always @(posedge clk) begin
   if (~rst_n || trn_lnk_up_n) begin
     mgmt_stats_credit_sel   <= #`Tcq 'h0;
     mgmt_stats_credit_sel_d <= #`Tcq 'h0;
     service_rxall_ph  <= #`Tcq 1'b0;
     service_rxall_nph <= #`Tcq 1'b0;
     service_rxall_pd  <= #`Tcq 1'b0;
     service_rxrcd_ph  <= #`Tcq 1'b0;
     service_rxrcd_nph <= #`Tcq 1'b0;
     service_rxrcd_ch  <= #`Tcq 1'b0;
     service_rxrcd_pd  <= #`Tcq 1'b0;
     service_txcon_ch  <= #`Tcq 1'b0;
     service_txcon_pd  <= #`Tcq 1'b0;
     service_txcon_npd <= #`Tcq 1'b0;
     service_txcon_cd  <= #`Tcq 1'b0;
     service_txlim_ph  <= #`Tcq 1'b0;
     service_txlim_nph <= #`Tcq 1'b0;
     service_txlim_ch  <= #`Tcq 1'b0;
     service_txlim_pd  <= #`Tcq 1'b0;
     service_txlim_npd <= #`Tcq 1'b0;
     service_txlim_cd  <= #`Tcq 1'b0;
   end else begin
//     mgmt_stats_credit_sel   <= #`Tcq {(cal_seq_out[7] || initial_header_read )? cal_sub_seq_out[6:2]:cal_seq_out[6:2], VC0};

     mgmt_stats_credit_sel   <= #`Tcq {initial_header_read ? cal_seq_init_out[6:2] : cal_seq_out[7] ? cal_sub_seq_out[6:2] : cal_seq_out[6:2], VC0};

     mgmt_stats_credit_sel_d <= #`Tcq mgmt_stats_credit_sel;
     service_rxall_ph  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_RX_ALLO,CREDIT_SEL_PH}; //0x40
     service_rxall_nph <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_RX_ALLO,CREDIT_SEL_NPH};//0x44
     service_rxall_pd  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_RX_ALLO,CREDIT_SEL_PD}; //0x4C
     service_rxrcd_ph  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_RX_RCVD,CREDIT_SEL_PH}; //0x60
     service_rxrcd_nph <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_RX_RCVD,CREDIT_SEL_NPH};//0x64
     service_rxrcd_ch  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_RX_RCVD,CREDIT_SEL_CH}; //0x68 (streaming)
     service_rxrcd_pd  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_RX_RCVD,CREDIT_SEL_PD}; //0x6C
     service_txcon_ch  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_CONS,CREDIT_SEL_CH}; //0x08 (tx cpl fix)
     service_txcon_pd  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_CONS,CREDIT_SEL_PD}; //0x0C (tx  PDcredit fix2)
     service_txcon_npd <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_CONS,CREDIT_SEL_NPD};//0x10 (tx NPDcredit fix2)
     service_txcon_cd  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_CONS,CREDIT_SEL_CD}; //0x14 (tx  CDcredit fix2)
     service_txlim_ph  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_LIM, CREDIT_SEL_PH}; //0x20
     service_txlim_nph <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_LIM, CREDIT_SEL_NPH};//0x24
     service_txlim_ch  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_LIM, CREDIT_SEL_CH}; //0x28
     service_txlim_pd  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_LIM, CREDIT_SEL_PD}; //0x2C (tx  PDcredit fix1)
     service_txlim_npd <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_LIM, CREDIT_SEL_NPD};//0x30 (tx NPDcredit fix1)
     service_txlim_cd  <= #`Tcq mgmt_stats_credit_sel_d[6:2] == {CREDIT_TX_LIM, CREDIT_SEL_CD}; //0x34 (tx  CDcredit fix1)
   end
end

assign service_stream = service_rxrcd_ch;
assign service_txcpl  = service_txcon_ch;
//}}}
//{{{ Capture Credit Data for Streaming Mode
always @(posedge clk) begin
   if (~rst_n) begin
      rx_ch_credits_received     <= #`Tcq 0;
      rx_ch_credits_received_inc <= #`Tcq 0;
   // requested CplH-rcvd when service_stream=1
   // wait 2 cycles for data
   end else if (service_stream) begin
      rx_ch_credits_received     <= #`Tcq mgmt_stats_credit[7:0];
      rx_ch_credits_received_inc <= #`Tcq (mgmt_stats_credit[7:0] != rx_ch_credits_received);
   end else begin
      rx_ch_credits_received_inc <= #`Tcq 0;
   end
end
//}}}
//{{{ Capture Credit Data for Tx Cpl Issue
always @(posedge clk) begin
   if (~rst_n) begin
      tx_ch_credits_consumed <= #`Tcq 0;
   end else if (service_txcpl) begin
      tx_ch_credits_consumed <= #`Tcq mgmt_stats_credit[7:0];
   end
end
//}}}
//{{{ Capture Credit Data for Tx Blocking Data Credit Issue
always @(posedge clk) begin
   if (~rst_n) begin
      service_txcon_pd_d           <= #`Tcq 0;
      service_txcon_npd_d          <= #`Tcq 0;
      service_txcon_cd_d           <= #`Tcq 0;
      tx_pd_credits_consumed       <= #`Tcq 0;
      tx_pd_credits_available      <= #`Tcq 0;
      tx_npd_credits_consumed      <= #`Tcq 0;
      tx_npd_credits_available     <= #`Tcq 0;
      tx_cd_credits_consumed_all   <= #`Tcq 0;
      tx_cd_credits_consumed_trn   <= #`Tcq 0;
      tx_cd_credits_consumed_int   <= #`Tcq 0;
      tx_cd_credits_consumed_diff  <= #`Tcq 'h0;
      tx_cd_credits_available      <= #`Tcq 0;
      l0_stats_cfg_transmitted_cnt <= #`Tcq 'h0;
   end else begin
      service_txcon_pd_d           <= #`Tcq service_txcon_pd;
      service_txcon_npd_d          <= #`Tcq service_txcon_npd;
      service_txcon_cd_d           <= #`Tcq service_txcon_cd;
      if (service_txcon_pd_d) begin
        tx_pd_credits_consumed   <= #`Tcq mgmt_stats_credit_d[11:0];
        tx_pd_credits_available  <= #`Tcq trn_pfc_pd_cl - mgmt_stats_credit_d[11:0];
      end
      if (LEGACY_EP && service_txcon_npd_d) begin
        tx_npd_credits_consumed  <= #`Tcq mgmt_stats_credit_d[11:0];
        tx_npd_credits_available <= #`Tcq trn_pfc_npd_cl - mgmt_stats_credit_d[11:0];
      end
      if (service_txcon_cd_d) begin
        tx_cd_credits_consumed_int <= #`Tcq mgmt_stats_credit_d[11:0];
        tx_cd_credits_consumed_diff<= #`Tcq mgmt_stats_credit_d[11:0] - tx_cd_credits_consumed_int;
        tx_cd_credits_available    <= #`Tcq trn_pfc_cpld_cl - mgmt_stats_credit_d[11:0];
      end else begin
        tx_cd_credits_consumed_diff<= #`Tcq 'h0;
      end
      tx_cd_credits_consumed_all   <= #`Tcq tx_cd_credits_consumed_all + tx_cd_credits_consumed_diff;
      tx_cd_credits_consumed_trn   <= #`Tcq tx_cd_credits_consumed_all - l0_stats_cfg_transmitted_cnt;
      if (clear_cpl_count) 
        l0_stats_cfg_transmitted_cnt <= #`Tcq 0;
      else
        l0_stats_cfg_transmitted_cnt <= #`Tcq l0_stats_cfg_transmitted_cnt + l0_stats_cfg_transmitted;
   end
end

assign  tx_cd_credits_consumed     = tx_cd_credits_consumed_all;

//}}}
//{{{ Capture Credit Data for RFC
always @(posedge clk) begin
   if (~rst_n) begin
      service_rxall_ph_d  <= #`Tcq 0;
      service_rxall_nph_d <= #`Tcq 0;
      service_rxall_pd_d  <= #`Tcq 0;
      service_rxrcd_ph_d  <= #`Tcq 0;
      service_rxrcd_nph_d <= #`Tcq 0;
      service_rxrcd_pd_d  <= #`Tcq 0;
      service_rxrcd_ph_d2 <= #`Tcq 0;
      service_rxrcd_nph_d2<= #`Tcq 0;
      service_rxrcd_pd_d2 <= #`Tcq 0;
      reg_ph_alloc        <= #`Tcq 0;
      reg_nph_alloc       <= #`Tcq 0;
      reg_pd_alloc        <= #`Tcq 0;
      reg_recvd           <= #`Tcq 0;
      trn_rfc_ph_av       <= #`Tcq 0;
      trn_rfc_nph_av      <= #`Tcq 0;
      trn_rfc_pd_av       <= #`Tcq 0;
   end else begin
      service_rxall_ph_d  <= #`Tcq service_rxall_ph;
      service_rxall_nph_d <= #`Tcq service_rxall_nph;
      service_rxall_pd_d  <= #`Tcq service_rxall_pd;
      service_rxrcd_ph_d  <= #`Tcq service_rxrcd_ph;
      service_rxrcd_nph_d <= #`Tcq service_rxrcd_nph;
      service_rxrcd_pd_d  <= #`Tcq service_rxrcd_pd;
      service_rxrcd_ph_d2 <= #`Tcq service_rxrcd_ph_d;
      service_rxrcd_nph_d2<= #`Tcq service_rxrcd_nph_d;
      service_rxrcd_pd_d2 <= #`Tcq service_rxrcd_pd_d;
      if (service_rxall_ph_d) 
        reg_ph_alloc        <= #`Tcq mgmt_stats_credit_d;
      if (service_rxall_nph_d) 
        reg_nph_alloc       <= #`Tcq mgmt_stats_credit_d;
      if (service_rxall_pd_d) 
        reg_pd_alloc        <= #`Tcq mgmt_stats_credit_d;
      if (service_rxrcd_ph_d || service_rxrcd_nph_d || service_rxrcd_pd_d)
        reg_recvd           <= #`Tcq mgmt_stats_credit_d;
      if (service_rxrcd_ph_d2)
        trn_rfc_ph_av     <= #`Tcq reg_ph_alloc  - reg_recvd;
      if (service_rxrcd_nph_d2)
        trn_rfc_nph_av    <= #`Tcq reg_nph_alloc - reg_recvd;
      if (service_rxrcd_pd_d2)
        trn_rfc_pd_av     <= #`Tcq reg_pd_alloc  - reg_recvd;
   end
end

//}}}

always @(posedge clk) begin
   if (~rst_n) begin
     mgmt_stats_credit_d    <= #`Tcq 'h0;
     service_txlim_ph_d     <= #`Tcq 1'b0;
     service_txlim_nph_d    <= #`Tcq 1'b0;
     service_txlim_ch_d     <= #`Tcq 1'b0;
     service_txlim_pd_d     <= #`Tcq 1'b0;
     service_txlim_npd_d    <= #`Tcq 1'b0;
     service_txlim_cd_d     <= #`Tcq 1'b0;
     trn_pfc_ph_cl          <= #`Tcq 'h0;
     trn_pfc_nph_cl         <= #`Tcq 'h0;
     trn_pfc_cplh_cl        <= #`Tcq 'h0;
     trn_pfc_pd_cl          <= #`Tcq 'h0;
     trn_pfc_npd_cl         <= #`Tcq 'h0;
     trn_pfc_cpld_cl        <= #`Tcq 'h0;
     trn_pfc_ph_cl_upd      <= #`Tcq 1'b0;
     trn_pfc_nph_cl_upd     <= #`Tcq 1'b0;
     trn_pfc_cplh_cl_upd    <= #`Tcq 1'b0;
     trn_pfc_pd_cl_upd      <= #`Tcq 1'b0;
     trn_pfc_npd_cl_upd     <= #`Tcq 1'b0;
     trn_pfc_cpld_cl_upd    <= #`Tcq 1'b0;
   end else begin
     mgmt_stats_credit_d    <= #`Tcq mgmt_stats_credit;
     service_txlim_ph_d     <= #`Tcq service_txlim_ph;
     service_txlim_nph_d    <= #`Tcq service_txlim_nph;
     service_txlim_ch_d     <= #`Tcq service_txlim_ch;
     service_txlim_pd_d     <= #`Tcq service_txlim_pd;
     service_txlim_npd_d    <= #`Tcq service_txlim_npd;
     service_txlim_cd_d     <= #`Tcq service_txlim_cd;
     if (service_txlim_ph_d) begin
       trn_pfc_ph_cl          <= #`Tcq mgmt_stats_credit_d[7:0];
       trn_pfc_ph_cl_upd      <= #`Tcq 1'b1;
     end
     if (service_txlim_nph_d) begin
       trn_pfc_nph_cl         <= #`Tcq mgmt_stats_credit_d[7:0];
       trn_pfc_nph_cl_upd     <= #`Tcq 1'b1;
     end
     if (service_txlim_ch_d) begin
       trn_pfc_cplh_cl        <= #`Tcq mgmt_stats_credit_d[7:0];
       trn_pfc_cplh_cl_upd    <= #`Tcq 1'b1;
     end
     if (service_txlim_pd_d) begin
       trn_pfc_pd_cl    <= #`Tcq (mgmt_stats_credit_d[11:0] == 0) ? 12'hfff :
                                  mgmt_stats_credit_d[11:0];
       trn_pfc_pd_cl_upd      <= #`Tcq 1'b1;
     end
     if (service_txlim_npd_d) begin
       trn_pfc_npd_cl   <= #`Tcq (mgmt_stats_credit_d[11:0] == 0) ? 12'hfff :
                                  mgmt_stats_credit_d[11:0];
       trn_pfc_npd_cl_upd     <= #`Tcq 1'b1;
     end
     if (service_txlim_cd_d) begin
       trn_pfc_cpld_cl        <= #`Tcq mgmt_stats_credit_d[11:0];
       trn_pfc_cpld_cl_upd    <= #`Tcq 1'b1;
     end
   end
end


always @(posedge clk) begin
   if (~rst_n) begin
     pd_credit_limited      <= #`Tcq 1'b1; //assume restricted until find out otherwise
     npd_credit_limited     <= #`Tcq 1'b1; //assume restricted until find out otherwise
     cd_credit_limited      <= #`Tcq 1'b1; //assume restricted until find out otherwise
     pd_credit_limited_upd  <= #`Tcq 1'b0;
     npd_credit_limited_upd <= #`Tcq 1'b0;
     cd_credit_limited_upd  <= #`Tcq 1'b0;
   end else begin
     if (!pd_credit_limited_upd  && trn_pfc_ph_cl_upd  && trn_pfc_pd_cl_upd) begin
       pd_credit_limited      <= #`Tcq trn_pfc_pd_cl < (trn_pfc_ph_cl*8*(2**MPS));
       pd_credit_limited_upd  <= #`Tcq 1'b1;
     end
     if (!npd_credit_limited_upd && trn_pfc_nph_cl_upd && trn_pfc_npd_cl_upd) begin
       npd_credit_limited     <= #`Tcq (trn_pfc_npd_cl < trn_pfc_nph_cl) && LEGACY_EP;
       npd_credit_limited_upd <= #`Tcq 1'b1;
     end
     if (!cd_credit_limited_upd && trn_pfc_cplh_cl_upd && trn_pfc_cpld_cl_upd) begin
       cd_credit_limited      <= #`Tcq trn_pfc_cpld_cl < (trn_pfc_cplh_cl*8*(2**MPS));
       cd_credit_limited_upd  <= #`Tcq 1'b1;
     end
   end
end

//{{{ Assertions
`ifdef SV
//synthesis translate_off
   ASSERT_DETECT_POSTED_LIMITED:     assert property (@(posedge clk)
       rst_n[*256] |-> (BFM_INIT_FC_PH<BFM_INIT_FC_PD*8*(MPS+1))      ? pd_credit_limited  : ~pd_credit_limited
                           ) else $fatal;
   ASSERT_DETECT_NONPOSTED_LIMITED:  assert property (@(posedge clk)
       rst_n[*256] |-> ((BFM_INIT_FC_NPH<BFM_INIT_FC_NPD)&&LEGACY_EP) ? npd_credit_limited : ~npd_credit_limited
                           ) else $fatal;
   ASSERT_DETECT_COMPLETION_LIMITED: assert property (@(posedge clk)
       rst_n[*256] |-> (BFM_INIT_FC_CPLH<BFM_INIT_FC_CPLD*8*(MPS+1))  ? cd_credit_limited  : ~cd_credit_limited
                           ) else $fatal;
   ASSERT_POSTED_LIMITED_POLL1:      assert property (@(posedge clk)
       rst_n[*256] ##1 pd_credit_limited  |-> ##[1:16] (mgmt_stats_credit_sel == 7'h2C)
                           ) else $fatal;
   ASSERT_POSTED_LIMITED_POLL2:      assert property (@(posedge clk)
       rst_n[*256] ##1 pd_credit_limited  |-> ##[1:16] (mgmt_stats_credit_sel == 7'h0C)
                           ) else $fatal;
   ASSERT_POSTED_NOT_LIMITED_POLL:   assert property (@(posedge clk)
       rst_n[*256] ##1 ((cal_seq_out[6:0]==7'h2C) || (cal_seq_out[6:0]==7'h0C))|-> pd_credit_limited
                           ) else $fatal;
   ASSERT_NONPOSTED_LIMITED_POLL1:   assert property (@(posedge clk)
       rst_n[*256] ##1 npd_credit_limited |-> ##[1:16] (mgmt_stats_credit_sel == 7'h30)
                           ) else $fatal;
   ASSERT_NONPOSTED_LIMITED_POLL2:   assert property (@(posedge clk)
       rst_n[*256] ##1 npd_credit_limited |-> ##[1:16] (mgmt_stats_credit_sel == 7'h10)
                           ) else $fatal;
   ASSERT_NONPOSTED_NOT_LIMITED_POLL:assert property (@(posedge clk)
       rst_n[*256] ##1 ((cal_seq_out[6:0]==7'h30) || (cal_seq_out[6:0]==7'h10))|-> npd_credit_limited
                           ) else $fatal;
   ASSERT_COMPLETION_LIMITED_POLL1:  assert property (@(posedge clk)
       rst_n[*256] ##1 cd_credit_limited  |-> ##[1:16] (mgmt_stats_credit_sel == 7'h34)
                           ) else $fatal;
   ASSERT_COMPLETION_LIMITED_POLL2:  assert property (@(posedge clk)
       rst_n[*256] ##1 cd_credit_limited  |-> ##[1:16] (mgmt_stats_credit_sel == 7'h14)
                           ) else $fatal;
   ASSERT_COMPLETION_NOT_LIMITED_POLL:assert property (@(posedge clk)
       rst_n[*256] ##1 ((cal_seq_out[6:0]==7'h34) || (cal_seq_out[6:0]==7'h14))|-> cd_credit_limited
                           ) else $fatal;
   ASSERT_NEVER_POLL_ZEROS:           assert property (@(posedge clk)  //assume we never poll 00
       rst_n |-> ##1 (mgmt_stats_credit_sel != 7'h00)
                           ) else $fatal;
   ASSERT_NEVER_POLL_X_S:             assert property (@(posedge clk)
       rst_n |-> ((^mgmt_stats_credit_sel) == 1'b0) || ((^mgmt_stats_credit_sel) == 1'b1)
                           ) else $fatal;
     
   ASSERT_MATCH_CAL_TAG : assert property (@(posedge clk)
      rst_n |-> ##1 (old_cal_tag_out == cal_tag_out)) else $fatal;

   ASSERT_MATCH_CAL_SEQ : assert property (@(posedge clk)
      rst_n |-> ##1 (old_cal_seq_out == cal_seq_out)) else $fatal;

   ASSERT_MATCH_CAL_SUB_SEQ : assert property (@(posedge clk)
      rst_n |-> ##1 (old_cal_sub_seq_out == cal_sub_seq_out)) else $fatal;




//synthesis translate_on
`endif
//}}}

endmodule // pcie_blk_ll_credit


module my_SRL16E #(
   parameter INIT = 16'h0000 
   )( 
     output Q,
     input A0,
     input A1,
     input A2,
     input A3,
     input CE,
     input CLK,
     input RST_N,
     input D
   );

    reg  [15:0] data = INIT;

    assign Q = data[{A3, A2, A1, A0}];

    always @(posedge CLK)
    begin
        if (RST_N == 1'b0)
            {data[15:0]} <= #1 INIT; 
        else
           if (CE == 1'b1) begin
               {data[15:0]} <= #1 {data[14:0], D};
           end

    end


endmodule



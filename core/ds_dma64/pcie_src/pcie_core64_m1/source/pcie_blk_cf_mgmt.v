
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
// File       : pcie_blk_cf_mgmt.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: Management Interface. This module will poll the
//--  configuration registers to store in shadow registers, and it will also
//--  arbitrate for access to the management interface with the user.
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`ifndef Tcq
  `define Tcq 1 
`endif

`define INSTANTIATE_LUTROM 1

module pcie_blk_cf_mgmt
(
       // PCIe Block clock and reset

       input wire         clk,
       input wire         rst_n,

       // PCIe CFG signals
       input wire  [12:0] completer_id,

       // PCIe Block Management Interface

       output reg  [10:0] mgmt_addr  = 11'h047,
       output reg         mgmt_wren  = 0,
       output reg         mgmt_rden  = 0,
       output reg  [31:0] mgmt_wdata = 0,
       output reg   [3:0] mgmt_bwren = 4'hF,
       input  wire [31:0] mgmt_rdata,
       input  wire [16:0] mgmt_pso,
 
       // PCIe Soft Macro Cfg Interface
       
       input  wire [63:0] cfg_dsn,
       output reg  [31:0] cfg_do       = 0,
       output reg         cfg_rd_wr_done_n = 1,
       input  wire [11:0] cfg_dwaddr,
       input  wire        cfg_rd_en_n,
       output reg  [31:0] cfg_rx_bar0  = 0,
       output reg  [31:0] cfg_rx_bar1  = 0,
       output reg  [31:0] cfg_rx_bar2  = 0,
       output reg  [31:0] cfg_rx_bar3  = 0,
       output reg  [31:0] cfg_rx_bar4  = 0,
       output reg  [31:0] cfg_rx_bar5  = 0,
       output reg  [31:0] cfg_rx_xrom  = 0,
       output reg  [15:0] cfg_status   = 0,
       output reg  [15:0] cfg_command  = 0,
       output reg  [15:0] cfg_dstatus  = 0,
       output reg  [15:0] cfg_dcommand = 0,
       output reg  [15:0] cfg_lstatus  = 0,
       output reg  [15:0] cfg_lcommand = 0,
       output reg  [31:0] cfg_pmcsr    = 0,
       output reg  [31:0] cfg_dcap     = 0,
       output reg  [15:0] cfg_msgctrl  = 0,
       output reg  [31:0] cfg_msgladdr = 0,
       output reg  [31:0] cfg_msguaddr = 0,
       output reg  [15:0] cfg_msgdata  = 0,
       output wire  [7:0] cfg_bus_number,
       output wire  [4:0] cfg_device_number,
       output wire  [2:0] cfg_function_number,

       //// These signals go to mgmt block to implement a workaround
       input  wire [63:0] llk_rx_data_d,
       input  wire        llk_rx_src_rdy_n,
       input  wire  [6:0] l0_dll_error_vector,
       input  wire  [1:0] l0_rx_mac_link_error,
       input  wire        l0_stats_cfg_received,
       input  wire        l0_stats_cfg_transmitted,
       input  wire        l0_set_unsupported_request_other_error,
       input  wire        l0_set_detected_corr_error
); 


  (* ram_style = "distributed" *)
reg  [6:0] poll_dwaddr_rom [0:31];
reg [31:0] poll_dwrw_rom;
reg  [4:0] poll_dwaddr_cntr    = 0;
reg  [4:0] poll_dwaddr_cntr_d1 = 0;
reg  [4:0] poll_dwaddr_cntr_d2 = 0;
reg        poll_en             = 0;
reg        poll_data_en_d      = 0;
reg        wait_stg1           = 0;
reg        wait_stg2           = 0;
//reg        poll_rd_wr_done_n   = 1;
reg [31:0] mgmt_rdata_d1       = 0;
reg        cfg_data_en_d       = 0;
reg        cfg_rd_en_n_d       = 0;
reg        lock_useraccess     = 0;
wire       poll_data_en;
reg  [6:0] cfg_dwaddr_rom [0:31];
reg  [3:0] zero_out_byte       = 0;
reg        shift_word          = 0;

// define fixed Unsupported Request Error detected register bit in fabric
reg        fabric_ur_error_detected  = 0;
// define fixed Correctable Error detected register bit in fabric
reg        fabric_co_error_detected  = 0;
wire       fabric_ur_error_detect;
wire       fabric_co_error_detect;
reg        detected_h68read          = 0;
reg        detected_h68read_d        = 0;
wire       detected_h68read2cycle;
wire       falseur_cfg_access_wr;
reg        falseur_cfg_access_wr_reg = 0;
reg [3:0]  packet_read_cntr          = 0;
reg        packet_read_occurred      = 0; 
reg        mgmt_pso_co_d             = 0;
reg        mgmt_pso_ur_d             = 0;
reg        mgmt_pso_co_fell_d        = 0;
reg        mgmt_pso_ur_fell_d        = 0;
reg [3:0]  l0_dll_error_vector_d     = 0;
reg [1:0]  l0_rx_mac_link_error_d    = 0;
reg        l0_set_detected_corr_error_d = 0;

reg        detected_h48read          = 0;
reg        detected_h48read_d        = 0;
reg        detected_cfg_read1cycle    = 0;
wire       detected_h48read2cycle;
wire       msi_ctrl_cfg_access_wr;
reg        msi_ctrl_cfg_access_wr_reg = 0;

assign cfg_bus_number      = completer_id[12:5];
assign cfg_device_number   = completer_id[4:0];
assign cfg_function_number = 3'b000;

`ifndef INSTANTIATE_LUTROM
// A ROM to store the sequence of addresses to poll
initial begin
   poll_dwaddr_rom[0]   = 7'h47;
   poll_dwaddr_rom[1]   = 7'h48;
   poll_dwaddr_rom[2]   = 7'h01;  //CSR
   poll_dwaddr_rom[3]   = 7'h04;  //BAR0
   poll_dwaddr_rom[4]   = 7'h05;  //BAR1
   poll_dwaddr_rom[5]   = 7'h06;  //BAR2
   poll_dwaddr_rom[6]   = 7'h07;  //BAR3
   poll_dwaddr_rom[7]   = 7'h08;  //BAR4
   poll_dwaddr_rom[8]   = 7'h09;  //BAR5
   poll_dwaddr_rom[9]   = 7'h0c;  //XROM
   poll_dwaddr_rom[10]  = 7'h2a;  //Dstat,Dctrl
   poll_dwaddr_rom[11]  = 7'h2c;  //Lstat,Lctrl
   poll_dwaddr_rom[12]  = 7'h1e;  //PMCSR
   poll_dwaddr_rom[13]  = 7'h29;  //Dcap
   poll_dwaddr_rom[14]  = 7'h47;  //DSN high (write)
   poll_dwaddr_rom[15]  = 7'h48;  //DSN low  (write)
   ////
   poll_dwaddr_rom[16]  = 7'h22;  //MSI Control
   poll_dwaddr_rom[17]  = 7'h23;  //MSI Lower Address
   poll_dwaddr_rom[18]  = 7'h24;  //MSI Upper Address
   poll_dwaddr_rom[19]  = 7'h25;  //MSI Data
   poll_dwaddr_rom[20]  = 7'h00;  //
   poll_dwaddr_rom[21]  = 7'h00;  //
   poll_dwaddr_rom[22]  = 7'h00;  //
   poll_dwaddr_rom[23]  = 7'h00;  //
   poll_dwaddr_rom[24]  = 7'h00;  //
   poll_dwaddr_rom[25]  = 7'h00;  //
   poll_dwaddr_rom[26]  = 7'h00;  //
   poll_dwaddr_rom[27]  = 7'h00;  //
   poll_dwaddr_rom[28]  = 7'h00;  //
   poll_dwaddr_rom[29]  = 7'h00;  //
   poll_dwaddr_rom[30]  = 7'h00;  //
   poll_dwaddr_rom[31]  = 7'h00;  //
end

// A ROM to store the sequence of read or write ops
initial begin
   poll_dwrw_rom[0]   = 1'b0;
   poll_dwrw_rom[1]   = 1'b0;
   poll_dwrw_rom[2]   = 1'b0;
   poll_dwrw_rom[3]   = 1'b0;
   poll_dwrw_rom[4]   = 1'b0;
   poll_dwrw_rom[5]   = 1'b0;
   poll_dwrw_rom[6]   = 1'b0;
   poll_dwrw_rom[7]   = 1'b0;
   poll_dwrw_rom[8]   = 1'b0;
   poll_dwrw_rom[9]   = 1'b0;
   poll_dwrw_rom[10]  = 1'b0;
   poll_dwrw_rom[11]  = 1'b0;
   poll_dwrw_rom[12]  = 1'b0;
   poll_dwrw_rom[13]  = 1'b0;
   poll_dwrw_rom[14]  = 1'b1;
   poll_dwrw_rom[15]  = 1'b1;
   ////
   poll_dwrw_rom[16]  = 1'b0;
   poll_dwrw_rom[17]  = 1'b0;
   poll_dwrw_rom[18]  = 1'b0;
   poll_dwrw_rom[19]  = 1'b0;
   poll_dwrw_rom[20]  = 1'b0;
   poll_dwrw_rom[21]  = 1'b0;
   poll_dwrw_rom[22]  = 1'b0;
   poll_dwrw_rom[23]  = 1'b0;
   poll_dwrw_rom[24]  = 1'b0;
   poll_dwrw_rom[25]  = 1'b0;
   poll_dwrw_rom[26]  = 1'b0;
   poll_dwrw_rom[27]  = 1'b0;
   poll_dwrw_rom[28]  = 1'b0;
   poll_dwrw_rom[29]  = 1'b0;
   poll_dwrw_rom[30]  = 1'b0;
   poll_dwrw_rom[31]  = 1'b0;
end

wire [10:0] poll_dwaddr  = {4'b0,poll_dwaddr_rom[poll_dwaddr_cntr]};
wire        poll_dwrw    = poll_dwrw_rom[poll_dwaddr_cntr];

`else

wire  [6:0] poll_dwaddrx;
wire        poll_dwrw;

//// DWADDR LUT ROM ////
//               fedc ba98 7654 3210  fedc ba98 7654 3210
LUT5 #(.INIT(32'b0000_0000_0000_0000__1100_0000_0000_0011)) lut_dwaddr_rom6( .O (poll_dwaddrx[6]), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));
LUT5 #(.INIT(32'b0000_0000_0000_1111__0010_1100_0000_0000)) lut_dwaddr_rom5( .O (poll_dwaddrx[5]), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));
LUT5 #(.INIT(32'b0000_0000_0000_0000__0001_0000_0000_0000)) lut_dwaddr_rom4( .O (poll_dwaddrx[4]), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));
LUT5 #(.INIT(32'b0000_0000_0000_0000__1011_1111_1000_0010)) lut_dwaddr_rom3( .O (poll_dwaddrx[3]), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));
LUT5 #(.INIT(32'b0000_0000_0000_1100__0101_1010_0111_1001)) lut_dwaddr_rom2( .O (poll_dwaddrx[2]), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));
LUT5 #(.INIT(32'b0000_0000_0000_0011__0101_0100_0110_0001)) lut_dwaddr_rom1( .O (poll_dwaddrx[1]), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));
LUT5 #(.INIT(32'b0000_0000_0000_1010__0110_0001_0101_0101)) lut_dwaddr_rom0( .O (poll_dwaddrx[0]), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));

wire [10:0] poll_dwaddr  = {4'b0,poll_dwaddrx};

//// DWRW LUT ROM ////
//               fedc ba98 7654 3210  fedc ba98 7654 3210
LUT5 #(.INIT(32'b0000_0000_0000_0000__1100_0000_0000_0000)) lut_dwrw_rom( .O (poll_dwrw), .I0(poll_dwaddr_cntr[0]), .I1(poll_dwaddr_cntr[1]), .I2(poll_dwaddr_cntr[2]), .I3(poll_dwaddr_cntr[3]), .I4(poll_dwaddr_cntr[4]));


`endif


wire       cfg_dwaddr_remap = (cfg_dwaddr[6:5] == 2'b10);
wire [4:0] cfg_dwaddr_int   = (cfg_dwaddr[4:0] ^ {5{cfg_dwaddr_remap}});

`ifndef INSTANTIATE_LUTROM
initial begin
  cfg_dwaddr_rom[0]  = 7'h00; //00
  cfg_dwaddr_rom[1]  = 7'h01; //04
  cfg_dwaddr_rom[2]  = 7'h02; //08
  cfg_dwaddr_rom[3]  = 7'h03; //0C
  //
  cfg_dwaddr_rom[4]  = 7'h04; //10
  cfg_dwaddr_rom[5]  = 7'h05; //14
  cfg_dwaddr_rom[6]  = 7'h06; //18
  cfg_dwaddr_rom[7]  = 7'h07; //1C
  //
  cfg_dwaddr_rom[8]  = 7'h08; //20
  cfg_dwaddr_rom[9]  = 7'h09; //24
  cfg_dwaddr_rom[10] = 7'h0a; //28
  cfg_dwaddr_rom[11] = 7'h0b; //2C
  //
  cfg_dwaddr_rom[12] = 7'h0c; //30
  cfg_dwaddr_rom[13] = 7'h0d; //34
  cfg_dwaddr_rom[14] = 7'h0d; //38 rsvd
  cfg_dwaddr_rom[15] = 7'h0d; //3C
  //
  cfg_dwaddr_rom[16] = 7'h1d; //40
  cfg_dwaddr_rom[17] = 7'h1e; //44
  cfg_dwaddr_rom[18] = 7'h22; //48
  cfg_dwaddr_rom[19] = 7'h23; //4C
  //
  cfg_dwaddr_rom[20] = 7'h24; //50
  cfg_dwaddr_rom[21] = 7'h25; //54
  cfg_dwaddr_rom[22] = 7'h26; //58 mask
  cfg_dwaddr_rom[23] = 7'h27; //5C pend
  //
  cfg_dwaddr_rom[24] = 7'h28; //60
  cfg_dwaddr_rom[25] = 7'h29; //64
  cfg_dwaddr_rom[26] = 7'h2a; //68
  cfg_dwaddr_rom[27] = 7'h2b; //6C
  //
  cfg_dwaddr_rom[28] = 7'h2c; //70
  //these addresses are in backwards order to "stuff" the last address range into the LUTRAM
  // if the upper bits of the cfgdwaddr are "10", then the lower bits that are used to address
  // this LUTRAM are inverted, which convienently happens to be 31,30,29 for inputted addresses
  // 0xh108, 0xh104, 0xh100
  cfg_dwaddr_rom[29] = 7'h48; //108  (dwaddr=66)
  cfg_dwaddr_rom[30] = 7'h47; //104  (dwaddr=65)
  cfg_dwaddr_rom[31] = 7'h46; //100  (dwaddr=64)
end

wire [9:0] cfg_dwaddr_trans = {3'b0,cfg_dwaddr_rom[cfg_dwaddr_int]};

`else

wire [9:0] cfg_dwaddr_trans;
assign cfg_dwaddr_trans[9:7] = 3'b000;

//               fedc ba98 7654 3210  fedc ba98 7654 3210
LUT5 #(.INIT(32'b1110_0000_0000_0000__0000_0000_0000_0000)) lut_cfgdw_rom6( .O (cfg_dwaddr_trans[6]), .I0(cfg_dwaddr_int[0]), .I1(cfg_dwaddr_int[1]), .I2(cfg_dwaddr_int[2]), .I3(cfg_dwaddr_int[3]), .I4(cfg_dwaddr_int[4]));
LUT5 #(.INIT(32'b0001_1111_1111_1100__0000_0000_0000_0000)) lut_cfgdw_rom5( .O (cfg_dwaddr_trans[5]), .I0(cfg_dwaddr_int[0]), .I1(cfg_dwaddr_int[1]), .I2(cfg_dwaddr_int[2]), .I3(cfg_dwaddr_int[3]), .I4(cfg_dwaddr_int[4]));
LUT5 #(.INIT(32'b0000_0000_0000_0011__0000_0000_0000_0000)) lut_cfgdw_rom4( .O (cfg_dwaddr_trans[4]), .I0(cfg_dwaddr_int[0]), .I1(cfg_dwaddr_int[1]), .I2(cfg_dwaddr_int[2]), .I3(cfg_dwaddr_int[3]), .I4(cfg_dwaddr_int[4]));

LUT5 #(.INIT(32'b0011_1111_0000_0011__1111_1111_0000_0000)) lut_cfgdw_rom3( .O (cfg_dwaddr_trans[3]), .I0(cfg_dwaddr_int[0]), .I1(cfg_dwaddr_int[1]), .I2(cfg_dwaddr_int[2]), .I3(cfg_dwaddr_int[3]), .I4(cfg_dwaddr_int[4]));
LUT5 #(.INIT(32'b1101_0000_1111_0011__1111_0000_1111_0000)) lut_cfgdw_rom2( .O (cfg_dwaddr_trans[2]), .I0(cfg_dwaddr_int[0]), .I1(cfg_dwaddr_int[1]), .I2(cfg_dwaddr_int[2]), .I3(cfg_dwaddr_int[3]), .I4(cfg_dwaddr_int[4]));
LUT5 #(.INIT(32'b1100_1100_1100_1110__0000_1100_1100_1100)) lut_cfgdw_rom1( .O (cfg_dwaddr_trans[1]), .I0(cfg_dwaddr_int[0]), .I1(cfg_dwaddr_int[1]), .I2(cfg_dwaddr_int[2]), .I3(cfg_dwaddr_int[3]), .I4(cfg_dwaddr_int[4]));
LUT5 #(.INIT(32'b0100_1010_1010_1001__1110_1010_1010_1010)) lut_cfgdw_rom0( .O (cfg_dwaddr_trans[0]), .I0(cfg_dwaddr_int[0]), .I1(cfg_dwaddr_int[1]), .I2(cfg_dwaddr_int[2]), .I3(cfg_dwaddr_int[3]), .I4(cfg_dwaddr_int[4]));

`endif

wire enable_mgmt_op = (!mgmt_rden && !wait_stg1 && !lock_useraccess);
reg  [9:0] cfg_dwaddr_trans_reg = 0;
wire       cappntr = (cfg_dwaddr[9:0] == 10'h00D);
wire       intline = (cfg_dwaddr[9:0] == 10'h00F);

always @(posedge clk) begin
   if (!rst_n) begin
      cfg_rd_en_n_d        <= #`Tcq 0;
      cfg_dwaddr_trans_reg <= #`Tcq 0;
   end else begin
      cfg_rd_en_n_d        <= #`Tcq cfg_rd_en_n || !cfg_rd_wr_done_n;
      cfg_dwaddr_trans_reg <= #`Tcq cfg_dwaddr_trans;
   end
end

//////////
// Generate MGMT interface transaction
always @(posedge clk) begin
   if (!rst_n) begin
      mgmt_addr           <= #`Tcq 11'h047;
      mgmt_wdata          <= #`Tcq 0;
      mgmt_rden           <= #`Tcq 0;
      mgmt_wren           <= #`Tcq 0;
      poll_en             <= #`Tcq 0;
      poll_dwaddr_cntr    <= #`Tcq 0;
      poll_dwaddr_cntr_d1 <= #`Tcq 0;
      zero_out_byte       <= #`Tcq 0;
      shift_word          <= #`Tcq 0;
   end else if (enable_mgmt_op || falseur_cfg_access_wr || msi_ctrl_cfg_access_wr) begin
      if (falseur_cfg_access_wr) begin
         mgmt_addr           <= #`Tcq 11'h02a;
         mgmt_wdata          <= #`Tcq {8'h00, 2'b00, mgmt_pso[6], 1'b0, fabric_ur_error_detected,
                                       mgmt_pso[8], mgmt_pso[9], fabric_co_error_detected, 16'h0000};
         mgmt_rden           <= #`Tcq 0;
         mgmt_wren           <= #`Tcq 1;
         mgmt_bwren          <= #`Tcq 4'b0100;
         poll_en             <= #`Tcq 0;
         poll_dwaddr_cntr    <= #`Tcq poll_dwaddr_cntr;
         poll_dwaddr_cntr_d1 <= #`Tcq poll_dwaddr_cntr_d1;
         zero_out_byte       <= #`Tcq 0;
         shift_word          <= #`Tcq 0;
      end else if (msi_ctrl_cfg_access_wr) begin
         mgmt_addr           <= #`Tcq 11'h022;
         mgmt_wdata          <= #`Tcq 32'h00;
         mgmt_rden           <= #`Tcq 0;
         mgmt_wren           <= #`Tcq 1;
         mgmt_bwren          <= #`Tcq 4'b1000;
         poll_en             <= #`Tcq 0;
         poll_dwaddr_cntr    <= #`Tcq poll_dwaddr_cntr;
         poll_dwaddr_cntr_d1 <= #`Tcq poll_dwaddr_cntr_d1;
         zero_out_byte       <= #`Tcq 0;
         shift_word          <= #`Tcq 0;
      // user requests Configuration access
      end else if (!cfg_rd_en_n && !cfg_rd_en_n_d) begin
         mgmt_addr           <= #`Tcq {1'b0,cfg_dwaddr_trans_reg[9:0]};
         mgmt_rden           <= #`Tcq 1;
         mgmt_wren           <= #`Tcq 0;
         mgmt_bwren          <= #`Tcq 4'hf;
         poll_en             <= #`Tcq 0;
         poll_dwaddr_cntr    <= #`Tcq poll_dwaddr_cntr;
         poll_dwaddr_cntr_d1 <= #`Tcq poll_dwaddr_cntr_d1;
         zero_out_byte       <= #`Tcq {(cappntr||intline),(cappntr||intline),cappntr,1'b0};
         shift_word          <= #`Tcq intline;
      // no User request, begin a new write operation
      end else if (poll_dwrw) begin
         mgmt_addr           <= #`Tcq poll_dwaddr;
         mgmt_wdata          <= #`Tcq (!poll_dwaddr_cntr[0]) ? cfg_dsn[31:0]:
                                                               cfg_dsn[63:32];
         mgmt_rden           <= #`Tcq 0;
         mgmt_wren           <= #`Tcq 1;
         mgmt_bwren          <= #`Tcq 4'hf;
         poll_en             <= #`Tcq 0;
         poll_dwaddr_cntr    <= #`Tcq poll_dwaddr_cntr + 1;
         poll_dwaddr_cntr_d1 <= #`Tcq poll_dwaddr_cntr;
         zero_out_byte       <= #`Tcq 0;
         shift_word          <= #`Tcq 0;
      // no User request, begin a new polling operation
      end else if (!poll_dwrw) begin
         mgmt_addr           <= #`Tcq poll_dwaddr;
         mgmt_rden           <= #`Tcq 1;
         mgmt_wren           <= #`Tcq 0;
         mgmt_bwren          <= #`Tcq 4'hf;
         poll_en             <= #`Tcq 1;
         poll_dwaddr_cntr    <= #`Tcq poll_dwaddr_cntr + 1;
         poll_dwaddr_cntr_d1 <= #`Tcq poll_dwaddr_cntr;
         zero_out_byte       <= #`Tcq 0;
         shift_word          <= #`Tcq 0;
      // in the middle of a current op, hold values (except turnoff rden)
      end 
   end else begin
      mgmt_addr           <= #`Tcq mgmt_addr;
      mgmt_rden           <= #`Tcq 0;
      mgmt_wren           <= #`Tcq 0;
      mgmt_bwren          <= #`Tcq 4'hf;
      poll_en             <= #`Tcq poll_en;
      poll_dwaddr_cntr    <= #`Tcq poll_dwaddr_cntr;
      poll_dwaddr_cntr_d1 <= #`Tcq poll_dwaddr_cntr_d1;
      zero_out_byte       <= #`Tcq zero_out_byte;
      shift_word          <= #`Tcq shift_word;
   end
end



always @(posedge clk) begin
   if (!rst_n) begin
      lock_useraccess     <= #`Tcq 0;
      wait_stg1           <= #`Tcq 0;
      wait_stg2           <= #`Tcq 0;
      poll_data_en_d      <= #`Tcq 0;
      poll_dwaddr_cntr_d2 <= #`Tcq 0;
   end else begin
      // Lock out new transactions while waiting for user access to complete
      if      (!cfg_rd_wr_done_n)
         lock_useraccess     <= #`Tcq 0;
      else if (!cfg_rd_en_n && !cfg_rd_en_n_d && !mgmt_rden && !wait_stg1 &&
               !lock_useraccess)
         lock_useraccess     <= #`Tcq 1;
      ////
      wait_stg1           <= #`Tcq mgmt_rden;
      wait_stg2           <= #`Tcq wait_stg1;
      poll_data_en_d      <= #`Tcq poll_data_en;
      poll_dwaddr_cntr_d2 <= #`Tcq poll_dwaddr_cntr_d1;
   end
end

assign poll_data_en = wait_stg2 && poll_en;
assign cfg_data_en  = wait_stg2 && !poll_en;

// Indicate whether user or polled access is complete, and capture data
always @(posedge clk) begin
   if (!rst_n) begin
      cfg_data_en_d     <= #`Tcq 0;
      mgmt_rdata_d1     <= #`Tcq 0;
      cfg_do            <= #`Tcq 0;
      cfg_rd_wr_done_n  <= #`Tcq 1;
   end else begin
      cfg_data_en_d     <= #`Tcq cfg_data_en;
      if (poll_data_en || cfg_data_en) begin
         mgmt_rdata_d1    <= #`Tcq mgmt_rdata;
      end
      if (cfg_data_en_d) begin
         case ( zero_out_byte[3])
         1'b0:  cfg_do[31:24] <= #`Tcq mgmt_rdata_d1[31:24];
         1'b1:  cfg_do[31:24] <= #`Tcq 8'b0;
         endcase
         case ( zero_out_byte[2])
         1'b0:  cfg_do[23:16] <= #`Tcq mgmt_rdata_d1[23:16];
         1'b1:  cfg_do[23:16] <= #`Tcq 8'b0;
         endcase
         case ({zero_out_byte[1], shift_word})
         2'b00: cfg_do[15:8]  <= #`Tcq mgmt_rdata_d1[15:8];
         2'b01: cfg_do[15:8]  <= #`Tcq mgmt_rdata_d1[23:16];
         2'b10: cfg_do[15:8]  <= #`Tcq 8'b0;
         2'b11: cfg_do[15:8]  <= #`Tcq 8'b0;
         endcase
         case ( shift_word)
         1'b0:  cfg_do[7:0]   <= #`Tcq mgmt_rdata_d1[7:0];
         1'b1:  cfg_do[7:0]   <= #`Tcq mgmt_rdata_d1[15:8];
         endcase
      end
      cfg_rd_wr_done_n  <= #`Tcq !cfg_data_en_d;
   end
end

// For polled data, write captured data to shadow registers
always @(posedge clk) begin
   if (!rst_n) begin
      cfg_status       <= #`Tcq 0;
      cfg_command      <= #`Tcq 0;
      cfg_dstatus      <= #`Tcq 0;
      cfg_dcommand     <= #`Tcq 0;
      cfg_lstatus      <= #`Tcq 0;
      cfg_lcommand     <= #`Tcq 0;
      cfg_pmcsr        <= #`Tcq 0;
      cfg_dcap         <= #`Tcq 0;
      cfg_msgctrl      <= #`Tcq 0;
      cfg_msgladdr     <= #`Tcq 0;
      cfg_msguaddr     <= #`Tcq 0;
      cfg_msgdata      <= #`Tcq 0;
      cfg_rx_bar0      <= #`Tcq 0;
      cfg_rx_bar1      <= #`Tcq 0;
      cfg_rx_bar2      <= #`Tcq 0;
      cfg_rx_bar3      <= #`Tcq 0;
      cfg_rx_bar4      <= #`Tcq 0;
      cfg_rx_bar5      <= #`Tcq 0;
      cfg_rx_xrom      <= #`Tcq 0;
   end else if (poll_data_en_d) begin
      case (poll_dwaddr_cntr_d2)
      5'h2: begin //01
         cfg_status       <= #`Tcq mgmt_rdata_d1[31:16];    
         cfg_command      <= #`Tcq mgmt_rdata_d1[15:0];
      end
      5'h3:       //04
         cfg_rx_bar0      <= #`Tcq mgmt_rdata_d1;
      5'h4:       //05
         cfg_rx_bar1      <= #`Tcq mgmt_rdata_d1;
      5'h5:       //06
         cfg_rx_bar2      <= #`Tcq mgmt_rdata_d1;
      5'h6:       //07
         cfg_rx_bar3      <= #`Tcq mgmt_rdata_d1;
      5'h7:       //08
         cfg_rx_bar4      <= #`Tcq mgmt_rdata_d1;
      5'h8:       //09
         cfg_rx_bar5      <= #`Tcq mgmt_rdata_d1;
      5'h9:       //0c
         cfg_rx_xrom      <= #`Tcq mgmt_rdata_d1;
      5'ha: begin //2a
         cfg_dstatus      <= #`Tcq mgmt_rdata_d1[31:16];    
         cfg_dcommand     <= #`Tcq mgmt_rdata_d1[15:0];
      end
      5'hb: begin //2c
         cfg_lstatus      <= #`Tcq mgmt_rdata_d1[31:16];    
         cfg_lcommand     <= #`Tcq mgmt_rdata_d1[15:0];
      end
      5'hc:       //1e
         cfg_pmcsr        <= #`Tcq mgmt_rdata_d1;
      5'hd:       //29
         cfg_dcap         <= #`Tcq mgmt_rdata_d1;
      5'h10:      //22
         cfg_msgctrl      <= #`Tcq mgmt_rdata_d1[31:16];
      5'h11:      //23
         cfg_msgladdr     <= #`Tcq mgmt_rdata_d1;
      5'h12:      //24
         cfg_msguaddr     <= #`Tcq mgmt_rdata_d1;
      5'h13:      //25
         cfg_msgdata      <= #`Tcq mgmt_rdata_d1[15:0];
      default: begin end
      endcase
   end
end


// ANFE workaround for Correctable and Unsupported Request detected


  assign fabric_co_error_detect = (|l0_dll_error_vector_d[3:0]) | l0_rx_mac_link_error_d[1] | l0_set_detected_corr_error_d;

  always @(posedge clk) begin
    if (!rst_n) begin
      mgmt_pso_co_d                <= #`Tcq 1'b0;
      mgmt_pso_ur_d                <= #`Tcq 1'b0;
      mgmt_pso_co_fell_d           <= #`Tcq 1'b0;
      mgmt_pso_ur_fell_d           <= #`Tcq 1'b0;
      l0_dll_error_vector_d        <= #`Tcq 4'b0;
      l0_rx_mac_link_error_d       <= #`Tcq 2'b0;
      l0_set_detected_corr_error_d <= #`Tcq 1'b0;
    end else begin
      mgmt_pso_co_d                <= #`Tcq mgmt_pso[10];
      mgmt_pso_ur_d                <= #`Tcq mgmt_pso[7];
      mgmt_pso_co_fell_d           <= #`Tcq !mgmt_pso[10]&& mgmt_pso_co_d;
      mgmt_pso_ur_fell_d           <= #`Tcq !mgmt_pso[7] && mgmt_pso_ur_d;
      l0_dll_error_vector_d        <= #`Tcq l0_dll_error_vector[3:0];
      l0_rx_mac_link_error_d       <= #`Tcq l0_rx_mac_link_error[1:0];
      l0_set_detected_corr_error_d <= #`Tcq l0_set_detected_corr_error;
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      fabric_co_error_detected <= #`Tcq 1'b0;
    end else if (mgmt_pso_co_fell_d) begin
      fabric_co_error_detected <= #`Tcq 1'b0;
    end else if (fabric_co_error_detect) begin
      fabric_co_error_detected <= #`Tcq 1'b1;
    end
  end

  assign fabric_ur_error_detect = l0_set_unsupported_request_other_error;
  always @(posedge clk) begin
    if (!rst_n) begin
      fabric_ur_error_detected <= #`Tcq 1'b0;
    end else if (mgmt_pso_ur_fell_d) begin
      fabric_ur_error_detected <= #`Tcq 1'b0;
    end else if (fabric_ur_error_detect) begin
      fabric_ur_error_detected <= #`Tcq 1'b1;
    end
  end

  // override the bits only when Root is reading the Device Control/Status
  // Register, and both the internal Correctable and UR Error detected bits
  // are 1
  always @(posedge clk)
    if (!rst_n)
      detected_cfg_read1cycle <= #`Tcq 1'b0;
    else if (llk_rx_data_d[63:32] == 32'h04000001)
      detected_cfg_read1cycle <= #`Tcq 1'b1;
    else if (!(detected_h68read2cycle | detected_h48read2cycle))
      detected_cfg_read1cycle <= #`Tcq 1'b0;

  assign detected_h68read2cycle = (llk_rx_data_d[47:32] == 16'h0068);

  always @(posedge clk) begin
    if (!rst_n) begin
      detected_h68read       <= #`Tcq 1'b0;
      detected_h68read_d     <= #`Tcq 1'b0;
    end else begin
      detected_h68read       <= #`Tcq detected_cfg_read1cycle &&
                                      detected_h68read2cycle;
      detected_h68read_d     <= #`Tcq detected_h68read;
    end
  end

  assign falseur_cfg_access_wr = falseur_cfg_access_wr_reg;

  always @(posedge clk) begin
    if (!rst_n | l0_stats_cfg_transmitted) begin
      falseur_cfg_access_wr_reg <= #`Tcq 1'b0;
    end else if (!falseur_cfg_access_wr_reg) begin
      falseur_cfg_access_wr_reg <= #`Tcq (detected_h68read_d && l0_stats_cfg_received && 
                                          (mgmt_pso_co_d || mgmt_pso_ur_d));
    end
  end

//end of ANFE workaround

  // override the PVM bit only when Root is reading the MSI control Register

  assign detected_h48read2cycle = (llk_rx_data_d[47:32] == 16'h0048);

  always @(posedge clk) begin
    if (!rst_n) begin
      detected_h48read       <= #`Tcq 1'b0;
      detected_h48read_d     <= #`Tcq 1'b0;
    end else begin
      detected_h48read       <= #`Tcq detected_cfg_read1cycle &&
                                      detected_h48read2cycle;
      detected_h48read_d     <= #`Tcq detected_h48read;
    end
  end

  assign msi_ctrl_cfg_access_wr = msi_ctrl_cfg_access_wr_reg;

  always @(posedge clk) begin
    if (!rst_n | l0_stats_cfg_transmitted) begin
      msi_ctrl_cfg_access_wr_reg <= #`Tcq 1'b0;
    end else if (!msi_ctrl_cfg_access_wr_reg) begin
      msi_ctrl_cfg_access_wr_reg <= #`Tcq (detected_h48read_d && l0_stats_cfg_received);
    end
  end

endmodule // pcie_blk_cf_mgmt



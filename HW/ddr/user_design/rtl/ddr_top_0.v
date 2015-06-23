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
// Copyright 2005, 2006, 2007, 2008 Xilinx, Inc.
// All rights reserved.
//
// This disclaimer and copyright notice must be retained as part
// of this file at all times.
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /   Vendor		    : Xilinx
// \   \   \/    Version            : 3.6.1
//  \   \        Application	    : MIG
//  /   /        Filename	    : ddr_top_0.v
// /___/   /\    Date Last Modified : $Date: 2010/11/26 18:25:42 $
// \   \  /  \   Date Created	    : Mon May 2 2005
//  \___\/\___\
// Device	: Spartan-3/3A/3A-DSP
// Design Name	: DDR2 SDRAM
// Purpose	: This modules has the instantiations infrastructure, iobs, 
//		  controller and data_paths modules
//*****************************************************************************

`timescale 1ns/100ps
`include "../rtl/ddr_parameters_0.v"

module  ddr_top_0
  (
   input                                         rst_dqs_div_in,
   output                                        rst_dqs_div_out,
   input                                         clk_int,
   input                                         clk90_int,
   input [4:0]                                   delay_sel_val,
   input                                         sys_rst,
   input                                         sys_rst90,
   input                                         sys_rst180,
   input [((`DATA_WIDTH*2)-1):0]                 user_input_data,
   output [((`DATA_WIDTH*2)-1):0]                user_output_data,
   output                                        user_data_valid,
   input [((`ROW_ADDRESS +
            `COLUMN_ADDRESS + `BANK_ADDRESS)-1):0] user_input_address,
   input [2:0]                                   user_command_register,
   output                                        user_cmd_ack,
   input                                         burst_done,
   output                                        init_done,
   output                                        ar_done,
   inout [((`DATA_STROBE_WIDTH)-1):0]            ddr2_dqs,
   inout [(`DATA_WIDTH-1):0]                     ddr2_dq,
   output                                        ddr2_cke,
   output                                        ddr2_cs_n,
   output                                        auto_ref_req,
   input                                         wait_200us,
   output                                        ddr2_ras_n,
   output                                        ddr2_cas_n,
   output                                        ddr2_we_n,
   output                                        ddr2_odt,
   output [`BANK_ADDRESS-1:0]                    ddr2_ba,
   output [`ROW_ADDRESS-1:0]                     ddr2_a,
   output [(`CLK_WIDTH-1):0]                     ddr2_ck,
   input  [((`DATA_MASK_WIDTH*2)-1):0]           user_data_mask,
   output [((`DATA_MASK_WIDTH)-1):0]             ddr2_dm,
    inout  [(`DATA_STROBE_WIDTH-1):0] ddr2_dqs_n, 

   output       clk_tb,
   output       clk90_tb,
   output       sys_rst_tb,
   output       sys_rst90_tb,
   output       sys_rst180_tb, 
   output [(`CLK_WIDTH-1):0]                     ddr2_ck_n,
   //debug_signals
   output [4:0]                                  dbg_delay_sel, 
   output                                        dbg_rst_calib,
   input [4:0]				         vio_out_dqs,
   input 				         vio_out_dqs_en,
   input [4:0]                                   vio_out_rst_dqs_div,
   input                                         vio_out_rst_dqs_div_en
   );


   wire                                          rst_calib;
   wire [4:0]                                    delay_sel;
   wire                                          write_enable;
   wire                                          dqs_div_rst;
   wire                                          dqs_enable;
   wire                                          dqs_reset;
   wire [(`DATA_WIDTH-1):0]                      dq;
   wire                                          write_en_val;
   wire [((`DATA_MASK_WIDTH)-1):0]               data_mask_f;
   wire [((`DATA_MASK_WIDTH)-1):0]               data_mask_r;
   wire [(`DATA_WIDTH-1):0]                      write_data_falling;
   wire [(`DATA_WIDTH-1):0]                      write_data_rising;
   wire                                          ddr_rasb_cntrl;
   wire                                          ddr_casb_cntrl;
   wire                                          ddr_web_cntrl;
   wire [`BANK_ADDRESS-1:0]                      ddr_ba_cntrl;
   wire [`ROW_ADDRESS-1:0]                       ddr_address_cntrl;
   wire                                          ddr_cke_cntrl;
   wire                                          ddr_csb_cntrl;
   wire                                          ddr_odt_cntrl;
   wire                                          rst_dqs_div_int;
   wire [(`DATA_STROBE_WIDTH-1):0]		 dqs_int_delay_in;

   assign     clk_tb   = clk_int;
   assign     clk90_tb = clk90_int;
   assign     sys_rst_tb   = sys_rst;
   assign     sys_rst90_tb = sys_rst90;
   assign     sys_rst180_tb = sys_rst180;

   ddr_controller_0 controller0
     (
      .auto_ref_req      (auto_ref_req),
      .wait_200us(wait_200us),
      .clk               (clk_int),
      .rst0              (sys_rst),
      .rst180            (sys_rst180),
      .address           (user_input_address[((`ROW_ADDRESS + 
                                               `COLUMN_ADDRESS +
                                               `BANK_ADDRESS)-1):
                                             `BANK_ADDRESS]),
      .bank_address      (user_input_address[(`BANK_ADDRESS-1): 0]),
      .command_register  (user_command_register),
      .burst_done        (burst_done),
      .ddr_rasb_cntrl    (ddr_rasb_cntrl),
      .ddr_casb_cntrl    (ddr_casb_cntrl),
      .ddr_web_cntrl     (ddr_web_cntrl),
      .ddr_ba_cntrl      (ddr_ba_cntrl),
      .ddr_address_cntrl (ddr_address_cntrl),
      .ddr_cke_cntrl     (ddr_cke_cntrl),
      .ddr_csb_cntrl     (ddr_csb_cntrl),
      .ddr_odt_cntrl     (ddr_odt_cntrl),
      .dqs_enable        (dqs_enable),
      .dqs_reset         (dqs_reset),
      .write_enable      (write_enable),
      .rst_calib         (rst_calib),
      .rst_dqs_div_int   (rst_dqs_div_int),
      .cmd_ack           (user_cmd_ack),
      .init              (init_done),
      .ar_done           (ar_done),
      .read_fifo_rden    (read_fifo_rden) // Added new signal
      );
   
   ddr_data_path_0  data_path0
     (
      .user_input_data       (user_input_data),
      .user_data_mask        (user_data_mask),
      .clk                   (clk_int),
      .clk90                 (clk90_int),
      .reset                 (sys_rst),
      .reset90               (sys_rst90),
      .write_enable          (write_enable),
      .rst_dqs_div_in        (dqs_div_rst),
      .delay_sel             (delay_sel),
      .dqs_int_delay_in      (dqs_int_delay_in),
      .dq                    (dq),
      .u_data_val            (user_data_valid),
      .user_output_data      (user_output_data),
      .write_en_val          (write_en_val),
      .data_mask_f           (data_mask_f),
      .data_mask_r           (data_mask_r),
      .write_data_falling    (write_data_falling),
      .write_data_rising     (write_data_rising),
      .read_fifo_rden        (read_fifo_rden),    // Added new signal
//debug signals
      .vio_out_dqs            (vio_out_dqs),   
      .vio_out_dqs_en         (vio_out_dqs_en),   
      .vio_out_rst_dqs_div    (vio_out_rst_dqs_div),
      .vio_out_rst_dqs_div_en (vio_out_rst_dqs_div_en)
      );
   
   ddr_infrastructure infrastructure0
     (
      .clk_int            (clk_int),
      .rst_calib1         (rst_calib),
      .delay_sel_val      (delay_sel_val),
      .delay_sel_val1_val (delay_sel),
      .dbg_delay_sel      (dbg_delay_sel),
      .dbg_rst_calib      (dbg_rst_calib)
      );
   
   ddr_iobs_0       iobs0
     (
      .clk               (clk_int),
      .clk90             (clk90_int),
      .ddr_rasb_cntrl    (ddr_rasb_cntrl),
      .ddr_casb_cntrl    (ddr_casb_cntrl),
      .ddr_web_cntrl     (ddr_web_cntrl),
      .ddr_cke_cntrl     (ddr_cke_cntrl),
      .ddr_csb_cntrl     (ddr_csb_cntrl),
      .ddr_odt_cntrl     (ddr_odt_cntrl),
      .ddr_address_cntrl (ddr_address_cntrl),
      .ddr_ba_cntrl      (ddr_ba_cntrl),
      .rst_dqs_div_int   (rst_dqs_div_int),
      .dqs_reset         (dqs_reset),
      .dqs_enable        (dqs_enable),
      .ddr_dqs           (ddr2_dqs),
       .ddr_dqs_n (ddr2_dqs_n),
      .ddr_dq            (ddr2_dq),
      .write_data_falling(write_data_falling),
      .write_data_rising (write_data_rising),
      .write_en_val      (write_en_val),
      .data_mask_f       (data_mask_f),
      .data_mask_r       (data_mask_r),
      .ddr2_ck           (ddr2_ck),
      .ddr2_ck_n         (ddr2_ck_n),
      .ddr_rasb          (ddr2_ras_n),
      .ddr_casb          (ddr2_cas_n),
      .ddr_web           (ddr2_we_n),
      .ddr_ba            (ddr2_ba),
      .ddr_address       (ddr2_a),
      .ddr_cke           (ddr2_cke),
      .ddr_csb           (ddr2_cs_n),
      .ddr_odt0          (ddr2_odt),
      .rst_dqs_div       (dqs_div_rst),
      .rst_dqs_div_in    (rst_dqs_div_in),
      .rst_dqs_div_out   (rst_dqs_div_out),
      .dqs_int_delay_in  (dqs_int_delay_in),
      .ddr_dm            (ddr2_dm),
      .dq                (dq)
      );
   
endmodule

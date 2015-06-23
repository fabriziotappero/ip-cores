
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
// File       : cmm_errman_ftl.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/***********************************************************************

  Description: 

  This module figures out what to do for fatal errors:
    1) count up or count down,
    2) how much to add or to subtract.
  It returns the number and a add/subtract_b signals to the error 
  tracking counter. The outputs are based on how many errors are 
  asserted by the error reporting modules.

***********************************************************************/


module cmm_errman_ftl (
                ftl_num,                // Output
                inc_dec_b,
                cmmp_training_err,      // Inputs
                cmml_protocol_err_n,    
                cmmt_err_rbuf_overflow,
                cmmt_err_fc,
                cmmt_err_tlp_malformed,
                decr_ftl,
                rst,
                clk
                );


  output  [2:0] ftl_num;
  output        inc_dec_b;              // 1 = increment, 0 = decrement 

  input         cmmp_training_err;
  input         cmml_protocol_err_n;
  input         cmmt_err_rbuf_overflow;
  input         cmmt_err_fc;
  input         cmmt_err_tlp_malformed;
  input         decr_ftl;
  input         rst;
  input         clk;
 

  //******************************************************************//
  // Reality check.                                                   //
  //******************************************************************//

  parameter FFD       = 1;        // clock to out delay model


  //******************************************************************//
  // Figure out how many errors to increment.                         //
  //******************************************************************//


  reg     [2:0] to_incr;
  reg           add_sub_b;

  always @(cmmt_err_tlp_malformed or
           cmmp_training_err or 
           cmml_protocol_err_n or 
           cmmt_err_rbuf_overflow or cmmt_err_fc or 
           decr_ftl) begin
    case ({cmmt_err_tlp_malformed, cmml_protocol_err_n, cmmt_err_rbuf_overflow, cmmp_training_err, cmmt_err_fc, 
           decr_ftl})   // synthesis full_case parallel_case
    6'b000000: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b000001: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b000010: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b000011: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b000100: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b000101: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b000110: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b000111: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001000: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001001: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b001010: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b001011: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001100: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b001101: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b001110: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b001111: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b010000: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b010001: begin to_incr = 3'b001; add_sub_b = 1'b0; end
    6'b010010: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b010011: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b010100: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b010101: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b010110: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b010111: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011000: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011001: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b011010: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b011011: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011100: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b011101: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b011110: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b011111: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100000: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100001: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b100010: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b100011: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100100: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b100101: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b100110: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b100111: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101000: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101001: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b101010: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b101011: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101100: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b101101: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b101110: begin to_incr = 3'b101; add_sub_b = 1'b1; end
    6'b101111: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b110000: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b110001: begin to_incr = 3'b000; add_sub_b = 1'b1; end
    6'b110010: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b110011: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b110100: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b110101: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b110110: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b110111: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111000: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111001: begin to_incr = 3'b001; add_sub_b = 1'b1; end
    6'b111010: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b111011: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111100: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    6'b111101: begin to_incr = 3'b010; add_sub_b = 1'b1; end
    6'b111110: begin to_incr = 3'b100; add_sub_b = 1'b1; end
    6'b111111: begin to_incr = 3'b011; add_sub_b = 1'b1; end
    default:   begin to_incr = 3'b000; add_sub_b = 1'b1; end
    endcase
  end


  //******************************************************************//
  // Register the outputs.                                            //
  //******************************************************************//


  reg     [2:0] reg_ftl_num;
  reg           reg_inc_dec_b;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      reg_ftl_num   <= #FFD 3'b000;
      reg_inc_dec_b <= #FFD 1'b0;
    end
    else begin
      reg_ftl_num   <= #FFD to_incr;
      reg_inc_dec_b <= #FFD add_sub_b;
    end
  end

  assign ftl_num   = reg_ftl_num;
  assign inc_dec_b = reg_inc_dec_b;

endmodule

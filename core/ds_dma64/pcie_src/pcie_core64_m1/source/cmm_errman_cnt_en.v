
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
// File       : cmm_errman_cnt_en.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

/***********************************************************************

  Description:   
  This is the error counter module for tracking the outstanding
  correctible/fatal. When overflow or underflow occurs, it remains at   
  either full scale (overflow) or zero (underflow) instead of rolling   
  over.

***********************************************************************/

`ifndef FFD
  `define FFD 1
`endif


module cmm_errman_cnt_en (
                count,                  // Outputs

                index,                  // Inputs
                inc_dec_b,
                enable,
                rst,
                clk
                );


  output  [3:0] count;

  input   [2:0] index;       // ftl_num, nfl_num  or cor_num
  input         inc_dec_b;   // 1 = increment, 0 = decrement
  input         enable;      // err_*_en
  input         rst;
  input         clk;
 

  //******************************************************************//
  // Reality check.                                                   //
  //******************************************************************//

  parameter FFD       = 1;        // clock to out delay model


  //******************************************************************//
  // There are 2 pipeline stages to help timing.                      //
  // Stage 1: a simple add/subtract accumulator with no overflow or   //
  //          underflow check.                                        //
  // Stage 2: underflow, overflow and counter enable are handled.     //
  //******************************************************************//


  // Stage 1: count up or count down


  reg     [3:0] reg_cnt;
  reg           reg_extra;
  reg           reg_inc_dec_b;
  reg           reg_uflow;

  //wire    [3:0] cnt;
  reg     [3:0] cnt;
  wire          oflow;
  wire          uflow;

  always @(posedge clk or posedge rst) begin
    if (rst)              {reg_extra, reg_cnt} <= #`FFD 5'b00000;
    else if (~enable)     {reg_extra, reg_cnt} <= #`FFD 5'b00000;
    else if (inc_dec_b)   {reg_extra, reg_cnt} <= #`FFD cnt + index;
    else                  {reg_extra, reg_cnt} <= #`FFD cnt - index;
  end

  //assign cnt   = oflow ? 4'hF : (uflow ? 4'h0 : reg_cnt);
  always @(oflow or uflow or reg_cnt) begin  
    case ({oflow,uflow})    // synthesis full_case parallel_case
      2'b11: cnt = 4'hF;
      2'b10: cnt = 4'hF;
      2'b01: cnt = 4'h0;
      2'b00: cnt = reg_cnt;
    endcase
  end


  always @(posedge clk or posedge rst) begin
    if (rst)  reg_inc_dec_b <= #`FFD 1'b0;
    else      reg_inc_dec_b <= #`FFD inc_dec_b;
  end

  assign oflow = reg_extra & reg_inc_dec_b;


  always @(posedge clk or posedge rst) begin
    if (rst)
      reg_uflow <= #`FFD 1'b0;
    else
      //reg_uflow <= #`FFD (count == 4'b0000) & (index[2:0] != 3'b000) & ~inc_dec_b;
      reg_uflow <= #`FFD ~|count & |index[2:0] & ~inc_dec_b;
  end
    
  assign uflow = reg_uflow;


  // Stage 2: if overflow occurs, the counter is set to full scale;
  //          if underflow occurs, it is set to zero.
  //          if counter is not enable, it is set to zero.


  reg     [3:0] reg_count;

  always @(posedge clk or posedge rst) begin
    if (rst)            reg_count <= #`FFD 4'b0000;
    else if (~enable)   reg_count <= #`FFD 4'b0000;
    else if (oflow)     reg_count <= #`FFD 4'b1111;
    else if (uflow)     reg_count <= #`FFD 4'b0000;
    else                reg_count <= #`FFD cnt;
  end

  assign count = reg_count;


  //******************************************************************//
  //                                                                  //
  //******************************************************************//

endmodule

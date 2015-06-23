
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
// File       : cmm_errman_cpl.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------

/***********************************************************************

  Description: 
  
  This module figures out what to do for scheduling Cpl transactions:
    1) count up or count down,
    2) how much to add or to subtract,
    3) it counts the Cpl requested by TLM and USER separately.
  It returns the number and a add/subtract_b signals to the Cpl 
  tracking counter. The outputs are based on how many non-posted
  requests have been received by either the TLM or the user.

***********************************************************************/

module cmm_errman_cpl (
                cpl_num,               // Output
                inc_dec_b,

                cmm_err_tlp_posted,    // Inputs
                decr_cpl,
                rst,
                clk
                );


  output  [2:0] cpl_num;
  output        inc_dec_b;             // 1 = increment, 0 = decrement 

  input         cmm_err_tlp_posted;
  input         decr_cpl;
  input         rst;
  input         clk;
 

  //******************************************************************//
  // Reality check.                                                   //
  //******************************************************************//

  parameter FFD       = 1;        // clock to out delay model


  //******************************************************************//
  // Figure out how many errors to increment.                         //
  //******************************************************************//


  reg     [2:0] mod_to_incr;
  reg           mod_add_sub_b;


  always @(cmm_err_tlp_posted or decr_cpl)
  begin
    case ({cmm_err_tlp_posted, decr_cpl})   // synthesis full_case parallel_case
    2'b00:   begin   mod_to_incr   = 3'b000;
                     mod_add_sub_b = 1'b1;
             end
    2'b01:   begin   mod_to_incr   = 3'b001;
                     mod_add_sub_b = 1'b0;
             end
    2'b10:   begin   mod_to_incr   = 3'b001;
                     mod_add_sub_b = 1'b1;
             end
    2'b11:   begin   mod_to_incr   = 3'b000;
                     mod_add_sub_b = 1'b1;
             end
    default: begin   mod_to_incr   = 3'b000;
                     mod_add_sub_b = 1'b1;
             end
    endcase
  end


  //******************************************************************//
  // Register the outputs.                                            //
  //******************************************************************//


  reg     [2:0] reg_cpl_num;
  reg           reg_inc_dec_b;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      reg_cpl_num   <= #FFD 3'b000;
      reg_inc_dec_b <= #FFD 1'b0;
    end
    else
    begin
      reg_cpl_num   <= #FFD mod_to_incr;
      reg_inc_dec_b <= #FFD mod_add_sub_b;
    end
  end

  assign cpl_num   = reg_cpl_num;
  assign inc_dec_b = reg_inc_dec_b;


  //******************************************************************//
  //                                                                  //
  //******************************************************************//

endmodule


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
// File       : cmm_errman_ram8x26.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
/***********************************************************************

  Description: 

  This is the 4x50 dual port RAM for the header information of the
  outstanding Completion packets in the error manager.
  The RAM output is registered. 

***********************************************************************/


`define  FFD 1
module cmm_errman_ram8x26 (
                rddata,                 // Output

                wrdata,                 // Inputs
                wr_ptr,
                rd_ptr,
                we,
                rst,
                clk
                );


  output [49:0] rddata;

  input  [49:0] wrdata;
  input   [2:0] wr_ptr;
  input   [2:0] rd_ptr;

  input         we;
  input         rst;
  input         clk;
 

  //******************************************************************//
  // Reality check.                                                   //
  //******************************************************************//


  //******************************************************************//
  // Construct the RAM.                                               //
  //******************************************************************//

  reg    [49:0] lutram_data [0:7];

  always @(posedge clk) begin
    if (we)
      lutram_data[wr_ptr] <= #`FFD wrdata;
  end


  //******************************************************************//
  // Register the outputs.                                            //
  //******************************************************************//


  reg    [49:0] reg_rdata;


  always @(posedge clk or posedge rst)
  begin
    if (rst)  reg_rdata <= #`FFD 50'h0000_0000_0000;
    else      reg_rdata <= #`FFD lutram_data[rd_ptr];
  end

  assign rddata = reg_rdata;


  //******************************************************************//
  //                                                                  //
  //******************************************************************//

endmodule

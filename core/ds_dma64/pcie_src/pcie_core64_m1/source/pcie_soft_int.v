
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
// File       : pcie_soft_int.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: PCIe Interrupt Module Wrapper for Softcore CMM32 Interrupt
//--    module
//--
//--
//--
//------------------------------------------------------------------------------

`timescale 1ns/1ns

`ifndef Tcq
   `define Tcq 1
`endif

module pcie_soft_cf_int
(
       // Clock and reset

       input wire         clk,
       input wire         rst_n,




       input  wire        cs_is_intr,
       input  wire        grant,
       input  wire [31:0] cfg_msguaddr,

       // PCIe Block Interrupt Ports

       input  wire        msi_enable,
       output      [3:0]  msi_request,
       output wire        legacy_int_request,

       // LocalLink Interrupt Ports

       input  wire        cfg_interrupt_n,
       output wire        cfg_interrupt_rdy_n,


       // NEWINTERRUPT signals
       input wire          msi_8bit_en,

       input wire         cfg_interrupt_assert_n,
       input wire   [7:0] cfg_interrupt_di,
       output       [2:0] cfg_interrupt_mmenable,
       output       [7:0] cfg_interrupt_do,
       output             cfg_interrupt_msienable,
       input wire [31:0]  msi_laddr,
       input wire [31:0]  msi_haddr,

       input wire [15:0]  cfg_command,
       input wire [15:0]  cfg_msgctrl,
       input wire [15:0]  cfg_msgdata,

       // To Arb
       output wire        signaledint,
       output wire        intr_req_valid,
       output wire  [1:0] intr_req_type,
       output wire  [7:0] intr_vector
    
);


wire intr_rdy;



assign cfg_interrupt_rdy_n = ~intr_rdy;

assign cfg_interrupt_msienable = cfg_msgctrl[0]; // adr 0x48
assign legacy_int_request = 0;             // tied low to disable in block
                                           // legacy will be generated manually
assign msi_request = 4'd0;                 // tied low per ug197

assign cfg_interrupt_mmenable = cfg_msgctrl[6:4]; // MSI Cap Structure
assign cfg_interrupt_do = cfg_msgdata[7:0];       // MSI Message Data


// Interrupt controller from softcore
  cmm_intr u_cmm_intr (
      .clk                           (clk)
     ,.rst                           (~rst_n)
     ,.signaledint                   (signaledint)            // O
     ,.intr_req_valid                (intr_req_valid)         // O 
     ,.intr_req_type                 (intr_req_type)          // O [1:0]
     ,.intr_rdy                      (intr_rdy)    // O
     ,.cfg_interrupt_n               (cfg_interrupt_n)        // I [7:0]

     ,.cfg_interrupt_assert_n        (cfg_interrupt_assert_n) // I
     ,.cfg_interrupt_di              (cfg_interrupt_di)       // I [7:0]
     ,.cfg_interrupt_mmenable        (cfg_interrupt_mmenable) // I [2:0]
     //,.cfg_interrupt_mmenable        (3'b0) // I [2:0]
     ,.msi_data                      (cfg_msgdata)               // I[15:0]
     ,.intr_vector                   (intr_vector)            // O [7:0]
     ,.cfg                           ( {556'd0, msi_8bit_en ,467'd0} )            // I[1023:0] 

     ,.command                       (cfg_command)            // I [15:0]
     ,.msi_control                   (cfg_msgctrl)          // I [15:0]
     ,.msi_laddr                     (msi_laddr)              // I [31:0]
     ,.msi_haddr                     (msi_haddr)              // I [31:0]
     //,.intr_grant                    (grant)                  // I 
     ,.intr_grant                    (grant & cs_is_intr)                  // I 
        );








endmodule

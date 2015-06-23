
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
// File       : pcie_blk_cf_pwr.v
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
//--
//-- Description: PCIe Block Power Management Interface
//--
//--             
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif

module pcie_blk_cf_pwr
(
       // Clock and reset

       input              clk,
       input              rst_n,

       // User Interface Power Management Ports
       
       input              cfg_turnoff_ok_n,
       output reg         cfg_to_turnoff_n,

       input              cfg_pm_wake_n,


       // PCIe Block Power Management Ports

       input              l0_pwr_turn_off_req,

       output reg         l0_pme_req_in,
       input              l0_pme_ack,

       // Interface to arbiter
       output reg         send_pmeack,
       input              cs_is_pm,
       input              grant
); 

always @(posedge clk)
begin
  if (~rst_n) begin
    cfg_to_turnoff_n    <= #`TCQ 1;
    send_pmeack         <= #`TCQ 0;
    l0_pme_req_in       <= #`TCQ 0;
  end else begin
    //PME Turn Off message rec'd; inform user
    if (l0_pwr_turn_off_req)
      cfg_to_turnoff_n    <= #`TCQ 0;
    else if (~cfg_turnoff_ok_n)
      cfg_to_turnoff_n    <= #`TCQ 1;
    //User issues PME To ACK
    if (~cfg_turnoff_ok_n && ~cfg_to_turnoff_n)
      send_pmeack         <= #`TCQ 1;
    else if (cs_is_pm && grant)
      send_pmeack         <= #`TCQ 0;
    //Send a PM PME message
    if (~cfg_pm_wake_n)
      l0_pme_req_in       <= #`TCQ 1;
    else if (l0_pme_ack)
      l0_pme_req_in       <= #`TCQ 0;
  end
end

endmodule // pcie_blk_cf_pwr


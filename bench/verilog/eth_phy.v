//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name: eth_phy.v                                        ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/project,ethmac                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Tadej Markovic, tadej@opencores.org                   ////
////                                                              ////
////  All additional information is available in the README.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002  Authors                                  ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.7  2002/10/18 13:58:22  tadejm
// Some code changed due to bug fixes.
//
// Revision 1.6  2002/10/09 13:16:51  tadejm
// Just back-up; not completed testbench and some testcases are not
// wotking properly yet.
//
// Revision 1.5  2002/09/18 17:55:08  tadej
// Bug repaired in eth_phy device
//
// Revision 1.3  2002/09/13 14:50:15  mohor
// Bug in MIIM fixed.
//
// Revision 1.2  2002/09/13 12:29:14  mohor
// Headers changed.
//
// Revision 1.1  2002/09/13 11:57:20  mohor
// New testbench. Thanks to Tadej M - "The Spammer".
//
//
//

`include "timescale.v"
`include "eth_phy_defines.v"
`include "tb_eth_defines.v"
module eth_phy // This PHY model simulate simplified Intel LXT971A PHY
(
        // COMMON
        m_rst_n_i,

        // MAC TX
        mtx_clk_o,
        mtxd_i,
        mtxen_i,
        mtxerr_i,

        // MAC RX
        mrx_clk_o,
        mrxd_o,
        mrxdv_o,
        mrxerr_o,

        mcoll_o,
        mcrs_o,

        // MIIM
        mdc_i,
        md_io,

        // SYSTEM
        phy_log
);

//////////////////////////////////////////////////////////////////////
//
// Input/output signals
//
//////////////////////////////////////////////////////////////////////

// MAC miscellaneous signals
input           m_rst_n_i;
// MAC TX signals
output          mtx_clk_o;
input   [3:0]   mtxd_i;
input           mtxen_i;
input           mtxerr_i;
// MAC RX signals
output          mrx_clk_o;
output  [3:0]   mrxd_o;
output          mrxdv_o;
output          mrxerr_o;
// MAC common signals
output          mcoll_o;
output          mcrs_o;
// MAC management signals
input           mdc_i;
inout           md_io;
// SYSTEM
input   [31:0]  phy_log;


//////////////////////////////////////////////////////////////////////
//
// PHY management (MIIM) REGISTER definitions
//
//////////////////////////////////////////////////////////////////////
//
//   Supported registers:
//
// Addr | Register Name
//--------------------------------------------------------------------
//   0  | Control reg.     |
//   1  | Status reg. #1   |--> normal operation
//   2  | PHY ID reg. 1    |
//   3  | PHY ID reg. 2    |
//----------------------
// Addr | Data MEMORY      |-->  for testing
//
//--------------------------------------------------------------------
//
// Control register
reg            control_bit15; // self clearing bit
reg    [14:10] control_bit14_10;
reg            control_bit9; // self clearing bit
reg    [8:0]   control_bit8_0;
// Status register
wire   [15:9]  status_bit15_9 = `SUPPORTED_SPEED_AND_PORT;
wire           status_bit8    = `EXTENDED_STATUS;
wire           status_bit7    = 1'b0; // reserved
reg    [6:0]   status_bit6_0;
// PHY ID register 1
wire   [15:0]  phy_id1        = `PHY_ID1;
// PHY ID register 2
wire   [15:0]  phy_id2        = {`PHY_ID2, `MAN_MODEL_NUM, `MAN_REVISION_NUM};
//--------------------------------------------------------------------
//
// Data MEMORY
reg    [15:0]  data_mem [0:31]; // 32 locations of 16-bit data width
//
//////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////
//
// PHY clocks - RX & TX
//
//////////////////////////////////////////////////////////////////////

reg       mtx_clk_o;
reg       mrx_clk_o;

// random generator for a RX period when link is down
real      rx_link_down_halfperiod;

always@(status_bit6_0[2])
begin
  if (!status_bit6_0[2]) // Link is down
  begin
    #1 rx_link_down_halfperiod = ({$random} % 243) + 13;
    `ifdef VERBOSE
    #1 $fdisplay(phy_log, "   (%0t)(%m)MAC RX clock is %f MHz while ethernet link is down!", 
                 $time, (1000/(rx_link_down_halfperiod*2)) );
    `endif
  end
end

`ifdef VERBOSE
always@(status_bit6_0[2])
begin
  if (!status_bit6_0[2]) // Link is down
    #1 $fdisplay(phy_log, "   (%0t)(%m)Ethernet link is down!", $time);
  else
    #1 $fdisplay(phy_log, "   (%0t)(%m)Ethernet link is up!", $time);
end
`endif

// speed selection signal eth_speed: 1'b1 - 100 Mbps, 1'b0 - 10 Mbps
wire      eth_speed;

assign eth_speed = ( (control_bit14_10[13]) && !((`LED_CFG1) && (`LED_CFG2)) );

`ifdef VERBOSE
always@(eth_speed)
begin
  if (eth_speed)
    #1 $fdisplay(phy_log, "   (%0t)(%m)PHY configured to 100 Mbps!", $time);
  else
    #1 $fdisplay(phy_log, "   (%0t)(%m)PHY configured tp 10 Mbps!", $time);
end
`endif

// different clock calculation between RX and TX, so that there is alsways a litle difference
/*initial
begin
  set_mrx_equal_mtx = 1; // default
end*/

always
begin
  mtx_clk_o = 0;
  #7;
  forever
  begin
    if (eth_speed) // 100 Mbps - 25 MHz, 40 ns
    begin
      #20 mtx_clk_o = ~mtx_clk_o;
    end
    else // 10 Mbps - 2.5 MHz, 400 ns
    begin
      #200 mtx_clk_o = ~mtx_clk_o;
    end
  end
end

always
begin
  // EQUAL mrx_clk to mtx_clk
  mrx_clk_o = 0;
  #7;
  forever
  begin
    if (eth_speed) // 100 Mbps - 25 MHz, 40 ns
    begin
      #20 mrx_clk_o = ~mrx_clk_o;
    end
    else // 10 Mbps - 2.5 MHz, 400 ns
    begin
      #200 mrx_clk_o = ~mrx_clk_o;
    end
  end
  // DIFFERENT mrx_clk than mtx_clk
/*  mrx_clk_diff_than_mtx = 1;
  #3;
  forever
  begin
    if (status_bit6_0[2]) // Link is UP
    begin
      if (eth_speed) // 100 Mbps - 25 MHz, 40 ns
      begin
        //#(((1/0.025001)/2)) 
        #19.99 mrx_clk_diff_than_mtx = ~mrx_clk_diff_than_mtx; // period is calculated from frequency in GHz
      end
      else // 10 Mbps - 2.5 MHz, 400 ns
      begin
        //#(((1/0.0024999)/2)) 
        #200.01 mrx_clk_diff_than_mtx = ~mrx_clk_diff_than_mtx; // period is calculated from frequency in GHz
      end
    end
    else // Link is down
    begin
      #(rx_link_down_halfperiod) mrx_clk_diff_than_mtx = ~mrx_clk_diff_than_mtx; // random frequency between 2 MHz and 40 MHz
    end
  end*/
//  // set output mrx_clk
//  if (set_mrx_equal_mtx)
//    mrx_clk_o = mrx_clk_equal_to_mtx;
//  else
//    mrx_clk_o = mrx_clk_diff_than_mtx;
end

// set output mrx_clk
//assign mrx_clk_o = set_mrx_equal_mtx ? mrx_clk_equal_to_mtx : mrx_clk_diff_than_mtx ;

//////////////////////////////////////////////////////////////////////
//
// PHY management (MIIM) interface
//
//////////////////////////////////////////////////////////////////////
reg             respond_to_all_phy_addr; // PHY will respond to all phy addresses
reg             no_preamble; // PHY responds to frames without preamble

integer         md_transfer_cnt; // counter countes the value of whole data transfer
reg             md_transfer_cnt_reset; // for reseting the counter
reg             md_io_reg; // registered input
reg             md_io_output; // registered output
reg             md_io_rd_wr;  // op-code latched (read or write)
reg             md_io_enable; // output enable
reg     [4:0]   phy_address; // address of PHY device
reg     [4:0]   reg_address; // address of a register
reg             md_get_phy_address; // for shifting PHY address in
reg             md_get_reg_address; // for shifting register address in
reg     [15:0]  reg_data_in; // data to be written in a register
reg             md_get_reg_data_in; // for shifting data in
reg             md_put_reg_data_in; // for storing data into a selected register
reg     [15:0]  reg_data_out; // data to be read from a register
reg             md_put_reg_data_out; // for registering data from a selected register

wire    [15:0]  register_bus_in; // data bus to a selected register
reg     [15:0]  register_bus_out; // data bus from a selected register

initial
begin
  md_io_enable = 1'b0;
  respond_to_all_phy_addr = 1'b0;
  no_preamble = 1'b0;
end

// tristate output
assign #1 md_io = (m_rst_n_i && md_io_enable) ? md_io_output : 1'bz ;

// registering input
always@(posedge mdc_i or negedge m_rst_n_i)
begin
  if (!m_rst_n_i)
    md_io_reg <= #1 0;
  else
    md_io_reg <= #1 md_io;
end

// getting (shifting) PHY address, Register address and Data in
// putting Data out and shifting
always@(posedge mdc_i or negedge m_rst_n_i)
begin
  if (!m_rst_n_i)
  begin
    phy_address <= 0;
    reg_address <= 0;
    reg_data_in <= 0;
    reg_data_out <= 0;
    md_io_output <= 0;
  end
  else
  begin
    if (md_get_phy_address)
    begin
      phy_address[4:1] <= phy_address[3:0]; // correct address is `ETH_PHY_ADDR
      phy_address[0]   <= md_io;
    end
    if (md_get_reg_address)
    begin
      reg_address[4:1] <= reg_address[3:0];
      reg_address[0]   <= md_io;
    end
    if (md_get_reg_data_in)
    begin
      reg_data_in[15:1] <= reg_data_in[14:0];
      reg_data_in[0]    <= md_io;
    end
    if (md_put_reg_data_out)
    begin
      reg_data_out <= register_bus_out;
    end
    if (md_io_enable)
    begin
      md_io_output       <= reg_data_out[15];
      reg_data_out[15:1] <= reg_data_out[14:0];
      reg_data_out[0]    <= 1'b0;
    end
  end
end

assign #1 register_bus_in = reg_data_in; // md_put_reg_data_in - allows writing to a selected register

// counter for transfer to and from MIIM
always@(posedge mdc_i or negedge m_rst_n_i)
begin
  if (!m_rst_n_i)
  begin
    if (no_preamble)
      md_transfer_cnt <= 33;
    else
      md_transfer_cnt <= 1;
  end
  else
  begin
    if (md_transfer_cnt_reset)
    begin
      if (no_preamble)
        md_transfer_cnt <= 33;
      else
        md_transfer_cnt <= 1;
    end
    else if (md_transfer_cnt < 64)
    begin
      md_transfer_cnt <= md_transfer_cnt + 1'b1;
    end
    else
    begin
      if (no_preamble)
        md_transfer_cnt <= 33;
      else
        md_transfer_cnt <= 1;
    end
  end
end

// MIIM transfer control
always@(m_rst_n_i or md_transfer_cnt or md_io_reg or md_io_rd_wr or 
        phy_address or respond_to_all_phy_addr or no_preamble)
begin
  #1;
  while ((m_rst_n_i) && (md_transfer_cnt <= 64))
  begin
    // reset the signal - put registered data in the register (when write)
    // check preamble
    if (md_transfer_cnt < 33)
    begin
      #4 md_put_reg_data_in = 1'b0;
      if (md_io_reg !== 1'b1)
      begin
        #1 md_transfer_cnt_reset = 1'b1;
      end
      else
      begin
        #1 md_transfer_cnt_reset = 1'b0;
      end
    end

    // check start bits
    else if (md_transfer_cnt == 33)
    begin
      if (no_preamble)
      begin
        #4 md_put_reg_data_in = 1'b0;
        if (md_io_reg === 1'b0)
        begin
          #1 md_transfer_cnt_reset = 1'b0;
        end
        else
        begin
          #1 md_transfer_cnt_reset = 1'b1;
          //if ((md_io_reg !== 1'bz) && (md_io_reg !== 1'b1))
          if (md_io_reg !== 1'bz)
          begin
            // ERROR - start !
            `ifdef VERBOSE
            $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong first start bit (without preamble)", $time);
            `endif
            #10 $stop;
          end
        end
      end
      else // with preamble
      begin
        #4 ;
        `ifdef VERBOSE
        $fdisplay(phy_log, "   (%0t)(%m)MIIM - 32-bit preamble received", $time);
        `endif
        // check start bit only if md_transfer_cnt_reset is inactive, because if
        // preamble suppression was changed start bit should not be checked
        if ((md_io_reg !== 1'b0) && (md_transfer_cnt_reset == 1'b0))
        begin
          // ERROR - start !
          `ifdef VERBOSE
          $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong first start bit", $time);
          `endif
          #10 $stop;
        end
      end
    end

    else if (md_transfer_cnt == 34)
    begin
      #4;
      if (md_io_reg !== 1'b1)
      begin
        // ERROR - start !
        #1;
        `ifdef VERBOSE
        if (no_preamble)
          $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong second start bit (without preamble)", $time);
        else
          $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong second start bit", $time);
        `endif
        #10 $stop;
      end
      else
      begin
        `ifdef VERBOSE
        if (no_preamble)
          #1 $fdisplay(phy_log, "   (%0t)(%m)MIIM - 2 start bits received (without preamble)", $time);
        else
          #1 $fdisplay(phy_log, "   (%0t)(%m)MIIM - 2 start bits received", $time);
        `endif
      end
    end

    // register the op-code (rd / wr)
    else if (md_transfer_cnt == 35)
    begin
      #4;
      if (md_io_reg === 1'b1)
      begin
        #1 md_io_rd_wr = 1'b1;
      end
      else 
      begin
        #1 md_io_rd_wr = 1'b0;
      end
    end

    else if (md_transfer_cnt == 36)
    begin
      #4;
      if ((md_io_reg === 1'b0) && (md_io_rd_wr == 1'b1))
      begin
        #1 md_io_rd_wr = 1'b1; // reading from PHY registers
        `ifdef VERBOSE
        $fdisplay(phy_log, "   (%0t)(%m)MIIM - op-code for READING from registers", $time);
        `endif
      end
      else if ((md_io_reg === 1'b1) && (md_io_rd_wr == 1'b0))
      begin
        #1 md_io_rd_wr = 1'b0; // writing to PHY registers
        `ifdef VERBOSE
        $fdisplay(phy_log, "   (%0t)(%m)MIIM - op-code for WRITING to registers", $time);
        `endif
      end
      else
      begin
        // ERROR - wrong opcode !
        `ifdef VERBOSE
        #1 $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong OP-CODE", $time);
        `endif
        #10 $stop;
      end
    // set the signal - get PHY address
      begin
        #1 md_get_phy_address = 1'b1;
      end
    end

    // reset the signal - get PHY address
    else if (md_transfer_cnt == 41)
    begin
      #4 md_get_phy_address = 1'b0;
    // set the signal - get register address
      #1 md_get_reg_address = 1'b1;
    end

    // reset the signal - get register address
    // set the signal - put register data to output register
    else if (md_transfer_cnt == 46)
    begin
      #4 md_get_reg_address = 1'b0;
      #1 md_put_reg_data_out = 1'b1;
    end

    // reset the signal - put register data to output register
    // set the signal - enable md_io as output when read
    else if (md_transfer_cnt == 47)
    begin
      #4 md_put_reg_data_out = 1'b0;
      if (md_io_rd_wr) //read
      begin
        if (md_io_reg !== 1'bz)
        begin
          // ERROR - turn around !
          `ifdef VERBOSE
          #1 $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong turn-around cycle before reading data out", $time);
          `endif
          #10 $stop;
        end
        if ((phy_address === `ETH_PHY_ADDR) || respond_to_all_phy_addr) // check the PHY address
        begin
          #1 md_io_enable = 1'b1;
          `ifdef VERBOSE
          $fdisplay(phy_log, "   (%0t)(%m)MIIM - received correct PHY ADDRESS: %x", $time, phy_address);
          `endif
        end
        else
        begin
          `ifdef VERBOSE
          #1 $fdisplay(phy_log, "*W (%0t)(%m)MIIM - received different PHY ADDRESS: %x", $time, phy_address);
          `endif
        end
      end
      else // write
      begin
        #1 md_io_enable = 1'b0;
    // check turn around cycle when write on clock 47
        if (md_io_reg !== 1'b1) 
        begin
          // ERROR - turn around !
          `ifdef VERBOSE
          #1 $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong 1. turn-around cycle before writing data in", 
                       $time);
          `endif
          #10 $stop;
        end
      end
    end

    // set the signal - get register data in when write
    else if (md_transfer_cnt == 48)
    begin
      #4;
      if (!md_io_rd_wr) // write
      begin
        #1 md_get_reg_data_in = 1'b1;
    // check turn around cycle when write on clock 48
        if (md_io_reg !== 1'b0)
        begin
          // ERROR - turn around !
          `ifdef VERBOSE
          #1 $fdisplay(phy_log, "*E (%0t)(%m)MIIM - wrong 2. turn-around cycle before writing data in", 
                       $time);
          `endif
          #10 $stop;
        end
      end
      else // read
      begin
        #1 md_get_reg_data_in = 1'b0;
      end
    end

    // reset the signal - enable md_io as output when read
    // reset the signal - get register data in when write
    // set the signal - put registered data in the register when write
    else if (md_transfer_cnt == 64)
    begin
      #1 md_io_enable = 1'b0;
      #4 md_get_reg_data_in = 1'b0;
      if (!md_io_rd_wr) // write
      begin
        if ((phy_address === `ETH_PHY_ADDR) || respond_to_all_phy_addr) // check the PHY address
        begin
          #1 md_put_reg_data_in = 1'b1;
          `ifdef VERBOSE
          $fdisplay(phy_log, "   (%0t)(%m)MIIM - received correct PHY ADDRESS: %x", $time, phy_address);
          $fdisplay(phy_log, "   (%0t)(%m)MIIM - WRITING to register %x COMPLETED!", $time, reg_address);
          `endif
        end
        else
        begin
          `ifdef VERBOSE
          #1 $fdisplay(phy_log, "*W (%0t)(%m)MIIM - received different PHY ADDRESS: %x", $time, phy_address);
          $fdisplay(phy_log, "*W (%0t)(%m)MIIM - NO WRITING to register %x !", $time, reg_address);
          `endif
        end
      end
      else // read
      begin
        `ifdef VERBOSE
        if ((phy_address === `ETH_PHY_ADDR) || respond_to_all_phy_addr) // check the PHY address
          #1 $fdisplay(phy_log, "   (%0t)(%m)MIIM - READING from register %x COMPLETED!", 
                       $time, reg_address);
        else
          #1 $fdisplay(phy_log, "*W (%0t)(%m)MIIM - NO READING from register %x !", $time, reg_address);
        `endif
      end
    end

    // wait for one clock period
    @(posedge mdc_i)
      #1;
  end 
end

//====================================================================
//
// PHY management (MIIM) REGISTERS
//
//====================================================================
//
//   Supported registers (normal operation):
//
// Addr | Register Name 
//--------------------------------------------------------------------
//   0  | Control reg.  
//   1  | Status reg. #1 
//   2  | PHY ID reg. 1 
//   3  | PHY ID reg. 2 
//----------------------
// Addr | Data MEMORY      |-->  for testing
//
//--------------------------------------------------------------------
//
// Control register
//  reg            control_bit15; // self clearing bit
//  reg    [14:10] control_bit14_10;
//  reg            control_bit9; // self clearing bit
//  reg    [8:0]   control_bit8_0;
// Status register
//  wire   [15:9]  status_bit15_9 = `SUPPORTED_SPEED_AND_PORT;
//  wire           status_bit8    = `EXTENDED_STATUS;
//  wire           status_bit7    = 1'b0; // reserved
//  reg    [6:0]   status_bit6_0  = `DEFAULT_STATUS;
// PHY ID register 1
//  wire   [15:0]  phy_id1        = `PHY_ID1;
// PHY ID register 2
//  wire   [15:0]  phy_id2        = {`PHY_ID2, `MAN_MODEL_NUM, `MAN_REVISION_NUM};
//--------------------------------------------------------------------
//
// Data MEMORY
//  reg    [15:0]  data_mem [0:31]; // 32 locations of 16-bit data width
//
//====================================================================

//////////////////////////////////////////////////////////////////////
//
// PHY management (MIIM) REGISTER control
//
//////////////////////////////////////////////////////////////////////

// wholy writable registers for walking ONE's on data, phy and reg. addresses
reg     registers_addr_data_test_operation;

// Non writable status registers
initial // always
begin
  #1 status_bit6_0[6] = no_preamble;
  status_bit6_0[5] = 1'b0;
  status_bit6_0[3] = 1'b1;
  status_bit6_0[0] = 1'b1;
end
always@(posedge mrx_clk_o)
begin
  status_bit6_0[4] <= #1 1'b0;
  status_bit6_0[1] <= #1 1'b0;
end
initial
begin
  status_bit6_0[2] = 1'b1;
  registers_addr_data_test_operation = 0;
end

// Reading from a selected registers
always@(reg_address or registers_addr_data_test_operation or md_put_reg_data_out or
        control_bit15 or control_bit14_10 or control_bit9 or control_bit8_0 or 
        status_bit15_9 or status_bit8 or status_bit7 or status_bit6_0 or
        phy_id1 or phy_id2)
begin
  if (registers_addr_data_test_operation) // test operation
  begin
    if (md_put_reg_data_out) // read enable
    begin
      register_bus_out = #1 data_mem[reg_address];
    end
  end
  else // normal operation
  begin
    if (md_put_reg_data_out) // read enable
    begin
      case (reg_address)
      5'h0:    register_bus_out = #1 {control_bit15, control_bit14_10, control_bit9, control_bit8_0};
      5'h1:    register_bus_out = #1 {status_bit15_9, status_bit8, status_bit7, status_bit6_0};
      5'h2:    register_bus_out = #1 phy_id1;
      5'h3:    register_bus_out = #1 phy_id2;
      default: register_bus_out = #1 16'hDEAD;
      endcase
    end
  end
end

// Self clear control signals
reg    self_clear_d0;
reg    self_clear_d1;
reg    self_clear_d2;
reg    self_clear_d3;
// Self clearing control
always@(posedge mdc_i or negedge m_rst_n_i)
begin
  if (!m_rst_n_i)
  begin
    self_clear_d0    <= #1 0;
    self_clear_d1    <= #1 0;
    self_clear_d2    <= #1 0;
    self_clear_d3    <= #1 0;
  end
  else
  begin
    self_clear_d0    <= #1 md_put_reg_data_in;
    self_clear_d1    <= #1 self_clear_d0;
    self_clear_d2    <= #1 self_clear_d1;
    self_clear_d3    <= #1 self_clear_d2;
  end
end

// Writing to a selected register
always@(posedge mdc_i or negedge m_rst_n_i)
begin
  if ((!m_rst_n_i) || (control_bit15))
  begin
    if (!registers_addr_data_test_operation) // normal operation
    begin
      control_bit15    <= #1 0;
      control_bit14_10 <= #1 {1'b0, (`LED_CFG1 || `LED_CFG2), `LED_CFG1, 2'b0};
      control_bit9     <= #1 0;
      control_bit8_0   <= #1 {`LED_CFG3, 8'b0};
    end
  end
  else
  begin
    if (registers_addr_data_test_operation) // test operation
    begin
      if (md_put_reg_data_in)
      begin
        data_mem[reg_address] <= #1 register_bus_in[15:0];
      end
    end
    else // normal operation
    begin
      // bits that are normaly written
      if (md_put_reg_data_in)
      begin
        case (reg_address)
        5'h0: 
        begin
          control_bit14_10 <= #1 register_bus_in[14:10];
          control_bit8_0   <= #1 register_bus_in[8:0];
        end
        default:
        begin
        end
        endcase
      end
      // self cleared bits written
      if ((md_put_reg_data_in) && (reg_address == 5'h0))
      begin
        control_bit15 <= #1 register_bus_in[15];
        control_bit9  <= #1 register_bus_in[9];
      end
      else if (self_clear_d3) // self cleared bits cleared
      begin
        control_bit15 <= #1 1'b0;
        control_bit9  <= #1 1'b0;
      end
    end
  end
end

//////////////////////////////////////////////////////////////////////
//
// PHY <-> MAC control (RX and TX clocks are at the begining)
//
//////////////////////////////////////////////////////////////////////

// CARRIER SENSE & COLLISION

// MAC common signals
reg             mcoll_o;
reg             mcrs_o;
// Internal signals controling Carrier sense & Collision
  // MAC common signals generated when appropriate transfer
reg             mcrs_rx;
reg             mcrs_tx;
  // delayed mtxen_i signal for generating delayed tx carrier sense
reg             mtxen_d1;
reg             mtxen_d2;
reg             mtxen_d3;
reg             mtxen_d4;
reg             mtxen_d5;
reg             mtxen_d6;
  // collision signal set or rest within task for controling collision
reg             task_mcoll;
  // carrier sense signal set or rest within task for controling carrier sense
reg             task_mcrs;
reg             task_mcrs_lost;
  // do not generate collision in half duplex - not normal operation
reg             no_collision_in_half_duplex;
  // generate collision in full-duplex mode also - not normal operation
reg             collision_in_full_duplex;
  // do not generate carrier sense in half duplex mode - not normal operation
reg             no_carrier_sense_in_tx_half_duplex;
reg             no_carrier_sense_in_rx_half_duplex;
  // generate carrier sense during TX in full-duplex mode also - not normal operation
reg             carrier_sense_in_tx_full_duplex;
  // do not generate carrier sense during RX in full-duplex mode - not normal operation
reg             no_carrier_sense_in_rx_full_duplex;
  // on RX: delay after carrier sense signal; on TX: carrier sense delayed (delay is one clock period)
reg             real_carrier_sense;

initial
begin
  mcrs_rx = 0;
  mcrs_tx = 0;
  task_mcoll = 0;
  task_mcrs = 0;
  task_mcrs_lost = 0;
  no_collision_in_half_duplex = 0;
  collision_in_full_duplex = 0;
  no_carrier_sense_in_tx_half_duplex = 0;
  no_carrier_sense_in_rx_half_duplex = 0;
  carrier_sense_in_tx_full_duplex = 0;
  no_carrier_sense_in_rx_full_duplex = 0;
  real_carrier_sense = 0;
end

// Collision
always@(m_rst_n_i or control_bit8_0 or collision_in_full_duplex or 
        mcrs_rx or mcrs_tx or task_mcoll or no_collision_in_half_duplex
        )
begin
  if (!m_rst_n_i)
    mcoll_o = 0;
  else
  begin
    if (control_bit8_0[8]) // full duplex
    begin
      if (collision_in_full_duplex) // collision is usually not asserted in full duplex
      begin
        mcoll_o = ((mcrs_rx && mcrs_tx) || task_mcoll);
        `ifdef VERBOSE
        if (mcrs_rx && mcrs_tx)
          $fdisplay(phy_log, "   (%0t)(%m) Collision set in FullDuplex!", $time);
        if (task_mcoll)
          $fdisplay(phy_log, "   (%0t)(%m) Collision set in FullDuplex from TASK!", $time);
        `endif
      end
      else
      begin
        mcoll_o = task_mcoll;
        `ifdef VERBOSE
        if (task_mcoll)
          $fdisplay(phy_log, "   (%0t)(%m) Collision set in FullDuplex from TASK!", $time);
        `endif
      end
    end
    else // half duplex
    begin
      mcoll_o = ((mcrs_rx && mcrs_tx && !no_collision_in_half_duplex) || 
                  task_mcoll);
      `ifdef VERBOSE
      if (mcrs_rx && mcrs_tx)
        $fdisplay(phy_log, "   (%0t)(%m) Collision set in HalfDuplex!", $time);
      if (task_mcoll)
        $fdisplay(phy_log, "   (%0t)(%m) Collision set in HalfDuplex from TASK!", $time);
      `endif
    end
  end
end

// Carrier sense
always@(m_rst_n_i or control_bit8_0 or carrier_sense_in_tx_full_duplex or
        no_carrier_sense_in_rx_full_duplex or
        no_carrier_sense_in_tx_half_duplex or 
        no_carrier_sense_in_rx_half_duplex or 
        mcrs_rx or mcrs_tx or task_mcrs or task_mcrs_lost
        )
begin
  if (!m_rst_n_i)
    mcrs_o = 0;
  else
  begin
    if (control_bit8_0[8]) // full duplex
    begin
      if (carrier_sense_in_tx_full_duplex) // carrier sense is usually not asserted during TX in full duplex
        mcrs_o = ((mcrs_rx && !no_carrier_sense_in_rx_full_duplex) || 
                   mcrs_tx || task_mcrs) && !task_mcrs_lost;
      else
        mcrs_o = ((mcrs_rx && !no_carrier_sense_in_rx_full_duplex) || 
                   task_mcrs) && !task_mcrs_lost;
    end
    else // half duplex
    begin
      mcrs_o = ((mcrs_rx && !no_carrier_sense_in_rx_half_duplex) || 
                (mcrs_tx && !no_carrier_sense_in_tx_half_duplex) || 
                 task_mcrs) && !task_mcrs_lost;
    end
  end
end

// MAC TX CONTROL (RECEIVING AT PHY)

// storage memory for TX data received from MAC
reg     [7:0]  tx_mem [0:4194303]; // 4194304 locations (22 address lines) of 8-bit data width
reg    [31:0]  tx_mem_addr_in; // address for storing to TX memory
reg     [7:0]  tx_mem_data_in; // data for storing to TX memory
reg    [31:0]  tx_cnt; // counts nibbles

// control data of a TX packet for upper layer of testbench
reg            tx_preamble_ok;
reg            tx_sfd_ok;
// if there is a drible nibble, then tx packet is not byte aligned!
reg            tx_byte_aligned_ok;
// complete length of TX packet (Bytes) received (without preamble and SFD)
reg    [31:0]  tx_len;
// complete length of TX packet (Bytes) received (without preamble and SFD) untill MTxErr signal was set first
reg    [31:0]  tx_len_err;

// TX control
always@(posedge mtx_clk_o)
begin
  // storing data and basic checking of frame
  if (!m_rst_n_i)
  begin
    tx_cnt <= 0;
    tx_preamble_ok <= 0;
    tx_sfd_ok <= 0;
    tx_len <= 0;
    tx_len_err <= 0;
  end
  else
  begin
    if (!mtxen_i)
    begin
      tx_cnt <= 0;
    end
    else
    begin
      // tx nibble counter
      tx_cnt <= tx_cnt + 1;
      // set initial values and check first preamble nibble
      if (tx_cnt == 0)
      begin
        `ifdef VERBOSE
        $fdisplay(phy_log, "   (%0t)(%m) TX frame started with tx_en set!", $time);
        `endif
        if (mtxd_i == 4'h5)
          tx_preamble_ok <= 1;
        else
          tx_preamble_ok <= 0;
        tx_sfd_ok <= 0;
        tx_byte_aligned_ok <= 0;
        tx_len <= 0;
        tx_len_err <= 0;
//        tx_mem_addr_in <= 0;
      end

      // check preamble
      if ((tx_cnt > 0) && (tx_cnt <= 13))
      begin
        if ((tx_preamble_ok != 1) || (mtxd_i != 4'h5))
          tx_preamble_ok <= 0;
      end
      // check SFD
      if (tx_cnt == 14)
      begin
        `ifdef VERBOSE
        if (tx_preamble_ok == 1)
          $fdisplay(phy_log, "   (%0t)(%m) TX frame preamble OK!", $time);
        else
          $fdisplay(phy_log, "*E (%0t)(%m) TX frame preamble NOT OK!", $time);
        `endif
        if (mtxd_i == 4'h5)
          tx_sfd_ok <= 1;
        else
          tx_sfd_ok <= 0;
      end
      if (tx_cnt == 15)
      begin
        if ((tx_sfd_ok != 1) || (mtxd_i != 4'hD))
          tx_sfd_ok <= 0;
      end

      // control for storing addresses, type/length, data and FCS to TX memory
      if (tx_cnt > 15)
      begin
        if (tx_cnt == 16)
        begin
          `ifdef VERBOSE
          if (tx_sfd_ok == 1)
            $fdisplay(phy_log, "   (%0t)(%m) TX frame SFD OK!", $time);
          else
            $fdisplay(phy_log, "*E (%0t)(%m) TX frame SFD NOT OK!", $time);
          `endif
        end

        if (tx_cnt[0] == 0)
        begin
          tx_mem_data_in[3:0] <= mtxd_i; // storing LSB nibble
          tx_byte_aligned_ok <= 0; // if transfer will stop after this, then there was drible nibble
        end
        else
        begin
          tx_mem[tx_mem_addr_in[21:0]] <= {mtxd_i, tx_mem_data_in[3:0]}; // storing data into tx memory
          tx_len <= tx_len + 1; // enlarge byte length counter
          tx_byte_aligned_ok <= 1; // if transfer will stop after this, then transfer is byte alligned
          tx_mem_addr_in <= tx_mem_addr_in + 1'b1;
        end

        if (mtxerr_i)
          tx_len_err <= tx_len;
      end
    end
  end

  // generating CARRIER SENSE for TX with or without delay
  if (!m_rst_n_i)
  begin
    mcrs_tx  <= 0;
    mtxen_d1 <= 0;
    mtxen_d2 <= 0;
    mtxen_d3 <= 0;
    mtxen_d4 <= 0;
    mtxen_d5 <= 0;
    mtxen_d6 <= 0;
  end
  else
  begin
    mtxen_d1 <= mtxen_i;
    mtxen_d2 <= mtxen_d1;
    mtxen_d3 <= mtxen_d2;
    mtxen_d4 <= mtxen_d3;
    mtxen_d5 <= mtxen_d4;
    mtxen_d6 <= mtxen_d5;
    if (real_carrier_sense)
      mcrs_tx  <= mtxen_d6;
    else
      mcrs_tx  <= mtxen_i;
  end
end

`ifdef VERBOSE
reg             frame_started;

initial
begin
  frame_started = 0;
end
always@(posedge mtxen_i)
begin
  frame_started <= 1;
end
always@(negedge mtxen_i)
begin
  if (frame_started)
  begin
    $fdisplay(phy_log, "   (%0t)(%m) TX frame ended with tx_en reset!", $time);
    frame_started <= 0;
  end
end

always@(posedge mrxerr_o)
begin
  $fdisplay(phy_log, "   (%0t)(%m) RX frame ERROR signal was set!", $time);
end
`endif

//////////////////////////////////////////////////////////////////////
// 
// Tasks for PHY <-> MAC transactions
// 
//////////////////////////////////////////////////////////////////////

initial
begin
  tx_mem_addr_in = 0;
end

// setting the address of tx_mem, to set the starting point of tx packet
task set_tx_mem_addr;
  input [31:0] tx_mem_address;
begin
  #1 tx_mem_addr_in = tx_mem_address;
end
endtask // set_tx_mem_addr

// storage memory for RX data to be transmited to MAC
reg     [7:0]  rx_mem [0:4194303]; // 4194304 locations (22 address lines) of 8-bit data width

// MAC RX signals
reg     [3:0]   mrxd_o;
reg             mrxdv_o;
reg             mrxerr_o;

initial
begin
  mrxd_o = 0;
  mrxdv_o = 0;
  mrxerr_o = 0;
  mcrs_rx = 0;
end

task send_rx_packet;
  input  [(8*8)-1:0] preamble_data; // preamble data to be sent - correct is 64'h0055_5555_5555_5555
  input   [3:0] preamble_len; // length of preamble in bytes - max is 4'h8, correct is 4'h7 
  input   [7:0] sfd_data; // SFD data to be sent - correct is 8'hD5
  input  [31:0] start_addr; // start address
  input  [31:0] len; // length of frame in Bytes (without preamble and SFD)
  input         plus_drible_nibble; // if length is longer for one nibble
  integer       rx_cnt;
  reg    [31:0] rx_mem_addr_in; // address for reading from RX memory       
  reg     [7:0] rx_mem_data_out; // data for reading from RX memory
begin
      @(posedge mrx_clk_o);
      // generating CARRIER SENSE for TX with or without delay
      if (real_carrier_sense)
        #1 mcrs_rx = 1;
      else
        #1 mcrs_rx = 0;
      @(posedge mrx_clk_o);
      #1 mcrs_rx = 1;
      #1 mrxdv_o = 1;
      `ifdef VERBOSE
      $fdisplay(phy_log, "   (%0t)(%m) RX frame started with rx_dv set!", $time);
      `endif
      // set initial rx memory address
      rx_mem_addr_in = start_addr;
    
      // send preamble
      for (rx_cnt = 0; (rx_cnt < (preamble_len << 1)) && (rx_cnt < 16); rx_cnt = rx_cnt + 1)
      begin
        #1 mrxd_o = preamble_data[3:0];
        #1 preamble_data = preamble_data >> 4;
        @(posedge mrx_clk_o);
      end
    
      // send SFD
      for (rx_cnt = 0; rx_cnt < 2; rx_cnt = rx_cnt + 1)
      begin
        #1 mrxd_o = sfd_data[3:0];
        #1 sfd_data = sfd_data >> 4;
        @(posedge mrx_clk_o);
      end
      `ifdef VERBOSE
      $fdisplay(phy_log, "   (%0t)(%m) RX frame preamble and SFD sent!", $time);
      `endif
      // send packet's addresses, type/length, data and FCS
      for (rx_cnt = 0; rx_cnt < len; rx_cnt = rx_cnt + 1)
      begin
        #1;
        rx_mem_data_out = rx_mem[rx_mem_addr_in[21:0]];
        mrxd_o = rx_mem_data_out[3:0];
        @(posedge mrx_clk_o);
        #1;
        mrxd_o = rx_mem_data_out[7:4];
        rx_mem_addr_in = rx_mem_addr_in + 1;
        @(posedge mrx_clk_o);
        #1;
      end
      if (plus_drible_nibble)
      begin
        rx_mem_data_out = rx_mem[rx_mem_addr_in[21:0]];
        mrxd_o = rx_mem_data_out[3:0];
        @(posedge mrx_clk_o);
      end
      `ifdef VERBOSE
      $fdisplay(phy_log, "   (%0t)(%m) RX frame addresses, type/length, data and FCS sent!", $time);
      `endif
      #1 mcrs_rx = 0;
      #1 mrxdv_o = 0;
      @(posedge mrx_clk_o);
      `ifdef VERBOSE
      $fdisplay(phy_log, "   (%0t)(%m) RX frame ended with rx_dv reset!", $time);
      `endif
end
endtask // send_rx_packet



task GetDataOnMRxD;
  input [15:0] Len;
  input [31:0] TransferType;
  integer tt;

  begin
    @ (posedge mrx_clk_o);
    #1 mrxdv_o=1'b1;

    for(tt=0; tt<15; tt=tt+1)
    begin
      mrxd_o=4'h5;              // preamble
      @ (posedge mrx_clk_o);
      #1;
    end

    mrxd_o=4'hd;                // SFD

    for(tt=1; tt<(Len+1); tt=tt+1)
    begin
      @ (posedge mrx_clk_o);
      #1;
      if(TransferType == `UNICAST_XFR && tt == 1)
        mrxd_o = 4'h0;   // Unicast transfer
      else if(TransferType == `BROADCAST_XFR && tt < 7)
        mrxd_o = 4'hf;
      else
        mrxd_o = tt[3:0]; // Multicast transfer

      @ (posedge mrx_clk_o);
      #1;

      if(TransferType == `BROADCAST_XFR && tt == 6)
        mrxd_o = 4'he;
      else

      if(TransferType == `BROADCAST_XFR && tt < 7)
        mrxd_o = 4'hf;
      else
        mrxd_o = tt[7:4];
    end

    @ (posedge mrx_clk_o);
    #1;
    mrxdv_o = 1'b0;
  end
endtask // GetDataOnMRxD


//////////////////////////////////////////////////////////////////////
//
// Tastks for controling PHY statuses and rx error
//
//////////////////////////////////////////////////////////////////////

// Link control tasks
task link_up_down;
  input   test_op;
begin
  #1 status_bit6_0[2] = test_op; // 1 - link up; 0 - link down
end
endtask

// RX error
task rx_err;
  input   test_op;
begin
  #1 mrxerr_o = test_op; // 1 - RX error set; 0 - RX error reset
end
endtask

//////////////////////////////////////////////////////////////////////
//
// Tastks for controling PHY carrier sense and collision
//
//////////////////////////////////////////////////////////////////////

// Collision
task collision;
  input   test_op;
begin
  #1 task_mcoll = test_op;
end
endtask

// Carrier sense
task carrier_sense;
  input   test_op;
begin
  #1 task_mcrs = test_op;
end
endtask

// Carrier sense lost - higher priority than Carrier sense task
task carrier_sense_lost;
  input   test_op;
begin
  #1 task_mcrs_lost = test_op;
end
endtask

// No collision detection in half duplex
task no_collision_hd_detect;
  input   test_op;
begin
  #1 no_collision_in_half_duplex = test_op;
end
endtask

// Collision detection in full duplex also
task collision_fd_detect;
  input   test_op;
begin
  #1 collision_in_full_duplex = test_op;
end
endtask

// No carrier sense detection at TX in half duplex
task no_carrier_sense_tx_hd_detect;
  input   test_op;
begin
  #1 no_carrier_sense_in_tx_half_duplex = test_op;
end
endtask

// No carrier sense detection at RX in half duplex
task no_carrier_sense_rx_hd_detect;
  input   test_op;
begin
  #1 no_carrier_sense_in_rx_half_duplex = test_op;
end
endtask

// Carrier sense detection at TX in full duplex also
task carrier_sense_tx_fd_detect;
  input   test_op;
begin
  #1 carrier_sense_in_tx_full_duplex = test_op;
end
endtask

// No carrier sense detection at RX in full duplex
task no_carrier_sense_rx_fd_detect;
  input   test_op;
begin
  #1 no_carrier_sense_in_rx_full_duplex = test_op;
end
endtask

// Set real delay on carrier sense signal (and therefor collision signal)
task carrier_sense_real_delay;
  input   test_op;
begin
  #1 real_carrier_sense = test_op;
end
endtask

//////////////////////////////////////////////////////////////////////
//
// Tastks for controling PHY management test operation
//
//////////////////////////////////////////////////////////////////////

// Set registers to test operation and respond to all phy addresses
task test_regs;
  input   test_op;
begin
  #1 registers_addr_data_test_operation = test_op;
  respond_to_all_phy_addr = test_op;
end
endtask

// Clears data memory for testing the MII
task clear_test_regs;
  integer i;
begin
  for (i = 0; i < 32; i = i + 1)
  begin
    #1 data_mem[i] = 16'h0;
  end
end
endtask

// Accept frames with preamble suppresed
task preamble_suppresed;
  input   test_op;
begin
  #1 no_preamble = test_op;
  md_transfer_cnt_reset = 1'b1;
  @(posedge mdc_i);
  #1 md_transfer_cnt_reset = 1'b0;
end
endtask





endmodule


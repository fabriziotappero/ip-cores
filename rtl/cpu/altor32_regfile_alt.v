//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.1
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "altor32_defs.v"

//-----------------------------------------------------------------
// Module - Altera LPM register file
//-----------------------------------------------------------------
module altor32_regfile_alt
(
    input               clk_i       /*verilator public*/,
    input               rst_i       /*verilator public*/,
    input               wr_i        /*verilator public*/,
    input [4:0]         ra_i        /*verilator public*/,
    input [4:0]         rb_i        /*verilator public*/,
    input [4:0]         rd_i        /*verilator public*/,
    output reg [31:0]   reg_ra_o    /*verilator public*/,
    output reg [31:0]   reg_rb_o    /*verilator public*/,
    input [31:0]        reg_rd_i    /*verilator public*/
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter       SUPPORT_32REGS = "ENABLED";

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
wire            clk_delayed_w;
wire [31:0]     reg_ra_w;
wire [31:0]     reg_rb_w;
wire            write_enable_w;

reg [4:0]       addr_q;
reg [31:0]      data_q;

wire [31:0]     ra_w;
wire [31:0]     rb_w;

//-----------------------------------------------------------------
// Sync addr & data
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i)
   begin
        addr_q <= 5'b00000;
        data_q <= 32'h00000000;

   end
   else
   begin
        addr_q <= rd_i;
        data_q <= reg_rd_i;
   end
end

//-----------------------------------------------------------------
// Register File (using lpm_ram_dp)
// Unfortunatly, LPM_RAM_DP primitives have synchronous read ports.
// As this core requires asynchronous/non-registered read ports,
// we have to invert the readclock edge to get close to what we
// require.
// This will have negative timing implications!
//-----------------------------------------------------------------
lpm_ram_dp
#(
    .lpm_width(32),
    .lpm_widthad(5),
    .lpm_indata("REGISTERED"),
    .lpm_outdata("UNREGISTERED"),
    .lpm_rdaddress_control("REGISTERED"),
    .lpm_wraddress_control("REGISTERED"),
    .lpm_file("UNUSED"),
    .lpm_type("lpm_ram_dp"),
    .lpm_hint("UNUSED")
)
lpm1
(
    .rdclock(clk_delayed_w),
    .rdclken(1'b1),
    .rdaddress(ra_i),
    .rden(1'b1),
    .data(reg_rd_i),
    .wraddress(rd_i),
    .wren(write_enable_w),
    .wrclock(clk_i),
    .wrclken(1'b1),
    .q(ra_w)
);


lpm_ram_dp
#(
    .lpm_width(32),
    .lpm_widthad(5),
    .lpm_indata("REGISTERED"),
    .lpm_outdata("UNREGISTERED"),
    .lpm_rdaddress_control("REGISTERED"),
    .lpm_wraddress_control("REGISTERED"),
    .lpm_file("UNUSED"),
    .lpm_type("lpm_ram_dp"),
    .lpm_hint("UNUSED")
)
lpm2
(
    .rdclock(clk_delayed_w),
    .rdclken(1'b1),
    .rdaddress(rb_i),
    .rden(1'b1),
    .data(reg_rd_i),
    .wraddress(rd_i),
    .wren(write_enable_w),
    .wrclock(clk_i),
    .wrclken(1'b1),
    .q(rb_w)
);

//-----------------------------------------------------------------
// Combinatorial Assignments
//-----------------------------------------------------------------

// Delayed clock
assign clk_delayed_w  = !clk_i;

// Register read ports
always @ *
begin
    if (ra_i == 5'b00000)
        reg_ra_o = 32'h00000000;
    else
        reg_ra_o = reg_ra_w;

    if (rb_i == 5'b00000)
        reg_rb_o = 32'h00000000;
    else
        reg_rb_o = reg_rb_w;
end

assign write_enable_w = (rd_i != 5'b00000) & wr_i;

// Reads are bypassed during write-back
assign reg_ra_w    = (ra_i != addr_q) ? ra_w : data_q;
assign reg_rb_w    = (rb_i != addr_q) ? rb_w : data_q;

endmodule

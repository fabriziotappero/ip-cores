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
// Module - Xilinx register file (async read)
//-----------------------------------------------------------------
module altor32_regfile_xil
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
// Registers / Wires
//-----------------------------------------------------------------
wire [31:0]     reg_ra_w;
wire [31:0]     reg_rb_w;
wire [31:0]     ra_0_15_w;
wire [31:0]     ra_16_31_w;
wire [31:0]     rb_0_15_w;
wire [31:0]     rb_16_31_w;
wire            write_enable_w;
wire            write_banka_w;
wire            write_bankb_w;

//-----------------------------------------------------------------
// Register File (using RAM16X1D )
//-----------------------------------------------------------------

// Registers 0 - 15
generate
begin
   genvar i;
   for (i=0;i<32;i=i+1)
   begin : reg_loop1
       RAM16X1D reg_bit1a(.WCLK(clk_i), .WE(write_banka_w), .A0(rd_i[0]), .A1(rd_i[1]), .A2(rd_i[2]), .A3(rd_i[3]), .D(reg_rd_i[i]), .DPRA0(ra_i[0]), .DPRA1(ra_i[1]), .DPRA2(ra_i[2]), .DPRA3(ra_i[3]), .DPO(ra_0_15_w[i]), .SPO(/* open */));
       RAM16X1D reg_bit2a(.WCLK(clk_i), .WE(write_banka_w), .A0(rd_i[0]), .A1(rd_i[1]), .A2(rd_i[2]), .A3(rd_i[3]), .D(reg_rd_i[i]), .DPRA0(rb_i[0]), .DPRA1(rb_i[1]), .DPRA2(rb_i[2]), .DPRA3(rb_i[3]), .DPO(rb_0_15_w[i]), .SPO(/* open */));
   end
end
endgenerate

// Registers 16 - 31
generate
if (SUPPORT_32REGS == "ENABLED")
begin
   genvar i;
   for (i=0;i<32;i=i+1)
   begin : reg_loop2
       RAM16X1D reg_bit1b(.WCLK(clk_i), .WE(write_bankb_w), .A0(rd_i[0]), .A1(rd_i[1]), .A2(rd_i[2]), .A3(rd_i[3]), .D(reg_rd_i[i]), .DPRA0(ra_i[0]), .DPRA1(ra_i[1]), .DPRA2(ra_i[2]), .DPRA3(ra_i[3]), .DPO(ra_16_31_w[i]), .SPO(/* open */));
       RAM16X1D reg_bit2b(.WCLK(clk_i), .WE(write_bankb_w), .A0(rd_i[0]), .A1(rd_i[1]), .A2(rd_i[2]), .A3(rd_i[3]), .D(reg_rd_i[i]), .DPRA0(rb_i[0]), .DPRA1(rb_i[1]), .DPRA2(rb_i[2]), .DPRA3(rb_i[3]), .DPO(rb_16_31_w[i]), .SPO(/* open */));
   end
end
else
begin
    assign ra_16_31_w = 32'h00000000;
    assign rb_16_31_w = 32'h00000000;
end
endgenerate

//-----------------------------------------------------------------
// Combinatorial Assignments
//-----------------------------------------------------------------
assign reg_ra_w       = (ra_i[4] == 1'b0) ? ra_0_15_w : ra_16_31_w;
assign reg_rb_w       = (rb_i[4] == 1'b0) ? rb_0_15_w : rb_16_31_w;

assign write_enable_w = (rd_i != 5'b00000) & wr_i;

assign write_banka_w  = (write_enable_w & (~rd_i[4]));
assign write_bankb_w  = (write_enable_w & rd_i[4]);

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

endmodule

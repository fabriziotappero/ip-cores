//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Simple Small VGA IP Core                                    ////
////                                                              ////
////  This file is part of the Simple Small VGA project           ////
////                                                              ////
////                                                              ////
////  Description                                                 ////
////  Hsync/Vsync generator.                                      ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
//

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

`include "ssvga_defines.v"

module ssvga_crtc(
	crt_clk, rst, hsync, vsync, hblank, vblank
);

//
// I/O ports
//
input				crt_clk;// Pixel Clock
input				rst;	// Reset
output				hsync;	// H sync
output				vsync;	// V sync
output				hblank;	// H blank
output				vblank;	// V blank

//
// Internal wires and regs
//
reg	[`SSVGA_HCW-1:0]	hcntr;	// Horizontal counter
reg	[`SSVGA_VCW-1:0]	vcntr;	// Vertical counter
reg				hsync;	// Horizontal sync
reg				vsync;	// Vertical sync

// flip - flops for decoding end of one line
reg line_end1 ;
reg line_end2 ;

always@(posedge crt_clk or posedge rst)
begin
    if (rst)
    begin
        line_end1 <= #1 1'b0 ;
        line_end2 <= #1 1'b0 ;
    end
    else
    begin
        line_end1 <= #1 hsync ;
        line_end2 <= #1 line_end1 ;
    end
end

wire line_end = ~line_end2 && line_end1 ;

//
// Assert hblank when hsync is not asserted
//
reg hblank ;
always@(posedge crt_clk or posedge rst)
begin
    if (rst)
        hblank <= #1 1'b0 ;
    else
    if ( hcntr == (`SSVGA_HPULSE + `SSVGA_HBACKP) )
        hblank <= #1 1'b0 ;
    else
    if ( hcntr == (`SSVGA_HTOT - `SSVGA_HFRONTP) )
        hblank <= #1 1'b1 ;
end

reg vblank ;
always@(posedge crt_clk or posedge rst)
begin
    if ( rst )
        vblank <= #1 1'b0 ;
    else
    if ((vcntr == (`SSVGA_VPULSE + `SSVGA_VBACKP)) && line_end)
        vblank <= #1 1'b0 ;
    else
    if ((vcntr == (`SSVGA_VTOT - `SSVGA_VFRONTP)) && line_end)
        vblank <= #1 1'b1 ;
end

//
// Horizontal counter
//
always @(posedge crt_clk or posedge rst)
		if (rst)
			hcntr <= #1 `SSVGA_HCW'h0;
		else if (hcntr == `SSVGA_HTOT - 1)
			hcntr <= #1 `SSVGA_HCW'h0;
		else
			hcntr <= #1 hcntr + 1;
//
// Horizontal sync
//
always @(posedge crt_clk or posedge rst)
		if (rst)
			hsync <= #1 1'b0;
		else if (hcntr == `SSVGA_HCW'h0)
			hsync <= #1 1'b1;
		else if (hcntr == `SSVGA_HPULSE)
			hsync <= #1 1'b0 ;

//
// Vertical counter
//
always @(posedge crt_clk or posedge rst)
		if (rst)
			vcntr <= #1 `SSVGA_VCW'h0;
		else if ((vcntr == `SSVGA_VTOT - 1) && line_end)
			vcntr <= #1 `SSVGA_VCW'h0;
		else if ( line_end )
			vcntr <= #1 vcntr + 1;
//
// Vertical sync
//
always @(posedge crt_clk or posedge rst)
		if (rst)
			vsync <= #1 1'b0;
		else if ((vcntr == `SSVGA_VCW'd0) && line_end)
			vsync <= #1 1'b1;
		else if ((vcntr == `SSVGA_VPULSE) && line_end)
			vsync <= #1 1'b0;
endmodule

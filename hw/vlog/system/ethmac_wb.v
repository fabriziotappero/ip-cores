//////////////////////////////////////////////////////////////////
//                                                              //
//  Ethmac module Wishbone bus width and endian switch          //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Arbitrates between two wishbone masters and 13 wishbone     //
//  slave modules. The ethernet MAC wishbone master is given    //
//  priority over the Amber core.                               //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////


module ethmac_wb #(
parameter WB_DWIDTH  = 32,
parameter WB_SWIDTH  = 4
)(

// Ethmac side
input       [31:0]          i_m_wb_adr,
input       [3:0]           i_m_wb_sel,
input                       i_m_wb_we,
output      [31:0]          o_m_wb_rdat,
input       [31:0]          i_m_wb_wdat,
input                       i_m_wb_cyc,
input                       i_m_wb_stb,
output                      o_m_wb_ack,
output                      o_m_wb_err,

// Wishbone arbiter side
output      [31:0]          o_m_wb_adr,
output      [WB_SWIDTH-1:0] o_m_wb_sel,
output                      o_m_wb_we,
input       [WB_DWIDTH-1:0] i_m_wb_rdat,
output      [WB_DWIDTH-1:0] o_m_wb_wdat,
output                      o_m_wb_cyc,
output                      o_m_wb_stb,
input                       i_m_wb_ack,
input                       i_m_wb_err,

// Wishbone arbiter side
input       [31:0]          i_s_wb_adr,
input       [WB_SWIDTH-1:0] i_s_wb_sel,
input                       i_s_wb_we,
output      [WB_DWIDTH-1:0] o_s_wb_rdat,
input       [WB_DWIDTH-1:0] i_s_wb_wdat,
input                       i_s_wb_cyc,
input                       i_s_wb_stb,
output                      o_s_wb_ack,
output                      o_s_wb_err,

// Ethmac side
output      [31:0]          o_s_wb_adr,
output      [3:0]           o_s_wb_sel,
output                      o_s_wb_we,
input       [31:0]          i_s_wb_rdat,
output      [31:0]          o_s_wb_wdat,
output                      o_s_wb_cyc,
output                      o_s_wb_stb,
input                       i_s_wb_ack,
input                       i_s_wb_err

);

`include "system_functions.vh"


// =========================
// Master interface - with endian conversion
// =========================
generate
if (WB_DWIDTH == 128) 
    begin : wbm128
    assign o_m_wb_rdat = i_m_wb_adr[3:2] == 2'd3 ? endian_x32(i_m_wb_rdat[127:96]) :
                         i_m_wb_adr[3:2] == 2'd2 ? endian_x32(i_m_wb_rdat[ 95:64]) :
                         i_m_wb_adr[3:2] == 2'd1 ? endian_x32(i_m_wb_rdat[ 63:32]) :
                                                   endian_x32(i_m_wb_rdat[ 31: 0]) ;
                                                  
    assign o_m_wb_sel  = i_m_wb_adr[3:2] == 2'd3 ? {       endian_x4(i_m_wb_sel), 12'd0} :
                         i_m_wb_adr[3:2] == 2'd2 ? { 4'd0, endian_x4(i_m_wb_sel),  8'd0} :
                         i_m_wb_adr[3:2] == 2'd1 ? { 8'd0, endian_x4(i_m_wb_sel),  4'd0} :
                                                   {12'd0, endian_x4(i_m_wb_sel)       } ;
                                                  
    assign o_m_wb_wdat = i_m_wb_adr[3:2] == 2'd3 ? {       endian_x32(i_m_wb_wdat), 96'd0} :
                         i_m_wb_adr[3:2] == 2'd2 ? {32'd0, endian_x32(i_m_wb_wdat), 64'd0} :
                         i_m_wb_adr[3:2] == 2'd1 ? {64'd0, endian_x32(i_m_wb_wdat), 32'd0} :
                                                   {96'd0, endian_x32(i_m_wb_wdat)       } ;
    end 
else
    begin : wbm32
    assign o_m_wb_rdat = endian_x32(i_m_wb_rdat);
    assign o_m_wb_sel  = endian_x4 (i_m_wb_sel);
    assign o_m_wb_wdat = endian_x32(i_m_wb_wdat);
    end
endgenerate

assign o_m_wb_ack = i_m_wb_ack;
assign o_m_wb_err = i_m_wb_err;
assign o_m_wb_adr = i_m_wb_adr;
assign o_m_wb_we  = i_m_wb_we ;
assign o_m_wb_cyc = i_m_wb_cyc;
assign o_m_wb_stb = i_m_wb_stb;


// =========================
// Slave interface - no endian conversion
// =========================
generate
if (WB_DWIDTH == 128) 
    begin : wbs128
    assign o_s_wb_wdat = i_s_wb_adr[3:2] == 2'd3 ? i_s_wb_wdat[127:96] :
                         i_s_wb_adr[3:2] == 2'd2 ? i_s_wb_wdat[ 95:64] :
                         i_s_wb_adr[3:2] == 2'd1 ? i_s_wb_wdat[ 63:32] :
                                                   i_s_wb_wdat[ 31: 0] ;
                                                  
    assign o_s_wb_sel  = i_s_wb_adr[3:2] == 2'd3 ? i_s_wb_sel[15:12] :
                         i_s_wb_adr[3:2] == 2'd2 ? i_s_wb_sel[11: 8] :
                         i_s_wb_adr[3:2] == 2'd1 ? i_s_wb_sel[ 7: 4] :
                                                   i_s_wb_sel[ 3: 0] ;
                                                  
    assign o_s_wb_rdat = i_s_wb_adr[3:2] == 2'd3 ? {       i_s_wb_rdat, 96'd0} :
                         i_s_wb_adr[3:2] == 2'd2 ? {32'd0, i_s_wb_rdat, 64'd0} :
                         i_s_wb_adr[3:2] == 2'd1 ? {64'd0, i_s_wb_rdat, 32'd0} :
                                                   {96'd0, i_s_wb_rdat       } ;
    end
else
    begin : wbs32
    assign o_s_wb_wdat = i_s_wb_wdat;
    assign o_s_wb_sel  = i_s_wb_sel;
    assign o_s_wb_rdat = i_s_wb_rdat;
    end
endgenerate

assign o_s_wb_ack = i_s_wb_ack;
assign o_s_wb_err = i_s_wb_err;
assign o_s_wb_adr = i_s_wb_adr;
assign o_s_wb_we  = i_s_wb_we ;
assign o_s_wb_cyc = i_s_wb_cyc;
assign o_s_wb_stb = i_s_wb_stb;

endmodule


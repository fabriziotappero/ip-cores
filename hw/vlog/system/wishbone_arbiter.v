//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone Arbiter                                            //
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

// TODO add module to switch endianess of ethmac i/f

module wishbone_arbiter #(
parameter WB_DWIDTH  = 32,
parameter WB_SWIDTH  = 4
)(

input                       i_wb_clk,     // WISHBONE clock

// WISHBONE master 0 - Ethmac
input       [31:0]          i_m0_wb_adr,
input       [WB_SWIDTH-1:0] i_m0_wb_sel,
input                       i_m0_wb_we,
output      [WB_DWIDTH-1:0] o_m0_wb_dat,
input       [WB_DWIDTH-1:0] i_m0_wb_dat,
input                       i_m0_wb_cyc,
input                       i_m0_wb_stb,
output                      o_m0_wb_ack,
output                      o_m0_wb_err,


// WISHBONE master 1 - Amber
input       [31:0]          i_m1_wb_adr,
input       [WB_SWIDTH-1:0] i_m1_wb_sel,
input                       i_m1_wb_we,
output      [WB_DWIDTH-1:0] o_m1_wb_dat,
input       [WB_DWIDTH-1:0] i_m1_wb_dat,
input                       i_m1_wb_cyc,
input                       i_m1_wb_stb,
output                      o_m1_wb_ack,
output                      o_m1_wb_err,


// WISHBONE slave 0 - Ethmac
output      [31:0]          o_s0_wb_adr,
output      [WB_SWIDTH-1:0] o_s0_wb_sel,
output                      o_s0_wb_we,
input       [WB_DWIDTH-1:0] i_s0_wb_dat,
output      [WB_DWIDTH-1:0] o_s0_wb_dat,
output                      o_s0_wb_cyc,
output                      o_s0_wb_stb,
input                       i_s0_wb_ack,
input                       i_s0_wb_err,


// WISHBONE slave 1 - Boot Memory
output      [31:0]          o_s1_wb_adr,
output      [WB_SWIDTH-1:0] o_s1_wb_sel,
output                      o_s1_wb_we,
input       [WB_DWIDTH-1:0] i_s1_wb_dat,
output      [WB_DWIDTH-1:0] o_s1_wb_dat,
output                      o_s1_wb_cyc,
output                      o_s1_wb_stb,
input                       i_s1_wb_ack,
input                       i_s1_wb_err,


// WISHBONE slave 2 - Main Memory
output      [31:0]          o_s2_wb_adr,
output      [WB_SWIDTH-1:0] o_s2_wb_sel,
output                      o_s2_wb_we,
input       [WB_DWIDTH-1:0] i_s2_wb_dat,
output      [WB_DWIDTH-1:0] o_s2_wb_dat,
output                      o_s2_wb_cyc,
output                      o_s2_wb_stb,
input                       i_s2_wb_ack,
input                       i_s2_wb_err,


// WISHBONE slave 3 - UART 0
output      [31:0]          o_s3_wb_adr,
output      [WB_SWIDTH-1:0] o_s3_wb_sel,
output                      o_s3_wb_we,
input       [WB_DWIDTH-1:0] i_s3_wb_dat,
output      [WB_DWIDTH-1:0] o_s3_wb_dat,
output                      o_s3_wb_cyc,
output                      o_s3_wb_stb,
input                       i_s3_wb_ack,
input                       i_s3_wb_err,


// WISHBONE slave 4 - UART 1
output      [31:0]          o_s4_wb_adr,
output      [WB_SWIDTH-1:0] o_s4_wb_sel,
output                      o_s4_wb_we,
input       [WB_DWIDTH-1:0] i_s4_wb_dat,
output      [WB_DWIDTH-1:0] o_s4_wb_dat,
output                      o_s4_wb_cyc,
output                      o_s4_wb_stb,
input                       i_s4_wb_ack,
input                       i_s4_wb_err,


// WISHBONE slave 5 - Test Module
output      [31:0]          o_s5_wb_adr,
output      [WB_SWIDTH-1:0] o_s5_wb_sel,
output                      o_s5_wb_we,
input       [WB_DWIDTH-1:0] i_s5_wb_dat,
output      [WB_DWIDTH-1:0] o_s5_wb_dat,
output                      o_s5_wb_cyc,
output                      o_s5_wb_stb,
input                       i_s5_wb_ack,
input                       i_s5_wb_err,


// WISHBONE slave 6 - Timer Module
output      [31:0]          o_s6_wb_adr,
output      [WB_SWIDTH-1:0] o_s6_wb_sel,
output                      o_s6_wb_we,
input       [WB_DWIDTH-1:0] i_s6_wb_dat,
output      [WB_DWIDTH-1:0] o_s6_wb_dat,
output                      o_s6_wb_cyc,
output                      o_s6_wb_stb,
input                       i_s6_wb_ack,
input                       i_s6_wb_err,


 // WISHBONE slave 7 - Interrupt Controller
output      [31:0]          o_s7_wb_adr,
output      [WB_SWIDTH-1:0] o_s7_wb_sel,
output                      o_s7_wb_we,
input       [WB_DWIDTH-1:0] i_s7_wb_dat,
output      [WB_DWIDTH-1:0] o_s7_wb_dat,
output                      o_s7_wb_cyc,
output                      o_s7_wb_stb,
input                       i_s7_wb_ack,
input                       i_s7_wb_err
);

`include "memory_configuration.vh"

reg         m0_wb_hold_r = 'd0;
reg         m1_wb_hold_r = 'd0;
wire        current_master;
reg         current_master_r = 'd0;
wire        next_master;
wire        select_master;
wire [3:0]  current_slave;

wire [31:0]             master_adr;
wire [WB_SWIDTH-1:0]    master_sel;
wire                    master_we;
wire [WB_DWIDTH-1:0]    master_wdat;
wire                    master_cyc;
wire                    master_stb;
wire [WB_DWIDTH-1:0]    master_rdat;
wire                    master_ack;
wire                    master_err;
   
   
// Arbitrate between m0 and m1. Ethmac (m0) always gets priority
assign next_master    = i_m0_wb_cyc ? 1'd0 : 1'd1;

// Use cyc signal for arbitration so block accesses are not split up
// assign m0_in_cycle    = m0_wb_hold_r && !master_ack;
// assign m1_in_cycle    = m1_wb_hold_r && !master_ack;

// only select a new bus master when the current bus master
// daccess ends
assign select_master  = current_master_r ? !m1_wb_hold_r : !m0_wb_hold_r;
assign current_master = select_master ? next_master : current_master_r;


always @( posedge i_wb_clk )
    begin
    current_master_r    <= current_master;
    m0_wb_hold_r        <= i_m0_wb_stb && !o_m0_wb_ack;
    m1_wb_hold_r        <= i_m1_wb_stb && !o_m1_wb_ack;
    end


// Arbitrate between slaves
assign current_slave = in_ethmac   ( master_adr ) ? 4'd0  :  // Ethmac
                       in_boot_mem ( master_adr ) ? 4'd1  :  // Boot memory
                       in_main_mem ( master_adr ) ? 4'd2  :  // Main memory
                       in_uart0    ( master_adr ) ? 4'd3  :  // UART 0
                       in_uart1    ( master_adr ) ? 4'd4  :  // UART 1
                       in_test     ( master_adr ) ? 4'd5  :  // Test Module
                       in_tm       ( master_adr ) ? 4'd6  :  // Timer Module
                       in_ic       ( master_adr ) ? 4'd7  :  // Interrupt Controller
                                                    4'd2  ;  // default to main memory


assign master_adr   = current_master ? i_m1_wb_adr : i_m0_wb_adr ;
assign master_sel   = current_master ? i_m1_wb_sel : i_m0_wb_sel ;
assign master_wdat  = current_master ? i_m1_wb_dat : i_m0_wb_dat ;
assign master_we    = current_master ? i_m1_wb_we  : i_m0_wb_we  ;
assign master_cyc   = current_master ? i_m1_wb_cyc : i_m0_wb_cyc ;
assign master_stb   = current_master ? i_m1_wb_stb : i_m0_wb_stb ;


// Ethmac Slave outputs
assign o_s0_wb_adr  = master_adr;
assign o_s0_wb_dat  = master_wdat;
assign o_s0_wb_sel  = master_sel;
assign o_s0_wb_we   = current_slave == 4'd0 ? master_we  : 1'd0;
assign o_s0_wb_cyc  = current_slave == 4'd0 ? master_cyc : 1'd0;
assign o_s0_wb_stb  = current_slave == 4'd0 ? master_stb : 1'd0;

// Boot Memory outputs
assign o_s1_wb_adr  = master_adr;
assign o_s1_wb_dat  = master_wdat;
assign o_s1_wb_sel  = master_sel;
assign o_s1_wb_we   = current_slave == 4'd1 ? master_we  : 1'd0;
assign o_s1_wb_cyc  = current_slave == 4'd1 ? master_cyc : 1'd0;
assign o_s1_wb_stb  = current_slave == 4'd1 ? master_stb : 1'd0;

// Main Memory Outputs
assign o_s2_wb_adr  = master_adr;
assign o_s2_wb_dat  = master_wdat;
assign o_s2_wb_sel  = master_sel;
assign o_s2_wb_we   = current_slave == 4'd2 ? master_we  : 1'd0;
assign o_s2_wb_cyc  = current_slave == 4'd2 ? master_cyc : 1'd0;
assign o_s2_wb_stb  = current_slave == 4'd2 ? master_stb : 1'd0;

// UART0 Outputs
assign o_s3_wb_adr  = master_adr;
assign o_s3_wb_dat  = master_wdat;
assign o_s3_wb_sel  = master_sel;
assign o_s3_wb_we   = current_slave == 4'd3 ? master_we  : 1'd0;
assign o_s3_wb_cyc  = current_slave == 4'd3 ? master_cyc : 1'd0;
assign o_s3_wb_stb  = current_slave == 4'd3 ? master_stb : 1'd0;

// UART1 Outputs
assign o_s4_wb_adr  = master_adr;
assign o_s4_wb_dat  = master_wdat;
assign o_s4_wb_sel  = master_sel;
assign o_s4_wb_we   = current_slave == 4'd4 ? master_we  : 1'd0;
assign o_s4_wb_cyc  = current_slave == 4'd4 ? master_cyc : 1'd0;
assign o_s4_wb_stb  = current_slave == 4'd4 ? master_stb : 1'd0;

// Test Module Outputs
assign o_s5_wb_adr  = master_adr;
assign o_s5_wb_dat  = master_wdat;
assign o_s5_wb_sel  = master_sel;
assign o_s5_wb_we   = current_slave == 4'd5 ? master_we  : 1'd0;
assign o_s5_wb_cyc  = current_slave == 4'd5 ? master_cyc : 1'd0;
assign o_s5_wb_stb  = current_slave == 4'd5 ? master_stb : 1'd0;

// Timers Outputs
assign o_s6_wb_adr  = master_adr;
assign o_s6_wb_dat  = master_wdat;
assign o_s6_wb_sel  = master_sel;
assign o_s6_wb_we   = current_slave == 4'd6 ? master_we  : 1'd0;
assign o_s6_wb_cyc  = current_slave == 4'd6 ? master_cyc : 1'd0;
assign o_s6_wb_stb  = current_slave == 4'd6 ? master_stb : 1'd0;

// Interrupt Controller
assign o_s7_wb_adr  = master_adr;
assign o_s7_wb_dat  = master_wdat;
assign o_s7_wb_sel  = master_sel;
assign o_s7_wb_we   = current_slave == 4'd7 ? master_we  : 1'd0;
assign o_s7_wb_cyc  = current_slave == 4'd7 ? master_cyc : 1'd0;
assign o_s7_wb_stb  = current_slave == 4'd7 ? master_stb : 1'd0;


// Master Outputs
assign master_rdat  = current_slave == 4'd0  ? i_s0_wb_dat  :
                      current_slave == 4'd1  ? i_s1_wb_dat  :
                      current_slave == 4'd2  ? i_s2_wb_dat  :
                      current_slave == 4'd3  ? i_s3_wb_dat  :
                      current_slave == 4'd4  ? i_s4_wb_dat  :
                      current_slave == 4'd5  ? i_s5_wb_dat  :
                      current_slave == 4'd6  ? i_s6_wb_dat  :
                      current_slave == 4'd7  ? i_s7_wb_dat  :
                                               i_s2_wb_dat  ;


assign master_ack   = current_slave == 4'd0  ? i_s0_wb_ack  :
                      current_slave == 4'd1  ? i_s1_wb_ack  :
                      current_slave == 4'd2  ? i_s2_wb_ack  :
                      current_slave == 4'd3  ? i_s3_wb_ack  :
                      current_slave == 4'd4  ? i_s4_wb_ack  :
                      current_slave == 4'd5  ? i_s5_wb_ack  :
                      current_slave == 4'd6  ? i_s6_wb_ack  :
                      current_slave == 4'd7  ? i_s7_wb_ack  :
                                               i_s2_wb_ack  ; 


assign master_err   = current_slave == 4'd0  ? i_s0_wb_err  :
                      current_slave == 4'd1  ? i_s1_wb_err  :
                      current_slave == 4'd2  ? i_s2_wb_err  :
                      current_slave == 4'd3  ? i_s3_wb_err  :
                      current_slave == 4'd4  ? i_s4_wb_err  :
                      current_slave == 4'd5  ? i_s5_wb_err  :
                      current_slave == 4'd6  ? i_s6_wb_err  :
                      current_slave == 4'd7  ? i_s7_wb_err  :
                                               i_s2_wb_err  ; 


// Ethmac Master Outputs
assign o_m0_wb_dat  = master_rdat;
assign o_m0_wb_ack  = current_master  ? 1'd0 : master_ack ;
assign o_m0_wb_err  = current_master  ? 1'd0 : master_err ;

// Amber Master Outputs
assign o_m1_wb_dat  = master_rdat;
assign o_m1_wb_ack  = current_master  ?  master_ack : 1'd0 ;
assign o_m1_wb_err  = current_master  ?  master_err : 1'd0 ;

endmodule


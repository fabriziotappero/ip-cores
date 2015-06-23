/**********************************************************************/
/*                                                                    */
/*             -------                                                */
/*            /   SOC  \                                              */
/*           /    GEN   \                                             */
/*          /     SIM    \                                            */
/*          ==============                                            */
/*          |            |                                            */
/*          |____________|                                            */
/*                                                                    */
/*  psram behavioral model for sims                                   */
/*                                                                    */
/*                                                                    */
/*  Author(s):                                                        */
/*      - John Eaton, jt_eaton@opencores.org                          */
/*                                                                    */
/**********************************************************************/
/*                                                                    */
/*    Copyright (C) <2010>  <Ouabache Design Works>                   */
/*                                                                    */
/*  This source file may be used and distributed without              */
/*  restriction provided that this copyright statement is not         */
/*  removed from the file and that any derivative work contains       */
/*  the original copyright notice and the associated disclaimer.      */
/*                                                                    */
/*  This source file is free software; you can redistribute it        */
/*  and/or modify it under the terms of the GNU Lesser General        */
/*  Public License as published by the Free Software Foundation;      */
/*  either version 2.1 of the License, or (at your option) any        */
/*  later version.                                                    */
/*                                                                    */
/*  This source is distributed in the hope that it will be            */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied        */
/*  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR           */
/*  PURPOSE.  See the GNU Lesser General Public License for more      */
/*  details.                                                          */
/*                                                                    */
/*  You should have received a copy of the GNU Lesser General         */
/*  Public License along with this source; if not, download it        */
/*  from http://www.opencores.org/lgpl.shtml                          */
/*                                                                    */
/**********************************************************************/
module mt45w8mw12_def 
#(
    parameter ADDR_BITS      = 23,   
    parameter DQ_BITS        = 16,
    parameter MEM_BITS       = 16
  )
(
    input  wire                       clk,
    input  wire                       adv_n,
    input  wire                       cre,
    output wire                       o_wait, 
    input  wire                       ce_n,
    input  wire                       oe_n,
    input  wire                       we_n,
    input  wire                       lb_n,
    input  wire                       ub_n,
    input  wire     [ADDR_BITS-1 : 0] addr,
    inout  wire       [DQ_BITS-1 : 0] dq
); 
reg [7:0] 		      memoryl [1<<MEM_BITS-1:0];
reg [7:0] 		      memoryu [1<<MEM_BITS-1:0];   
reg [DQ_BITS-1 : 0]           dq_out;
// Write Memory  
always@(*)      
if(!ce_n && !we_n && !lb_n)  memoryl[addr]  =  dq[7:0];
always@(*)      
if(!ce_n && !we_n && !ub_n)  memoryu[addr]  =  dq[15:8];
// Read Memory   
always@(*)      dq_out[7:0]  = memoryl[addr];
always@(*)      dq_out[15:8] = memoryu[addr];   
// Tristate output
assign  dq    =  (!ce_n && !oe_n) ? dq_out[DQ_BITS-1:0]: {DQ_BITS{1'bz}};
endmodule

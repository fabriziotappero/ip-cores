`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Address register.
// 
// Additional Comments: See US 2959351, Fig. 71.
//
// Copyright (c) 2015 Robert Abeles
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
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module addr_reg (
    input rst,
    input ap, bp,
    input dx, d1, d2, d3, d4, d5, d6, d7, d8, d9,
    input w0, w1, w2, w3, w4, w5, w6, w7, w8, w9,
    input s0, s1, s2, s3, s4,
    
    input error_reset,
    input restart_a,
    input set_8000, reset_8000,
    input tlu_band_change,
    input double_write,
    input no_write,
    input bs_to_gs,
    input rigs,
    input [0:6] ps_reg_in, console_in,
    input ri_addr_reg,
    input console_to_addr_reg,
    
    output reg[0:6] addr_th, addr_h, addr_t, addr_u,
    output reg dynamic_addr_hit,
    output reg addr_no_800x, addr_8000, addr_8001, addr_8002, 
               addr_8003, addr_8002_8003,
    output reg invalid_addr
    );

   wire reset_to_0000 =  (d1 & tlu_band_change)
                       | restart_a 
                       | reset_8000;
  
   always @(posedge bp)
      if (rst) begin
         addr_th <= `biq_0;
         addr_h  <= `biq_0;
         addr_t  <= `biq_0;
         addr_u  <= `biq_0;
      end else if (set_8000) begin
         addr_th <= `biq_8;
         addr_h  <= `biq_0;
         addr_t  <= `biq_0;
         addr_u  <= `biq_0;
      end else if (reset_to_0000) begin
         addr_th <= `biq_0;
         addr_h  <= `biq_0;
         addr_t  <= `biq_0;
         addr_u  <= `biq_0;
      end else if (ri_addr_reg) begin
         if (d4 | d8) addr_th <= ps_reg_in;
         else if (d3 | d7) addr_h <= ps_reg_in;
         else if (d2 | d6) addr_t <= ps_reg_in;
         else if (d1 | d5) addr_u <= ps_reg_in;
      end else if (console_to_addr_reg) begin
         if (d4) addr_th <= console_in;
         else if (d3) addr_h <= console_in;
         else if (d2) addr_t <= console_in;
         else if (d1) addr_u <= console_in;
      end;
   
   // Find whether next word coincides with address register (dynamic portion of address)
   // Sample at d9:ap
   assign q4un_p = addr_u[`biq_q4] & (w3 | w8);
   assign q3un_p = addr_u[`biq_q3] & (w2 | w7);
   assign q2un_p = addr_u[`biq_q2] & (w1 | w6);
   assign q1un_p = addr_u[`biq_q1] & (w0 | w5);
   assign q0un_p = addr_u[`biq_q0] & (w4 | w9);
   assign b0un_p = addr_u[`biq_b0] & (w0 | w1 | w2 | w3 | w9);
   assign b5un_p = addr_u[`biq_b5] & (w4 | w5 | w6 | w7 | w8);
   assign q4t_p = addr_t[`biq_q4] & w9 & s3 | addr_t[`biq_q4] & ~w9 & s4;
   assign q3t_p = addr_t[`biq_q3] & w9 & s2 | addr_t[`biq_q3] & ~w9 & s3;
   assign q2t_p = addr_t[`biq_q2] & w9 & s1 | addr_t[`biq_q2] & ~w9 & s2;
   assign q1t_p = addr_t[`biq_q1] & w9 & s0 | addr_t[`biq_q1] & ~w9 & s1;
   assign q0t_p = addr_t[`biq_q0] & w9 & s4 | addr_t[`biq_q0] & ~w9 & s0;
   assign dynamic_addr_hit_p = (q4un_p | q3un_p | q2un_p | q1un_p | q0un_p)
                             & (b0un_p | b5un_p) & (q4t_p | q3t_p | q2t_p | q1t_p | q0t_p);
 
   // Test address register validity
   //    Test address == 0xxx or == 1xxx or == 800[0..3]
   assign inv1_p = (addr_th[2] | addr_th[4]) | (addr_th[3] & addr_th[1])
                 | (addr_th[6] & addr_th[0]) | (addr_th[5] & addr_th[0]);  // 0xxx or 1xxx or 8xxx
   assign inv2_p = (addr_th[3] & addr_th[0]) & ~(addr_h[1] & addr_h[6]);   // 80xx
   assign inv3_p = (addr_th[3] & addr_th[0]) & ~(addr_t[1] & addr_t[6]);   // 8x0x
   assign inv4_p = (addr_th[3] & addr_th[0]) & (addr_u[0] | addr_u[2]);    // 8xx[0..3]
   assign invalid_addr_p = inv1_p | inv2_p | inv3_p | inv4_p;
   
   // Decode 8xxx addresses
   assign addr_8xxx_p = (addr_th[`biq_b5] & addr_th[`biq_q3]);
   assign addr_8xx0_p = addr_8xxx_p & addr_u[`biq_q0];
   assign addr_8xx1_p = addr_8xxx_p & addr_u[`biq_q1];
   assign addr_8xx2_p = addr_8xxx_p & addr_u[`biq_q2];
   assign addr_8xx3_p = addr_8xxx_p & addr_u[`biq_q3];
   
   // Memory access error
   assign mem_error_p = double_write | ((bs_to_gs | rigs) & ~dx & no_write);
   
   always @(posedge ap)
      if (rst) begin
         invalid_addr <= 0;
      end else if (error_reset | ri_addr_reg | console_to_addr_reg) begin
         invalid_addr <= 0;
      end else if (mem_error_p | invalid_addr_p) begin
         invalid_addr <= 1;
      end;
      
   always @(posedge ap)
      if (rst) begin
         dynamic_addr_hit <= 0;
      end else if (d9) begin
         dynamic_addr_hit <= dynamic_addr_hit_p;
      end else if (dx) begin
         dynamic_addr_hit <= 0;
      end;
   
   always @(posedge bp)
      if (rst) begin
         addr_no_800x <= 1;
         addr_8000 <= 0; 
         addr_8001 <= 0;
         addr_8002 <= 0;
         addr_8003 <= 0;
         addr_8002_8003 <= 0;
      end else begin
         addr_no_800x <= ~addr_8xxx_p & ~invalid_addr_p;
         addr_8000 <= addr_8xx0_p & ~invalid_addr_p;
         addr_8001 <= addr_8xx1_p & ~invalid_addr_p;
         addr_8002 <= addr_8xx2_p & ~invalid_addr_p;
         addr_8003 <= addr_8xx3_p & ~invalid_addr_p;
         addr_8002_8003 <= (addr_8xx2_p | addr_8xx3_p) & ~invalid_addr_p;
      end;   

endmodule

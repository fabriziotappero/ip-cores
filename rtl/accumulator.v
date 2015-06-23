`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: 650 accumulator register.
// 
// Additional Comments: See US 2959351, Fig. 64.
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

module accumulator (
   input rst,
   input ap, bp, dp,
   input dx, d1, d2, d10,
   input dxu, d0u,
   input wu, wl,
   input [0:6] adder_out, console_out,
   input acc_regen_gate, right_shift_gate, acc_ri_gate, acc_ri_console,
         zero_shift_count, man_acc_reset, reset_op,
   input [0:3] early_idx, ontime_idx,
   output reg [0:6] early_out, ontime_out, ped_out
   );
    
   //-----------------------------------------------------------------------------
   // The accumulator occupies 22 locations of a 32x7bit RAM. 
   //-----------------------------------------------------------------------------
   reg [0:6] digits [0:31];
   
   wire [0:4] acc_early_idx  = {(d10? ~wu : wu), early_idx};
   wire [0:4] acc_ontime_idx = {wu, ontime_idx};
   
   //-----------------------------------------------------------------------------
   // A -- Read into early_out from RAM
   //      Read into ontime_out
   //-----------------------------------------------------------------------------
   wire acc_reset =  reset_op | man_acc_reset 
                   | (zero_shift_count & wl & (d1 | d2));
   always @(posedge ap)
      if (rst) begin
         early_out  <= `biq_blank;
         ontime_out <= `biq_blank;
      end else begin
         early_out  <= reset_op?           `biq_0 
                     : ((wl & d10) | dxu)? early_out
                     :                     digits[acc_early_idx];
         ontime_out <= (acc_reset | d0u | dxu)? `biq_0 : early_out;
      end;
   
   //-----------------------------------------------------------------------------
   // B -- Read into ped_out
   //-----------------------------------------------------------------------------
   always @(posedge bp)
      if (rst) begin
         ped_out <= `biq_blank;
      end else begin
         ped_out <= acc_ri_console?   console_out
                  : right_shift_gate? early_out
                  : acc_ri_gate?      adder_out
                  : acc_regen_gate?   ontime_out
                  : `biq_blank;
      end;
   
   //-----------------------------------------------------------------------------
   // D -- Write ped_out into RAM
   //-----------------------------------------------------------------------------
   always @(posedge dp)
      digits[acc_ontime_idx] <= ped_out;

endmodule

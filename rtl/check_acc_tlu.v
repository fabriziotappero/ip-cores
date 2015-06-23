`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Error check accumulator, adder carry, and TLU.
// 
// Additional Comments: See US 2959351, Fig. 83.
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

module check_acc_tlu (
   input rst,
   input ap, bp,
   input d0, d2, d1_dx,
   input [0:6] acc_ped_out,
   input sel_store_add_gate, err_reset, carry_test_latch, no_carry_test_latch,
    
   output acc_zero, acc_no_zero,
   output reg check_latch
   );

   reg tlu_check;
   assign acc_zero = acc_ped_out[`biq_b0] & acc_ped_out[`biq_q0];
   assign acc_no_zero = acc_ped_out[`biq_b5] | acc_ped_out[`biq_q4]
                      | acc_ped_out[`biq_q3] | acc_ped_out[`biq_q2]
                      | acc_ped_out[`biq_q1];
   wire acc_err1_p = ~(acc_zero | acc_no_zero) & d1_dx;
   wire acc_err2_p = (acc_zero & acc_no_zero) & d1_dx;
   wire carry_err1_p = ~(carry_test_latch | no_carry_test_latch) & tlu_check;
   wire carry_err2_p = carry_test_latch & no_carry_test_latch;
   wire set_check_latch_p = acc_err1_p | acc_err2_p | carry_err1_p | carry_err2_p;

   always @(posedge ap)
      if (rst) begin
         tlu_check <= 0;
      end else if (d0) begin
         tlu_check <= 0;
      end else if (d2 & sel_store_add_gate) begin
         tlu_check <= 1;
      end;
   
   always @(posedge bp)
      if (rst) begin
         check_latch <= 0;
      end else if (err_reset) begin
         check_latch <= 0;
      end else if (set_check_latch_p) begin
         check_latch <= 1;
      end;
   
endmodule

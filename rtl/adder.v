`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Bi-quinary adder.
// 
// Additional Comments: 
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

module adder (
   input rst,
   input ap, bp, dp, 
         dxu, dx, d0u, d1, d1l, d10, d10u, wl,
   input [0:6] entry_a, entry_b,
   input tlu_on, left_shift_off, left_shift_on,  
   input no_carry_insert, no_carry_blank, carry_insert, carry_blank,
   input zero_insert,
    
   input error_reset,
   input quotient_digit_on, overflow_stop_sw, overflow_sense_sw,
   input mult_div_off, dist_true_add_gate, acc_true_add_latch,
   input shift_overflow,
    
   output reg[0:6] adder_out,
   output reg carry_test, no_carry_test, d0l_carry_sig, overflow_stop,
    
   output overflow_light, overflow_sense_sig
   );
    
   //-----------------------------------------------------------------------------
   // The 650 bi-quinary adder accepts its inputs early (i.e., one clock ahead),
   // producing a result during the next digit time. This implementation retains
   // sum and carries in _hold flip-flops, the 650 used other tricky means.
   //-----------------------------------------------------------------------------
   reg [0:6] sum_hold;
   reg carry_hold, no_carry_hold, carry_test_hold, no_carry_test_hold;
   reg reset_ctl;
   reg carry, no_carry;    
   
   //-----------------------------------------------------------------------------
   // Bi-quinary adder, forms biq sum of two biq digits with carry in and out.
   // Hand captured from 650 patent fig. 68.
   //
   // By design, this logic produces a sum of all zeroes with zero carry_out and 
   // no_carry_out whenever entry_a or entry_b or both carry and no_carry are
   // zero.
   //-----------------------------------------------------------------------------
   wire b0_and_b5 =  (entry_a[`biq_b0] & entry_b[`biq_b5])
                   | (entry_a[`biq_b5] & entry_b[`biq_b0]);
   wire q4_a_or_b = entry_a[`biq_q4] | entry_b[`biq_q4];
   wire q3_a_or_b = entry_a[`biq_q3] | entry_b[`biq_q3];
   wire q2_a_or_b = entry_a[`biq_q2] | entry_b[`biq_q2];
   wire q1_a_or_b = entry_a[`biq_q1] | entry_b[`biq_q1];
   wire q0_a_or_b = entry_a[`biq_q0] | entry_b[`biq_q0];
   wire qsum_8 = entry_a[`biq_q4] & entry_b[`biq_q4];
   wire qsum_7 = q4_a_or_b & q3_a_or_b;
   wire qsum_6 =  (entry_a[`biq_q3] & entry_b[`biq_q3])
                | (q4_a_or_b & q2_a_or_b);
   wire qsum_5 =  (q4_a_or_b & q3_a_or_b)
                | (q3_a_or_b & q2_a_or_b);
   wire qsum_4 =  (entry_a[`biq_q2] & entry_b[`biq_q2])
                | (q3_a_or_b & q1_a_or_b)
                | (q4_a_or_b & q0_a_or_b);
   wire qsum_3 =  (q3_a_or_b & q0_a_or_b)
                | (q2_a_or_b & q1_a_or_b);
   wire qsum_2 =  (entry_a[`biq_q1] & entry_b[`biq_q1])
                | (q2_a_or_b & q0_a_or_b);
   wire qsum_1 = q1_a_or_b & q0_a_or_b;
   wire qsum_0 = (entry_a[`biq_q0] & entry_b[`biq_q0]);
   wire three_or_eight = qsum_3 | qsum_8;
   wire two_or_seven   = qsum_2 | qsum_7;
   wire six_or_one     = qsum_6 | qsum_1;
   wire zero_or_five   = qsum_0 | qsum_5;
   wire five_and_up = qsum_8 | qsum_7 | qsum_6 | qsum_5 | (qsum_4 & carry);
   wire below_five  = (qsum_4 & no_carry) | qsum_3 | qsum_2 | qsum_1 | qsum_0;
   wire b5_carry    = five_and_up & entry_a[`biq_b5] & entry_b[`biq_b5];
   wire b5_no_carry =  (five_and_up & entry_a[`biq_b0] & entry_b[`biq_b0])
                     | (below_five & b0_and_b5);
   wire b0_carry    =  (five_and_up & b0_and_b5)
                     | (below_five & entry_a[`biq_b5] & entry_b[`biq_b5]);
   wire b0_no_carry = below_five & entry_a[`biq_b0] & entry_b[`biq_b0];
   wire sum_q0 = (carry & qsum_4) | (no_carry & zero_or_five);
   wire sum_q1 = (carry & zero_or_five) | (no_carry & six_or_one);
   wire sum_q2 = (carry & six_or_one) | (no_carry & two_or_seven);
   wire sum_q3 = (carry & two_or_seven) | (no_carry & three_or_eight);
   wire sum_q4 = (carry & three_or_eight) | (no_carry & qsum_4);
   wire sum_b0 = b0_no_carry | b0_carry;
   wire sum_b5 = b5_no_carry | b5_carry;
   wire [0:6] sum_out = {sum_b5, sum_b0, sum_q4, sum_q3, sum_q2, sum_q1, sum_q0};
   wire carry_out = b0_carry | b5_carry;
   wire no_carry_out = b0_no_carry | b5_no_carry;
      
   //-----------------------------------------------------------------------------
   // A : Supply sum and carries from previous digit time
   //-----------------------------------------------------------------------------
   always @(posedge ap)
      if (rst) begin
         adder_out     <= `biq_blank;
         carry_test    <= 0;
         no_carry_test <= 0;
         carry         <= 0;
         no_carry      <= 0;
      end else begin
         adder_out     <= sum_hold;
         carry_test    <= carry_test_hold;
         no_carry_test <= no_carry_test_hold;
         carry         <= carry_hold;
         no_carry      <= no_carry_hold;
      end
   
   wire reset_ctl_on_p  = (wl & d10 & left_shift_off) | (dxu & left_shift_on);
   wire reset_ctl_off_p = tlu_on | (d1 & left_shift_on) | (d0u & left_shift_off);
   always @(posedge ap)
      if (rst) begin
         reset_ctl <= 0;
      end else if (reset_ctl_on_p) begin
         reset_ctl <= 1;
      end else if (reset_ctl_off_p) begin
         reset_ctl <= 0;
      end;
      
   wire overflow =  shift_overflow 
                  | (carry_test & d10u & dist_true_add_gate 
                                & acc_true_add_latch & mult_div_off);
   assign overflow_sense_sig = overflow & overflow_sense_sw;
   wire overflow_stop_p =  (d1l & carry_test & quotient_digit_on) 
                         | (overflow & overflow_stop_sw);
   assign overflow_light = overflow_stop;
   always @(posedge bp)
      if (rst) begin
         overflow_stop <= 1;
      end else if (error_reset) begin
         overflow_stop <= 0;
      end else if (overflow_stop_p) begin
         overflow_stop <= 1;
      end;
      
   always @(posedge dp)
      if (rst)                      d0l_carry_sig <= 0;
      else if (wl & d1)             d0l_carry_sig <= 0;
      else if (wl & dx & carry_out) d0l_carry_sig <= 1;
         
   always @(posedge dp)
      if (rst) begin
         sum_hold <= `biq_blank;
         carry_hold <= 0;
         no_carry_hold <= 0;
         carry_test_hold <= 0;
         no_carry_test_hold <= 0;
      end else begin
         sum_hold      <= zero_insert? `biq_0 
                        : reset_ctl?  sum_hold 
                        : sum_out;
         carry_hold    <= (reset_ctl | carry_blank)? 1'b0
                        : carry_insert? 1'b1
                        : carry_out;
         no_carry_hold <= (reset_ctl | no_carry_blank)? 1'b0
                        : no_carry_insert? 1'b1
                        : no_carry_out;
         carry_test_hold    <= reset_ctl? 1'b0 : carry_out;
         no_carry_test_hold <= reset_ctl? 1'b0 : no_carry_out;
      end;
   

endmodule

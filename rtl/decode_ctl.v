`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Instruction decode and control.
// 
// Additional Comments: See US 2959351, Fig. 78.
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

module decode_ctl (
   input rst,
   input ap, bp, cp,
   input dx, d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10,
   input d5_d10, d10_d1_d5, dxl, dxu, d10u,
   input [0:6] opreg_t, opreg_u, addr_u,
   input [0:6] ontime_dist,
   input man_ro_storage, dist_back_sig, d_control, ena_arith_codes,
   input pgm_stop_sw,
   input acc_zero_test, acc_no_zero_test, acc_plus_test, acc_minus_test,
   input single_intlk, arith_restart, overflow_sense_sig, man_acc_reset,

   output all_restarts, use_d_for_i, turn_on_single_intlk, turn_on_op_intlk,
   output stop_code, code_69, tlu_sig,
   output mult_sig, divide_sig, reset_sig, no_reset_sig, abs_sig, no_abs_sig,
   output lower_sig, upper_sig, add_sig, subt_sig,
   output right_shift_sig, left_shift_sig, half_correct_sig, shift_count_sig,
   output end_shift_control,
   output reg overflow_sense_latch
   );

   //-----------------------------------------------------------------------------
   // Miscellaneous signals
   //-----------------------------------------------------------------------------
   wire code_90_d_for_i_sig, code_90_restart_sig, code_69_restart_sig,
        code_00_01_restart_sig, code_30_35_restart, shift_restart,
        branch_restart, branch_d_for_i, code_47_d_for_i_sig;
        
   assign all_restarts =  code_90_restart_sig | code_69_restart_sig
                        | code_00_01_restart_sig | code_30_35_restart
                        | shift_restart | branch_restart;
   assign use_d_for_i =  code_90_d_for_i_sig | branch_d_for_i
                       | code_47_d_for_i_sig;
   assign turn_on_single_intlk = end_shift_control;
   
   //-----------------------------------------------------------------------------
   // 00 -- No Operation
   // 01 -- Stop
   //-----------------------------------------------------------------------------
   wire code_00_to_04_dctl_p =  opreg_t[`biq_b0] & opreg_t[`biq_q0]
                              & opreg_u[`biq_b0] & d_control;
   wire code_00_dctl_p = code_00_to_04_dctl_p & opreg_u[`biq_q0];
   wire code_01_dctl_p = code_00_to_04_dctl_p & opreg_u[`biq_q1];
   wire code_00_01_restart_p = code_00_dctl_p | code_01_dctl_p;
   digit_pulse c00_rstrt (rst, ap, code_00_01_restart_p, 
                          1'b0, code_00_01_restart_sig);
   assign stop_code = pgm_stop_sw & code_01_dctl_p;
   
   //-----------------------------------------------------------------------------
   // 14 -- Divide
   // 64 -- Divide and Reset Upper
   //-----------------------------------------------------------------------------
   wire code_14_64_dx_d0_p = (dx | d0) & opreg_t[`biq_q1] // schematic missing term
                                       & opreg_u[`biq_b0] & opreg_u[`biq_q4]; 
   assign divide_sig =  (code_14_64_dx_d0_p & ena_arith_codes & opreg_t[`biq_b5])
                      | (code_14_64_dx_d0_p & ena_arith_codes & opreg_t[`biq_b0]);
   
   //-----------------------------------------------------------------------------
   // 19 -- Multiply
   //-----------------------------------------------------------------------------
   assign mult_sig = (dx | d0) & ena_arith_codes 
                               & code_19_or_69_dctl_p & opreg_t[`biq_b0];
   
   //-----------------------------------------------------------------------------
   // 30 -- Shift Right
   // 31 -- Shift and Round
   // 35 -- Shift Left
   // 36 -- Shift Left and Count
   //-----------------------------------------------------------------------------
   reg shift_control_latch;
   digit_pulse end_shift (rst, cp, ~shift_control_latch, 1'b1, end_shift_control);
   wire shift_control_on_p = d_control & d10u & ~single_intlk & opreg_t[`biq_b0]
                                                              & opreg_t[`biq_q3];   
   always @(posedge ap)
      if (rst) begin
         shift_control_latch <= 0;
      end else if (dxu) begin
         shift_control_latch <= 0;
      end else if (shift_control_on_p) begin
         shift_control_latch <= 1;
      end;
   
   wire zero_shift_number = addr_u[`biq_b0] & addr_u[`biq_q0];
   wire edxl_shift_control = shift_control_latch & dxl;
   wire code_x5 = opreg_u[`biq_b5] & opreg_u[`biq_q0];
   wire code_x0 = opreg_u[`biq_b0] & opreg_u[`biq_q0];
   wire code_x0_or_x5 = code_x0 | code_x5;
   // turn_on_op_intlk: No zero shift num on 30 or 35 codes
   assign turn_on_op_intlk =  ~(zero_shift_number & shift_control_latch 
                                                  & code_x0_or_x5) 
                            & edxl_shift_control;
   assign code_30_35_restart = zero_shift_number & edxl_shift_control
                                                 & (code_x0_or_x5);
   
   assign right_shift_sig  = ~zero_shift_number & edxl_shift_control & code_x0;
   assign left_shift_sig   = ~zero_shift_number & edxl_shift_control & code_x5;
   assign half_correct_sig = shift_control_latch & opreg_u[`biq_b0]
                                                 & opreg_u[`biq_q1];
   assign shift_count_sig  = shift_control_latch & opreg_u[`biq_b5]
                                                 & opreg_u[`biq_q1];
   assign shift_restart = arith_restart & opreg_t[`biq_q3];
   
   //-----------------------------------------------------------------------------
   // 44 -- Branch on non-zero upper acc 
   // 45 -- Branch on zero acc
   // 46 -- Branch on minus acc
   // 47 -- Branch on adder overflow
   //-----------------------------------------------------------------------------  
   wire code_44_dctl_edxl_p =  d_control & dxl
                             & opreg_t[`biq_b0] & opreg_t[`biq_q4]
                             & opreg_u[`biq_b0] & opreg_u[`biq_q4];
   wire code_45_to_49_dctl_p = d_control & opreg_t[`biq_b0] & opreg_t[`biq_q4]
                                         & opreg_u[`biq_b5];
   wire code_45_dctl_edxu_p = dxu & code_45_to_49_dctl_p & opreg_u[`biq_q0];
   wire code_46_dctl_p = code_45_to_49_dctl_p & opreg_u[`biq_q1];
   wire code_47_dctl_p = code_45_to_49_dctl_p & opreg_u[`biq_q2];

   wire code_44_or_45_restart_p =  (code_44_dctl_edxl_p | code_45_dctl_edxu_p)
                                  & acc_zero_test;
   wire code_44_or_45_d_for_i_p =  (code_44_dctl_edxl_p | code_45_dctl_edxu_p)
                                  & acc_no_zero_test;
   wire code_46_restart_p = code_46_dctl_p & acc_plus_test;
   wire code_46_d_for_i_p = code_46_dctl_p & acc_minus_test;
   wire code_47_restart_p = code_47_dctl_p & d5 & ~overflow_sense_latch;
                          
   wire branch_restart_p =  code_44_or_45_restart_p | code_46_restart_p 
                          | code_47_restart_p;
   digit_pulse br_rstrt (rst, bp, branch_restart_p, 1'b0, branch_restart);
   wire branch_d_for_i_p = code_44_or_45_d_for_i_p | code_46_d_for_i_p;
   digit_pulse br_d4i (rst, bp, branch_d_for_i_p, 1'b0, branch_d_for_i);
   
   wire overflow_sense_off_p = man_acc_reset | (code_47_dctl_p & d1);
   always @(posedge ap) begin
      if (rst) overflow_sense_latch <= 0;
      else if (overflow_sense_off_p) overflow_sense_latch <= 0;
      else if (overflow_sense_sig)   overflow_sense_latch <= 1;
   end;
   digit_pulse c47_d4i (rst, bp, ~overflow_sense_latch, 1'b1, code_47_d_for_i_sig);

   //-----------------------------------------------------------------------------
   // 69 -- Load Distributor
   //-----------------------------------------------------------------------------
   wire code_19_or_69_dctl_p =  opreg_t[`biq_q1] & opreg_u[`biq_b5] 
                              & opreg_u[`biq_q4] & d_control;
   assign code_69 = (code_19_or_69_dctl_p & opreg_t[`biq_b5]) | man_ro_storage;
   wire code_69_restart_p = code_69 & dist_back_sig;
   digit_pulse c69_rstrt (rst, ap, code_69_restart_p, 1'b0, code_69_restart_sig);
   
   //-----------------------------------------------------------------------------
   // 70 -- Read
   // 71 -- Punch
   //-----------------------------------------------------------------------------
   

   //-----------------------------------------------------------------------------
   // 84 -- Table Lookup
   //-----------------------------------------------------------------------------
   assign tlu_sig = d_control & ~single_intlk 
                              & opreg_t[`biq_b5] & opreg_t[`biq_q3]
                              & opreg_u[`biq_b0] & opreg_u[`biq_q4];
   
   //-----------------------------------------------------------------------------
   // 9x -- Branch on Distributor Digit
   //-----------------------------------------------------------------------------
   wire code_9x_dctl_p = opreg_t[`biq_b5] & opreg_t[`biq_q4] & d_control;
   wire code_90_ctrl = (d5_d10    & code_9x_dctl_p & opreg_u[`biq_b5])
                     | (d10_d1_d5 & code_9x_dctl_p & opreg_u[`biq_b0]);
   wire code_90_95_p = (d10 | d5) & opreg_u[`biq_q0] & code_90_ctrl;
   wire code_91_96_p = (d1  | d6) & opreg_u[`biq_q1] & code_90_ctrl;
   wire code_92_97_p = (d2  | d7) & opreg_u[`biq_q2] & code_90_ctrl;
   wire code_93_98_p = (d3  | d8) & opreg_u[`biq_q3] & code_90_ctrl;
   wire code_94_99_p = (d4  | d9) & opreg_u[`biq_q4] & code_90_ctrl;
   wire code_90_to_99_p   =  code_90_95_p | code_91_96_p | code_92_97_p 
                           | code_93_98_p | code_94_99_p;
   wire code_90_d_for_i_p = code_90_to_99_p & ontime_dist[`biq_b5] 
                                            & ontime_dist[`biq_q3];
   wire code_90_restart_p = code_90_to_99_p & ontime_dist[`biq_b5]
                                            & ontime_dist[`biq_q4];
   digit_pulse c90_d4i (rst, cp, code_90_d_for_i_p, 1'b0, code_90_d_for_i_sig);
   digit_pulse c90_rstrt (rst, cp, code_90_restart_p, 1'b0, code_90_restart_sig);

   //-----------------------------------------------------------------------------
   // 10's and 60's Opcode Derived Control Signals
   //
   //   SIGNAL        OPCODES
   //   ------------  ----------------------------------------------
   //   reset_sig     60, 61, 64, 65, 66, 67, 68
   //   no_reset_sig  10, 11, 14, 15, 16, 17, 18, 19, 69
   //   abs_sig       17, 18, 67, 68
   //   no_abs_sig    10, 11, 14, 15, 16, 19, 60, 61, 64, 65, 66, 69
   //   lower_sig     15, 16, 17, 18, 65, 66, 67, 68
   //   upper_sig     10, 11, 14, 60, 61, 64
   //   add_sig       10, 15, 17, 60, 65, 67
   //   subt_sig      11, 16, 18, 61, 66, 68
   //-----------------------------------------------------------------------------
   assign reset_sig    = ~code_19_or_69_dctl_p & d_control & opreg_t[`biq_b5] 
                                                           & opreg_t[`biq_q1];
   assign no_reset_sig = code_19_or_69_dctl_p | (d_control & opreg_t[`biq_b0] 
                                                           & opreg_t[`biq_q1]);
   assign abs_sig      = d_control & opreg_t[`biq_q1] & opreg_u[`biq_b5]
                                   & (opreg_u[`biq_q2] | opreg_u[`biq_q3]);
   assign no_abs_sig   = d_control & opreg_t[`biq_q1]
                                   & (opreg_u[`biq_q4] | opreg_u[`biq_q1]
                                      | opreg_u[`biq_q0]);
   assign lower_sig    = ena_arith_codes & dx & ~code_19_or_69_dctl_p 
                                         & opreg_u[`biq_b5];
   assign upper_sig    = ena_arith_codes & dx & opreg_u[`biq_b0];
   assign add_sig      = ena_arith_codes & (dx | d0)
                                         & (opreg_u[`biq_q2] | opreg_u[`biq_q0]);
   assign subt_sig     = ena_arith_codes & (dx | d0)
                                         & (opreg_u[`biq_q3] | opreg_u[`biq_q1]);

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Control commutator.
// 
// Additional Comments: See US 2959351, Fig. 81.
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

module ctl_commutator (
   input rst,
   input ap, bp, cp, dp,
   input dx, d1, d3, d7, d9, d10,
   input dxu, dxl,
   input wu, wl,
    
   input invalid_addr,
   input man_prog_reset, run_control_sw, program_start_sw, manual_ri_storage_sw,
   input manual_ro_storage_sw, manual_error_reset_sw,
   input half_or_pgm_stop,
    
   input prog_restart, error_stop, error_sense_restart, arith_restart,
   input stop_code, code_69, start_10s_60s, end_shift_cntrl, tlu_on,
   input end_of_operation, turn_on_op_intlk, decode_restarts,
    
   input use_d_for_i, dist_back_signal,
   input error_stop_ed0u, divide_overflow_stop, 
         exceed_address_or_stor_select_light,
   input [0:6] opreg_t, opreg_u,
   input addr_no_800x, addr_8001,
   input dynamic_addr_hit,
    
   output reg restart_a, restart_b,
   output reg i_alt, d_alt,
   output reg manual_stop_start, run_latch,
   output reg enable_ri,
   output manual_ri_storage, manual_ro_storage,
   output reg manual_start_ri_dist_latch,
   output i_control_pulse,
   output i_control, d_control, d_control_no_8001,
   output reg start_ri,
   output reg rips_ri_dist_intlk_a, rips_ri_dist_intlk_b, op_intlk, single_intlk,
   output rips, ri_dist,
   output reg acc_to_dist_ri_latch,
   output start_acc_to_dist_ri, end_acc_to_dist_ri,
   output reg rigs,
   output end_rigs
   );

   //-----------------------------------------------------------------------------
   // Restart control
   //-----------------------------------------------------------------------------
   wire ri_dist_restart, arith_codes_restart;
   assign all_restarts =   decode_restarts 
                         | prog_restart 
                         | ri_dist_restart 
                         | arith_codes_restart;
   
   always @(posedge ap)
      if (rst) begin
         restart_a <= 0;
      end else if (~invalid_addr & all_restarts & ~restart_b) begin
         restart_a <= 1;
      end else if (man_prog_reset | (restart_b & dx)) begin
         restart_a <= 0;
      end;
   
   always @(posedge ap)
      if (rst) begin
         restart_b <= 0;
      end else if (restart_a & dx) begin
         restart_b <= 1;
      end else if (restart_b & dx) begin
         restart_b <= 0;
      end;
   
   //-----------------------------------------------------------------------------
   // I / D alternation
   //-----------------------------------------------------------------------------
   assign run_control = run_control_sw & run_latch;
   assign d_control_no_8001 = opreg_t[`biq_q1] & d_control & ~addr_8001;
   wire   d_control_8001    = opreg_t[`biq_q1] & d_control & addr_8001;
   assign i_control = i_alt & ~restart_b & run_latch;
   assign d_control = d_alt & ~op_intlk & ~restart_b & run_control;
   
   always @(posedge dp)
      if (rst) begin
         i_alt <= 0;
         d_alt <= 1;
      end else if (man_prog_reset | use_d_for_i ) begin
         i_alt <= 0;
         d_alt <= 1;
      end else if (dx & restart_b & run_control) begin
         i_alt <= d_alt;
         d_alt <= i_alt;
      end;
   
   //-----------------------------------------------------------------------------
   // 8uS i_control_pulse is emited at the rising edge of (ap & i_control)
   //-----------------------------------------------------------------------------
   digit_pulse i_ctl (rst, ap, (i_control | manual_ro_storage | d_control_no_8001), 1'b0, i_control_pulse);
   
   //-----------------------------------------------------------------------------
   // CPU running control
   //-----------------------------------------------------------------------------
   assign manual_ri_storage = manual_ri_storage_sw & run_latch;
   assign manual_ro_storage = manual_ro_storage_sw & run_latch;
   
   always @(posedge ap)
      if (rst) begin
         manual_stop_start <= 0;
      end else if (dxl) begin
         manual_stop_start <= 0;
      end else if (program_start_sw & dxu & ~error_stop) begin
         manual_stop_start <= 1;
      end;
   
   wire turn_off_run_latch = half_or_pgm_stop & ~invalid_addr & all_restarts & ~restart_b;
   
   always @(posedge bp)
      if (rst) begin
         run_latch <= 0;
      end else if (   (manual_ri_storage & end_rigs)
                    | (manual_ro_storage & dist_back_signal)
                    | manual_error_reset_sw
                    | error_stop_ed0u
                    | divide_overflow_stop
                    | exceed_address_or_stor_select_light
                    | stop_code
                    | turn_off_run_latch ) begin
         run_latch <= 0;
      end else if (manual_stop_start | error_sense_restart) begin
         run_latch <= 1;
      end;

   
   //-----------------------------------------------------------------------------
   // Accumulator to distributor read-in control
   //-----------------------------------------------------------------------------
   
   //-----------------------------------------------------------------------------
   // Predicates for accumulator to distributor read-in. Instructions decoded:
   //  20 STL Store Lower in Memory
   //  21 STU Store Upper in Memory
   //  22 STDA Store Lower Data Address
   //  23 STIA Store Lower Inst Address
   //  24 STD Store Distributor
   //-----------------------------------------------------------------------------
   assign op_20_24_d_p         = opreg_t[`biq_b0] & opreg_t[`biq_q2] & opreg_u[`biq_q0] & d_control;
 
   assign op_20_24_d_intlk_p   = op_20_24_d_p & ~single_intlk;

   assign op_20_d_intlk_d10u_p = op_20_24_d_intlk_p & opreg_u[`biq_q0] & wu & d10;
   assign op_21_d_intlk_d10l_p = op_20_24_d_intlk_p & opreg_u[`biq_q1] & wl & d10;
   assign op_22_d_intlk_d3l_p  = op_20_24_d_intlk_p & opreg_u[`biq_q2] & wl & d3;
   assign op_23_d_intlk_dxl_p  = op_20_24_d_intlk_p & opreg_u[`biq_q3] & wl & dx;
   assign acc_to_dist_ri_on_p  = op_20_d_intlk_d10u_p | op_21_d_intlk_d10l_p | op_22_d_intlk_d3l_p | op_23_d_intlk_dxl_p;
   
   assign op_20_d_intlk_d9_p   = op_20_24_d_intlk_p & opreg_u[`biq_q0] & d9;
   
   assign op_21_d_intlk_d9u_p  = op_20_24_d_intlk_p & opreg_u[`biq_q1] & wu & d9;
  
   assign op_22_d_intlk_d7_p   = op_20_24_d_intlk_p & opreg_u[`biq_q2] & d7;
 
   assign op_23_d_intlk_d3_p   = op_20_24_d_intlk_p & opreg_u[`biq_q3] & d3;
   assign acc_to_dist_ri_off_p = op_20_d_intlk_d9_p | op_21_d_intlk_d9u_p | op_22_d_intlk_d7_p | op_23_d_intlk_d3_p;

   assign op_24_d_intlk_p      = op_20_24_d_intlk_p & opreg_u[`biq_q4];
   
   always @(posedge bp)
      if (rst) begin
         acc_to_dist_ri_latch <= 0;
      end else if (acc_to_dist_ri_off_p) begin
         acc_to_dist_ri_latch <= 0;
      end else if (acc_to_dist_ri_on_p) begin
         acc_to_dist_ri_latch <= 1;
      end;
   digit_pulse a2d_ri_on (rst, cp, acc_to_dist_ri_latch, 1'b0, start_acc_to_dist_ri);
   digit_pulse a2d_ri_off(rst, cp, ~acc_to_dist_ri_latch, 1'b1, end_acc_to_dist_ri);
   
   //-----------------------------------------------------------------------------
   // Manual read-in control
   //-----------------------------------------------------------------------------
   wire man_start_ri_dist_sig;
   digit_pulse ri_dist_sig (rst, ap, manual_ri_storage, 1'b0, man_start_ri_dist_sig);
   
   always @(posedge bp)
      if (rst) begin
         manual_start_ri_dist_latch <= 0;
      end
   
   //-----------------------------------------------------------------------------
   // Read-in control
   //-----------------------------------------------------------------------------
   always @(posedge dp)
      if (rst) begin
         enable_ri <= 0;
      end else if (man_prog_reset | start_ri) begin
         enable_ri <= 0;
      end else if (   start_acc_to_dist_ri
                    | man_start_ri_dist_sig
                    | i_control_pulse
                    | op_24_d_intlk_p ) begin
         enable_ri <= 1;
      end;
   
   always @(posedge cp)
      if (rst) begin
         start_ri <= 0;
      end else if (d1) begin
         start_ri <= 0;
      end else if (d9 & addr_no_800x & enable_ri & dynamic_addr_hit) begin
         start_ri <= 1;
      end;

   //-----------------------------------------------------------------------------
   // Read-in general storage
   //-----------------------------------------------------------------------------
   always @(posedge bp)
      if (rst) begin
         rigs <= 0;
      end else if (d10 & ~start_ri) begin
         rigs <= 0;
      end else if ((d10 & manual_ri_storage & start_ri) | (d10 & op_20_24_d_p & start_ri)) begin
         rigs <= 1;
      end;
   
   digit_pulse end_rigs_sig (rst, cp, ~rigs, 1'b1, end_rigs);

   //-----------------------------------------------------------------------------
   // Read-in distributor
   //-----------------------------------------------------------------------------
   assign ri_dist = (dx & start_ri & ~rips_ri_dist_intlk_b & (manual_ro_storage | d_control_no_8001)) | man_start_ri_dist_sig;
   assign ri_dist_restart = dist_back_sig_latch & end_rigs;
   reg dist_back_sig_latch;
   
   always @(posedge bp)
      if (rst) begin
         dist_back_sig_latch <= 0;
      end else if (man_prog_reset | dist_back_signal) begin
         dist_back_sig_latch <= 1;
      end else if (ri_dist | start_acc_to_dist_ri) begin
         dist_back_sig_latch <= 0;
      end;
   
   //-----------------------------------------------------------------------------
   // Read-in program step
   //-----------------------------------------------------------------------------
   assign rips = dx & start_ri & i_control & ~rips_ri_dist_intlk_b;
   
   //-----------------------------------------------------------------------------
   // Enable arithmetic codes latch
   //-----------------------------------------------------------------------------
   reg enable_arith_codes_latch;
   wire d_control_8001_sig;
   
   digit_pulse ac_on_sig (rst, ap, d_control_8001, 1'b0, d_control_8001_sig); 
   
   always @(posedge bp)
      if (rst) begin
         enable_arith_codes_latch <= 0;
      end else if ((arith_restart & dist_back_sig_latch) | code_69) begin
         enable_arith_codes_latch <= 0;
      end else if (d_control_8001_sig | (d_control_no_8001 & dist_back_signal)) begin
         enable_arith_codes_latch <= 1;
      end;

   digit_pulse ac_restart (rst, cp, ~arith_restart, 1'b1, arith_codes_restart);
   
   //-----------------------------------------------------------------------------
   // Interlocks
   //-----------------------------------------------------------------------------

   // RIPS-RID interlock A and B latches: These latches provide an interlock to
   // insure that only one RIPS or storage to distributor RI signal will be
   // developed on any commutator half cycle. Interlock B must be off to obtain
   // either RIPS or storage to distributor RI. Either signal when developed
   // turns on interlock A which turns off with the next D1 and turns interlock
   // B on. With interlock B on, one of the conditions necessary for RIPS or 
   // storage to distributor RI is removed. Interlock B is reset by any restart,
   // program reset, or manual RI.
   always @(posedge bp)
      if (rst) begin
         rips_ri_dist_intlk_a <= 0;
         rips_ri_dist_intlk_b <= 0;
      end else begin
         if (d1) begin
            rips_ri_dist_intlk_a <= 0;
         end else if (ri_dist | rips) begin
            rips_ri_dist_intlk_a <= 1;
         end
         if (all_restarts | man_prog_reset) begin
            rips_ri_dist_intlk_b <= 0;
         end else if (d1 & rips_ri_dist_intlk_a) begin
            rips_ri_dist_intlk_b <= 1;
         end
      end;

   // Operation interlock latch (791, Fig 81i): The off output of this latch is
   // one of the conditions needed for the development of the "D" control signal
   // and for the turning of the start RI latch on an 800X address. The arith-
   // metic and shift operations make use of the accumulator and distributor and
   // may require several word times for their completion. The restart signal on
   // these operations is developed during the first operation word interval.
   // Thus the commutator can advance concurrently with the performance of the
   // operation and allow the next instruction to be located, read into program
   // step storage, restart to "D" and transfer the new Op. code and "D" address
   // to the registers. At this point further advance of the commutator cannot
   // be allowed until the preceeding operation is completed. This interlocking
   // is done by allowing arithmetic and shift signals to turn on the operation
   // interlock latch, removing one of the necessary conditions for "D" control.
   // When an arithmetic or shift instruction has an 800X "I" address, the
   // location of the next instruction must be prevented until the preceeding
   // operation is complete, since the instruction itself is in the process of
   // being developed by the operation. This is accomplished by the Op.
   // interlock off condition necessary for turning on the start RI.
   wire set_op_intlk_sig;
   wire set_op_intlk_p = wl & opreg_t[`biq_q1] & enable_arith_codes_latch & ~single_intlk;
   digit_pulse op_ilk_sig (rst, ap, ~set_op_intlk_p, 1'b1, set_op_intlk_sig);
   always @(posedge bp)
      if (rst) begin
         op_intlk <= 0;
      end else if (man_prog_reset | end_of_operation) begin
         op_intlk <= 0;
      end else if (set_op_intlk_sig | turn_on_op_intlk) begin
         op_intlk <= 1;
      end;

   // Single interlock latch (857, Fig 81i): This latch when off, conditions
   // the development of arithmetic code signals, store code signals, shift
   // code signals and TLU signals. When any of these signals are developed
   // they cause the single interlock latch to be turned on thus preventing
   // further development of the same signals during successive word intervals
   // of the same commutator half cycle. The latch is turned off by any
   // restart or by program reset.
   wire single_intlk_set_p = (enable_ri & op_24_d_intlk_p)
                           | start_10s_60s
                           | end_shift_cntrl
                           | end_acc_to_dist_ri
                           | tlu_on;
   always @(posedge dp)
      if (rst) begin
         single_intlk <= 0;
      end else if (man_prog_reset | all_restarts) begin
         single_intlk <= 0;
      end else if (single_intlk_set_p) begin
         single_intlk <= 1;
      end;

endmodule

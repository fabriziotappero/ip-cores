`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Top level.
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

module toplev (
      input clk,
      input rst,

      input [0:6] cmd_digit_in, io_buffer_in,
      input [0:5] command,

      output [0:6] cmd_digit_out, display_digit,
      output busy, digit_ready, punch_card, read_card, card_digit_ready,
      output digit_sync, word_upper, 
      output [0:3] digit_ctr
  );
   
   wire ap, bp, cp, dp;
   wire dx, d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10,
        d1_d5, d5_dx, d5_d10, d1_dx, d5_d9, d10_d1_d5,
        dxl, dxu, d0l, d0u, d1l, d1u, d2l, d10u;
   wire w0, w1, w2, w3, w4, w5, w6, w7, w8, w9,
        wl, wu, ewl;
   wire s0, s1, s2, s3, s4, hp;
   wire [0:9] digit_idx;
   wire [0:3] early_idx, ontime_idx;
   
   assign digit_sync = bp;
   assign digit_ctr = ontime_idx;
   assign word_upper = wu;
   
   timing tm (
    .clk(clk), 
    .rst(rst), 
    .ap(ap), 
    .bp(bp), 
    .cp(cp), 
    .dp(dp), 
    .dx(dx), 
    .d0(d0), 
    .d1(d1), 
    .d2(d2), 
    .d3(d3), 
    .d4(d4), 
    .d5(d5), 
    .d6(d6), 
    .d7(d7), 
    .d8(d8), 
    .d9(d9), 
    .d10(d10), 
    .d1_d5(d1_d5), 
    .d5_dx(d5_dx), 
    .d5_d10(d5_d10), 
    .d1_dx(d1_dx), 
    .d5_d9(d5_d9), 
    .d10_d1_d5(d10_d1_d5), 
    .dxl(dxl), 
    .dxu(dxu), 
    .d0l(d0l), 
    .d0u(d0u), 
    .d1l(d1l), 
    .d1u(d1u), 
    .d2l(d2l), 
    .d10u(d10u), 
    .w0(w0), 
    .w1(w1), 
    .w2(w2), 
    .w3(w3), 
    .w4(w4), 
    .w5(w5), 
    .w6(w6), 
    .w7(w7), 
    .w8(w8), 
    .w9(w9), 
    .wl(wl), 
    .wu(wu), 
    .ewl(ewl), 
    .s0(s0), 
    .s1(s1), 
    .s2(s2), 
    .s3(s3), 
    .s4(s4), 
    .hp(hp), 
    .digit_idx(digit_idx), 
    .early_idx(early_idx), 
    .ontime_idx(ontime_idx)
   );
   
   //-----------------------------------------------------------------------------
   // Adder input muxes
   //-----------------------------------------------------------------------------
   wire [0:6] aa_entry_a, ab_entry_b;
   
   //-----------------------------------------------------------------------------
   // Accumulator
   //-----------------------------------------------------------------------------
   wire [0:6] ac_early_out, ac_ontime_out, ac_ped_out;
   
   //-----------------------------------------------------------------------------
   // Adder
   //-----------------------------------------------------------------------------
   wire [0:6] ad_adder_out;
   wire ad_carry_test, ad_no_carry_test, ad_d0l_carry_sig, ad_overflow_stop,
        ad_overflow_light, ad_overflow_sense_sig;

   //-----------------------------------------------------------------------------
   // Address register
   //-----------------------------------------------------------------------------
   wire [0:6] ar_addr_th, ar_addr_h, ar_addr_t, ar_addr_u;
   wire ar_dynamic_addr_hit, ar_addr_no_800x, ar_addr_8000, ar_addr_8001,
        ar_addr_8002, ar_addr_8003, ar_addr_8002_8003, ar_invalid_addr;
   
   //-----------------------------------------------------------------------------
   // Arithmetic control
   //-----------------------------------------------------------------------------
   wire at_end_of_operation, at_arith_restart_d5, at_zero_insert, at_carry_blank,
        at_no_carry_blank, at_carry_insert, at_no_carry_insert, at_compl_adj,
        at_divide, at_multiply, at_acc_true_add, at_half_correct, at_hc_add_5;
   
   //-----------------------------------------------------------------------------
   // Accumulator and TLU validity checking
   //-----------------------------------------------------------------------------
   wire ca_acc_zero, ca_acc_no_zero, ca_check_latch;

   //-----------------------------------------------------------------------------
   // Control commutator
   //-----------------------------------------------------------------------------
   wire cc_restart_a, cc_restart_b, cc_i_alt, cc_d_alt, cc_man_stop_start,
        cc_run_latch, cc_enable_ri, cc_man_ri_storage, cc_man_ro_storage,
        cc_man_start_ri_dist_latch, cc_i_control_pulse, cc_i_control,
        cc_d_control, cc_d_control_no_8001, cc_start_ri, cc_rips_ri_dist_intlk_a,
        cc_rips_ri_dist_intlk_b, cc_op_intlk, cc_single_intlk, cc_rips,
        cc_ri_dist, cc_acc_to_dist_ri_latch, cc_start_acc_to_dist_ri,
        cc_end_acc_to_dist_ri, cc_rigs, cc_end_rigs;
   
   //-----------------------------------------------------------------------------
   // Register validity checking
   //-----------------------------------------------------------------------------
   wire ck_error_stop, ck_acc_check_light, ck_prog_check_light, 
        ck_dist_check_light;

   //-----------------------------------------------------------------------------
   // Decode control
   //-----------------------------------------------------------------------------
   wire dc_all_restarts, dc_use_d_for_i, dc_turn_on_single_intlk,
        dc_turn_on_op_intlk, dc_stop_code, dc_code_69, dc_tlu_sig, dc_mult_sig,
        dc_divide_sig, dc_reset_sig, dc_no_reset_sig, dc_abs_sig, dc_no_abs_sig,
        dc_lower_sig, dc_upper_sig, dc_add_sig, dc_subt_sig, dc_right_shift_sig,
        dc_left_shift_sig, dc_half_correct_sig, dc_shift_count_sig,
        dc_end_shift_control, dc_overflow_sense_latch;
         
   //-----------------------------------------------------------------------------
   // Distributor
   //-----------------------------------------------------------------------------
   wire [0:6] ds_early_out, ds_ontime_out;
   wire ds_back_sig;
   
   //-----------------------------------------------------------------------------
   // Error stop
   //-----------------------------------------------------------------------------
   wire es_err_stop, es_err_sense_light, es_err_stop_ed0u, es_err_sense_restart,
        es_restart_reset;
        
   //-----------------------------------------------------------------------------
   // General storage
   //-----------------------------------------------------------------------------
   wire [0:4] gs_out;
   wire gs_double_write, gs_no_write;
   
   //-----------------------------------------------------------------------------
   // Opcode register
   //-----------------------------------------------------------------------------
   wire [0:6] op_opreg_t, op_opreg_u;
   wire op_ri_addr_reg;
   
   //-----------------------------------------------------------------------------
   // Operator controls
   //-----------------------------------------------------------------------------
   wire [0:6] oc_data_out, oc_addr_out, oc_console_out, oc_display_digit;
   wire oc_console_to_addr, oc_acc_ri_console;
   wire [0:14] oc_gs_ram_addr;
   wire oc_read_gs, oc_write_gs;
   wire oc_pgm_start, oc_pgm_stop, oc_err_reset, oc_err_sense_reset;
   wire oc_run_control, oc_half_or_pgm_stop, oc_ri_storage, oc_ro_storage, 
        oc_storage_control, oc_err_restart_sw, oc_ovflw_stop_sw, 
        oc_ovflw_sense_sw, oc_pgm_stop_sw;
   wire oc_man_pgm_reset, oc_man_acc_reset, oc_set_8000, oc_reset_8000,
        oc_hard_reset;
   wire oc_restart_reset_busy;
   assign display_digit = oc_display_digit;
     
   //-----------------------------------------------------------------------------
   // Program step register
   //-----------------------------------------------------------------------------
   wire [0:6] ps_early_out, ps_ontime_out, ps_ped_out;
   wire ps_restart_sig;
   
   //-----------------------------------------------------------------------------
   // Storage select
   //-----------------------------------------------------------------------------
   wire [0:6] ss_selected_out;
 
   //-----------------------------------------------------------------------------
   // Table look-up
   //-----------------------------------------------------------------------------
   wire tl_tlu_on, tl_early_dist_zero_entry, tl_early_dist_zero_control,
        tl_prog_to_acc_add, tl_prog_add, tl_prog_add_d0, tl_prog_ped_regen,
        tl_tlu_band_change, tl_dist_blank_gate, tl_sel_stor_add_gate,
        tl_ontime_dist_add_gate, tl_upper_lower_check;
   wire [0:9] tl_special_digit;
   
   //-----------------------------------------------------------------------------
   // Translators
   //-----------------------------------------------------------------------------
   wire tr_gs_write;
   wire [0:4] tr_gs_in;
   wire [0:6] tr_gs_out;
   
   //-----------------------------------------------------------------------------
   // Accumulator zero check
   //-----------------------------------------------------------------------------
   wire zc_acc_no_zero_test, zc_acc_zero_test;

   add_in_a aa (
    .acc_early_out(ac_early_out), 
    .acc_ontime_out(ac_ontime_out), 
    .prog_step_early_out(ps_early_out), 
    .select_storage_out(ss_selected_out), 
    .addr_u(ar_addr_u), 
    .acc_true_add_gate(at_acc_true_add),
    .acc_compl_add_gate(1'b0),               // 85r
    .left_shift_gate(1'b0),                  // 85b 
    .prog_step_add_gate(tl_prog_add),
    .shift_num_gate(1'b0),                   // 85a
    .select_stor_add_gate(tl_sel_stor_add_gate), 
    .adder_entry_a(aa_entry_a)
    );
   
   add_in_b ab (
    .dist_early_out(ds_early_out), 
    .dist_ontime_out(ds_ontime_out), 
    .special_int_entry(tl_special_digit), 
    .ontime_dist_add_gate_tlu(tl_ontime_dist_add_gate), 
    .dist_compl_add_gate(1'b0),              // 85r
    .upper_lower_check(tl_upper_lower_check), 
    .dist_blank_gate(tl_dist_blank_gate), 
    .early_dist_zero_entry(tl_early_dist_zero_entry),
    .dist_true_add_gate(1'b0),               // 85r
    .adder_entry_b(ab_entry_b)
    );
    
   accumulator ac (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .bp(bp), 
    .dp(dp),
    .dx(dx),    
    .d1(d1), 
    .d2(d2), 
    .d10(d10),
    .dxu(dxu), 
    .d0u(d0u), 
    .wu(wu), 
    .wl(wl), 
    .adder_out(ad_adder_out), 
    .console_out(oc_console_out),
    .acc_regen_gate(1'b1),                   // 85c
    .right_shift_gate(1'b0),                 // 85f
    .acc_ri_gate(1'b0),                      // 85c
    .acc_ri_console(oc_acc_ri_console),    
    .zero_shift_count(1'b0),                 // 85b
    .man_acc_reset(oc_man_acc_reset), 
    .reset_op(dc_reset_sig),
    .early_idx(early_idx), 
    .ontime_idx(ontime_idx), 
    .early_out(ac_early_out), 
    .ontime_out(ac_ontime_out), 
    .ped_out(ac_ped_out)
    );

   adder ad (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .bp(bp), 
    .dp(dp), 
    .dxu(dxu), 
    .dx(dx), 
    .d0u(d0u), 
    .d1(d1), 
    .d1l(d1l), 
    .d10(d10), 
    .d10u(d10u), 
    .wl(wl), 
    .entry_a(aa_entry_a), 
    .entry_b(ab_entry_b), 
    .tlu_on(tl_tlu_on),
    .left_shift_off(1'b1),                   // 85d
    .left_shift_on(1'b0),                    // 85d
    .no_carry_insert(at_no_carry_insert),
    .no_carry_blank(at_no_carry_blank),
    .carry_insert(at_carry_insert),
    .carry_blank(at_carry_blank),
    .zero_insert(at_zero_insert),
    .error_reset(oc_err_reset), 
    .quotient_digit_on(1'b0),                // 85p
    .overflow_stop_sw(oc_ovflw_stop_sw),
    .overflow_sense_sw(oc_ovflw_sense_sw),
    .mult_div_off(1'b0),                     // 85k
    .dist_true_add_gate(1'b0),               // 85r
    .acc_true_add_latch(at_acc_true_add),
    .shift_overflow(1'b0),                   // 85b
    .adder_out(ad_adder_out), 
    .carry_test(ad_carry_test), 
    .no_carry_test(ad_no_carry_test), 
    .d0l_carry_sig(ad_d0l_carry_sig), 
    .overflow_stop(ad_overflow_stop), 
    .overflow_light(ad_overflow_light), 
    .overflow_sense_sig(ad_overflow_sense_sig)
    );
    
   addr_reg ar (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .bp(bp), 
    .dx(dx), 
    .d1(d1), 
    .d2(d2), 
    .d3(d3), 
    .d4(d4), 
    .d5(d5), 
    .d6(d6), 
    .d7(d7), 
    .d8(d8), 
    .d9(d9), 
    .w0(w0), 
    .w1(w1), 
    .w2(w2), 
    .w3(w3), 
    .w4(w4), 
    .w5(w5), 
    .w6(w6), 
    .w7(w7), 
    .w8(w8), 
    .w9(w9), 
    .s0(s0), 
    .s1(s1), 
    .s2(s2), 
    .s3(s3), 
    .s4(s4), 
    .error_reset(oc_err_reset), 
    .restart_a(cc_restart_a),
    .set_8000(oc_set_8000), 
    .reset_8000(oc_reset_8000), 
    .tlu_band_change(tl_tlu_band_change), 
    .double_write(gs_double_write), 
    .no_write(gs_no_write), 
    .bs_to_gs(1'b0),                         // 87b ***
    .rigs(cc_rigs), 
    .ps_reg_in(ps_ontime_out), 
    .console_in(oc_addr_out), 
    .ri_addr_reg(op_ri_addr_reg), 
    .console_to_addr_reg(oc_console_to_addr), 
    .addr_th(ar_addr_th), 
    .addr_h(ar_addr_h), 
    .addr_t(ar_addr_t), 
    .addr_u(ar_addr_u), 
    .dynamic_addr_hit(ar_dynamic_addr_hit), 
    .addr_no_800x(ar_addr_no_800x), 
    .addr_8000(ar_addr_8000), 
    .addr_8001(ar_addr_8001), 
    .addr_8002(ar_addr_8002), 
    .addr_8003(ar_addr_8003), 
    .addr_8002_8003(ar_addr_8002_8003), 
    .invalid_addr(ar_invalid_addr)
    );
    
   arith_ctl at (
    .rst(rst), 
    .ap(ap), 
    .bp(bp), 
    .cp(cp), 
    .dx(dx), 
    .d0(d0), 
    .d5(d5), 
    .d9(d9), 
    .dxl(dxl), 
    .d0l(d0l), 
    .d1l(d1l), 
    .wu(wu), 
    .adder_out(ad_adder_out), 
    .man_acc_reset(ac_man_acc_reset), 
    .overflow_stop(ad_overflow_stop), 
    .prog_add_d0(tl_prog_add_d0), 
    .half_correct_sig(dc_half_correct_sig), 
    .end_of_operation(at_end_of_operation), 
    .arith_restart_d5(at_arith_restart_d5), 
    .zero_insert(at_zero_insert), 
    .carry_blank(at_carry_blank), 
    .no_carry_blank(at_no_carry_blank), 
    .carry_insert(at_carry_insert), 
    .no_carry_insert(at_no_carry_insert), 
    .compl_adj(at_compl_adj), 
    .divide(at_divide), 
    .multiply(at_multiply), 
    .acc_true_add(at_acc_true_add), 
    .half_correct(at_half_correct), 
    .hc_add_5(at_hc_add_5)
    );
    
   check_acc_tlu ca (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .bp(bp), 
    .d0(d0), 
    .d2(d2), 
    .d1_dx(d1_dx), 
    .acc_ped_out(ac_ped_out), 
    .sel_store_add_gate(tl_sel_stor_add_gate), 
    .err_reset(oc_err_reset), 
    .carry_test_latch(ad_carry_test), 
    .no_carry_test_latch(ad_no_carry_test), 
    .acc_zero(ca_acc_zero), 
    .acc_no_zero(ca_acc_no_zero), 
    .check_latch(ca_check_latch)
    );
    
   ctl_commutator cc (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .bp(bp), 
    .cp(cp), 
    .dp(dp), 
    .dx(dx), 
    .d1(d1), 
    .d3(d3), 
    .d7(d7), 
    .d9(d9), 
    .d10(d10), 
    .dxu(dxu), 
    .dxl(dxl), 
    .wu(wu), 
    .wl(wl), 
    .invalid_addr(ar_invalid_addr), 
    .man_prog_reset(oc_man_pgm_reset), 
    .run_control_sw(oc_run_control), 
    .program_start_sw(oc_pgm_start), 
    .manual_ri_storage_sw(oc_ri_storage), 
    .manual_ro_storage_sw(oc_ro_storage), 
    .manual_error_reset_sw(oc_err_reset), 
    .half_or_pgm_stop(oc_half_or_pgm_stop), 
    .prog_restart(ps_restart_sig), 
    .error_stop(es_err_stop), 
    .error_sense_restart(es_err_sense_restart), 
    .arith_restart(at_arith_restart_d5),        // ****
    .stop_code(dc_stop_code), 
    .code_69(dc_code_69), 
    .start_10s_60s(dc_turn_on_single_intlk), 
    .end_shift_cntrl(dc_end_shift_control),
    .tlu_on(tl_tlu_on), 
    .end_of_operation(at_end_of_operation),
    .turn_on_op_intlk(dc_turn_on_op_intlk), 
    .decode_restarts(dc_all_restarts), 
    .use_d_for_i(dc_use_d_for_i), 
    .dist_back_signal(ds_back_sig), 
    .error_stop_ed0u(es_err_stop_ed0u), 
    .divide_overflow_stop(1'b0),             // 68a ***
    .exceed_address_or_stor_select_light(1'b0), // 71a ***
    .opreg_t(op_opreg_t), 
    .opreg_u(op_opreg_u), 
    .addr_no_800x(ar_addr_no_800x), 
    .addr_8001(ar_addr_8001), 
    .dynamic_addr_hit(ar_dynamic_addr_hit), 
    .restart_a(cc_restart_a), 
    .restart_b(cc_restart_b), 
    .i_alt(cc_i_alt), 
    .d_alt(cc_d_alt), 
    .manual_stop_start(cc_man_stop_start), 
    .run_latch(cc_run_latch), 
    .enable_ri(cc_enable_ri), 
    .manual_ri_storage(cc_man_ri_storage), 
    .manual_ro_storage(cc_man_ro_storage), 
    .manual_start_ri_dist_latch(cc_man_start_ri_dist_latch), 
    .i_control_pulse(cc_i_control_pulse), 
    .i_control(cc_i_control), 
    .d_control(cc_d_control), 
    .d_control_no_8001(cc_d_control_no_8001), 
    .start_ri(cc_start_ri), 
    .rips_ri_dist_intlk_a(cc_rips_ri_dist_intlk_a), 
    .rips_ri_dist_intlk_b(cc_rips_ri_dist_intlk_b), 
    .op_intlk(cc_op_intlk), 
    .single_intlk(cc_single_intlk), 
    .rips(cc_rips), 
    .ri_dist(cc_ri_dist), 
    .acc_to_dist_ri_latch(cc_acc_to_dist_ri_latch), 
    .start_acc_to_dist_ri(cc_start_acc_to_dist_ri), 
    .end_acc_to_dist_ri(cc_end_acc_to_dist_ri), 
    .rigs(cc_rigs), 
    .end_rigs(cc_end_rigs)
    );
    
   checking ck (
    .rst(oc_hard_reset), 
    .bp(bp), 
    .d1_dx(d1_dx), 
    .acc_ontime(ac_ontime_out), 
    .prog_ontime(ps_ontime_out), 
    .dist_ontime(ds_ontime_out), 
    .error_reset(oc_err_reset), 
    .tlu_or_zero_check(ca_check_latch), 
    .error_stop(ck_error_stop), 
    .acc_check_light(ck_acc_check_light), 
    .prog_check_light(ck_prog_check_light), 
    .dist_check_light(ck_dist_check_light)
    );
    
   decode_ctl dc (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .bp(bp), 
    .cp(cp), 
    .dx(dx), 
    .d0(d0), 
    .d1(d1), 
    .d2(d2), 
    .d3(d3), 
    .d4(d4), 
    .d5(d5), 
    .d6(d6), 
    .d7(d7), 
    .d8(d8), 
    .d9(d9), 
    .d10(d10), 
    .d5_d10(d5_d10), 
    .d10_d1_d5(d10_d1_d5), 
    .dxl(dxl), 
    .dxu(dxu), 
    .d10u(d10u), 
    .opreg_t(op_opreg_t), 
    .opreg_u(op_opreg_u), 
    .addr_u(ar_addr_u), 
    .ontime_dist(ds_ontime_out), 
    .man_ro_storage(cc_man_ro_storage),
    .dist_back_sig(ds_back_sig), 
    .d_control(cc_d_control),
    .ena_arith_codes(1'b0),                  // 81i ***
    .pgm_stop_sw(oc_pgm_stop_sw),
    .acc_zero_test(zc_acc_zero_test), 
    .acc_no_zero_test(zc_acc_no_zero_test), 
    .acc_plus_test(1'b0),                    // 85t
    .acc_minus_test(1'b0),                   // 85t
    .single_intlk(cc_single_intlk),
    .arith_restart(at_arith_restart_d5),                    // ****
    .overflow_sense_sig(ad_overflow_sense_sig), 
    .man_acc_reset(oc_man_acc_reset), 
    .all_restarts(dc_all_restarts),
    .use_d_for_i(dc_use_d_for_i), 
    .turn_on_single_intlk(dc_turn_on_single_intlk), 
    .turn_on_op_intlk(dc_turn_on_op_intlk), 
    .stop_code(dc_stop_code), 
    .code_69(dc_code_69), 
    .tlu_sig(dc_tlu_sig), 
    .mult_sig(dc_mult_sig), 
    .divide_sig(dc_divide_sig), 
    .reset_sig(dc_reset_sig), 
    .no_reset_sig(dc_no_reset_sig), 
    .abs_sig(dc_abs_sig), 
    .no_abs_sig(dc_no_abs_sig), 
    .lower_sig(dc_lower_sig), 
    .upper_sig(dc_upper_sig), 
    .add_sig(dc_add_sig), 
    .subt_sig(dc_subt_sig), 
    .right_shift_sig(dc_right_shift_sig), 
    .left_shift_sig(dc_left_shift_sig), 
    .half_correct_sig(dc_half_correct_sig), 
    .shift_count_sig(dc_shift_count_sig),
    .end_shift_control(dc_end_shift_control), 
    .overflow_sense_latch(dc_overflow_sense_latch)
    );

   distributor ds (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .cp(cp), 
    .dp(dp), 
    .dx(dx), 
    .d0(d0), 
    .d10(d10), 
    .selected_storage(ss_selected_out), 
    .ri_dist(cc_ri_dist), 
    .acc_ontime(ac_ontime_out), 
    .start_acc_dist_ri(cc_start_acc_to_dist_ri), 
    .end_acc_dist_ri(cc_end_acc_to_dist_ri), 
    .acc_dist_ri(cc_acc_to_dist_ri_latch), 
    .man_acc_reset(oc_man_acc_reset), 
    .early_idx(early_idx), 
    .ontime_idx(ontime_idx), 
    .ontime_out(ds_ontime_out), 
    .early_out(ds_early_out), 
    .dist_back_sig(ds_back_sig)
    );
    
   error_stop es (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .dp(dp), 
    .dxu(dxu), 
    .d10(d10), 
    .wl(wl), 
    .err_restart_sw(oc_err_restart_sw), 
    .err_reset(oc_err_reset), 
    .err_sense_reset(oc_err_sense_reset), 
    .clock_err_sig(1'b0),                    // not possible
    .err_stop_sig(ck_error_stop),
    .restart_reset_busy(oc_restart_reset_busy), 
    .err_stop(es_err_stop),
    .err_sense_light(es_err_sense_light), 
    .err_stop_ed0u(es_err_stop_ed0u), 
    .err_sense_restart(es_err_sense_restart), 
    .restart_reset(es_restart_reset)
    );
    
   gen_store gs (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .dp(dp), 
    .write_gate(tr_gs_write), 
    .addr_th(ar_addr_th), 
    .addr_h(ar_addr_h), 
    .addr_t(ar_addr_t), 
    .dynamic_addr(digit_idx), 
    .gs_in(tr_gs_in), 
    .console_ram_addr(oc_gs_ram_addr), 
    .console_read_gs(oc_read_gs),
    .console_write_gs(oc_write_gs),
    .gs_out(gs_out), 
    .double_write(gs_double_write), 
    .no_write(gs_no_write)
    );

   operator_ctl oc (
    .rst(rst),
    .clk(clk),
    .ap(ap), 
    .dp(dp), 
    .dx(dx), 
    .d0(d0), 
    .d1(d1), 
    .d2(d2), 
    .d3(d3), 
    .d4(d4), 
    .d5(d5), 
    .d6(d6),
    .d9(d9),    
    .d10(d10), 
    .wu(wu),
    .wl(wl),
    .hp(hp), 
    .early_idx(early_idx), 
    .ontime_idx(ontime_idx), 
    .cmd_digit_in(cmd_digit_in), 
    .io_buffer_in(io_buffer_in), 
    .gs_in(tr_gs_out),
    .acc_ontime(ac_ontime_out),
    .dist_ontime(ds_ontime_out),
    .prog_ontime(ps_ontime_out),
    .command(command), 
    .restart_reset(es_restart_reset),
    .data_out(oc_data_out), 
    .addr_out(oc_addr_out), 
    .console_out(oc_console_out),
    .display_digit(oc_display_digit),
    .console_to_addr(oc_console_to_addr),
    .acc_ri_console(oc_acc_ri_console),    
    .gs_ram_addr(oc_gs_ram_addr),
    .read_gs(oc_read_gs),
    .write_gs(oc_write_gs),
    .pgm_start(oc_pgm_start), 
    .pgm_stop(oc_pgm_stop), 
    .err_reset(oc_err_reset), 
    .err_sense_reset(oc_err_sense_reset), 
    .run_control(oc_run_control), 
    .half_or_pgm_stop(oc_half_or_pgm_stop), 
    .ri_storage(oc_ri_storage), 
    .ro_storage(oc_ro_storage), 
    .storage_control(oc_storage_control), 
    .err_restart_sw(oc_err_restart_sw),
    .ovflw_stop_sw(oc_ovflw_stop_sw),
    .ovflw_sense_sw(oc_ovflw_sense_sw),
    .pgm_stop_sw(oc_pgm_stop_sw),
    .man_pgm_reset(oc_man_pgm_reset), 
    .man_acc_reset(oc_man_acc_reset), 
    .set_8000(oc_set_8000), 
    .reset_8000(oc_reset_8000),
    .hard_reset(oc_hard_reset),
    .cmd_digit_out(cmd_digit_out), 
    .busy(busy), 
    .digit_ready(digit_ready),
    .restart_reset_busy(oc_restart_reset_busy), 
    .punch_card(punch_card), 
    .read_card(read_card), 
    .card_digit_ready(card_digit_ready)
    );

   op_reg op (
    .rst(oc_hard_reset), 
    .cp(cp), 
    .d0(d0), 
    .d9(d9), 
    .d10(d10), 
    .d1_d5(d1_d5), 
    .d5_dx(d5_dx), 
    .restart_a(cc_restart_a), 
    .restart_b(cc_restart_b), 
    .d_alt(cc_d_alt), 
    .i_alt(cc_i_alt), 
    .tlu_band_change(tl_tlu_band_change), 
    .man_prog_reset(oc_man_pgm_reset), 
    .prog_step_ped(ps_ped_out), 
    .opreg_t(op_opreg_t), 
    .opreg_u(op_opreg_u), 
    .ri_addr_reg(op_ri_addr_reg)
    );

   prog_step ps (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .dp(dp), 
    .dx(dx), 
    .d0(d0), 
    .d10(d10), 
    .early_idx(early_idx), 
    .ontime_idx(ontime_idx), 
    .man_prog_reset(oc_man_pgm_reset), 
    .rips(cc_rips), 
    .adder_out(ad_adder_out), 
    .sel_store_out(ss_selected_out), 
    .prog_ped_regen(tl_prog_ped_regen), 
    .prog_add(tl_prog_add), 
    .early_out(ps_early_out), 
    .ontime_out(ps_ontime_out), 
    .ped_out(ps_ped_out), 
    .prog_restart_sig(ps_restart_sig)
    );
    
   store_select ss (
    .d0(d0), 
    .d1_dx(d1_dx), 
    .addr_no_800x(ar_addr_no_800x), 
    .addr_8000(ar_addr_8000), 
    .addr_8001(ar_addr_8001), 
    .addr_8002_8003(ar_addr_8002_8003), 
    .addr_hot_8000(1'b0),                    // *** see cc 
    .acc_ontime(ac_ontime_out),
    .dist_ontime(ds_ontime_out), 
    .gs_out(tr_gs_out), 
    .console_switches(oc_data_out), 
    .acc_plus(1'b0),                         // 85o
    .acc_minus(1'b0),                        // 85o
    .selected_out(ss_selected_out)
    );

   tlu tl (
    .rst(oc_hard_reset), 
    .ap(ap), 
    .bp(bp), 
    .dx(dx), 
    .d0(d0), 
    .d4(d4), 
    .d5(d5), 
    .d10(d10), 
    .dxl(dxl), 
    .d0l(d0l), 
    .d10u(d10u), 
    .w0(w0), 
    .w1(w1), 
    .w2(w2), 
    .w3(w3), 
    .w4(w4), 
    .w5(w5), 
    .w6(w6), 
    .w7(w7), 
    .w8(w8), 
    .w9(w9), 
    .wl(wl), 
    .wu(wu), 
    .s0(s0), 
    .s1(s1), 
    .s2(s2), 
    .s3(s3), 
    .s4(s4), 
    .tlu_sig(dc_tlu_sig), 
    .upper_sig(dc_upper_sig), 
    .lower_sig(dc_lower_sig), 
    .divide_on(at_divide),
    .mult_nozero_edxl(1'b0),                 // 85j
    .carry_test_latch(ad_carry_test), 
    .tlu_or_acc_zero_check(ca_check_latch), 
    .man_acc_reset(oc_man_acc_reset), 
    .reset_sig(dc_reset_sig), 
    .no_reset_sig(dc_no_reset_sig), 
    .acc_minus_sign(1'b0),                   // 85t
    .compl_adj(at_compl_adj),
    .quot_digit_on(1'b0),                    // 85p
    .dist_compl_add(1'b0),                   // 85p
    .any_left_shift_on(1'b0),                // 85j
    .right_shift_on(1'b0),                   // 85a
    .left_shift_on(1'b0),                    // 85b
    .mult_div_left_shift(1'b0),              // 85k
    .sig_digit_on(1'b0),                     // 85j
    .hc_add_5(at_hc_add_5),
    .mult_on(at_multiply),
    .acc_true_add_gate(at_acc_true_add),
    .tlu_on(tl_tlu_on), 
    .early_dist_zero_entry(tl_early_dist_zero_entry), 
    .early_dist_zero_control(tl_early_dist_zero_control), 
    .prog_to_acc_add(tl_prog_to_acc_add), 
    .prog_add(tl_prog_add), 
    .prog_add_d0(tl_prog_add_d0), 
    .prog_ped_regen(tl_prog_ped_regen), 
    .special_digit(tl_special_digit), 
    .tlu_band_change(tl_tlu_band_change), 
    .dist_blank_gate(tl_dist_blank_gate), 
    .sel_stor_add_gate(tl_sel_stor_add_gate), 
    .ontime_dist_add_gate(tl_ontime_dist_add_gate), 
    .upper_lower_check(tl_upper_lower_check)
    );

    translators tr (
    .dist_early_out(`biq_blank), 
    .bs_out(`biq_blank), 
    .console_out(oc_console_out),
    .ri_gs(cc_rigs), 
    .ri_bs(1'b0),                            // 87b ***
    .ri_console(oc_write_gs),
    .n800x(ar_addr_no_800x),
    .console_read_gs(oc_read_gs),    
    .gs_out(gs_out), 
    .gs_write(tr_gs_write), 
    .gs_in(tr_gs_in), 
    .gs_biq_out(tr_gs_out)
    );
   
   zero_check zc (
    .rst(oc_hard_reset), 
    .bp(bp), 
    .d0(d0), 
    .d1_dx(d1_dx), 
    .wu(wu), 
    .acc_no_zero(ca_acc_no_zero), 
    .acc_no_zero_test(zc_acc_no_zero_test), 
    .acc_zero_test(zc_acc_zero_test)
    );

endmodule
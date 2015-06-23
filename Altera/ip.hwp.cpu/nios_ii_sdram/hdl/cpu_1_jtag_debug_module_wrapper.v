//Legal Notice: (C)2012 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_1_jtag_debug_module_wrapper (
                                         // inputs:
                                          MonDReg,
                                          break_readreg,
                                          clk,
                                          dbrk_hit0_latch,
                                          dbrk_hit1_latch,
                                          dbrk_hit2_latch,
                                          dbrk_hit3_latch,
                                          debugack,
                                          monitor_error,
                                          monitor_ready,
                                          reset_n,
                                          resetlatch,
                                          tracemem_on,
                                          tracemem_trcdata,
                                          tracemem_tw,
                                          trc_im_addr,
                                          trc_on,
                                          trc_wrap,
                                          trigbrktype,
                                          trigger_state_1,

                                         // outputs:
                                          jdo,
                                          jrst_n,
                                          st_ready_test_idle,
                                          take_action_break_a,
                                          take_action_break_b,
                                          take_action_break_c,
                                          take_action_ocimem_a,
                                          take_action_ocimem_b,
                                          take_action_tracectrl,
                                          take_action_tracemem_a,
                                          take_action_tracemem_b,
                                          take_no_action_break_a,
                                          take_no_action_break_b,
                                          take_no_action_break_c,
                                          take_no_action_ocimem_a,
                                          take_no_action_tracemem_a
                                       )
;

  output  [ 37: 0] jdo;
  output           jrst_n;
  output           st_ready_test_idle;
  output           take_action_break_a;
  output           take_action_break_b;
  output           take_action_break_c;
  output           take_action_ocimem_a;
  output           take_action_ocimem_b;
  output           take_action_tracectrl;
  output           take_action_tracemem_a;
  output           take_action_tracemem_b;
  output           take_no_action_break_a;
  output           take_no_action_break_b;
  output           take_no_action_break_c;
  output           take_no_action_ocimem_a;
  output           take_no_action_tracemem_a;
  input   [ 31: 0] MonDReg;
  input   [ 31: 0] break_readreg;
  input            clk;
  input            dbrk_hit0_latch;
  input            dbrk_hit1_latch;
  input            dbrk_hit2_latch;
  input            dbrk_hit3_latch;
  input            debugack;
  input            monitor_error;
  input            monitor_ready;
  input            reset_n;
  input            resetlatch;
  input            tracemem_on;
  input   [ 35: 0] tracemem_trcdata;
  input            tracemem_tw;
  input   [  6: 0] trc_im_addr;
  input            trc_on;
  input            trc_wrap;
  input            trigbrktype;
  input            trigger_state_1;

  wire    [ 37: 0] jdo;
  wire             jrst_n;
  wire    [ 37: 0] sr;
  wire             st_ready_test_idle;
  wire             take_action_break_a;
  wire             take_action_break_b;
  wire             take_action_break_c;
  wire             take_action_ocimem_a;
  wire             take_action_ocimem_b;
  wire             take_action_tracectrl;
  wire             take_action_tracemem_a;
  wire             take_action_tracemem_b;
  wire             take_no_action_break_a;
  wire             take_no_action_break_b;
  wire             take_no_action_break_c;
  wire             take_no_action_ocimem_a;
  wire             take_no_action_tracemem_a;
  wire             vji_cdr;
  wire    [  1: 0] vji_ir_in;
  wire    [  1: 0] vji_ir_out;
  wire             vji_rti;
  wire             vji_sdr;
  wire             vji_tck;
  wire             vji_tdi;
  wire             vji_tdo;
  wire             vji_udr;
  wire             vji_uir;
  //Change the sld_virtual_jtag_basic's defparams to
  //switch between a regular Nios II or an internally embedded Nios II.
  //For a regular Nios II, sld_mfg_id = 70, sld_type_id = 34.
  //For an internally embedded Nios II, slf_mfg_id = 110, sld_type_id = 135.
  cpu_1_jtag_debug_module_tck the_cpu_1_jtag_debug_module_tck
    (
      .MonDReg            (MonDReg),
      .break_readreg      (break_readreg),
      .dbrk_hit0_latch    (dbrk_hit0_latch),
      .dbrk_hit1_latch    (dbrk_hit1_latch),
      .dbrk_hit2_latch    (dbrk_hit2_latch),
      .dbrk_hit3_latch    (dbrk_hit3_latch),
      .debugack           (debugack),
      .ir_in              (vji_ir_in),
      .ir_out             (vji_ir_out),
      .jrst_n             (jrst_n),
      .jtag_state_rti     (vji_rti),
      .monitor_error      (monitor_error),
      .monitor_ready      (monitor_ready),
      .reset_n            (reset_n),
      .resetlatch         (resetlatch),
      .sr                 (sr),
      .st_ready_test_idle (st_ready_test_idle),
      .tck                (vji_tck),
      .tdi                (vji_tdi),
      .tdo                (vji_tdo),
      .tracemem_on        (tracemem_on),
      .tracemem_trcdata   (tracemem_trcdata),
      .tracemem_tw        (tracemem_tw),
      .trc_im_addr        (trc_im_addr),
      .trc_on             (trc_on),
      .trc_wrap           (trc_wrap),
      .trigbrktype        (trigbrktype),
      .trigger_state_1    (trigger_state_1),
      .vs_cdr             (vji_cdr),
      .vs_sdr             (vji_sdr),
      .vs_uir             (vji_uir)
    );

  cpu_1_jtag_debug_module_sysclk the_cpu_1_jtag_debug_module_sysclk
    (
      .clk                       (clk),
      .ir_in                     (vji_ir_in),
      .jdo                       (jdo),
      .sr                        (sr),
      .take_action_break_a       (take_action_break_a),
      .take_action_break_b       (take_action_break_b),
      .take_action_break_c       (take_action_break_c),
      .take_action_ocimem_a      (take_action_ocimem_a),
      .take_action_ocimem_b      (take_action_ocimem_b),
      .take_action_tracectrl     (take_action_tracectrl),
      .take_action_tracemem_a    (take_action_tracemem_a),
      .take_action_tracemem_b    (take_action_tracemem_b),
      .take_no_action_break_a    (take_no_action_break_a),
      .take_no_action_break_b    (take_no_action_break_b),
      .take_no_action_break_c    (take_no_action_break_c),
      .take_no_action_ocimem_a   (take_no_action_ocimem_a),
      .take_no_action_tracemem_a (take_no_action_tracemem_a),
      .vs_udr                    (vji_udr),
      .vs_uir                    (vji_uir)
    );


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  assign vji_tck = 1'b0;
  assign vji_tdi = 1'b0;
  assign vji_sdr = 1'b0;
  assign vji_cdr = 1'b0;
  assign vji_rti = 1'b0;
  assign vji_uir = 1'b0;
  assign vji_udr = 1'b0;
  assign vji_ir_in = 2'b0;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
//synthesis read_comments_as_HDL on
//  sld_virtual_jtag_basic cpu_1_jtag_debug_module_phy
//    (
//      .ir_in (vji_ir_in),
//      .ir_out (vji_ir_out),
//      .jtag_state_rti (vji_rti),
//      .tck (vji_tck),
//      .tdi (vji_tdi),
//      .tdo (vji_tdo),
//      .virtual_state_cdr (vji_cdr),
//      .virtual_state_sdr (vji_sdr),
//      .virtual_state_udr (vji_udr),
//      .virtual_state_uir (vji_uir)
//    );
//
//  defparam cpu_1_jtag_debug_module_phy.sld_auto_instance_index = "YES",
//           cpu_1_jtag_debug_module_phy.sld_instance_index = 0,
//           cpu_1_jtag_debug_module_phy.sld_ir_width = 2,
//           cpu_1_jtag_debug_module_phy.sld_mfg_id = 70,
//           cpu_1_jtag_debug_module_phy.sld_sim_action = "",
//           cpu_1_jtag_debug_module_phy.sld_sim_n_scan = 0,
//           cpu_1_jtag_debug_module_phy.sld_sim_total_length = 0,
//           cpu_1_jtag_debug_module_phy.sld_type_id = 34,
//           cpu_1_jtag_debug_module_phy.sld_version = 3;
//
//synthesis read_comments_as_HDL off

endmodule


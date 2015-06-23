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

module cpu_0_jtag_debug_module_sysclk (
                                        // inputs:
                                         clk,
                                         ir_in,
                                         sr,
                                         vs_udr,
                                         vs_uir,

                                        // outputs:
                                         jdo,
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
  input            clk;
  input   [  1: 0] ir_in;
  input   [ 37: 0] sr;
  input            vs_udr;
  input            vs_uir;

  reg              enable_action_strobe /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103\""  */;
  reg     [  1: 0] ir /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,R101\""  */;
  reg     [ 37: 0] jdo /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,R101\""  */;
  reg              jxuir /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103\""  */;
  reg              sync2_udr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103\""  */;
  reg              sync2_uir /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103\""  */;
  wire             sync_udr;
  wire             sync_uir;
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
  wire             unxunused_resetxx2;
  wire             unxunused_resetxx3;
  reg              update_jdo_strobe /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103\""  */;
  assign unxunused_resetxx2 = 1'b1;
  altera_std_synchronizer the_altera_std_synchronizer2
    (
      .clk (clk),
      .din (vs_udr),
      .dout (sync_udr),
      .reset_n (unxunused_resetxx2)
    );

  defparam the_altera_std_synchronizer2.depth = 2;

  assign unxunused_resetxx3 = 1'b1;
  altera_std_synchronizer the_altera_std_synchronizer3
    (
      .clk (clk),
      .din (vs_uir),
      .dout (sync_uir),
      .reset_n (unxunused_resetxx3)
    );

  defparam the_altera_std_synchronizer3.depth = 2;

  always @(posedge clk)
    begin
      sync2_udr <= sync_udr;
      update_jdo_strobe <= sync_udr & ~sync2_udr;
      enable_action_strobe <= update_jdo_strobe;
      sync2_uir <= sync_uir;
      jxuir <= sync_uir & ~sync2_uir;
    end


  assign take_action_ocimem_a = enable_action_strobe && (ir == 2'b00) && 
    ~jdo[35] && jdo[34];

  assign take_no_action_ocimem_a = enable_action_strobe && (ir == 2'b00) && 
    ~jdo[35] && ~jdo[34];

  assign take_action_ocimem_b = enable_action_strobe && (ir == 2'b00) && 
    jdo[35];

  assign take_action_tracemem_a = enable_action_strobe && (ir == 2'b01) &&
    ~jdo[37] && 
    jdo[36];

  assign take_no_action_tracemem_a = enable_action_strobe && (ir == 2'b01) &&
    ~jdo[37] && 
    ~jdo[36];

  assign take_action_tracemem_b = enable_action_strobe && (ir == 2'b01) &&
    jdo[37];

  assign take_action_break_a = enable_action_strobe && (ir == 2'b10) && 
    ~jdo[36] && 
    jdo[37];

  assign take_no_action_break_a = enable_action_strobe && (ir == 2'b10) && 
    ~jdo[36] && 
    ~jdo[37];

  assign take_action_break_b = enable_action_strobe && (ir == 2'b10) && 
    jdo[36] && ~jdo[35] &&
    jdo[37];

  assign take_no_action_break_b = enable_action_strobe && (ir == 2'b10) && 
    jdo[36] && ~jdo[35] &&
    ~jdo[37];

  assign take_action_break_c = enable_action_strobe && (ir == 2'b10) && 
    jdo[36] &&  jdo[35] &&
    jdo[37];

  assign take_no_action_break_c = enable_action_strobe && (ir == 2'b10) && 
    jdo[36] &&  jdo[35] &&
    ~jdo[37];

  assign take_action_tracectrl = enable_action_strobe && (ir == 2'b11) &&  
    jdo[15];

  always @(posedge clk)
    begin
      if (jxuir)
          ir <= ir_in;
      if (update_jdo_strobe)
          jdo <= sr;
    end



endmodule


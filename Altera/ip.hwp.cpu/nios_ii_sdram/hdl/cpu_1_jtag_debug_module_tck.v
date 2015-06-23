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

module cpu_1_jtag_debug_module_tck (
                                     // inputs:
                                      MonDReg,
                                      break_readreg,
                                      dbrk_hit0_latch,
                                      dbrk_hit1_latch,
                                      dbrk_hit2_latch,
                                      dbrk_hit3_latch,
                                      debugack,
                                      ir_in,
                                      jtag_state_rti,
                                      monitor_error,
                                      monitor_ready,
                                      reset_n,
                                      resetlatch,
                                      tck,
                                      tdi,
                                      tracemem_on,
                                      tracemem_trcdata,
                                      tracemem_tw,
                                      trc_im_addr,
                                      trc_on,
                                      trc_wrap,
                                      trigbrktype,
                                      trigger_state_1,
                                      vs_cdr,
                                      vs_sdr,
                                      vs_uir,

                                     // outputs:
                                      ir_out,
                                      jrst_n,
                                      sr,
                                      st_ready_test_idle,
                                      tdo
                                   )
;

  output  [  1: 0] ir_out;
  output           jrst_n;
  output  [ 37: 0] sr;
  output           st_ready_test_idle;
  output           tdo;
  input   [ 31: 0] MonDReg;
  input   [ 31: 0] break_readreg;
  input            dbrk_hit0_latch;
  input            dbrk_hit1_latch;
  input            dbrk_hit2_latch;
  input            dbrk_hit3_latch;
  input            debugack;
  input   [  1: 0] ir_in;
  input            jtag_state_rti;
  input            monitor_error;
  input            monitor_ready;
  input            reset_n;
  input            resetlatch;
  input            tck;
  input            tdi;
  input            tracemem_on;
  input   [ 35: 0] tracemem_trcdata;
  input            tracemem_tw;
  input   [  6: 0] trc_im_addr;
  input            trc_on;
  input            trc_wrap;
  input            trigbrktype;
  input            trigger_state_1;
  input            vs_cdr;
  input            vs_sdr;
  input            vs_uir;

  reg     [  2: 0] DRsize /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103,R101\""  */;
  wire             debugack_sync;
  reg     [  1: 0] ir_out;
  wire             jrst_n;
  wire             monitor_ready_sync;
  reg     [ 37: 0] sr /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103,R101\""  */;
  wire             st_ready_test_idle;
  wire             tdo;
  wire             unxcomplemented_resetxx0;
  wire             unxcomplemented_resetxx1;
  always @(posedge tck)
    begin
      if (vs_cdr)
          case (ir_in)
          
              2'b00: begin
                  sr[35] <= debugack_sync;
                  sr[34] <= monitor_error;
                  sr[33] <= resetlatch;
                  sr[32 : 1] <= MonDReg;
                  sr[0] <= monitor_ready_sync;
              end // 2'b00 
          
              2'b01: begin
                  sr[35 : 0] <= tracemem_trcdata;
                  sr[37] <= tracemem_tw;
                  sr[36] <= tracemem_on;
              end // 2'b01 
          
              2'b10: begin
                  sr[37] <= trigger_state_1;
                  sr[36] <= dbrk_hit3_latch;
                  sr[35] <= dbrk_hit2_latch;
                  sr[34] <= dbrk_hit1_latch;
                  sr[33] <= dbrk_hit0_latch;
                  sr[32 : 1] <= break_readreg;
                  sr[0] <= trigbrktype;
              end // 2'b10 
          
              2'b11: begin
                  sr[15 : 12] <= 1'b0;
                  sr[11 : 2] <= trc_im_addr;
                  sr[1] <= trc_wrap;
                  sr[0] <= trc_on;
              end // 2'b11 
          
          endcase // ir_in
      if (vs_sdr)
          case (DRsize)
          
              3'b000: begin
                  sr <= {tdi, sr[37 : 2], tdi};
              end // 3'b000 
          
              3'b001: begin
                  sr <= {tdi, sr[37 : 9], tdi, sr[7 : 1]};
              end // 3'b001 
          
              3'b010: begin
                  sr <= {tdi, sr[37 : 17], tdi, sr[15 : 1]};
              end // 3'b010 
          
              3'b011: begin
                  sr <= {tdi, sr[37 : 33], tdi, sr[31 : 1]};
              end // 3'b011 
          
              3'b100: begin
                  sr <= {tdi, sr[37],         tdi, sr[35 : 1]};
              end // 3'b100 
          
              3'b101: begin
                  sr <= {tdi, sr[37 : 1]};
              end // 3'b101 
          
              default: begin
                  sr <= {tdi, sr[37 : 2], tdi};
              end // default
          
          endcase // DRsize
      if (vs_uir)
          case (ir_in)
          
              2'b00: begin
                  DRsize <= 3'b100;
              end // 2'b00 
          
              2'b01: begin
                  DRsize <= 3'b101;
              end // 2'b01 
          
              2'b10: begin
                  DRsize <= 3'b101;
              end // 2'b10 
          
              2'b11: begin
                  DRsize <= 3'b010;
              end // 2'b11 
          
          endcase // ir_in
    end


  assign tdo = sr[0];
  assign st_ready_test_idle = jtag_state_rti;
  assign unxcomplemented_resetxx0 = jrst_n;
  altera_std_synchronizer the_altera_std_synchronizer
    (
      .clk (tck),
      .din (debugack),
      .dout (debugack_sync),
      .reset_n (unxcomplemented_resetxx0)
    );

  defparam the_altera_std_synchronizer.depth = 2;

  assign unxcomplemented_resetxx1 = jrst_n;
  altera_std_synchronizer the_altera_std_synchronizer1
    (
      .clk (tck),
      .din (monitor_ready),
      .dout (monitor_ready_sync),
      .reset_n (unxcomplemented_resetxx1)
    );

  defparam the_altera_std_synchronizer1.depth = 2;

  always @(posedge tck or negedge jrst_n)
    begin
      if (jrst_n == 0)
          ir_out <= 2'b0;
      else 
        ir_out <= {debugack_sync, monitor_ready_sync};
    end



//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  assign jrst_n = reset_n;

//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on
//synthesis read_comments_as_HDL on
//  assign jrst_n = 1;
//synthesis read_comments_as_HDL off

endmodule


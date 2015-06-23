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

module cpu_0_mult_cell (
                         // inputs:
                          A_mul_src1,
                          A_mul_src2,
                          clk,
                          reset_n,

                         // outputs:
                          A_mul_cell_result
                       )
;

  output  [ 31: 0] A_mul_cell_result;
  input   [ 31: 0] A_mul_src1;
  input   [ 31: 0] A_mul_src2;
  input            clk;
  input            reset_n;

  wire    [ 31: 0] A_mul_cell_result;
  wire    [ 31: 0] A_mul_cell_result_part_1;
  wire    [ 15: 0] A_mul_cell_result_part_2;
  wire             mul_clr;
  assign mul_clr = ~reset_n;
  altmult_add the_altmult_add_part_1
    (
      .aclr0 (mul_clr),
      .clock0 (clk),
      .dataa (A_mul_src1[15 : 0]),
      .datab (A_mul_src2[15 : 0]),
      .ena0 (1'b1),
      .result (A_mul_cell_result_part_1)
    );

  defparam the_altmult_add_part_1.addnsub_multiplier_pipeline_aclr1 = "ACLR0",
           the_altmult_add_part_1.addnsub_multiplier_pipeline_register1 = "CLOCK0",
           the_altmult_add_part_1.addnsub_multiplier_register1 = "UNREGISTERED",
           the_altmult_add_part_1.dedicated_multiplier_circuitry = "YES",
           the_altmult_add_part_1.input_register_a0 = "UNREGISTERED",
           the_altmult_add_part_1.input_register_b0 = "UNREGISTERED",
           the_altmult_add_part_1.input_source_a0 = "DATAA",
           the_altmult_add_part_1.input_source_b0 = "DATAB",
           the_altmult_add_part_1.intended_device_family = "CYCLONEII",
           the_altmult_add_part_1.lpm_type = "altmult_add",
           the_altmult_add_part_1.multiplier1_direction = "ADD",
           the_altmult_add_part_1.multiplier_aclr0 = "ACLR0",
           the_altmult_add_part_1.multiplier_register0 = "CLOCK0",
           the_altmult_add_part_1.number_of_multipliers = 1,
           the_altmult_add_part_1.output_register = "UNREGISTERED",
           the_altmult_add_part_1.port_addnsub1 = "PORT_UNUSED",
           the_altmult_add_part_1.port_signa = "PORT_UNUSED",
           the_altmult_add_part_1.port_signb = "PORT_UNUSED",
           the_altmult_add_part_1.representation_a = "UNSIGNED",
           the_altmult_add_part_1.representation_b = "UNSIGNED",
           the_altmult_add_part_1.signed_pipeline_aclr_a = "ACLR0",
           the_altmult_add_part_1.signed_pipeline_aclr_b = "ACLR0",
           the_altmult_add_part_1.signed_pipeline_register_a = "CLOCK0",
           the_altmult_add_part_1.signed_pipeline_register_b = "CLOCK0",
           the_altmult_add_part_1.signed_register_a = "UNREGISTERED",
           the_altmult_add_part_1.signed_register_b = "UNREGISTERED",
           the_altmult_add_part_1.width_a = 16,
           the_altmult_add_part_1.width_b = 16,
           the_altmult_add_part_1.width_result = 32;

  altmult_add the_altmult_add_part_2
    (
      .aclr0 (mul_clr),
      .clock0 (clk),
      .dataa (A_mul_src1[31 : 16]),
      .datab (A_mul_src2[15 : 0]),
      .ena0 (1'b1),
      .result (A_mul_cell_result_part_2)
    );

  defparam the_altmult_add_part_2.addnsub_multiplier_pipeline_aclr1 = "ACLR0",
           the_altmult_add_part_2.addnsub_multiplier_pipeline_register1 = "CLOCK0",
           the_altmult_add_part_2.addnsub_multiplier_register1 = "UNREGISTERED",
           the_altmult_add_part_2.dedicated_multiplier_circuitry = "YES",
           the_altmult_add_part_2.input_register_a0 = "UNREGISTERED",
           the_altmult_add_part_2.input_register_b0 = "UNREGISTERED",
           the_altmult_add_part_2.input_source_a0 = "DATAA",
           the_altmult_add_part_2.input_source_b0 = "DATAB",
           the_altmult_add_part_2.intended_device_family = "CYCLONEII",
           the_altmult_add_part_2.lpm_type = "altmult_add",
           the_altmult_add_part_2.multiplier1_direction = "ADD",
           the_altmult_add_part_2.multiplier_aclr0 = "ACLR0",
           the_altmult_add_part_2.multiplier_register0 = "CLOCK0",
           the_altmult_add_part_2.number_of_multipliers = 1,
           the_altmult_add_part_2.output_register = "UNREGISTERED",
           the_altmult_add_part_2.port_addnsub1 = "PORT_UNUSED",
           the_altmult_add_part_2.port_signa = "PORT_UNUSED",
           the_altmult_add_part_2.port_signb = "PORT_UNUSED",
           the_altmult_add_part_2.representation_a = "UNSIGNED",
           the_altmult_add_part_2.representation_b = "UNSIGNED",
           the_altmult_add_part_2.signed_pipeline_aclr_a = "ACLR0",
           the_altmult_add_part_2.signed_pipeline_aclr_b = "ACLR0",
           the_altmult_add_part_2.signed_pipeline_register_a = "CLOCK0",
           the_altmult_add_part_2.signed_pipeline_register_b = "CLOCK0",
           the_altmult_add_part_2.signed_register_a = "UNREGISTERED",
           the_altmult_add_part_2.signed_register_b = "UNREGISTERED",
           the_altmult_add_part_2.width_a = 16,
           the_altmult_add_part_2.width_b = 16,
           the_altmult_add_part_2.width_result = 16;

  assign A_mul_cell_result = {A_mul_cell_result_part_1[31 : 16] +
    A_mul_cell_result_part_2,
    A_mul_cell_result_part_1[15 : 0]};


endmodule


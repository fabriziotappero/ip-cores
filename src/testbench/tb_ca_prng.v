//========================================================================
//
// tb_ca_prng.v
// ------------
// Testbench for the rule cellular automata based PRNG ca_prng.
// This version is for ca_prng with 32 bit pattern output.
// 
// 
// Author: Joachim Strombergson
// Copyright (c) 2008, InformAsic AB
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
// 
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials
//       provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY InformAsic AB ''AS IS'' AND ANY EXPRESS
// OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL InformAsic AB BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
//========================================================================

//------------------------------------------------------------------
// Simulator directives
//
// Timescale etc.
//------------------------------------------------------------------
`timescale 1ns / 1ps


//------------------------------------------------------------------
// tb_ca_prng
//
// The self contained testbench module.
//------------------------------------------------------------------
module tb_ca_prng();
 
  //----------------------------------------------------------------
  // Parameter declarations
  //----------------------------------------------------------------
  // CLK_HALF_PERIOD
  // Half period (assuming 50/50 duty cycle) in ns.
  parameter CLK_HALF_PERIOD = 5;

  // RULE_2
  // This rule generates a single angled line. 
  // See the following link for more info:
  // http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
  parameter [7 : 0] RULE_2 = 8'b00000010;
  
  // RULE_90
  // This rule generates Pascals triangle from a single
  // bit input. See the following link for more info:
  // http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
  parameter [7 : 0] RULE_90 = 8'b01011010;

  // MIDDLE_BIT_INIT_PATTERN
  // An initial bgit pattern with a single bit set in the middle
  // of the 32 bit word.
  parameter  [31 : 0] MIDDLE_BIT_INIT_PATTERN = 32'b00000000000000010000000000000000;

  // COMPLEX_INIT_PATTERN
  // A more complex init pattern.
  parameter  [31 : 0] COMPLEX_INIT_PATTERN = 32'b01011000000000010000111000001100;

  // TC1_RESPONSE
  // Expected PRNG pattern response after TC1.
  parameter  [31 : 0] TC1_RESPONSE = 32'b01110001010110000000111010001001;

  // TC2_RESPONSE
  // Expected PRNG pattern response after TC2.
  parameter  [31 : 0] TC2_RESPONSE = 32'b10111101001101000001100001101001;

  // TC3_RESPONSE
  // Expected PRNG pattern response after TC3.
  parameter  [31 : 0] TC3_RESPONSE = 32'b00000000000000000001000000000000;

  // TC4_RESPONSE
  // Expected PRNG pattern response after TC4.
  parameter  [31 : 0] TC4_RESPONSE = 32'b10101010101010101010101010101010;
  
  
  //----------------------------------------------------------------
  // Wire declarations.
  //----------------------------------------------------------------
  // Wires needed to connect the DUT.
  reg           tb_clk;
  reg           tb_reset_n;
  reg [31 : 0]  tb_init_pattern_data;
  reg           tb_load_init_pattern;
  reg           tb_next_pattern;
  reg [7 : 0]   tb_update_rule;
  reg           tb_load_update_rule;
  wire [31 : 0] tb_prng_data;


  //----------------------------------------------------------------
  // Testbench variables.
  //----------------------------------------------------------------
  // num_errors
  // Number of errors detected.
  integer num_errors;

  
  //----------------------------------------------------------------
  // ca_prng_dut
  // 
  // Instantiation of the ca_prng core as device under test.
  //----------------------------------------------------------------
  ca_prng ca_prng_dut(
                      .clk(tb_clk),
                      .reset_n(tb_reset_n),

                      .init_pattern_data(tb_init_pattern_data),
                      .load_init_pattern(tb_load_init_pattern),
                      .next_pattern(tb_next_pattern),

                      .update_rule(tb_update_rule),
                      .load_update_rule(tb_load_update_rule),

                      .prng_data(tb_prng_data)
                     );
  

  //----------------------------------------------------------------
  // check_pattern
  //
  // Check that the reusult pattern matches the expected pattern.
  // If the patterns don't match increase the error counter.
  //----------------------------------------------------------------
  task check_pattern;
    input [31 : 0] expected_pattern;
    input [31 : 0] result_pattern;
    
    begin
      if (expected_pattern != result_pattern)
        begin
          $display("Error: Expected %b, got: %b",
                   expected_pattern, result_pattern);
          num_errors = num_errors + 1;
        end
    end
  endtask // check_pattern

  
  //----------------------------------------------------------------
  // init_sim
  //
  // Initialize all DUT inputs variables, testbench variables etc 
  // to defined values.
  //----------------------------------------------------------------
  task init_sim;
    begin
      tb_clk               = 0;
      tb_reset_n           = 0;
      tb_init_pattern_data = MIDDLE_BIT_INIT_PATTERN;
      tb_load_init_pattern = 1'b0;
      tb_next_pattern      = 1'b0;
      tb_update_rule       = 8'b00000000;
      tb_load_update_rule  = 1'b0;
      num_errors           = 0;
    end
  endtask // init_sim 
  
      
  //----------------------------------------------------------------
  // end_sim
  //
  // Perform any clean up as needed and check the simulation 
  // results from the test cases, reporting number of errors etc.
  //----------------------------------------------------------------
  task end_sim;
    begin
      if (num_errors == 0)
        begin
          $display("Simulation completed ok.");
        end
      else
        begin
          $display("Simulation completed, but %d test cases had errors.", num_errors);
        end
    end
  endtask // end_sim 

  
  //----------------------------------------------------------------
  // release_reset
  //
  // Wait a few cycles and then release the reset in sync
  // with the clock.
  //----------------------------------------------------------------
  task release_reset;
    begin
      #(20 * CLK_HALF_PERIOD);
      @(negedge tb_clk)
        tb_reset_n = 1'b1;
    end
  endtask // release_reset 

  
  //----------------------------------------------------------------
  // test_tc1
  //
  // Verify that the default rule30 update rule uns ok from the 
  // start using a simple init pattern.
  //----------------------------------------------------------------
  task test_tc1;
    begin
      $display("TC1: Default rule30 update rule with simple init pattern.");
      // Load the init pattern into the dut and then
      // start asserting the next pattern pin for a while.
      #(4 * CLK_HALF_PERIOD);
      @(negedge tb_clk)
        tb_load_init_pattern = 1'b1;
      @(negedge tb_clk)
        tb_load_init_pattern = 1'b0;
      @(negedge tb_clk)
        tb_next_pattern      = 1'b1;
      
      // Run the DUT for a number of cycles.
      #(100 * CLK_HALF_PERIOD);

      // Drop the next pattern signal and check the results.
      @(negedge tb_clk)
        tb_next_pattern = 1'b0;
      check_pattern(TC1_RESPONSE, tb_prng_data);
    end
  endtask // test_tc1
  
  
  //----------------------------------------------------------------
  // test_tc2
  //
  // Verify that we can change state by changing the init pattern
  // and get a new set of PRNG data.
  //----------------------------------------------------------------
  task test_tc2;
    begin
      $display("TC2: Default rule30 update rule with complex init pattern.");
      // Load a new init pattern and run that pattern
      @(negedge tb_clk)
      tb_init_pattern_data = COMPLEX_INIT_PATTERN;
      tb_load_init_pattern = 1'b1;
      @(negedge tb_clk)
      tb_load_init_pattern = 1'b0;
      tb_next_pattern      = 1'b1;
      
      // Run the DUT for a number of cycles.
      #(200 * CLK_HALF_PERIOD);

      // Drop the next pattern signal and check the results.
      @(negedge tb_clk)
        tb_next_pattern = 1'b0;
      check_pattern(TC2_RESPONSE, tb_prng_data);
    end
  endtask // test_tc2


  //----------------------------------------------------------------
  // test_tc3
  //
  // Verify that the we can change the rule and get another set
  // of PRNG data.
  //----------------------------------------------------------------
  task test_tc3;
    begin
      $display("TC3: rule2 update rule with simple init pattern.");
      // Change update rule to RULE_2 and the simple init pattern.
      @(negedge tb_clk)
      tb_update_rule       = RULE_2;
      tb_load_update_rule  = 1'b1;
      tb_init_pattern_data = MIDDLE_BIT_INIT_PATTERN;
      tb_load_init_pattern = 1'b1;
      @(negedge tb_clk)
      tb_load_update_rule  = 1'b0;
      tb_load_init_pattern = 1'b0;
      tb_next_pattern      = 1'b1;
      
      // Run the DUT for a number of cycles.
      #(200 * CLK_HALF_PERIOD);

      // Drop the next pattern signal and check the results.
      @(negedge tb_clk)
        tb_next_pattern = 1'b0;
      check_pattern(TC3_RESPONSE, tb_prng_data);
    end
  endtask // test_tc3


  //----------------------------------------------------------------
  // test_tc4
  //
  // Verify that the we can generate Pascals triangle.
  //----------------------------------------------------------------
  task test_tc4;
    begin
      $display("TC4: rule90 (Pascals triangle) update rule with simple init pattern.");
      // Change update rule to RULE_90 and the simple init pattern.
      @(negedge tb_clk)
      tb_update_rule       = RULE_90;
      tb_load_update_rule  = 1'b1;
      tb_init_pattern_data = MIDDLE_BIT_INIT_PATTERN;
      tb_load_init_pattern = 1'b1;
      @(negedge tb_clk)
      tb_load_update_rule  = 1'b0;
      tb_load_init_pattern = 1'b0;
      tb_next_pattern      = 1'b1;
      
      // Run the DUT for a number of cycles.
      #(30 * CLK_HALF_PERIOD);

      // Drop the next pattern signal and check the results.
      @(negedge tb_clk)
        tb_next_pattern = 1'b0;
      check_pattern(TC4_RESPONSE, tb_prng_data);
    end
  endtask // test_tc4

  
  //----------------------------------------------------------------
  // clk_gen
  //
  // Clock generator process. 50/50 duty cycle.
  //----------------------------------------------------------------
  always 
    begin : clk_gen
      #CLK_HALF_PERIOD tb_clk = !tb_clk;
    end // clk_gen
  
    
  //--------------------------------------------------------------------
  // dut_monitor
  //
  // Monitor for observing the inputs and outputs to the dut.
  //--------------------------------------------------------------------
  always @ (posedge tb_clk)
    begin : dut_monitor
      $display("reset = %b, init_pattern = %b, load_init_pattern = %b, next_pattern = %b, prng_data = %b", 
               tb_reset_n, tb_init_pattern_data, tb_load_init_pattern, tb_next_pattern, tb_prng_data);
    end // dut_monitor

      
  //----------------------------------------------------------------
  // ca_prng_test
  //
  // The main test logic. Basically calls the tasks to init the
  // simulation, all test cases and finish the simulation.
  //----------------------------------------------------------------
  initial
    begin : ca_prng_test
      $display("   -- Testbench for for ca_prng module started --");

      // Call tasks as needed to init and executing test cases.
      init_sim;
      release_reset;

      test_tc1;
      test_tc2;
      test_tc3;
      test_tc4;

      end_sim;
      
      $display("   -- Testbench for for ca_prng module stopped --");
      $finish;
    end // ca_prng_test
endmodule // tb_ca_prng

//========================================================================
// EOF tb_ca_prng.v
//========================================================================

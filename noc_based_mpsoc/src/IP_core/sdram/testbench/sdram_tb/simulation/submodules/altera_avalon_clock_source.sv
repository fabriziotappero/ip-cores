// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $File: //acds/rel/13.0/ip/sopc/components/verification/altera_avalon_clock_source/altera_avalon_clock_source.sv $
// $Revision: #1 $
// $Date: 2013/02/11 $
// $Author: swbranch $
//------------------------------------------------------------------------------
// Clock generator

`timescale 1ns / 1ps

module altera_avalon_clock_source (clk);
   output clk;

   parameter CLOCK_RATE = 10;       // clock rate in MHz / kHz / Hz depends on the clock unit
   parameter CLOCK_UNIT = 1000000;  // clock unit MHz / kHz / Hz

// synthesis translate_off
   import verbosity_pkg::*;

   localparam HALF_CLOCK_PERIOD   = 1000000000.000000/(CLOCK_RATE*CLOCK_UNIT*2); // half clock period in ns
   
   logic clk = 1'b0;

   string message   = "*uninitialized*";
   string freq_unit = (CLOCK_UNIT == 1)? "Hz" : 
                      (CLOCK_UNIT == 1000)? "kHz" : "MHz";
   bit    run_state = 1'b1;
   
   function automatic void __hello();
      $sformat(message, "%m: - Hello from altera_clock_source.");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Date: 2013/02/11 $");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   CLOCK_RATE = %0d %s", CLOCK_RATE, freq_unit);      
      print(VERBOSITY_INFO, message);
      print_divider(VERBOSITY_INFO);      
   endfunction

   function automatic string get_version();  // public
      // Return BFM version as a string of three integers separated by periods.
      // For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "13.0";
      return ret_version;
   endfunction
   
   task automatic clock_start();  // public
      // Turn the clock on. By default the clock is initially turned on.
      $sformat(message, "%m: Clock started");
      print(VERBOSITY_INFO, message);       
      run_state = 1;
   endtask

   task automatic clock_stop();  // public
      // Turn the clock off.
      $sformat(message, "%m: Clock stopped");
      print(VERBOSITY_INFO, message);       
      run_state = 0;      
   endtask

   function automatic get_run_state();  // public
      // Return the state of the clock source: running=1, stopped=0
      return run_state;
   endfunction      

   initial begin
      __hello();
   end

   always begin
      #HALF_CLOCK_PERIOD;      
      clk = run_state;      

      #HALF_CLOCK_PERIOD;
      clk = 1'b0; 
   end
// synthesis translate_on

endmodule


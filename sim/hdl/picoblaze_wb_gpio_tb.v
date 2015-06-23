////////////////////////////////////////////////////////////////////////////////
// This sourcecode is released under BSD license.
// Please see http://www.opensource.org/licenses/bsd-license.php for details!
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
//
////////////////////////////////////////////////////////////////////////////////
// filename: picoblaze_wb_gpio_tb.v
// description: testbench for picoblaze_wb_gpio example
// todo4user: modify stimulus as needed
// version: 0.0.0
// changelog: - 0.0.0, initial release
//            - ...
////////////////////////////////////////////////////////////////////////////////


`uselib lib = unisims_ver

`timescale 1 ns / 1 ps


module picoblaze_wb_gpio_tb;

  reg rst_n;
  reg clk;
    
  wire[7:0] gpio;
  
  parameter PERIOD = 20;

  reg[7:4] test_data_in;
  
  // system signal generation
  initial begin
    test_data_in = 4'h0;
    clk = 1'b1;
    rst_n = 1'b0;
    #(PERIOD*2) rst_n = 1'b1;
  end 
  always #(PERIOD/2) clk = ! clk;
  
  // 4 bit counting data, changing after some micro seconds
  always #3000 test_data_in = test_data_in + 1;
  // stimulus at upper gpio nibble
  assign gpio[7:4] = test_data_in;

  // design under test instance
  picoblaze_wb_gpio dut (
    .p_rst_n_i(rst_n),
    .p_clk_i(clk),
    
    .p_gpio_io(gpio)
  );
  
endmodule

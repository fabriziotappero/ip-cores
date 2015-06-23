//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`timescale 1ns/10ps


module tb_top();

  parameter CLK_PERIOD = 42; // ~24MHZ (23.8MHZ) 

  reg tb_clk, tb_rst;

  initial 
    begin
      tb_clk <= 1'b1;      
      tb_rst <= 1'b1;
      
      #(CLK_PERIOD); #(CLK_PERIOD/3);
      tb_rst = 1'b0;
      
    end

  always
    #(CLK_PERIOD/2) tb_clk = ~tb_clk;
    
// --------------------------------------------------------------------
// tb_dut
  tb_dut dut( tb_clk, tb_rst );
  

  the_test test( tb_clk, tb_rst );
  
// --------------------------------------------------------------------
// run the test function

  initial
    begin
    
      // wait for system to come out of reset
      wait( ~tb_rst );
      
      repeat(2) @(posedge tb_clk);
      
      
      $display("\n^^^---------------------------------\n");
      
      test.run_the_test();
      
      $display("\n^^^---------------------------------\n");
      $display("^^^- Testbench done. %t.\n", $time);
      
      $stop();
    
    end
  
endmodule


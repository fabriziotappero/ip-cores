//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// bistable_domain_cross_tb.sv                                  ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for bistable_domain_cross module                   ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
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
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module bistable_domain_cross_tb();

parameter TCLK_A = 20; // 50 MHz -> timescale 1ns
parameter TCLK_B = 203; // 4.98 MHz -> timescale 1ns

reg rst;
reg clk_a;
reg [1:0] in;
reg clk_b;
wire [1:0] out;

bistable_domain_cross #(2) bistable_domain_cross_dut(
    .rst(rst),
    .clk_a(clk_a),
    .in(in), 
    .clk_b(clk_b),
    .out(out)
);

// Generating clk_a clock
always
begin
    clk_a=0;
    forever #(TCLK_A/2) clk_a = ~clk_a;
end

// Generating clk_b clock
always
begin
    clk_b=0;
    forever #(TCLK_B/2) clk_b = ~clk_b;
end

initial
begin
    rst = 1;
    in = 0;
    
    #(3.2*TCLK_B);
    rst = 0;
    
    $display("bistable_domain_cross_tb start ...");
    
    #(3*TCLK_B);
    wait(clk_a == 0);
    wait(clk_a == 1);
    in = 2'b11;
    #(1.5*TCLK_A);
    wait(clk_b == 0);
    wait(clk_b == 1);
    #(1.5*TCLK_B);
    
    assert(out == 2'b11);
    
    #TCLK_B;
    assert(out == 2'b11);
    
    wait(clk_a == 0);
    wait(clk_a == 1);
    in = 2'b00;
    #(1.5*TCLK_A);
    
    wait(clk_b == 0);
    wait(clk_b == 1);
    #(1.5*TCLK_B);

    assert(out == 2'b00);

    #(10*TCLK_B) $display("bistable_domain_cross_tb finish ...");
    $finish;
    
end

endmodule
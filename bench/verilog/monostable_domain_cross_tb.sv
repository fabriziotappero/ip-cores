//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// monostable_domain_cross_tb.sv                                ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for monostable_domain_cross module                 ////
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

module monostable_domain_cross_tb();

parameter TCLK_A = 20; // 50 MHz -> timescale 1ns
parameter TCLK_B = 203; // 4.98 MHz -> timescale 1ns

reg rst0;
reg rst1;
reg clk_a;
reg in;
reg clk_b;
wire out0;
wire out1;
integer i;

monostable_domain_cross monostable_domain_cross_dut0(
    .rst(rst0),
    .clk_a(clk_a),
    .in(in), 
    .clk_b(clk_b),
    .out(out0)
);

monostable_domain_cross monostable_domain_cross_dut1(
    .rst(rst1),
    .clk_a(clk_b),
    .in(in), 
    .clk_b(clk_a),
    .out(out1)
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
    rst0 = 1;
    rst1 = 1;
    in = 0;
    
    #(3.2*TCLK_B);
    rst0 = 0;
    
    $display("monostable_domain_cross_tb start ...");
    
    for (i = 0; i < 2; i = i + 1) begin
        wait(clk_a == 0);
        wait(clk_a == 1);
        in = 1;
        #(1.5*TCLK_A);
        in = 0;
    
        wait(out0 == 1);
        #(1.5*TCLK_B);
        assert(out0 == 0);
    end
    
    rst0 = 1;
    ///////////////////////////////////////////////////////////////////////
    rst1 = 0;
    
    for (i = 0; i < 2; i = i + 1) begin
        wait(clk_b == 0);
        wait(clk_b == 1);
        fork 
            begin
                in = 1;
                #(1.5*TCLK_B);
                in = 0;
            end
            begin
                wait(out1 == 1);
                #(1.5*TCLK_A);
                assert(out1 == 0);
            end
        join
    end


    #(10*TCLK_B) $display("monostable_domain_cross_tb finish ...");
    $finish;
    
end

endmodule
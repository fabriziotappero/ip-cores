//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// edge_detect_tb.sv                                            ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// testbench for edge_detect module                             ////
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

module edge_detect_tb();

parameter TCLK = 20; // 50 MHz -> timescale 1ns

reg rst;
reg clk;
reg sig;
wire rise;
wire fall;

edge_detect edge_detect_dut(
    .rst(rst),
    .clk(clk),
    .sig(sig), 
    .rise(rise),
    .fall(fall)
);

// Generating clk clock
always
begin
    clk=0;
    forever #(TCLK/2) clk = ~clk;
end

initial
begin
    rst = 1;
    sig = 0;
    
    #(3.2*TCLK);
    rst = 0;
    
    $display("edge_detect_tb start ...");

    //one cycle sig
    sig = 1;
    #TCLK;
    assert(rise == 1);
    assert(fall == 0);
    
    sig = 0;
    #TCLK;
    assert(rise == 0);
    assert(fall == 1);

    #TCLK;
    assert(rise == 0);
    assert(fall == 0);
    #TCLK;
    assert(rise == 0);
    assert(fall == 0);

    //multiple cycles sig
    sig = 1;
    #TCLK;
    assert(rise == 1);
    assert(fall == 0);
    #TCLK;
    assert(rise == 0);
    assert(fall == 0);
    #TCLK;
    assert(rise == 0);
    assert(fall == 0);
    
    sig = 0;
    #TCLK;
    assert(rise == 0);
    assert(fall == 1);
    #TCLK;
    assert(rise == 0);
    assert(fall == 0);
    #TCLK;
    assert(rise == 0);
    assert(fall == 0);

    #(10*TCLK) $display("edge_detect_tb finish ...");
    $finish;
    
end

endmodule 

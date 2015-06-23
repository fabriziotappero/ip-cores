//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tb_serirq_top.v                                             ////
////                                                              ////
////  This file is part of the Wishbone LPC Bridge project        ////
////  http://www.opencores.org/projects/wb_lpc/                   ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
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

`timescale 1 ns / 1 ns

`include "../../rtl/verilog/serirq_defines.v"

// Define Module for Test Fixture
module serirq_host_bench();

// SERIRQ Host Inputs
    reg clk_i;
    reg nrst_i;
    reg serirq_mode;
// SERIRQ Host Outputs
    wire serirq_o;
    wire serirq_oe;
    wire [31:0] irq_o;
// Bidirs
    wire serirq;

// SERIRQ Slave
    wire slave_serirq_o;
    wire slave_serirq_oe;

    reg [31:0] irq_i;

task Reset;
begin
    nrst_i = 1; # 1000;
    nrst_i = 0; # 1000;
    nrst_i = 1; # 1000;
end
endtask

   always begin
       #50 clk_i = 0;
       #50 clk_i = 1;
   end

// Instantiate the UUT
    serirq_host UUT_Serirq_Host (
        .clk_i(clk_i), 
        .nrst_i(nrst_i), 
        .serirq_mode_i(serirq_mode), 
        .irq_o(irq_o), 
        .serirq_o(serirq_o), 
        .serirq_i(serirq), 
        .serirq_oe(serirq_oe)
        );

// Instantiate the UUT Slave
    serirq_slave UUT_Serirq_Slave (
        .clk_i(clk_i), 
        .nrst_i(nrst_i), 
        .irq_i(irq_i), 
        .serirq_o(slave_serirq_o), 
        .serirq_i(serirq), 
        .serirq_oe(slave_serirq_oe)
        );

assign serirq = (serirq_oe ? serirq_o : (slave_serirq_oe ? slave_serirq_o : 1'bz));

// Initialize Inputs
    initial begin
//      $monitor("Time: %d clk_i=%b",
//          $time, clk_i);
            clk_i = 0;
            nrst_i = 1;
                irq_i = 32'hA5a51234;
                serirq_mode = `SERIRQ_MODE_CONTINUOUS;
                
    Reset();

    $display($time, " Testing SERIRQ Accesses in Continuous mode.");
    # 40000;

    if(irq_i != irq_o) begin
        $display($time, " Error, irq_i: expected %x, got %x", irq_i, irq_o); $stop(1);
    end

    irq_i = 32'h5a5a4321;
    $display($time, " Testing SERIRQ Accesses, Switch to Quiet Mode");

    serirq_mode = `SERIRQ_MODE_QUIET;
    # 40000;
     
    if(irq_i != irq_o) begin
        $display($time, " Error, irq_i: expected %x, got %x", irq_i, irq_o); $stop(1);
    end

    irq_i = 32'h5555aaaa;
    $display($time, " Slave should start serirq sequence");

    # 15000;

    irq_i = 32'ha5a5a5a5;
    $display($time, " Testing SERIRQ Accesses");
    # 40000;

    $display($time, " Switch back to Continuous");
    serirq_mode = `SERIRQ_MODE_CONTINUOUS;

    # 80000;
     
    if(irq_i != irq_o) begin
        $display($time, " Error, irq_i: expected %x, got %x", irq_i, irq_o); $stop(1);
    end
    
    $display($time, " Simulation passed"); $stop(1);

end

endmodule // serirq_tb

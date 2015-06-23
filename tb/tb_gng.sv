//------------------------------------------------------------------------------
//
// tb_gng.sv
//
// This file is part of the Gaussian Noise Generator IP Core
//
// Description
//     Systemverilog testbench for module gng. Generate noise sequences of
// length N and output to file. 
//
//------------------------------------------------------------------------------
//
// Copyright (C) 2014, Guangxi Liu <guangxi.liu@opencores.org>
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation; either version 2.1 of the License,
// or (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, download it from
// http://www.opencores.org/lgpl.shtml
//
//------------------------------------------------------------------------------


`timescale 1 ns / 1 ps


module tb_gng;

// Parameters
parameter ClkPeriod = 10.0;
parameter Dly = 1.0;
parameter N = 1000000;


// Local variables
logic clk;
logic rstn;
logic ce;
logic valid_out;
logic [15:0] data_out;


// Instances
gng #(
   .INIT_Z1(64'd5030521883283424767),
   .INIT_Z2(64'd18445829279364155008),
   .INIT_Z3(64'd18436106298727503359)
)
u_gng (.*);


// System signals
initial begin
    clk <= 1'b0;
    forever #(ClkPeriod/2) clk = ~clk;
end

initial begin
    rstn <= 1'b0;
    #(ClkPeriod*2) rstn = 1'b1;
end


// Main process
int fpOut;

initial begin
    fpOut = $fopen("gng_data_out.txt", "w");

    ce = 0;

    #(ClkPeriod*10)
    repeat (N) begin
        @(posedge clk);
        #(Dly);
        ce = 1;
    end
    @(posedge clk);
    #(Dly);
    ce = 0;

    #(ClkPeriod*20)
    $fclose(fpOut);
    $stop;
end


// Record data
always_ff @ (negedge clk) begin
    if (valid_out)
        $fwrite(fpOut, "%0d\n", $signed(data_out));
end


endmodule

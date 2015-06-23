//------------------------------------------------------------------------------
//
// gng_smul_16_18_sadd_37.v
//
// This file is part of the Gaussian Noise Generator IP Core
//
// Description
//     Signed multiplier 16-bit x 18-bit follows signed adder 37-bit,
// delay 3 cycles¡£
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


module gng_smul_16_18_sadd_37 (
    // System signals
    input clk,                  // system clock

    // Data interface
    input [15:0] a,             // multiplicand
    input [17:0] b,             // multiplicator
    input [36:0] c,             // adder
    output [37:0] p             // result
);

// Behavioral model
reg signed [15:0] a_reg;
reg signed [17:0] b_reg;
reg signed [36:0] c_reg;
reg signed [33:0] prod;
wire signed [37:0] sum;
reg [37:0] result;

always @ (posedge clk) begin
    a_reg <= a;
    b_reg <= b;
    c_reg <= c;
end

always @ (posedge clk) begin
    prod <= a_reg * b_reg;
end

assign sum = c_reg + prod;

always @ (posedge clk) begin
    result <= sum;
end

assign p = result;


endmodule

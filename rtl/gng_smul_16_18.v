//------------------------------------------------------------------------------
//
// gng_smul_16_18.v
//
// This file is part of the Gaussian Noise Generator IP Core
//
// Description
//     Signed multiplier 16-bit x 18-bit, delay 2 cycles.
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


module gng_smul_16_18 (
    // System signals
    input clk,                  // system clock

    // Data interface
    input [15:0] a,             // multiplicand
    input [17:0] b,             // multiplicator
    output [33:0] p             // result
);

// Behavioral model
reg signed [15:0] a_reg;
reg signed [17:0] b_reg;
reg signed [33:0] prod;

always @ (posedge clk) begin
    a_reg <= a;
    b_reg <= b;
end

always @ (posedge clk) begin
    prod <= a_reg * b_reg;
end

assign p = prod;


endmodule

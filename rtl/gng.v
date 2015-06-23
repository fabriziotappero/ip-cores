//------------------------------------------------------------------------------
//
// gng.v
//
// This file is part of the Gaussian Noise Generator IP Core
//
// Description
//     Top module of Gaussian noise generator.
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


module gng #(
    parameter INIT_Z1 = 64'd5030521883283424767,
    parameter INIT_Z2 = 64'd18445829279364155008,
    parameter INIT_Z3 = 64'd18436106298727503359
)
(
    // System signals
    input clk,                    // system clock
    input rstn,                   // system synchronous reset, active low

    // Data interface
    input ce,                     // clock enable
    output valid_out,             // output data valid
    output [15:0] data_out        // output data, s<16,11>
);

// Local variables
wire valid_out_ctg;
wire [63:0] data_out_ctg;


// Instances
gng_ctg #(
    .INIT_Z1(INIT_Z1),
    .INIT_Z2(INIT_Z2),
    .INIT_Z3(INIT_Z3)
) u_gng_ctg (
    .clk(clk),
    .rstn(rstn),
    .ce(ce),
    .valid_out(valid_out_ctg),
    .data_out(data_out_ctg)
);

gng_interp u_gng_interp (
    .clk(clk),
    .rstn(rstn),
    .valid_in(valid_out_ctg),
    .data_in(data_out_ctg),
    .valid_out(valid_out),
    .data_out(data_out)
);


endmodule

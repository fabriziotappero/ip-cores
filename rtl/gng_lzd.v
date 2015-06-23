//------------------------------------------------------------------------------
//
// gng_lzd.v
//
// This file is part of the Gaussian Noise Generator IP Core
//
// Description
//     Leading zero detector of 61-bit number.
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


module gng_lzd (
    // Data interface
    input [60:0] data_in,        // input data
    output [5:0] data_out        // output number of leading zeros
);

// Local variables
wire [63:0] d;
wire p1 [31:0];
wire [31:0] v1;
wire [1:0] p2 [15:0];
wire [15:0] v2;
wire [2:0] p3 [7:0];
wire [7:0] v3;
wire [3:0] p4 [3:0];
wire [3:0] v4;
wire [4:0] p5 [1:0];
wire [1:0] v5;
wire [5:0] p6;


// Parallel structure
assign d = {data_in, 3'b111};    // fill last 3 bits with '1'

assign p1[0 ] = ~d[1 ];
assign p1[1 ] = ~d[3 ];
assign p1[2 ] = ~d[5 ];
assign p1[3 ] = ~d[7 ];
assign p1[4 ] = ~d[9 ];
assign p1[5 ] = ~d[11];
assign p1[6 ] = ~d[13];
assign p1[7 ] = ~d[15];
assign p1[8 ] = ~d[17];
assign p1[9 ] = ~d[19];
assign p1[10] = ~d[21];
assign p1[11] = ~d[23];
assign p1[12] = ~d[25];
assign p1[13] = ~d[27];
assign p1[14] = ~d[29];
assign p1[15] = ~d[31];
assign p1[16] = ~d[33];
assign p1[17] = ~d[35];
assign p1[18] = ~d[37];
assign p1[19] = ~d[39];
assign p1[20] = ~d[41];
assign p1[21] = ~d[43];
assign p1[22] = ~d[45];
assign p1[23] = ~d[47];
assign p1[24] = ~d[49];
assign p1[25] = ~d[51];
assign p1[26] = ~d[53];
assign p1[27] = ~d[55];
assign p1[28] = ~d[57];
assign p1[29] = ~d[59];
assign p1[30] = ~d[61];
assign p1[31] = ~d[63];
assign v1[0 ] = d[0 ] | d[1 ];
assign v1[1 ] = d[2 ] | d[3 ];
assign v1[2 ] = d[4 ] | d[5 ];
assign v1[3 ] = d[6 ] | d[7 ];
assign v1[4 ] = d[8 ] | d[9 ];
assign v1[5 ] = d[10] | d[11];
assign v1[6 ] = d[12] | d[13];
assign v1[7 ] = d[14] | d[15];
assign v1[8 ] = d[16] | d[17];
assign v1[9 ] = d[18] | d[19];
assign v1[10] = d[20] | d[21];
assign v1[11] = d[22] | d[23];
assign v1[12] = d[24] | d[25];
assign v1[13] = d[26] | d[27];
assign v1[14] = d[28] | d[29];
assign v1[15] = d[30] | d[31];
assign v1[16] = d[32] | d[33];
assign v1[17] = d[34] | d[35];
assign v1[18] = d[36] | d[37];
assign v1[19] = d[38] | d[39];
assign v1[20] = d[40] | d[41];
assign v1[21] = d[42] | d[43];
assign v1[22] = d[44] | d[45];
assign v1[23] = d[46] | d[47];
assign v1[24] = d[48] | d[49];
assign v1[25] = d[50] | d[51];
assign v1[26] = d[52] | d[53];
assign v1[27] = d[54] | d[55];
assign v1[28] = d[56] | d[57];
assign v1[29] = d[58] | d[59];
assign v1[30] = d[60] | d[61];
assign v1[31] = d[62] | d[63];

assign p2[0 ] = {~v1[1 ], (v1[1 ] ? p1[1 ] : p1[0 ])};
assign p2[1 ] = {~v1[3 ], (v1[3 ] ? p1[3 ] : p1[2 ])};
assign p2[2 ] = {~v1[5 ], (v1[5 ] ? p1[5 ] : p1[4 ])};
assign p2[3 ] = {~v1[7 ], (v1[7 ] ? p1[7 ] : p1[6 ])};
assign p2[4 ] = {~v1[9 ], (v1[9 ] ? p1[9 ] : p1[8 ])};
assign p2[5 ] = {~v1[11], (v1[11] ? p1[11] : p1[10])};
assign p2[6 ] = {~v1[13], (v1[13] ? p1[13] : p1[12])};
assign p2[7 ] = {~v1[15], (v1[15] ? p1[15] : p1[14])};
assign p2[8 ] = {~v1[17], (v1[17] ? p1[17] : p1[16])};
assign p2[9 ] = {~v1[19], (v1[19] ? p1[19] : p1[18])};
assign p2[10] = {~v1[21], (v1[21] ? p1[21] : p1[20])};
assign p2[11] = {~v1[23], (v1[23] ? p1[23] : p1[22])};
assign p2[12] = {~v1[25], (v1[25] ? p1[25] : p1[24])};
assign p2[13] = {~v1[27], (v1[27] ? p1[27] : p1[26])};
assign p2[14] = {~v1[29], (v1[29] ? p1[29] : p1[28])};
assign p2[15] = {~v1[31], (v1[31] ? p1[31] : p1[30])};
assign v2[0 ] = v1[1 ] | v1[0 ];
assign v2[1 ] = v1[3 ] | v1[2 ];
assign v2[2 ] = v1[5 ] | v1[4 ];
assign v2[3 ] = v1[7 ] | v1[6 ];
assign v2[4 ] = v1[9 ] | v1[8 ];
assign v2[5 ] = v1[11] | v1[10];
assign v2[6 ] = v1[13] | v1[12];
assign v2[7 ] = v1[15] | v1[14];
assign v2[8 ] = v1[17] | v1[16];
assign v2[9 ] = v1[19] | v1[18];
assign v2[10] = v1[21] | v1[20];
assign v2[11] = v1[23] | v1[22];
assign v2[12] = v1[25] | v1[24];
assign v2[13] = v1[27] | v1[26];
assign v2[14] = v1[29] | v1[28];
assign v2[15] = v1[31] | v1[30];

assign p3[0] = {~v2[1 ], (v2[1 ] ? p2[1 ] : p2[0 ])};
assign p3[1] = {~v2[3 ], (v2[3 ] ? p2[3 ] : p2[2 ])};
assign p3[2] = {~v2[5 ], (v2[5 ] ? p2[5 ] : p2[4 ])};
assign p3[3] = {~v2[7 ], (v2[7 ] ? p2[7 ] : p2[6 ])};
assign p3[4] = {~v2[9 ], (v2[9 ] ? p2[9 ] : p2[8 ])};
assign p3[5] = {~v2[11], (v2[11] ? p2[11] : p2[10])};
assign p3[6] = {~v2[13], (v2[13] ? p2[13] : p2[12])};
assign p3[7] = {~v2[15], (v2[15] ? p2[15] : p2[14])};
assign v3[0] = v2[1 ] | v2[0 ];
assign v3[1] = v2[3 ] | v2[2 ];
assign v3[2] = v2[5 ] | v2[4 ];
assign v3[3] = v2[7 ] | v2[6 ];
assign v3[4] = v2[9 ] | v2[8 ];
assign v3[5] = v2[11] | v2[10];
assign v3[6] = v2[13] | v2[12];
assign v3[7] = v2[15] | v2[14];

assign p4[0] = {~v3[1], (v3[1] ? p3[1] : p3[0])};
assign p4[1] = {~v3[3], (v3[3] ? p3[3] : p3[2])};
assign p4[2] = {~v3[5], (v3[5] ? p3[5] : p3[4])};
assign p4[3] = {~v3[7], (v3[7] ? p3[7] : p3[6])};
assign v4[0] = v3[1] | v3[0];
assign v4[1] = v3[3] | v3[2];
assign v4[2] = v3[5] | v3[4];
assign v4[3] = v3[7] | v3[6];

assign p5[0] = {~v4[1], (v4[1] ? p4[1] : p4[0])};
assign p5[1] = {~v4[3], (v4[3] ? p4[3] : p4[2])};
assign v5[0] = v4[1] | v4[0];
assign v5[1] = v4[3] | v4[2];

assign p6 = {~v5[1], (v5[1] ? p5[1] : p5[0])};


// Output data
assign data_out = p6;


endmodule

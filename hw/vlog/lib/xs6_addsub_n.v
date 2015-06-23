//////////////////////////////////////////////////////////////////
//                                                              //
//  Wrapper for Xilinx Spartan-6 DSP48 Block                    //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  DSP block configured as an N-bit adder and substractor      //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////


module xs6_addsub_n #(
parameter WIDTH=32
)(
input [WIDTH-1:0]   i_a,
input [WIDTH-1:0]   i_b,
input               i_cin,
input               i_sub,

output [WIDTH-1:0]  o_sum,
output              o_co
);


wire [7:0]  opmode;
wire [47:0] in_a, in_b;
wire [47:0] out;

assign opmode = {i_sub, 1'd0, i_cin, 1'd0, 2'd3, 2'd3 };
assign in_a   = {{48-WIDTH{1'd0}}, i_a};
assign in_b   = {{48-WIDTH{1'd0}}, i_b};
assign o_sum  = out[WIDTH-1:0];
assign o_co   = out[WIDTH];


DSP48A1  #(
    // Enable registers
    .A1REG          ( 0         ),
    .B0REG          ( 0         ),
    .B1REG          ( 0         ),
    .CARRYINREG     ( 0         ),
    .CARRYOUTREG    ( 0         ),
    .CREG           ( 0         ),
    .DREG           ( 0         ),
    .MREG           ( 0         ),
    .OPMODEREG      ( 0         ),
    .PREG           ( 0         ),
    .CARRYINSEL     ("OPMODE5"  ),
    .RSTTYPE        ( "SYNC"    )
)

u_dsp48 (
    // Outputs
    .BCOUT         (                        ),
    .CARRYOUT      (                        ),
    .CARRYOUTF     (                        ), 
    .M             (                        ),
    .P             ( out                    ),
    .PCOUT         (                        ),
                                           
    // Inputs
    .CLK           ( 1'd0                   ),
                                           
    .A             (         in_b[35:18]    ),
    .B             (         in_b[17:00]    ),
    .C             (         in_a           ),
    .D             ( {6'd0,  in_b[47:36]}   ),

    .CARRYIN       ( 1'd0                   ),  // uses opmode bit 5 for carry in
    .OPMODE        ( opmode                 ),
    .PCIN          ( 48'd0                  ),

    // Clock enables
    .CEA           ( 1'd1                   ),
    .CEB           ( 1'd1                   ),
    .CEC           ( 1'd1                   ),
    .CED           ( 1'd1                   ),
    .CEM           ( 1'd1                   ),
    .CEP           ( 1'd1                   ),
    .CECARRYIN     ( 1'd1                   ),
    .CEOPMODE      ( 1'd1                   ),
    
    // Register Resets
    .RSTA          ( 1'd0                   ),
    .RSTB          ( 1'd0                   ),
    .RSTC          ( 1'd0                   ),
    .RSTCARRYIN    ( 1'd0                   ),
    .RSTD          ( 1'd0                   ),
    .RSTM          ( 1'd0                   ),
    .RSTOPMODE     ( 1'd0                   ),
    .RSTP          ( 1'd0                   )
    );
    
    
endmodule

//////////////////////////////////////////////////////////////////
//                                                              //
//  Barrel Shifter for Amber 25 Core                            //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Provides 32-bit shifts LSL, LSR, ASR and ROR                //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
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


module a25_barrel_shift (

input                       i_clk,
input       [31:0]          i_in,
input                       i_carry_in,
input       [7:0]           i_shift_amount,     // uses 8 LSBs of Rs, or a 5 bit immediate constant
input                       i_shift_imm_zero,   // high when immediate shift value of zero selected
input       [1:0]           i_function,

output      [31:0]          o_out,
output                      o_carry_out,
output                      o_stall

);


wire [31:0] quick_out;
wire        quick_carry_out;
wire [31:0] full_out;
wire        full_carry_out;
reg  [31:0] full_out_r       = 'd0;
reg         full_carry_out_r = 'd0;
reg         use_quick_r      = 1'd1;


assign o_stall      = (|i_shift_amount[7:2]) & use_quick_r;
assign o_out        = use_quick_r ? quick_out : full_out_r;
assign o_carry_out  = use_quick_r ? quick_carry_out : full_carry_out_r;


// Capture the result from the full barrel shifter in case the
// quick shifter gives the wrong value
always @(posedge i_clk)
    begin
    full_out_r       <= full_out;
    full_carry_out_r <= full_carry_out;
    use_quick_r      <= !o_stall;
    end


// Full barrel shifter
a25_shifter #( 
    .FULL_BARREL (1)
    )
u_a25_shifter_full (
    .i_in               ( i_in             ),
    .i_carry_in         ( i_carry_in       ),
    .i_shift_amount     ( i_shift_amount   ),   
    .i_shift_imm_zero   ( i_shift_imm_zero ), 
    .i_function         ( i_function       ),
    .o_out              ( full_out         ),
    .o_carry_out        ( full_carry_out   )
);



// Quick barrel shifter
a25_shifter #( 
    .FULL_BARREL        ( 0                ) 
    )
u_a25_shifter_quick (
    .i_in               ( i_in             ),
    .i_carry_in         ( i_carry_in       ),
    .i_shift_amount     ( i_shift_amount   ),   
    .i_shift_imm_zero   ( i_shift_imm_zero ), 
    .i_function         ( i_function       ),
    .o_out              ( quick_out        ),
    .o_carry_out        ( quick_carry_out  )
);

endmodule



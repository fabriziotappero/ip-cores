//////////////////////////////////////////////////////////////////
//                                                              //
//  Arithmetic Logic Unit (ALU) for Amber 25 Core               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Supported functions: 32-bit add and subtract, AND, OR,      //
//  XOR, NOT, Zero extent 8-bit numbers                         //
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


module a25_alu (

input       [31:0]          i_a_in,
input       [31:0]          i_b_in,
input                       i_barrel_shift_carry,
input                       i_status_bits_carry,
input       [8:0]           i_function,

output      [31:0]          o_out,
output      [3:0]           o_flags
);

wire     [31:0]         a, b, b_not;
wire     [31:0]         and_out, or_out, xor_out;
wire     [31:0]         sign_ex8_out, sign_ex_16_out;
wire     [31:0]         zero_ex8_out, zero_ex_16_out;
wire     [32:0]         fadder_out;
wire                    swap_sel;
wire                    not_sel;
wire     [1:0]          cin_sel;
wire                    cout_sel;
wire     [3:0]          out_sel;
wire                    carry_in;
wire                    carry_out;
wire                    overflow_out;
wire                    fadder_carry_out;

assign  { swap_sel, not_sel, cin_sel, cout_sel, out_sel } = i_function;


// ========================================================
// A Select
// ========================================================
assign a     = (swap_sel ) ? i_b_in : i_a_in ;

// ========================================================
// B Select
// ========================================================
assign b     = (swap_sel ) ? i_a_in : i_b_in ;
                             
// ========================================================
// Not Select
// ========================================================
assign b_not     = (not_sel ) ? ~b : b ;
                             
// ========================================================
// Cin Select
// ========================================================
assign carry_in  = (cin_sel==2'd0 ) ? 1'd0                   :
                   (cin_sel==2'd1 ) ? 1'd1                   :
                                      i_status_bits_carry    ;  // add with carry

// ========================================================
// Cout Select
// ========================================================
assign carry_out = (cout_sel==1'd0 ) ? fadder_carry_out     :
                                       i_barrel_shift_carry ;

// For non-addition/subtractions that incorporate a shift 
// operation, C is set to the last bit
// shifted out of the value by the shifter.


// ========================================================
// Overflow out
// ========================================================
// Only assert the overflow flag when using the adder
assign  overflow_out    = out_sel == 4'd1 &&
                            // overflow if adding two positive numbers and get a negative number
                          ( (!a[31] && !b_not[31] && fadder_out[31]) ||
                            // or adding two negative numbers and get a positive number
                            (a[31] && b_not[31] && !fadder_out[31])     );


// ========================================================
// ALU Operations
// ========================================================

`ifdef XILINX_FPGA

    // XIlinx Spartan 6 DSP module
    `ifdef XILINX_SPARTAN6_FPGA
        xs6_addsub_n #(.WIDTH(33)) 
    `endif
    `ifdef XILINX_VIRTEX6_FPGA
        xv6_addsub_n #(.WIDTH(33)) 
    `endif
        u_xx_addsub_33(
        .i_a    ( {1'd0,a}      ),
        .i_b    ( {1'd0,b_not}  ),
        .i_cin  ( carry_in      ),
        .i_sub  ( 1'd0          ),
        .o_sum  ( fadder_out    ),
        .o_co   (               )
    );

`else
assign fadder_out       = { 1'd0,a} + {1'd0,b_not} + {32'd0,carry_in};
`endif                                                

assign fadder_carry_out = fadder_out[32];
assign and_out          = a & b_not;
assign or_out           = a | b_not;
assign xor_out          = a ^ b_not;
assign zero_ex8_out     = {24'd0,  b_not[7:0]};
assign zero_ex_16_out   = {16'd0,  b_not[15:0]};
assign sign_ex8_out     = {{24{b_not[7]}},  b_not[7:0]};
assign sign_ex_16_out   = {{16{b_not[15]}}, b_not[15:0]};
                          
// ========================================================
// Out Select
// ========================================================
assign o_out = out_sel == 4'd0 ? b_not            : 
               out_sel == 4'd1 ? fadder_out[31:0] : 
               out_sel == 4'd2 ? zero_ex_16_out   :
               out_sel == 4'd3 ? zero_ex8_out     :
               out_sel == 4'd4 ? sign_ex_16_out   :
               out_sel == 4'd5 ? sign_ex8_out     :
               out_sel == 4'd6 ? xor_out          :
               out_sel == 4'd7 ? or_out           :
                                 and_out          ;

assign o_flags       = {  o_out[31],      // negative
                         |o_out == 1'd0,  // zero
                         carry_out,       // carry
                         overflow_out     // overflow
                         };
                         
                                     
endmodule



//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.1
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module - ALU
//-----------------------------------------------------------------
module altor32_alu
(
    // ALU operation select
    input [3:0]     op_i        /*verilator public*/,

    // Operands
    input [31:0]    a_i         /*verilator public*/,
    input [31:0]    b_i         /*verilator public*/,
    input           c_i         /*verilator public*/,

    // Result
    output [31:0]   p_o         /*verilator public*/,

    // Carry
    output reg      c_o         /*verilator public*/,
    output reg      c_update_o  /*verilator public*/,

    // Comparison    
    output reg      equal_o                /*verilator public*/,
    output reg      greater_than_signed_o  /*verilator public*/,
    output reg      greater_than_o         /*verilator public*/,
    output reg      less_than_signed_o     /*verilator public*/,
    output reg      less_than_o            /*verilator public*/,
    output          flag_update_o          /*verilator public*/
);

//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "altor32_defs.v"
`include "altor32_funcs.v"

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [31:0]      result_r;

reg [31:16]     shift_right_fill_r;
reg [31:0]      shift_right_1_r;
reg [31:0]      shift_right_2_r;
reg [31:0]      shift_right_4_r;
reg [31:0]      shift_right_8_r;

reg [31:0]      shift_left_1_r;
reg [31:0]      shift_left_2_r;
reg [31:0]      shift_left_4_r;
reg [31:0]      shift_left_8_r;

//-----------------------------------------------------------------
// ALU
//-----------------------------------------------------------------
always @ (op_i or a_i or b_i or c_i)
begin
   case (op_i)
       //----------------------------------------------
       // Shift Left
       //----------------------------------------------   
       `ALU_SHIFTL :
       begin
            if (b_i[0] == 1'b1)
                shift_left_1_r = {a_i[30:0],1'b0};
            else
                shift_left_1_r = a_i;

            if (b_i[1] == 1'b1)
                shift_left_2_r = {shift_left_1_r[29:0],2'b00};
            else
                shift_left_2_r = shift_left_1_r;

            if (b_i[2] == 1'b1)
                shift_left_4_r = {shift_left_2_r[27:0],4'b0000};
            else
                shift_left_4_r = shift_left_2_r;

            if (b_i[3] == 1'b1)
                shift_left_8_r = {shift_left_4_r[23:0],8'b00000000};
            else
                shift_left_8_r = shift_left_4_r;

            if (b_i[4] == 1'b1)
                result_r = {shift_left_8_r[15:0],16'b0000000000000000};
            else
                result_r = shift_left_8_r;

            c_o        = 1'b0;
            c_update_o = 1'b0;
       end
       //----------------------------------------------
       // Shift Right
       //----------------------------------------------
       `ALU_SHIFTR, `ALU_SHIRTR_ARITH:
       begin
            // Arithmetic shift? Fill with 1's if MSB set
            if (a_i[31] == 1'b1 && op_i == `ALU_SHIRTR_ARITH)
                shift_right_fill_r = 16'b1111111111111111;
            else
                shift_right_fill_r = 16'b0000000000000000;

            if (b_i[0] == 1'b1)
                shift_right_1_r = {shift_right_fill_r[31], a_i[31:1]};
            else
                shift_right_1_r = a_i;

            if (b_i[1] == 1'b1)
                shift_right_2_r = {shift_right_fill_r[31:30], shift_right_1_r[31:2]};
            else
                shift_right_2_r = shift_right_1_r;

            if (b_i[2] == 1'b1)
                shift_right_4_r = {shift_right_fill_r[31:28], shift_right_2_r[31:4]};
            else
                shift_right_4_r = shift_right_2_r;

            if (b_i[3] == 1'b1)
                shift_right_8_r = {shift_right_fill_r[31:24], shift_right_4_r[31:8]};
            else
                shift_right_8_r = shift_right_4_r;

            if (b_i[4] == 1'b1)
                result_r = {shift_right_fill_r[31:16], shift_right_8_r[31:16]};
            else
                result_r = shift_right_8_r;

            c_o        = 1'b0;
            c_update_o = 1'b0;
       end       
       //----------------------------------------------
       // Arithmetic
       //----------------------------------------------
       `ALU_ADD : 
       begin
            {c_o, result_r} = (a_i + b_i);
            c_update_o      = 1'b1;
       end
       `ALU_ADDC : 
       begin
            {c_o, result_r} = (a_i + b_i) + {31'h00000000, c_i};
            c_update_o      = 1'b1;
       end
       `ALU_SUB : 
       begin
            result_r      = (a_i - b_i);
            c_o           = 1'b0;
            c_update_o    = 1'b0;
       end
       //----------------------------------------------
       // Logical
       //----------------------------------------------       
       `ALU_AND : 
       begin
            result_r      = (a_i & b_i);
            c_o           = 1'b0;
            c_update_o    = 1'b0;
       end
       `ALU_OR  : 
       begin
            result_r      = (a_i | b_i);
            c_o           = 1'b0;
            c_update_o    = 1'b0;
       end
       `ALU_XOR : 
       begin
            result_r      = (a_i ^ b_i);
            c_o           = 1'b0;
            c_update_o    = 1'b0;
       end
       default  : 
       begin
            result_r      = a_i;
            c_o           = 1'b0;
            c_update_o    = 1'b0;
       end
   endcase
end

assign p_o    = result_r;

//-----------------------------------------------------------------
// Comparisons
//-----------------------------------------------------------------
always @ *
begin
    if (a_i == b_i)
        equal_o = 1'b1;
    else
        equal_o = 1'b0;

    if (a_i < b_i)
        less_than_o = 1'b1;
    else
        less_than_o = 1'b0;     

    if (a_i > b_i)
        greater_than_o = 1'b1;
    else
        greater_than_o = 1'b0;

    less_than_signed_o    = less_than_signed(a_i, b_i);
    greater_than_signed_o = ~(less_than_signed_o | equal_o);
end

assign flag_update_o = (op_i == `ALU_COMPARE);

endmodule

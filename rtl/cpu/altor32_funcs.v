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
// less_than_signed: Less than operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x < (int)y
//-----------------------------------------------------------------
function [0:0] less_than_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (x - y);
    if (x[31] != y[31])
        less_than_signed = x[31];
    else
        less_than_signed = v[31];
end
endfunction

//-----------------------------------------------------------------
// less_than_equal_signed: Less than or equal to operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x <= (int)y
//-----------------------------------------------------------------
function [0:0] less_than_equal_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (x - y);
    if (x == y)
        less_than_equal_signed = 1'b1;
    else if (x[31] != y[31])
        less_than_equal_signed = x[31];
    else
        less_than_equal_signed = v[31];
end
endfunction

//-----------------------------------------------------------------
// greater_than_signed: Greater than operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x > (int)y
//-----------------------------------------------------------------
function [0:0] greater_than_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (y - x);
    if (x[31] != y[31])
        greater_than_signed = y[31];
    else
        greater_than_signed = v[31];
end
endfunction

//-----------------------------------------------------------------
// greater_than_equal_signed: Greater than or equal to operator (signed)
// Inputs: x = left operand, y = right operand
// Return: (int)x >= (int)y
//-----------------------------------------------------------------
function [0:0] greater_than_equal_signed;
    input  [31:0] x;
    input  [31:0] y;
    reg [31:0] v;
begin
    v = (y - x);
    if (x == y)
        greater_than_equal_signed = 1'b1;
    else if (x[31] != y[31])
        greater_than_equal_signed = y[31];
    else
        greater_than_equal_signed = v[31];
end
endfunction

//-----------------------------------------------------------------
// sign_extend_imm16: Extend 16-bit signed value to 32-bit signed.
// Inputs: x = operand
// Return: (int)((short)x)
//-----------------------------------------------------------------
function [31:0] sign_extend_imm16;
    input  [15:0] x;
    reg [31:0] y;
begin
    if (x[15] == 1'b0)
        y[31:16] = 16'b0000000000000000;
    else
        y[31:16] = 16'b1111111111111111;

    y[15:0] = x;
    sign_extend_imm16 = y;
end
endfunction

//-----------------------------------------------------------------
// sign_extend_imm26: Extend 26-bit signed value to 32-bit signed.
// Inputs: x = operand
// Return: (int)((short)x)
//-----------------------------------------------------------------
function [31:0] sign_extend_imm26;
    input  [25:0] x;
    reg [31:0] y;
begin
    if (x[25] == 1'b0)
        y[31:26] = 6'b000000;
    else
        y[31:26] = 6'b111111;

    y[25:0] = x;
    sign_extend_imm26 = y;
end
endfunction

//-----------------------------------------------------------------
// extend_imm16: Extend 16-bit unsigned value to 32-bit unsigned.
// Inputs: x = operand
// Return: (unsigned int)x
//-----------------------------------------------------------------
function [31:0] extend_imm16;
    input  [15:0] x;
begin
    extend_imm16 = {16'h0000,x};
end
endfunction

//-----------------------------------------------------------------
// less_than_zero: Is signed value less than 0?
// Inputs: x = operand
// Return: ((int)x) < 0
//-----------------------------------------------------------------
function [0:0] less_than_zero;
    input  [31:0] x;
begin
    if ((x != 32'h00000000) & (x[31] == 1'b1))
        less_than_zero = 1'b1;
    else
        less_than_zero = 1'b0;
end
endfunction

//-----------------------------------------------------------------
// less_than_equal_zero: Is signed value less than or equal to 0?
// Inputs: x = operand
// Return: ((int)x) <= 0
//-----------------------------------------------------------------
function [0:0] less_than_equal_zero;
    input  [31:0] x;
begin
    if ((x == 32'h00000000) | (x[31] == 1'b1))
        less_than_equal_zero = 1'b1;
    else
        less_than_equal_zero = 1'b0;
end
endfunction

//-----------------------------------------------------------------
// more_than_equal_zero: Is signed value more than or equal to 0?
// Inputs: x = operand
// Return: ((int)x) >= 0
//-----------------------------------------------------------------
function [0:0] more_than_equal_zero;
    input  [31:0] x;
begin
    if ((x == 32'h00000000) | (x[31] == 1'b0))
        more_than_equal_zero = 1'b1;
    else
        more_than_equal_zero = 1'b0;
end
endfunction

//-----------------------------------------------------------------
// more_than_equal_zero: Is signed value more than 0?
// Inputs: x = operand
// Return: ((int)x) > 0
//-----------------------------------------------------------------
function [0:0] more_than_zero;
    input  [31:0] x;
begin
    if (((x != 32'h00000000) & (x[31] == 1'b0)))
        more_than_zero = 1'b1;
    else
        more_than_zero = 1'b0;
end
endfunction

//-----------------------------------------------------------------
// is_load_operation: Is this opcode a load operation?
// Inputs: opcode
// Return: 1 or 0
//-----------------------------------------------------------------
function [0:0] is_load_operation;
    input [7:0] opcode;
begin
    is_load_operation = (opcode == `INST_OR32_LBS ||
                         opcode == `INST_OR32_LBZ ||
                         opcode == `INST_OR32_LHS ||
                         opcode == `INST_OR32_LHZ ||
                         opcode == `INST_OR32_LWZ ||
                         opcode == `INST_OR32_LWS) ? 1'b1 : 1'b0;
end
endfunction

//-----------------------------------------------------------------
// is_store_operation: Is this opcode a store operation?
// Inputs: opcode
// Return: 1 or 0
//-----------------------------------------------------------------
function [0:0] is_store_operation;
    input [7:0] opcode;
begin
    is_store_operation = (opcode == `INST_OR32_SB ||
                          opcode == `INST_OR32_SH ||
                          opcode == `INST_OR32_SW) ? 1'b1 : 1'b0;
end
endfunction

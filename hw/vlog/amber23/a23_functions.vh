//////////////////////////////////////////////////////////////////
//                                                              //
//  Functions for Amber 2 Core                                  //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Functions used in more than one module                      //
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


// ========================================================
// PC Filter - Remove the status bits 
// ========================================================
function [31:0] pcf;
input [31:0] pc_reg;
    begin
    pcf = {6'd0, pc_reg[25:2], 2'd0};
    end
endfunction


// ========================================================
// 4-bit to 16-bit 1-hot decode
// ========================================================
function [14:0] decode;
input [3:0] reg_sel;
begin
case ( reg_sel )
    4'h0:    decode = 15'h0001;
    4'h1:    decode = 15'h0002;
    4'h2:    decode = 15'h0004;
    4'h3:    decode = 15'h0008;
    4'h4:    decode = 15'h0010;
    4'h5:    decode = 15'h0020;
    4'h6:    decode = 15'h0040;
    4'h7:    decode = 15'h0080;
    4'h8:    decode = 15'h0100;
    4'h9:    decode = 15'h0200;
    4'ha:    decode = 15'h0400;
    4'hb:    decode = 15'h0800;
    4'hc:    decode = 15'h1000;
    4'hd:    decode = 15'h2000;
    4'he:    decode = 15'h4000;
    default: decode = 15'h0000;
endcase
end
endfunction


// ========================================================
// Convert Stats Bits Mode to one-hot encoded version
// ========================================================
function [3:0] oh_status_bits_mode;
input [1:0] fn_status_bits_mode;
begin
oh_status_bits_mode = 
    fn_status_bits_mode == SVC  ? 1'd1 << OH_SVC  :
    fn_status_bits_mode == IRQ  ? 1'd1 << OH_IRQ  :
    fn_status_bits_mode == FIRQ ? 1'd1 << OH_FIRQ :
                                  1'd1 << OH_USR  ;
end
endfunction

// ========================================================
// Convert mode into ascii name
// ========================================================
function [(14*8)-1:0]  mode_name;
input [4:0] mode;
begin

mode_name    = mode == USR  ? "User          " :
               mode == SVC  ? "Supervisor    " :
               mode == IRQ  ? "Interrupt     " :
               mode == FIRQ ? "Fast Interrupt" :
                              "UNKNOWN       " ;
end
endfunction


// ========================================================
// Conditional Execution Function
// ========================================================
// EQ Z set
// NE Z clear
// CS C set
// CC C clear
// MI N set
// PL N clear
// VS V set
// VC V clear
// HI C set and Z clear
// LS C clear or Z set
// GE N == V
// LT N != V
// GT Z == 0,N == V
// LE Z == 1 or N != V
// AL Always (unconditional)
// NV Never

function conditional_execute;
input [3:0] condition;
input [3:0] flags;
begin
conditional_execute  
               = ( condition == AL                                        ) ||
                 ( condition == EQ  &&  flags[2]                          ) ||
                 ( condition == NE  && !flags[2]                          ) ||
                 ( condition == CS  &&  flags[1]                          ) ||
                 ( condition == CC  && !flags[1]                          ) ||
                 ( condition == MI  &&  flags[3]                          ) ||
                 ( condition == PL  && !flags[3]                          ) ||
                 ( condition == VS  &&  flags[0]                          ) ||
                 ( condition == VC  && !flags[0]                          ) ||
            
                 ( condition == HI  &&    flags[1] && !flags[2]           ) ||
                 ( condition == LS  &&  (!flags[1] ||  flags[2])          ) ||
            
                 ( condition == GE  &&  flags[3] == flags[0]              ) ||
                 ( condition == LT  &&  flags[3] != flags[0]              ) ||

                 ( condition == GT  &&  !flags[2] && flags[3] == flags[0] ) ||
                 ( condition == LE  &&  (flags[2] || flags[3] != flags[0])) ;
            
end
endfunction


// ========================================================
// Log 2
// ========================================================

function [31:0] log2;
input    [31:0] num;
integer i;
integer out;
begin
  out = 32'd0;
  for (i=0; i<30; i=i+1)
    if ((2**i > num) && (out == 0))
      out = i-1;
  log2 = out;
end
endfunction

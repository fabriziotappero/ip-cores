//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
//
// *File Name: io_mux.v
// 
// *Module Description:
//                      I/O mux for port function selection.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 23 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2009-08-30 18:39:26 +0200 (Sun, 30 Aug 2009) $
//----------------------------------------------------------------------------


module  io_mux (

// Function A (typically GPIO)
    a_din,
    a_dout,
    a_dout_en,

// Function B (Timer A, ...)
    b_din,
    b_dout,
    b_dout_en,

// IO Cell
    io_din,
    io_dout,
    io_dout_en,

// Function selection (0=A, 1=B)
    sel
);

// PARAMETERs
//============
parameter          WIDTH = 8;
   
// Function A (typically GPIO)
//===============================
output [WIDTH-1:0] a_din;
input  [WIDTH-1:0] a_dout;
input  [WIDTH-1:0] a_dout_en;

// Function B (Timer A, ...)
//===============================
output [WIDTH-1:0] b_din;
input  [WIDTH-1:0] b_dout;
input  [WIDTH-1:0] b_dout_en;

// IO Cell
//===============================
input  [WIDTH-1:0] io_din;
output [WIDTH-1:0] io_dout;
output [WIDTH-1:0] io_dout_en;

// Function selection (0=A, 1=B)
//===============================
input  [WIDTH-1:0] sel;


//=============================================================================
// 1)  I/O FUNCTION SELECTION MUX
//=============================================================================

function [WIDTH-1:0] mux (
   input [WIDTH-1:0] A,
   input [WIDTH-1:0] B,
   input [WIDTH-1:0] SEL
);
   integer i;   
   begin
      mux = {WIDTH{1'b0}};
      for (i = 0; i < WIDTH; i = i + 1)
	mux[i] = sel[i] ? B[i] : A[i];
   end
endfunction


assign a_din      = mux(       io_din, {WIDTH{1'b0}}, sel);
assign b_din      = mux({WIDTH{1'b0}},        io_din, sel);
assign io_dout    = mux(       a_dout,        b_dout, sel);
assign io_dout_en = mux(    a_dout_en,     b_dout_en, sel);

	   
endmodule // io_mux

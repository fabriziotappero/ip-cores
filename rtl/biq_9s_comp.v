`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: 9's complement of a bi-quinary number.
// 
// Additional Comments: 
//
// Copyright (c) 2015 Robert Abeles
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
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module biq_9s_comp (
   input  [0:6] biq_in,
   output [0:6] biq_out
   );

   //-----------------------------------------------------------------------------
   //  9's complement swaps binary bits and reverses order of quinary bits.
   //-----------------------------------------------------------------------------
   assign biq_out = {biq_in[`biq_b0], biq_in[`biq_b5],
                     biq_in[`biq_q0], biq_in[`biq_q1],
                     biq_in[`biq_q2], biq_in[`biq_q3],
                     biq_in[`biq_q4]};

endmodule

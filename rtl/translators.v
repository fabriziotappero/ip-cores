`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Drum code translators.
// 
// Additional Comments: See US 2959351, Fig. 72.
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

module translators (
    input [0:6] dist_early_out, bs_out, console_out,
    input ri_gs, ri_bs, ri_console,
    input n800x, console_read_gs,
    input [0:4] gs_out,
    output gs_write,
    output [0:4] gs_in,
    output [0:6] gs_biq_out
    );

   wire [0:6] sel_in7;
   wire [0:6] sel_out7;
   xlate7to5 x75 (sel_in7, gs_in);
   xlate5to7 x57 (gs_out, sel_out7);
   
   assign gs_write = ri_gs | ri_bs | ri_console;
   
   assign sel_in7 = ri_console? console_out
                  : ri_gs? dist_early_out 
                  : ri_bs? bs_out 
                  : `biq_blank;
   assign gs_biq_out = (n800x | console_read_gs)? sel_out7 : `biq_blank;

endmodule

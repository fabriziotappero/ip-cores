`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Storage output selection.
// 
// Additional Comments: See US 2959351, Fig. 73.
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

module store_select (
    input d0, d1_dx,
    input addr_no_800x, addr_8000, addr_8001, addr_8002_8003,
    input addr_hot_8000,
    input [0:6] acc_ontime, dist_ontime, gs_out, console_switches,
    input acc_plus, acc_minus,
    
    output [0:6] selected_out
    );
    
   wire[0:6] acc_sign = acc_plus? `biq_9 : acc_minus? `biq_8 : `biq_blank;
   wire[0:6] acc_select = d1_dx? acc_ontime : d0? acc_sign : `biq_blank;
   assign selected_out = addr_no_800x?                gs_out
                       : (addr_8000 | addr_hot_8000)? console_switches
                       : addr_8001?                   dist_ontime
                       : addr_8002_8003?              acc_select
                       :                              `biq_blank;

endmodule

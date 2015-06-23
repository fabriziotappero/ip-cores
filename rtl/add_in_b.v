`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Adder input B.
// 
// Additional Comments: See US 2959351, Fig. 67.
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

module add_in_b (
   input [0:6] dist_early_out, dist_ontime_out,
   input [0:9] special_int_entry,
   input ontime_dist_add_gate_tlu, dist_compl_add_gate, upper_lower_check,
         dist_blank_gate, early_dist_zero_entry, //early_dist_zero_ctrl,
         dist_true_add_gate,
    
   output [0:6] adder_entry_b
   );

   wire [0:6] special_int_biq = special_int_entry[0]? `biq_0
                              : special_int_entry[1]? `biq_1
                              : special_int_entry[2]? `biq_2
                              : special_int_entry[3]? `biq_3
                              : special_int_entry[4]? `biq_4
                              : special_int_entry[5]? `biq_5
                              : special_int_entry[6]? `biq_6
                              : special_int_entry[7]? `biq_7
                              : special_int_entry[8]? `biq_8
                              : special_int_entry[9]? `biq_9
                              : `biq_blank;
   wire [0:6] dist_early_compl;
   biq_9s_comp bc1 (dist_early_out, dist_early_compl);
   wire dist_true_add  = dist_true_add_gate  & upper_lower_check & dist_blank_gate;
   wire dist_compl_add = dist_compl_add_gate & upper_lower_check & dist_blank_gate;
   
   assign adder_entry_b = early_dist_zero_entry?    `biq_0
                        : dist_true_add?            dist_early_out
                        : dist_compl_add?           dist_early_compl
                        : ontime_dist_add_gate_tlu? dist_ontime_out
                        :                           special_int_biq;

endmodule

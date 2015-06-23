`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Adder input A.
// 
// Additional Comments: See US 2959351, Fig. 66.
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

module add_in_a (
   input [0:6] acc_early_out, acc_ontime_out, prog_step_early_out,
               select_storage_out, addr_u,
   input acc_true_add_gate, acc_compl_add_gate,
         left_shift_gate, prog_step_add_gate, shift_num_gate, 
         select_stor_add_gate,    
   output [0:6] adder_entry_a
   );

   wire [0:6] acc_early_compl;   // 9's complement
   biq_9s_comp bc1 (acc_early_out, acc_early_compl);
   wire [0:6] addr_u_compl;
   biq_9s_comp bc2 (addr_u, addr_u_compl);

   assign adder_entry_a = acc_true_add_gate?    acc_early_out 
                        : acc_compl_add_gate?   acc_early_compl 
                        : left_shift_gate?      acc_ontime_out
                        : prog_step_add_gate?   prog_step_early_out
                        : shift_num_gate?       addr_u_compl
                        : select_stor_add_gate? select_storage_out
                        :                       `biq_blank;

endmodule

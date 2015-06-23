`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Operation code register.
// 
// Additional Comments: See US 2959351, Fig. 69.
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

module op_reg (
   input rst,
   input cp,
   input d0, d9, d10, d1_d5, d5_dx,
   input restart_a, restart_b, d_alt, i_alt, tlu_band_change, man_prog_reset,
   input [0:6] prog_step_ped,
    
   output reg[0:6] opreg_t, opreg_u,
   output ri_addr_reg
   );

   wire op_reg_reset;
   assign ri_addr_reg = (d_alt & restart_b & d5_dx) 
                      | (i_alt & restart_b & d1_d5) 
                      | (tlu_band_change & d1_d5);
   assign op_reg_reset = man_prog_reset | restart_a | (tlu_band_change & d0);
    
   // reading the program step pedistal, so must wait for c phase
   always @(posedge cp)
      if (rst) begin
         opreg_t <= `biq_blank;
         opreg_u <= `biq_blank;
      end else if (op_reg_reset) begin
         opreg_t <= `biq_blank;
         opreg_u <= `biq_blank;
      end else if (ri_addr_reg) begin
         if (d9)
            opreg_u <= prog_step_ped;
         if (d10)
            opreg_t <= prog_step_ped;
      end;
   
endmodule

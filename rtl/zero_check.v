`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Accumulator zero check.
// 
// Additional Comments: See US 2959351, Fig. 84.
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

module zero_check (
    input rst,
    input bp,
    input d0, d1_dx,
    input wu,
    input acc_no_zero,
    
    output acc_no_zero_test, acc_zero_test
    );

   reg no_zero_latch, no_zero_check_latch;
   assign acc_no_zero_test = no_zero_latch & no_zero_check_latch;
   assign acc_zero_test = ~no_zero_latch & ~no_zero_check_latch;
   
   always @(posedge bp)
      if (rst) begin
         no_zero_latch <= 0;
         no_zero_check_latch <= 0;
      end else if (wu & d0) begin
         no_zero_latch <= 0;
         no_zero_check_latch <= 0;
      end else if (acc_no_zero & d1_dx) begin
         no_zero_latch <= 1;
         no_zero_check_latch <= 1;
      end;
   
endmodule

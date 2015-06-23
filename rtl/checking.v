`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Register validity checking.
// 
// Additional Comments: See US 2959351, Fig. 82.
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

module biq_check (
   input [0:6] biq,
   output invalid
   );
   
   //-----------------------------------------------------------------------------
   // Validate bi-quinary digit. 
   //-----------------------------------------------------------------------------
   wire q0_or_q1 = biq[`biq_q0] | biq[`biq_q1];
   wire q2_or_q3_or_q4 = biq[`biq_q2] | biq[`biq_q3] | biq[`biq_q4];
   wire b0_or_b5 = biq[`biq_b0] | biq[`biq_b5];
   wire q0_and_q1 = biq[`biq_q0] & biq[`biq_q1];
   wire b0_and_b5 = biq[`biq_b0] & biq[`biq_b5];
   wire q2_and_q4 = biq[`biq_q2] & biq[`biq_q4];
   wire q3_and_q4 = biq[`biq_q3] & biq[`biq_q4];
   wire q2_and_q3 = biq[`biq_q2] & biq[`biq_q3];
   assign invalid =  (q2_and_q4)
                   | (q3_and_q4)
                   | (q2_and_q3) 
                   | (q0_or_q1 & q2_or_q3_or_q4)
                   | (q0_and_q1)
                   | (b0_and_b5)
                   | ~(b0_or_b5 & (q0_or_q1 | q2_or_q3_or_q4));
   
endmodule

module checking (
   input rst,
   input bp,
   input d1_dx,
   input [0:6] acc_ontime, prog_ontime, dist_ontime,
   input error_reset, tlu_or_zero_check,

   output error_stop, acc_check_light, prog_check_light, dist_check_light
   );
   
   reg acc_error, prog_error, dist_error;
   wire acc_invalid, prog_invalid, dist_invalid;
   biq_check bc1 (acc_ontime, acc_invalid);
   biq_check bc2 (prog_ontime, prog_invalid);
   biq_check bc3 (dist_ontime, dist_invalid);
   assign error_stop = tlu_or_zero_check | acc_error | prog_error | dist_error;
   assign acc_check_light = acc_error;
   assign prog_check_light = prog_error;
   assign dist_check_light = dist_error;
   
   always @(posedge bp)
      if (rst) begin
         acc_error <= 0;
         prog_error <= 0;
         dist_error <= 0;
      end else if (error_reset) begin
         acc_error <= 0;
         prog_error <= 0;
         dist_error <= 0;
      end else begin
         if (acc_invalid) acc_error <= 1;
         if (prog_invalid & d1_dx) prog_error <= 1;
         if (dist_invalid) dist_error <= 1;
      end;
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Digit time pulse generator. Emits a pulse lasting 1 digit time
//    beginning at the first rising clk edge at/after in_pulse becomes true,
//    approximating rising-edge triggering by in_pulse.
// 
// Additional Comments: Input init_history is a 0 for rising egde tiggering.
//    For falling edge triggering, set in_pulse to the complement of the signal
//    and set init_history to 1.
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

module digit_pulse (
   input rst, clk,
   input in_pulse,
   input init_history,
   output reg out_pulse
   );

   reg history;
   
   always @(posedge clk) begin
      if (rst) begin
         out_pulse <= 0;
         history <= init_history;
      end else if (out_pulse) begin
         out_pulse <= 0;
      end else if (in_pulse) begin
         out_pulse <= ~history;
         history <= 1;
      end else begin
         history <= 0;
      end
   end;
endmodule

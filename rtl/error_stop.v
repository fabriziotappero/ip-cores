`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: Error stop and sense controls.
// 
// Additional Comments: See US 2959351, Fig. 79.
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

module error_stop (
    input rst,
    input ap, dp,
    input dxu, d10, wl,
    input err_restart_sw, err_reset, err_sense_reset, clock_err_sig,
          err_stop_sig, restart_reset_busy,
    
    output err_sense_light,
    output reg err_stop, err_stop_ed0u, err_sense_restart, restart_reset
    );
    
   reg err_sense;
   
   //-----------------------------------------------------------------------------
   //  The err_sense flip-flop does nothing but control a light.
   //-----------------------------------------------------------------------------
   assign err_sense_light = err_sense;
   always @(posedge ap)
      if      (rst)                       err_sense <= 0;
      else if (err_sense_reset)           err_sense <= 0;
      else if (err_stop & err_restart_sw) err_sense <= 1;
      
   //-----------------------------------------------------------------------------
   // This FSM controls the error stop / error restart process.
   //-----------------------------------------------------------------------------
   reg [0:2] state;
   `define restart_idle 3'd0
   `define restart_1    3'd1
   `define restart_2    3'd2
   `define restart_3    3'd3
   `define restart_4    3'd4
   `define restart_5    3'd5
   `define restart_6    3'd6
   always @(posedge dp)
      if (rst) begin
         err_sense_restart <= 0;
         restart_reset     <= 0;
         err_stop          <= 0;
         err_stop_ed0u     <= 0;
         state             <= `restart_idle;
      end else
         case (state)
            `restart_idle:    // start state, transition on external err signal
                              // error restart switch selects next state
               if (err_reset) 
                  err_stop <= 0;
               else if (~err_stop & (clock_err_sig | err_stop_sig)) begin
                  err_stop <= 1;
                  if (err_restart_sw)
                     state <= `restart_1;
                  else
                     state <= `restart_5;
               end
            `restart_1:       // >>>error_sense switch position<<<
                              // wait for dxu
                              // signal console to begin restart reset
                              // turn off run latch
               if (dxu) begin
                  restart_reset <= 1;
                  err_stop_ed0u <= 1;
                  state <= `restart_2;
               end
            `restart_2: begin // wait for restart reset to start
               err_stop_ed0u <= 0;
               if (restart_reset_busy) begin
                  restart_reset <= 0;
                  state <= `restart_3;
               end
            end
            `restart_3:       // wait for end of restart reset
                              // turn on run latch
               if (~restart_reset_busy & wl & d10) begin
                  err_sense_restart <= 1;
                  err_stop <= 0;
                  state <= `restart_4;
               end
            `restart_4: begin
               err_sense_restart <= 0;
               state <= `restart_idle;
            end
            `restart_5:       // >>>error_stop switch position<<<
                              // turn off run latch
               if (dxu) begin
                  err_stop_ed0u <= 1;
                  state <= `restart_6;
               end
            `restart_6: begin
               err_stop_ed0u <= 0;
               state <= `restart_idle;
            end
         endcase;
   
endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// clock_detect.v                                               ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
////   Use a stable, faster clock to detect whether a slower      ////
////  input clock (sclk_i) is actually running.                   ////
////                                                              ////
////   If there is no change is the suspect clock for (1<<CW)     ////
////  clk_i periods; the alive_o output will be de-asserted.      ////
////                                                              ////
////   For example, if clk_i has a period of 1us, and CW=8: when  ////
////  there is no transition on sclk_i for 256us, the alive_o     ////
////  output will be de-asserted.                                 ////
////                                                              ////
////   For the alive_o output to be asserted, there must be       ////
////   2 changes in sclk_i within (1<<CW) clock periods.          ////
////                                                              ////
////   The "alive_o" output is synchronous with clk_i.            ////
////                                                              ////
//// To Do:                                                       ////
//// Verify in silicon.                                           ////
////                                                              ////
//// Author(s):                                                   ////
//// - Shannon Hill                                               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2004 Shannon Hill and OPENCORES.ORG            ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from <http://www.opencores.org/lgpl.shtml>                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// $Id: clock_detect.v,v 1.1 2004-07-07 12:41:17 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
module clock_detect( /*AUTOARG*/
// Outputs
alive_o, 
// Inputs
rst_i, clk_i, sclk_i
);

input     rst_i;
input     clk_i;

input     sclk_i;   // suspect clock
output    alive_o;

parameter CW = 8;   // if (1<<CW) clk_i's occur with no sclk_i change, it's stopped.

reg   [2:0]          synchro;
wire                 changed = synchro[2] ^ synchro[1];

reg              nxt_alive_o;
reg                  alive_o;

reg   [CW-1:0]   nxt_counter;
reg   [CW-1:0]       counter;
wire  [CW-1:0]       counter_inc =  counter + 1'b1;
wire                 timeout     = &counter;

reg    [1:0]     nxt_state;
reg    [1:0]     cur_state;

parameter [1:0] STOPPED  = 2'd0;
parameter [1:0] CHECKING = 2'd1;
parameter [1:0] RUNNING  = 2'd2;

always @( /*AUTOSENSE*/changed or counter_inc or cur_state or timeout)
begin
                         nxt_alive_o = 1'b0;
                         nxt_state   = cur_state;
                         nxt_counter = {CW{1'b0}};

     case( cur_state )

     STOPPED:  if( changed )                          // wait for an sclk_i change...
                         nxt_state   = CHECKING;

     CHECKING:  casex( { changed, timeout } )
                2'b00:   nxt_counter = counter_inc;   // waiting for another change...
                2'b01:   nxt_state   = STOPPED;       // give up.
                2'b1X:   nxt_state   = RUNNING;       // changed again!
                default: ;
                endcase

     RUNNING:  begin
                         nxt_alive_o = 1'b1;

                casex( { changed, timeout } )
                2'b00:   nxt_counter = counter_inc;   // waiting for another change...
                2'b01:   nxt_state   = STOPPED;       // give up.
                2'b1X:   ;                            // changed; still alive...
                default: ;
                endcase

               end

     default:            nxt_state   = STOPPED;
     endcase
end


always @( posedge clk_i or posedge rst_i)
if( rst_i )
begin
                cur_state <= STOPPED;
                counter   <= {CW{1'b0}};
                alive_o   <= 1'b0;
                synchro   <= 3'b0;
end
else
begin
                cur_state <= nxt_state;
                counter   <= nxt_counter;
                alive_o   <= nxt_alive_o;

                synchro   <= { synchro[1:0], sclk_i }; // async input; sclk_i consumed as data

//
// synopsys translate_off
//              case( { nxt_alive_o, alive_o } )
//              2'b01:  $display( "%d:%m: clock dead.", $time);
//              2'b10:  $display( "%d:%m: clock alive.", $time);
//              default: ;
//              endcase
// synopsys translate_on
//
end

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// arbiter.v                                                    ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
//// Parameterizable round-robin arbiter.                         ////
////  RNUM = log2( number of requestors )                         ////
////  so, RNUM = 3 implies 8 requestors.                          ////
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
// $Id: arbiter.v,v 1.1 2004-07-07 12:41:17 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
module arbiter( /*AUTOARG*/
// Outputs
grant, 
// Inputs
rst_i, clk_i, reqst
);
parameter RNUM = 3;
parameter RCNT = 1<<RNUM;     // 1 bit per request

input                 rst_i;
input                 clk_i;

input  [RCNT-1:0]     reqst;
output [RCNT-1:0]     grant;

reg    [RCNT-1:0]     grant;
reg    [RCNT-1:0] nxt_grant;

reg    [RNUM-1:0]     state;  // the last-granted-request number
reg    [RNUM-1:0] nxt_state;
wire   [RNUM-1:0] inc_state = state + 1'b1;

reg                 granted;

integer i,j;

//
// rotate the requests, based on state.
//
wire   [RCNT-1:0] req_bit = { reqst, reqst } >> inc_state;

// maintain a list of which req_bit is mapped to which
//  request number, so that we can issue the appropriate grant.
//
reg    [RNUM-1:0] req_map [0:RCNT-1];

always @( inc_state )
for( i = 0 ; i < RCNT ; i = i + 1 ) req_map[i] = i+inc_state;

//
// issue the next grant...
//
always @( grant or req_bit or reqst or state )
begin
       nxt_state = state;
       nxt_grant = grant;
       granted   = 1'b0;

if( (   grant[ state ] & ~reqst[ state ] ) || // request going inactive? or...
    ( ~|grant                            ) )  // no grants outstanding?
begin

       nxt_grant = {RCNT{1'b0}};            // de-assert all grants

   for( j = 0 ; j < RCNT ; j = j + 1 )
     if( req_bit[j] & ~granted )            // look for a pending request
     begin
       nxt_state = req_map[j];              // change state to granted number
       nxt_grant[  req_map[j] ] = 1'b1;     // issue the grant
       granted   = 1'b1;                    // issue only 1 grant (verilog has no "break;")
     end
end
end


always @( posedge clk_i or posedge rst_i )
if( rst_i )
begin
    grant <= {RCNT{1'b0}};
    state <= {RNUM{1'b0}};
end
else
begin
    grant <= nxt_grant;
    state <= nxt_state;
end

endmodule

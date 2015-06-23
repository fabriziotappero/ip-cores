//////////////////////////////////////////////////////////////////////
////                                                              ////
//// random_ff.v                                                  ////
////                                                              ////
//// This file is part of the boundaries opencores effort.        ////
//// <http://www.opencores.org/cores/boundaries/>                 ////
////                                                              ////
//// Module Description:                                          ////
////                                                              ////
//// This model of a set/reset D flipflop emits a random 0 or 1   ////
//// on a setup or hold violation; instead of going X like most   ////
//// simulation models of D flipflops.  Its output DOES go X if   ////
//// the CLK, SETN, or CLRN inputs become undefined.              ////
//// Not intended for synthesis.                                  ////
////                                                              ////
//// To Do:                                                       ////
//// Done.                                                        ////
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
// $Id: random_ff.v,v 1.1 2004-07-07 12:41:17 esquehill Exp $
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//
//
module random_ff( /*AUTOARG*/
// Outputs
Q, 
// Inputs
D, CLK, CLRN, SETN, SI, SE
);

input   D;
input   CLK;
output  Q;
input   CLRN;   //  reset when 0
input   SETN;   // preset when 0
input   SI;     // scan input
input   SE;     // scan enable

parameter D2Q = 0.200; // Q delay

// synopsys translate_off

reg     Q;
reg     syn_notify;
reg     asy_notify;
integer seed;

initial
begin
seed        = 19827;
syn_notify  = 0;
asy_notify  = 0;
end

wire se_check;
wire dq_check;
wire sq_check;

and u_se_check ( se_check, CLRN, SETN      );
and u_dq_check ( dq_check, CLRN, SETN, ~SE );
and u_sq_check ( sq_check, CLRN, SETN,  SE );

wire CLK_is_X = (CLK ===0) ? 1'b0 : ((CLK ===1) ? 1'b0 : ($stime > 0));
wire CLR_is_X = (CLRN===0) ? 1'b0 : ((CLRN===1) ? 1'b0 : ($stime > 0));
wire SET_is_X = (SETN===0) ? 1'b0 : ((SETN===1) ? 1'b0 : ($stime > 0));

wire #0.1 old_CLK = CLK; // X->1 should NOT work like a 0->1 edge

//
// handle CLK input
//
always @( posedge CLK )
begin
 case( SE | old_CLK )
 1'b0:    Q <= #(D2Q)    D;
 1'b1:    Q <= #(D2Q)   SI;
 default: Q <= #(D2Q) 1'bX;
 endcase
end

//
// handle async inputs
//
always @( negedge CLRN or negedge SETN )
begin
 case( { SETN, CLRN } )

 2'b00:   Q <= #(D2Q)1'b1; // both set & clr?????

 2'b0Z,
 2'b0X,                    // set wins
 2'b01:   Q <= #(D2Q)1'b1;

 2'bZ0,
 2'bX0,                    // clr wins
 2'b10:   Q <= #(D2Q)1'b0;

 default: Q <= #(D2Q)1'bX; // no good...
 endcase
end

//
// handle CLK, CLRN, or SETN going X/Z (Q -> X).
// handle setup/hold violation         (Q -> 0 or 1).
//

always @( syn_notify or posedge CLK_is_X or posedge CLR_is_X or posedge SET_is_X )
if( CLK_is_X | CLR_is_X | SET_is_X )
begin
          Q <= 1'bX;
          Q <= #(D2Q) 1'bX;
end
else
begin
          Q <= 1'bX;
          Q <= #(D2Q) $random(seed);
end

//
// all these specparams are technology-specific;
// just provide place-holders for now...
// Note: Don't expect the testbench to work after you change all these values.
//

specify
specparam
            r_width = 0.48,
            p_width = 0.49,
            d_setup = 0.50,
            d_hold  = 0.51,
           si_setup = 0.52,
           si_hold  = 0.53,
           se_setup = 0.54,
           se_hold  = 0.55,
            r_setup = 0.56,
            r_hold  = 0.57,
            p_setup = 0.59,
            p_hold  = 0.60,
          rvp_setup = 0.62,  // reset vs. preset
          rvp_hold  = 0.63;

// While no SETN and no CLRN and no SE;
// If D changes near CLK,  Q is uncertain
$setuphold( posedge CLK &&& (dq_check===1), posedge D ,  d_setup,  d_hold, syn_notify );
$setuphold( posedge CLK &&& (dq_check===1), negedge D ,  d_setup,  d_hold, syn_notify );

// While no SETN and no CLRN;
// If SE changes near CLK, Q is uncertain
$setuphold( posedge CLK &&& (se_check===1), posedge SE, se_setup, se_hold, syn_notify );
$setuphold( posedge CLK &&& (se_check===1), negedge SE, se_setup, se_hold, syn_notify );

// While no SETN and no CLRN and is SE;
// If SI changes near CLK, Q is uncertain
$setuphold( posedge CLK &&& (sq_check===1), posedge SI, si_setup, si_hold, syn_notify );
$setuphold( posedge CLK &&& (sq_check===1), negedge SI, si_setup, si_hold, syn_notify );

// While no SETN;
// If CLRN de-asserts near CLK, it's uncertain which wins; CLRN or CLK.
$setuphold( posedge CLK &&&      (SETN===1), posedge CLRN,  r_setup  ,  r_hold, asy_notify );

// While no CLRN;
// If SETN de-asserts near CLK, it's uncertain which wins; SETN or CLK.
$setuphold( posedge CLK &&&      (CLRN===1), posedge SETN,  p_setup  ,  p_hold, asy_notify );

// If CLRN de-asserts near SETN deassertion, it's uncertain which wins; SETN or CLRN.
$setuphold( posedge CLRN, posedge SETN,  rvp_setup, rvp_hold,  asy_notify );

// check for narrow CLRNs
$width(                   negedge CLRN,  r_width  , 0,         asy_notify );

// check for narrow SETNs
$width(                   negedge SETN,  p_width  , 0,         asy_notify );

endspecify

// synopsys translate_on

endmodule


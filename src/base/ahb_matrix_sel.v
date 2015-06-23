<##//////////////////////////////////////////////////////////////////
////                                                             ////
////  Author: Eyal Hochberg                                      ////
////          eyal@provartec.com                                 ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2010 Provartec LTD                            ////
//// www.provartec.com                                           ////
//// info@provartec.com                                          ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// This source file is free software; you can redistribute it  ////
//// and/or modify it under the terms of the GNU Lesser General  ////
//// Public License as published by the Free Software Foundation.////
////                                                             ////
//// This source is distributed in the hope that it will be      ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied  ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR     ////
//// PURPOSE.  See the GNU Lesser General Public License for more////
//// details. http://www.gnu.org/licenses/lgpl.html              ////
////                                                             ////
//////////////////////////////////////////////////////////////////##>

OUTFILE PREFIX_sel.v
INCLUDE def_ahb_matrix.txt

ITER MX
ITER SX
module PREFIX_sel(PORTS);

   input 		       clk;
   input 		       reset;

   input [MSTRS-1:0]           SSX_mstr;
   
   input                       SSX_HREADY;
   
   
   output 		       SSX_MMX;
   output                      SSX_MMX_resp;
   


   
   reg [MSTRS-1:0]             SSX_mstr_resp;


   LOOP SX
   always @(posedge clk or posedge reset)
     if (reset)
       SSX_mstr_resp <= #FFD {MSTRS{1'b0}};
     else if (SSX_HREADY)
       SSX_mstr_resp <= #FFD SSX_mstr;

   ENDLOOP SX

     
   assign 		      SSX_MMX      = SSX_mstr[MX];
   
   assign 		      SSX_MMX_resp = SSX_mstr_resp[MX];
   
endmodule





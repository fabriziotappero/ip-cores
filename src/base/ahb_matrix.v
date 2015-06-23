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

OUTFILE PREFIX.v
INCLUDE def_ahb_matrix.txt

ITER MX
ITER SX
  
module PREFIX(PORTS);

   input 		       clk;
   input                       reset;
   
   port                        MMX_GROUP_AHB;
   revport                     SSX_GROUP_AHB;

   

   wire [MSTRS-1:0]            SSX_mstr;
   
   wire [SLV_BITS-1:0]         MMX_slv;

   wire                        MMX_HLAST;
   
   wire                        SSX_MMX;
   wire                        SSX_MMX_resp;


   
   CREATE ahb_matrix_dec.v
   PREFIX_dec
   PREFIX_dec (
                  .MMX_HADDR(MMX_HADDR),
                  .MMX_slv(MMX_slv),
                  STOMP ,
                  );


   CREATE ahb_matrix_hlast.v
     PREFIX_hlast
       PREFIX_hlast(
                        .clk(clk),
                        .reset(reset),
                        .MMX_HTRANS(MMX_HTRANS),
                        .MMX_HREADY(MMX_HREADY),
                        .MMX_HBURST(MMX_HBURST),
                        .MMX_HLAST(MMX_HLAST),
                        STOMP ,
                        );
   
   
   CREATE prgen_arbiter.v DEFCMD(SWAP CONST(PREFIX) PREFIX) DEFCMD(SWAP MSTR_SLV mstr) DEFCMD(SWAP MSTRNUM MSTRS) DEFCMD(SWAP SLVNUM SLVS) DEFCMD(DEFINE DEF_PRIO)
   prgen_arbiter_mstr_MSTRS_SLVS
   prgen_arbiter_mstr_MSTRS_SLVS(
                                 .clk(clk),
                                 .reset(reset),
      
                                 .MMX_slave(MMX_slv),
                                 
                                 .SSX_master(SSX_mstr),
                                 
                                 .M_last({CONCAT(MMX_HLAST ,)}),
                                 .M_req({CONCAT(MMX_HTRANS[1] ,)}),
                                 .M_grant({CONCAT(MMX_HREADY ,)})
                                 );
   

   CREATE ahb_matrix_sel.v
   PREFIX_sel  
     PREFIX_sel (
		     .clk(clk),
		     .reset(reset),
		     .SSX_mstr(SSX_mstr),
		     .SSX_HREADY(SSX_HREADY),
		     .SSX_MMX(SSX_MMX),
		     .SSX_MMX_resp(SSX_MMX_resp),
                     STOMP ,
		     );

   
   CREATE ahb_matrix_bus.v
   PREFIX_bus  
     PREFIX_bus (
		     .clk(clk),
		     .reset(reset),
                     .MMX_GROUP_AHB(MMX_GROUP_AHB),
                     .SSX_GROUP_AHB(SSX_GROUP_AHB),
		     .SSX_MMX(SSX_MMX),
		     .SSX_MMX_resp(SSX_MMX_resp),
                     STOMP ,
		     );
   

   
  
endmodule





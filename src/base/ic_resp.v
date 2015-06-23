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

OUTFILE PREFIX_ic_resp.v

ITER MX
ITER SX

module PREFIX_ic_resp (PORTS);

   parameter 				  STRB_BITS  = DATA_BITS/8;
   
   input 				      clk;
   input 				      reset;
   
   port 				      MMX_AGROUP_IC_AXI_CMD;
   port 				      MMX_GROUP_IC_AXI_R;
   revport 				      SSX_GROUP_IC_AXI_R;
   
   
   parameter 				  RBUS_WIDTH = GONCAT(GROUP_IC_AXI_R.OUT.WIDTH +);
      
   wire 				      SSX_req;
   
   wire [RBUS_WIDTH-1:0] 	  SSX_RBUS;
   
   wire [RBUS_WIDTH-1:0] 	  MMX_RBUS;
   
   wire 				      SSX_MMX;

   wire [MSTR_BITS-1:0] 	  SSX_MSTR;
   wire 				      SSX_OK;
   
   wire [SLVS-1:0] 			  MMX_slave;


   


   CREATE ic_registry_resp.v def_ic.txt
   PREFIX_ic_registry_resp
     PREFIX_ic_registry_resp (
			      .clk(clk),
			      .reset(reset),
			      .MMX_ASLV(MMX_ASLV),
			      .MMX_AID(MMX_AID),
			      .MMX_AVALID(MMX_AVALID),
			      .MMX_AREADY(MMX_AREADY),
			      .SSX_ID(SSX_ID),
			      .SSX_VALID(SSX_VALID),
			      .SSX_READY(SSX_READY),
			      .SSX_LAST(SSX_LAST),
			      .SSX_MSTR(SSX_MSTR),
			      .SSX_OK(SSX_OK),
			      STOMP ,
			      );

   
   CREATE ic_arbiter.v def_ic.txt DEFCMD(SWAP MSTR_SLV slv) DEFCMD(SWAP MSTRNUM SLVS) DEFCMD(SWAP SLVNUM MSTRS) DEFCMD(DEFINE DEF_PRIO)
   PREFIX_ic_slv_arbiter
   PREFIX_ic_slv_arbiter(
			 .clk(clk),
			 .reset(reset),
			 
			 .MSX_slave(SSX_MSTR),
			 
			 .SMX_master(MMX_slave),
			 
			 .M_last({CONCAT(SSX_LAST ,)}),
			 .M_req({CONCAT(SSX_req ,)}),
			 .M_grant({CONCAT(SSX_READY ,)})
			 );

  
   assign 					 SSX_req = SSX_VALID & SSX_OK;
   
   assign 					 SSX_MMX = MMX_slave[SX];
      
   
   assign 					 SSX_RBUS   = {GONCAT(SSX_GROUP_IC_AXI_R.OUT ,)};

   assign 					 {GONCAT(MMX_GROUP_IC_AXI_R.OUT ,)} = MMX_RBUS;

   LOOP MX
     assign 					 MMX_RBUS = CONCAT((SSX_RBUS & {RBUS_WIDTH{SSX_MMX}}) |);
   
   ENDLOOP MX
      

   LOOP SX
       assign 					 SSX_READY = CONCAT((SSX_MMX & MMX_READY) |);
   
   ENDLOOP SX
   
endmodule


 

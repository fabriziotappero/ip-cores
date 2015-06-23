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

OUTFILE PREFIX_ic_addr.v

ITER MX
ITER SX

module PREFIX_ic_addr (PORTS);

   input 				      clk;
   input 				      reset;
   
   output [EXPR(SLV_BITS-1):0] 		      MMX_ASLV;
   port 				      MMX_AGROUP_IC_AXI_A;
   output [EXPR(MSTR_BITS-1):0] 	      SSX_AMSTR;
   output 				      SSX_AIDOK;
   revport 				      SSX_AGROUP_IC_AXI_A;
   
   
   parameter 				      MASTER_NONE = 0;
   parameter 				      MASTERMX    = 1 << MX;

   parameter 				      ABUS_WIDTH = GONCAT(GROUP_IC_AXI_A.IN.WIDTH +);

   
   wire [ABUS_WIDTH-1:0] 		      SSX_ABUS;
   
   wire [ABUS_WIDTH-1:0] 		      MMX_ABUS;
   
   wire 				      SSX_MMX;
   
   wire [EXPR(SLV_BITS-1):0] 		      MMX_ASLV;
   
   wire 				      MMX_AIDOK;
   
   wire [EXPR(MSTRS-1):0] 		      SSX_master;

   reg [EXPR(MSTR_BITS-1):0] 		      SSX_AMSTR;

   wire 				      SSX_AIDOK;

   wire [EXPR(ADDR_BITS-1):0]                 MMX_AADDR_valid;
   wire [EXPR(ID_BITS-1):0]                   MMX_AID_valid;


   
   assign                                     MMX_AADDR_valid = MMX_AADDR & {ADDR_BITS{MMX_AVALID}};
   assign                                     MMX_AID_valid   = MMX_AID & {ID_BITS{MMX_AVALID}};

   
   CREATE ic_dec.v def_ic.txt
   PREFIX_ic_dec
   PREFIX_ic_dec (
		  .MMX_AADDR(MMX_AADDR_valid),
		  .MMX_AID(MMX_AID_valid),
		  .MMX_ASLV(MMX_ASLV),
		  .MMX_AIDOK(MMX_AIDOK),
		  STOMP ,
		  );

   
   CREATE ic_arbiter.v def_ic.txt DEFCMD(SWAP MSTR_SLV mstr) DEFCMD(SWAP MSTRNUM MSTRS) DEFCMD(SWAP SLVNUM SLVS) DEFCMD(DEFINE DEF_PRIO)
   PREFIX_ic_mstr_arbiter
   PREFIX_ic_mstr_arbiter(
			  .clk(clk),
			  .reset(reset),
      
			  .MMX_slave(MMX_ASLV),
      
			  .SSX_master(SSX_master),
      
			  .M_last({MSTRS{1'b1}}),
			  .M_req({CONCAT(MMX_AVALID ,)}),
			  .M_grant({CONCAT(MMX_AREADY ,)})
			  );
   
   LOOP SX
     always @(/*AUTOSENSE*/SSX_master)         
       begin                                    
	  case (SSX_master)                    
	    MASTERMX : SSX_AMSTR = MX;         
	    default : SSX_AMSTR = MASTER_NONE; 
	  endcase                               
       end                                      
   ENDLOOP SX
      
     assign 		     SSX_MMX    = SSX_master[MX];
   
   assign 		     MMX_ABUS   = {GONCAT(MMX_AGROUP_IC_AXI_A.IN ,)};

   
   assign 		     {GONCAT(SSX_AGROUP_IC_AXI_A.IN ,)} = SSX_ABUS;
   
   
   LOOP SX
   assign 		     SSX_ABUS  = CONCAT((MMX_ABUS & {ABUS_WIDTH{SSX_MMX}}) |);              
   assign 		     SSX_AIDOK = CONCAT((SSX_MMX & MMX_AIDOK) |);                  
   ENDLOOP SX
   
   LOOP MX
       assign 		 MMX_AREADY = 
					  SSX_MMX ? SSX_AREADY :  
					  ~MMX_AVALID;            
   ENDLOOP MX
      
     endmodule




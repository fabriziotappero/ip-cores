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

OUTFILE PREFIX_ic_registry_resp.v

ITER MX
ITER SX   
  
module PREFIX_ic_registry_resp(PORTS);
   
   input 			    clk;
   input 			    reset;

   port 			    MMX_AGROUP_IC_AXI_CMD;
   
   input [ID_BITS-1:0]              SSX_ID;
   input 			    SSX_VALID; 
   input 			    SSX_READY; 
   input 			    SSX_LAST; 
   output [MSTR_BITS-1:0]           SSX_MSTR;
   output 			    SSX_OK;


   wire                             Amatch_MMX_IDGROUP_MMX_ID.IDX;
   
   wire 			    match_SSX_MMX_IDGROUP_MMX_ID.IDX;
   wire 			    no_Amatch_MMX;
   
   wire 			    cmd_push_MMX;
   wire 			    cmd_push_MMX_IDGROUP_MMX_ID.IDX;
   
   wire 			    cmd_pop_SSX;
   wire 			    cmd_pop_MMX_IDGROUP_MMX_ID.IDX;

   wire [SLV_BITS-1:0]              slave_in_MMX_IDGROUP_MMX_ID.IDX;
   wire [SLV_BITS-1:0]              slave_out_MMX_IDGROUP_MMX_ID.IDX;
   wire 			    slave_empty_MMX_IDGROUP_MMX_ID.IDX;
   wire 			    slave_full_MMX_IDGROUP_MMX_ID.IDX;

   reg [MSTR_BITS-1:0]              ERR_MSTR_reg;
   wire [MSTR_BITS-1:0]             ERR_MSTR;
   
   reg [MSTR_BITS-1:0]              SSX_MSTR;
   reg                              SSX_OK;

   
   
   
   assign 			    Amatch_MMX_IDGROUP_MMX_ID.IDX = MMX_AID == ID_BITS'bADD_IDGROUP_MMX_ID;
   
   assign 			    match_SSX_MMX_IDGROUP_MMX_ID.IDX = SSX_ID == ID_BITS'bADD_IDGROUP_MMX_ID;

		   
   assign 			    cmd_push_MMX           = MMX_AVALID & MMX_AREADY;
   assign 			    cmd_push_MMX_IDGROUP_MMX_ID.IDX = cmd_push_MMX & Amatch_MMX_IDGROUP_MMX_ID.IDX;
   assign 			    cmd_pop_SSX            = SSX_VALID & SSX_READY & SSX_LAST;
   
LOOP MX
  assign 			    cmd_pop_MMX_IDGROUP_MMX_ID.IDX = CONCAT((cmd_pop_SSX & match_SSX_MMX_IDGROUP_MMX_ID.IDX) |);
ENDLOOP MX
   	
  assign                           slave_in_MMX_IDGROUP_MMX_ID.IDX = MMX_ASLV;


IFDEF DEF_DECERR_SLV
     assign 			    no_Amatch_MMX         = GONCAT.REV((~Amatch_MMX_IDGROUP_MMX_ID.IDX) &);
   

   always @(posedge clk or posedge reset)
     if (reset)
       ERR_MSTR_reg <= #FFD {MSTR_BITS{1'b0}};
     else if (cmd_push_MMX & no_Amatch_MMX) ERR_MSTR_reg <= #FFD MSTR_BITS'dMX;
   
   assign 			    ERR_MSTR = ERR_MSTR_reg;
ELSE DEF_DECERR_SLV
   assign 			    ERR_MSTR = 'd0;
ENDIF DEF_DECERR_SLV

   
LOOP SX
   always @(*)                                               
     begin                                                                     
	case (SSX_ID)                                            
	  ID_BITS'bADD_IDGROUP_MMX_ID : SSX_MSTR = MSTR_BITS'dMX;
	  default : SSX_MSTR = ERR_MSTR;                                      
	endcase                                                                
     end                                                                       
   
   always @(*)                                                                  
     begin                                                                     
	case (SSX_ID)                                           
	  ID_BITS'bADD_IDGROUP_MMX_ID : SSX_OK = slave_out_MMX_IDGROUP_MMX_ID.IDX == SLV_BITS'dSX;
	  default : SSX_OK = 1'b1; //SLVERR                                   
	endcase                                                                
     end                                                                       
ENDLOOP SX

CREATE prgen_fifo.v DEFCMD(SWAP CONST(#FFD) #FFD)
LOOP MX
 LOOP IX GROUP_MMX_ID.NUM
   prgen_fifo #(SLV_BITS, CMD_DEPTH)
   slave_fifo_MMX_IDIX(
                       .clk(clk),                              
                       .reset(reset),                          
                       .push(cmd_push_MMX_IDIX),       
                       .pop(cmd_pop_MMX_IDIX),         
                       .din(slave_in_MMX_IDIX),        
                       .dout(slave_out_MMX_IDIX),      
		       .empty(slave_empty_MMX_IDIX),   
		       .full(slave_full_MMX_IDIX)      
                       );
   
   ENDLOOP IX
ENDLOOP MX
   

endmodule

   

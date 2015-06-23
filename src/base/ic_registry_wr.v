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

OUTFILE PREFIX_ic_registry_wr.v

ITER MX
ITER SX   

module PREFIX_ic_registry_wr(PORTS);
   

   
   input 			    clk;
   input 			    reset;

   port 			    MMX_AWGROUP_IC_AXI_CMD;
   
   input [ID_BITS-1:0]              MMX_WID;
   input 			    MMX_WVALID; 
   input 			    MMX_WREADY; 
   input 			    MMX_WLAST; 
   output [SLV_BITS-1:0]            MMX_WSLV;
   output 			    MMX_WOK;
   
   input 			    SSX_AWVALID;
   input 			    SSX_AWREADY;
   input [MSTR_BITS-1:0]            SSX_AWMSTR;
   input 			    SSX_WVALID;
   input 			    SSX_WREADY;
   input 			    SSX_WLAST;
   
   
   wire 			    AWmatch_MMX_IDGROUP_MMX_ID.IDX;
   wire 			    Wmatch_MMX_IDGROUP_MMX_ID.IDX;

   wire 			    cmd_push_MMX;
   wire 			    cmd_push_MMX_IDGROUP_MMX_ID.IDX;
   
   wire 			    cmd_pop_MMX;
   wire 			    cmd_pop_MMX_IDGROUP_MMX_ID.IDX;

   wire                             slave_empty_MMX;
   wire [SLV_BITS-1:0]              slave_in_MMX_IDGROUP_MMX_ID.IDX;
   wire [SLV_BITS-1:0]              slave_out_MMX_IDGROUP_MMX_ID.IDX;
   wire 			    slave_empty_MMX_IDGROUP_MMX_ID.IDX;
   wire 			    slave_full_MMX_IDGROUP_MMX_ID.IDX;

   wire 			    cmd_push_SSX;
   wire 			    cmd_pop_SSX;
   wire [MSTR_BITS-1:0]             master_in_SSX;
   wire [MSTR_BITS-1:0]             master_out_SSX;
   wire 			    master_empty_SSX;
   wire 			    master_full_SSX;
   
   reg [SLV_BITS-1:0]               MMX_WSLV;
   reg 				    MMX_WOK;

   reg                              MMX_pending;
   reg                              MMX_pending_d;
   wire                             MMX_pending_rise;
   reg                              SSX_pending;
   reg                              SSX_pending_d;
   wire                             SSX_pending_rise;
   
   
   
   assign                           AWmatch_MMX_IDGROUP_MMX_ID.IDX  = MMX_AWID == ID_BITS'bADD_IDGROUP_MMX_ID;
      
   assign 			    Wmatch_MMX_IDGROUP_MMX_ID.IDX   = MMX_WID == ID_BITS'bADD_IDGROUP_MMX_ID;
		   
		   
   assign 			    cmd_push_MMX           = MMX_AWVALID & (MMX_pending ? MMX_pending_rise : MMX_AWREADY);
   assign 			    cmd_push_MMX_IDGROUP_MMX_ID.IDX = cmd_push_MMX & AWmatch_MMX_IDGROUP_MMX_ID.IDX;
   assign 			    cmd_pop_MMX            = MMX_WVALID & MMX_WREADY & MMX_WLAST;
   assign  			    cmd_pop_MMX_IDGROUP_MMX_ID.IDX  = cmd_pop_MMX & Wmatch_MMX_IDGROUP_MMX_ID.IDX;

   assign 			    cmd_push_SSX           = SSX_AWVALID & (SSX_pending ? SSX_pending_rise : SSX_AWREADY);
   assign 			    cmd_pop_SSX            = SSX_WVALID & SSX_WREADY & SSX_WLAST;
   assign 			    master_in_SSX          = SSX_AWMSTR;
   
   assign 			    slave_in_MMX_IDGROUP_MMX_ID.IDX = MMX_AWSLV;


   assign                           MMX_pending_rise = MMX_pending & (~MMX_pending_d);
   assign                           SSX_pending_rise = SSX_pending & (~SSX_pending_d);
   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
          MMX_pending   <= #FFD 1'b0;
          MMX_pending_d <= #FFD 1'b0;
          SSX_pending   <= #FFD 1'b0;
          SSX_pending_d <= #FFD 1'b0;
       end
     else
       begin
          MMX_pending   <= #FFD MMX_AWVALID & (~MMX_AWREADY);
          MMX_pending_d <= #FFD MMX_pending;
          SSX_pending   <= #FFD SSX_AWVALID & (~SSX_AWREADY);
          SSX_pending_d <= #FFD SSX_pending;
       end
   
   
   
   LOOP MX
   always @(*)                                                              
     begin                                                                 
	case (MMX_WID)                                            
	  ID_BITS'bADD_IDGROUP_MMX_ID : MMX_WSLV = slave_out_MMX_IDGROUP_MMX_ID.IDX;
	  default : MMX_WSLV = SERR;                           
	endcase                                                            
     end   

   always @(*)                                                              
     begin                                                                 
	case (MMX_WSLV)                                                   
	  SLV_BITS'dSX : MMX_WOK = (master_out_SSX == MSTR_BITS'dMX) & (~slave_empty_MMX);
	  default : MMX_WOK = 1'b0;                                       
	endcase                                                            
     end                                                                   

   ENDLOOP MX
      
LOOP MX
  assign slave_empty_MMX = GONCAT(slave_empty_MMX_IDGROUP_MMX_ID.IDX &);
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

	
   
LOOP SX
   prgen_fifo #(MSTR_BITS, SLV_DEPTH)
   master_fifo_SSX(                                            
		   .clk(clk),                                   
		   .reset(reset),                               
		   .push(cmd_push_SSX),                        
		   .pop(cmd_pop_SSX),                          
		   .din(master_in_SSX),                        
		   .dout(master_out_SSX),                      
		   .empty(master_empty_SSX),                   
		   .full(master_full_SSX)                      
		   );                                           

ENDLOOP SX
   
endmodule

   

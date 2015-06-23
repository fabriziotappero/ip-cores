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

OUTFILE PREFIX_ic_MSTR_SLV_arbiter.v

ITER MX MSTRNUM
ITER SX SLVNUM
  
module PREFIX_ic_MSTR_SLV_arbiter(PORTS);

   input 			      clk;
   input 			      reset;

   input [MSTRNUM-1:0] 	      M_last;
   input [MSTRNUM-1:0] 	      M_req;
   input [MSTRNUM-1:0] 	      M_grant;
   
   input [LOG2(SLVNUM)-1:0] 	      MMX_slave;
   
   output [MSTRNUM-1:0] 	      SSX_master;


   
   reg [MSTRNUM:0] 		      SSX_master_prio_reg;
   wire [MSTRNUM-1:0] 		      SSX_master_prio;
   reg [MSTRNUM-1:0] 		      SSX_master_d;
   
   wire [MSTRNUM-1:0] 		      M_SSX;
   wire [MSTRNUM-1:0] 		      M_SSX_valid;
   wire [MSTRNUM-1:0] 		      M_SSX_prio;
   reg [MSTRNUM-1:0] 		      M_SSX_burst;


   
   
   parameter 			      MASTER_NONE = BIN(0 MSTRNUM);
   parameter 			      MASTERMX    = BIN(EXPR(2^MX) MSTRNUM);
   
   
   

IFDEF DEF_PRIO
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  SSX_master_prio_reg[MSTRNUM:1] <= #FFD {MSTRNUM{1'b0}};
	  SSX_master_prio_reg[0]          <= #FFD 1'b1;
       end
     else if (|(M_req & M_grant & M_last))
       begin	  
	  SSX_master_prio_reg[MSTRNUM:1] <= #FFD SSX_master_prio_reg[MSTRNUM-1:0];
	  SSX_master_prio_reg[0]          <= #FFD SSX_master_prio_reg[MSTRNUM-1];
       end

   assign SSX_master_prio = SSX_master_prio_reg[MSTRNUM-1:0];
   
   assign M_SSX_prio      = M_SSX_valid & SSX_master_prio;
ENDIF DEF_PRIO
   


   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  SSX_master_d <= #FFD {MSTRNUM{1'b0}};
       end
     else
       begin
	  SSX_master_d <= #FFD SSX_master;
       end

   LOOP MX MSTRNUM
     always @(posedge clk or posedge reset)                        
       if (reset)                                                  
	 begin                                                     
	    M_SSX_burst[MX] <= #FFD 1'b0;                        
	 end                                                       
       else if (M_req[MX])                         
	 begin                                                     
	    M_SSX_burst[MX] <= #FFD SSX_master[MX] & (M_grant[MX] ? (~M_last[MX]) : 1'b1); 
	 end
   
   ENDLOOP MX
      
     assign                              M_SSX = {CONCAT(MMX_slave == 'dSX ,)};
   
   assign 				 M_SSX_valid = M_SSX & M_req;
   
   
   LOOP SX SLVNUM
     assign 			       SSX_master = 
   						    M_SSX_burst[MX] ? SSX_master_d : 
	                               IF DEF_PRIO 	    M_SSX_prio[MX]  ? MASTERMX : 
						    M_SSX_valid[MX] ? MASTERMX :      
						    MASTER_NONE;
   
   ENDLOOP SX
      
     endmodule


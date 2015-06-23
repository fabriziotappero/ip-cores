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

OUTFILE PREFIX_regfile.v
INCLUDE def_regfile.txt

ITER RX GROUP_REGS.NUM

module PREFIX_regfile (PORTS);

   parameter            ADDR_BITS = 16;

   input                clk;
   input                reset;
   port                 GROUP_APB;
     
  
   input                GROUP_REGRX.SON(TYPE == TYPE_RO);
   output               GROUP_REGRX.SON(TYPE == TYPE_RW);
   output               wr_GROUP_REGRX.SON(TYPE == TYPE_WO);
   output               GROUP_REGRX.SON(TYPE == TYPE_IW);
   
   
   wire                 gpwrite;
   wire                 gpread;
   reg [31:0]           prdata_pre;
   reg                  pslverr_pre;
   reg [31:0]           prdata;
   reg                  pslverr;
   reg                  pready;
   
   wire                 
   STOMP NEWLINE ;;     GONCAT(wr_regGROUP_REGS.SON(TYPE != TYPE_RO).IDX ,);
   reg [31:0]           
   STOMP NEWLINE ;;     GONCAT(rd_regGROUP_REGS.SON(TYPE != TYPE_WO).IDX ,);
   
   reg                  GROUP_REGRX.SON(TYPE == TYPE_IW);
   reg                  GROUP_REGRX.SON(TYPE == TYPE_RW);
   
   wire                 wr_GROUP_REGRX.SON(TYPE == TYPE_WO);
   wire                 wr_GROUP_REGRX.SON(TYPE == TYPE_IW);
   
   
   //---------------------- addresses-----------------------------------
   parameter            GROUP_REGS = 'hGROUP_REGS.ADDR;     //GROUP_REGS.DESC
   
   //---------------------- gating -------------------------------------
   assign               gpwrite     = psel & (~penable) & pwrite;
   assign               gpread      = psel & (~penable) & (~pwrite);
   
   
   //---------------------- Write Operations ---------------------------
   assign            wr_regGROUP_REGS.SON(TYPE != TYPE_RO).IDX = gpwrite & (paddr == GROUP_REGS);

   LOOP RX GROUP_REGS.NUM
   IFDEF TRUE(GROUP_REGS[RX].TYPE == TYPE_RW)
   //GROUP_REGS[RX].DESC
   always @(posedge clk or posedge reset)
     if (reset)
	   begin
	     GROUP_REGRX.SON(TYPE==TYPE_RW) <= #FFD GROUP_REGRX.WIDTH'dGROUP_REGRX.DEFAULT;     //GROUP_REGRX.DESC
	   end
     else if (wr_regRX)
	   begin
	     GROUP_REGRX.SON(TYPE==TYPE_RW) <= #FFD pwdata[EXPR(GROUP_REGRX.WIDTH+GROUP_REGRX.FIRST_BIT-1):GROUP_REGRX.FIRST_BIT];
	   end
	   
   ENDIF TRUE(GROUP_REGS[RX].TYPE == TYPE_RW)
	assign  wr_GROUP_REGRX.SON(TYPE==TYPE_WO) = {GROUP_REGRX.WIDTH{wr_regRX}} & pwdata[EXPR(GROUP_REGRX.WIDTH-1):0];
	assign  wr_GROUP_REGRX.SON(TYPE==TYPE_IW) = {GROUP_REGRX.WIDTH{wr_regRX}} & pwdata[EXPR(GROUP_REGRX.WIDTH-1):0];
    ENDLOOP RX
	      
	//---------------------- Read Operations ----------------------------
     always @(*)
     begin
	   rd_regGROUP_REGS.SON(TYPE != TYPE_WO).IDX  = {32{1'b0}};
	   
	   rd_regRX[EXPR(GROUP_REGRX.WIDTH+GROUP_REGRX.FIRST_BIT-1):GROUP_REGRX.FIRST_BIT] = GROUP_REGRX.SON(TYPE != TYPE_WO);     //GROUP_REGRX.DESC
     end
   
   always @(*)
     begin
	  prdata_pre  = {32{1'b0}};
	  
	  case (paddr)
	   GROUP_REGS : prdata_pre = rd_regGROUP_REGS.SON(TYPE != TYPE_WO).IDX;
	  
	   default : prdata_pre  = {32{1'b0}};
	  endcase
     end

   
 always @(paddr or gpread or gpwrite or psel)
     begin
	  pslverr_pre = 1'b0;
	  
	  case (paddr)
	    GROUP_REGS.SON(TYPE==TYPE_RW) : pslverr_pre = 1'b0; //read and write
	    GROUP_REGS.SON(TYPE==TYPE_RO) : pslverr_pre = gpwrite; //read only
	    GROUP_REGS.SON(TYPE==TYPE_WO) : pslverr_pre = gpread; //write only

	   default : pslverr_pre = psel;    //decode error
	  endcase
     end

	 
	//---------------------- Sample outputs -----------------------------
   always @(posedge clk or posedge reset)
     if (reset)
       prdata <= #FFD {32{1'b0}};
     else if (gpread & pclken)
       prdata <= #FFD prdata_pre;
     else if (pclken)
       prdata <= #FFD {32{1'b0}};
   
   always @(posedge clk or posedge reset)
     if (reset)
	  begin
       pslverr <= #FFD 1'b0;
       pready <= #FFD 1'b0;
	  end
     else if ((gpread | gpwrite) & pclken)
	  begin
       pslverr <= #FFD pslverr_pre;
       pready <= #FFD 1'b1;
	  end
     else if (pclken)
	  begin
       pslverr <= #FFD 1'b0;
       pready <= #FFD 1'b0;
	  end

   
endmodule



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

OUTFILE PREFIX_ram.v

INCLUDE def_ahb_slave.txt
  
CHECK CONST(#FFD)
CHECK CONST(PREFIX)
CHECK CONST(ADDR_BITS)
CHECK CONST(DATA_BITS)
  
module PREFIX_ram(PORTS);
   
   input 		      clk;
   input 		      reset;
   
   revport                    GROUP_STUB_AHB;

   port                       GROUP_STUB_MEM;

   
CREATE prgen_rand.v DEFCMD(DEFINE NOT_IN_LIST)
`include "prgen_rand.v"

   
   //---------------- config parameters ------------------------
   reg                        stall_enable  = 1;  //enable stall on HREADY
   integer 		      burst_chance  = 1;  //chance for burst on HREADY stall
   integer 		      burst_len     = 10; //length of stall burst in cycles
   integer 		      burst_val     = 90; //chance for stall during burst
   integer 		      stall_chance  = 10; //chance for stall

   reg [ADDR_BITS-1:0] 	      HRESP_addr = {ADDR_BITS{1'b1}};   //address for response error
   reg [ADDR_BITS-1:0] 	      TIMEOUT_addr = {ADDR_BITS{1'b1}}; //address for timeout response (no HREADY)
   //-----------------------------------------------------------

   
   integer                    burst_stall;
   integer 		      stall_chance_valid;
   
   reg 			      HRESP;
   reg 			      timeout_stall;
   
   reg [1:0] 		      HSIZE_d;
   wire 		      WR_pre;
   reg                        WR_pre_d;
   wire                       WR;
   wire [ADDR_BITS-1:0]       ADDR_WR_pre;
   reg [ADDR_BITS-1:0] 	      ADDR_WR;
   reg 			      data_phase;
   
   wire [7:0] 		      BSEL_wide;
   
   reg 			      STALL_pre;
   reg 			      STALL;
   
   
   parameter 		      TRANS_IDLE   = 2'b00;
   parameter 		      TRANS_STALL   = 2'b01;
   parameter 		      TRANS_NONSEQ = 2'b10;
   parameter 		      TRANS_SEQ    = 2'b11;


   task set_stall;
      begin
    	 stall_chance_valid = stall_chance;
      end
   endtask

   initial
     begin
	#FFD;
	set_stall;

	if (burst_chance > 0)
	  forever
	    begin
	       burst_stall = rand_chance(burst_chance);

	       if (burst_stall)
		 begin   
                    #FFD;
		    stall_chance_valid = burst_val;
		    repeat (burst_len) @(posedge clk);
		    set_stall;
		 end
	       else
		 begin
		    @(posedge clk);
		 end
	    end
     end

   
   always @(posedge clk)
       begin
	  #FFD;
    	  STALL_pre = rand_chance(stall_chance_valid);
       end
	  
   
   always @(posedge clk or posedge reset)
     if (reset)
       STALL <= #FFD 1'b0;
     else if (stall_enable)
       STALL <= #FFD STALL_pre;
     else 
       STALL <= #FFD 1'b0;
   
   always @(posedge clk or posedge reset)
     if (reset)
       timeout_stall <= #FFD 1'b0;
     else if ((|HTRANS) & (TIMEOUT_addr == HADDR))
       timeout_stall <= #FFD 1'b1;
     else if (TIMEOUT_addr == 0)
       timeout_stall <= #FFD 1'b0;
   
   always @(posedge clk or posedge reset)
     if (reset)
       HRESP <= #FFD 1'b0;
     else if ((|HTRANS) & (HRESP_addr == HADDR))
       HRESP <= #FFD 1'b1;
     else if (HREADY)
       HRESP <= #FFD 1'b0;
   
   always @(posedge clk or posedge reset)
     if (reset)
       data_phase <= #FFD 1'b0;
     else if (RD)
       data_phase <= #FFD 1'b1;
     else if (HREADY)
       data_phase <= #FFD 1'b0;
   
   assign 		      HRDATA = HREADY & data_phase ? DOUT : 'd0;
   assign 		      HREADY = HTRANS == TRANS_STALL ? 1'b0 : (~timeout_stall) & (~STALL);

   
   assign 		      WR_pre      = HWRITE & ((HTRANS == TRANS_NONSEQ) | (HTRANS == TRANS_SEQ));
   assign                     WR          = WR_pre_d & HREADY;
   assign 		      RD          = (~HWRITE) & ((HTRANS == TRANS_NONSEQ) | (HTRANS == TRANS_SEQ)) & HREADY;
   assign 		      ADDR_WR_pre = {ADDR_BITS{WR_pre}} & HADDR;
   assign 		      ADDR_RD     = {ADDR_BITS{RD}} & HADDR;
   assign 		      DIN         = HWDATA;

   IFDEF TRUE(DATA_BITS==32)
   assign                     BSEL        = ADDR_WR[2] ? BSEL_wide[7:4] : BSEL_wide[3:0];
   ELSE TRUE(DATA_BITS==32)
   assign                     BSEL        = BSEL_wide;
   ENDIF TRUE(DATA_BITS==32)
			      		  
   assign 		      BSEL_wide    = 
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd0) ? 8'b0000_0001 :
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd1) ? 8'b0000_0010 :
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd2) ? 8'b0000_0100 :
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd3) ? 8'b0000_1000 :
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd4) ? 8'b0001_0000 :
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd5) ? 8'b0010_0000 :
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd6) ? 8'b0100_0000 :
			      (HSIZE_d == 2'b00) & (ADDR_WR[2:0] == 3'd7) ? 8'b1000_0000 :

			      (HSIZE_d == 2'b01) & (ADDR_WR[2:1] == 2'd0) ? 8'b0000_0011 :
			      (HSIZE_d == 2'b01) & (ADDR_WR[2:1] == 2'd1) ? 8'b0000_1100 :
			      (HSIZE_d == 2'b01) & (ADDR_WR[2:1] == 2'd2) ? 8'b0011_0000 :
			      (HSIZE_d == 2'b01) & (ADDR_WR[2:1] == 2'd3) ? 8'b1100_0000 :
			      
			      (HSIZE_d == 2'b10) & (ADDR_WR[2] == 1'd0)   ? 8'b0000_1111 :
			      (HSIZE_d == 2'b10) & (ADDR_WR[2] == 1'd1)   ? 8'b1111_0000 :

			      8'b1111_1111;
   
			   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
	  WR_pre_d <= #FFD 1'b0;
	  ADDR_WR <= #FFD {ADDR_BITS{1'b0}};
	  HSIZE_d <= #FFD 2'b0;
       end
     else if (HREADY)
       begin
	  WR_pre_d <= #FFD WR_pre;
	  ADDR_WR <= #FFD ADDR_WR_pre;
	  HSIZE_d <= #FFD HSIZE;
       end
       
      
endmodule





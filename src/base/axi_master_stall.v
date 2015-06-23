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

OUTFILE PREFIX_stall.v

INCLUDE def_axi_master.txt
  
module PREFIX_stall(PORTS);
   
`include "prgen_rand.v"
   
   input 		      clk;
   input 		      reset;

   input 		      rd_hold;
   input 		      wr_hold;
   
   input 		      ARVALID_pre;
   input 		      RREADY_pre;
   input 		      AWVALID_pre;
   input 		      WVALID_pre;
   input 		      BREADY_pre;

   input 		      ARREADY;
   input 		      AWREADY;
   input 		      WREADY;
   
   output 		      ARVALID;
   output 		      RREADY;
   output 		      AWVALID;
   output 		      WVALID;
   output 		      BREADY;


   reg                        stall_enable = 1;
   
   integer                    burst_chance    = 1;
   integer 		      burst_len       = 10;
   integer 		      burst_val       = 90;
   
   integer 		      ar_stall_chance = 10;
   integer 		      r_stall_chance  = 10;
   integer 		      aw_stall_chance = 10;
   integer 		      w_stall_chance  = 10;
   integer 		      b_stall_chance  = 10;

   
   integer 		      burst_type;
   reg 			      burst_stall;
   integer 		      ar_stall_chance_valid;
   integer 		      r_stall_chance_valid;
   integer 		      aw_stall_chance_valid;
   integer 		      w_stall_chance_valid;
   integer 		      b_stall_chance_valid;
   
   
   reg 			      ARSTALL_pre = 0;
   reg 			      RSTALL_pre  = 0;
   reg 			      AWSTALL_pre = 0;
   reg 			      WSTALL_pre  = 0;
   reg 			      BSTALL_pre  = 0;
   reg 			      ARSTALL;
   reg 			      RSTALL;
   reg 			      AWSTALL;
   reg 			      WSTALL;
   reg 			      BSTALL;

   

   assign 		      ARVALID = ARVALID_pre & (~ARSTALL) & (~rd_hold);
   assign 		      RREADY  = RREADY_pre  & (~RSTALL);
   assign 		      AWVALID = AWVALID_pre & (~AWSTALL) & (~wr_hold);
   assign 		      WVALID  = WVALID_pre  & (~WSTALL);
   assign 		      BREADY  = BREADY_pre  & (~BSTALL);


   task set_stall;
      reg stall;
      begin
    	 ar_stall_chance_valid = ar_stall_chance;
    	 r_stall_chance_valid  = r_stall_chance;
    	 aw_stall_chance_valid = aw_stall_chance;
    	 w_stall_chance_valid  = w_stall_chance;
    	 b_stall_chance_valid  = b_stall_chance;
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
		    burst_type = rand(1, 5);
		    
		    case (burst_type)
		      1 : ar_stall_chance_valid = burst_val;
		      2 : r_stall_chance_valid  = burst_val;
		      3 : aw_stall_chance_valid = burst_val;
		      4 : w_stall_chance_valid  = burst_val;
		      5 : b_stall_chance_valid  = burst_val;
		    endcase
		    
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
	ARSTALL_pre = rand_chance(ar_stall_chance_valid);
    	RSTALL_pre  = rand_chance(r_stall_chance_valid);
    	AWSTALL_pre = rand_chance(aw_stall_chance_valid);
    	WSTALL_pre  = rand_chance(w_stall_chance_valid);
    	BSTALL_pre  = rand_chance(b_stall_chance_valid);
     end
   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
    	  ARSTALL <= #FFD 1'b0;
    	  RSTALL  <= #FFD 1'b0;
    	  AWSTALL <= #FFD 1'b0;
    	  WSTALL  <= #FFD 1'b0;
    	  BSTALL  <= #FFD 1'b0;
       end
     else if (stall_enable)
       begin
    	  ARSTALL <= #FFD ARSTALL_pre & ARREADY; //keep VALID signal stable while ~READY
    	  RSTALL  <= #FFD RSTALL_pre;
    	  AWSTALL <= #FFD AWSTALL_pre & AWREADY; //keep VALID signal stable while ~READY
    	  WSTALL  <= #FFD WSTALL_pre & WREADY; //keep VALID signal stable while ~READY
    	  BSTALL  <= #FFD BSTALL_pre;
       end
     else
       begin
    	  ARSTALL <= #FFD 1'b0;
    	  RSTALL  <= #FFD 1'b0;
    	  AWSTALL <= #FFD 1'b0;
    	  WSTALL  <= #FFD 1'b0;
    	  BSTALL  <= #FFD 1'b0;
       end
   
endmodule
   








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

OUTFILE PREFIX_busy.v

INCLUDE def_axi_slave.txt
  
module PREFIX_busy(PORTS);
   
CREATE prgen_rand.v DEFCMD(DEFINE NOT_IN_LIST)
`include "prgen_rand.v"
   
   input 		      clk;
   input 		      reset;
   
   output 		      ARBUSY;
   output 		      RBUSY;
   output 		      AWBUSY;
   output 		      WBUSY;
   output 		      BBUSY;


   reg                        stall_enable    = 1;
      
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
   
   
   reg 			      ARBUSY_pre = 0;
   reg 			      RBUSY_pre = 0;
   reg 			      AWBUSY_pre = 0;
   reg 			      WBUSY_pre = 0;
   reg 			      BBUSY_pre = 0;
   reg 			      ARBUSY;
   reg 			      RBUSY;
   reg 			      AWBUSY;
   reg 			      WBUSY;
   reg 			      BBUSY;


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
	ARBUSY_pre = rand_chance(ar_stall_chance_valid);
    	RBUSY_pre  = rand_chance(r_stall_chance_valid);
    	AWBUSY_pre = rand_chance(aw_stall_chance_valid);
    	WBUSY_pre  = rand_chance(w_stall_chance_valid);
    	BBUSY_pre  = rand_chance(b_stall_chance_valid);
     end
   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
    	  ARBUSY <= #FFD 1'b0;
    	  RBUSY  <= #FFD 1'b0;
    	  AWBUSY <= #FFD 1'b0;
    	  WBUSY  <= #FFD 1'b0;
    	  BBUSY  <= #FFD 1'b0;
       end
     else if (stall_enable)
       begin
    	  ARBUSY <= #FFD ARBUSY_pre;
    	  RBUSY  <= #FFD RBUSY_pre;
    	  AWBUSY <= #FFD AWBUSY_pre;
    	  WBUSY  <= #FFD WBUSY_pre;
    	  BBUSY  <= #FFD BBUSY_pre;
       end
     else
       begin
    	  ARBUSY <= #FFD 1'b0;
    	  RBUSY  <= #FFD 1'b0;
    	  AWBUSY <= #FFD 1'b0;
    	  WBUSY  <= #FFD 1'b0;
    	  BBUSY  <= #FFD 1'b0;
       end
   
endmodule
   








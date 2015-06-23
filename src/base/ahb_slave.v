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

INCLUDE def_ahb_slave.txt
  
module PREFIX(PORTS);
   
   parameter                  SLAVE_NUM = 0;
   
   input 		      clk;
   input 		      reset;
   
   revport                    GROUP_STUB_AHB;


   
   wire                       GROUP_STUB_MEM;
   

   
   CREATE ahb_slave_ram.v
     PREFIX_ram PREFIX_ram(
			   .clk(clk),
			   .reset(reset),
                           .GROUP_STUB_AHB(GROUP_STUB_AHB),
                           .GROUP_STUB_MEM(GROUP_STUB_MEM),
                           STOMP ,
                           );
   
   
   CREATE ahb_slave_mem.v
   PREFIX_mem PREFIX_mem(
			 .clk(clk),
			 .reset(reset),
                         .GROUP_STUB_MEM(GROUP_STUB_MEM),
                         STOMP ,
			 );


   
   IFDEF TRACE
     CREATE ahb_slave_trace.v
       PREFIX_trace #(SLAVE_NUM)
         PREFIX_trace(
			         .clk(clk),
			         .reset(reset),
                                 .GROUP_STUB_MEM(GROUP_STUB_MEM),
                                 STOMP ,
			         );
     
   ENDIF TRACE
   
endmodule



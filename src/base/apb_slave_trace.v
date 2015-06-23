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

OUTFILE PREFIX_trace.v

INCLUDE def_apb_slave.txt
  
module PREFIX_trace(PORTS);
      
   parameter                  SLAVE_NUM = 0;
   
   parameter 		      FILE_NAME     = "PREFIX.trc";
   
   input 		      clk;
   input 		      reset;

   input                      GROUP_STUB_MEM;
   

   reg                        RD_d;
   reg [ADDR_BITS-1:0] 	      ADDR_RD_d;

   wire [31:0] 		      ADDR_WR_disp =  ADDR_WR;	
   wire [31:0] 		      ADDR_RD_disp =  ADDR_RD_d;
   
   integer                    file_ptr;
   
   initial
     file_ptr = $fopen(FILE_NAME, "w");

   
   always @(posedge clk or posedge reset)
     if (reset)
       begin
          ADDR_RD_d <= #FFD 'd0;
          RD_d <= #FFD 'd0;
       end
     else
       begin
          ADDR_RD_d <= #FFD ADDR_RD;
          RD_d <= #FFD RD;
       end
   
   always @(posedge clk)
     if (WR)
       $fwrite(file_ptr, "%16d: %0s WR: Addr: 0x%8h, Data: 0x%8h, Bsel: 0x%2h\n", $time, FILE_NAME, ADDR_WR_disp, DIN, BSEL);
	
   always @(posedge clk)
     if (RD_d)
       $fwrite(file_ptr, "%16d: %0s RD: Addr: 0x%8h, Data: 0x%8h\n", $time, FILE_NAME, ADDR_RD_disp, DOUT);

      
endmodule

   

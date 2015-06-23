//////////////////////////////////////////////////////////////////////
////                                                              ////
////  OR1200's simulation monitor                                 ////
////                                                              ////
////  This file is part of the OpenRISC 1200 project              ////
////  http://www.opencores.org/cores/or1k/                        ////
////                                                              ////
////  Description                                                 ////
////  wishbone protocal  monitor                                  ////
////                                                              ////
////  To Do:                                                      ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module model_monitor
#(parameter TEST_NAME="unspecified",
  parameter INSTANCE="none",
  parameter ADD_WIDTH=32,
  parameter DATA_WIDTH=32
)
(
input wire                   clk,
input wire                   reset,
input wire [ADD_WIDTH-1:0]   wb_adr,
input wire                   wb_ack,
input wire                   wb_err,
input wire                   wb_cyc,
input wire                   wb_stb,
input wire                   wb_we,
input wire [DATA_WIDTH-1:0]  wb_read,
input wire [DATA_WIDTH-1:0]  wb_write,
input wire [3:0]             wb_sel
);
integer    fgeneral;
   //
   // Initialization
   //
   initial 
      begin
      fgeneral = $fopen({TEST_NAME,"_",INSTANCE,"_wishbone.log"});
      end
   always @(posedge clk)
     begin
     if (wb_stb && wb_cyc && wb_ack) 
           begin
	   $fdisplay(fgeneral, "%t  %m WB access  %x %x  %x  %x  %x",  $realtime,   wb_adr, wb_we, wb_sel, wb_read, wb_write,  );
	   end
     end
   integer wb_progress;
   reg [ADD_WIDTH-1:0] wb_progress_addr;
   //
   // WISHBONE bus checker
   //
   always @(posedge clk)
     if (reset) 
        begin
	wb_progress = 0;
	wb_progress_addr = wb_adr;
        end
     else 
       begin	  
	if (wb_cyc && (wb_progress != 2)) 
           begin
	   wb_progress = 1;
	   end
	if (wb_stb) 
           begin
	   if (wb_progress >= 1) 
              begin
	      if (wb_progress == 1)	 wb_progress_addr = wb_adr; 
	      wb_progress = 2;
	      end
	   else 
              begin
	      $fdisplay(fgeneral, "%t  %m WISHBONE protocol violation: wb_stb_i raised without wb_cyc_i", $realtime);
	      end
	   end
	if (wb_ack & wb_err) 
           begin
	   $fdisplay(fgeneral, "%t  %m WISHBONE protocol violation: wb_ack_i and wb_err_i raised at the same time", $realtime);
	   end
	if ((wb_progress == 2) && (wb_progress_addr != wb_adr)) 
           begin
	   $fdisplay(fgeneral, "%t  %m WISHBONE protocol violation: wb_adr changed while waiting for wb_err_i/wb_ack_i", $realtime);
	   end
	if (wb_ack | wb_err)
	   if (wb_progress == 2) 
               begin
	       wb_progress = 0;
	       wb_progress_addr = wb_adr;
	       end
	   else 
             begin
	     $fdisplay(fgeneral, "%t  %m WISHBONE protocol violation: wb_ack_i/wb_err_i raised without wb_cyc_i/wb_stb_i", $realtime);
	     end
	if ((wb_progress == 2) && !wb_stb) 
           begin
	   $fdisplay(fgeneral, "%t  %m WISHBONE protocol violation: wb_stb lowered without wb_err_i/wb_ack_i", $realtime);
      	   end
        end
endmodule

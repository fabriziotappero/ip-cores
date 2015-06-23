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

//////////////////////////////////////
//
// General:
//   The APB slave can use APB or APB3 protocol (APB3 is with pslverr and pready)
//   APB3 is set by DEFINE in def_apb_slave.txt
//   All following tasks regard APB3 only.
//
//
// Tasks:
//
// set_random_delay(input min_delay, input max_delay)
//   Description: Set random wait states on pready
//   Parameters: min_delay - minimum delay
//               max_delay = maximum delay
//
// set_fixed_delay(input delay)
//   Description: Set fixed wait states on pready
//   Parameters: delay - fixed delay on pready
//
// set_slverr(input address)
//   Description: Set address to return slave error (pslverr)
//   Parameters: address - address will return pslverr
// 
// 
//////////////////////////////////////

  
OUTFILE PREFIX.v

INCLUDE def_apb_slave.txt
  
module PREFIX(PORTS);

CREATE prgen_rand.v DEFCMD(DEFINE NOT_IN_LIST)
`include "prgen_rand.v"

   parameter                  SLAVE_NUM = 0;
   
   input 		      clk;
   input 		      reset;
   
   revport                    GROUP_STUB_APB;


   
   wire                       GROUP_STUB_MEM;

IFDEF APB3
  reg                busy_rand_enable = 0; //enable random busy
  integer            busy_min         = 0; //min busy cycles
  integer            busy_max         = 5; //max busy cycles
   integer           busy_delay       = 1; //fixed delay for pready
   
   reg               err_enable = 0;
   reg [ADDR_BITS-1:0] err_addr = {ADDR_BITS{1'b1}}; //error address

   
   wire               pslverr   = err_enable && (paddr == err_addr);
   reg                pready = 1'b1;
   
   always @(negedge clk)
     begin
        #FFD;
        if (psel)
          begin
             if (busy_rand_enable)
               begin
                  busy_delay = rand(busy_min, busy_max);
               end
             if (busy_delay > 0)
               begin
                  pready = 1'b0;
                  repeat (busy_delay)
                    begin
                       @(posedge clk); #FFD;
                    end
                  pready = 1'b1;
                  @(posedge clk); #FFD;
               end
          end
     end


   task set_random_delay;
      input [31:0] delay_min;
      input [31:0] delay_max;
      begin
         busy_rand_enable = 1;
         busy_min = delay_min;
         busy_max = delay_max;
      end
   endtask

   task set_fixed_delay;
      input [31:0] delay;
      begin
         busy_rand_enable = 0;
         busy_delay = delay;
      end
   endtask

   task set_slverr;
      input [31:0] addr;
      begin
         err_enable = 1;
         err_addr = addr;
      end
   endtask


   
ELSE APB3
   wire  pready  = 1'b1;
   wire  pslverr = 1'b0;
ENDIF APB3


  
   assign WR      = psel & penable & pwrite;
   assign RD      = psel & (~penable) & (~pwrite);
   assign ADDR_WR = paddr;
   assign ADDR_RD = paddr;
   assign DIN     = pwdata;
   assign BSEL    = 4'b1111;
   assign prdata  = pready ? DOUT : {DATA_BITS{1'bx}};
  

 
   CREATE apb_slave_mem.v
   PREFIX_mem PREFIX_mem(
			 .clk(clk),
			 .reset(reset),
                         .GROUP_STUB_MEM(GROUP_STUB_MEM),
                         STOMP ,
			 );


   
   IFDEF TRACE
     CREATE apb_slave_trace.v
       PREFIX_trace #(SLAVE_NUM)
         PREFIX_trace(
		      .clk(clk),
		      .reset(reset),
                      .GROUP_STUB_MEM(GROUP_STUB_MEM),
                      STOMP ,
		      );
     
   ENDIF TRACE
   
endmodule



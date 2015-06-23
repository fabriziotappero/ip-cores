//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Module:
//-----------------------------------------------------------------
module soc_pif8
(
    // General - Clocking & Reset
    input               clk_i,
    input               rst_i,

    // Peripherals
    output [7:0]        periph0_addr_o,
    output [31:0]       periph0_data_o,
    input [31:0]        periph0_data_i,
    output reg          periph0_we_o,
    output reg          periph0_stb_o,

    output [7:0]        periph1_addr_o,
    output [31:0]       periph1_data_o,
    input [31:0]        periph1_data_i,
    output reg          periph1_we_o,
    output reg          periph1_stb_o,

    output [7:0]        periph2_addr_o,
    output [31:0]       periph2_data_o,
    input [31:0]        periph2_data_i,
    output reg          periph2_we_o,
    output reg          periph2_stb_o,

    output [7:0]        periph3_addr_o,
    output [31:0]       periph3_data_o,
    input [31:0]        periph3_data_i,
    output reg          periph3_we_o,
    output reg          periph3_stb_o,

    output [7:0]        periph4_addr_o,
    output [31:0]       periph4_data_o,
    input [31:0]        periph4_data_i,
    output reg          periph4_we_o,
    output reg          periph4_stb_o,

    output [7:0]        periph5_addr_o,
    output [31:0]       periph5_data_o,
    input [31:0]        periph5_data_i,
    output reg          periph5_we_o,
    output reg          periph5_stb_o,

    output [7:0]        periph6_addr_o,
    output [31:0]       periph6_data_o,
    input [31:0]        periph6_data_i,
    output reg          periph6_we_o,
    output reg          periph6_stb_o,

    output [7:0]        periph7_addr_o,
    output [31:0]       periph7_data_o,
    input [31:0]        periph7_data_i,
    output reg          periph7_we_o,
    output reg          periph7_stb_o,

    // I/O bus
    input [31:0]        io_addr_i,
    input [31:0]        io_data_i,
    output reg [31:0]   io_data_o,
    input               io_we_i,
    input               io_stb_i,
    output reg          io_ack_o
);

//-----------------------------------------------------------------
// Memory Map
//-----------------------------------------------------------------

// Route data / address to all peripherals
assign              periph0_addr_o = io_addr_i[7:0];
assign              periph0_data_o = io_data_i;
assign              periph1_addr_o = io_addr_i[7:0];
assign              periph1_data_o = io_data_i;
assign              periph2_addr_o = io_addr_i[7:0];
assign              periph2_data_o = io_data_i;
assign              periph3_addr_o = io_addr_i[7:0];
assign              periph3_data_o = io_data_i;
assign              periph4_addr_o = io_addr_i[7:0];
assign              periph4_data_o = io_data_i;
assign              periph5_addr_o = io_addr_i[7:0];
assign              periph5_data_o = io_data_i;
assign              periph6_addr_o = io_addr_i[7:0];
assign              periph6_data_o = io_data_i;
assign              periph7_addr_o = io_addr_i[7:0];
assign              periph7_data_o = io_data_i;

// Select correct target
always @ *
begin

   periph0_we_o         = 1'b0;
   periph0_stb_o        = 1'b0;
   periph1_we_o         = 1'b0;
   periph1_stb_o        = 1'b0;
   periph2_we_o         = 1'b0;
   periph2_stb_o        = 1'b0;
   periph3_we_o         = 1'b0;
   periph3_stb_o        = 1'b0;
   periph4_we_o         = 1'b0;
   periph4_stb_o        = 1'b0;
   periph5_we_o         = 1'b0;
   periph5_stb_o        = 1'b0;
   periph6_we_o         = 1'b0;
   periph6_stb_o        = 1'b0;
   periph7_we_o         = 1'b0;
   periph7_stb_o        = 1'b0;

   // Decode 4-bit peripheral select
   case (io_addr_i[11:8])

   // Peripheral 0
   4'd 0 :
   begin
       periph0_we_o         = io_we_i;
       periph0_stb_o        = io_stb_i;
   end
   // Peripheral 1
   4'd 1 :
   begin
       periph1_we_o         = io_we_i;
       periph1_stb_o        = io_stb_i;
   end
   // Peripheral 2
   4'd 2 :
   begin
       periph2_we_o         = io_we_i;
       periph2_stb_o        = io_stb_i;
   end
   // Peripheral 3
   4'd 3 :
   begin
       periph3_we_o         = io_we_i;
       periph3_stb_o        = io_stb_i;
   end
   // Peripheral 4
   4'd 4 :
   begin
       periph4_we_o         = io_we_i;
       periph4_stb_o        = io_stb_i;
   end
   // Peripheral 5
   4'd 5 :
   begin
       periph5_we_o         = io_we_i;
       periph5_stb_o        = io_stb_i;
   end
   // Peripheral 6
   4'd 6 :
   begin
       periph6_we_o         = io_we_i;
       periph6_stb_o        = io_stb_i;
   end
   // Peripheral 7
   4'd 7 :
   begin
       periph7_we_o         = io_we_i;
       periph7_stb_o        = io_stb_i;
   end

   default :
      ;
   endcase
end

//-----------------------------------------------------------------
// Read Port
//-----------------------------------------------------------------
always @ (posedge clk_i or posedge rst_i)
begin
   if (rst_i == 1'b1)
   begin
       io_data_o <= 32'b0;
       io_ack_o  <= 1'b0;
   end
   else
   begin
       if (io_stb_i)
       begin
           // Decode 4-bit peripheral select
           case (io_addr_i[11:8])
           // Peripheral 0
           4'd 0 : io_data_o  <= periph0_data_i;
           // Peripheral 1
           4'd 1 : io_data_o  <= periph1_data_i;
           // Peripheral 2
           4'd 2 : io_data_o  <= periph2_data_i;
           // Peripheral 3
           4'd 3 : io_data_o  <= periph3_data_i;
           // Peripheral 4
           4'd 4 : io_data_o  <= periph4_data_i;
           // Peripheral 5
           4'd 5 : io_data_o  <= periph5_data_i;
           // Peripheral 6
           4'd 6 : io_data_o  <= periph6_data_i;
           // Peripheral 7
           4'd 7 : io_data_o  <= periph7_data_i;

           default :  io_data_o  <= 32'h00000000;
           endcase
       end

       io_ack_o  <= io_stb_i;
   end
end

endmodule

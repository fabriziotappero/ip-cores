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
module dmem_mux3
(
    // Outputs
    output reg [31:0] out0_addr_o,
    output reg [31:0] out0_data_o,
    input [31:0]      out0_data_i,
    output reg [3:0]  out0_sel_o,
    output reg        out0_we_o,
    output reg        out0_stb_o,
    output reg        out0_cyc_o,
    output reg [2:0]  out0_cti_o,
    input             out0_ack_i,
    input             out0_stall_i,

    output reg [31:0] out1_addr_o,
    output reg [31:0] out1_data_o,
    input [31:0]      out1_data_i,
    output reg [3:0]  out1_sel_o,
    output reg        out1_we_o,
    output reg        out1_stb_o,
    output reg        out1_cyc_o,
    output reg [2:0]  out1_cti_o,
    input             out1_ack_i,
    input             out1_stall_i,

    output reg [31:0] out2_addr_o,
    output reg [31:0] out2_data_o,
    input [31:0]      out2_data_i,
    output reg [3:0]  out2_sel_o,
    output reg        out2_we_o,
    output reg        out2_stb_o,
    output reg        out2_cyc_o,
    output reg [2:0]  out2_cti_o,
    input             out2_ack_i,
    input             out2_stall_i,

    // Input
    input [31:0]      mem_addr_i,
    input [31:0]      mem_data_i,
    output reg[31:0]  mem_data_o,
    input [3:0]       mem_sel_i,
    input             mem_we_i,
    input             mem_stb_i,
    input             mem_cyc_i,
    input [2:0]       mem_cti_i,
    output reg        mem_ack_o,
    output reg        mem_stall_o
);

//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
parameter           ADDR_MUX_START      = 28;

//-----------------------------------------------------------------
// Request
//-----------------------------------------------------------------
always @ *
begin

   out0_addr_o      = 32'h00000000;
   out0_data_o      = 32'h00000000;
   out0_sel_o       = 4'b0000;
   out0_we_o        = 1'b0;
   out0_stb_o       = 1'b0;
   out0_cyc_o       = 1'b0;
   out0_cti_o       = 3'b0;
   out1_addr_o      = 32'h00000000;
   out1_data_o      = 32'h00000000;
   out1_sel_o       = 4'b0000;
   out1_we_o        = 1'b0;
   out1_stb_o       = 1'b0;
   out1_cyc_o       = 1'b0;
   out1_cti_o       = 3'b0;
   out2_addr_o      = 32'h00000000;
   out2_data_o      = 32'h00000000;
   out2_sel_o       = 4'b0000;
   out2_we_o        = 1'b0;
   out2_stb_o       = 1'b0;
   out2_cyc_o       = 1'b0;
   out2_cti_o       = 3'b0;

   case (mem_addr_i[ADDR_MUX_START+2-1:ADDR_MUX_START])

   2'd0:
   begin
       out0_addr_o      = mem_addr_i;
       out0_data_o      = mem_data_i;
       out0_sel_o       = mem_sel_i;
       out0_we_o        = mem_we_i;
       out0_stb_o       = mem_stb_i;
       out0_cyc_o       = mem_cyc_i;
       out0_cti_o       = mem_cti_i;
   end
   2'd1:
   begin
       out1_addr_o      = mem_addr_i;
       out1_data_o      = mem_data_i;
       out1_sel_o       = mem_sel_i;
       out1_we_o        = mem_we_i;
       out1_stb_o       = mem_stb_i;
       out1_cyc_o       = mem_cyc_i;
       out1_cti_o       = mem_cti_i;
   end
   2'd2:
   begin
       out2_addr_o      = mem_addr_i;
       out2_data_o      = mem_data_i;
       out2_sel_o       = mem_sel_i;
       out2_we_o        = mem_we_i;
       out2_stb_o       = mem_stb_i;
       out2_cyc_o       = mem_cyc_i;
       out2_cti_o       = mem_cti_i;
   end

   default :
      ;      
   endcase
end

//-----------------------------------------------------------------
// Response
//-----------------------------------------------------------------
always @ *
begin
   case (mem_addr_i[ADDR_MUX_START+2-1:ADDR_MUX_START])

    2'd0:
    begin
       mem_data_o   = out0_data_i;
       mem_stall_o  = out0_stall_i;
       mem_ack_o    = out0_ack_i;
    end
    2'd1:
    begin
       mem_data_o   = out1_data_i;
       mem_stall_o  = out1_stall_i;
       mem_ack_o    = out1_ack_i;
    end
    2'd2:
    begin
       mem_data_o   = out2_data_i;
       mem_stall_o  = out2_stall_i;
       mem_ack_o    = out2_ack_i;
    end

   default :
   begin
       mem_data_o   = 32'h00000000;
       mem_stall_o  = 1'b0;
       mem_ack_o    = 1'b0;
   end
   endcase
end

endmodule

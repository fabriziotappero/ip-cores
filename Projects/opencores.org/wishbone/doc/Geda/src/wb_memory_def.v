//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_ram.v                                                    ////
////                                                              ////
////                                                              ////
////  Author(s):                                                  ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001, 2009 Authors                             ////
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
 module 
  wb_memory_def 
    #( parameter 
      SRAM_MEM_0_FILE="NONE",
      SRAM_MEM_1_FILE="NONE",
      SRAM_MEM_2_FILE="NONE",
      SRAM_MEM_3_FILE="NONE",
      adr_width=12,
      dat_width=32,
      mem_size=16384,
      wb_addr_width=24,
      wb_byte_lanes=4,
      wb_data_width=32)
     (
 input   wire                 clk_i,
 input   wire                 cyc_i,
 input   wire                 rst_i,
 input   wire                 stb_i,
 input   wire                 we_i,
 input   wire    [ wb_addr_width-1 :  0]        adr_i,
 input   wire    [ wb_byte_lanes-1 :  0]        sel_i,
 input   wire    [ wb_data_width-1 :  0]        dat_i,
 output   reg                 ack_o,
 output   wire    [ wb_data_width-1 :  0]        dat_o);
wire                        sram_wr;
cde_sram_byte
#( .ADDR (adr_width),
   .WORDS (mem_size),
   .WRITETHRU (0))
rambyte_0 
   (
    .addr      ( adr_i[adr_width+1:2] ),
    .be      ( sel_i[0:0] ),
    .clk      ( clk_i  ),
    .cs      ( 1'b1  ),
    .rd      ( 1'b1  ),
    .rdata      ( dat_o[7:0] ),
    .wdata      ( dat_i[7:0] ),
    .wr      ( sram_wr  ));
cde_sram_byte
#( .ADDR (adr_width),
   .WORDS (mem_size),
   .WRITETHRU (0))
rambyte_1 
   (
    .addr      ( adr_i[adr_width+1:2] ),
    .be      ( sel_i[1:1] ),
    .clk      ( clk_i  ),
    .cs      ( 1'b1  ),
    .rd      ( 1'b1  ),
    .rdata      ( dat_o[15:8] ),
    .wdata      ( dat_i[15:8] ),
    .wr      ( sram_wr  ));
cde_sram_byte
#( .ADDR (adr_width),
   .WORDS (mem_size),
   .WRITETHRU (0))
rambyte_2 
   (
    .addr      ( adr_i[adr_width+1:2] ),
    .be      ( sel_i[2:2] ),
    .clk      ( clk_i  ),
    .cs      ( 1'b1  ),
    .rd      ( 1'b1  ),
    .rdata      ( dat_o[23:16] ),
    .wdata      ( dat_i[23:16] ),
    .wr      ( sram_wr  ));
cde_sram_byte
#( .ADDR (adr_width),
   .WORDS (mem_size),
   .WRITETHRU (0))
rambyte_3 
   (
    .addr      ( adr_i[adr_width+1:2] ),
    .be      ( sel_i[3:3] ),
    .clk      ( clk_i  ),
    .cs      ( 1'b1  ),
    .rd      ( 1'b1  ),
    .rdata      ( dat_o[31:24] ),
    .wdata      ( dat_i[31:24] ),
    .wr      ( sram_wr  ));
reg waitst;
   always @ (posedge clk_i or posedge rst_i)
     if (rst_i)                  waitst <= 1'b0;
     else
     if (!ack_o) 
       begin
        if (cyc_i & stb_i)       waitst <= 1'b1;
        else                     waitst <= waitst;
       end
     else                        waitst <= 1'b0;
   // ack_o
   always @ (posedge clk_i or posedge rst_i)
     if (rst_i)                             ack_o <= 1'b0;
     else
     if (!ack_o) 
       begin
        if (cyc_i & stb_i & waitst )        ack_o <= 1'b1; 
        else                                ack_o <= ack_o; 
       end
     else                                   ack_o <= 1'b0;
assign sram_wr        =   we_i & ack_o;
  endmodule

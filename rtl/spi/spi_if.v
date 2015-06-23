//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores SPI Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
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

module spi_if
          (
           clk, 
           reset_n,

           // towards ctrl i/f
           sck_pe,
           sck_int,
           cs_int_n,
           byte_in,
           load_byte,
           byte_out,
           shift_out,
           shift_in,

           cfg_tgt_sel,

           sck,
           so,
           si,
           cs_n
           );

  input clk,reset_n;
  input sck_pe;
  input sck_int,cs_int_n;
  
  input       load_byte;
  input [1:0] cfg_tgt_sel;

  input [7:0] byte_out;
  input       shift_out,shift_in;

  output [7:0] byte_in;
  output       sck,so;
  output [3:0] cs_n;
  input        si;


  reg [7:0]    so_reg;
  reg [7:0]    si_reg;
  wire [7:0]   byte_out;
  wire         sck;
  reg          so;
  wire [3:0]   cs_n;


  //Output Shift Register

  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        so_reg <= 8'h00;
        so <= 1'b0;
     end
     else begin
        if(load_byte) begin
           so_reg <= byte_out;
           if(shift_out) begin 
              // Handling backto back case : 
              // Last Transfer bit + New Trasfer Load
              so <= so_reg[7];
           end
        end // if (load_byte)
        else begin
           if(shift_out) begin
              so <= so_reg[7];
              so_reg <= {so_reg[6:0],1'b0};
           end // if (shift_out)
        end // else: !if(load_byte)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)


// Input shift register
  always @(posedge clk or negedge reset_n) begin
     if(!reset_n) begin
        si_reg <= 8'h0;
     end
     else begin
        if(sck_pe & shift_in) begin
           si_reg[7:0] <= {si_reg[6:0],si};
        end // if (sck_pe & shift_in)
     end // else: !if(!reset_n)
  end // always @ (posedge clk or negedge reset_n)


  assign byte_in[7:0] = si_reg[7:0];
  assign cs_n[0] = (cfg_tgt_sel[1:0] == 2'b00) ? cs_int_n : 1'b1;
  assign cs_n[1] = (cfg_tgt_sel[1:0] == 2'b01) ? cs_int_n : 1'b1;
  assign cs_n[2] = (cfg_tgt_sel[1:0] == 2'b10) ? cs_int_n : 1'b1;
  assign cs_n[3] = (cfg_tgt_sel[1:0] == 2'b11) ? cs_int_n : 1'b1;
  assign sck = sck_int;

endmodule

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  $Id: wb_sram.v,v 1.4 2008-12-13 21:04:13 hharte Exp $       ////
////  wb_sram.v - SRAM with Wishbone Slave interface.             ////
////                                                              ////
////  This file is part of the Vector Graphic Z80 SBC Project     ////
////  http://www.opencores.org/projects/vg_z80_sbc/               ////
////                                                              ////
////  Author:                                                     ////
////      - Howard M. Harte (hharte@opencores.org)                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 Howard M. Harte                           ////
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
module wb_sram
#(
    parameter mem_file_name = "none",
    parameter adr_width = 14,
    parameter dat_width = 8,
    parameter dw = 32 //number of data-bits
) (
    // Generic synchronous single-port RAM interface
    clk_i, nrst_i, wb_adr_i, wb_dat_o, wb_dat_i, wb_sel_i, wb_we_i,
    wb_stb_i, wb_cyc_i, wb_ack_o
);

    //
    // Default address and data buses width
    //

    //
    // Generic synchronous single-port RAM interface
    //
    input            clk_i;
    input            nrst_i;
    input   [adr_width-1:0] wb_adr_i;
    output  [dw-1:0] wb_dat_o;
    input   [dw-1:0] wb_dat_i;
    input      [3:0] wb_sel_i;
    input            wb_we_i;
    input            wb_stb_i;
    input            wb_cyc_i;
    output reg       wb_ack_o;

    //
    // generate wishbone register bank writes
    wire wb_acc = wb_cyc_i & wb_stb_i;    // WISHBONE access
    wire wb_wr  = wb_acc & wb_we_i;       // WISHBONE write access
    wire [3:0] xram_we;

    // generate ack_o
    always @(posedge clk_i)
        wb_ack_o <= #1 wb_acc & !wb_ack_o;

    wire       [1:0] adr_low;
    wire       [7:0] sram_dat_o;
    wire       [7:0] sram_dat_i;

    assign adr_low = wb_sel_i == 4'b0001 ? 2'b00 : wb_sel_i == 4'b0010 ? 2'b01 : wb_sel_i == 4'b0100 ? 2'b10 : 2'b11;
    assign wb_dat_o = {sram_dat_o, sram_dat_o, sram_dat_o, sram_dat_o};
    assign sram_dat_i = wb_sel_i == 4'b0001 ? wb_dat_i[7:0] : wb_sel_i == 4'b0010 ? wb_dat_i[15:8] : wb_sel_i == 4'b0100 ? wb_dat_i[23:16] : wb_dat_i[31:24];

// Instantiate the memory using Block RAM
// synthesis attribute ram_style of sram_block is block
sram_block #(
    .mem_file_name(mem_file_name),
    .adr_width(adr_width),
    .dat_width(dat_width)
) sram_block0 (
    .clk(clk_i),
    .adr({wb_adr_i[adr_width-1:2],adr_low}),
    .dout(sram_dat_o),
    .din(sram_dat_i),  
    .we(wb_wr)
);

endmodule

module sram_block
#(
    parameter mem_file_name = "none",
    parameter adr_width = 14,
    parameter dat_width = 8
) (
    input                       clk,
    input      [adr_width-1:0]  adr,
    input                       we,
    input      [dat_width-1:0]  din,
    output reg [dat_width-1:0]  dout
);

parameter depth = (1 << adr_width);

// RAM Array 
reg [dat_width-1:0] ram [0:depth-1];

always @(posedge clk)
begin
    if (we) 
        ram[adr] <= din;

    dout <= ram[adr];
end

//------------------------------------------------------------------
// Initialize contents of RAM from file
//------------------------------------------------------------------
integer i;

initial 
begin
    if (mem_file_name != "none")
    begin
        $readmemh(mem_file_name, ram);
    end
    else begin
        for(i=0; i<depth; i=i+1) 
            ram[i] <= 'b0;
    end
    
end

endmodule

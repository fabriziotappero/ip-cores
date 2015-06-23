//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_vga.v - Wishbone wrapper and Video/Font RAM.             ////
////                                                              ////
////  This file is part of the Text-Mode VGA Controller Project   ////
////  http://www.opencores.org/projects/                          ////
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

//////////////////////////////////////////////////////////////////////
////                                                              ////
//// This controller occupies 16K of address space:               ////
////                                                              ////
//// 0000-0FFF - Video RAM (Character storage)                    ////
//// 1000-1FFF - Font  RAM (Font storage)                         ////
//// 2000-2FFF - VGA Controller Registers                         ////
////             2000 - VGA OCTL                                  ////
////                    [7] - 1=Video enable / 0=disable          ////
////                    [6] - 1=Cursor enable / 0=disable         ////
////                    [5] - 1=Cursor blink / 0=solid            ////
////                    [4] - 1=Cursor Mode                       ////
////                    [2:0] - R/G/B Color Enables               ////
////             2001 - VGA OCTL2 (unused)                        ////
////             2002 - VGA OCRX Cursor X Position                ////
////             2003 - VGA OCRY Cursor Y Position                ////
//// 3000-3FFF - Unused                                           ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module wb_vga(
    // VGA Interface
    clk_i, clk_50mhz_i, nrst_i, wb_adr_i, wb_dat_o, wb_dat_i, wb_sel_i, wb_we_i,
    wb_stb_i, wb_cyc_i, wb_ack_o,
    vga_hsync_o, vga_vsync_o, vga_r_o, vga_g_o, vga_b_o
);

    parameter font_file_name = "fwii_8x10.ram";     // Font filename (must contain exactly 4K of data)
    parameter font_height = 10;    // Number of pixels in font height
    parameter text_height = 2; // 1=80x48, 2=80x24

    //
    // Wishbone Wrapper for Text-Mode VGA Controller
    //
    input            clk_i;
    input            clk_50mhz_i;
    input            nrst_i;
    input     [13:0] wb_adr_i;
    output    [31:0] wb_dat_o;
    input     [31:0] wb_dat_i;
    input      [3:0] wb_sel_i;
    input            wb_we_i;
    input            wb_stb_i;
    input            wb_cyc_i;
    output  reg      wb_ack_o;
    output           vga_hsync_o;
    output           vga_vsync_o;
    output           vga_r_o;
    output           vga_g_o;
    output           vga_b_o;    
    
    wire     [7:0]   vga_dat;
    wire    [11:0]   vga_adr;

    reg     [7:0]    vga_regs[0:3];

    wire     [7:0]   octl = vga_regs[0]; // 7=vga_en, 6=cursor_en, 2:0=color
    wire     [7:0]   octl2 = vga_regs[1]; // unused for now
    wire     [7:0]   ocrx = vga_regs[2];
    wire     [7:0]   ocry = vga_regs[3];
    
    wire    [11:0]   font_a;
    wire     [7:0]   font_d;
    
    wire    [1:0]    adr_low;
    wire    [7:0]    dpram_dat_o;
    wire    [7:0]    dpram_dat_i;

    reg              clk25mhz;
    wire             vga_clk = clk25mhz;

    wire             video_ram_acc = wb_adr_i[13:12] == 2'b00; 
    wire             font_ram_acc = wb_adr_i[13:12] == 2'b01;
    wire             vga_regs_acc = wb_adr_i[13:12] == 2'b10;    

    wire    [7:0]    font_dat_o;
    wire    [7:0]    reg_dat_o;

    //
    // generate wishbone register bank writes
    wire wb_acc = wb_cyc_i & wb_stb_i;    // WISHBONE access
    wire wb_wr  = wb_acc & wb_we_i;       // WISHBONE write access
    wire wb_rd  = wb_acc & ~wb_we_i;      // WISHBONE read access
    wire vga_ram_wr = wb_wr & video_ram_acc;
    wire font_ram_wr = wb_wr & font_ram_acc;
    wire vga_reg_wr = wb_wr & vga_regs_acc;

    // generate ack_o
    always @(posedge clk_i)
        wb_ack_o <= #1 wb_acc & !wb_ack_o;

    assign adr_low = wb_sel_i == 4'b0001 ? 2'b00 : wb_sel_i == 4'b0010 ? 2'b01 : wb_sel_i == 4'b0100 ? 2'b10 : 2'b11;
    assign wb_dat_o = video_ram_acc ? {dpram_dat_o, dpram_dat_o, dpram_dat_o, dpram_dat_o} : 
                       font_ram_acc ? {font_dat_o, font_dat_o, font_dat_o, font_dat_o} : 
                       {reg_dat_o, reg_dat_o, reg_dat_o, reg_dat_o};
    assign dpram_dat_i = wb_sel_i == 4'b0001 ? wb_dat_i[7:0] : wb_sel_i == 4'b0010 ? wb_dat_i[15:8] : wb_sel_i == 4'b0100 ? wb_dat_i[23:16] : wb_dat_i[31:24];

    always @(posedge clk_i or negedge nrst_i)
        if (~nrst_i)                // reset registers
            begin
                vga_regs[0] <= 8'b10110111; // 7=vga_en, 6=cursor_en, 2:0=color
                vga_regs[1] <= 8'b00000000; // 0xA5
                vga_regs[2] <= 8'b00000000;
                vga_regs[3] <= 8'b00000000;
            end
        else if(vga_reg_wr)          // wishbone write cycle
            vga_regs[adr_low] <= dpram_dat_i;

        assign reg_dat_o = vga_regs[adr_low];

// Instantiate the VGA module
vga80x40    # (
    .font_height(font_height),
    .text_height(text_height))
vga_controller (
    .reset(~nrst_i), 
    .clk25MHz(vga_clk), 
    .TEXT_A(vga_adr), 
    .TEXT_D(vga_dat), 
    .FONT_A(font_a), 
    .FONT_D(font_d), 
    .ocrx(ocrx), 
    .ocry(ocry), 
    .octl(octl), 
    .R(vga_r_o), 
    .G(vga_g_o), 
    .B(vga_b_o), 
    .hsync(vga_hsync_o), 
    .vsync(vga_vsync_o)
    );

// Instantiate the Video RAM (4K)
// synthesis attribute ram_style of video_ram is block
vga_dpram #(
    .mem_file_name("none"),
    .adr_width(12),
    .dat_width(8)
) video_ram (
    .clk1(clk_i),
    .clk2(vga_clk),
    //
    .adr0({wb_adr_i[11:2], adr_low}),
    .dout0(dpram_dat_o),
    .din0(dpram_dat_i),  
    .we0(vga_ram_wr),
    //
    .adr1(vga_adr),
    .dout1(vga_dat),
    .din1(8'b0),  
    .we1(1'b0)
);

// Instantiate the Font RAM (4K, initialized with font data)
// synthesis attribute ram_style of font_ram is block
vga_dpram #(
    .mem_file_name(font_file_name),
    .adr_width(12),
    .dat_width(8)
) font_ram (
    .clk1(clk_i),
    .clk2(vga_clk),
    //
    .adr0({wb_adr_i[11:2], adr_low}  ),
    .dout0(font_dat_o),
    .din0(dpram_dat_i),  
    .we0(font_ram_wr),
    //
    .adr1(font_a),
    .dout1(font_d),
    .din1(8'b0),  
    .we1(1'b0)
);

// Generate 25MHz Pixel Clock
always @(posedge clk_50mhz_i or negedge nrst_i)
    if (~nrst_i)
        begin
            clk25mhz <= 1'b0;
        end else begin
            clk25mhz <= !clk25mhz;
        end

endmodule


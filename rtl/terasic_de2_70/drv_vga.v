/*
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*! \file
 * \brief ADV7123 Video DAC driver for VGA output.
 */

/*! \brief \copybrief drv_vga.v
*/
module drv_vga(
	//% \name Clock and reset
    //% @{
	input clk_30,
	input reset_n,
	//% @}
	
	//% \name On-Screen-Display management interface
    //% @{
	input               management_mode,
	input               on_screen_display,
	output [4:0]        osd_line,
	output [4:0]        osd_column,
	input [7:0]         character,
	//% @}
	
	//% \name Control signal for VGA capture
    //% @{
	output              display_valid,
	//% @}
	
	//% \name Direct drv_ssram burst read DMA video interface
    //% @{
	output reg          burst_read_request,
	output reg [31:2]   burst_read_address,
	input               burst_read_ready,
	input [35:0]        burst_read_data,
	//% @}
	
	//% \name ADV7123 Video DAC hardware interface
    //% @{
	output [9:0]        vga_r,
	output [9:0]        vga_g,
	output [9:0]        vga_b,
	output              vga_blank_n,
	output              vga_sync_n,
	output              vga_clock,
	output              vga_hsync,
	output              vga_vsync
	//% @}
);

`define VGA_VIDEO_BUFFER            32'h10180000
`define VGA_VIDEO_BUFFER_DIV_4      30'h04060000

assign vga_blank_n = 1'b1;
assign vga_sync_n = 1'b0;
assign vga_clock = clk_30;

reg [7:0] address_a;
reg [7:0] address_b;
wire [35:0] q_b;
altsyncram line_ram_inst(
	.clock0(clk_30),
	.address_a(address_a),
	.wren_a(burst_read_ready),
	.data_a(burst_read_data),
	
	.clock1(clk_30),
	.address_b(address_b),
	.q_b(q_b)
);
defparam 	line_ram_inst.operation_mode = "DUAL_PORT",
			line_ram_inst.width_a = 36,
			line_ram_inst.widthad_a = 8,
			line_ram_inst.width_b = 36,
			line_ram_inst.widthad_b = 8;


wire burst_read_prepare;
assign burst_read_prepare = (
    // time to start of next line: 129 + 150 -> enough for ssram write and read
	h_counter == (10'd799-10'd129) &&
	(
		v_counter == 9'd18 || /* before first line */ 
		(v_counter != 9'd498 && line_counter != 9'd511 && {line_counter + 9'd1} == next_line) /* other valid lines, without last line */
	)
) ? 1'b1 : 1'b0;

//	0,	2,	4,	6,	8,	10,	12,	14,
//	15,	17,	19,	21,	23,	25,	27,	29,
//	30,	32,	34,	36,	38,	40,	42,	44,
//	45, ...
//	

reg [8:0] next_line;
reg [2:0] next_counter;
always @(posedge clk_30 or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		burst_read_request <= 1'b0;
		burst_read_address <= 30'd0;
		address_a <= 8'd0;
		
		next_line <= 9'd0;
		next_counter <= 3'd0;
	end
	else if(v_counter == 9'd0) begin
		burst_read_address <= `VGA_VIDEO_BUFFER_DIV_4; // start of video buffer
		next_line <= 9'd0;
		next_counter <= 3'd0;
	end
	else if(burst_read_prepare == 1'b1) begin
		burst_read_request <= 1'b1;
		address_a <= 8'd0;
	end
	else if(burst_read_ready == 1'b1 && address_a <= 8'd211) begin
		address_a <= address_a + 8'd1;
	end
	else if(burst_read_ready == 1'b1 && address_a == 8'd212) begin
		address_a <= address_a + 8'd1;
		burst_read_request <= 1'b0;
		burst_read_address <= burst_read_address + 30'd216; // 640/3 = 213.(3) = 214 +2 for %4 = 0
		
		next_counter <= next_counter + 3'd1;
		
		if(next_counter == 3'd7)	next_line <= next_line + 9'd1;
		else 						next_line <= next_line + 9'd2;
	end
end

reg [1:0] three_counter;
always @(posedge clk_30 or negedge reset_n) begin
	if(reset_n == 1'b0) begin
		address_b <= 8'd0;
		three_counter <= 2'd0;
	end
	else if(display_valid == 1'b0) begin
		address_b <= 8'd0;
		three_counter <= 2'd1;
	end
	else if(three_counter == 2'd1) begin
		three_counter <= three_counter + 2'd1;
	end
	else if(three_counter == 2'd2) begin
	    three_counter <= three_counter + 2'd1;
	    address_b <= address_b + 8'd1;
	end
	else if(three_counter == 2'd3) begin
		three_counter <= 2'd1;
	end
end

wire [9:0] red =
        (management_mode == 1'b1 && three_counter == 2'd1)? { q_b[31:29], 7'b0 } :
        (management_mode == 1'b1 && three_counter == 2'd1)? { q_b[22:20], 7'b0 } :
        (management_mode == 1'b1)? { q_b[13:11], 7'b0 } :
    (three_counter == 2'd1) ? { q_b[35:32], 6'b0 } :
    (three_counter == 2'd2) ? { q_b[23:20], 6'b0 } :
    { q_b[11:8], 6'b0 };

wire [9:0] green =
        (management_mode == 1'b1 && three_counter == 2'd1)? { q_b[28:26], 7'b0 } :
        (management_mode == 1'b1 && three_counter == 2'd1)? { q_b[19:17], 7'b0 } :
        (management_mode == 1'b1)? { q_b[10:8], 7'b0 } :
	(three_counter == 2'd1) ? { q_b[31:28], 6'b0 } :
	(three_counter == 2'd2) ? { q_b[19:16], 6'b0 } :
	{ q_b[7:4], 6'b0 };

wire [9:0] blue =
        (management_mode == 1'b1 && three_counter == 2'd1)? { q_b[25:23], 7'b0 } :
        (management_mode == 1'b1 && three_counter == 2'd1)? { q_b[16:14], 7'b0 } :
        (management_mode == 1'b1)? { q_b[7:5], 7'b0 } :
    (three_counter == 2'd1) ? { q_b[27:24], 6'b0 } :
    (three_counter == 2'd2) ? { q_b[15:12], 6'b0 } :
    { q_b[3:0], 6'b0 };

//------------------------------------------------------------------------------ on screen display: 24 columns, 18 lines start
wire [8:0] line_counter_for_osd;
assign line_counter_for_osd     = line_counter - 9'd176;
wire [10:0] column_counter_for_osd;
assign column_counter_for_osd   = column_counter - 11'd8;

assign osd_line     = (line_counter >= 9'd176 /* 480-16-16x18 */ && line_counter < 9'd464 /* 480-16*/)? line_counter_for_osd[8:4]  : 5'd31;
assign osd_column   = (column_counter >= 11'd8 && column_counter < 11'd200 /* 8+24x8 */)?               column_counter_for_osd[7:3]: 5'd31;

reg [7:0] char_saved;
always @(posedge clk_30 or negedge reset_n) begin
    if(reset_n == 1'b0)                             char_saved <= 8'd0;
    else if(column_counter_for_osd[2:0] == 3'd6)    char_saved <= character;
end

//****************** Font
wire [8:0] font_line;
assign font_line = v_counter - 9'd3;

wire [9:0] font_column;
assign font_column = h_counter - 10'd6;

wire [7:0] font;
altsyncram font_rom_inst(
	.clock0(clk_30),
	.address_a({char_saved[6:0], font_line[3:0]}),
	.q_a(font)
);
defparam font_rom_inst.operation_mode = "ROM";
defparam font_rom_inst.width_a = 8;
defparam font_rom_inst.widthad_a = 11;
defparam font_rom_inst.init_file = "drv_vga_font.mif";

wire font_pixel;
assign font_pixel = char_saved[7] ^ font[font_column[2:0]];

wire osd_active;
assign osd_active = (on_screen_display == 1'b1 && osd_line != 5'd31 && osd_column != 5'd31);
//------------------------------------------------------------------------------ on screen display end

// 640x480@75Hz
reg [9:0] h_counter;
reg [8:0] v_counter;
always @(posedge clk_30 or negedge reset_n) begin
	if(reset_n == 1'b0) begin
	    h_counter <= 10'd0;
	    v_counter <= 9'd0;
	end
	else if(h_counter == 10'd799) begin
		h_counter <= 10'd0;
		
		if(v_counter == 9'd499) 	v_counter <= 9'd0;
		else						v_counter <= v_counter + 9'd1;
	end
	else begin
		h_counter <= h_counter + 10'd1;
	end
end

assign vga_hsync = (h_counter >= 10'd0 && h_counter <= 10'd63) ? 1'b0 : 1'b1;
assign vga_vsync = (v_counter >= 9'd0 && v_counter <= 9'd2) ? 1'b0 : 1'b1;

wire [8:0] line_counter;
assign line_counter = (v_counter >= 9'd19 && v_counter <= 9'd498)? v_counter - 9'd19 : 9'd511;

wire [10:0] column_counter;
assign column_counter = (h_counter >= 10'd150 && h_counter <= 10'd789)? h_counter - 10'd150 : 10'd1023;

assign display_valid = (line_counter != 9'd511 && column_counter != 10'd1023);

assign vga_r = display_valid ? ((osd_active == 1'b0) ? red      : {10{font_pixel}}) : 10'd0;
assign vga_g = display_valid ? ((osd_active == 1'b0) ? green    : {10{font_pixel}}) : 10'd0;
assign vga_b = display_valid ? ((osd_active == 1'b0) ? blue     : {10{font_pixel}}) : 10'd0;

endmodule


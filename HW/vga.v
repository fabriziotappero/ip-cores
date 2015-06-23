//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: vga.v
// Description: Part of the Next186 SoC PC project, VGA module
//		customized VGA, only modes 3 (25x80x256 text), 13h (320x200x256 graphic) 
//		and VESA 101h (640x480x256) implemented
// Version 1.0
// Creation date: Jan2012
//
// Author: Nicolae Dumitrache 
// e-mail: ndumitrache@opencores.org
//
/////////////////////////////////////////////////////////////////////////////////
// 
// Copyright (C) 2012 Nicolae Dumitrache
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
// PURPOSE. See the GNU Lesser General Public License for more 
// details. 
// 
// You should have received a copy of the GNU Lesser General 
// Public License along with this source; if not, download it 
// from http://www.opencores.org/lgpl.shtml 
// 
///////////////////////////////////////////////////////////////////////////////////
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module VGA_SG
  (
  input  wire	[9:0]	tc_hsblnk,
  input  wire	[9:0]	tc_hssync,
  input  wire	[9:0]	tc_hesync,
  input  wire	[9:0]	tc_heblnk,

  output reg	[9:0]	hcount = 0,
  output reg			hsync,
  output reg			hblnk = 0,

  input  wire	[9:0]	tc_vsblnk,
  input  wire	[9:0]	tc_vssync,
  input  wire	[9:0]	tc_vesync,
  input  wire	[9:0]	tc_veblnk,

  output reg	[9:0]	vcount = 0,
  output reg			vsync,
  output reg			vblnk = 0,

  input  wire			clk,
  input  wire			ce
  );

  //******************************************************************//
  // This logic describes a 10-bit horizontal position counter.       //
  //******************************************************************//
  always @(posedge clk)
		if(ce) begin
			if(hcount >= tc_heblnk) begin
				hcount <= 0;
				hblnk <= 0;
			end else begin
				hcount <= hcount + 1;
				hblnk <= (hcount >= tc_hsblnk);
			end
			hsync <= (hcount >= tc_hssync) && (hcount < tc_hesync);
		end
		
  //******************************************************************//
  // This logic describes a 10-bit vertical position counter.         //
  //******************************************************************//
	always @(posedge clk)
		if(ce && hcount == tc_heblnk) begin
			if (vcount >= tc_veblnk) begin
				vcount <= 0;
				vblnk <= 0;
			end else begin
				vcount <= vcount + 1;
				vblnk <= (vcount >= tc_vsblnk);
			end
			vsync <= (vcount >= tc_vssync) && (vcount < tc_vesync);
		end

  //******************************************************************//
  // This is the logic for the horizontal outputs.  Active video is   //
  // always started when the horizontal count is zero.  Example:      //
  //                          
  //
  // tc_hsblnk = 03                                                   //
  // tc_hssync = 07                                                   //
  // tc_hesync = 11                                                   //
  // tc_heblnk = 15 (htotal)                                          //
  //                                                                  //
  // hcount   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15         //
  // hsync    ________________________------------____________        //
  // hblnk    ____________------------------------------------        //
  //                                                                  //
  // hsync time  = (tc_hesync - tc_hssync) pixels                     //
  // hblnk time  = (tc_heblnk - tc_hsblnk) pixels                     //
  // active time = (tc_hsblnk + 1) pixels                             //
  //                                                                  //
  //******************************************************************//

  //******************************************************************//
  // This is the logic for the vertical outputs.  Active video is     //
  // always started when the vertical count is zero.  Example:        //
  //                                                                  //
  // tc_vsblnk = 03                                                   //
  // tc_vssync = 07                                                   //
  // tc_vesync = 11                                                   //
  // tc_veblnk = 15 (vtotal)                                          //
  //                                                                  //
  // vcount   00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15         //
  // vsync    ________________________------------____________        //
  // vblnk    ____________------------------------------------        //
  //                                                                  //
  // vsync time  = (tc_vesync - tc_vssync) lines                      //
  // vblnk time  = (tc_veblnk - tc_vsblnk) lines                      //
  // active time = (tc_vsblnk + 1) lines                              //
  //                                                                  //
  //******************************************************************//


endmodule


module VGA_DAC(
    input CE,
	 input WR,
    input [3:0]addr,
	 input [7:0]din,
	 output [7:0]dout,
	 input CLK,
	 input VGA_CLK,
	 input [7:0]vga_addr,
	 input setindex,
	 output [17:0]color,
	 output reg vgatext = 1,
	 output reg vga400 = 1,
	 output reg vgaflash = 0,
	 output reg half = 0,
	 output reg [3:0]hrzpan = 0
    );
	
	reg [7:0]mask = 8'hff;
	reg [9:0]index = 0;
	reg mode = 0;
	reg [1:0]a0mode = 0;
	reg a0data = 0;
	wire [7:0]pal_dout;
	wire [31:0]pal_out;
	wire addr6 = addr == 6;
	wire addr7 = addr == 7;
	wire addr8 = addr == 8;
	wire addr9 = addr == 9;
	wire addr0 = addr == 0;
	

	DAC_SRAM vga_dac 
	(
	  .clka(CLK), // input clka
	  .wea(CE & WR & addr9), // input [0 : 0] wea
	  .addra(index), // input [9 : 0] addra
	  .dina(din), // input [7 : 0] dina
	  .douta(pal_dout), // output [7 : 0] douta
	  .clkb(VGA_CLK), // input clkb
	  .web(1'b0), // input [0 : 0] web
	  .addrb(vga_addr & mask), // input [7 : 0] addrb
	  .dinb(32'h00000000), // input [31 : 0] dinb
	  .doutb(pal_out) // output [31 : 0] doutb
	);
	
	assign color = {pal_out[21:16], pal_out[13:8], pal_out[5:0]};
	assign dout = addr6 ? mask : addr7 ? {6'bxxxxxx, mode, mode} : addr8 ? index[9:2] : pal_dout;
	
	always @(posedge CLK) begin
	
		if(setindex) a0data <= 0;
		else if(CE && addr0 && WR) a0data <= ~a0data;
	
		if(CE) begin
			if(addr0) begin
				if(WR) begin					
					if(a0data) case(a0mode) 
						2'b01: {vga400, half, vgaflash, vgatext} <= {din[6], din[4:3], ~din[0]};
						2'b10: hrzpan <= din[3:0];
					endcase else case(din[4:0])
						5'h10: a0mode <= 2'b01;
						5'h13: a0mode <= 2'b10;
						default: a0mode <= 2'b00;
					endcase
				end
			end 
			if(addr6 && WR) mask <= din;
			if(addr7 | addr8) begin
				if(WR) index <= {din, 2'b00};
				mode <= addr8;
			end else if(addr9) index <= index + (index[1:0] == 2'b10 ? 2 : 1);
		end
	end

endmodule



module VGA_CRT(
    input CE,
	 input WR,
	 input WORD,
	 input [15:0]din,
	 input addr,
	 output reg [7:0]dout,
	 input CLK,
	 output reg oncursor,
	 output wire [11:0]cursorpos,
	 output wire [15:0]scraddr,
	 output reg v240 = 1'b0,
	 output reg [7:0]offset = 8'h28
    );
	
	reg [7:0]crtc[3:0];
	reg [4:0]index = 0;
	assign cursorpos = {crtc[2][3:0], crtc[3]};
	assign scraddr = {crtc[0], crtc[1]};
	 
	always @(posedge CLK) begin
		if(CE && WR) begin
			if(addr) begin
				if(index == 5'h6) v240 <= ~din[7];
				if(index == 5'ha) oncursor <= din[5];
				if(index >= 5'hc && index <= 5'hf) crtc[index[1:0]] <= din[7:0];
				if(index == 5'h13) offset <= din[7:0];
			end else begin
				if(WORD) begin
					if(din[4:0] == 5'h6) v240 <= ~din[15];
					if(din[4:0] == 5'ha) oncursor <= din[13];
					if(din[4:0] >= 5'hc && din[4:0] <= 5'hf) crtc[din[1:0]] <= din[15:8];
					if(din[4:0] == 5'h13) offset <= din[15:8];
				end
				index <= din[4:0];
			end
		end
		dout <= crtc[index[1:0]];
	end
endmodule


module VGA_SC(
    input CE,
	 input WR,
	 input WORD,
	 input [15:0]din,
	 output reg [7:0]dout,
	 input addr,
	 input CLK,
	 output reg planarreq,
	 output reg[3:0]wplane
    );
	
	reg [2:0]index = 0;
	 
	always @(posedge CLK) begin 
		if(CE && WR) begin
			if(addr) begin
				if(index == 2) wplane <= din[3:0];
				if(index == 4) planarreq <= ~din[3];
			end else begin
				if(WORD) begin
					if(din[2:0] == 2) wplane <= din[11:8];
					if(din[2:0] == 4) planarreq <= ~din[11];
				end
				index <= din[2:0];
			end
		end
		dout <= {4'b0000, index == 2 ? wplane : {~planarreq, 3'b000}};
	end
endmodule


module VGA_GC(
    input CE,
	 input WR,
	 input WORD,
	 input [15:0]din,
	 output reg [7:0]dout,
	 input addr,
	 input CLK,
	 output reg [1:0]rplane = 2'b00,
	 output reg[7:0]bitmask = 8'b11111111,
	 output reg [2:0]rwmode = 3'b000,
	 output reg [3:0]setres = 4'b0000,
	 output reg [3:0]enable_setres = 4'b0000,
	 output reg [1:0]logop = 2'b00,
	 output reg [3:0]color_compare,
	 output reg [3:0]color_dont_care
    );
	
	reg [3:0]index = 0;
	 
	always @(posedge CLK) begin
		if(CE && WR) begin
			if(addr) begin
				case(index)
					0: setres <= din[3:0];
					1: enable_setres <= din[3:0];
					2: color_compare <= din[3:0];
					3: logop <= din[4:3];
					4: rplane <= din[1:0];
					5: rwmode <= {din[3], din[1:0]};
					7: color_dont_care <= din[3:0];
					8: bitmask <= din[7:0];
				endcase
			end else begin
				if(WORD) case(din[3:0])
					0: setres <= din[11:8];
					1: enable_setres <= din[11:8];
					2: color_compare <= din[11:8];
					3: logop <= din[12:11];
					4: rplane <= din[9:8];
					5: rwmode <= {din[11], din[9:8]};
					7: color_dont_care <= din[11:8];
					8: bitmask <= din[15:8];
				endcase
				index <= din[3:0];
			end
		end
		case(index)
			0: dout[3:0] <= setres;
			1: dout[3:0] <= enable_setres;
			2: dout[3:0] <= color_compare;
			3: dout[4:3] <= logop;
			4: dout[1:0] <= rplane;
			5: dout[3:0] <= {rwmode[2], 1'bx, rwmode[1:0]};
			7: dout[3:0] <= color_dont_care;
			8: dout[7:0] <= bitmask;
		endcase
	end
endmodule


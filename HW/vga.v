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
	 output OE,
	 output [7:0]dout,
	 input CLK,
	 input VGA_CLK,
	 input [7:0]vga_addr,
	 input setindex,
	 output [11:0]color,
	 output reg vgatext = 1,
	 output reg vga400 = 1,
	 output reg vgaflash = 0
    );
	
	reg [7:0]mask = 8'hff;
	reg [9:0]index = 0;
	reg mode = 0;
	reg a0mode = 0;
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
	  .dinb(32'hxxxxxxxx), // input [31 : 0] dinb
	  .doutb(pal_out) // output [31 : 0] doutb
	);
	
	assign color = {pal_out[21:18], pal_out[13:10], pal_out[5:2]};
	assign dout = addr6 ? mask : addr7 ? {6'bxxxxxx, mode, mode} : addr8 ? index[9:2] : pal_dout;
	assign OE = CE & (addr6 | addr7 | addr8 | addr9);
	
	always @(posedge CLK) begin
	
		if(setindex) a0data <= 0;
		else if(CE && addr0 && WR) a0data <= ~a0data;
	
		if(CE) begin
			if(addr0) begin
				if(WR) begin
					if(~a0data && (din[4:0] == 5'h10)) a0mode <= 1;
					else a0mode <= 0;
					if(a0mode) begin
						vgatext <= ~din[0];
						vga400 <= din[6];
						vgaflash <= din[3];
					end
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
	 input [7:0]din,
	 input addr,
	 output [7:0]dout,
	 input CLK,
	 output reg oncursor,
	 output wire [11:0]cursorpos,
	 output wire [15:0]scraddr
    );
	
	reg [7:0]crtc[3:0];
	reg [2:0]index = 0;
	assign dout = crtc[index[1:0]];
	assign cursorpos = {crtc[2][3:0], crtc[3]};
	assign scraddr = {crtc[0], crtc[1]};
	 
	always @(posedge CLK) if(CE && WR) begin
		if(addr) begin
			if(index[2]) crtc[index[1:0]] <= din;
			else if(index[1:0] == 2'b10) oncursor <= din[5];
		end else index <= din[2:0];
	end
endmodule

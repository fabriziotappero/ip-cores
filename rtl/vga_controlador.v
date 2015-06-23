/*	MODULE: openfire vga
	DESCRIPTION: Contains vga controller (displays pictures from RAM)

AUTHOR: 
Antonio J. Anton
Anro Ingenieros (www.anro-ingenieros.com)
aj@anro-ingenieros.com

REVISION HISTORY:
Revision 1.0, 26/03/2007
Initial release

COPYRIGHT:
Copyright (c) 2007 Antonio J. Anton

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.*/

`timescale 1ns / 1ps
`include "openfire_define.v"

//***************************************************************************
// VGA timming by Jason Stewart
// http://www.cs.unc.edu/~stewart/comp290-ghw/vga.html
//
// Filename:  vga_controller.v
//
// Module for a simple vga controller. A "horizontal counter" counts pixels 
// in a line, including the sync pulse, front porch, back porch, etc. Then, 
// a "pulse generator" looks at the output of the counter and outputs a 
// pulse of a given length starting at a given count. These are used to 
// generate the sync pulse and the active video signal. Parameters for 
// the counter and pulse generators appear below.
//
// The logic for vertical is similar. The main difference is that the 
// vertical counter has a clock enable, which is used to make the vert 
// counter count lines instead of pixels. Specifically, the hsync from 
// the horizontal stage (which occurs once per line) creates a 1-cycle 
// pulse for the vert counter clock enable, and thus the vert counter 
// increments on every hsync.
//
// In general, you can play around with the start counts for the sync pulse 
// and active signal. This basically increases/decreases the front and back 
// porches, thereby moving the frame up/down or left/right on the screen.
//***************************************************************************
module vga_controller(cpu_clk, pixel_clk, reset, 
							 hsync_n, vsync_n, red, green, blue,
							 ram_pointer, ram_data, req, rdy);

// The default parameters are for 800x600 @ 72 Hz (assuming a 50 MHz clock). 
/*  parameter N1       = 11;    // number of counter bits  HORIZONTAL
  parameter HCOUNT   = 1040;  // total pixel count
  parameter HS_START = 40;    // start of hsync pulse
  parameter HS_LEN   = 120;   // length of hsync pulse
  parameter HA_START = 224;   // start of active video
  parameter HA_LEN   = 800;   // length of active video

  parameter N2 = 10;          // number of counter bits  VERTICAL
  parameter VCOUNT = 666;     // total line count
  parameter VS_START = 24;    // start of vsync pulse
  parameter VS_LEN   = 6;     // length of vsync pulse
  parameter VA_START = 64;    // start of active video
  parameter VA_LEN   = 600;   // length of active video */

// For 640x480 @ 60 Hz, use the following (assuming a 25 MHz clock):
  parameter N1       = 10;
  parameter HCOUNT   = 800;
  parameter HS_START = 8;
  parameter HS_LEN   = 96;
  parameter HA_START = 127;
  parameter HA_LEN   = 640;
  
  parameter N2 = 10;
  parameter VCOUNT = 525;
  parameter VS_START = 2;
  parameter VS_LEN   = 2;
  parameter VA_START = 24;
  parameter VA_LEN   = 480;

  input  cpu_clk;				// clock de la cpu
  input  pixel_clk;			// pixel clock
  input	reset;
  output hsync_n, vsync_n;	// señales sincronismo
  output red;					// color
  output green;
  output blue;

  output [17:0]	ram_pointer;	// SRAM pointer (32 bit aligned)
  input	[31:0]	ram_data;		// data from SRAM
  output req;							// read request
  input  rdy;							// SRAM data available
 
  wire hsync, vsync;					// --- sync signals are negated ----
  wire hsync_n = ~hsync;
  wire vsync_n = ~vsync;

  wire htc, vtc, vce;				// --------- Sync pulse stuff ----------  
  wire hactive, vactive;
  wire [N1-1:0] hcnt;
  wire [N2-1:0] vcnt;

  // horizontal
  counter_tc #(N1,HCOUNT)	     	  H_CNT(pixel_clk, reset, hcnt, htc);
  pulse_gen #(N1,HS_START,HS_LEN)  H_SYNC(pixel_clk, reset, hcnt, hsync);
  pulse_gen #(N1,HA_START,HA_LEN)  H_ACTIVE(pixel_clk, reset, hcnt, hactive);

  // vertical
  pulse_high_low                   V_CNT_CE(pixel_clk, reset, hsync, vce);
  counter_tc_ce #(N2,VCOUNT)	     V_CNT(pixel_clk, reset, vce, vcnt, vtc);
  pulse_gen #(N2,VS_START,VS_LEN)  V_SYNC(pixel_clk, reset, vcnt, vsync);
  pulse_gen #(N2,VA_START,VA_LEN)  V_ACTIVE(pixel_clk, reset, vcnt, vactive);

// -------- memory and video parameters ------------
  reg [17:0] ram_pointer;		// memory pointer
  reg 		 req;					// indica si hay que leer desde memoria

  wire red;		  					// output RGB signals (1 bpp)
  wire green;
  wire blue;

  reg	[9:0]	pixels_red;			// WORD = x RGB RGB RGB RGB RGB x RGB RGB RGB RGB RGB
  reg	[9:0] pixels_green;		// 		 1 098 765 432 109 876 5 432 109 876 543 210
  reg [9:0] pixels_blue;  		//			   3            2             1
  reg [3:0]	contador_pixels;	// pixel counter
  reg 	   leer;					// video asks SRAM reader next word
  reg			leido;				// SRAM reader notifies video the data is available

assign red   = (hactive && vactive) && pixels_red[9];			// current pixel 
assign green = (hactive && vactive) && pixels_green[9];
assign blue  = (hactive && vactive) && pixels_blue[9];
 
// --------- retrieve 1 word (30 pixels) each time from SRAM  ---------
always @(posedge cpu_clk)
begin
 if(reset || !vactive)						// reset or vertical retrace -> restart
 begin
  ram_pointer <= `LOCATION_VRAM;			// video memory at the end of the SRAM (upper 120 Kbytes)
  req    	  <= 0;
  leido 	  	  <= 0;
 end	 
 else
 begin
  if(!leido && leer && !req)				// request data
  begin
	 req <= 1;
  end
  else if(!leido && leer && req && rdy)// data avaiable	(registered at controller level)
  begin
	 req      <= 0;
	 leido    <= 1;
  end
  else if(leido && !leer)					// waiting next read
  begin
    leido <= 0;
	 ram_pointer <= ram_pointer + 1;
  end
 end
end

// ------- pintamos los pixels (al pixel clock) --------
wire first_pixel		= (contador_pixels == 0);
wire threshold_pixel = (contador_pixels == 2);
wire last_pixel		= (contador_pixels == 9);

always @(posedge pixel_clk)
begin
 if(reset)							// tras un reset -> pedir el 1er word a SRAM
 begin
   leer 					<= 1;		// on startup request next data
   contador_pixels 	<= 0;
   pixels_red   		<= 10'b0;
   pixels_green 		<= 10'b0;
   pixels_blue  		<= 10'b0;	
 end
 else if(hactive && vactive)	// we are in visible area
 begin  
	pixels_red	 <= first_pixel ? { ram_data[30], ram_data[27], ram_data[24], ram_data[21], ram_data[18], ram_data[14], ram_data[11], ram_data[8], ram_data[5], ram_data[2] } : { pixels_red[8:0], 	1'bX };
	pixels_green <= first_pixel ? { ram_data[29], ram_data[26], ram_data[23], ram_data[20], ram_data[17], ram_data[13], ram_data[10], ram_data[7], ram_data[4], ram_data[1] } : { pixels_green[8:0], 1'bX };
	pixels_blue  <= first_pixel ? { ram_data[28], ram_data[25], ram_data[22], ram_data[19], ram_data[16], ram_data[12], ram_data[9],  ram_data[6], ram_data[3], ram_data[0] } : { pixels_blue[8:0],	1'bX };	  
	if(threshold_pixel) leer <= 1;		// fetch next word before current is processed
	else if(leido) 	  leer <= 0; 		// if already done, release flag
	contador_pixels <= last_pixel ? 0 : contador_pixels + 1;		// pixel counter
 end
end

endmodule


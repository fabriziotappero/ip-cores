//////////////////////////////////////////////////////////////////////
////                                                              ////
////  system.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   - Wishbone controller testbench implementation for         ////
////     Spartan 3E Starter Kit (XC3S500E) board from Digilent.   ////
////  To Do:                                                      ////
////   - nothing really                                           ////
////                                                              ////
////  Author(s):                                                  ////
////   - José Ignacio Villar, jose@dte.us.es , jvillar@gmail.com  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2009 José Ignacio Villar - jvillar@gmail.com   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 3 of the License, or (at your option) any     ////
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
//// from http://www.gnu.org/licenses/lgpl.txt                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "lcd_defines.v"

module system(
	input clk,
	input reset,
	
	input  [2:0] rot,
	
	output [3:0] SF_D,
	output LCD_E,
	output LCD_RS,
	output LCD_RW,
	output SF_CE0,
	
	output reg [7:0] led
	);
	
//----------------------------------------------------------------------------
// rotary decoder
//----------------------------------------------------------------------------
wire rot_btn;
wire rot_event;
wire rot_left;

rotary rotdec0 (
	.clk(       clk        ),
	.reset(     reset      ),
	.rot(       rot        ),
	// output
	.rot_btn(   rot_btn    ),
	.rot_event( rot_event  ),
	.rot_left(  rot_left   )
);

//----------------------------------------------------------------------------
// LCD Display
//----------------------------------------------------------------------------

reg	[`DAT_RNG]	dat = 8'b00100000;
wire	[`WB_DAT_RNG]	wb_dat = {24'b0, dat};
reg	[`ADDR_WIDTH:0] addr = 0;
wire	[`WB_ADDR_RNG]	wb_addr = {24'b0, addr};
wire	[`WB_DAT_RNG]	status;
wire 			busy = status[0];
wire cs;
wire we;
wire ack;

wb_lcd lcd  (
	//
	// I/O Ports
	//
	.wb_clk_i	( clk ),
	.wb_rst_i	( reset),
	
	//
	// WB slave interface
	//
	.wb_dat_i	( wb_dat ),
	.wb_dat_o	( status ),
	.wb_adr_i	( wb_addr ),
	.wb_sel_i	(  ),
	.wb_we_i	( we ),
	.wb_cyc_i	( cs  ),
	.wb_stb_i	( cs ),
	.wb_ack_o	( ack ),

	//
	// LCD interface
	//
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	
//----------------------------------------------------------------------------
// Behavioural description
//----------------------------------------------------------------------------
assign SF_CE0 = 1'b1; // disable intel strataflash

// Handles "start displaying character" shift
reg [`DAT_RNG]  start_dat = 8'b00100000;

integer i = 0;
assign we = (i < 104) & ~busy;
assign cs = (i < 104);
			
// Handles transfers to the display
always @(posedge clk) 
begin
	if(reset) begin
		led <= 8'b00100000;
		start_dat <= 8'b00100000;

		i <= 0;
		addr <= 0;
		dat <= start_dat;
	end else begin
		if (i < 104 && !busy) begin
			i <= i + 1;
			addr <= addr + 1;
			dat <= dat + 1;
		end else if (rot_event && rot_left && !busy) begin
			led <= led - 1;
			start_dat <= start_dat - 1;

			i <= 0;
			addr <= 0;
			dat <= start_dat - 1;
		end else if (rot_event && !busy) begin
			led <= led + 1;
			start_dat <= start_dat + 1;	

			i <= 0;
			addr <= 0;
			dat <= start_dat + 1;
		end
	end
end
 
endmodule

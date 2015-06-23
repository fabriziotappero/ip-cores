//////////////////////////////////////////////////////////////////////
////                                                              ////
////  wb_lcd.v                                                    ////
////                                                              ////
////  This file is part of:                                       ////
////  WISHBONE/MEM MAPPED CONTROLLER FOR LCD CHARACTER DISPLAYS   ////
////  http://www.opencores.org/projects/wb_lcd/                   ////
////                                                              ////
////  Description                                                 ////
////   -  Wishbone wrapper.                                       ////
////                                                              ////
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

module wb_lcd (
	//
	// I/O Ports
	//
	input			wb_clk_i,
	input			wb_rst_i,

	//
	// WB slave interface
	//
	input	[`WB_DAT_RNG]	wb_dat_i,
	output	reg [`WB_DAT_RNG]	wb_dat_o,
	input	[`WB_ADDR_RNG]	wb_adr_i,
	input	[`WB_BSEL_RNG]	wb_sel_i,
	input			wb_we_i,
	input			wb_cyc_i,
	input			wb_stb_i,
	output	reg		wb_ack_o,
	output			wb_err_o,
	
	//
	// LCD interface
	//
	output	[3:0]		SF_D,
	output			LCD_E,
	output			LCD_RS,
	output			LCD_RW
	);
	

assign wb_err_o = 0;

wire cs = wb_cyc_i & wb_stb_i;
wire we = cs & wb_we_i;
wire re = cs & !wb_we_i;
wire special_address = (`SPECIAL_REG_ADDR_MASK == (`SPECIAL_REG_ADDR_MASK & wb_adr_i));

wire lcd_busy;
wire lcd_we = !special_address & we;
wire [`ADDR_WIDTH-1:0] lcd_addr = wb_adr_i[`ADDR_WIDTH-1:0];

wire repaint_req =  we & (wb_adr_i == `COMMAND_REG_ADDR) & (wb_dat_i == `COMMAND_REPAINT_CODE);
wire status = lcd_busy ? `STATUS_BUSY_CODE : `STATUS_IDDLE_CODE;


// wb_ack management: two clk cycles per WB access to avoid long combinational paths.
always @(posedge wb_clk_i) begin
	if(wb_rst_i)
		wb_ack_o <= 1'b0;
	else begin
		if(cs)
			wb_ack_o <= ~wb_ack_o;
		else
			wb_ack_o <= 1'b0;
	end
end

// Status register (only checks if lcd is busy)
always @(posedge wb_clk_i) // wb_dat_o always outputs the status register not depending on what address is being accessed
	wb_dat_o = status;

// Command register (only issues repaint commands)
reg lcd_repaint = 0;
always @(posedge wb_clk_i) begin
	if(repaint_req & !lcd_busy)
		lcd_repaint <= 1;
	else
		lcd_repaint <= 0;
end

//----------------------------------------------------------------------------
// Memory mapped LCD display controller
//----------------------------------------------------------------------------

lcd lcd(
	.clk	( wb_clk_i ),
	.reset	( wb_rst_i ),
	
	.dat	( wb_dat_i[`DAT_RNG] ),
	.addr	( lcd_addr ),
	.we	( lcd_we ),
	.repaint( lcd_repaint ),
	
	.busy	( lcd_busy ),	
	.SF_D	( SF_D ),
	.LCD_E	( LCD_E ),
	.LCD_RS	( LCD_RS ),
	.LCD_RW	( LCD_RW )
	);
	


endmodule


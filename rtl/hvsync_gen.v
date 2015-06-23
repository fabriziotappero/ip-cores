`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:01:50 04/13/2009 
// Design Name:    HV sync generator
// Module Name:    hvsync_gen 
// Project Name:   The FPGA Othello Game
// Target Devices: Spartan3E
// Tool versions: 
// Description: 
//		             designed for 640x480@60Hz
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//    it works, using 50MHz clock
// Marius TIVADAR.
//
//////////////////////////////////////////////////////////////////////////////////
module hvsync_gen(
			clk,
			h_sync,
			v_sync,
			wcntX,
			wcntY
		 );


/* input clock */
input clk;

/* output h_sync */
output h_sync;
/* output v_sync */
output v_sync;
/* output X pixel cnt */ 
output [9:0] wcntX;
/* output Y pixel cnt */ 
output [8:0] wcntY;

/* 25.175 MHz pixel clock */
parameter PIXEL_CLOCK = 25;

/* ~50Mhz global clock frequency */
parameter GLOBAL_CLOCK = 50;

/* clock frequency not equal with pixel clock, so we multiply the parameters */
parameter MULT_FACTOR = GLOBAL_CLOCK / PIXEL_CLOCK;

parameter VGA_H_SYNC_PULSE  = 96 * MULT_FACTOR;
parameter VGA_H_FRONT_PORCH = 16 * MULT_FACTOR;
parameter VGA_H_BACK_PORCH  = 48 * MULT_FACTOR;
parameter VGA_H_PIXEL_COUNT = 800 * MULT_FACTOR;

parameter VGA_V_SYNC_PULSE  = 2;
parameter VGA_V_FRONT_PORCH = 10;
parameter VGA_V_BACK_PORCH  = 33;
parameter VGA_V_LINE_COUNT  = 525;

/* internal registers for H/V sync */
reg vga_HS;
reg vga_VS;

/* internal counters */
reg [10:0] cntX;
reg [9:0]  cntY;

/* window counters, H visible area: 640, V visible area: 480 */
reg [9:0] wcntX;
reg [8:0] wcntY;

wire cntXmaxed = (cntX == VGA_H_PIXEL_COUNT - 1);
wire cntYmaxed = (cntY == VGA_V_LINE_COUNT - 1);

/* update counters*/
always @(posedge clk) begin
	if(cntYmaxed) begin
			 cntY <= 0;
			wcntY <= 0;
	end
	
	if(cntXmaxed) begin
	     cntX <= 0;
		  cntY <= cntY + 1;
		 wcntX <= 0;		  
		
	 	 if (   (cntY > VGA_V_SYNC_PULSE + VGA_V_FRONT_PORCH) 
		 	  && (cntY < VGA_V_LINE_COUNT - VGA_V_BACK_PORCH)
				)
		 begin
		     wcntY <= wcntY + 1;
		 end
	
	end
	else begin
		 if (   (cntX[10:0] > VGA_H_SYNC_PULSE + VGA_H_FRONT_PORCH) 
			  && (cntX[10:0] < VGA_H_PIXEL_COUNT  - VGA_H_BACK_PORCH) 
			  && (cntX[0] == 0)  // count 2 by 2 (because global clock is 2*pixel_clock)
			 ) 
		  begin
				wcntX <= wcntX + 1;
		  end
	
		  cntX <= cntX + 1;
	end
	
end

/* generate HS and VS */
always @(posedge clk)
begin
	vga_HS <= (cntX[10:0] < VGA_H_SYNC_PULSE);
	vga_VS <= (cntY[9:0] < VGA_V_SYNC_PULSE);
end

/* polarity negative */
assign h_sync = ~vga_HS;
assign v_sync = ~vga_VS;

endmodule

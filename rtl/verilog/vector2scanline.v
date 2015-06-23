`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Yann Vernier
// 
// Create Date:    21:37:32 02/19/2011 
// Design Name: 
// Module Name:    vector2scanline 
// Project Name: PDP-1
// Target Devices: Spartan 3A
// Tool versions: 
// Description: Converts vector data (exposed points) into raster video
//
// Dependencies: 
//
// Revision: $Id$
// $Log$
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

/*
 * Design: Two interfaces are provided, each with their own clock.
 *         The first is an XY plotting interface, where each new point
 *         is indicated by a rising edge on strobe_i.
 *         The second is the scanline/raster video port, where a pixel
 *         clock reads out a single scanline, and rising edges on
 *         newline_i and newframe_i indicate when a new or first line
 *         should start.
 * 
 * The target design runs a pixel clock of 193MHz and plotting clock
 * of 50MHz, ensuring that no plotted point is missed. 
 * A register to store the plotted point could be added instead, but
 * currently hold times are guaranteed to work (changes only occur on
 * a 200kHz cycle). Expect timing warnings, however.
 * 
 * Internal structure: One ring buffer FIFO stores plotted points and their
 * respective age. Age is decremented only when the points are copied into
 * the scanline buffer (once per frame). 
 * A dual-port scanline buffer is filled in with plotted points in a back-
 * buffer while the forward buffer is read out to video and subsequently
 * wiped.
 * 
 * The FIFO could be factored out and converted to LFSR counting.
 * 
 * TODO: Make the scanning stop once it has reached the edges.
 *       Connect to main design. Add next scanline ports, so double
 *       buffers do not delay everything one line.
 *
 */
 
module vector2scanline(
		       clk_xy_i,          // clock
		       strobe_i,      // new exposed pixel trigger
		       x_i,          // column of exposed pixel
		       y_i,          // row of exposed pixel

		       clk_fifo_i,
		       
		       // Video output interface
		       clk_video_i,    // pixel clock
		       xout_i,         // current pixel column
		       yout_i,         // current pixel row
		       newline_i,      // line buffer swap signal
		       newframe_i,     // new frame signal
		       pixel_o,  // output pixel intensity, unregistered
		       /*AUTOARG*/
   // Inputs
   wipe_i
   );


   parameter X_WIDTH = 10;     // bit width of column coordinate
   parameter Y_WIDTH = 10;     // bit width of row coordinate
   parameter HIST_WIDTH = 10;  // log2 of maximum lit pixels (exposure buffer)
   parameter AGE_WIDTH = 8;    // width of exposure age counter
   
   input clk_xy_i;
   input strobe_i;
   input [X_WIDTH-1:0] x_i;
   input [Y_WIDTH-1:0] y_i;

   input 	       clk_fifo_i;
   input [AGE_WIDTH-1:0] wipe_i;
   
   input 	       clk_video_i;
   input [X_WIDTH-1:0] xout_i;
   input [Y_WIDTH-1:0] yout_i;
   input 	       newline_i, newframe_i;
   output [AGE_WIDTH-1:0] pixel_o;
   reg 			  pixel_o;

   // Used for edge detection on strobe signals
   reg prev_strobe_i, prev_newline_i, prev_newframe_i;
   // Result of edge detectors
   wire strobe, newline, newframe;

   // positions and age of lit pixels
   reg [X_WIDTH+Y_WIDTH+AGE_WIDTH-1:0] exposures [(2**HIST_WIDTH)-1:0];
   // output register of exposed pixels buffer
   reg [X_WIDTH+Y_WIDTH+AGE_WIDTH-1:0] expr;
   // data for next pixel to store in exposure buffer
   wire [X_WIDTH-1:0] 		       expx;
   wire [Y_WIDTH-1:0] 		       expy;
   wire [AGE_WIDTH-1:0] 	       expi;
   // whether this pixel needs to be stored back in exposure buffer
   wire 			       exposed;
   // whether this pixel belongs to the next (backbuffer) scanline
   wire 			       rowmatch;
   // addresses for exposure buffer read and write ports
   reg [HIST_WIDTH-1:0] 	       exprptr=0, expwptr=0;
	
   // dual port scanline pixel buffer, stores intensity
   // double-buffered; one gets wiped as it is displayed
   // the other gets filled in with current exposures
   reg [AGE_WIDTH-1:0] 		       scanlines [(2**X_WIDTH):0];
   // selection register for which scanline buffer is output/filled in
   reg 				       bufsel = 0;
   // address lines for the two memory ports
   wire [X_WIDTH:0] 		       scanout_addr, lineplot_addr;
   wire 			       scanout_clk, lineplot_clk;
   
   // Edge detectors for strobe lines
   always @(posedge clk_xy_i) prev_strobe_i <= strobe_i;
   assign strobe = strobe_i & ~prev_strobe_i;
   always @(posedge clk_video_i) prev_newline_i <= newline_i;
   assign newline = newline_i & ~prev_newline_i;
   always @(posedge clk_video_i) prev_newframe_i <= newframe_i;
   assign newframe = newframe_i & ~prev_newframe_i;


   // RAM read out of exposure buffer
   always @(posedge clk_fifo_i) begin
      // TODO: stop scanning until newline once we're through the entire buffer
      expr<=exposures[exprptr];
      if (!strobe) begin
	 // do not skip current read position if strobe inserts a new pixel
	 exprptr<=exprptr+1;
      end
   end

   // decode and mux: split fields from exposure buffer, or collect new at strobe
   assign expx = strobe?x_i:expr[X_WIDTH+Y_WIDTH+AGE_WIDTH-1:Y_WIDTH+AGE_WIDTH];
   assign expy = strobe?y_i:expr[Y_WIDTH+AGE_WIDTH-1:AGE_WIDTH];
   assign expi = strobe?(2**AGE_WIDTH)-1:expr[AGE_WIDTH-1:0];
   // detect whether pixel even needs to be stored back
   assign exposed = expi!=0;
   // detect whether pixel applies to current backbuffer
      // TODO: use a next line input port, the double buffering delays this data
      // by an entire scanline.
   assign rowmatch=(expy==yout_i);
   
   always @(posedge clk_fifo_i) begin
      // Feed incoming exposures into exposure buffer
      // TODO: stop scanning until newline once we're through the entire buffer
      if (exposed) begin
	 exposures[expwptr] <= {expx, expy, expy==yout_i?expi-1:expi};
	 expwptr <= expwptr+1;
      end
   end


   // Fron buffer address
   assign scanout_addr = {bufsel,xout_i};
   assign scanout_clk = clk_video_i;
   always @(posedge scanout_clk) begin
      // Wipe front buffer
      scanlines[scanout_addr] <= wipe_i;
      // Read out front buffer
      pixel_o <= scanlines[scanout_addr];
   end

   // Back buffer address
   assign lineplot_addr = {~bufsel, expx};
   assign lineplot_clk = clk_fifo_i;
   always @(posedge lineplot_clk) begin
      //            pixel_o <= scanlines[lineplot_addr];
      // Store exposures for next scanline
      if (rowmatch) begin
	 scanlines[lineplot_addr] <= expi;
      end
   end

   always @(posedge clk_video_i) begin
      // swap buffers when signaled
      if (newline) begin
	 bufsel <= ~bufsel;
      end
   end
   
endmodule

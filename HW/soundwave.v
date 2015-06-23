`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the Next186 Soc PC project
// http://opencores.org/project,next186
//
// Filename: sound_gen.v
// Description: Part of the Next186 SoC PC project, 
//		stereo 2x16bit pulse density modulated sound generator
// 	44100 samples/sec
//		Disney Sound Source and Covox Speech compatible
// Version 1.0
// Creation date: Jan2015
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
//////////////////////////////////////////////////////////////////////////////////
// Additional Comments: 
//
//	byte write: both channels are the same (Covox emulation), the 8bit sample value is shifted by 8, the channel selector is reset to LEFT
// word write: LEFT first, the queue is updated only after RIGHT value is written
// sample rate: 44100Hz
//////////////////////////////////////////////////////////////////////////////////
module soundwave(
		input CLK,
		input CLK44100x256,
		input [15:0]data,
		input we,
		input word,
		output full,	// when not full, write max 2x1152 16bit samples
		output dss_full,
		output reg AUDIO_L,
		output reg AUDIO_R
	);

	 reg [31:0]wdata;
	 reg lr = 1'b0;
	 reg [2:0]write = 3'b000;
	 wire [31:0]sample;
	 reg [31:0]lval = 0; 
	 reg [31:0]rval = 0;
	 reg [8:0]clkdiv = 0;
	 wire lsign = lval[31:16] < sample[15:0];
	 wire rsign = rval[31:16] < sample[31:16];
	 wire empty;
	 assign dss_full = !empty;	// Disney sound source queue full
	 
	 sndfifo sndfifo_inst 
	 (
	  .wr_clk(CLK), // input wr_clk
	  .rd_clk(CLK44100x256), // input rd_clk
	  .din(wdata), // input [31 : 0] din
	  .wr_en(|write), // input wr_en
	  .rd_en(clkdiv[8]), // input rd_en
	  .dout(sample), // output [31 : 0] dout
//	  .full(full), // output full
//	  .empty(empty), // output empty
	  .prog_full(full), // output prog_full
	  .prog_empty(empty)
	);
	 

	 always @(posedge CLK44100x256) begin
		clkdiv[8:0] <= clkdiv[7:0] + 1'b1;
		
		lval <= lval - lval[31:7] + (lsign << 25);
		AUDIO_L <= lsign;

		rval <= rval - rval[31:7] + (rsign << 25);
		AUDIO_R <= rsign;
	 end


	always @(posedge CLK) begin
		if(we) 
			if(word) begin
				lr <= !lr;
				write <= {2'b00, lr};
				if(lr) wdata[31:16] <= {!data[15], data[14:0]};
				else wdata[15:0] <= {!data[15], data[14:0]};
			end else begin
				lr <= 1'b0;		// left
				write <= 3'b110;
				wdata <= {1'b0, data[7:0], 8'b00000000, data[7:0], 7'b0000000};
			end
		else write <= write - |write;
	end


endmodule

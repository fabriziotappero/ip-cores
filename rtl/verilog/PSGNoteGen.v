`timescale 1ns / 1ps
//=============================================================================
//	(C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGNoteGen.v
//	Version 1.1
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//	Note generator. 4/8 channels
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	337 LUTs / 224 slices / 98.445 MHz
//=============================================================================

module PSGNoteGen(rst, clk, cnt, br, bg, bgn, ack, test,
	vt0, vt1, vt2, vt3,
	freq0, freq1, freq2, freq3,
	pw0, pw1, pw2, pw3,
	acc0, acc1, acc2, acc3,
	wave, sync, ringmod, o
);
input rst;
input clk;
input [7:0] cnt;
input ack;
input [11:0] wave;
input [2:0] bgn;		// bus grant number
output [3:0] br;
input [3:0] bg;
input [3:0] test;
input [4:0] vt0, vt1, vt2, vt3;
input [15:0] freq0, freq1, freq2, freq3;
input [11:0] pw0, pw1, pw2, pw3;
input [3:0] sync;
input [3:0] ringmod;
//	input pxacc25;
output [23:0] acc0, acc1, acc2, acc3;	// 1.023MHz / 2^ 24 = 0.06Hz resolution
output [11:0] o;

wire [15:0] freqx;
wire [11:0] pwx;
reg [23:0] pxacc;
reg [23:0] acc;
reg [11:0] outputT;
reg [7:0] pxacc23x;
reg [7:0] ibr;

integer n;

reg [23:0] accx [3:0];
reg [11:0] pacc [3:0];
wire [1:0] sel = cnt[1:0];
reg [11:0] outputW [3:0];
reg [22:0] lfsr [3:0];

assign br[0] =	ibr[0] & ~bg[0];
assign br[1] =	ibr[1] & ~bg[1];
assign br[2] =	ibr[2] & ~bg[2];
assign br[3] =	ibr[3] & ~bg[3];

wire [4:0] vtx;

always @(sel)
	acc <= accx[sel];


mux4to1 #(16) u1 (.e(1'b1), .s(sel), .i0(freq0), .i1(freq1), .i2(freq2), .i3(freq3), .z(freqx) );
mux4to1 #(12) u2 (.e(1'b1), .s(sel), .i0(pw0), .i1(pw1), .i2(pw2), .i3(pw3), .z(pwx) );
mux4to1 #( 5) u3 (.e(1'b1), .s(sel), .i0(vt0), .i1(vt1), .i2(vt2), .i3(vt3), .z(vtx) );


wire [22:0] lfsrx = lfsr[sel];
wire [7:0] paccx = pacc[sel];

always @(sel)
	pxacc <= accx[sel-1];
wire pxacc23 = pxacc[23];


// for sync'ing
always @(posedge clk)
	if (cnt < 8'd4)
		pxacc23x[sel] <= pxacc23;

wire synca = ~pxacc23x[sel]&pxacc23&sync[sel];


// detect a transition on the wavetable address
// previous address not equal to current address
wire accTran = pacc[sel]!=acc[23:12];

// for wave table DMA
// capture the previous address
always @(posedge clk)
	if (rst) begin
		for (n = 0; n < 4; n = n + 1)
			pacc[n] <= 0;
	end
	else if (cnt < 8'd4)
		pacc[sel] <= acc[23:12];


// capture wave input
// must be to who was granted the bus
always @(posedge clk)
	if (rst) begin
		for (n = 0; n < 8'd4; n = n + 1)
			outputW[n] <= 0;
	end
	else if (ack)
		outputW[bgn] <= wave;


// bus request control
always @(posedge clk)
	if (rst) begin
		ibr <= 0;
	end
	else if (cnt < 8'd4) begin
		// check for an address transition and wave enabled
		// if so, request bus
		if (accTran & vtx[4])
			ibr[sel] <= 1;
		// otherwise
		// turn off bus request for whoever it was granted
		else
			ibr[bgn] <= 0;
	end


// Noise generator
always @(posedge clk)
	if (cnt < 8'd4 && paccx[2] != acc[18])
		lfsr[sel] <= {lfsrx[21:0],~(lfsrx[22]^lfsrx[17])};


// Harmonic synthesizer
always @(posedge clk)
	if (rst) begin
		for (n = 0; n < 4; n = n + 1)
			accx[n] <= 0;
	end
	else if (cnt < 8'd4) begin
		if (~test[sel]) begin
			if (synca)
				accx[sel] <= 0;
			else
				accx[sel] <= acc + freqx;
		end
		else
			accx[sel] <= 0;
	end


// Triangle wave, ring modulation
wire msb = ringmod[sel] ? acc[23]^pxacc23 : acc[23];
always @(acc or msb)
	outputT <= msb ? ~acc[22:11] : acc[22:11];

// Other waveforms, ho-hum
wire [11:0] outputP = {12{acc[23:12] < pwx}};
wire [11:0] outputS = acc[23:12];
wire [11:0] outputN = lfsrx[11:0];

wire [11:0] out;
PSGNoteOutMux #(12) u4 (.s(vtx), .a(outputT), .b(outputS), .c(outputP), .d(outputN), .e(outputW[sel]), .o(out) );
assign o = out;

assign acc0 = accx[0];
assign acc1 = accx[1];
assign acc2 = accx[2];
assign acc3 = accx[3];

endmodule


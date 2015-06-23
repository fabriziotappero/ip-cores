//////////////////////////////////////////////////////////////////////
////                                                              ////
////  spi_shift.v                                                 ////
////                                                              ////
////  This file is part of the SPI IP core project                ////
////  http://www.opencores.org/projects/spi/                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Srot (simons@opencores.org)                     ////
////                                                              ////
////  All additional information is avaliable in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2002 Authors                                   ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
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
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

`include "spi_defines.v"
`include "timescale.v"

module spi_shift_in (clk, rst, go,
                  pos_edge, neg_edge, rx_negedge, 
                  tip, last, p_out, s_clk, s_in);

 	parameter Tp = 1;

	input                          clk;          // system clock
	input                          rst;          // reset
//	input [`SPI_ADC_CHAR_LEN_BITS-1:0] len;          // data len in bits (minus one)
	input                          go;           // start stansfer
	input                          pos_edge;     // recognize posedge of sclk
	input                          neg_edge;     // recognize negedge of sclk
	input                          rx_negedge;   // s_in is sampled on negative edge 
	output                         tip;          // transfer in progress
	output                         last;         // last bit
	output     [`SPI_ADC_CHAR-1:0] p_out;        // parallel out
	input						s_clk;			// serial clk
	input                          s_in;         // serial in
                                            
	reg                            tip;
                           
	reg     [`SPI_ADC_CHAR_LEN_BITS:0] cnt;          // data bit count
	reg        [`SPI_ADC_CHAR-1:0] data;         // shift register
	wire    [`SPI_ADC_CHAR_LEN_BITS:0] rx_bit_pos;   // next bit position
	wire                           rx_clk;       // rx clock enable
	wire [`SPI_ADC_CHAR_LEN_BITS-1:0] len;          // data len in bits (minus one)

	assign len = 'h20; //Fix LEN since that won't be changing, unless you only want to sample one channel
	assign p_out = data;

	//LSB last
	assign rx_bit_pos =	(rx_negedge ? cnt : cnt - {{`SPI_ADC_CHAR_LEN_BITS{1'b0}},1'b1});

	assign last = !(|cnt);

	assign rx_clk = (rx_negedge ? neg_edge : pos_edge) && (!last || s_clk);

	// Character bit counter
	always @(posedge clk or posedge rst)
	begin
		if(rst)
			cnt <= #Tp {`SPI_ADC_CHAR_LEN_BITS+1{1'b0}};
		else
		begin
			if(tip)
				cnt <= #Tp pos_edge ? (cnt - {{`SPI_ADC_CHAR_LEN_BITS{1'b0}}, 1'b1}) : cnt;
			else
				cnt <= #Tp !(|len) ? {1'b1, {`SPI_ADC_CHAR_LEN_BITS{1'b0}}} : {1'b0, len};
		end
	end
  
	// Transfer in progress
	always @(posedge clk or posedge rst)
	begin
		if(rst)
			tip <= #Tp 1'b0;
		else if(go && ~tip)
			tip <= #Tp 1'b1;
		else if(tip && last && pos_edge)
			tip <= #Tp 1'b0;
	end

	// Receiving bits from the line
	always @(posedge clk or posedge rst)
	begin
		if (rst)
			data   <= #Tp {`SPI_ADC_CHAR{1'b0}};
		else if (tip)
			data[rx_bit_pos[`SPI_ADC_CHAR_LEN_BITS-1:0]] <= #Tp rx_clk ? s_in : data[rx_bit_pos[`SPI_ADC_CHAR_LEN_BITS-1:0]];
	end

endmodule


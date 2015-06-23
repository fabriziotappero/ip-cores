//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
//
// *File Name: ext_de1_sram.v
//
// *Module Description:
//                      openMSP430 interface with altera DE1's external async SRAM (256kwords x 16bits)
//
// *Author(s):
//              - Vadim Akimov,    lvd.mhm@gmail.com


module ext_de1_sram(

	input clk,

	// ram interface with openmsp430 core
	input [ADDR_WIDTH-1:0] ram_addr,
	input                  ram_cen,
	input            [1:0] ram_wen,
	input           [15:0] ram_din,
	output reg      [15:0] ram_dout,

	// DE1's sram signals
	inout      [15:0] SRAM_DQ,
	output reg [17:0] SRAM_ADDR,
	output reg SRAM_UB_N,
	output reg SRAM_LB_N,
	output reg SRAM_WE_N,
	output reg SRAM_CE_N,
	output reg SRAM_OE_N
);


	parameter ADDR_WIDTH = 9; // [8:0] - 512 words of 16 bits (1 kB) are only addressed by default



	// we assume SRAM is fast enough to accomodate 1-cycle access rate of openmsp430. Also it must be fast
	// enough to provide read data half cycle after read access begins. It is highly recommended to
	// set all SRAM_ signals as "Fast Output Register" in quartus. Also set Fast Enable Register for SRAM_DQ.
	// SRAM used in DE1 has zero setup and hold times for address and data in write cycle, so we can write data
	// in one clock cycle.
	//
	// we emulate ram_cen behavior by not changing read data when ram_cen=1 (last read data remain on ram_dout)


	reg [15:0] sram_dout;

	reg rnw; // =1 - read, =0 - write (Read-Not_Write)
	reg ena; // enable




	// address is always loaded from core
	always @(negedge clk)
	begin
		SRAM_ADDR <= { {18-ADDR_WIDTH{1'b0}}, ram_addr[ADDR_WIDTH-1:0] };
	end


	// some control signals
	always @(negedge clk)
	begin
		if( !ram_cen && !(&ram_wen) )
			rnw <= 1'b0;
		else
			rnw <= 1'b1;

		ena <= ~ram_cen;
	end


	// store data for write cycle
	always @(negedge clk)
		sram_dout <= ram_din;

	// bus control
	assign SRAM_DQ = rnw ? {16{1'bZ}} : sram_dout;

	// read cycle - data latching
	always @(posedge clk)
	begin
		if( ena && rnw )
			ram_dout <= SRAM_DQ;
	end


	// SRAM access signals
	always @(negedge clk)
	begin
		if( !ram_cen )
		begin
			if( &ram_wen[1:0] ) // read access
			begin
				SRAM_CE_N <= 1'b0;
				SRAM_OE_N <= 1'b0;
				SRAM_WE_N <= 1'b1;
				SRAM_UB_N <= 1'b0;
				SRAM_LB_N <= 1'b0;
			end
			else // !(&ram_wen[1:0]) - write access
			begin
				SRAM_CE_N <= 1'b0;
				SRAM_OE_N <= 1'b1;
				SRAM_WE_N <= 1'b0;
				SRAM_UB_N <= ram_wen[1];
				SRAM_LB_N <= ram_wen[0];
			end
		end
		else // ram_cen - idle
		begin
			SRAM_CE_N <= 1'b1;
			SRAM_OE_N <= 1'b1;
			SRAM_WE_N <= 1'b1;
			SRAM_UB_N <= 1'b1;
			SRAM_LB_N <= 1'b1;
		end
	end





endmodule




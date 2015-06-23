/*!
   btcminer -- BTCMiner for ZTEX USB-FPGA Modules: HDL code: double hash miner
   Copyright (C) 2011 ZTEX GmbH
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

module miner253 (clk, reset,  midstate, data,  golden_nonce, nonce2, hash2);

	parameter NONCE_OFFS = 32'd0;
	parameter NONCE_INCR = 32'd1;
	parameter NONCE2_OFFS = 32'd0;

	input clk, reset;
	input [255:0] midstate;
	input [95:0] data;
	output reg [31:0] golden_nonce, hash2, nonce2;

	
	reg [31:0] nonce;
	wire [255:0] hash;
	wire [31:0] hash2_w;
	reg reset_b1, reset_b2, reset_b3, is_golden_nonce;
	
	sha256_pipe130 p1 (
		.clk(clk),
		.state(midstate),
		.state2(midstate),
		.data({384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce, data}),
		.hash(hash)
	);

	sha256_pipe123 p2 (
		.clk(clk),
		.data({256'h0000010000000000000000000000000000000000000000000000000080000000, hash}),
		.hash(hash2_w)
	);

	always @ (posedge clk)
	begin
		if ( reset_b1 )
		begin
		    nonce <= 32'd254 + NONCE_OFFS;
		end else begin
		    nonce <= nonce + NONCE_INCR;
		end

		if ( reset_b2 )
		begin
		    nonce2 <= NONCE_OFFS + NONCE2_OFFS;
		end else begin
		    nonce2 <= nonce2 + NONCE_INCR;
		end

		if ( reset_b3 )
		begin
		    golden_nonce1 <= 32'd0;
		    golden_nonce2 <= 32'd0;
		end 
		else if ( is_golden_nonce ) 
    	        begin
	    	    golden_nonce1 <= nonce2;
	    	    golgen_nonce2 <= golden_nonce1;
		end

		reset_b1 <= reset;
		reset_b2 <= reset;
		reset_b3 <= reset;
		
		hash2 <= hash2_w;
		is_golden_nonce <= hash2_w == 32'ha41f32e7;
	end

endmodule

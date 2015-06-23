/*!
   btcminer -- BTCMiner for ZTEX USB-FPGA Modules: HDL code for ZTEX USB-FPGA Module 1.15b (one double hash pipe)
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

`define IDX(x) (((x)+1)*(32)-1):((x)*(32))

module miner130 (clk, reset,  midstate, data,  golden_nonce, nonce2, hash2);

	parameter NONCE_OFFS = 32'd0;
	parameter NONCE_INCR = 32'd1;

	input clk, reset;
	input [255:0] midstate;
	input [95:0] data;
	output reg [31:0] golden_nonce, nonce2, hash2;

	reg [31:0] nonce;
	wire [255:0] hash;
	
	reg [7:0] cnt = 8'd0;
	reg feedback = 1'b0;
	reg is_golden_nonce;
	reg feedback_b1, feedback_b2, feedback_b3, feedback_b4, feedback_b5, feedback_b6, reset_b1, reset_b2;

	reg [255:0] state_buf;
	reg [511:0] data_buf;
	
	sha256_pipe129 p (
		.clk(clk),
		.state(state_buf),
		.data(data_buf),
		.hash(hash)
	);

	always @ (posedge clk)
	begin
		if ( cnt == 8'd129 )
		begin
		    feedback <= ~feedback;
		    cnt <= 8'd0;
		end else begin
		    cnt <= cnt + 8'd1;
		end

		if ( feedback_b1 ) 
		begin
		    data_buf <= { 256'h0000010000000000000000000000000000000000000000000000000080000000, 
		                  hash[`IDX(7)] + midstate[`IDX(7)], 
		                  hash[`IDX(6)] + midstate[`IDX(6)], 
		                  hash[`IDX(5)] + midstate[`IDX(5)], 
		                  hash[`IDX(4)] + midstate[`IDX(4)], 
		                  hash[`IDX(3)] + midstate[`IDX(3)], 
		                  hash[`IDX(2)] + midstate[`IDX(2)], 
		                  hash[`IDX(1)] + midstate[`IDX(1)], 
		                  hash[`IDX(0)] + midstate[`IDX(0)]
		                };
		end else begin
		    data_buf <= {384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce, data};
		end

		if ( feedback_b2 ) 
		begin
		    state_buf <= 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
		end else begin
		    state_buf <= midstate;
		end

	        if ( reset_b1 )
	        begin
	    	    nonce <= NONCE_OFFS;
		end else if ( ! feedback_b3 ) 
		begin
		    nonce <= nonce + NONCE_INCR;
		end

		if ( reset_b2 )
		begin
		    golden_nonce <= 32'd0;
	    	end else if ( is_golden_nonce ) 
	    	begin
		    golden_nonce <= nonce2;
		end
		
		if ( ! feedback_b4 ) 
		begin
		    hash2 <= hash[255:224];
		end
		
		if ( ! feedback_b5 ) 
		begin
		    nonce2 <= nonce;
		end

		if ( ! feedback_b6 ) 
		begin
		    is_golden_nonce <= hash[255:224] == 32'ha41f32e7;
		end
		
		feedback_b1 <= feedback;
		feedback_b2 <= feedback;
		feedback_b3 <= feedback;
		feedback_b4 <= feedback;
		feedback_b5 <= feedback;
		feedback_b6 <= feedback;
		
		reset_b1 <= reset;
		reset_b2 <= reset;
	end

endmodule

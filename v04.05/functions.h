/*
--------------------------------------------------------------------------------
--
-- Module : functions.h
--
--------------------------------------------------------------------------------
--
-- Function:
-- - A bunch of functions for a stack processor.
-- 
-- Instantiates:
-- - Nothing.
--
--------------------------------------------------------------------------------
*/


	/*
	---------------
	-- functions --
	---------------
	*/


	// returns safe ceiling value of log2(n)
	// (for vector sizing we never want less than 1)
	// examples: 
	// clog2(0 thru 2)  = 1,
	// clog2(3 & 4)     = 2,
	// clog2(5 thru 8)  = 3,
	// clog2(9 thru 16) = 4, etc.
	function integer clog2;
	input integer in;
		begin
			clog2 = 1;
			while ( in > 2 ) begin
				in = ( in + 1 ) / 2;
				clog2 = clog2 + 1;
			end
		end
	endfunction


	// flip 32 bit value
	function [31:0] flip_32;
	input [31:0] in;
	integer i;
		begin
			for ( i=0; i<32; i=i+1 ) begin
				flip_32[i] = in[31-i];
			end
		end
	endfunction


	// return leading zero count of 32 bit value
	// examples:
	// lzc_32(32'b000...000) = 32
	// lzc_32(32'b000...001) = 31
	// lzc_32(32'b000...01x) = 30
	// ...
	// lzc_32(32'b001...xxx) = 2
	// lzc_32(32'b01x...xxx) = 1
	// lzc_32(32'b1xx...xxx) = 0
	function [5:0] lzc_32;
	input [31:0] in;
	integer j, hi_1, all_0;
		begin
			hi_1 = 31;
			all_0 = 1;
			// priority encoder (find MSB 1 position)
			for ( j = 0; j < 32; j = j + 1 ) begin 
				if ( in[j] ) begin
					hi_1 = j; 
					all_0 = 0;
				end
			end
		end
		// invert & concat to get zero count
		lzc_32 = { all_0[0], ~hi_1[4:0] };
	endfunction


	// returns the max of 2 integers
	function integer max_of_2;
	input integer a, b;
		begin
			if ( a > b ) begin
				max_of_2 = a;
			end else begin
				max_of_2 = b;
			end
		end
	endfunction


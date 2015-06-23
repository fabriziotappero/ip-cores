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
	input integer n;
		begin
			clog2 = 1;
			while ( n > 2 ) begin
				n = ( n + 1 ) / 2;
				clog2 = clog2 + 1;
			end
		end
	endfunction


	// returns the max of 2 values
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


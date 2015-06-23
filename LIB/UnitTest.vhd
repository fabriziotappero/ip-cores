--		UNIT TESTS
--
--	Purpose: This package gives procedures and function to make automated unit tests.


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package UnitTest is
	-- assertEqual: 
	-- This procedure tests if 2 values are equal, if they are not, it shows an error report
	procedure assertEqual(current, expected: in integer; resultName: in string := "Result"); 
	procedure assertEqual(current, expected: in std_logic; resultName: in string := "Result");
	procedure assertEqual(current, expected: in std_logic_vector; resultName: in string := "Result");
	
	-- assertOperationResult:
	-- This procedure tests if an operation is working under overflow conditions. If they are not, it reports an error.
	-- You can also specify an overflow bit to be verified automatically by the procedure to be at '1' when there is an
	-- overflow and at '0' when there is no overflow.
	procedure assertOperationResult(	actual, expected : in integer; opName: in string:= "operation"; overflowCond: boolean := false; overflowBit: std_logic := '-');
	procedure assertOperationResult(	actual, expected : in std_logic_vector; opName: in string:= "operation"; overflowCond: boolean := false; overflowBit: std_logic := '-');
end UnitTest;


package body UnitTest is
		
		procedure assertEqual(current, expected: in integer; resultName: in string := "Result") is
		begin
			assert current = expected
				report resultName &" is incorrect. Expected: " & integer'image(expected) & " Current: " & integer'image(current) 
				severity ERROR; 
		end procedure;
		
		procedure assertEqual(current, expected: in std_logic; resultName: in string := "Result") is
		begin
			assert current = expected
				report resultName &" is incorrect. Expected: " & std_logic'image(expected) & " Current: " & std_logic'image(current) 
				severity ERROR; 
		end procedure;

		procedure assertEqual(current, expected: in std_logic_vector; resultName: in string := "Result") is
		begin
			assertEqual(to_integer(unsigned(current)), to_integer(unsigned(expected)), resultName);
		end procedure;


		-- Automaticaly verifies that the result is correct, beeing given the boundaries of the calculator and that
		-- overflow bit is correctly set in both cases
		-- Arguments:
		-- 	actual, expected: Actual and expected results
		--		opName: Name of the operation
		--		overflowCond: Condition for an overflow, ignored by default
		--		overflowBit: Overflow bit set to 1 in case of overflow, no verification if set to '-' (default)
		procedure assertOperationResult(	actual, expected : in integer; opName: in string:= "operation"; 
													overflowCond: boolean := false; overflowBit: std_logic := '-') is
		begin
			if overflowCond then
				if overflowBit /= '-' then
					assertEqual(overflowBit, '1', "Overflow bit for " & opName & " with result " & integer'image(actual));
				end if;
			else
				if overflowBit /= '-' then
					assertEqual(overflowBit, '0', "Overflow bit for " & opName & " with result " & integer'image(actual));
				end if;
				assertEqual(actual, expected , opName & " result");
			end if;
		end procedure;
		
		procedure assertOperationResult(	actual, expected : in std_logic_vector; opName: in string:= "operation"; 
													overflowCond: boolean := false; overflowBit: std_logic := '-') is
		begin
			assertOperationResult(to_integer(unsigned(actual)), to_integer(unsigned(expected)), opName, overflowCond, overflowBit);
		end procedure;
end UnitTest;

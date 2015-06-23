--------------------------------------------------------------------------------
-- This file is part of the project  avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description: (Encryption implementation of Shiftrow) 
-- Shift Row rotates the Rows of the AES Block
-- This module takes the whole Rijdael state as input, extracts the rows,
-- shifts them and rebuilts the state.
--
-------------------------------------------------------------------------------
--
-- Author(s):
--	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
--
--------------------------------------------------------------------------------
-- Copyright (c) 2009, Authors and opencores.org
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--    * Neither the name of the organization nor the names of its contributors
--    may be used to endorse or promote products derived from this software without
--    specific prior written permission.
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
-- OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
-- THE POSSIBILITY OF SUCH DAMAGE
-------------------------------------------------------------------------------
-- version management:
-- $Author::                                         $
-- $Date::                                           $
-- $Revision::                                       $
-------------------------------------------------------------------------------

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

library avs_aes_lib;
use avs_aes_lib.avs_aes_pkg.all;


architecture fwd of Shiftrow is
		-- type of converting the columns into rows
	subtype ROW is BYTEARRAY(0 to 3);
	-- Row signal for easier handling of the shift operations
	signal row1_in	: Row;				-- 1st row
	signal row2_in	: Row;				-- 2nd row
	signal row3_in	: Row;				-- 3rd row
	signal row4_in	: Row;				-- 4th row
	-- single rows after shift operation
	-- row1 of the shifted state = row1 of unshifted state 
	signal row2_out : Row;				-- 2nd row
	signal row3_out : Row;				-- 3rd row
	signal row4_out : Row;				-- 4th row
	
begin  -- architecture arch1
	-- purpose: build the temorary internal signals for easier handling
	-- type	  : combinational
	-- inputs : state_in
	-- outputs: state_out
	build_in : process (state_in) is
	begin  -- process build_in
		-- state is a DWORD array with 16, 24 or 32 Byte in 4,6 or 8 columns
		-- thus we loop through the columns and slice the column in its bytes
		for col_cnt in 0 to (state_in'high) loop
			row1_in(col_cnt) <= state_in(col_cnt)(31 downto 24);
			row2_in(col_cnt) <= state_in(col_cnt)(23 downto 16);
			row3_in(col_cnt) <= state_in(col_cnt)(15 downto 8);
			row4_in(col_cnt) <= state_in(col_cnt)(7 downto 0);
		end loop;  -- col_cnt
	end process build_in;


	-- purpose: shift rows of Rindael state by 'shift_delta'
	-- type	  : combinational
	-- inputs : row(1 to 4)_in
	-- outputs: row(1 to 4)_out
	shifter : process (row2_in, row3_in, row4_in) is
	begin
		-- 1st row was never shifted so no reverse action needed
		-- rotate 2nd row left
		row2_out <= row2_in(row2_in'left+1 to row2_in'right) & row2_in(row2_in'left);
		--rotate by 2 left
		row3_out <= row3_in(row3_in'left+2 to row3_in'right) & row3_in(row3_in'left to row3_in'left+1);
		-- rotate by 3 left
		row4_out <= row4_in(row4_in'left+3 to row4_in'right) & row4_in(row4_in'left to row4_in'left+2);
	end process shifter;


	-- purpose: rebuilt the state form the shifted rows
	-- type	  : combinational
	-- inputs : row1_out, row2_out, row3_out, row4_out
	-- outputs: state_out
	rebuilt_state : process (row1_in, row2_out, row3_out, row4_out) is
	begin  -- process rebuilt_state 
		for col_cnt in 0 to state_out'high loop	 -- works because 15/4=3
			state_out(col_cnt)(31 downto 24) <= row1_in(col_cnt);
			state_out(col_cnt)(23 downto 16) <= row2_out(col_cnt);
			state_out(col_cnt)(15 downto 8)	 <= row3_out(col_cnt);
			state_out(col_cnt)(7 downto 0)	 <= row4_out(col_cnt);
		end loop;  -- col_cnt		
	end process rebuilt_state;

end architecture fwd;

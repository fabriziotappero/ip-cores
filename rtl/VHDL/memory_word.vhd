--------------------------------------------------------------------------------
-- This file is part of the project	 avs_aes
-- see: http://opencores.org/project,avs_aes
--
-- description: Register - nothing special
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
--	  * Redistributions of source code must retain the above copyright notice,
--	  this list of conditions and the following disclaimer.
--	  * Redistributions in binary form must reproduce the above copyright notice,
--	  this list of conditions and the following disclaimer in the documentation
--	  and/or other materials provided with the distribution.
--	  * Neither the name of the organization nor the names of its contributors
--	  may be used to endorse or promote products derived from this software without
--	  specific prior written permission.
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

library ieee;
use ieee.std_logic_1164.all;

entity memory_word is
	generic (
		IOwidth : POSITIVE := 1);		-- width in bits
	port (
		data_in	 : in  STD_LOGIC_VECTOR(IOwidth-1 downto 0);
		data_out : out STD_LOGIC_VECTOR(IOwidth-1 downto 0);
		res_n	 : in  STD_LOGIC;		-- system reset active low
		ena		 : in  STD_LOGIC;		-- enable write
		clk		 : in  STD_LOGIC);		-- system clock
end entity memory_word;

architecture arch1 of memory_word is
	signal data : STD_LOGIC_VECTOR(IOwidth-1 downto 0);	 -- storage
begin  -- architecture arch1

	-- purpose: write data to register at clock edge if enabled
	-- type	  : sequential
	-- inputs : clk, res_n, data_in,ena
	write_mem : process (clk, res_n) is
	begin  -- process write_mem
		if res_n = '0' then
			data <= (others => '0');
		elsif rising_edge(clk) then
			if ena = '1' then
				data <= data_in;
			end if;
		end if;
	end process write_mem;

	-- data can always be read
	data_out <= data;
	
	
end architecture arch1;

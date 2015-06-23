----==============================================================----
----                                                              ----
---- Filename: prenc_loops5.vhd                                   ----
---- Module description: Priority encoder unit. Obtains           ----
----        increment and reset decisions for the loop indices.   ----
----                                                              ----
---- Author: Nikolaos Kavvadias                                   ----
----         nkavv@physics.auth.gr                                ----
----                                                              ----
----                                                              ----
---- Part of the hwlu OPENCORES project generated automatically   ----
---- with the use of the "gen_priority_encoder" tool              ----
----                                                              ----
---- To Do:                                                       ----
----         Considered stable for the time being                 ----
----                                                              ----
---- Author: Nikolaos Kavvadias                                   ----
----         nkavv@physics.auth.gr                                ----
----                                                              ----
----==============================================================----
----                                                              ----
---- Copyright (C) 2004-2010   Nikolaos Kavvadias                 ----
----                    nkavv@uop.gr                              ----
----                    nkavv@physics.auth.gr                     ----
----                    nikolaos.kavvadias@gmail.com              ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from <http://www.opencores.org/lgpl.shtml>                   ----
----                                                              ----
----==============================================================----
--
-- CVS Revision History
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity priority_encoder is
	generic (
		NLP : integer := 5
	);
	port (
		flag           : in std_logic_vector(NLP-1 downto 0);
		task_loop5_end : in std_logic;
		incl           : out std_logic_vector(NLP-1 downto 0);
		reset_vct      : out std_logic_vector(NLP-1 downto 0);
		loops_end      : out std_logic
	);
end priority_encoder;

architecture rtl of priority_encoder is
begin

	-- Fully-nested loop structure with 5 loops
	-- From outer to inner: 4-> 3-> 2-> 1-> 0
	process (flag, task_loop5_end)
	begin
		--
		-- if loop4 is terminating:
		-- reset loops 4-0 to initial index
		if (flag(4 downto 0) = "11111") then
			incl <= "00000";
			reset_vct <= "11111";
			loops_end <= '1';
		-- else if loop3 is terminating:
		-- 1. increment loop4 index
		-- 2. reset loop3 to initial index
		elsif (flag(3 downto 0) = "1111") then
			incl <= "10000";
			reset_vct <= "01111";
			loops_end <= '0';
		-- else if loop2 is terminating:
		-- 1. increment loop3 index
		-- 2. reset loop2 to initial index
		elsif (flag(2 downto 0) = "111") then
			incl <= "01000";
			reset_vct <= "00111";
			loops_end <= '0';
		-- else if loop1 is terminating:
		-- 1. increment loop2 index
		-- 2. reset loop1 to initial index
		elsif (flag(1 downto 0) = "11") then
			incl <= "00100";
			reset_vct <= "00011";
			loops_end <= '0';
		-- else if loop0 is terminating:
		-- 1. increment loop1 index
		-- 2. reset loop0 to initial index
		elsif (flag(0 downto 0) = "1") then
			incl <= "00010";
			reset_vct <= "00001";
			loops_end <= '0';
		-- else increment loop-1 index
		else
			reset_vct <= "00000";
			loops_end <= '0';
			if (task_loop5_end = '1') then
				incl <= "00001";
			else
				incl <= "00000";
			end if;
		end if;
	end process;

end rtl;

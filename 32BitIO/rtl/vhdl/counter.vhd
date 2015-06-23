-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     A little modified counter construction - it additionally  ----
---- control another one signal. It contains "built-in" reset if   ----
---- it is not counting.                                           ----
---- To Do:                                                        ----
----                                                               ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2013 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
	generic (
		w_2 : integer := 2;
		w_5 : integer := 5
	);
	port (
		clk, reset, cnt_res : in std_logic;
		info : out std_logic_vector (w_2-1 downto 0);
		num : out std_logic_vector (w_5-1 downto 0)
	);
end counter;

architecture Behavioral of counter is
	begin
		licznik : process (clk, reset)
			variable cnt : unsigned(w_5-1 downto 0);
			begin
				if (reset = '1') then
					cnt := (others => '0');
				elsif (clk'Event and clk = '1') then
					if (cnt_res = '1') then
						cnt := cnt + 1;
						if (std_logic_vector(cnt) = "00001") then
							info <= "01";
						elsif (std_logic_vector(cnt) = "00000") then
							info <= "00";
						else
							info <= "11";
						end if;
					else 
						cnt := (others => '0');
					end if;
				end if;
				num <= std_logic_vector(cnt);
			end process licznik;
	end Behavioral;


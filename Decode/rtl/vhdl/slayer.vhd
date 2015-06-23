-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Substitution layer of Present cipher. Simple logic.       ----
---- For more information see                                      ----
---- http://homes.esat.kuleuven.be/~abogdano/papers/               ----
---- present_ches07.pdf                                            ----
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

entity slayer is
	generic (
		w_4 : integer := 4
	);
	port (
		input : in std_logic_vector(w_4-1 downto 0);
		output : out std_logic_vector(w_4-1 downto 0)
	);
end slayer;

architecture Behavioral of slayer is

	begin
		output <= x"C" when input = x"0" else
					 x"5" when input = x"1" else
					 x"6" when input = x"2" else
					 x"B" when input = x"3" else
					 x"9" when input = x"4" else
					 x"0" when input = x"5" else 
					 x"A" when input = x"6" else
					 x"D" when input = x"7" else
					 x"3" when input = x"8" else
					 x"E" when input = x"9" else 
					 x"F" when input = x"A" else
					 x"8" when input = x"B" else 
					 x"4" when input = x"C" else
					 x"7" when input = x"D" else 
					 x"1" when input = x"E" else
					 x"2" when input = x"F" else
					 "ZZZZ";
	end Behavioral;
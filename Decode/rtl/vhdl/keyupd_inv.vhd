-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Inverse Key update module for present cipher decoding     ----
---- it is 'signal mixing' made by rotation right by 61 bits,      ---- 
---- using one s-box, and output of the counter. Note, that order  ----
---- of this operatins must be inverse in comparison with key_upd. ----
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

entity keyupd_inv is
	generic(
		w_80: integer := 80;
		w_5 : integer := 5;
		w_4 : integer := 4);
	port(
		key : in std_logic_vector(w_80-1 downto 0);
		num : in std_logic_vector(w_5-1 downto 0);
		keyout : out std_logic_vector(w_80-1 downto 0)
	);
end keyupd_inv;

architecture Behavioral of keyupd_inv is

	component slayer_inv is
		generic(w_4: integer := 4);
		port(
			input : in std_logic_vector(w_4-1 downto 0);
			output : out std_logic_vector(w_4-1 downto 0)
		);
	end component;

	signal changed : std_logic_vector(w_4-1 downto 0);
	signal changin : std_logic_vector(w_4-1 downto 0);
	signal keytemp : std_logic_vector(w_80-1 downto 0);

	begin
		s1: slayer_inv port map(input => changin, output => changed);
		changin <= key(79 downto 76);
		keytemp(79 downto 76)<= changed;
		keytemp(75 downto 20) <= key(75 downto 20);
		keytemp(19 downto 15)<= key(19 downto 15) xor num;
		keytemp(14 downto 0) <= key(14 downto 0);
		keyout <= keytemp(60 downto 0) & keytemp(79 downto 61);
	end Behavioral;
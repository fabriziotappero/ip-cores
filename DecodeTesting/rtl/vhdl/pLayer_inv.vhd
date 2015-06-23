-----------------------------------------------------------------------
----                                                               ----
---- Present - a lightweight block cipher project                  ----
----                                                               ----
---- This file is part of the Present - a lightweight block        ----
---- cipher project                                                ----
---- http://www.http://opencores.org/project,present               ----
----                                                               ----
---- Description:                                                  ----
----     Permutation layer of Present decoder. Simple signal       ----
---- mixing, but in inverse way as cipher. For more information see----
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

entity pLayer_inv is
	generic(w_64 : integer := 64);
	port (
		input : in std_logic_vector(w_64-1 downto 0);
		output : out std_logic_vector(w_64-1 downto 0)
	);
end pLayer_inv;

architecture Behavioral of pLayer_inv is
begin
			output(0) <= input(0);
			output(1) <= input(16);
			output(2) <= input(32);
			output(3) <= input(48);
			output(4) <= input(1);
			output(5) <= input(17);
			output(6) <= input(33);
			output(7) <= input(49);
			output(8) <= input(2);
			output(9) <= input(18);
			output(10) <= input(34);
			output(11) <= input(50);
			output(12) <= input(3);
			output(13) <= input(19);
			output(14) <= input(35);
			output(15) <= input(51);
			output(16) <= input(4);
			output(17) <= input(20);
			output(18) <= input(36);
			output(19) <= input(52);
			output(20) <= input(5);
			output(21) <= input(21);
			output(22) <= input(37);
			output(23) <= input(53);
			output(24) <= input(6);
			output(25) <= input(22);
			output(26) <= input(38);
			output(27) <= input(54);
			output(28) <= input(7);
			output(29) <= input(23);
			output(30) <= input(39);
			output(31) <= input(55);
			output(32) <= input(8);
			output(33) <= input(24);
			output(34) <= input(40);
			output(35) <= input(56);
			output(36) <= input(9);
			output(37) <= input(25);
			output(38) <= input(41);
			output(39) <= input(57);
			output(40) <= input(10);
			output(41) <= input(26);
			output(42) <= input(42);
			output(43) <= input(58);
			output(44) <= input(11);
			output(45) <= input(27);
			output(46) <= input(43);
			output(47) <= input(59);
			output(48) <= input(12);
			output(49) <= input(28);
			output(50) <= input(44);
			output(51) <= input(60);
			output(52) <= input(13);
			output(53) <= input(29);
			output(54) <= input(45);
			output(55) <= input(61);
			output(56) <= input(14);
			output(57) <= input(30);
			output(58) <= input(46);
			output(59) <= input(62);
			output(60) <= input(15);
			output(61) <= input(31);
			output(62) <= input(47);
			output(63) <= input(63);
end Behavioral;
----------------------------------------------------------------------
----                                                              ----
---- Pipelined Aes IP Core                                        ----
----                                                              ----
---- This file is part of the Pipelined AES project               ----
---- http://www.opencores.org/cores/aes_pipe/                     ----
----                                                              ----
---- Description                                                  ----
---- Implementation of AES IP core according to                   ----
---- FIPS PUB 197 specification document.                         ----
----                                                              ----
---- To Do:                                                       ----
----   -                                                          ----
----                                                              ----
---- Author:                                                      ----
----      - Subhasis Das, subhasis256@gmail.com                   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains ----
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
---- PURPOSE. See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
------------------------------------------------------
-- Project: AESFast
-- Author: Subhasis
-- Last Modified: 25/03/10
-- Email: subhasis256@gmail.com
------------------------------------------------------
--
-- Description: The Sbox and Shiftrows step
-- Ports:
--			clk: System Clock
--			blockin: Input state block
--			fc3: See keysched1 for explanation
--			c0: See keysched1 for explanation
--			c1: See keysched1 for explanation
--			c2: See keysched1 for explanation
--			c3: See keysched1 for explanation
--			nextkey: Roundkey for next round
--			blockout: output state block
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity sboxshr is
port(
	clk: in std_logic;
	rst: in std_logic;
	blockin: in datablock;
	fc3: in blockcol;
	c0: in blockcol;
	c1: in blockcol;
	c2: in blockcol;
	c3: in blockcol;
	nextkey: out datablock;
	blockout: out datablock
	);
end sboxshr;

architecture rtl of sboxshr is
component sbox is
port(
	clk: in std_logic;
	rst: in std_logic;
	bytein: in std_logic_vector(7 downto 0);
	byteout: out std_logic_vector(7 downto 0)
	);
end component;
begin
	-- The sbox, the output going to the appropriate state byte after shiftrows
	g0: for i in 3 downto 0 generate
		g1: for j in 3 downto 0 generate
			sub: sbox port map(
							  clk => clk,
							  rst => rst,
							  bytein => blockin(i,j),
							  byteout => blockout(i,(j-i) mod 4)
							  );
		end generate;
	end generate;
	process(clk,rst)
	begin
		if(rst = '1') then
			nextkey <= zero_data;
		elsif(rising_edge(clk)) then
			-- col0 of nextkey = fc3 xor col0
			-- col1 of nextkey = fc3 xor col0 xor col1
			-- col2 of nextkey = fc3 xor col0 xor col1 xor col2
			-- col3 of nextkey = fc3 xor col0 xor col1 xor col2 xor col3
			genkey: for j in 3 downto 0 loop
				nextkey(j, 0) <= fc3(j) xor c0(j);
				nextkey(j, 1) <= fc3(j) xor c1(j);
				nextkey(j, 2) <= fc3(j) xor c2(j);
				nextkey(j, 3) <= fc3(j) xor c3(j);
			end loop;
		end if;
	end process;
end rtl;

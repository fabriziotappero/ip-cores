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
-- Description: The AddKey step
-- Ports:
--			clk: System Clock
--			roundkey: The RoundKey block for this round
--			datain: Input State block
--			rcon: The rcon byte corresponding to the current stage
--			dataout: datain xor roundkey
--			fc3: See keysched1 for explanation
--			c0: See keysched1 for explanation
--			c1: See keysched1 for explanation
--			c2: See keysched1 for explanation
--			c3: See keysched1 for explanation
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity addkey is
port(
	clk: in std_logic;
	rst: in std_logic;
	roundkey: in datablock;
	datain: in datablock;
	rcon: in std_logic_vector(7 downto 0);
	dataout: out datablock;
	fc3: out blockcol;
	c0: out blockcol;
	c1: out blockcol;
	c2: out blockcol;
	c3: out blockcol
	);
end addkey;

architecture rtl of addkey is
component keysched1 is
port(
	clk: in std_logic;
	rst: in std_logic;
	roundkey: in datablock;
	rcon: in std_logic_vector(7 downto 0);
	fc3: out blockcol;
	c0: out blockcol;
	c1: out blockcol;
	c2: out blockcol;
	c3: out blockcol
	);
end component;
signal added: datablock;
begin
	step1: keysched1 port map(
							 clk => clk,
							 rst => rst,
							 roundkey => roundkey,
							 rcon => rcon,
							 fc3 => fc3,
							 c0 => c0,
							 c1 => c1,
							 c2 => c2,
							 c3 => c3
							 );
	g0: for i in 3 downto 0 generate
		g1: for j in 3 downto 0 generate
			added(i,j) <= datain(i,j) xor roundkey(i,j);
		end generate;
	end generate;
	
	process(clk,rst)
	begin
		if(rst = '1') then
			dataout <= zero_data;
		elsif(rising_edge(clk)) then
			dataout <= added;
		end if;
	end process;
end rtl;

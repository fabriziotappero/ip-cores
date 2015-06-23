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
-- Description: The Overall Core
-- Ports:
--			clk_i: System Clock
--			plaintext_i: Input plaintext blocks
--			keyblock_i: Input keyblock
--			ciphertext_o: Output Cipher Block
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity aes_top is
port(
	clk_i: in std_logic;
	rst_i: in std_logic;
	plaintext_i: in datablock;
	keyblock_i: in datablock;
	ciphertext_o: out datablock
	);
end aes_top;

architecture rtl of aes_top is
signal fc3, c0, c1, c2, c3: colnet(9 downto 0);
signal textnet_a_s, textnet_s_m, textnet_m_a: datanet(9 downto 0);
signal key_m, key_s: datanet(9 downto 0);
signal textnet_s_a: datablock;

component sboxshr is
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
end component;
component colmix is
port(
	clk: in std_logic;
	rst: in std_logic;
	datain: in datablock;
	inrkey: in datablock;
	outrkey: out datablock;
	dataout: out datablock
	);
end component;
component addkey is
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
end component;
begin
	key_m(0) <= keyblock_i;
	textnet_m_a(0) <= plaintext_i;
	-------------------------------------------------------
	-- Instead of the conventional order of
	-- Addkey -> (Sbox -> Mixcol -> Addkey) ... 9 times
	-- -> Sbox -> Addkey, we code the design as
	-- (Addkey -> Sbox -> Mixcol) ... 9 times -> Addkey ->
	-- Sbox -> Addkey
	-------------------------------------------------------
	proc: for i in 8 downto 0 generate
		add: addkey port map(
							clk => clk_i,
							rst => rst_i,
							roundkey => key_m(i),
							datain => textnet_m_a(i),
							rcon => rcon(i),
							dataout => textnet_a_s(i),
							fc3 => fc3(i),
							c0 => c0(i),
							c1 => c1(i),
							c2 => c2(i),
							c3 => c3(i)
							);
		sbox: sboxshr port map(
							  clk => clk_i,
							  rst => rst_i,
							  blockin => textnet_a_s(i),
							  fc3 => fc3(i),
							  c0 => c0(i),
							  c1 => c1(i),
							  c2 => c2(i),
							  c3 => c3(i),
							  nextkey => key_s(i),
							  blockout => textnet_s_m(i)
							  );
		mix: colmix port map(
							clk => clk_i,
							rst => rst_i,
							datain => textnet_s_m(i),
							inrkey => key_s(i),
							outrkey => key_m(i+1),
							dataout => textnet_m_a(i+1)
							);
	end generate;
	add_f_1: addkey port map(
							clk => clk_i,
							rst => rst_i,
							roundkey => key_m(9),
							datain => textnet_m_a(9),
							rcon => rcon(9),
							dataout => textnet_a_s(9),
							fc3 => fc3(9),
							c0 => c0(9),
							c1 => c1(9),
							c2 => c2(9),
							c3 => c3(9)
							);
	sbox_f_1: sboxshr port map(
							  clk => clk_i,
							  rst => rst_i,
							  blockin => textnet_a_s(9),
							  fc3 => fc3(9),
							  c0 => c0(9),
							  c1 => c1(9),
							  c2 => c2(9),
							  c3 => c3(9),
							  nextkey => key_s(9),
							  blockout => textnet_s_a
							  );
	add_f: addkey port map(
						  clk => clk_i,
						  rst => rst_i,
						  roundkey => key_s(9),
						  datain => textnet_s_a,
						  rcon => X"00",
						  dataout => ciphertext_o
						  );
end rtl;

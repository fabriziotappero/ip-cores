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
-- Description: The MixColumns operation
-- Ports:
--			clk: System Clock
--			in0: Byte 0 of a column
--			in1: Byte 1 of a column
--			in2: Byte 2 of a column
--			in3: Byte 3 of a column
--			out0: Byte 0 of output column
--			out1: Byte 1 of output column
--			out2: Byte 2 of output column
--			out3: Byte 3 of output column
--			keyblock: Input Key Blocks three at a time
--			ciphertext: Output Cipher Block
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity mixcol is
port(
	clk: in std_logic;
	rst: in std_logic;
	in0: in std_logic_vector(7 downto 0);
	in1: in std_logic_vector(7 downto 0);
	in2: in std_logic_vector(7 downto 0);
	in3: in std_logic_vector(7 downto 0);
	out0: out std_logic_vector(7 downto 0);
	out1: out std_logic_vector(7 downto 0);
	out2: out std_logic_vector(7 downto 0);
	out3: out std_logic_vector(7 downto 0)
	);
end mixcol;

architecture rtl of mixcol is
signal d0, d1, d2, d3: std_logic_vector(7 downto 0);
signal t0, t1, t2, t3: std_logic_vector(7 downto 0);
signal sh0, sh1, sh2, sh3: std_logic_vector(7 downto 0);
signal xored: std_logic_vector(7 downto 0);

begin
	sh0(0) <= '0';
	sh1(0) <= '0';
	sh2(0) <= '0';
	sh3(0) <= '0';
	-----------------------------------------------------
	-- In GF(2^8) 2*x = (x << 1) xor 0x1b if x(7) = '1'
	--                  (x << 1) else
	-- This just left shifts each byte by 1.
	shift: for i in 7 downto 1 generate
		sh0(i) <= in0(i-1);
		sh1(i) <= in1(i-1);
		sh2(i) <= in2(i-1);
		sh3(i) <= in3(i-1);
	end generate;
	-- Conditional XOR'ing
	d0 <= sh0 xor X"1b" when in0(7) = '1' else
	sh0;
	d1 <= sh1 xor X"1b" when in1(7) = '1' else
	sh1;
	d2 <= sh2 xor X"1b" when in2(7) = '1' else
	sh2;
	d3 <= sh3 xor X"1b" when in3(7) = '1' else
	sh3;
	
	----------------------------------------------------
	-- 3*x = 2*x xor x
	----------------------------------------------------
	t0 <= d0 xor in0;
	t1 <= d1 xor in1;
	t2 <= d2 xor in2;
	t3 <= d3 xor in3;
	
	xored <= in0 xor in1 xor in2 xor in3;
	process(clk,rst)
	begin
		if(rst = '1') then
			out0 <= X"00";
			out1 <= X"00";
			out2 <= X"00";
			out3 <= X"00";
		elsif(rising_edge(clk)) then
			out0 <= xored xor t0 xor d1;
			out1 <= xored xor t1 xor d2;
			out2 <= xored xor t2 xor d3;
			out3 <= xored xor t3 xor d0;
		end if;
	end process;
end rtl;

--
-- Xilinx Block RAM, 8 bit wide and variable size (Min. 512 bytes)
--
-- Version : 0247
--
-- Copyright (c) 2002 Daniel Wallner (jesus@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--
--	0240 : Initial release
--
--	0242 : Changed RAMB4_S8 to map by name
--
--	0247 : Added RAMB4_S8 component declaration
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SSRAM is
	generic(
		AddrWidth	: integer := 11;
		DataWidth	: integer := 8
	);
	port(
		Clk			: in std_logic;
		CE_n		: in std_logic;
		WE_n		: in std_logic;
		A			: in std_logic_vector(AddrWidth - 1 downto 0);
		DIn			: in std_logic_vector(DataWidth - 1 downto 0);
		DOut		: out std_logic_vector(DataWidth - 1 downto 0)
	);
end SSRAM;

architecture rtl of SSRAM is

	component RAMB4_S8
		port(
			DO     : out std_logic_vector(7 downto 0);
			ADDR   : in std_logic_vector(8 downto 0);
			CLK    : in std_ulogic;
			DI     : in std_logic_vector(7 downto 0);
			EN     : in std_ulogic;
			RST    : in std_ulogic;
			WE     : in std_ulogic);
	end component;

	constant RAMs : integer := (2 ** AddrWidth) / 512;

	type bRAMOut_a is array(0 to RAMs - 1) of std_logic_vector(7 downto 0);

	signal bRAMOut : bRAMOut_a;
	signal biA_r : integer;
	signal A_r : unsigned(A'left downto 0);
--	signal A_i : std_logic_vector(8 downto 0);
	signal WEA : std_logic_vector(RAMs - 1 downto 0);

begin

	process (Clk)
	begin
		if Clk'event and Clk = '1' then
			A_r <= unsigned(A);
		end if;
	end process;

	biA_r <= to_integer(A_r(A'left downto 9));
--	A_i <= std_logic_vector(A_r(8 downto 0)) when (CE_n nor WE_n) = '1' else A(8 downto 0);

	bG1: for I in 0 to RAMs - 1 generate
	begin
		WEA(I) <= '1' when (CE_n nor WE_n) = '1' and biA_r = I else '0';
		BSSRAM : RAMB4_S8
			port map(
				DI => DIn,
				EN => '1',
				WE => WEA(I),
				RST => '0',
				CLK => Clk,
				ADDR => A,
				DO => bRAMOut(I));
	end generate;

	process (biA_r, bRAMOut)
	begin
		DOut <= bRAMOut(0);
		for I in 1 to RAMs - 1 loop
			if biA_r = I then
				DOut <= bRAMOut(I);
			end if;
		end loop;
	end process;

end;

--
--  This file is part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2003, Martin Schoeberl (martin@jopdesign.com)
--  Copyright (C) 2003, Ed Anuff
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--	xram_xc2s_xcv.vhd
--
--	internal memory for JOP3
--	Version for Xilinx Spartan II/IIe and Virtex Families
--
--	Changes:
--    2003-12-29  EA - modified for Xilinx ISE to use Block SelectRAM+
--
--

Library IEEE ;
use IEEE.std_logic_1164.all ;
use IEEE.std_logic_arith.all ;
use IEEE.std_logic_unsigned.all ;
library unisim; 
use unisim.vcomponents.all; 

entity ram is
generic (width : integer := 32; addr_width : integer := 8);
port (
        reset           : in std_logic;
	data		: in std_logic_vector(width-1 downto 0);
	wraddress	: in std_logic_vector(addr_width-1 downto 0);
	rdaddress	: in std_logic_vector(addr_width-1 downto 0);
	wren		: in std_logic;
	clock		: in std_logic;

	q			: out std_logic_vector(width-1 downto 0)
);
end ram ;

--
--	registered and delayed wraddress, wren
--	registered din
--	registered rdaddress
--	unregistered dout
--
--	with normal clock on wrclock:
--		=> read during write on same address!!! (ok in ACEX)
--	for Cyclone use not clock for wrclock, but works also on ACEX
--
architecture rtl of ram is

	signal wraddr_dly	: std_logic_vector(addr_width-1 downto 0);
	signal wren_dly		: std_logic;

	COMPONENT xram_block
	PORT(
		a_rst : IN std_logic;
		a_clk : IN std_logic;
		a_en : IN std_logic;
		a_wr : IN std_logic;
		a_addr : IN std_logic_vector(7 downto 0);
		a_din : IN std_logic_vector(31 downto 0);
		b_rst : IN std_logic;
		b_clk : IN std_logic;
		b_en : IN std_logic;
		b_wr : IN std_logic;
		b_addr : IN std_logic_vector(7 downto 0);
		b_din : IN std_logic_vector(31 downto 0);          
		a_dout : OUT std_logic_vector(31 downto 0);
		b_dout : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;


begin

--
--	delay wr addr and ena because of registerd indata
--
	process(clock) begin

		if rising_edge(clock) then
			wraddr_dly <= wraddress;
			wren_dly <= wren;
		end if;
	end process;

	cmp_xram_block: xram_block PORT MAP(
		a_rst => '0',
		a_clk => not clock,
		a_en => '1',
		a_wr => wren_dly,
		a_addr => wraddr_dly,
		a_din => data,
		a_dout => open,
		b_rst => '0',
		b_clk => clock,
		b_en => '1',
		b_wr => '0',
		b_addr => rdaddress,
		b_din => X"00000000",
		b_dout => q
	);

end rtl;

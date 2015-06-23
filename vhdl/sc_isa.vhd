--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
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
--	sc_isa.vhd
--
--	ISA bus for ethernet chip
--	
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--	resources on Cyclone
--
--		xx LCs, max xx MHz
--
--
--	2005-12-28	changed for SimpCon
--
--	todo:
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sc_isa is
generic (addr_bits : integer);

port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0);

-- ISA bus

	isa_d		: inout std_logic_vector(7 downto 0);
	isa_a		: out std_logic_vector(4 downto 0);
	isa_reset	: out std_logic;
	isa_nior	: out std_logic;
	isa_niow	: out std_logic
);
end sc_isa;

architecture rtl of sc_isa is

--
--	signal for isa data bus
--
	signal isa_data			: std_logic_vector(7 downto 0);
	signal isa_dir			: std_logic;		-- direction of isa_d ('1' means driving out)

begin

	rdy_cnt <= "00";	-- no wait states

--
--	The registered MUX is all we need for a SimpCon read.
--
process(clk, reset)
begin

	if (reset='1') then
		rd_data <= (others => '0');
	elsif rising_edge(clk) then

		if rd='1' then
			-- no address decoding
			rd_data <= std_logic_vector(to_unsigned(0, 24)) & isa_d;
		end if;
	end if;

end process;


--
--	SimpCon write is very simple
--
process(clk, reset)

begin

	if (reset='1') then

		isa_data <= (others => '0');
		isa_a <= (others => '0');
		isa_reset <= '0';
		isa_nior <= '1';
		isa_niow <= '1';
		isa_dir <= '0';

	elsif rising_edge(clk) then

		if wr='1' then
			if address(0)='0' then
				isa_a <= wr_data(4 downto 0);
				isa_reset <= wr_data(5);
				isa_nior <= not wr_data(6);
				isa_niow <= not wr_data(7);
				isa_dir <= wr_data(8);
			else
				isa_data <= wr_data(7 downto 0);
			end if;
		end if;

	end if;
end process;

--
--	isa data bus
--
	isa_d <= isa_data when isa_dir='1' else "ZZZZZZZZ";

end rtl;

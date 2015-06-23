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
--	sc2ahbsl.vhd
--
--	SimpCon to AMBA bridge
--
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--	2007-03-16	first version
--

Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sc_pack.all;

library grlib;
use grlib.amba.all;
--use grlib.tech.all;
library gaisler;
use gaisler.memctrl.all;
--use gaisler.pads.all; -- used for I/O pads
--use gaisler.misc.all;

entity sc2ahbsl is

port (

	clk, reset	: in std_logic;

--	SimpCon memory interface
	scmo		: in sc_mem_out_type;
	scmi		: out sc_in_type;

-- AMBA slave interface
    ahbsi  		: out  ahb_slv_in_type;
    ahbso  		: in ahb_slv_out_type
);
end sc2ahbsl;

architecture rtl of sc2ahbsl is

	type state_type		is (idl, rd, rdw, wr, wrw);
	signal state 		: state_type;
	signal next_state	: state_type;

	signal reg_wr_data	: std_logic_vector(31 downto 0);
	signal reg_rd_data	: std_logic_vector(31 downto 0);

begin

--
--	some defaults
--
	ahbsi.hsel(1 to NAHBSLV-1) <= (others => '0');	-- we use only slave 0
	ahbsi.hsel(0) <= scmo.rd or scmo.wr;			-- slave select
	-- do we need to store the addrsss in a register?
	ahbsi.haddr(SC_ADDR_SIZE-1+2 downto 2) <= scmo.address;	-- address bus (byte)
	ahbsi.haddr(1 downto 0) <= (others => '0');
	ahbsi.haddr(31 downto SC_ADDR_SIZE+2) <= (others => '0');
	ahbsi.hwrite <= scmo.wr;						-- read/write
	ahbsi.htrans <= HTRANS_NONSEQ;					-- transfer type
	ahbsi.hsize <= "010";							-- transfer size 32 bits
	ahbsi.hburst <= HBURST_SINGLE;					-- burst type
	ahbsi.hwdata <= reg_wr_data;					-- write data bus
	ahbsi.hprot <= "0000";		-- ? protection control
	ahbsi.hready <= '1';		-- ? transer done 
	ahbsi.hmaster <= "0000";						-- current master
	ahbsi.hmastlock <= '0';		-- locked access
	ahbsi.hmbsel(0) <= '0';							-- memory bank select
	ahbsi.hmbsel(1) <= '1';							-- second is SRAM
	ahbsi.hmbsel(2 to NAHBAMR-1) <= (others => '0');
	ahbsi.hcache <= '1';							-- cacheable
	ahbsi.hirq <= (others => '0');					-- interrupt result bus




--
--	Register write data
--
process(clk, reset)
begin
	if reset='1' then

		reg_wr_data <= (others => '0');

	elsif rising_edge(clk) then

		if scmo.wr='1' then
			reg_wr_data <= scmo.wr_data;
		end if;

	end if;
end process;

--
--	next state logic
--
process(state, scmo, ahbso.hready)

begin

	next_state <= state;

	case state is

		when idl =>
			if scmo.rd='1' then
				next_state <= rdw;
			elsif scmo.wr='1' then
				next_state <= wrw;
			end if;

		when rdw =>
			if ahbso.hready='1' then
				next_state <= rd;
			end if;

		when rd =>
			next_state <= idl;
			if scmo.rd='1' then
				next_state <= rdw;
			elsif scmo.wr='1' then
				next_state <= wrw;
			end if;

		when wrw =>
			if ahbso.hready='1' then
				next_state <= wr;
			end if;

		when wr =>
			next_state <= idl;
			if scmo.rd='1' then
				next_state <= rdw;
			elsif scmo.wr='1' then
				next_state <= wrw;
			end if;


	end case;
				
end process;

--
--	state machine register
--	and output register
--
process(clk, reset)

begin
	if (reset='1') then
		state <= idl;
		reg_rd_data <= (others => '0');

	elsif rising_edge(clk) then

		state <= next_state;

		case next_state is

			when idl =>

			when rdw =>

			when rd =>
				reg_rd_data <= ahbso.hrdata;

			when wrw =>

			when wr =>

		end case;
					
	end if;
end process;

--
--	combinatorial state machine output
--
process(next_state)

begin

	scmi.rdy_cnt <= "00";
	scmi.rd_data <= reg_rd_data;

	case next_state is

		when idl =>

		when rdw =>
			scmi.rdy_cnt <= "11";

		when rd =>
			scmi.rd_data <= ahbso.hrdata;

		when wrw =>
			scmi.rdy_cnt <= "11";

		when wr =>

	end case;

end process;

end rtl;

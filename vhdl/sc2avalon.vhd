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
--	sc2avalon.vhd
--
--	SimpCon to Avalon bridge
--
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--	2006-08-10	first version
--

Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity sc2avalon is
generic (addr_bits : integer);

port (

	clk, reset	: in std_logic;

-- SimpCon interface

	sc_address		: in std_logic_vector(addr_bits-1 downto 0);
	sc_wr_data		: in std_logic_vector(31 downto 0);
	sc_rd, sc_wr	: in std_logic;
	sc_rd_data		: out std_logic_vector(31 downto 0);
	sc_rdy_cnt		: out unsigned(1 downto 0);

-- Avalon interface

	av_address		: out std_logic_vector(addr_bits-1+2 downto 0);
	av_writedata	: out std_logic_vector(31 downto 0);
	av_byteenable	: out std_logic_vector(3 downto 0);
	av_readdata		: in std_logic_vector(31 downto 0);
	av_read			: out std_logic;
	av_write		: out std_logic;
	av_waitrequest	: in std_logic

);
end sc2avalon;

architecture rtl of sc2avalon is

	type state_type		is (idl, rd, rdw, wr, wrw);
	signal state 		: state_type;
	signal next_state	: state_type;

	signal reg_addr		: std_logic_vector(addr_bits-1 downto 0);
	signal reg_wr_data	: std_logic_vector(31 downto 0);
	signal reg_rd_data	: std_logic_vector(31 downto 0);

	signal reg_rd		: std_logic;
	signal reg_wr		: std_logic;

begin

	av_byteenable <= "1111"; 			-- we use only 32 bit transfers
	av_address(1 downto 0) <= "00";

	sc_rd_data <= reg_rd_data;


--
--	Register memory address, write data and read data
--
process(clk, reset)
begin
	if reset='1' then

		reg_addr <= (others => '0');
		reg_wr_data <= (others => '0');

	elsif rising_edge(clk) then

		if sc_rd='1' or sc_wr='1' then
			reg_addr <= sc_address;
		end if;
		if sc_wr='1' then
			reg_wr_data <= sc_wr_data;
		end if;

	end if;
end process;


--
--	The address MUX slightly violates the Avalon
--	specification. The address changes from the sc_address
--	to the registerd address in the second cycle. However,
--	as both registers contain the same value there should be
--	no real glitch. For synchronous peripherals this is not
--	an issue. For asynchronous peripherals (SRAM) the possible
--	glitch should be short enough to be not seen on the output
--	pins.
--
process(sc_rd, sc_wr, sc_address, reg_addr)
begin
	if sc_rd='1' or sc_wr='1' then
		av_address(addr_bits-1+2 downto 2) <= sc_address;
	else
		av_address(addr_bits-1+2 downto 2) <= reg_addr;
	end if;
end process;

--	Same game for the write data and write/read control
process(sc_wr, sc_wr_data, reg_wr_data)
begin
	if sc_wr='1' then
		av_writedata <= sc_wr_data;
	else
		av_writedata <= reg_wr_data;
	end if;
end process;
		
	av_write <= sc_wr or reg_wr;
	av_read <= sc_rd or reg_rd;



--
--	next state logic
--
--	At the moment we do not support back to back read
--	or write. We don't need it for JOP, right?
--	If needed just copy the idl code to rd and wr.
--
process(state, sc_rd, sc_wr, av_waitrequest)

begin

	next_state <= state;

	case state is

		when idl =>
			if sc_rd='1' then
				if av_waitrequest='0' then
					next_state <= rd;
				else
					next_state <= rdw;
				end if;
			elsif sc_wr='1' then
				if av_waitrequest='0' then
					next_state <= wr;
				else
					next_state <= wrw;
				end if;
			end if;

		when rdw =>
			if av_waitrequest='0' then
				next_state <= rd;
			end if;

		when rd =>
			next_state <= idl;

		when wrw =>
			if av_waitrequest='0' then
				next_state <= wr;
			end if;

		when wr =>
			next_state <= idl;


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
		sc_rdy_cnt <= "00";
		reg_rd <= '0';
		reg_wr <= '0';

	elsif rising_edge(clk) then

		state <= next_state;
		sc_rdy_cnt <= "00";
		reg_rd <= '0';
		reg_wr <= '0';

		case next_state is

			when idl =>

			when rdw =>
				sc_rdy_cnt <= "11";
				reg_rd <= '1';

			when rd =>
				reg_rd_data <= av_readdata;

			when wrw =>
				sc_rdy_cnt <= "11";
				reg_wr <= '1';

			when wr =>

		end case;
					
	end if;
end process;

end rtl;

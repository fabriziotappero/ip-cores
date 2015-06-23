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
--	sc_sigdel.vhd
--
--	A simple sigma-delta ADC and PWM DAC for the SimpCon interface
--	
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--	resources on Cyclone
--
--		xx LCs, max xx MHz
--
--
--	2006-04-16	first version
--
--	todo:
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_config.all;

entity sc_sigdel is
generic (addr_bits : integer; fsamp : integer);

port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0);

-- io ports
	sdi			: in std_logic;		-- input of the sigma-delta ADC
	sdo			: out std_logic;	-- output of the sigma-delta ADC
	dac			: out std_logic		-- output of the PWM DAC
);
end sc_sigdel;

architecture rtl of sc_sigdel is

	-- we use a 10MHz sigma-delta clock
	constant SDF		: integer := 10000000;
	constant SDTICK		: integer := (clk_freq+SDF/2)/SDF;
	signal clksd		: integer range 0 to SDTICK;
	constant CNT_MAX	: integer := (SDF+fsamp/2)/fsamp;
	signal cnt			: integer range 0 to CNT_MAX;
	signal dac_cnt		: integer range 0 to CNT_MAX;

	signal rx_d			: std_logic;
	signal serdata		: std_logic;
	signal spike		: std_logic_vector(2 downto 0);	-- sync in, filter
	signal sum			: unsigned(15 downto 0);
	signal delta		: unsigned(15 downto 0);

	signal audio_in		: std_logic_vector(15 downto 0);
	signal audio_out	: std_logic_vector(15 downto 0);

	signal sample_rdy	: std_logic;
	signal sample_rd	: std_logic;
	signal sample_wr	: std_logic;

begin

	rdy_cnt <= "00";	-- no wait states
	-- we use only 16 bits
	-- bit 31 is the ready bit
	rd_data(30 downto 16) <= (others => '0');

--
--	The registered MUX is all we need for a SimpCon read.
--	The read data is stored in registered rd_data.
--
process(clk, reset)
begin

	if (reset='1') then
		rd_data(15 downto 0) <= (others => '0');
		rd_data(31) <= '0';
		sample_rd <= '0';
	elsif rising_edge(clk) then

		sample_rd <= '0';
		if rd='1' then
			rd_data(15 downto 0) <= audio_in;
			rd_data(31) <= sample_rdy;
			sample_rd <= '1';
		end if;
	end if;

end process;


--
--	SimpCon write is very simple
--
process(clk, reset)

begin

	if (reset='1') then
		audio_out <= (others => '0');
		sample_wr <= '0';
	elsif rising_edge(clk) then
		sample_wr <= '0';
		if wr='1' then
			audio_out <= wr_data(15 downto 0);
			sample_wr <= '1';
		end if;
	end if;
end process;


--
--	Here we go with the simple sigma-delta converter:
--
process(clk, reset)

begin

	if reset='1' then

		spike <= "000";
		clksd <= 0;
		cnt <= 0;
		sum <= (others => '0');
		sample_rdy <= '0';

	elsif rising_edge(clk) then

		if clksd=0 then
			clksd <= SDTICK-1;
			spike(0) <= sdi;
			spike(2 downto 1) <= spike(1 downto 0);
			sdo <= not rx_d;
			serdata <= rx_d;

			if cnt=0 then
				cnt <= CNT_MAX-1;
				audio_in <= std_logic_vector(sum);
				sample_rdy <= '1';
				sum <= (others => '0');
				-- BTW: we miss one sigma-delta sample here...
			else
				cnt <= cnt-1;
				if serdata='1' then
					sum <= sum+1;
				end if;
			end if;
		else
			clksd <= clksd-1;
		end if;

		-- reset ready flag after read
		if sample_rd='1' then
			sample_rdy <= '0';
		end if;

	end if;

end process;

--
--	filter input (majority voting)
--
	with spike select
		rx_d <=	'0' when "000",
				'0' when "001",
				'0' when "010",
				'1' when "011",
				'0' when "100",
				'1' when "101",
				'1' when "110",
				'1' when "111",
				'X' when others;

--
--	and here comes the primitive version of the
--	digital delta part - not really delta...
--		it's just a simple PWM...
--	now do it with the main clock...
--
process(clk, reset)

begin
	if reset='1' then
		delta <= (others => '0');
		dac <= '0';
		dac_cnt <= 0;
	elsif rising_edge(clk) then

		if dac_cnt=0 then
			dac_cnt <= CNT_MAX-1;
			delta <= unsigned(audio_out);
		else
			dac_cnt <= dac_cnt-1;
			dac <= '0';
			if delta /= 0 then
				delta <= delta-1;
				dac <= '1';
			end if;
		end if;

	end if;
end process;

end rtl;

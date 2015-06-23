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
--	sc_mac.vhd
--
--	A simple MAC unit with a SimpCon interface
--	
--	Author: Martin Schoeberl	martin@jopdesign.com
--
--
--	resources on Cyclone
--
--		xx LCs, max xx MHz
--
--
--	2006-02-12	first version
--
--	todo:
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.lpm_components.all;

entity mac is

port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	opa, opb	: in std_logic_vector(31 downto 0);
	start		: in std_logic;
	clear		: in std_logic;
	result		: out std_logic_vector(63 downto 0)
);
end mac;

architecture rtl of mac is

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (63 DOWNTO 0);

	COMPONENT lpm_mult
	GENERIC (
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING;
		lpm_widtha		: NATURAL;
		lpm_widthb		: NATURAL;
		lpm_widthp		: NATURAL;
		lpm_widths		: NATURAL
	);
	PORT (
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			clock	: IN STD_LOGIC ;
			result	: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
	END COMPONENT;

	type state_type		is (idle, mul, add);
	signal state 		: state_type;

	signal cnt			: unsigned(5 downto 0);

	signal mul_res		: unsigned(63 downto 0);
	signal acc			: unsigned(63 downto 0);

begin


	lpm_mult_component : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_pipeline => 16,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 32,
		lpm_widthb => 32,
		lpm_widthp => 64,
		lpm_widths => 1
	)
	PORT MAP (
		dataa => opa,
		datab => opb,
		clock => clk,
		result => sub_wire0
	);

	mul_res <= unsigned(sub_wire0);



process(clk, reset)

begin
	if reset='1' then
		acc <= (others => '0');

	elsif rising_edge(clk) then

		case state is

			when idle =>
				if start='1' then
					state <= mul;
					cnt <= "010010";	-- for shure
				end if;

			when mul =>
				cnt <= cnt-1;
				if cnt=0 then
					state <= add;
				end if;

			when add =>
				acc <= acc + mul_res;
				state <= idle;
				
		end case;

		if clear='1' then
			acc <= (others => '0');
		end if;

	end if;

	result <= std_logic_vector(acc);

end process;
	
end rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sc_mac is
generic (addr_bits : integer; scale : integer := 16);

port (
	clk		: in std_logic;
	reset	: in std_logic;

-- SimpCon interface

	address		: in std_logic_vector(addr_bits-1 downto 0);
	wr_data		: in std_logic_vector(31 downto 0);
	rd, wr		: in std_logic;
	rd_data		: out std_logic_vector(31 downto 0);
	rdy_cnt		: out unsigned(1 downto 0)

);
end sc_mac;

architecture rtl of sc_mac is

	signal opa, opb		: std_logic_vector(31 downto 0);
	signal result		: std_logic_vector(63 downto 0);

	signal start		: std_logic;
	signal clear		: std_logic;

begin

	rdy_cnt <= "00";	-- no wait states, we are hopefully fast enough

	cm: entity work.mac
		port map(
			clk => clk,
			reset => reset,

			opa => opa,
			opb => opb,
			start => start,
			clear => clear,
			result => result
	);

--
--	SimpCon read and write
--
process(clk, reset)

begin

	if reset='1' then
		rd_data <= (others => '0');

	elsif rising_edge(clk) then

		start <= '0';
		if wr='1' then
			if address(0)='0' then
				opa <= wr_data;
			else
				opb <= wr_data;
				start <= '1';
			end if;
		end if;

		-- get MAC result scaled by 'scale' and clear the accumulator
		clear <= '0';
		if rd='1' then
--			if address(0)='0' then
				rd_data <= result(31+scale downto scale);
				clear <= '1';
--			else
--				rd_data <= result(63 downto 32);
--			end if;
		end if;

	end if;
end process;


end rtl;

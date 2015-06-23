--
--  Programmable sync generator.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

-- Standard library.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library wb_tk;
use wb_tk.technology.all;

entity sync_gen is
	port (
		clk: in std_logic;
		clk_en: in std_logic;
		reset: in std_logic := '0';

		bs: in std_logic_vector(7 downto 0);
		ss: in std_logic_vector(7 downto 0);
		se: in std_logic_vector(7 downto 0);
		total: in std_logic_vector(7 downto 0);

		sync: out std_logic;
		blank: out std_logic;
		tc: out std_logic;
		
		count: out std_logic_vector (7 downto 0)
	);
end sync_gen;

architecture sync_gen of sync_gen is
begin
	-- And the sequential machine generating the output signals.
	generator: process is
		variable state: std_logic_vector(7 downto 0);
	begin
		wait until clk'event and clk='1';
		if (reset = '1') then
			tc <= '0';
			state := (others => '0');
			sync <= '0';
			tc <= '0';
			blank <= '1';
		else
			if  (clk_en='1') then
				if (state = bs) then
					sync <= '0';
					blank <= '1';
					tc <= '0';
					state := add_one(state);
				elsif (state = ss) then
					sync <= '1';
					blank <= '1';
					tc <= '1';
					state := add_one(state);
				elsif (state = se) then
					sync <= '0';
					blank <= '1';
					tc <= '0';
					state := add_one(state);
				elsif (state = total) then
					sync <= '0';
					blank <= '0';
					tc <= '0';
					state := (others => '0');
				else
					tc <= '0';
					state := add_one(state);
				end if;
				count <= state;
			else
				tc <= '0';
			end if;
		end if;
	end process;
end sync_gen;


-- Copyright (c) 2013 Antonio de la Piedra

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity xtea is
	port(clk : in std_logic;
	     rst : in std_logic;
	     enc : in std_logic;
	     block_in : in std_logic_vector(63 downto 0);
	     key : in std_logic_vector(127 downto 0);
	     v_0_out : out std_logic_vector(31 downto 0);
	     v_1_out : out std_logic_vector(31 downto 0));
end xtea;

architecture Behavioral of xtea is

	signal delta_s : unsigned(31 downto 0);

	component round_f is
	port(v_in : in std_logic_vector(31 downto 0);
		  last_val : in std_logic_vector(31 downto 0);
        v_out : out std_logic_vector(31 downto 0));
	end component;

	component key_schedule is
	port(clk : in std_logic;
		  rst : in std_logic;
		  enc : in std_logic; -- (0, enc) (1, dec)
		  val : in std_logic_vector(1 downto 0);
		  key : in std_logic_vector(127 downto 0);
		  subkey : out std_logic_vector(31 downto 0));
	end component;
	
	signal subkey_s : std_logic_vector(31 downto 0);
	signal cnt_s : unsigned(1 downto 0);

	signal v_0_s, v_1_s : unsigned(31 downto 0);
	signal output_s : std_logic_vector(31 downto 0);
	signal input_a_s : std_logic_vector(31 downto 0);
begin

	KEY_SCHEDULE_0 : key_schedule port map (clk, rst, enc, std_logic_vector(cnt_s), key, subkey_s);

	pr_cnt : process(clk, rst)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cnt_s <= (others => '0');
			else
				cnt_s <= cnt_s + 1;
			end if;
		end if;
	end process;

	ROUND_F_0 : round_f port map (input_a_s, subkey_s, output_s);

	pr_macc : process(clk, rst, enc, block_in, output_s, cnt_s)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				if enc = '0' then
					v_1_s <= unsigned(block_in(63 downto 32));
					v_0_s <= unsigned(block_in(31 downto 0));
				else
					v_0_s <= unsigned(block_in(63 downto 32));
					v_1_s <= unsigned(block_in(31 downto 0));				
				end if;
			else			
				if cnt_s = "00" then -- v_0
					input_a_s <= std_logic_vector(v_1_s);
				elsif cnt_s = "01" then -- v_0
					if enc = '0' then
						v_0_s <= v_0_s + unsigned(output_s);
					else
						v_0_s <= v_0_s - unsigned(output_s);
					end if;
				elsif cnt_s = "10" then -- v_1
					input_a_s <= std_logic_vector(v_0_s);
				else -- v_1
					if enc = '0' then
						v_1_s <= v_1_s + unsigned(output_s);
					else
						v_1_s <= v_1_s - unsigned(output_s);
					end if;
				end if;
			end if;
		end if;
	end process;

	v_0_out <= std_logic_vector(v_0_s);
	v_1_out <= std_logic_vector(v_1_s);

end Behavioral;


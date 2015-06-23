
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

entity key_schedule is
	port(clk : in std_logic;
		  rst : in std_logic;
		  mode : in std_logic; -- 0 encrypt, 1 decrypt
	     key : in std_logic_vector(55 downto 0);
		  key_out : out std_logic_vector(47 downto 0));
end key_schedule;

architecture Behavioral of key_schedule is
	signal init_key_s : std_logic_vector(55 downto 0);
	signal c_0_s : std_logic_vector(27 downto 0);
	signal d_0_s : std_logic_vector(27 downto 0);
	
	signal shift_s : std_logic_vector(15 downto 0);
	signal key_pre_s : std_logic_vector(55 downto 0);
	signal key_pre_delay_s : std_logic_vector(55 downto 0);
	
begin

	pr_seq: process(clk, rst, key, shift_s(15), mode)
	begin
		if rst = '1' then
			c_0_s <=  key(55 downto 28);
			d_0_s <=  key(27 downto 0);
		elsif rising_edge(clk) then
			if shift_s(15) = '0' then
				if mode = '0' then
					c_0_s <= c_0_s(26 downto 0) & c_0_s(27);
					d_0_s <= d_0_s(26 downto 0) & d_0_s(27);
				else
					c_0_s <= c_0_s(0) & c_0_s(27 downto 1);
					d_0_s <= d_0_s(0) & d_0_s(27 downto 1);
				end if;
			else
				if mode = '0' then
					c_0_s <= c_0_s(25 downto 0) & c_0_s(27 downto 26);
					d_0_s <= d_0_s(25 downto 0) & d_0_s(27 downto 26);
				else
					c_0_s <= c_0_s(1 downto 0) & c_0_s(27 downto 2);
					d_0_s <= d_0_s(1 downto 0) & d_0_s(27 downto 2);
				end if;
			end if;
		end if;
	end process;

	pr_shr: process(clk, rst, mode)
	begin
		if rst = '1' then
			if mode = '0' then
				shift_s <= "0011111101111110";
			else
				shift_s <= "0111111011111100";
			end if;
		elsif rising_edge(clk) then
			shift_s <= shift_s(14 downto 0) & shift_s(15); 
		end if;
	end process;

	key_pre_s <= c_0_s & d_0_s;
	
	pr_delay: process(clk, mode, key_pre_s)
	begin
		if rising_edge(clk) then
			if mode = '1' then
				key_pre_delay_s <= key_pre_s;
			end if;
		end if;
	end process;
	

	key_out <= (key_pre_s (42)  & key_pre_s (39) & key_pre_s (45) & key_pre_s (32) & key_pre_s (55) & key_pre_s (51) & key_pre_s (53) & key_pre_s (28) &
				  key_pre_s (41) & key_pre_s (50)  & key_pre_s (35) & key_pre_s (46) & key_pre_s (33) & key_pre_s (37) & key_pre_s (44) & key_pre_s (52) &
				  key_pre_s (30) & key_pre_s (48) & key_pre_s (40)  & key_pre_s (49) & key_pre_s (29) & key_pre_s (36) & key_pre_s (43) & key_pre_s (54) &
				  key_pre_s (15)  & key_pre_s (4) & key_pre_s (25) & key_pre_s (19) & key_pre_s (9) & key_pre_s (1) & key_pre_s (26) & key_pre_s (16) &
				  key_pre_s (5) & key_pre_s (11)  & key_pre_s (23) & key_pre_s (8) & key_pre_s (12) & key_pre_s (7) & key_pre_s (17) & key_pre_s (0) &
				  key_pre_s (22) & key_pre_s (3) & key_pre_s (10)  & key_pre_s (14) & key_pre_s (6) & key_pre_s (20) & key_pre_s (27) & key_pre_s (24))
				  when mode = '0' else
				  (key_pre_delay_s (42)  & key_pre_delay_s (39) & key_pre_delay_s (45) & key_pre_delay_s (32) & key_pre_delay_s (55) & key_pre_delay_s (51) & key_pre_delay_s (53) & key_pre_delay_s (28) &
				  key_pre_delay_s (41) & key_pre_delay_s (50)  & key_pre_delay_s (35) & key_pre_delay_s (46) & key_pre_delay_s (33) & key_pre_delay_s (37) & key_pre_delay_s (44) & key_pre_delay_s (52) &
				  key_pre_delay_s (30) & key_pre_delay_s (48) & key_pre_delay_s (40)  & key_pre_delay_s (49) & key_pre_delay_s (29) & key_pre_delay_s (36) & key_pre_delay_s (43) & key_pre_delay_s (54) &
				  key_pre_delay_s (15)  & key_pre_delay_s (4) & key_pre_delay_s (25) & key_pre_delay_s (19) & key_pre_delay_s (9) & key_pre_delay_s (1) & key_pre_delay_s (26) & key_pre_delay_s (16) &
				  key_pre_delay_s (5) & key_pre_delay_s (11)  & key_pre_delay_s (23) & key_pre_delay_s (8) & key_pre_delay_s (12) & key_pre_delay_s (7) & key_pre_delay_s (17) & key_pre_delay_s (0) &
				  key_pre_delay_s (22) & key_pre_delay_s (3) & key_pre_delay_s (10)  & key_pre_delay_s (14) & key_pre_delay_s (6) & key_pre_delay_s (20) & key_pre_delay_s (27) & key_pre_delay_s (24));

end Behavioral;


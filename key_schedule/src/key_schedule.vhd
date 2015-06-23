-- Copyright (c) 2011 Antonio de la Piedra
 
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
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity key_schedule is
	port(clk   : in std_logic;
	     rst   : in std_logic;

	     load  : in std_logic;
	     start : in std_logic;
	     
	     key_in : in std_logic_vector(127 downto 0);
	     
	     key_ready : out std_logic;
	     key_out : out std_logic_vector(127 downto 0));
end key_schedule;

architecture Behavioral of key_schedule is
	signal w_3_i_s :  std_logic_vector(31 downto 0);

	signal g_sub_0_s :  std_logic_vector(7 downto 0);
	signal g_sub_1_s :  std_logic_vector(7 downto 0);
	signal g_sub_2_s :  std_logic_vector(7 downto 0);
	signal g_sub_3_s :  std_logic_vector(7 downto 0);
	
	signal count_5 : natural range 0 to 5;
	signal count_10 : natural range 0 to 10;
	
	type type_RCON is array (0 to 9) of std_logic_vector(7 downto 0);
	constant rcon : type_RCON :=  (x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1B", x"36");
      	
begin
	mod_5_cnt : process(clk, rst, start)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				count_5 <= 0;
			elsif(start = '1') then
				if (count_5 = 4) then
					count_5 <= 0;
				else
					count_5 <= count_5 + 1;
				end if;
			end if;
		end if; 
	end process mod_5_cnt;

	mod_10_cnt : process(clk, rst, start, count_5)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				count_10 <= 0;
			elsif(start = '1' and count_5 = 4) then
				if (count_10 = 9) then
					count_10 <= 0;
				else
					count_10 <= count_10 + 1;
				end if;
			end if;
		end if; 
	end process mod_10_cnt;

	gen_sub_keys : process(clk, rst, start, count_5, count_10, load)
		variable w_0_i_tmp_old : std_logic_vector(31 downto 0) := (others => '0');
		variable w_1_i_tmp_old : std_logic_vector(31 downto 0) := (others => '0');
		variable w_2_i_tmp_old : std_logic_vector(31 downto 0) := (others => '0');
		variable w_3_i_tmp_old : std_logic_vector(31 downto 0) := (others => '0');

		variable tmp_0 : std_logic_vector(31 downto 0) := (others => '0');
		variable tmp_1 : std_logic_vector(31 downto 0) := (others => '0');
		variable tmp_2 : std_logic_vector(31 downto 0) := (others => '0');
		variable tmp_3 : std_logic_vector(31 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				w_0_i_tmp_old := (others => '0');
				w_1_i_tmp_old := (others => '0');
				w_2_i_tmp_old := (others => '0');
				w_3_i_tmp_old := (others => '0');
			elsif (load = '1') then
				w_0_i_tmp_old := key_in(31 downto 0);
				w_1_i_tmp_old := key_in(63 downto 32);
				w_2_i_tmp_old := key_in(95 downto 64);
				w_3_i_tmp_old := key_in(127 downto 96);
			elsif (start = '1') then
				if (count_5 = 1) then
					tmp_0 := w_0_i_tmp_old xor (g_sub_3_s & g_sub_2_s & g_sub_1_s & (g_sub_0_s xor rcon(count_10)));
					w_0_i_tmp_old := tmp_0;
				elsif (count_5 = 2) then
					tmp_1 :=  w_1_i_tmp_old xor w_0_i_tmp_old;
					w_1_i_tmp_old := tmp_1;
				elsif (count_5 = 3) then
					tmp_2 := w_2_i_tmp_old xor w_1_i_tmp_old;
					w_2_i_tmp_old := tmp_2;
				elsif (count_5 = 4) then
					tmp_3 := w_3_i_tmp_old xor w_2_i_tmp_old;
					w_3_i_tmp_old := tmp_3;
				end if;	
			end if;
		end if;

		w_3_i_s <= w_3_i_tmp_old; 
				
		key_out <= tmp_3 & tmp_2 & tmp_1 & tmp_0; 

	end process;
	
	key_ready <= '1' when (count_5 = 1 and start = '1') else '0';
		
	S_BOX_DUAL_1: entity work.dual_mem(rtl) port map (clk, '0', w_3_i_s(7 downto 0), w_3_i_s(15 downto 8),  (others=>'0'), g_sub_3_s, g_sub_0_s);
	S_BOX_DUAL_2: entity work.dual_mem(rtl) port map (clk, '0', w_3_i_s(23 downto 16),   w_3_i_s(31 downto 24), (others=>'0'), g_sub_1_s, g_sub_2_s); 

end Behavioral;

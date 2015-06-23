
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

entity des_loop is
	port(clk :  in std_logic;
		  rst : in std_logic;
		  mode : in std_logic; -- 0 encrypt, 1 decrypt
		  key_in : in std_logic_vector(55 downto 0);
		  blk_in : in std_logic_vector(63 downto 0);
		  blk_out : out std_logic_vector(63 downto 0));
end des_loop;

architecture Behavioral of des_loop is

	signal after_ip_s : std_logic_vector(63 downto 0);
	signal after_ip_minus_one_s : std_logic_vector(63 downto 0);
	signal after_f_s : std_logic_vector(31 downto 0);
	signal final_s : std_logic_vector(63 downto 0);

	component des_round is
		port(clk : in std_logic;
			  l_0 : in std_logic_vector(31 downto 0);
		     r_0 : in std_logic_vector(31 downto 0);
		     k_i : in std_logic_vector(47 downto 0);
		     l_1 : out std_logic_vector(31 downto 0);
		     r_1 : out std_logic_vector(31 downto 0));
	end component;

	component key_schedule is
		port(clk : in std_logic;
			  rst : in std_logic;
		     mode : in std_logic; -- 0 encrypt, 1 decrypt
	        key : in std_logic_vector(55 downto 0);
		     key_out : out std_logic_vector(47 downto 0));
	end component;

	signal key_s : std_logic_vector(47 downto 0);

	signal l_0_s : std_logic_vector(31 downto 0);
	signal l_1_s : std_logic_vector(31 downto 0);
	signal r_0_s : std_logic_vector(31 downto 0);
	signal r_1_s : std_logic_vector(31 downto 0);
	
	signal rst_s : std_logic;
	
begin

	pr_rst_delay : process(clk, rst)
	begin
		if rising_edge(clk) then
			rst_s <= rst;
		end if;
	end process;

	pr_seq: process(clk, rst_s, blk_in)
	begin
		if rst_s = '1' then
			l_0_s <= blk_in(63 downto 32);
			r_0_s <= blk_in(31 downto 0);
		elsif rising_edge(clk) then
			l_0_s <= l_1_s;
			r_0_s <= r_1_s;
		end if;
	end process;

	DES_ROUND_0 :  des_round port map (clk, l_0_s, r_0_s, key_s, l_1_s, r_1_s);

	blk_out <= r_1_s & l_1_s;

	KEY_SCHEDULE_0 : key_schedule port map (clk, rst, mode, key_in, key_s);

end Behavioral;


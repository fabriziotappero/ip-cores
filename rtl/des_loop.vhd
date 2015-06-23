
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
		  key_in : in std_logic_vector(63 downto 0);
		  key_pre_w_in : in std_logic_vector(63 downto 0);
		  key_pos_w_in : in std_logic_vector(63 downto 0);
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
	        key : in std_logic_vector(63 downto 0);
		     key_out : out std_logic_vector(47 downto 0));
	end component;

	signal key_s : std_logic_vector(47 downto 0);

	signal l_0_s : std_logic_vector(31 downto 0);
	signal l_1_s : std_logic_vector(31 downto 0);
	signal l_2_s : std_logic_vector(31 downto 0);
	signal l_3_s : std_logic_vector(31 downto 0);
	signal l_4_s : std_logic_vector(31 downto 0);
	signal l_5_s : std_logic_vector(31 downto 0);
	signal l_6_s : std_logic_vector(31 downto 0);
	signal l_7_s : std_logic_vector(31 downto 0);
	signal l_8_s : std_logic_vector(31 downto 0);
	signal l_9_s : std_logic_vector(31 downto 0);
	signal l_10_s : std_logic_vector(31 downto 0);
	signal l_11_s : std_logic_vector(31 downto 0);
	signal l_12_s : std_logic_vector(31 downto 0);
	signal l_13_s : std_logic_vector(31 downto 0);
	signal l_14_s : std_logic_vector(31 downto 0);
	signal l_15_s : std_logic_vector(31 downto 0);
	signal l_16_s : std_logic_vector(31 downto 0);

	signal r_0_s : std_logic_vector(31 downto 0);
	signal r_1_s : std_logic_vector(31 downto 0);
	signal r_2_s : std_logic_vector(31 downto 0);
	signal r_3_s : std_logic_vector(31 downto 0);
	signal r_4_s : std_logic_vector(31 downto 0);
	signal r_5_s : std_logic_vector(31 downto 0);
	signal r_6_s : std_logic_vector(31 downto 0);
	signal r_7_s : std_logic_vector(31 downto 0);
	signal r_8_s : std_logic_vector(31 downto 0);
	signal r_9_s : std_logic_vector(31 downto 0);
	signal r_10_s : std_logic_vector(31 downto 0);
	signal r_11_s : std_logic_vector(31 downto 0);
	signal r_12_s : std_logic_vector(31 downto 0);
	signal r_13_s : std_logic_vector(31 downto 0);
	signal r_14_s : std_logic_vector(31 downto 0);
	signal r_15_s : std_logic_vector(31 downto 0);
	signal r_16_s : std_logic_vector(31 downto 0);
	
	signal k_0_s : std_logic_vector(47 downto 0);
	signal k_1_s : std_logic_vector(47 downto 0);
	signal k_2_s : std_logic_vector(47 downto 0);
	signal k_3_s : std_logic_vector(47 downto 0);
	signal k_4_s : std_logic_vector(47 downto 0);
	signal k_5_s : std_logic_vector(47 downto 0);
	signal k_6_s : std_logic_vector(47 downto 0);
	signal k_7_s : std_logic_vector(47 downto 0);
	signal k_8_s : std_logic_vector(47 downto 0);
	signal k_9_s : std_logic_vector(47 downto 0);
	signal k_10_s : std_logic_vector(47 downto 0);
	signal k_11_s : std_logic_vector(47 downto 0);
	signal k_12_s : std_logic_vector(47 downto 0);
	signal k_13_s : std_logic_vector(47 downto 0);
	signal k_14_s : std_logic_vector(47 downto 0);
	signal k_15_s : std_logic_vector(47 downto 0);
	
	signal rst_s : std_logic;
	
	signal blk_in_s : std_logic_vector(63 downto 0);
	signal blk_out_s : std_logic_vector(63 downto 0);
	
begin

	pr_rst_delay : process(clk, rst)
	begin
		if rising_edge(clk) then
			rst_s <= rst;
		end if;
	end process;
	
	-- IP

	blk_in_s <= (blk_in xor key_pre_w_in) when mode = '0' else (blk_in xor key_pos_w_in);

	pr_seq: process(clk, rst_s, blk_in_s)
	begin
		if rst_s = '1' then
			l_0_s <= blk_in_s(6) & blk_in_s(14) & blk_in_s(22) & blk_in_s(30) & blk_in_s(38) & blk_in_s(46) & blk_in_s(54)  & blk_in_s(62) &
							  blk_in_s(4) & blk_in_s(12) & blk_in_s(20) & blk_in_s(28) & blk_in_s(36) & blk_in_s(44) & blk_in_s(52)  & blk_in_s(60) &
							  blk_in_s(2) & blk_in_s(10) & blk_in_s(18) & blk_in_s(26) & blk_in_s(34) & blk_in_s(42) & blk_in_s(50)  & blk_in_s(58) &
							  blk_in_s(0) & blk_in_s(8)  & blk_in_s(16) & blk_in_s(24) & blk_in_s(32) & blk_in_s(40) & blk_in_s(48)  & blk_in_s(56);
							  
			r_0_s <= blk_in_s(7) & blk_in_s(15) & blk_in_s(23) & blk_in_s(31) & blk_in_s(39) & blk_in_s(47) & blk_in_s(55)  & blk_in_s(63) &
							  blk_in_s(5) & blk_in_s(13) & blk_in_s(21) & blk_in_s(29) & blk_in_s(37) & blk_in_s(45) & blk_in_s(53)  & blk_in_s(61) &
							  blk_in_s(3) & blk_in_s(11) & blk_in_s(19) & blk_in_s(27) & blk_in_s(35) & blk_in_s(43) & blk_in_s(51)  & blk_in_s(59) &
							  blk_in_s(1) & blk_in_s(9)  & blk_in_s(17) & blk_in_s(25) & blk_in_s(33) & blk_in_s(41) & blk_in_s(49)  & blk_in_s(57);		
		elsif rising_edge(clk) then
			l_0_s <= l_1_s;
			r_0_s <= r_1_s;
		end if;
	end process;

	DES_ROUND_0 :  des_round port map (clk, l_0_s, r_0_s, k_0_s, l_1_s, r_1_s);

	final_s <= r_1_s & l_1_s;

	blk_out_s  <= final_s(24) & final_s(56) & final_s(16) & final_s(48) & final_s(8) & final_s(40) & final_s(0)  & final_s(32) &
					  final_s(25) & final_s(57) & final_s(17) & final_s(49) & final_s(9) & final_s(41) & final_s(1) & final_s(33) &
					  final_s(26) & final_s(58) & final_s(18) & final_s(50) & final_s(10) & final_s(42) & final_s(2) & final_s(34) &
					  final_s(27) & final_s(59) & final_s(19) & final_s(51) & final_s(11) & final_s(43) & final_s(3) & final_s(35) &
					  final_s(28) & final_s(60) & final_s(20) & final_s(52) & final_s(12) & final_s(44) & final_s(4)  & final_s(36) &
					  final_s(29) & final_s(61) & final_s(21) & final_s(53) & final_s(13) & final_s(45) & final_s(5) & final_s(37) &
					  final_s(30) & final_s(62) & final_s(22) & final_s(54) & final_s(14) & final_s(46) & final_s(6) & final_s(38) &
					  final_s(31) & final_s(63) & final_s(23) & final_s(55) & final_s(15) & final_s(47) & final_s(7) & final_s(39);

	blk_out <= (blk_out_s xor key_pos_w_in) when mode = '0' else (blk_out_s xor key_pre_w_in);


	KEY_SCHEDULE_0 : key_schedule port map (clk, rst, mode, key_in, k_0_s);

end Behavioral;



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

entity f_fun is
	port(clk : in std_logic;
		  r_in : in std_logic_vector(31 downto 0);
		  k_in : in std_logic_vector(47 downto 0);
		  r_out : out std_logic_vector(31 downto 0));
end f_fun;

architecture Behavioral of f_fun is

	component dsp_xor is
		port (clk     : in std_logic;
				op_1	  : in std_logic_vector(31 downto 0);
				op_2	  : in std_logic_vector(31 downto 0);
				op_3	  : out std_logic_vector(31 downto 0));
	end component;

	component dsp_xor_48 is
		port (clk     : in std_logic;
				op_1	  : in std_logic_vector(47 downto 0);
				op_2	  : in std_logic_vector(47 downto 0);
				op_3	  : out std_logic_vector(47 downto 0));
	end component;

	COMPONENT s_box_dram_1
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	COMPONENT s_box_dram_2
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT s_box_dram_3
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;	

	COMPONENT s_box_dram_4
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	COMPONENT s_box_dram_5
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT s_box_dram_6
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;		

	COMPONENT s_box_dram_7
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	COMPONENT s_box_dram_8
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;

	COMPONENT s_box_l_dual_dram
		PORT (
			a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			d : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			dpra : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
			clk : IN STD_LOGIC;
			we : IN STD_LOGIC;
			spo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			dpo : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
	END COMPONENT;
	
	signal blk_exp_s : std_logic_vector(47 downto 0);
	signal post_exp_key_add_s : std_logic_vector(47 downto 0);
	signal post_s_box_s : std_logic_vector(31 downto 0);
	
begin

	-- E

	blk_exp_s <= r_in(0)  & r_in(31)  & r_in(30)  & r_in(29)  & r_in(28)  & r_in(27)  &
					 r_in(28) & r_in(27)  & r_in(26)  & r_in(25)  & r_in(24)  & r_in(23)  &
					 r_in(24) & r_in(23)  & r_in(22)  & r_in(21)  & r_in(20)  & r_in(19)  &
					 r_in(20) & r_in(19)  & r_in(18)  & r_in(17)  & r_in(16)  & r_in(15)  &
					 r_in(16) & r_in(15)  & r_in(14)  & r_in(13)  & r_in(12)  & r_in(11)  &
					 r_in(12) & r_in(11)  & r_in(10)  & r_in(9)   & r_in(8)   & r_in(7)   &
					 r_in(8)  & r_in(7)   & r_in(6)   & r_in(5)   & r_in(4)   & r_in(3)   &
					 r_in(4)  & r_in(3)   & r_in(2)   & r_in(1)   & r_in(0)   & r_in(31);
					 
	post_exp_key_add_s <= blk_exp_s xor k_in;

	S_BOX_0 : s_box_l_dual_dram port map (post_exp_key_add_s(47 downto 42), 
												    (others => '0'),
													  post_exp_key_add_s(41 downto 36),
													  clk,
													  '0',
													  post_s_box_s(31 downto 28),
													  post_s_box_s(27 downto 24));

	S_BOX_1 : s_box_l_dual_dram port map (post_exp_key_add_s(35 downto 30), 
												    (others => '0'),
													  post_exp_key_add_s(29 downto 24),
													  clk,
													  '0',
													  post_s_box_s(23 downto 20),
													  post_s_box_s(19 downto 16));

	S_BOX_2 : s_box_l_dual_dram port map (post_exp_key_add_s(23 downto 18), 
												    (others => '0'),
													  post_exp_key_add_s(17 downto 12),
													  clk,
													  '0',
													  post_s_box_s(15 downto 12),
													  post_s_box_s(11 downto 8));

	S_BOX_3 : s_box_l_dual_dram port map (post_exp_key_add_s(11 downto 6), 
												    (others => '0'),
													  post_exp_key_add_s(5 downto 0),
													  clk,
													  '0',
													  post_s_box_s(7 downto 4),
													  post_s_box_s(3 downto 0));

	r_out <= post_s_box_s(16) & post_s_box_s(25)  & post_s_box_s(12) & post_s_box_s(11) & post_s_box_s(3) & post_s_box_s(20) & post_s_box_s(4) & post_s_box_s(15) & 
				post_s_box_s(31)  & post_s_box_s(17) & post_s_box_s(9) & post_s_box_s(6) & post_s_box_s(27)  & post_s_box_s(14) & post_s_box_s(1) & post_s_box_s(22)  &
				post_s_box_s(30)  & post_s_box_s(24)  & post_s_box_s(8) & post_s_box_s(18) & post_s_box_s(0) & post_s_box_s(5) & post_s_box_s(29)  & post_s_box_s(23)  &
				post_s_box_s(13) & post_s_box_s(19) & post_s_box_s(2) & post_s_box_s(26)  & post_s_box_s(10) & post_s_box_s(21) & post_s_box_s(28)  & post_s_box_s(7);


end Behavioral;


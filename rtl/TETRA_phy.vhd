
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TETRA_phy is

	port(tetra_clk_36_KHz : in std_logic;
		  tetra_clk_18_KHz : in std_logic;
		  tetra_rst : in std_logic;
		  tetra_bit_stream_input : in  STD_LOGIC;
        tetra_valid_input : in  STD_LOGIC;
		  tetra_debug_dbit_output : out std_logic_vector(1 downto 0);
		  tetra_diffPhaseEncoder_output_0 : out std_logic_vector(7 downto 0);
		  tetra_diffPhaseEncoder_output_1 : out std_logic_vector(7 downto 0)
   );
	
end TETRA_phy;

architecture Behavioral of TETRA_phy is

	component dataConverter is
		Port (clk_36_KHz : in  STD_LOGIC;
				rst : in std_logic;
				bit_stream_input : in  STD_LOGIC;
				valid_input : in  STD_LOGIC;
				dbit_output : out std_logic_vector(1 downto 0));
	end component;

	component biPolarEncoder is
		Port (bit_input : in  std_logic;
				valid_input : in  STD_LOGIC;
				bi_polar_output : out std_logic_vector(1 downto 0));
	end component;

	component diffPhaseEncoder is
	port(clk_18_KHz: in std_logic;
		  rst: in std_logic;
		  en: in std_logic;
		  a_k : in std_logic;
		  b_k : in std_logic;
		  i_k : out std_logic_vector(7 downto 0);  
		  q_k : out std_logic_vector(7 downto 0)); 
	end component;	
	
	signal dc_dbit_output_tmp : std_logic_vector(1 downto 0);
	signal valid_input_diffPhaseEncoder_1_s : std_logic;
	signal valid_input_diffPhaseEncoder_2_s : std_logic;
	signal tetra_diffPhaseEncoder_output_0_tmp : std_logic_vector(7 downto 0); 
	signal tetra_diffPhaseEncoder_output_1_tmp : std_logic_vector(7 downto 0);

begin
	
	DCONV: dataConverter port map (tetra_clk_36_KHz,
											 tetra_rst,
											 tetra_bit_stream_input,
											 tetra_valid_input,
											 dc_dbit_output_tmp);
											 

											  
	PHENC: diffPhaseEncoder port map (tetra_clk_18_KHz,
												 tetra_rst,
												 valid_input_diffPhaseEncoder_2_s, --valid_input_diffPhaseEncoder_s,
												 dc_dbit_output_tmp(1),
												 dc_dbit_output_tmp(0),
												 tetra_diffPhaseEncoder_output_0_tmp,
												 tetra_diffPhaseEncoder_output_1_tmp);										  
											  
	tetra_debug_dbit_output <= dc_dbit_output_tmp;
	tetra_diffPhaseEncoder_output_0 <= tetra_diffPhaseEncoder_output_0_tmp;
	tetra_diffPhaseEncoder_output_1 <= tetra_diffPhaseEncoder_output_1_tmp;
	
	delay_biPolarEncoder_1: process(tetra_clk_18_KHz, tetra_valid_input)
		variable valid_input_diffPhaseEncoder_v : std_logic := '0';
	begin
		if falling_edge(tetra_clk_36_KHz) then
			valid_input_diffPhaseEncoder_v := tetra_valid_input;
		end if;	
		
		valid_input_diffPhaseEncoder_1_s <= valid_input_diffPhaseEncoder_v;
	end process;

	delay_biPolarEncoder_2: process(tetra_clk_18_KHz, tetra_valid_input, valid_input_diffPhaseEncoder_1_s)
		variable valid_input_diffPhaseEncoder_v : std_logic := '0';
	begin
		if falling_edge(tetra_clk_36_KHz) then
			valid_input_diffPhaseEncoder_v := valid_input_diffPhaseEncoder_1_s;
		end if;	
		
		valid_input_diffPhaseEncoder_2_s <= valid_input_diffPhaseEncoder_v;
	end process;
	
end Behavioral;


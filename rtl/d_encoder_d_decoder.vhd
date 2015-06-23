
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

entity d_encoder_d_decoder is
	port(tx_tetra_clk_36_KHz : in std_logic;
		  tx_tetra_clk_18_KHz : in std_logic;
		  tx_tetra_rst : in std_logic;
		  tx_tetra_bit_stream_input : in  STD_LOGIC;
        tx_tetra_valid_input : in  STD_LOGIC;
		  tx_tetra_debug_dbit_output : out std_logic_vector(1 downto 0);
		  tx_tetra_diffPhaseEncoder_output_0 : out std_logic_vector(7 downto 0);
		  tx_tetra_diffPhaseEncoder_output_1 : out std_logic_vector(7 downto 0);
		  rx_clk_18_KHz: in std_logic;
		  rx_rst: in std_logic;
		  rx_en: in std_logic;
		  rx_a_k : out std_logic_vector(7 downto 0);
		  rx_b_k : out std_logic_vector(7 downto 0);
		  rx_i_k : in std_logic_vector(7 downto 0);  
	     rx_q_k : in std_logic_vector(7 downto 0) 
   );
end d_encoder_d_decoder;

architecture Behavioral of d_encoder_d_decoder is

	component TETRA_phy is
		port(tetra_clk_36_KHz : in std_logic;
			tetra_clk_18_KHz : in std_logic;
			tetra_rst : in std_logic;
			tetra_bit_stream_input : in  STD_LOGIC;
			tetra_valid_input : in  STD_LOGIC;
			tetra_debug_dbit_output : out std_logic_vector(1 downto 0);
			tetra_diffPhaseEncoder_output_0 : out std_logic_vector(7 downto 0);
			tetra_diffPhaseEncoder_output_1 : out std_logic_vector(7 downto 0)
		);
	end component;

	component diffPhaseDecoder is
		port(clk_18_KHz: in std_logic;
			rst: in std_logic;
			en: in std_logic;
			a_k : out std_logic_vector(7 downto 0);
			b_k : out std_logic_vector(7 downto 0);
			i_k : in std_logic_vector(7 downto 0);  
			q_k : in std_logic_vector(7 downto 0)); 
	end component;

begin

	TETRA_TX : TETRA_phy port map (tx_tetra_clk_36_KHz,
											 tx_tetra_clk_18_KHz,
											 tx_tetra_rst,
											 tx_tetra_bit_stream_input,
											 tx_tetra_valid_input,
											 tx_tetra_debug_dbit_output,
											 tx_tetra_diffPhaseEncoder_output_0,
											 tx_tetra_diffPhaseEncoder_output_1);
											 
	TETRA_RX : diffPhaseDecoder port map (rx_clk_18_KHz,
					    							  rx_rst,
												     rx_en,
		                                   rx_a_k,
		                                   rx_b_k,
		                                   rx_i_k,
	                                      rx_q_k);							 

end Behavioral;


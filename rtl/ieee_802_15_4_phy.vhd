-- Copyright (c) 2010 Antonio de la Piedra
 
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

-- A VHDL model of the IEEE 802.15.4 physical layer.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ieee_802_15_4_phy is
	port(   clk_1_mhz : in std_logic; 
                clk_8_mhz : in std_logic; 
        
                rst : in std_logic;
                
                tx_start : in std_logic;
                tx_symbol :in std_logic_vector(3 downto 0);
                tx_i_out : out std_logic_vector(9 downto 0);
                tx_q_out : out std_logic_vector(9 downto 0);
                
                rx_start : in std_logic;
                rx_i_in : in std_logic_vector(9 downto 0);
                rx_q_in : in std_logic_vector(9 downto 0);
                rx_sym_out : out std_logic_vector(3 downto 0));
                

end ieee_802_15_4_phy;

architecture Behavioral of ieee_802_15_4_phy is

begin

  TX : entity work.tx_core(Behavioral) port map (clk_1_mhz,
                                                 clk_8_mhz,
                                                 tx_start,
                                                 rst,
                                                 tx_symbol,
                                                 tx_i_out,
                                                 tx_q_out);

                                             
  RX : entity work.rx_core(Behavioral) port map (clk_1_mhz,
                                                 clk_8_mhz,
                                                 rx_start,
                                                 rst,
                                                 rx_i_in,
                                                 rx_q_in,
                                                 rx_sym_out);
                                               
   
end Behavioral;


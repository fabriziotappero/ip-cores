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

entity tx_core is

	port(   clk_1_mhz : in std_logic; 
                clk_8_mhz : in std_logic; 
        
                tx_core_start : in std_logic;
                tx_core_rst : in std_logic;
                tx_core_symbol : in std_logic_vector(3 downto 0);
						
                tx_core_i_out : out std_logic_vector(9 downto 0);
                tx_core_q_out : out std_logic_vector(9 downto 0));

end tx_core;

architecture Behavioral of tx_core is
 constant N : integer := 5; 

 type delay_buffer_t is array(N-1 downto 0) of
  std_logic_vector(9 downto 0);

 signal chip_i, chip_q : std_logic;
 signal upsampler_i, upsampler_q : std_logic_vector(1 downto 0);
 signal tx_core_q_out_tmp : std_logic_vector(9 downto 0);
 signal delay_buffer : delay_buffer_t;

begin

  CHIP_GEN : entity work.chip_gen(Behavioral) port map (tx_core_rst,
                                                                  clk_1_mhz, 
                                                                 tx_core_symbol, 
                                                                 chip_i, 
                                                                 chip_q);
  UPSAMPLER_CH_I : entity work.upsampler(Behavioral) port map (upsampler_i,
                                               chip_i,
                                               clk_8_mhz,
                                               tx_core_start);
                                               
  UPSAMPLER_CH_Q : entity work.upsampler(Behavioral) port map (upsampler_q,
                                               chip_q,
                                               clk_8_mhz,
                                               tx_core_start);
  
  FIR_CH_I : entity work.tx_fir(Behavioral) port map (upsampler_i,
                                               clk_8_mhz,
                                               tx_core_rst,
                                               tx_core_i_out);
                                                                                              
  FIR_CH_Q : entity work.tx_fir(Behavioral) port map (upsampler_q,
                                               clk_8_mhz,
                                               tx_core_rst,
                                               tx_core_q_out_tmp);

  -- Q Channel delay by T_sym/2: O-QPSK modulator will need the Q channel 
  -- delayed by T_sym/2 (0.5 us).
                                                
  delay_buffer(0) <= tx_core_q_out_tmp;
 
  gen_delay: for i in 1 to N-1 generate
   q_ch_delay: process(clk_8_mhz)
   begin
    if rising_edge(clk_8_mhz) then
     delay_buffer(i) <= delay_buffer(i-1);
    end if;
   end process q_ch_delay;
  end generate gen_delay;
                   
  tx_core_q_out <= delay_buffer(N-1);
                                                  
end Behavioral;


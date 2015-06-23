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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity rx_core is
	port (clk_1_mhz: in std_logic;
              clk_8_mhz: in std_logic;
          
              rx_core_start: in std_logic;
              rx_core_rst:  in std_logic;
          
              rx_core_input_i: in std_logic_vector(9 downto 0);
              rx_core_input_q: in std_logic_vector(9 downto 0);
              rx_sym_out : out std_logic_vector(3 downto 0));
end rx_core;

architecture Behavioral of rx_core is
  signal rx_core_input_i_delayed : std_logic_vector(9 downto 0);
  signal mfilter_ch_i, mfilter_ch_q : std_logic_vector(9 downto 0);
  signal down_ch_i, down_ch_q : std_logic_vector(9 downto 0);
  signal rz_ch_i, rz_ch_q : std_logic;
  signal corr_s_1, corr_s_2 : std_logic;

  constant N : integer := 5; 

  type delay_buffer_t is array(N-1 downto 0) of
   std_logic_vector(9 downto 0);

  signal delay_buffer_ch_i : delay_buffer_t;

  signal corr_sym : std_logic_vector(3 downto 0);
  signal corr_start_delayed : std_logic_vector(2 downto 0);
begin

  FIR_RX_CH_I : entity work.rx_fir(Behavioral) port map (rx_core_input_i_delayed,
                                                         clk_8_mhz,
                                                         rx_core_rst,
                                                         mfilter_ch_i);

  FIR_RX_CH_Q : entity work.rx_fir(Behavioral) port map (rx_core_input_q,
                                                         clk_8_mhz,
                                                         rx_core_rst,
                                                         mfilter_ch_q);

  DOWNSAMPLER_CH_I : entity work.downsampler(Behavioral) port map (clk_1_mhz,
                                                                   rx_core_start,
                                                                   mfilter_ch_i,
                                                                   down_ch_i);


  DOWNSAMPLER_CH_Q : entity work.downsampler(Behavioral) port map (clk_1_mhz,
                                                                   rx_core_start,
                                                                   mfilter_ch_q,
                                                                   down_ch_q);

  RZ_ENCODER_CH_I : entity work.rz_enc(Behavioral) port map (down_ch_i,
                                                        rz_ch_i);

  RZ_ENCODER_CH_Q : entity work.rz_enc(Behavioral) port map (down_ch_q,
                                                        rz_ch_q);

  SYM_CORR : entity work.sym_corr(Behavioral) port map (corr_start_delayed(2),
                                                        clk_1_mhz,
                                                        rx_core_rst,
                                                        rz_ch_q,
                                                        rx_sym_out);

  -- Symbol correlator start signal is delayed by 2 us
  -- before it can start detecting symbols.                                                                 
                                                                   
  corr_start_delayed(0) <= rx_core_start;

  gen_delay_corr: for i in 1 to 2 generate
   corr_delay: process(clk_1_mhz)
   begin
    if rising_edge(clk_1_mhz) then
     corr_start_delayed(i) <= corr_start_delayed(i-1);
    end if;
   end process corr_delay;
  end generate gen_delay_corr;
                   
  -- I Channel is delayed to perform demodulation at the same
  -- time that Q Channel (delayed by Tx) arrives.
                                                
  delay_buffer_ch_i(0) <= rx_core_input_i;
 
  gen_delay_ch_i: for i in 1 to N-1 generate
   i_ch_delay: process(clk_8_mhz)
   begin
    if rising_edge(clk_8_mhz) then
     delay_buffer_ch_i(i) <= delay_buffer_ch_i(i-1);
    end if;
   end process i_ch_delay;
  end generate gen_delay_ch_i;
                   
  rx_core_input_i_delayed <= delay_buffer_ch_i(N-1);

  
end Behavioral;


-------------------------------------------------------------------------------
-- Title      : LED from packet codec
-- Project    : 
-------------------------------------------------------------------------------
-- File       : led_packet_codec.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Last update: 2011-12-01
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Blinks led. For the older packet codec interface.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_packet_codec is

  generic (
    data_width_g   : integer := 32;
    tx_len_width_g : integer := 16);

  port (
    
    clk   : in std_logic;
    rst_n : in std_logic;

    tx_av_out    : out std_logic;
    tx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    tx_we_out    : out std_logic;
    tx_txlen_out : out std_logic_vector (tx_len_width_g -1 downto 0);
    tx_full_in   : in  std_logic;

    rx_av_in    : in  std_logic;
    rx_data_in  : in  std_logic_vector (data_width_g -1 downto 0);
    rx_re_out   : out std_logic;
    rx_empty_in : in  std_logic;

    led_out : out std_logic
    );

end led_packet_codec;


architecture rtl of led_packet_codec is

  signal rx_re_out_r : std_logic;
  signal led_out_r   : std_logic;
  
begin  -- rtl

  tx_av_out    <= '0';
  tx_data_out  <= (others => '0');
  tx_we_out    <= '0';
  tx_txlen_out <= (others => '0');
  rx_re_out    <= rx_re_out_r;

  led_out <= led_out_r;


  main_p : process (clk, rst_n)
  begin  -- process main_p
    if rst_n = '0' then  
      
      led_out_r   <= '0';
      rx_re_out_r <= '0';
      
    elsif clk'event and clk = '1' then  


      if rx_empty_in = '0' then
        if rx_re_out_r = '0' then 
          rx_re_out_r <= '1'; 
        else
          if rx_av_in = '1' then

          else

            if to_integer(unsigned(rx_data_in)) = 42 then
              led_out_r <= not led_out_r;
            elsif to_integer(unsigned(rx_data_in)) = 38 then
              led_out_r <= '0';
            else
              led_out_r <= '1';
            end if;
          end if;        
        end if;        
      else
        rx_re_out_r <= '0';
      end if;

    end if;
  end process main_p;

end rtl;

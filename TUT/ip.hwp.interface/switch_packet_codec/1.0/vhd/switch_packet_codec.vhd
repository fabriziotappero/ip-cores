-------------------------------------------------------------------------------
-- Title      : Switch to packet codec
-- Project    : 
-------------------------------------------------------------------------------
-- File       : switch_packet_codec.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Last update: 2012-03-16
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Detects an edge in switch input and generates a constant
--              message to the network.
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

entity switch_packet_codec is

  generic (
    data_width_g   : integer := 32;
    tx_len_width_g : integer := 16;
    my_id_g        : integer);          -- Target network address
                                        -- And yes, very poor name for that

  port (


    clk   : in std_logic;
    rst_n : in std_logic;


    tx_av_out    : out std_logic;
    tx_data_out  : out std_logic_vector (data_width_g -1 downto 0);
    tx_comm_out  : out std_logic_vector (5 -1 downto 0);
    tx_we_out    : out std_logic;
    tx_txlen_out : out std_logic_vector (tx_len_width_g -1 downto 0);
    tx_full_in   : in  std_logic;

    rx_av_in    : in  std_logic;
    rx_data_in  : in  std_logic_vector (data_width_g -1 downto 0);
    rx_re_out   : out std_logic;
    rx_empty_in : in  std_logic;


    switch_in : in std_logic
    );

end switch_packet_codec;



architecture rtl of switch_packet_codec is

  signal tx_av_out_r    : std_logic;
  signal tx_data_out_r  : std_logic_vector(data_width_g-1 downto 0);
  signal tx_we_out_r    : std_logic;
  signal tx_txlen_out_r : std_logic_vector(tx_len_width_g-1 downto 0);

  signal switch_in_r  : std_logic;
  signal switch_in2_r : std_logic;
  signal switch_in3_r : std_logic;

  type   state_type is (idle, addr, data);
  signal state_r : state_type;
  
begin  -- rtl

  tx_av_out    <= tx_av_out_r;
  tx_data_out  <= tx_data_out_r;
  tx_we_out    <= tx_we_out_r;
  tx_txlen_out <= tx_txlen_out_r;
  rx_re_out    <= '0';


  tx_comm_out <= "00010" when tx_we_out_r = '1' else (others => '0');  -- ES 2012-03-16

  main_p : process (clk, rst_n)
  begin  -- process main_p
    if rst_n = '0' then                 -- asynchronous reset (active low)

      tx_av_out_r    <= '0';
      tx_data_out_r  <= (others => '0');
      tx_we_out_r    <= '0';
      tx_txlen_out_r <= (others => '0');
      switch_in_r    <= '0';
      state_r        <= idle;
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      switch_in3_r <= switch_in;
      switch_in2_r <= switch_in3_r;
      switch_in_r  <= switch_in2_r;

      case state_r is
        -----------------------------------------------------------------------
        -- IDLE
        -----------------------------------------------------------------------
        when idle =>
          tx_av_out_r    <= '0';
          tx_data_out_r  <= (others => '0');
          tx_we_out_r    <= '0';
          tx_txlen_out_r <= (others => '0');

          if switch_in2_r /= switch_in_r then
            state_r <= addr;
          end if;

          ---------------------------------------------------------------------
          -- ADDR
          ---------------------------------------------------------------------
        when addr =>
          tx_av_out_r   <= '1';
          tx_data_out_r <=
            std_logic_vector(to_unsigned(my_id_g, data_width_g));
          tx_txlen_out_r <= std_logic_vector(to_unsigned(1, tx_len_width_g));
          tx_we_out_r    <= '1';
          if tx_full_in /= '1' then
            state_r <= data;
          end if;


          ---------------------------------------------------------------------
          -- DATA
          ---------------------------------------------------------------------
        when data =>
          tx_av_out_r    <= '0';
          tx_data_out_r  <= std_logic_vector(to_unsigned(42, data_width_g));
          tx_txlen_out_r <= std_logic_vector(to_unsigned(1, tx_len_width_g));
          tx_we_out_r    <= '1';
          if tx_full_in /= '1' then
            state_r <= idle;
          end if;
          
          
        when others =>
          state_r <= idle;
          
      end case;
      
      
    end if;
  end process main_p;

end rtl;

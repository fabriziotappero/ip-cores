-------------------------------------------------------------------------------
-- Title      : Avalon cfg reader
-- Project    : 
-------------------------------------------------------------------------------
-- File       : avalon_cfg_reader.vhd
-- Author     : kulmala3
-- Created    : 22.03.2005
-- Last update: 2011-11-10
-- Description: testbench block to test the config of the dma via avalon
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 22.03.2005  1.0      AK      Created
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use work.txt_util.all;
--use work.log2_pkg.all;
use work.tb_n2h2_pkg.all;

entity avalon_cfg_reader is
  generic (
    n_chans_g    : integer := 0;
    data_width_g : integer := 0;
    conf_file_g  : string  := ""
    );
  port (
    clk                    : in  std_logic;
    rst_n                  : in  std_logic;
    start_in               : in  std_logic;
    avalon_cfg_addr_out    : out std_logic_vector(log2(n_chans_g)+conf_bits_c-1 downto 0);
    avalon_cfg_readdata_in : in  std_logic_vector(data_width_g-1 downto 0);
    avalon_cfg_re_out      : out std_logic;
    avalon_cfg_cs_out      : out std_logic;
    done_out               : out std_logic
    );
end avalon_cfg_reader;

architecture rtl of avalon_cfg_reader is
  
  signal state_r        : integer;
  signal chan_counter_r : integer;
begin  -- rtl

  -----------------------------------------------------------------------------
  -- Go through states 0-7
  ------------------------------------------------------------------------------
  process (clk, rst_n)
    file conf_file        : text open read_mode is conf_file_g;
    variable mem_addr_r   : integer;
    variable dst_addr_r     : integer;
    variable irq_amount_r : integer;
    variable max_amount_r : integer;
  begin  -- process
    if rst_n = '0' then                 -- asynchronous reset (active low)
      chan_counter_r <= 0;
      avalon_cfg_addr_out <= (others => '0');
      avalon_cfg_re_out <= '0';
      avalon_cfg_cs_out <= '0';
      done_out <= '0';
      state_r <= 0;
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      
      case state_r is
        when 0 =>
          if start_in = '1' then
            state_r             <= 1;
            done_out            <= '0';
            avalon_cfg_addr_out <= conv_std_logic_vector(chan_counter_r, log2(n_chans_g)) &
                                   conv_std_logic_vector(0, conf_bits_c);
            avalon_cfg_re_out   <= '1';
            avalon_cfg_cs_out   <= '1';
          else
            state_r <= 0;
          end if;

        when 1 =>
          read_conf_file (
            mem_addr   => mem_addr_r ,
            dst_addr   => dst_addr_r,
            irq_amount => irq_amount_r,
--            max_amount => max_amount_r,
            file_txt   => conf_file
            );

          assert avalon_cfg_readdata_in = conv_std_logic_vector(mem_addr_r, data_width_g) report "config mismatch mem addr: "  & str(avalon_cfg_readdata_in) severity error;

          state_r             <= 2;
          avalon_cfg_addr_out <= conv_std_logic_vector(chan_counter_r, log2(n_chans_g)) &
                                 conv_std_logic_vector(1, conf_bits_c);
          avalon_cfg_re_out   <= '1';
          avalon_cfg_cs_out   <= '1';

        when 2 =>

          assert avalon_cfg_readdata_in = conv_std_logic_vector(dst_addr_r, data_width_g) report "config mismatch sender addr" severity error;
          avalon_cfg_addr_out <= conv_std_logic_vector(chan_counter_r, log2(n_chans_g)) &
                                 conv_std_logic_vector(2, conf_bits_c);
          avalon_cfg_re_out   <= '1';
          avalon_cfg_cs_out   <= '1';

          state_r <= 3;
          
        when 3 =>

          assert avalon_cfg_readdata_in  = conv_std_logic_vector(irq_amount_r, data_width_g) report "config mismatch irq amount" severity error;
          avalon_cfg_addr_out <= conv_std_logic_vector(chan_counter_r, log2(n_chans_g)) &
                                 conv_std_logic_vector(3, conf_bits_c);
          avalon_cfg_re_out   <= '1';
          avalon_cfg_cs_out   <= '1';

          state_r <= 4;

        when 4 =>
          assert avalon_cfg_readdata_in  = conv_std_logic_vector(mem_addr_r, data_width_g) report "config mismatch curr addr ptr" severity error;
          avalon_cfg_addr_out <= conv_std_logic_vector(chan_counter_r, log2(n_chans_g)) &
                                 conv_std_logic_vector(5, conf_bits_c);
          avalon_cfg_re_out   <= '1';
          avalon_cfg_cs_out   <= '1';

          state_r <= 5;

        when 5 =>
          assert avalon_cfg_readdata_in  = conv_std_logic_vector(0, data_width_g) report "config mismatch inits not reseted" severity error;
          avalon_cfg_re_out   <= '0';

          state_r <= 6;

          
        when 6 =>
          avalon_cfg_cs_out <= '0';
          chan_counter_r    <= chan_counter_r+1;
          state_r           <= 7;

        when 7 =>
          if chan_counter_r = n_chans_g then
            state_r  <= 0;
            done_out <= '1';
          else
            avalon_cfg_addr_out <= conv_std_logic_vector(chan_counter_r, log2(n_chans_g)) &
                                   conv_std_logic_vector(0, conf_bits_c);
            avalon_cfg_re_out   <= '1';
            avalon_cfg_cs_out   <= '1';
            state_r <= 1;
          end if;
          
        when others => null;
      end case;
    end if;
  end process;
  
  
end rtl;

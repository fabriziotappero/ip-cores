-------------------------------------------------------------------------------
-- Title      : Multiclock FIFO
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multiclk_fifo.vhd
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 2010-04-27
-- Description: Synchronous multi-clock FIFO. Note that clock frequencies MUST
-- be realted (synchronized) in order to avoid metastability.
-- Clocks that are asynchronous wrt. each other do not work.
--
-- Note! data must be ready in the data in wrt. faster clock when writing!
-- same applies for re and we
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or modify
--  it under the terms of the Lesser GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.12.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity multiclk_fifo is
  
  generic (
    re_freq_g     : integer := 0;        -- integer multiple of clk_we
    we_freq_g     : integer := 0;        -- or vice versa
    depth_g      : integer := 0;
    data_width_g : integer := 0
    );
  port (
    clk_re : in std_logic;
    clk_we : in std_logic;
    rst_n  : in std_logic;

    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    we_in     : in  std_logic;
    full_out  : out std_logic;
    one_p_out : out std_logic;

    re_in     : in  std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    empty_out : out std_logic;
    one_d_out : out std_logic
    );
end multiclk_fifo;

architecture rtl of multiclk_fifo is

  component fifo
    generic (
      data_width_g : integer;
      depth_g      : integer);
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic);
  end component;

  constant re_per_we_c : integer := re_freq_g / we_freq_g;
  constant we_per_re_c : integer := we_freq_g / re_freq_g;

  -- no 0 to x-1, cuz otherwise range 0 to -1 is possible
  signal re_cnt_r : integer range 0 to re_per_we_c;
  signal we_cnt_r : integer range 0 to we_per_re_c;

  signal data_to_fifo    : std_logic_vector (data_width_g-1 downto 0);
  signal we_to_fifo      : std_logic;
  signal full_from_fifo  : std_logic;
  signal one_p_from_fifo : std_logic;
  signal re_to_fifo      : std_logic;
  signal data_from_fifo  : std_logic_vector (data_width_g-1 downto 0);
  signal empty_from_fifo : std_logic;
  signal one_d_from_fifo : std_logic;
  
begin  -- rtl

  data_to_fifo <= data_in;
  full_out     <= full_from_fifo;
  one_p_out    <= one_p_from_fifo;
  data_out     <= data_from_fifo;
  empty_out    <= empty_from_fifo;
  one_d_out    <= one_d_from_fifo;

  re_gt_we : if re_freq_g >= we_freq_g generate

    fifo_re_gt_we : fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => depth_g)
      port map (
        clk       => clk_re,            -- this is the difference
        rst_n     => rst_n,
        data_in   => data_to_fifo,
        we_in     => we_to_fifo,
        full_out  => full_from_fifo,
        one_p_out => one_p_from_fifo,
        re_in     => re_to_fifo,
        data_out  => data_from_fifo,
        empty_out => empty_from_fifo,
        one_d_out => one_d_from_fifo
        );

    re_to_fifo <= re_in;

    equal : if re_per_we_c = 1 generate
      we_to_fifo <= we_in;
    end generate equal;

    greater : if re_per_we_c > 1 generate
      -- re clk is faster than we
      process (clk_re, rst_n)
      begin  -- process
        if rst_n = '0' then             -- asynchronous reset (active low)
          we_to_fifo <= '0';--we_in;
          re_cnt_r   <= 0;
          
        elsif clk_re'event and clk_re = '1' then  -- rising clock edge
          
          if we_in = '1' then
            if re_cnt_r = re_per_we_c-2 then
              we_to_fifo <= '1';
            else
              we_to_fifo <= '0';
            end if;
            
            if re_cnt_r /= re_per_we_c-1 then
              re_cnt_r <= re_cnt_r+1;
            else
              re_cnt_r <= 0;
            end if;
            
          else
            we_to_fifo <= '0';
            re_cnt_r   <= 0;
          end if;
        end if;
      end process;
      
      
    end generate greater;

    
  end generate re_gt_we;

  we_gt_re : if re_freq_g < we_freq_g generate

    fifo_re_gt_we : fifo
      generic map (
        data_width_g => data_width_g,
        depth_g      => depth_g)
      port map (
        clk       => clk_we,
        rst_n     => rst_n,
        data_in   => data_to_fifo,
        we_in     => we_to_fifo,
        full_out  => full_from_fifo,
        one_p_out => one_p_from_fifo,
        re_in     => re_to_fifo,
        data_out  => data_from_fifo,
        empty_out => empty_from_fifo,
        one_d_out => one_d_from_fifo
        );

    
    we_to_fifo <= we_in;

    -- we clk is faster than re
    process (clk_we, rst_n)
    begin  -- process
      if rst_n = '0' then               -- asynchronous reset (active low)
        re_to_fifo <= '0';--re_in;
        we_cnt_r   <= 0;
        
      elsif clk_we'event and clk_we = '1' then  -- rising clock edge
        if re_in = '1' then
          if we_cnt_r = we_per_re_c-2 then
            re_to_fifo <= '1';
          else
            re_to_fifo <= '0';
          end if;
          if we_cnt_r /= we_per_re_c-1 then
            we_cnt_r <= we_cnt_r+1;
          else
            we_cnt_r <= 0;
          end if;
        else
          re_to_fifo <= '0';
          we_cnt_r   <= 0;
        end if;
      end if;
    end process;

  end generate we_gt_re;
  
end rtl;

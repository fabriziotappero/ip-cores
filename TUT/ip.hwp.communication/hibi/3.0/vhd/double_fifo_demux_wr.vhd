-------------------------------------------------------------------------------
-- File        : double_fifo.vhd
-- Description : Includes two fifos. Multi-clk systems are supported.
--
-- Author      : Lasse Lehtonen
-- Project     : Nocbench, Funbase
-- Design      : 
-- Date        : 1.4.2011
-- Modified    : 
-- TO DO:
--      Rename the entity and file, because mux was actually removed
--      and new write port added by LL (note by ES 2011-10-07)
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


entity double_fifo_demux_wr is

  generic (
    -- 0 synch multiclk, 1 basic GALS,
    -- 2 Gray FIFO (depth=2^n!), 3 mixed clock pausible    
    fifo_sel_g : integer := 0;

    -- needed for fifos 0 (accurate) and 3 (which is faster)    
    re_freq_g     : integer := 1;
    we_freq_g     : integer := 1;
    depth_0_g     : integer := 5;
    depth_1_g     : integer := 5;
    data_width_g  : integer := 32;
    debug_width_g : integer := 0;
    comm_width_g  : integer := 3
    );
  port (
    clk_re     : in std_logic;
    clk_we     : in std_logic;
    -- pulsed clocks. used in pausible clock scheme
    clk_re_pls : in std_logic;
    clk_we_pls : in std_logic;
    rst_n      : in std_logic;

    -- Data inputs
    av_0_in     : in  std_logic;
    data_0_in   : in  std_logic_vector (data_width_g-1 downto 0);
    comm_0_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    we_0_in     : in  std_logic;
    one_p_0_out : out std_logic;
    full_0_out  : out std_logic;

    av_1_in     : in  std_logic;
    data_1_in   : in  std_logic_vector (data_width_g-1 downto 0);
    comm_1_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    we_1_in     : in  std_logic;
    one_p_1_out : out std_logic;
    full_1_out  : out std_logic;

    -- Data outputs
    re_0_in     : in  std_logic;
    av_0_out    : out std_logic;
    data_0_out  : out std_logic_vector (data_width_g-1 downto 0);
    comm_0_out  : out std_logic_vector (comm_width_g-1 downto 0);
    empty_0_out : out std_logic;
    one_d_0_out : out std_logic;

    re_1_in     : in  std_logic;
    av_1_out    : out std_logic;
    data_1_out  : out std_logic_vector (data_width_g-1 downto 0);
    comm_1_out  : out std_logic_vector (comm_width_g-1 downto 0);
    empty_1_out : out std_logic;
    debug_out   : out std_logic_vector(debug_width_g downto 0);
    one_d_1_out : out std_logic
    );
end double_fifo_demux_wr;



architecture structural of double_fifo_demux_wr is

  constant re_faster_c : integer := re_freq_g/we_freq_g;

  component mixed_clk_fifo
    generic (
--      re_freq_g    : integer := 0;      -- integer multiple of clk_we
--      we_freq_g    : integer := 0;      -- or vice versa
      re_faster_g  : integer := 0;
      data_width_g : integer := 0;
      depth_g      : integer := 0
      );
    port (
      clk_re    : in std_logic;
      clk_we    : in std_logic;
      clk_ps_re : in std_logic;         -- phase shifted pulse      
      clk_ps_we : in std_logic;         -- phase shifted pulse      
      rst_n     : in std_logic;

      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;

      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic
      );
  end component;  --fifo;


  component multiclk_fifo
    generic (
      re_freq_g    : integer;
      we_freq_g    : integer;
      depth_g      : integer;
      data_width_g : integer);
    port (
      clk_re    : in  std_logic;
      clk_we    : in  std_logic;
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

  component cdc_fifo
    generic (
      READ_AHEAD_g  : integer;
      SYNC_CLOCKS_g : integer;
      depth_log2_g  : integer;
      dataw_g       : integer);
    port (
      rst_n        : in  std_logic;
      rd_clk       : in  std_logic;
      rd_en_in     : in  std_logic;
      rd_one_d_out : out std_logic;
      rd_empty_out : out std_logic;      
      rd_data_out  : out std_logic_vector(dataw_g-1 downto 0);
      wr_clk       : in  std_logic;
      wr_en_in     : in  std_logic;
      wr_full_out  : out std_logic;
      wr_one_p_out  : out std_logic;
      wr_data_in   : in  std_logic_vector(dataw_g-1 downto 0));
  end component;

  component fifo
    generic (
      data_width_g : integer := 0;
      depth_g      : integer := 0
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;

      re_in     : in  std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic
      );
  end component;  --fifo;


  component fifo_demux_wr
    generic (
      data_width_g : integer := 0;
      comm_width_g : integer := 0
      );
    port (
      -- 13.04 clk                : in  std_logic;
      -- 13.04 rst_n              : in  std_logic;
      av_in     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;

      -- data/comm/AV conencted to both fifos
      -- Distinction made with WE!
      av_out     : out std_logic;
      data_out   : out std_logic_vector (data_width_g-1 downto 0);
      comm_out   : out std_logic_vector (comm_width_g-1 downto 0);
      we_0_out   : out std_logic;
      we_1_out   : out std_logic;
      full_0_in  : in  std_logic;
      full_1_in  : in  std_logic;
      one_p_0_in : in  std_logic;
      one_p_1_in : in  std_logic
      );
  end component;


  component aif_read_top
    generic (
      data_width_g : integer);
    port (
      tx_clk       : in  std_logic;
      tx_rst_n     : in  std_logic;
      tx_data_in   : in  std_logic_vector(data_width_g-1 downto 0);
      tx_empty_in  : in  std_logic;
      tx_re_out    : out std_logic;
      rx_clk       : in  std_logic;
      rx_rst_n     : in  std_logic;
      rx_empty_out : out std_logic;
      rx_re_in     : in  std_logic;
      rx_data_out  : out std_logic_vector(data_width_g-1 downto 0));
  end component;


  signal data_0 : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);
  signal data_1 : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);

  signal data_0_i : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);
  signal data_1_i : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);
  
  signal tx_data_0_to_aif  : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);
  signal tx_data_1_to_aif  : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);
  signal tx_empty_0_to_aif : std_logic;
  signal tx_empty_1_to_aif : std_logic;
  signal tx_re_0_from_aif : std_logic;
  signal tx_re_1_from_aif : std_logic;

  function log2 (
    constant value : integer)
    return integer is
    variable temp    : integer := 1;
    variable counter : integer := 0;
  begin  -- log2
    while temp < value loop
      temp    := temp*2;
      counter := counter+1;
    end loop;

    return counter;
  end log2;
    
begin  -- structural
  
  av_0_out   <= data_0(1 + comm_width_g + data_width_g - 1);
  comm_0_out <= data_0(comm_width_g + data_width_g -1 downto data_width_g);
  data_0_out <= data_0(data_width_g - 1 downto 0);

  av_1_out   <= data_1(1 + comm_width_g + data_width_g - 1);
  comm_1_out <= data_1(comm_width_g + data_width_g -1 downto data_width_g);
  data_1_out <= data_1(data_width_g - 1 downto 0);

  data_0_i <= av_0_in & comm_0_in & data_0_in;
  data_1_i <= av_1_in & comm_1_in & data_1_in;

  multi : if fifo_sel_g = 0 generate
    -- synch multiclk
    
    Map_Fifo_0 : if depth_0_g > 0 generate
      Multiclk_Fifo_0 : multiclk_fifo
        generic map(
          re_freq_g    => re_freq_g,
          we_freq_g    => we_freq_g,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_0_g
          )
        port map(
          clk_re    => clk_re,
          clk_we    => clk_we,
          rst_n     => rst_n,
          data_in   => data_0_i,
          we_in     => we_0_in,
          full_out  => full_0_out,
          one_p_out => one_p_0_out,

          re_in     => re_0_in,
          data_out  => data_0,
          empty_out => empty_0_out,
          one_d_out => one_d_0_out
          );
    end generate Map_Fifo_0;

    Map_Fifo_1 : if depth_1_g > 0 generate
      Multiclk_Fifo_1 : multiclk_fifo
        generic map(
          re_freq_g    => re_freq_g,
          we_freq_g    => we_freq_g,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_1_g
          )
        port map(
          clk_re => clk_re,
          clk_we => clk_we,
          rst_n  => rst_n,

          data_in   => data_1_i,
          we_in     => we_1_in,
          one_p_out => one_p_1_out,
          full_out  => full_1_out,

          re_in     => re_1_in,
          data_out  => data_1,
          empty_out => empty_1_out,
          one_d_out => one_d_1_out
          );
    end generate Map_Fifo_1;

  end generate multi;


  gals : if fifo_sel_g = 1 generate
    -- GALS, may be used with fast synch

    Map_Fifo_0 : if depth_0_g > 0 generate

      aif_read_top_0 : aif_read_top
        generic map (
          data_width_g => 1 + comm_width_g + data_width_g
          )
        port map (
          tx_clk      => clk_we_pls,
          tx_rst_n    => rst_n,
          
          tx_data_in  => tx_data_0_to_aif,
          tx_empty_in => tx_empty_0_to_aif,
          tx_re_out   => tx_re_0_from_aif,

          rx_clk       => clk_re,       -- should be the agent clock...
          rx_rst_n     => rst_n,
          rx_empty_out => empty_0_out,
          rx_re_in     => re_0_in,
          rx_data_out  => data_0
          );

      
      Multiclk_Fifo_0 : multiclk_fifo
        generic map(
          re_freq_g    => re_freq_g,
          we_freq_g    => we_freq_g,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_0_g
          )
        port map(
          clk_re    => clk_we_pls,
          clk_we    => clk_we,
          rst_n     => rst_n,
          data_in   => data_0_i,
          we_in     => we_0_in,
          full_out  => full_0_out,
          one_p_out => one_p_0_out,   --- ???

          re_in     => tx_re_0_from_aif,
          data_out  => tx_data_0_to_aif,
          empty_out => tx_empty_0_to_aif,
          one_d_out => one_d_0_out      -- ???
          );
    end generate Map_Fifo_0;

    Map_Fifo_1 : if depth_1_g > 0 generate
      
      aif_read_top_1 : aif_read_top
        generic map (
          data_width_g => 1 + comm_width_g + data_width_g
          )
        port map (
          tx_clk      => clk_we_pls,
          tx_rst_n    => rst_n,
          tx_data_in  => tx_data_1_to_aif,
          tx_empty_in => tx_empty_1_to_aif,
          tx_re_out   => tx_re_1_from_aif,

          rx_clk       => clk_re,       -- should be the agent clock...
          rx_rst_n     => rst_n,
          rx_empty_out => empty_1_out,
          rx_re_in     => re_1_in,
          rx_data_out  => data_1
          );

      Multiclk_Fifo_1 : multiclk_fifo
        generic map(
          re_freq_g    => re_freq_g,
          we_freq_g    => we_freq_g,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_1_g
          )
        port map(
          clk_re    => clk_we_pls,
          clk_we    => clk_we,
          rst_n     => rst_n,
          data_in   => data_1_i,
          we_in     => we_1_in,
          full_out  => full_1_out,
          one_p_out => one_p_1_out,   --- ???

          re_in     => tx_re_1_from_aif,
          data_out  => tx_data_1_to_aif,
          empty_out => tx_empty_1_to_aif,
          one_d_out => one_d_1_out      -- ???
          );
    end generate Map_Fifo_1;
    
  end generate gals;


  gray : if fifo_sel_g = 2 generate
    -- Gray FIFO
    
    Map_Fifo_0 : if depth_0_g > 0 generate
      cdc_fifo_0 : cdc_fifo
        generic map (
          READ_AHEAD_g  => 1,           -- this is the hibi style, look-ahead
          SYNC_CLOCKS_g => 0,           -- we use two flops
          depth_log2_g  => log2(depth_0_g),
          dataw_g       => 1 + comm_width_g + data_width_g)
        port map (
          rst_n        => rst_n,
          rd_clk       => clk_re,
          rd_en_in     => re_0_in,
          rd_empty_out => empty_0_out,
          rd_one_d_out => one_d_0_out,
          rd_data_out  => data_0,
          
          wr_clk      => clk_we,
          wr_en_in    => we_0_in,
          wr_full_out => full_0_out,
          wr_one_p_out => one_p_0_out,
          wr_data_in  => data_0_i
          );          

    end generate Map_Fifo_0;


    Map_Fifo_1 : if depth_1_g > 0 generate
      cdc_fifo_1 : cdc_fifo
        generic map (
          READ_AHEAD_g  => 1,           -- this is the hibi style, look-ahead
          SYNC_CLOCKS_g => 0,           -- we use two flops
          depth_log2_g  => log2(depth_1_g),
          dataw_g       => 1 + comm_width_g + data_width_g
          )
        port map (
          rst_n        => rst_n,
          rd_clk       => clk_re,
          rd_en_in     => re_1_in,
          rd_empty_out => empty_1_out,
          rd_one_d_out => one_d_1_out,          
          rd_data_out  => data_1,

          wr_clk      => clk_we,
          wr_en_in    => we_1_in,
          wr_full_out => full_1_out,
          wr_one_p_out => one_p_1_out,          
          wr_data_in  => data_1_i
          );
    end generate Map_Fifo_1;

  end generate gray;

  mixed : if fifo_sel_g = 3 generate
    
    Map_Fifo_0 : if depth_0_g > 0 generate
      Mixed_clk_Fifo_0 : mixed_clk_fifo
        generic map(
          re_faster_g  => re_faster_c,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_0_g
          )
        port map(
          clk_re    => clk_re,
          clk_we    => clk_we,
          clk_ps_we => clk_we_pls,
          clk_ps_re => clk_re_pls,
          rst_n     => rst_n,

          data_in   => data_0_i,
          we_in     => we_0_in,
          full_out  => full_0_out,
          one_p_out => one_p_0_out,

          re_in     => re_0_in,
          data_out  => data_0,
          empty_out => empty_0_out,
          one_d_out => one_d_0_out
          );
    end generate Map_Fifo_0;

    Map_Fifo_1 : if depth_1_g > 0 generate
      Mixed_clk_Fifo_1 : mixed_clk_fifo
        generic map(
          re_faster_g  => re_faster_c,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_1_g
          )
        port map(
          clk_re    => clk_re,
          clk_we    => clk_we,
          clk_ps_we => clk_we_pls,
          clk_ps_re => clk_re_pls,
          rst_n     => rst_n,

          data_in   => data_1_i,
          we_in     => we_1_in,
          one_p_out => one_p_1_out,
          full_out  => full_1_out,

          re_in     => re_1_in,
          data_out  => data_1,
          empty_out => empty_1_out,
          one_d_out => one_d_1_out
          );
    end generate Map_Fifo_1;

  end generate mixed;


  Not_Map_Fifo_0 : if depth_0_g = 0 generate

--    assert false report "Do not map fifo 0."
--      & " This fails because there's no logic to convert "
--      & " WE interface to RE interface" severity failure;

    full_0_out <= '1';
    one_p_0_out <= '0';
      
    empty_0_out <= '1';
    one_d_0_out <= '0';
    
  end generate Not_Map_Fifo_0;

  Not_Map_Fifo_1 : if depth_1_g = 0 generate

    assert false report "Do not map fifo 0."
      & " This fails because there's no logic to convert "
      & " WE interface to RE interface" severity failure;

  end generate Not_Map_Fifo_1;
  
end structural;





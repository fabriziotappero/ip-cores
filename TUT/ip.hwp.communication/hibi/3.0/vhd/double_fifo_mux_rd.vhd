-------------------------------------------------------------------------------
-- File        : double_fifo_mux_rd.vhd
-- Description : Includes two fifos and a special multiplexer
--               so that the reader sees only one fifo. Multiplexer
--               selects addr+data first from fifo 0 (i.e. it has a higher priority)
-- Author      : Erno Salminen
-- Project      
-- Design      : 
-- Date        : 07.02.2003
-- Modified    : 
--
--15.12.04      ES names changed
--18.12.2006 AK modified to support different kinds of IF fifos
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



entity double_fifo_mux_rd is

  generic (
    -- 0 synch multiclk, 1 basic GALS,
    -- 2 Gray FIFO (depth=2^n!), 3 mixed clock pausible
    fifo_sel_g : integer;

    -- needed for fifos 0 (accurate) and 3 (to know which is faster, wr or rd)
    re_freq_g       : integer;
    we_freq_g       : integer;
    depth_0_g       : integer;          -- #words, log2 for fifo 2!
    depth_1_g       : integer;          -- -"-
    data_width_g    : integer;          -- in bits
    debug_width_g   : integer;          -- for debugging
    comm_width_g    : integer;
    separate_addr_g : integer
    );
  port (
    clk_re     : in std_logic;
    clk_we     : in std_logic;
    -- pulsed clocks. used in pausible clock scheme
    -- used in 1 for faster synchronization, when they are integer multiples
    -- of re and we (can also be 1 if the same as clk_re and clk_we
    clk_re_pls : in std_logic;
    clk_we_pls : in std_logic;
    rst_n      : in std_logic;

    av_0_in     : in  std_logic;
    data_0_in   : in  std_logic_vector (data_width_g-1 downto 0);
    comm_0_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    we_0_in     : in  std_logic;
    full_0_out  : out std_logic;
    one_p_0_out : out std_logic;

    av_1_in     : in  std_logic;
    data_1_in   : in  std_logic_vector (data_width_g-1 downto 0);
    comm_1_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    we_1_in     : in  std_logic;
    full_1_out  : out std_logic;
    one_p_1_out : out std_logic;

    re_in     : in  std_logic;
    av_out    : out std_logic;
    data_out  : out std_logic_vector (data_width_g-1 downto 0);
    comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
    empty_out : out std_logic;
    one_d_out : out std_logic;
    debug_out : out std_logic_vector(debug_width_g downto 0)
    );
end double_fifo_mux_rd;



architecture structural of double_fifo_mux_rd is

  -- Mixed-clk fifo must know which faster, reader or writer
  constant re_faster_c : integer := re_freq_g/we_freq_g;

  
  --
  --
  --
  -- one_p currently statically at '0' ...
  component mixed_clk_fifo
    generic (
      re_faster_g  : integer := 1;      -- integer multiple of clk_we
--      we_freq_g    : integer := 0;      -- or vice versa
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
      one_d_out : out std_logic;
      empty_out : out std_logic
      );
  end component;  --multiclk_fifo;

  --
  --
  --
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
  -- basic gals, for fifo 1
  component aif_we_top
    generic (
      data_width_g : integer);
    port (
      tx_clk      : in  std_logic;
      tx_rst_n    : in  std_logic;
      tx_we_in    : in  std_logic;
      tx_data_in  : in  std_logic_vector(data_width_g-1 downto 0);
      tx_full_out : out std_logic;
      rx_clk      : in  std_logic;
      rx_rst_n    : in  std_logic;
      rx_full_in  : in  std_logic;
      rx_we_out   : out std_logic;
      rx_data_out : out std_logic_vector(data_width_g-1 downto 0));
  end component;

  --
  --
  --
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
      rd_empty_out : out std_logic;
      rd_one_d_out : out std_logic;
      rd_data_out  : out std_logic_vector(dataw_g-1 downto 0);
      wr_clk       : in  std_logic;
      wr_en_in     : in  std_logic;
      wr_full_out  : out std_logic;
      wr_one_p_out : out std_logic;
      wr_data_in   : in  std_logic_vector(dataw_g-1 downto 0));
  end component;

  component fifo_mux_rd
    generic (
      data_width_g    : integer;
      comm_width_g    : integer;
      separate_addr_g : integer
      );
    port (
      clk   : in std_logic;
      rst_n : in std_logic;

      av_0_in    : in  std_logic;
      data_0_in  : in  std_logic_vector (data_width_g-1 downto 0);
      comm_0_in  : in  std_logic_vector (comm_width_g-1 downto 0);
      empty_0_in : in  std_logic;
      one_d_0_in : in  std_logic;
      re_0_out   : out std_logic;

      av_1_in    : in  std_logic;
      data_1_in  : in  std_logic_vector (data_width_g-1 downto 0);
      comm_1_in  : in  std_logic_vector (comm_width_g-1 downto 0);
      empty_1_in : in  std_logic;
      one_d_1_in : in  std_logic;
      re_1_out   : out std_logic;

      re_in     : in  std_logic;
      av_out    : out std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      comm_out  : out std_logic_vector (comm_width_g-1 downto 0);
      empty_out : out std_logic;
      one_d_out : out std_logic
      );
  end component;  --fifo_mux_rd;



  
  -- from inputs to fifos (addr_valid + comm + data concatenated together)
  signal a_c_d_input_f0 : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);
  signal a_c_d_input_f1 : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);

  -- from fifo 0 to mux
  signal a_c_d_f0_mux : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);
  signal av_f0_mux    : std_logic;
  signal data_f0_mux  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_f0_mux  : std_logic_vector (comm_width_g-1 downto 0);
  signal empty_f0_mux : std_logic;
  signal one_d_f0_mux : std_logic;

  -- from fifo 1 to mux
  signal a_c_d_f1_mux : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);
  signal av_f1_mux    : std_logic;
  signal data_f1_mux  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_f1_mux  : std_logic_vector (comm_width_g-1 downto 0);
  signal empty_f1_mux : std_logic;
  signal one_d_f1_mux : std_logic;


  -- Control signals from mux to fifos
  signal re_mux_f0 : std_logic;
  signal re_mux_f1 : std_logic;


  signal Tie_High : std_logic;
  signal Tie_Low  : std_logic;

  
  -- For asynch. interface (aif) used with fifo_sel=1
  signal tx_we_to_we_aif     : std_logic;
  signal tx_data_to_we_aif   : std_logic_vector(data_width_g+comm_width_g+1-1 downto 0);
  signal tx_full_from_we_aif : std_logic;

  signal rx_full_to_we_aif   : std_logic;
  signal rx_we_from_we_aif   : std_logic;
  signal rx_data_from_we_aif : std_logic_vector(data_width_g+comm_width_g+1-1 downto 0);

  signal tx_msg_we_to_we_aif     : std_logic;
  signal tx_msg_data_to_we_aif   : std_logic_vector(data_width_g+comm_width_g+1-1 downto 0);
  signal tx_msg_full_from_we_aif : std_logic;

  signal rx_msg_full_to_we_aif   : std_logic;
  signal rx_msg_we_from_we_aif   : std_logic;
  signal rx_msg_data_from_we_aif : std_logic_vector(data_width_g+comm_width_g+1-1 downto 0);



  -- Helper function (needed at least for Gray fifo)
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
  -- Check generics
  assert (depth_0_g + depth_1_g > 0) report "Both fifo depths zero!" severity warning;

  -- Concurrent assignments
  Tie_High       <= '1';
  Tie_Low        <= '0';


  -- Combine fifo inputs
  a_c_d_input_f0 <= av_0_in & comm_0_in & data_0_in;
  a_c_d_input_f1 <= av_1_in & comm_1_in & data_1_in;

  -- Split fifo output
  av_f0_mux   <= a_c_d_f0_mux (1+comm_width_g + data_width_g-1);
  comm_f0_mux <= a_c_d_f0_mux (comm_width_g + data_width_g-1 downto data_width_g);
  data_f0_mux <= a_c_d_f0_mux (data_width_g-1 downto 0);
  av_f1_mux   <= a_c_d_f1_mux (1+comm_width_g + data_width_g-1);
  comm_f1_mux <= a_c_d_f1_mux (comm_width_g + data_width_g-1 downto data_width_g);
  data_f1_mux <= a_c_d_f1_mux (data_width_g-1 downto 0);

  --
  -- Lots of if-generates depending on which fifo type is selected
  -- and if both fifos are really needed
  -- 

  
  multi : if fifo_sel_g = 0 generate
    -- regular / multiclock synchronous
    
    Map_Fifo_0 : if depth_0_g > 0 generate
      multiclk_fifo_0 : multiclk_fifo
        generic map(
          re_freq_g    => re_freq_g,
          we_freq_g    => we_freq_g,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_0_g
          )
        port map(
          clk_re => clk_re,
          clk_we => clk_we,
          rst_n  => rst_n,

          data_in   => a_c_d_input_f0,
          we_in     => we_0_in,
          full_out  => full_0_out,
          one_p_out => one_p_0_out,

          re_in     => re_mux_f0,
          data_out  => a_c_d_f0_mux,
          one_d_out => one_d_f0_mux,
          empty_out => empty_f0_mux
          );
    end generate Map_Fifo_0;


    Map_Fifo_1 : if depth_1_g > 0 generate
      multiclk_fifo_1 : multiclk_fifo
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

          data_in   => a_c_d_input_f1,
          we_in     => we_1_in,
          full_out  => full_1_out,
          one_p_out => one_p_1_out,

          re_in     => re_mux_f1,
          data_out  => a_c_d_f1_mux,
          one_d_out => one_d_f1_mux,
          empty_out => empty_f1_mux
          );
    end generate Map_Fifo_1;

  end generate multi;


  

  gals : if fifo_sel_g = 1 generate

    -- GALS basic + multiclk

    -- signal assigments needed for asynchronous modes

    -- agent writes.

    Map_Fifo_0 : if depth_0_g > 0 generate
      
      aif_we_top_0 : aif_we_top
        generic map (
          data_width_g => data_width_g+comm_width_g+1)
        port map (
          tx_clk      => clk_we,
          tx_rst_n    => rst_n,
          tx_we_in    => we_0_in,
          tx_data_in  => a_c_d_input_f0,
          tx_full_out => full_0_out,

          rx_clk      => clk_re_pls,
          rx_rst_n    => rst_n,
          rx_full_in  => rx_full_to_we_aif,
          rx_we_out   => rx_we_from_we_aif,
          rx_data_out => rx_data_from_we_aif
          );

      multiclk_fifo_0 : multiclk_fifo
        generic map(
          re_freq_g    => re_freq_g,    -- HIBI reading side
          we_freq_g    => we_freq_g,    -- Writing agent OR HIBI synch clk
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_0_g
          )
        port map(
          clk_re => clk_re,
          clk_we => clk_re_pls,         -- HIBI synch clk
          rst_n  => rst_n,

          data_in   => rx_data_from_we_aif,
          we_in     => rx_we_from_we_aif,
          full_out  => rx_full_to_we_aif,
          one_p_out => one_p_0_out,     -- ???

          re_in     => re_mux_f0,
          data_out  => a_c_d_f0_mux,
          one_d_out => one_d_f0_mux,
          empty_out => empty_f0_mux
          );
    end generate Map_Fifo_0;

    Map_Fifo_1 : if depth_1_g > 0 generate

      -- agent msg writes.
      aif_we_top_1 : aif_we_top
        generic map (
          data_width_g => data_width_g+comm_width_g+1)
        port map (
          tx_clk      => clk_we,
          tx_rst_n    => rst_n,
          tx_we_in    => we_1_in,
          tx_data_in  => a_c_d_input_f1,
          tx_full_out => full_1_out,

          rx_clk      => clk_re_pls,
          rx_rst_n    => rst_n,
          rx_full_in  => rx_msg_full_to_we_aif,
          rx_we_out   => rx_msg_we_from_we_aif,
          rx_data_out => rx_msg_data_from_we_aif
          );

      multiclk_fifo_1 : multiclk_fifo
        generic map(
          re_freq_g    => re_freq_g,
          we_freq_g    => we_freq_g,
          data_width_g => 1 + comm_width_g + data_width_g,
          depth_g      => depth_1_g
          )
        port map(
          clk_re => clk_re,
          clk_we => clk_re_pls,
          rst_n  => rst_n,

          data_in   => rx_msg_data_from_we_aif,
          we_in     => rx_msg_we_from_we_aif,
          full_out  => rx_msg_full_to_we_aif,
          one_p_out => one_p_1_out,

          re_in     => re_mux_f1,
          data_out  => a_c_d_f1_mux,
          one_d_out => one_d_f1_mux,
          empty_out => empty_f1_mux
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
          dataw_g       => 1 + comm_width_g + data_width_g
          )
        port map (
          rst_n        => rst_n,
          rd_clk       => clk_re,
          rd_en_in     => re_mux_f0,
          rd_empty_out => empty_f0_mux,
          rd_one_d_out => one_d_f0_mux,
          rd_data_out  => a_c_d_f0_mux,

          wr_clk       => clk_we,
          wr_en_in     => we_0_in,
          wr_full_out  => full_0_out,
          wr_one_p_out => one_p_0_out,
          wr_data_in   => a_c_d_input_f0
          );

--      one_p_0_out <= '0';

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
          rd_en_in     => re_mux_f1,
          rd_empty_out => empty_f1_mux,
          rd_one_d_out => one_d_f1_mux,
          rd_data_out  => a_c_d_f1_mux,

          wr_clk       => clk_we,
          wr_en_in     => we_1_in,
          wr_full_out  => full_1_out,
          wr_one_p_out => one_p_1_out,
          wr_data_in   => a_c_d_input_f1
          );

--      one_p_1_out <= '0';

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

          data_in   => a_c_d_input_f0,
          we_in     => we_0_in,
          full_out  => full_0_out,
          one_p_out => one_p_0_out,

          re_in     => re_mux_f0,
          data_out  => a_c_d_f0_mux,
          one_d_out => one_d_f0_mux,
          empty_out => empty_f0_mux
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

          data_in   => a_c_d_input_f1,
          we_in     => we_1_in,
          full_out  => full_1_out,
          one_p_out => one_p_1_out,

          re_in     => re_mux_f1,
          data_out  => a_c_d_f1_mux,
          one_d_out => one_d_f1_mux,
          empty_out => empty_f1_mux
          );
    end generate Map_Fifo_1;

  end generate mixed;

  --
  -- Deactivate signals "coming from fifo" that was not
  -- instantiated (depth=0)
  --

  Not_Map_Fifo_0 : if depth_0_g = 0 generate
    -- Fifo #0 does not exist!
    a_c_d_f0_mux <= (others => '0');
    empty_f0_mux <= Tie_High;
    one_d_f0_mux <= Tie_Low;
    full_0_out   <= Tie_High;
    one_p_0_out  <= Tie_Low;

    -- Connect the other fifo (#1)straight to the outputs ( =>  FSM)
    av_out    <= av_f1_mux;
    data_out  <= data_f1_mux;
    comm_out  <= comm_f1_mux;
    empty_out <= empty_f1_mux;
    one_d_out <= one_d_f1_mux;

    re_mux_f1 <= re_in;                 --15.05

  end generate Not_Map_Fifo_0;


  Not_Map_Fifo_1 : if depth_1_g = 0 generate
    -- Fifo #1 does not exist!

    -- Signals fifo#1=> IP
    --     full_1_out  <= Tie_High;
    --     one_p_1_out <= Tie_Low;

    -- Signals fifo#1=> FSM
    a_c_d_f1_mux <= (others => '0');
    empty_f1_mux <= Tie_High;
    one_d_f1_mux <= Tie_Low;

    -- Connect the other fifo (#0)straight to the outputs ( =>  FSM)
    av_out    <= av_f0_mux;
    data_out  <= data_f0_mux;
    comm_out  <= comm_f0_mux;
    empty_out <= empty_f0_mux;
    one_d_out <= one_d_f0_mux;

    re_mux_f0 <= re_in;                 --15.05

  end generate Not_Map_Fifo_1;


  --
  -- Include a special multiplexer if both fifos are present
  --
  Map_mux : if depth_0_g > 0 and depth_1_g > 0 generate
    -- Multiplexer is needed only if two fifos are used
    MUX_01 : fifo_mux_rd
      generic map(
        data_width_g    => data_width_g,
        comm_width_g    => comm_width_g,
        separate_addr_g => separate_addr_g
        )
      port map(
        clk   => clk_re,
        rst_n => rst_n,

        av_0_in    => av_f0_mux,
        data_0_in  => data_f0_mux,
        comm_0_in  => comm_f0_mux,
        empty_0_in => empty_f0_mux,
        one_d_0_in => one_d_f0_mux,
        re_0_out   => re_mux_f0,

        av_1_in    => av_f1_mux,
        data_1_in  => data_f1_mux,
        comm_1_in  => comm_f1_mux,
        empty_1_in => empty_f1_mux,
        one_d_1_in => one_d_f1_mux,
        re_1_out   => re_mux_f1,

        re_in     => re_in,
        av_out    => av_out,
        data_out  => data_out,
        comm_out  => comm_out,
        empty_out => empty_out,
        one_d_out => one_d_out
        );
  end generate Map_mux;


  






  
end structural;




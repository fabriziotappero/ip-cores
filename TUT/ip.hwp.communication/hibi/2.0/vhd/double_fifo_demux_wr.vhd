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
-------------------------------------------------------------------------------
-- File        : double_fifo_demux_wr.vhd
-- Description : Double_Fifo_Demux_wr buffer for hibi v.2 interface
--               Includes two fifos and a special demultiplexer,
--               has 1 input and 2 output ports
--               so that the writer sees only one fifo. Demultiplexer
--               directs addr+data to correct fifo (0 = for messages)
--
--               This version includes an extra fifo at the input the to get
--               One_Place_Left_Out and Full_Out signals correctly timed
--
-- Author      : Erno salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : huuhaa
-- Design      : Do not use term design when you mean system
-- Date        : 08.04.2003
-- Modified    : 
-- 24.07.03     ES added extra fifo in input, changed file name. Extra fifo
--                      provides signals "full" and "one_p" correctly
--18.12.2006 AK modified to support different kinds of IF fifos

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

    av_in     : in  std_logic;
    data_in   : in  std_logic_vector (data_width_g-1 downto 0);
    comm_in   : in  std_logic_vector (comm_width_g-1 downto 0);
    we_in     : in  std_logic;
    one_p_out : out std_logic;
    full_out  : out std_logic;

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

  -- inputs to extra fifo (xf)
  signal a_c_d_input_xf : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);


  -- from extra fifo to demux, 24.07 es
  signal a_c_d_xf_demux : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);
  signal data_xf_demux  : std_logic_vector (data_width_g-1 downto 0);
  signal comm_xf_demux  : std_logic_vector (comm_width_g-1 downto 0);
  signal av_xf_demux    : std_logic;
  signal empty_xf_demux : std_logic;
  signal we_xf_demux    : std_logic;

  signal re_demux_xf   : std_logic;
  signal full_demux_xf : std_logic;
  -- signal one_p_demux_xf : std_logic; ei tarvi


  -- signals to fifos (either from inputs or from demux)
  signal a_c_d_to_f01 : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);

  signal we_to_f0      : std_logic;
  signal full_from_f0  : std_logic;
  signal one_p_from_f0 : std_logic;

  signal we_to_f1      : std_logic;
  signal full_from_f1  : std_logic;
  signal one_p_from_f1 : std_logic;


  -- from fifos to output
  signal a_c_d_f0_output : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);
  signal a_c_d_f1_output : std_logic_vector (1 + comm_width_g + data_width_g-1 downto 0);

  -- logical zero and one
  signal Tie_High : std_logic;
  signal Tie_Low  : std_logic;

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

  signal tx_data_to_aif  : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);
  signal tx_empty_to_aif : std_logic;
  signal tx_re_from_aif  : std_logic;

  signal rx_empty_from_aif : std_logic;
  signal rx_re_to_aif      : std_logic;
  signal rx_data_from_aif  : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);

  signal tx_msg_data_to_aif  : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);
  signal tx_msg_empty_to_aif : std_logic;
  signal tx_msg_re_from_aif  : std_logic;

  signal rx_msg_empty_from_aif : std_logic;
  signal rx_msg_re_to_aif      : std_logic;
  signal rx_msg_data_from_aif  : std_logic_vector(1+comm_width_g+data_width_g-1 downto 0);

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
  Tie_High <= '1';
  Tie_Low  <= '0';


  -- Splitting the data from fifo outputs
  av_0_out   <= a_c_d_f0_output (1 + comm_width_g + data_width_g -1);
  comm_0_out <= a_c_d_f0_output (comm_width_g + data_width_g -1 downto data_width_g);
  data_0_out <= a_c_d_f0_output (data_width_g -1 downto 0);

  av_1_out   <= a_c_d_f1_output (1+ comm_width_g + data_width_g -1);
  comm_1_out <= a_c_d_f1_output (comm_width_g + data_width_g -1 downto data_width_g);
  data_1_out <= a_c_d_f1_output (data_width_g -1 downto 0);

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
          data_in   => a_c_d_to_f01,
          we_in     => we_to_f0,
          full_out  => full_from_f0,
          one_p_out => one_p_from_f0,

          re_in     => re_0_in,
          data_out  => a_c_d_f0_output,
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

          data_in   => a_c_d_to_f01,
          we_in     => we_to_f1,
          one_p_out => one_p_from_f1,
          full_out  => full_from_f1,

          re_in     => re_1_in,
          data_out  => a_c_d_f1_output,
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
          tx_data_in  => tx_data_to_aif,
          tx_empty_in => tx_empty_to_aif,
          tx_re_out   => tx_re_from_aif,

          rx_clk       => clk_re,       -- should be the agent clock...
          rx_rst_n     => rst_n,
          rx_empty_out => empty_0_out,
          rx_re_in     => re_0_in,
          rx_data_out  => a_c_d_f0_output
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
          data_in   => a_c_d_to_f01,
          we_in     => we_to_f0,
          full_out  => full_from_f0,
          one_p_out => one_p_from_f0,   --- ???

          re_in     => tx_re_from_aif,
          data_out  => tx_data_to_aif,
          empty_out => tx_empty_to_aif,
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
          tx_data_in  => tx_msg_data_to_aif,
          tx_empty_in => tx_msg_empty_to_aif,
          tx_re_out   => tx_msg_re_from_aif,

          rx_clk       => clk_re,       -- should be the agent clock...
          rx_rst_n     => rst_n,
          rx_empty_out => empty_1_out,
          rx_re_in     => re_1_in,
          rx_data_out  => a_c_d_f1_output
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
          data_in   => a_c_d_to_f01,
          we_in     => we_to_f1,
          full_out  => full_from_f1,
          one_p_out => one_p_from_f1,   --- ???

          re_in     => tx_msg_re_from_aif,
          data_out  => tx_msg_data_to_aif,
          empty_out => tx_msg_empty_to_aif,
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
          rd_data_out  => a_c_d_f0_output,
          
          wr_clk      => clk_we,
          wr_en_in    => we_to_f0,
          wr_full_out => full_from_f0,
          wr_one_p_out => one_p_from_f0,
          wr_data_in  => a_c_d_to_f01
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
          rd_data_out  => a_c_d_f1_output,

          wr_clk      => clk_we,
          wr_en_in    => we_to_f1,
          wr_full_out => full_from_f1,
          wr_one_p_out => one_p_from_f1,          
          wr_data_in  => a_c_d_to_f01
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

          data_in   => a_c_d_to_f01,
          we_in     => we_to_f0,
          full_out  => full_from_f0,
          one_p_out => one_p_from_f0,

          re_in     => re_0_in,
          data_out  => a_c_d_f0_output,
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

          data_in   => a_c_d_to_f01,
          we_in     => we_to_f1,
          one_p_out => one_p_from_f1,
          full_out  => full_from_f1,

          re_in     => re_1_in,
          data_out  => a_c_d_f1_output,
          empty_out => empty_1_out,
          one_d_out => one_d_1_out
          );
    end generate Map_Fifo_1;

  end generate mixed;


  Not_Map_Fifo_0 : if depth_0_g = 0 generate

    assert false report "Do not map fifo 0 (depth=0)" severity note;

    -- Fifo #0 and demux does not exist!
    a_c_d_f0_output <= (others => '0');
    empty_0_out     <= Tie_High;
    one_d_0_out     <= Tie_Low;
    full_from_f0    <= Tie_High;
    one_p_from_f0   <= Tie_Low;
    we_to_f0        <= Tie_Low;

    -- Connect the other fifo (#1) straight to the outputs/inputs
    one_p_out <= one_p_from_f1;
    full_out  <= full_from_f1;

    -- replace with concatenation?
    a_c_d_to_f01(comm_width_g + data_width_g)                       <= av_in;
    a_c_d_to_f01(comm_width_g + data_width_g-1 downto data_width_g) <= comm_in;
    a_c_d_to_f01(data_width_g-1 downto 0)                           <= data_in;

    we_to_f1 <= we_in;
  end generate Not_Map_Fifo_0;

  Not_Map_Fifo_1 : if depth_1_g = 0 generate
    assert false report "Do not map fifo 1 (depth_g = 0)" severity note;
    -- Fifo #1 and demux does not exist!
    a_c_d_f1_output <= (others => '0');
    empty_1_out     <= Tie_High;
    one_d_1_out     <= Tie_Low;
    full_from_f1    <= Tie_High;
    one_p_from_f1   <= Tie_Low;
    we_to_f1        <= Tie_Low;

    -- Connect the other fifo (#0) straight to the outputs/inputs
    one_p_out <= one_p_from_f0;
    full_out  <= full_from_f0;

    -- replace with concatenation?
    a_c_d_to_f01(1 + comm_width_g + data_width_g -1)                 <= av_in;
    a_c_d_to_f01(comm_width_g + data_width_g -1 downto data_width_g) <= comm_in;
    a_c_d_to_f01(data_width_g -1 downto 0)                           <= data_in;



    we_to_f0 <= we_in;

  end generate Not_Map_Fifo_1;


  Map_Demux : if depth_0_g > 0 and depth_1_g > 0 generate
    -- Demultiplexer is needed only if two fifos are used
    DEMUX_01 : fifo_demux_wr
      generic map(
        data_width_g => data_width_g,
        comm_width_g => comm_width_g
        )
      port map(

        data_in  => data_xf_demux,
        comm_in  => comm_xf_demux,
        av_in    => av_xf_demux,
        we_in    => we_xf_demux,
        full_out => full_demux_xf,
        --one_p_out => one_p_demux_xf,


        av_out   => a_c_d_to_f01 (1 + comm_width_g + data_width_g -1),
        comm_out => a_c_d_to_f01 (comm_width_g + data_width_g -1 downto data_width_g),
        data_out => a_c_d_to_f01 (data_width_g -1 downto 0),

        we_0_out   => we_to_f0,
        we_1_out   => we_to_f1,
        full_0_in  => full_from_f0,
        full_1_in  => full_from_f1,
        one_p_0_in => one_p_from_f0,
        one_p_1_in => one_p_from_f1
        );
  end generate Map_Demux;


  Map_xtrafifo : if depth_0_g > 0 and depth_1_g > 0 generate
    -- Xtra fifo is needed only if two fifos (and demux) are used
--    xtra_in_fifo : multiclk_fifo
    xtra_in_fifo : fifo
      -- regular FIFO
      generic map (
        data_width_g => 1+ comm_width_g + data_width_g,
        depth_g      => 3
        )
      port map(
        clk   => clk_we,
        rst_n => rst_n,

        data_in   => a_c_d_input_xf,
        we_in     => we_in,
        one_p_out => one_p_out,
        full_out  => full_out,

        re_in     => re_demux_xf,
        data_out  => a_c_d_xf_demux,
        empty_out => empty_xf_demux     --,
        --one_d_out => one_d_1_out
        );

    -- Handshaking between xtra fifo and demux
    we_xf_demux <= not empty_xf_demux;
    re_demux_xf <= not full_demux_xf;

    -- Split extra fifo output before feeding it to demux
    av_xf_demux   <= a_c_d_xf_demux (1 + comm_width_g + data_width_g -1);
    comm_xf_demux <= a_c_d_xf_demux (comm_width_g + data_width_g -1 downto data_width_g);
    data_xf_demux <= a_c_d_xf_demux (data_width_g -1 downto 0);

    -- Join inputs for xtra fifo
    a_c_d_input_xf <= av_in & comm_in & data_in;

  end generate Map_xtrafifo;
  
end structural;





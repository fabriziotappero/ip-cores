-------------------------------------------------------------------------------
-- Title      : Mixed clock FIFO
-- Project    :
-------------------------------------------------------------------------------
-- File       : 
-- Author     : kulmala3
-- Created    : 16.12.2005
-- Last update: 18.12.2006
-- Description: This aims to include possibility to have the
-- synchronization interface on both sides instead of fixed re faster scheme.
--
-- NOTE! one_p may be high when full is also high
-- one_d is high when empty is '0'.
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-- Works in fpga testbench. 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 16.12.2005  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mixed_clk_fifo is
  
  generic (
    re_faster_g : integer := 1; -- 0 we faster, 1 re faster.
    depth_g      : integer := 0;
    data_width_g : integer := 0
    );
  port (
    clk_re    : in std_logic;
    clk_ps_re : in std_logic;           -- phase shifted pulse
    clk_we    : in std_logic;
    clk_ps_we : in std_logic;           -- phase shifted pulse
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
end mixed_clk_fifo;

architecture rtl of mixed_clk_fifo is

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

  component we_pulse_synchronizer
    generic (
      data_width_g : integer);
    port (
      clk_re    : in  std_logic;
      clk_ps_re : in  std_logic;
      clk_we    : in  std_logic;
      clk_ps_we : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      we_in     : in  std_logic;
      full_out  : out std_logic;
      one_p_out : out std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      we_out    : out std_logic;
      full_in   : in  std_logic;
      one_p_in  : in  std_logic);
  end component;

  component re_pulse_synchronizer
    generic (
      data_width_g : integer);
    port (
      clk_re    : in  std_logic;
      clk_ps_re : in  std_logic;
      clk_we    : in  std_logic;
      clk_ps_we : in  std_logic;
      rst_n     : in  std_logic;
      data_in   : in  std_logic_vector (data_width_g-1 downto 0);
      empty_in  : in  std_logic;
      re_out    : out std_logic;
      data_out  : out std_logic_vector (data_width_g-1 downto 0);
      re_in     : in  std_logic;
      empty_out : out std_logic);
  end component;
  
  signal data_to_fifo : std_logic_vector (data_width_g-1 downto 0);
  signal we_to_fifo   : std_logic;

  signal full_from_fifo  : std_logic;
  signal one_p_from_fifo : std_logic;
  signal re_to_fifo      : std_logic;
  signal data_from_fifo  : std_logic_vector (data_width_g-1 downto 0);
  signal empty_from_fifo : std_logic;
  signal one_d_from_fifo : std_logic;

  signal full_out_from_synch : std_logic;
  signal empty_out_from_synch : std_logic;
  signal one_p_from_synch : std_logic;

  signal clk_fifo : std_logic;
begin  -- rtl


  regular_fifo : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => depth_g)
    port map (
      clk       => clk_fifo,
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
  
refaster: if re_faster_g > 0 generate
  
  we_pulse_synchronizer_1: we_pulse_synchronizer
    generic map (
      data_width_g => data_width_g)
    port map (
      clk_re    => clk_re,
      clk_ps_re => clk_ps_re,
      clk_we    => clk_we,
      clk_ps_we => clk_ps_we,
      rst_n     => rst_n,
      -- to/from we domain
      data_in   => data_in,
      we_in     => we_in,
      full_out  => full_out_from_synch,
      one_p_out => one_p_from_synch,
      -- to/from re domain
      data_out  => data_to_fifo,
      we_out    => we_to_fifo,
      full_in   => full_from_fifo,
      one_p_in  => one_p_from_fifo);

  re_to_fifo <= re_in;
  data_out <= data_from_fifo;
  empty_out <= empty_from_fifo;
  -- NOTE! this is for stupid HIBI which does not start when one_p is '1' and
  -- addres is coming
  one_p_out <= one_p_from_synch;--'0'; --not full_out_from_synch;
  full_out <= full_out_from_synch;
  one_d_out <= one_d_from_fifo;

  clk_fifo <= clk_re;
end generate refaster;

wefaster: if re_faster_g = 0 generate
  re_pulse_synchronizer_1: re_pulse_synchronizer
    generic map (
      data_width_g => data_width_g)
    port map (
      clk_re    => clk_re,
      clk_ps_re => clk_ps_re,
      clk_we    => clk_we,
      clk_ps_we => clk_ps_we,
      
      rst_n     => rst_n,
      data_in   => data_from_fifo,
      empty_in  => empty_from_fifo,
      re_out    => re_to_fifo,
      data_out  => data_out,
      re_in     => re_in,
      empty_out => empty_out_from_synch
      );

  we_to_fifo <= we_in;
  full_out <= full_from_fifo;
  one_p_out <= one_p_from_fifo;
  data_to_fifo <= data_in;
  
  empty_out <= empty_out_from_synch;
  one_d_out <= not empty_out_from_synch;  
  clk_fifo <= clk_we;
end generate wefaster;
          
end rtl;

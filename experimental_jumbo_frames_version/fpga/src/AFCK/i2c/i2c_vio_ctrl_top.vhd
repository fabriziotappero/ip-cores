-------------------------------------------------------------------------------
-- Title      : I2C controller driven by VIO objects
-- Project    : 
-------------------------------------------------------------------------------
-- File       : i2c_vio_ctrl_top.vhd
-- Author     : Wojciech M. Zabolotny wzab01<at>gmail.com
-- License    : PUBLIC DOMAIN
-- Company    : 
-- Created    : 2015-05-03
-- Last update: 2015-05-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-05-03  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity i2c_vio_ctrl is

  port (
    clk : in    std_logic;
    --rst_p : in    std_logic;
    scl : inout std_logic;
    sda : inout std_logic);

end entity i2c_vio_ctrl;

architecture beh of i2c_vio_ctrl is

  signal din       : std_logic_vector(7 downto 0);
  signal dout      : std_logic_vector(7 downto 0);
  signal addr      : std_logic_vector(2 downto 0);
  signal rd_nwr    : std_logic_vector(0 to 0);
  signal cs        : std_logic_vector(0 to 0);
  signal vclk      : std_logic;
  signal i2c_rst_n : std_logic_vector(0 to 0);
  signal vrst_n    : std_logic_vector(0 to 0);
  signal scl_i     : std_logic;
  signal scl_o     : std_logic;
  signal sda_i     : std_logic;
  signal sda_o     : std_logic;

  component i2c_bus_wrap is
    port (
      din   : in  std_logic_vector(7 downto 0);
      dout  : out std_logic_vector(7 downto 0);
      addr  : in  std_logic_vector(2 downto 0);
      rd_nwr    : in  std_logic;
      cs    : in  std_logic;
      clk   : in  std_logic;
      rst   : in  std_logic;
      scl_i : in  std_logic;
      scl_o : out std_logic;
      sda_i : in  std_logic;
      sda_o : out std_logic);
  end component i2c_bus_wrap;

  component vio_0 is
    port (
      clk        : in  std_logic;
      probe_in0  : in  std_logic_vector (7 downto 0);
      probe_out0 : out std_logic_vector (0 downto 0);
      probe_out1 : out std_logic_vector (7 downto 0);
      probe_out2 : out std_logic_vector (2 downto 0);
      probe_out3 : out std_logic_vector (0 to 0);
      probe_out4 : out std_logic_vector (0 to 0);
      probe_out5 : out std_logic_vector (0 to 0));
  end component vio_0;

begin  -- architecture beh

  vio_0_1 : entity work.vio_0
    port map (
      clk        => clk,
      probe_in0  => dout,
      probe_out0 => i2c_rst_n,
      probe_out1 => din,
      probe_out2 => addr,
      probe_out3 => rd_nwr,
      probe_out4 => cs,
      probe_out5 => vrst_n);

  i2c_bus_wrap1 : entity work.i2c_bus_wrap
    port map (
      din     => din,
      dout    => dout,
      addr    => addr,
      rd_nwr  => rd_nwr(0),
      cs      => cs(0),
      clk     => vclk,
      rst     => vrst_n(0),
      i2c_rst => i2c_rst_n(0),
      scl_i   => scl_i,
      scl_o   => scl_o,
      sda_i   => sda_i,
      sda_o   => sda_o);

  vclk  <= clk;
  scl_i <= scl;
  sda_i <= sda;
  scl   <= '0' when scl_o = '0' else 'Z';
  sda   <= '0' when sda_o = '0' else 'Z';

end architecture beh;


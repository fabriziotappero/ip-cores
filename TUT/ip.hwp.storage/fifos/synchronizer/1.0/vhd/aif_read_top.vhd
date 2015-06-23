-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : 
-- Author     : 
-- Created    : 04.01.2006
-- Last update: 04.01.2006
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 04.01.2006  1.0      AK      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------------------------------------------------

entity aif_read_top is
  generic (
    data_width_g : integer := 32
    );
  port (
    tx_clk      : in  std_logic;
    tx_rst_n    : in  std_logic;
    tx_data_in  : in  std_logic_vector(data_width_g-1 downto 0);
    tx_empty_in : in  std_logic;
    tx_re_out   : out std_logic;

    rx_clk       : in  std_logic;
    rx_rst_n     : in  std_logic;
    rx_empty_out : out std_logic;
    rx_re_in     : in  std_logic;

    rx_data_out : out std_logic_vector(data_width_g-1 downto 0)

    );

end aif_read_top;

-------------------------------------------------------------------------------

architecture structural of aif_read_top is

  component aif_read_out
    generic (
      data_width_g : integer := 32
      );
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      a_we_in   : in  std_logic;
      ack_out   : out std_logic;
      empty_out : out std_logic;
      re_in     : in  std_logic;
      data_in   : in  std_logic_vector(data_width_g-1 downto 0);
      data_out  : out std_logic_vector(data_width_g-1 downto 0)
      );
  end component;

  -- component ports
  signal ack_from_rx : std_logic;
--  signal we_from_rx   : std_logic;
--  signal data_from_rx : std_logic_vector(data_width_g-1 downto 0);

  component aif_read_in
    generic (
      data_width_g : integer);
    port (
      clk      : in  std_logic;
      rst_n    : in  std_logic;
      empty_in : in  std_logic;
      re_out   : out std_logic;
      data_in  : in  std_logic_vector(data_width_g-1 downto 0);
      data_out : out std_logic_vector(data_width_g-1 downto 0);
      a_we_out : out std_logic;
      ack_in   : in  std_logic
      );
  end component;

  signal data_from_tx : std_logic_vector(data_width_g-1 downto 0);
  signal full_from_tx : std_logic;
  signal a_we_from_tx : std_logic;

begin  -- structural

  -- component instantiation
  DUT : aif_read_out
    generic map (
      data_width_g => data_width_g)
    port map (
      clk       => rx_clk,
      rst_n     => rx_rst_n,
      a_we_in   => a_we_from_tx,
      ack_out   => ack_from_rx,
      data_in   => data_from_tx,
      data_out  => rx_data_out,
      empty_out => rx_empty_out,
      re_in     => rx_re_in
      );

  aif_read_in_1 : aif_read_in
    generic map (
      data_width_g => data_width_g)
    port map (
      clk      => tx_clk,
      rst_n    => tx_rst_n,
      empty_in => tx_empty_in,
      data_in  => tx_data_in,
      data_out => data_from_tx,
      re_out   => tx_re_out,
      a_we_out => a_we_from_tx,
      ack_in   => ack_from_rx
      );


end structural;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Title      : asyn re fifo
-- Project    : 
-------------------------------------------------------------------------------
-- File       : asyn_re_fifo.vhd
-- Author     : kulmala3
-- Created    : 13.06.2006
-- Last update: 13.06.2006
-- Description: A FIFO with synchronous write interface and asynchronous
-- signaling for RX
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 13.06.2006  1.0      AK	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity asyn_re_fifo is
  generic (
    depth_g : integer := 5;
    data_width_g : integer := 32
    );
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    -- regular fifo
    data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    we_in    : in  std_logic;
    full_out : out std_logic;
    -- asyn IF
    data_out : out std_logic_vector (data_width_g-1 downto 0);
    ack_in   : in  std_logic;
    a_we_out : out std_logic
    
    );
end asyn_re_fifo;


architecture structural of asyn_re_fifo is

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
      ack_in   : in  std_logic);
  end component;

  signal empty_to_read_in  : std_logic;
  signal re_from_read_in   : std_logic;
  signal data_to_read_in   : std_logic_vector(data_width_g-1 downto 0);
  signal data_from_read_in : std_logic_vector(data_width_g-1 downto 0);
  signal a_we_from_read_in : std_logic;
  signal ack_to_read_in    : std_logic;

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


  
begin

  aif_read_in_1 : aif_read_in
    generic map (
      data_width_g => data_width_g)
    port map (
      clk   => clk,
      rst_n => rst_n,

      empty_in => empty_to_read_in,
      re_out   => re_from_read_in,
      data_in  => data_to_read_in,

      data_out => data_out,
      a_we_out => a_we_out,
      ack_in   => ack_in
      );

  fifo_1 : fifo
    generic map (
      data_width_g => data_width_g,
      depth_g      => depth_g)
    port map (
      clk   => clk,
      rst_n => rst_n,

      data_in  => data_in,
      we_in    => we_in,
      full_out => full_out,

--      one_p_out => one_p_out,
--      one_d_out => one_d_out,

      re_in     => re_from_read_in,
      data_out  => data_to_read_in,
      empty_out => empty_to_read_in
      );


end structural;

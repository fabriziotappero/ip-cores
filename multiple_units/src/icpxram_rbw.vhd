-------------------------------------------------------------------------------
-- Title      : icpxram
-- Project    : 
-------------------------------------------------------------------------------
-- File       : icpxram_rbw.vhd
-- Author     : Wojciech Zabolotny
-- Company    : 
-- License    : BSD
-- Created    : 2014-01-19
-- Last update: 2014-04-25
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This block holds the complex numbers with real and imaginary
--              parts stored as signed integers with defined bit number
--              This memory implements "read before write" behaviour!
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-01-19  1.0      wzab    Created
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
library work;
use work.icpx.all;

entity dp_ram_rbw_icpx is
  generic (
    ADDR_WIDTH : integer := 10
    );
  port (
-- common clock
    clk    : in  std_logic;
    -- Port A
    we_a   : in  std_logic;
    addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_a : in  icpx_number;
    q_a    : out icpx_number;

    -- Port B
    we_b   : in  std_logic;
    addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
    data_b : in  icpx_number;
    q_b    : out icpx_number
    );
end dp_ram_rbw_icpx;

architecture rtl of dp_ram_rbw_icpx is

  signal s_data_a : std_logic_vector(ICPX_BV_LEN-1 downto 0);
  signal s_q_a    : std_logic_vector(ICPX_BV_LEN-1 downto 0);
  signal s_data_b : std_logic_vector(ICPX_BV_LEN-1 downto 0);
  signal s_q_b    : std_logic_vector(ICPX_BV_LEN-1 downto 0);

  component dp_ram_rbw_scl
    generic (
      DATA_WIDTH : integer;
      ADDR_WIDTH : integer);
    port (
      clk    : in  std_logic;
      we_a   : in  std_logic;
      addr_a : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_a : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      q_a    : out std_logic_vector(DATA_WIDTH-1 downto 0);
      we_b   : in  std_logic;
      addr_b : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_b : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      q_b    : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component;
  
begin

  dp_ram_scl_1 : dp_ram_rbw_scl
    generic map (
      DATA_WIDTH => ICPX_BV_LEN,
      ADDR_WIDTH => ADDR_WIDTH)
    port map (
      clk    => clk,
      we_a   => we_a,
      addr_a => addr_a,
      data_a => s_data_a,
      q_a    => s_q_a,
      we_b   => we_b,
      addr_b => addr_b,
      data_b => s_data_b,
      q_b    => s_q_b);

  s_data_a <= icpx2stlv(data_a);
  s_data_b <= icpx2stlv(data_b);
  q_a      <= stlv2icpx(s_q_a);
  q_b      <= stlv2icpx(s_q_b);
  
end rtl;

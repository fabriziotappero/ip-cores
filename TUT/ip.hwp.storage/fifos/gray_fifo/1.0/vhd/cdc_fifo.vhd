-------------------------------------------------------------------------------
-- Title      : Gray counter based mixed clock FIFO
-- Project    : 
-------------------------------------------------------------------------------
-- File       : cdc_fifo.vhd
-- Author     : 
-- Created    : 19.12.2006
-- Last update: 19.12.2006
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2006         1.0     Timo Alho	Created
-- 19.12.2006           Ari Kulmala     Comments. header. one p and one d
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cdc_fifo is
  
  generic (
    READ_AHEAD_g  : integer := 0;
    SYNC_CLOCKS_g : integer := 0; -- 0 two flop synch, otherwise 1 flop synch
    depth_log2_g  : integer := 5;
    dataw_g       : integer := 32);

  port (
    rst_n        : in  std_logic;
    rd_clk       : in  std_logic;
    rd_en_in     : in  std_logic;
    rd_empty_out : out std_logic;
    rd_one_d_out : out std_logic;
    rd_data_out  : out std_logic_vector(dataw_g-1 downto 0);
    

    wr_clk      : in  std_logic;
    wr_en_in    : in  std_logic;
    wr_full_out : out std_logic;
    wr_one_p_out : out std_logic;
    wr_data_in  : in  std_logic_vector(dataw_g-1 downto 0)
    );

end entity cdc_fifo;

architecture rtl of cdc_fifo is

  signal wr_en, rd_en     : std_logic;
  signal rd_addr, wr_addr : std_logic_vector(depth_log2_g-1 downto 0);

  signal wr_full, rd_empty : std_logic;
begin  -- architecture rtl

  wr_full_out  <= wr_full;
  rd_empty_out <= rd_empty;
  -- write cannot be '1' when full,
  wr_en        <= wr_en_in and (not wr_full);
  -- read cannot be asserted wen empty
  rd_en        <= rd_en_in and (not rd_empty);

  fifo_ram_storage : entity work.async_dpram
    generic map (
      addrw_g => depth_log2_g,
      dataw_g => dataw_g)
    port map (
      rd_clk     => rd_clk,
      wr_clk     => wr_clk,
      wr_en_in   => wr_en,
      data_in    => wr_data_in,
      data_out   => rd_data_out,
      rd_addr_in => rd_addr,
      wr_addr_in => wr_addr);

  cdc_fifo_ctrl_2 : entity work.cdc_fifo_ctrl
    generic map (
      READ_AHEAD_g  => READ_AHEAD_g,
      SYNC_CLOCKS_g => SYNC_CLOCKS_g,
      depth_log2_g  => depth_log2_g)
    port map (
      rst_n        => rst_n,
      rd_clk       => rd_clk,
      rd_en_in     => rd_en,
      rd_empty_out => rd_empty,
      rd_addr_out  => rd_addr,
      rd_one_d_out => rd_one_d_out,
      wr_clk       => wr_clk,
      wr_en_in     => wr_en,
      wr_full_out  => wr_full,
      wr_one_p_out => wr_one_p_out,
      wr_addr_out  => wr_addr
      );

end architecture rtl;

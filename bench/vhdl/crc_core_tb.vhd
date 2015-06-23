-------------------------------------------------------------------------------
-- Title      : Testbench for design "crc_core"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : crc_core_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2008-03-23
-- Last update: 2008-03-23
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008-03-23  1.0      d.koethe        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
-------------------------------------------------------------------------------

entity crc_core_tb is
  generic (
    C_SR_WIDTH : integer := 32);

end crc_core_tb;

-------------------------------------------------------------------------------

architecture behavior of crc_core_tb is
  component crc_core
    generic (
      C_SR_WIDTH : integer);
    port (
      rst              : in  std_logic;
      opb_clk          : in  std_logic;
      crc_en           : in  std_logic;
      crc_clr          : in  std_logic;
      opb_m_last_block : in  std_logic;
      fifo_rx_en       : in  std_logic;
      fifo_rx_data     : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_rx_crc_value : out std_logic_vector(C_SR_WIDTH-1 downto 0);
      fifo_tx_en       : in  std_logic;
      fifo_tx_data     : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      tx_crc_insert    : out std_logic;
      opb_tx_crc_value : out std_logic_vector(C_SR_WIDTH-1 downto 0));
  end component;

  signal rst              : std_logic;
  signal opb_clk          : std_logic;
  signal crc_en           : std_logic;
  signal crc_clr          : std_logic;
  signal opb_m_last_block : std_logic;
  signal fifo_rx_en       : std_logic;
  signal fifo_rx_data     : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_rx_crc_value : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal fifo_tx_en       : std_logic;
  signal fifo_tx_data     : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal tx_crc_insert    : std_logic;
  signal opb_tx_crc_value : std_logic_vector(C_SR_WIDTH-1 downto 0);

  constant C_CLK_PERIOD : time := 10 ns;
  
begin  -- behavior

  -- component instantiation
  DUT : crc_core
    generic map (
      C_SR_WIDTH => C_SR_WIDTH)
    port map (
      rst              => rst,
      opb_clk          => opb_clk,
      crc_en           => crc_en,
      crc_clr          => crc_clr,
      opb_m_last_block => opb_m_last_block,
      fifo_rx_en       => fifo_rx_en,
      fifo_rx_data     => fifo_rx_data,
      opb_rx_crc_value => opb_rx_crc_value,
      fifo_tx_en       => fifo_tx_en,
      fifo_tx_data     => fifo_tx_data,
      tx_crc_insert    => tx_crc_insert,
      opb_tx_crc_value => opb_tx_crc_value);

  -- clock generation
  process
  begin
    opb_clk <= '0';
    wait for C_CLK_PERIOD/2;
    opb_clk <= '1';
    wait for C_CLK_PERIOD/2;
  end process;

  -- waveform generation
  WaveGen_Proc : process
  begin
    rst              <= '1';
    crc_en           <= '0';
    crc_clr          <= '0';
    opb_m_last_block <= '0';
    fifo_rx_en       <= '0';
    fifo_rx_data     <= (others => '0');
    fifo_tx_en       <= '0';
    fifo_tx_data     <= (others => '0');
    wait for 100 ns;
    rst              <= '0';

    -- clear crc
    wait until rising_edge(opb_clk);
    crc_clr <= '1';
    wait until rising_edge(opb_clk);
    crc_clr <= '0';
    crc_en  <= '1';



    -- generate data block
    opb_m_last_block <= '0';

    for i in 0 to 15 loop
      wait until rising_edge(opb_clk);
      -- RX
      fifo_rx_en   <= '1';
      fifo_rx_data <= conv_std_logic_vector(i, fifo_rx_data'length);
      -- TX
      fifo_tx_en   <= '1';
      fifo_tx_data <= conv_std_logic_vector(i, fifo_tx_data'length);
    end loop;  -- i
    wait until rising_edge(opb_clk);
    fifo_rx_en   <= '0';
    fifo_rx_data <= (others => '0');
    fifo_tx_en   <= '0';
    fifo_tx_data <= (others => '0');
    wait until rising_edge(opb_clk);

    if (C_SR_WIDTH = 32) then
      assert (conv_integer(opb_rx_crc_value) = 16#eb99fa90#) report"RX_CRC_Failure" severity failure;
      assert (conv_integer(opb_tx_crc_value) = 16#eb99fa90#) report"RX_CRC_Failure" severity failure;
    end if;


    -- generate crc_block
    opb_m_last_block <= '1';

    for i in 0 to 15 loop
      wait until rising_edge(opb_clk);
      -- RX
      fifo_rx_en   <= '1';
      fifo_rx_data <= (others => '1');
      -- TX
      fifo_tx_en   <= '1';
      fifo_tx_data <= (others => '1');
    end loop;  -- i
    wait until rising_edge(opb_clk);
    fifo_rx_en   <= '0';
    fifo_rx_data <= (others => '0');
    fifo_tx_en   <= '0';
    fifo_tx_data <= (others => '0');
    wait until rising_edge(opb_clk);
    -- same value, no changes in last block
    if (C_SR_WIDTH = 32) then
      assert (conv_integer(opb_rx_crc_value) = 16#eb99fa90#) report"RX_CRC_Failure" severity failure;
      assert (conv_integer(opb_tx_crc_value) = 16#eb99fa90#) report"RX_CRC_Failure" severity failure;
    end if;
    opb_m_last_block <= '0';


    wait for 100 ns;



    assert false report "Simulation Sucessful" severity failure;

  end process WaveGen_Proc;

  

end behavior;

-------------------------------------------------------------------------------

configuration crc_core_tb_behavior_cfg of crc_core_tb is
  for behavior
  end for;
end crc_core_tb_behavior_cfg;

-------------------------------------------------------------------------------

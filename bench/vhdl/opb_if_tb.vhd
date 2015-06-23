-------------------------------------------------------------------------------
-- Title      : Testbench for design "opb_if"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : opb_if_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-09-01
-- Last update: 2007-11-12
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-09-01  1.0      d.koethe        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.opb_spi_slave_pack.all;

-------------------------------------------------------------------------------

entity opb_if_tb is

end opb_if_tb;

-------------------------------------------------------------------------------

architecture behavior of opb_if_tb is

  component opb_if
    generic (
      C_BASEADDR        : std_logic_vector(0 to 31);
      C_HIGHADDR        : std_logic_vector(0 to 31);
      C_USER_ID_CODE    : integer;
      C_OPB_AWIDTH      : integer;
      C_OPB_DWIDTH      : integer;
      C_FAMILY          : string;
      C_SR_WIDTH        : integer;
      C_FIFO_SIZE_WIDTH : integer;
      C_DMA_EN          : boolean);
    port (
      OPB_ABus        : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE          : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_Clk         : in  std_logic;
      OPB_DBus        : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      OPB_RNW         : in  std_logic;
      OPB_Rst         : in  std_logic;
      OPB_select      : in  std_logic;
      OPB_seqAddr     : in  std_logic;
      Sln_DBus        : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sln_errAck      : out std_logic;
      Sln_retry       : out std_logic;
      Sln_toutSup     : out std_logic;
      Sln_xferAck     : out std_logic;
      opb_s_tx_en     : out std_logic;
      opb_s_tx_data   : out std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_s_rx_en     : out std_logic;
      opb_s_rx_data   : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_ctl_reg     : out std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
      tx_thresh       : out std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
      rx_thresh       : out std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
      opb_fifo_flg    : in  std_logic_vector(C_NUM_FLG-1 downto 0);
      opb_dgie        : out std_logic;
      opb_ier         : out std_logic_vector(C_NUM_INT-1 downto 0);
      opb_isr         : in  std_logic_vector(C_NUM_INT-1 downto 0);
      opb_isr_clr     : out std_logic_vector(C_NUM_INT-1 downto 0);
      opb_tx_dma_addr : out std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_tx_dma_ctl  : out std_logic_vector(0 downto 0);
      opb_tx_dma_num  : out std_logic_vector(15 downto 0);
      opb_rx_dma_addr : out std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_rx_dma_ctl  : out std_logic_vector(0 downto 0);
      opb_rx_dma_num  : out std_logic_vector(15 downto 0));
  end component;
  
  constant C_BASEADDR        : std_logic_vector(0 to 31) := X"00000000";
  constant C_HIGHADDR        : std_logic_vector(0 to 31) := X"FFFFFFFF";
  constant C_USER_ID_CODE    : integer                   := 3;
  constant C_OPB_AWIDTH      : integer                   := 32;
  constant C_OPB_DWIDTH      : integer                   := 32;
  constant C_FAMILY          : string                    := "virtex-4";
  constant C_SR_WIDTH        : integer                   := 8;
  constant C_FIFO_SIZE_WIDTH : integer                   := 4;
  constant C_DMA_EN          : boolean                   := true;
  

  signal OPB_ABus        : std_logic_vector(0 to C_OPB_AWIDTH-1);
  signal OPB_BE          : std_logic_vector(0 to C_OPB_DWIDTH/8-1);
  signal OPB_Clk         : std_logic;
  signal OPB_DBus        : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal OPB_RNW         : std_logic;
  signal OPB_Rst         : std_logic;
  signal OPB_select      : std_logic;
  signal OPB_seqAddr     : std_logic;
  signal Sln_DBus        : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal Sln_errAck      : std_logic;
  signal Sln_retry       : std_logic;
  signal Sln_toutSup     : std_logic;
  signal Sln_xferAck     : std_logic;
  signal opb_s_tx_en     : std_logic;
  signal opb_s_tx_data   : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_s_rx_en     : std_logic;
  signal opb_s_rx_data   : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_ctl_reg     : std_logic_vector(C_OPB_CTL_REG_WIDTH-1 downto 0);
  signal tx_thresh       : std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
  signal rx_thresh       : std_logic_vector((2*C_FIFO_SIZE_WIDTH)-1 downto 0);
  signal opb_fifo_flg    : std_logic_vector(C_NUM_FLG-1 downto 0);
  signal opb_dgie        : std_logic;
  signal opb_ier         : std_logic_vector(C_NUM_INT-1 downto 0);
  signal opb_isr         : std_logic_vector(C_NUM_INT-1 downto 0);
  signal opb_isr_clr     : std_logic_vector(C_NUM_INT-1 downto 0);
  signal opb_tx_dma_addr : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_tx_dma_ctl  : std_logic_vector(0 downto 0);
  signal opb_tx_dma_num  : std_logic_vector(15 downto 0);
  signal opb_rx_dma_addr : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_rx_dma_ctl  : std_logic_vector(0 downto 0);
  signal opb_rx_dma_num  : std_logic_vector(15 downto 0);

  constant clk_period : time := 25 ns;

begin  -- behavior

  -- component instantiation
  DUT: opb_if
    generic map (
      C_BASEADDR        => C_BASEADDR,
      C_HIGHADDR        => C_HIGHADDR,
      C_USER_ID_CODE    => C_USER_ID_CODE,
      C_OPB_AWIDTH      => C_OPB_AWIDTH,
      C_OPB_DWIDTH      => C_OPB_DWIDTH,
      C_FAMILY          => C_FAMILY,
      C_SR_WIDTH        => C_SR_WIDTH,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH,
      C_DMA_EN          => C_DMA_EN)
    port map (
      OPB_ABus        => OPB_ABus,
      OPB_BE          => OPB_BE,
      OPB_Clk         => OPB_Clk,
      OPB_DBus        => OPB_DBus,
      OPB_RNW         => OPB_RNW,
      OPB_Rst         => OPB_Rst,
      OPB_select      => OPB_select,
      OPB_seqAddr     => OPB_seqAddr,
      Sln_DBus        => Sln_DBus,
      Sln_errAck      => Sln_errAck,
      Sln_retry       => Sln_retry,
      Sln_toutSup     => Sln_toutSup,
      Sln_xferAck     => Sln_xferAck,
      opb_s_tx_en     => opb_s_tx_en,
      opb_s_tx_data   => opb_s_tx_data,
      opb_s_rx_en     => opb_s_rx_en,
      opb_s_rx_data   => opb_s_rx_data,
      opb_ctl_reg     => opb_ctl_reg,
      tx_thresh       => tx_thresh,
      rx_thresh       => rx_thresh,
      opb_fifo_flg    => opb_fifo_flg,
      opb_dgie        => opb_dgie,
      opb_ier         => opb_ier,
      opb_isr         => opb_isr,
      opb_isr_clr     => opb_isr_clr,
      opb_tx_dma_addr => opb_tx_dma_addr,
      opb_tx_dma_ctl  => opb_tx_dma_ctl,
      opb_tx_dma_num  => opb_tx_dma_num,
      opb_rx_dma_addr => opb_rx_dma_addr,
      opb_rx_dma_ctl  => opb_rx_dma_ctl,
      opb_rx_dma_num  => opb_rx_dma_num);

  -- clock generation
  process
  begin
    OPB_Clk <= '0';
    wait for clk_period;
    OPB_Clk <= '1';
    wait for clk_period;
  end process;

  -- waveform generation
  WaveGen_Proc : process
  begin
    OPB_ABus    <= (others => '0');
    OPB_BE      <= (others => '0');
    OPB_DBus    <= (others => '0');
    OPB_RNW     <= '0';
    OPB_select  <= '0';
    OPB_seqAddr <= '0';
    -- reset active
    OPB_Rst     <= '1';
    wait for 100 ns;
    -- reset inactive
    OPB_Rst     <= '0';


    -- write acess
    wait until rising_edge(OPB_Clk);
    OPB_ABus   <= X"10000000";
    OPB_select <= '1';
    OPB_RNW    <= '0';
    OPB_DBus   <= X"12345678";

    for i in 0 to 3 loop
      wait until rising_edge(OPB_Clk);
      if (Sln_xferAck = '1') then
        exit;
      end if;
    end loop;  -- i
    OPB_DBus   <= X"00000000";
    OPB_ABus   <= X"00000000";
    OPB_select <= '0';


    -- read acess
    wait until rising_edge(OPB_Clk);
    OPB_ABus   <= X"10000000";
    OPB_select <= '1';
    OPB_RNW    <= '1';

    for i in 0 to 3 loop
      wait until rising_edge(OPB_Clk);
      if (Sln_xferAck = '1') then
        exit;
      end if;
    end loop;  -- i
    OPB_ABus   <= X"00000000";
    OPB_select <= '0';



    wait for 100 ns;
    assert false report "Simulation sucessful" severity failure;

    
  end process WaveGen_Proc;

  

end behavior;

-------------------------------------------------------------------------------

configuration opb_if_tb_behavior_cfg of opb_if_tb is
  for behavior
  end for;
end opb_if_tb_behavior_cfg;

-------------------------------------------------------------------------------

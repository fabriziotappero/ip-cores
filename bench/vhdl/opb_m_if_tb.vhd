-------------------------------------------------------------------------------
-- Title      : Testbench for design "opb_m_if"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : opb_m_if_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-10-29
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
-- 2007-10-29  1.0      d.koethe        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.numeric_std.all;               -- conv_integer()
-------------------------------------------------------------------------------

entity opb_m_if_tb is

end opb_m_if_tb;

-------------------------------------------------------------------------------

architecture behavior of opb_m_if_tb is

  component opb_m_if
    generic (
      C_BASEADDR        : std_logic_vector(0 to 31);
      C_HIGHADDR        : std_logic_vector(0 to 31);
      C_USER_ID_CODE    : integer;
      C_OPB_AWIDTH      : integer;
      C_OPB_DWIDTH      : integer;
      C_FAMILY          : string;
      C_SR_WIDTH        : integer;
      C_MSB_FIRST       : boolean;
      C_CPOL            : integer range 0 to 1;
      C_PHA             : integer range 0 to 1;
      C_FIFO_SIZE_WIDTH : integer range 4 to 7);
    port (
      OPB_Clk         : in  std_logic;
      OPB_Rst         : in  std_logic;
      OPB_DBus        : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      M_request       : out std_logic;
      MOPB_MGrant     : in  std_logic;
      M_busLock       : out std_logic;
      M_ABus          : out std_logic_vector(0 to C_OPB_AWIDTH-1);
      M_BE            : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      M_DBus          : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      M_RNW           : out std_logic;
      M_select        : out std_logic;
      M_seqAddr       : out std_logic;
      MOPB_errAck     : in  std_logic;
      MOPB_retry      : in  std_logic;
      MOPB_timeout    : in  std_logic;
      MOPB_xferAck    : in  std_logic;
      opb_m_tx_req    : in  std_logic;
      opb_m_tx_en     : out std_logic;
      opb_m_tx_data   : out std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_tx_dma_ctl  : in  std_logic_vector(0 downto 0);
      opb_tx_dma_addr : in  std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_tx_dma_num  : in  std_logic_vector(15 downto 0);
      opb_tx_dma_done : out std_logic;
      opb_m_rx_req    : in  std_logic;
      opb_m_rx_en     : out std_logic;
      opb_m_rx_data   : in  std_logic_vector(C_SR_WIDTH-1 downto 0);
      opb_rx_dma_ctl  : in  std_logic_vector(0 downto 0);
      opb_rx_dma_addr : in  std_logic_vector(C_OPB_DWIDTH-1 downto 0);
      opb_rx_dma_num  : in  std_logic_vector(15 downto 0);
      opb_rx_dma_done : out std_logic);
  end component;



  -- component generics
  constant C_BASEADDR        : std_logic_vector(0 to 31) := X"00000000";
  constant C_HIGHADDR        : std_logic_vector(0 to 31) := X"FFFFFFFF";
  constant C_USER_ID_CODE    : integer                   := 0;
  constant C_OPB_AWIDTH      : integer                   := 32;
  constant C_OPB_DWIDTH      : integer                   := 32;
  constant C_FAMILY          : string                    := "virtex-4";
  constant C_SR_WIDTH        : integer                   := 8;
  constant C_MSB_FIRST       : boolean                   := true;
  constant C_CPOL            : integer range 0 to 1      := 0;
  constant C_PHA             : integer range 0 to 1      := 0;
  constant C_FIFO_SIZE_WIDTH : integer range 4 to 7      := 7;
  
  -- component ports
  signal OPB_Clk         : std_logic;
  signal OPB_Rst         : std_logic;
  signal OPB_DBus        : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal M_request       : std_logic;
  signal MOPB_MGrant     : std_logic;
  signal M_busLock       : std_logic;
  signal M_ABus          : std_logic_vector(0 to C_OPB_AWIDTH-1);
  signal M_BE            : std_logic_vector(0 to C_OPB_DWIDTH/8-1);
  signal M_DBus          : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal M_RNW           : std_logic;
  signal M_select        : std_logic;
  signal M_seqAddr       : std_logic;
  signal MOPB_errAck     : std_logic;
  signal MOPB_retry      : std_logic;
  signal MOPB_timeout    : std_logic;
  signal MOPB_xferAck    : std_logic;
  signal opb_m_tx_req    : std_logic;
  signal opb_m_tx_en     : std_logic;
  signal opb_m_tx_data   : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_tx_dma_ctl  : std_logic_vector(0 downto 0);
  signal opb_tx_dma_addr : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_tx_dma_num  : std_logic_vector(15 downto 0);
  signal opb_tx_dma_done : std_logic;
  signal opb_m_rx_req    : std_logic;
  signal opb_m_rx_en     : std_logic;
  signal opb_m_rx_data   : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_rx_dma_ctl  : std_logic_vector(0 downto 0);
  signal opb_rx_dma_addr : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal opb_rx_dma_num  : std_logic_vector(15 downto 0);
  signal opb_rx_dma_done : std_logic;

  signal opb_rx_data : std_logic_vector(C_SR_WIDTH-1 downto 0);
  signal opb_tx_data : std_logic_vector(0 to C_SR_WIDTH-1);
  
begin  -- behavior

  -- component instantiation
  opb_m_if_1: opb_m_if
    generic map (
      C_BASEADDR        => C_BASEADDR,
      C_HIGHADDR        => C_HIGHADDR,
      C_USER_ID_CODE    => C_USER_ID_CODE,
      C_OPB_AWIDTH      => C_OPB_AWIDTH,
      C_OPB_DWIDTH      => C_OPB_DWIDTH,
      C_FAMILY          => C_FAMILY,
      C_SR_WIDTH        => C_SR_WIDTH,
      C_MSB_FIRST       => C_MSB_FIRST,
      C_CPOL            => C_CPOL,
      C_PHA             => C_PHA,
      C_FIFO_SIZE_WIDTH => C_FIFO_SIZE_WIDTH)
    port map (
      OPB_Clk         => OPB_Clk,
      OPB_Rst         => OPB_Rst,
      OPB_DBus        => OPB_DBus,
      M_request       => M_request,
      MOPB_MGrant     => MOPB_MGrant,
      M_busLock       => M_busLock,
      M_ABus          => M_ABus,
      M_BE            => M_BE,
      M_DBus          => M_DBus,
      M_RNW           => M_RNW,
      M_select        => M_select,
      M_seqAddr       => M_seqAddr,
      MOPB_errAck     => MOPB_errAck,
      MOPB_retry      => MOPB_retry,
      MOPB_timeout    => MOPB_timeout,
      MOPB_xferAck    => MOPB_xferAck,
      opb_m_tx_req    => opb_m_tx_req,
      opb_m_tx_en     => opb_m_tx_en,
      opb_m_tx_data   => opb_m_tx_data,
      opb_tx_dma_ctl  => opb_tx_dma_ctl,
      opb_tx_dma_addr => opb_tx_dma_addr,
      opb_tx_dma_num  => opb_tx_dma_num,
      opb_tx_dma_done => opb_tx_dma_done,
      opb_m_rx_req    => opb_m_rx_req,
      opb_m_rx_en     => opb_m_rx_en,
      opb_m_rx_data   => opb_m_rx_data,
      opb_rx_dma_ctl  => opb_rx_dma_ctl,
      opb_rx_dma_addr => opb_rx_dma_addr,
      opb_rx_dma_num  => opb_rx_dma_num,
      opb_rx_dma_done => opb_rx_dma_done);


  -- clock generation
  process
  begin
    OPB_Clk <= '0';
    wait for 10 ns;
    OPB_Clk <= '1';
    wait for 10 ns;
  end process;


  -- arbiter/xferack
  process(OPB_Rst, OPB_Clk)
  begin
    if (OPB_Rst = '1') then
      MOPB_MGrant  <= '0';
      MOPB_xferAck <= '0';
      opb_tx_data  <= (others => '0');
    elsif rising_edge(OPB_Clk) then
      -- arbiter
      if (M_request = '1') then
        MOPB_MGrant <= '1';
      else
        MOPB_MGrant <= '0';
      end if;

      -- xfer_Ack
      if (M_select = '1') then
        if (M_RNW = '1' and MOPB_xferAck = '1') then
          opb_tx_data <= opb_tx_data+1;
        end if;
        MOPB_xferAck <= not MOPB_xferAck;
      else
        opb_tx_data  <= (others => '0');
        MOPB_xferAck <= '0';
      end if;
     end if;
  end process;

  OPB_DBus( 0 to C_OPB_DWIDTH-C_SR_WIDTH-1) <= (others => '0');
  OPB_DBus(C_OPB_DWIDTH-C_SR_WIDTH to C_OPB_DWIDTH-1)    <= opb_tx_data;

  -- rx fifo emulation
  process(OPB_Rst, OPB_Clk)
  begin
    if (OPB_Rst = '1') then
      opb_rx_data <= (others => '0');
    elsif rising_edge(OPB_Clk) then
      if (opb_m_rx_en = '1') then
        opb_rx_data <= opb_rx_data+1;
      end if;
    end if;
  end process;

  opb_m_rx_data <= opb_rx_data;


  -- waveform generation
  WaveGen_Proc : process
  begin
    -- reset active
    OPB_Rst <= '1';

    MOPB_errAck  <= '0';
    MOPB_retry   <= '0';
    MOPB_timeout <= '0';

    opb_m_tx_req    <= '0';
    opb_tx_dma_ctl  <= (others => '0');
    opb_tx_dma_addr <= (others => '0');
    opb_m_rx_req    <= '0';
    opb_rx_dma_ctl  <= (others => '0');
    opb_rx_dma_addr <= (others => '0');




    wait for 100 ns;
    -- remove rst
    OPB_Rst <= '0';
    ---------------------------------------------------------------------------
    -- write transfer
    opb_tx_dma_addr <= conv_std_logic_vector(16#24000000#, 32);

    wait until rising_edge(OPB_Clk);
    opb_tx_dma_ctl(0) <= '1';


    wait until rising_edge(OPB_Clk);
    opb_m_tx_req <= '1';                -- asssert almost full flag
    wait until rising_edge(OPB_Clk);
    opb_m_tx_req <= '0';                -- deassert almost full flag

    wait for 1 us;

    ---------------------------------------------------------------------------
    -- read transfer
    opb_rx_dma_addr <= conv_std_logic_vector(16#25000000#, 32);

    wait until rising_edge(OPB_Clk);
    opb_rx_dma_ctl(0) <= '1';

    -- first transfer
    wait until rising_edge(OPB_Clk);
    opb_m_rx_req <= '1';                -- asssert almost full flag
    wait until rising_edge(OPB_Clk);
    opb_m_rx_req <= '0';                -- deassert almost full flag
    wait for 1 us;

    -- second transfer
    wait until rising_edge(OPB_Clk);
    opb_m_rx_req <= '1';                -- asssert almost full flag
    wait until rising_edge(OPB_Clk);
    opb_m_rx_req <= '0';                -- deassert almost full flag
    wait for 1 us;    
    ---------------------------------------------------------------------------


    assert false report "Simulation Sucessful" severity failure;

  end process WaveGen_Proc;

  

end behavior;

-------------------------------------------------------------------------------

configuration opb_m_if_tb_behavior_cfg of opb_m_if_tb is
  for behavior
  end for;
end opb_m_if_tb_behavior_cfg;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_tx_top.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2013-05-10
-- Last update: 2013-05-20
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-05-10  1.0      liyi    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.de2_pkg.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_tx_top IS
  GENERIC (
    IN_SIMULATION : BOOLEAN := FALSE);
  PORT (
    iWbClk  : IN STD_LOGIC;
    iEthClk : IN STD_LOGIC;
    iRst_n  : IN STD_LOGIC;

    iWbS2M      : IN  wbSlaveToMasterIF_t;
    oWbM2S      : OUT wbMasterToSlaveIF_t;
    -- synthesis translate_off
    oWbM2S_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbM2S_sel  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    oWbM2S_cyc  : OUT STD_LOGIC;
    oWbM2S_stb  : OUT STD_LOGIC;
    oWbM2S_we   : OUT STD_LOGIC;
    oWbM2S_cti  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    oWbM2S_bte  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    iWbS2M_ack  : IN  STD_LOGIC;
    iWbS2M_dat  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- synthesis translate_on

    oEnetTxData : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    oEnetTxEn   : OUT STD_LOGIC;
    oEnetTxErr  : OUT STD_LOGIC;

    iWbTxEn       : IN  STD_LOGIC;      -- tx module enable
    iWbTxIntEn    : IN  STD_LOGIC;      -- interrupt enable
    iWbTxIntClr   : IN  STD_LOGIC;      -- clear interrupt SIGNAL
    oWbTxIntInfo  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    iWbTxDescData : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbTxDescData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    iWbTxDescWr   : IN  STD_LOGIC;
    iWbTxDescAddr : IN  STD_LOGIC_VECTOR(8 DOWNTO 2);

    iCheckSumIPGen   : IN STD_LOGIC;
    iCheckSumTCPGen  : IN STD_LOGIC;
    iCheckSumUDPGen  : IN STD_LOGIC;
    iCheckSumICMPGen : IN STD_LOGIC;

    oWbTxInt : OUT STD_LOGIC
    );

END ENTITY rgmii_tx_top;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_tx_top IS
  SIGNAL tx_done_info  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL tx_data_32    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL tx_data_32_wr : STD_LOGIC;
  SIGNAL tx_info_32    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL tx_info_32_wr : STD_LOGIC;
  SIGNAL tx_data_addr  : UNSIGNED(10 DOWNTO 0);

  SIGNAL sof, eof     : STD_LOGIC;
  SIGNAL cTxData      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL cGenFrame    : STD_LOGIC;
  SIGNAL cGenFrameAck : STD_LOGIC;
BEGIN  -- ARCHITECTURE rtl

  rgmii_tx_1 : ENTITY work.rgmii_tx
    PORT MAP (
      iClk         => iEthClk,
      iRst_n       => iRst_n,
      iTxData      => cTxData,
      oSOF         => sof,
      iEOF         => eof,
      iGenFrame    => cGenFrame,
      oGenFrameAck => cGenFrameAck,
      oTxData      => oEnetTxData,
      oTxEn        => oEnetTxEn,
      oTxErr       => oEnetTxErr);

  rgmii_tx_buf_1 : ENTITY work.rgmii_tx_buf
    PORT MAP (
      iEthClk => iEthClk,
      iWbClk  => iWbClk,
      iRst_n  => iRst_n,

      oEthTxData      => cTxData,
      iEthSOF         => sof,
      oEthEOF         => eof,
      oEthGenFrame    => cGenFrame,
      iEthGenFrameAck => cGenFrameAck,
      iWbTxData       => tx_data_32,
      iWbTxAddr       => tx_data_addr,
      iWbTxDataWr     => tx_data_32_wr,
      iWbTxInfo       => tx_info_32,
      iWbTxInfoWr     => tx_info_32_wr,
      iWbIntEn        => '0',
      iWbIntClr       => '0',
      oWbInt          => OPEN,
      oWbTxInfo       => tx_done_info);

  rgmii_tx_wbm_1 : ENTITY work.rgmii_tx_wbm
    GENERIC MAP (
      IN_SIMULATION => IN_SIMULATION)
    PORT MAP (
      iWbClk => iWbClk,
      iRst_n => iRst_n,

      oWbM2S      => oWbM2S,
      iWbS2M      => iWbS2M,
      -- synthesis translate_off
      oWbM2S_addr => oWbM2S_addr,
      oWbM2S_sel  => oWbM2S_sel,
      oWbM2S_cyc  => oWbM2S_cyc,
      oWbM2S_stb  => oWbM2S_stb,
      oWbM2S_we   => oWbM2S_we,
      oWbM2S_cti  => oWbM2S_cti,
      oWbM2S_bte  => oWbM2S_bte,
      iWbS2M_ack  => iWbS2M_ack,
      iWbS2M_dat  => iWbS2M_dat,
      -- synthesis translate_on

      iTxDone     => '0',
      oTxDoneClr  => OPEN,
      iTxDoneInfo => tx_done_info,
      oTxData     => tx_data_32,
      oTxAddr     => tx_data_addr,
      oTxDataWr   => tx_data_32_wr,
      oTxInfo     => tx_info_32,
      oTxInfoWr   => tx_info_32_wr,

      iCheckSumIPGen   => iCheckSumIPGen,
      iCheckSumTCPGen  => iCheckSumTCPGen,
      iCheckSumUDPGen  => iCheckSumUDPGen,
      iCheckSumICMPGen => iCheckSumICMPGen,

      iWbTxEnable  => iWbTxEn,
      oWbTxInt     => oWbTxInt,
      iWbTxIntClr  => iWbTxIntClr,
      iWbTxIntEn   => iWbTxIntEn,
      iWbTxAddr    => iWbTxDescAddr,
      iWbTxWE      => iWbTxDescWr,
      iWbTxData    => iWbTxDescData,
      oWbTxData    => oWbTxDescData,
      oWbTxIntInfo => oWbTxIntInfo);

END ARCHITECTURE rtl;

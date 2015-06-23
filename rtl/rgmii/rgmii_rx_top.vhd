-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_rx_top.vhd
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
ENTITY rgmii_rx_top IS
  GENERIC (
    MY_MAC        : STD_LOGIC_VECTOR(47 DOWNTO 0) := X"10BF487A0FED";
    IN_SIMULATION : BOOLEAN                       := FALSE);
  PORT (
    iWbClk  : IN STD_LOGIC;
    iEthClk : IN STD_LOGIC;
    iRst_n  : IN STD_LOGIC;

    iWbS2M      : IN  wbSlaveToMasterIF_t;
    oWbM2S      : OUT wbMasterToSlaveIF_t;
    -- synthesis translate_off
    oWbM2S_dat  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbM2S_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbM2S_sel  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    oWbM2S_cyc  : OUT STD_LOGIC;
    oWbM2S_stb  : OUT STD_LOGIC;
    oWbM2S_we   : OUT STD_LOGIC;
    oWbM2S_cti  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    oWbM2S_bte  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    iWbS2M_ack  : IN  STD_LOGIC;
    -- synthesis translate_on

    iEnetRxData : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    iEnetRxDv   : IN STD_LOGIC;
    iEnetRxErr  : IN STD_LOGIC;

    iWbRxEn       : IN  STD_LOGIC;
    iWbRxIntEn    : IN  STD_LOGIC;
    iWbRxIntClr   : IN  STD_LOGIC;
    oWbRxIntInfo  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    iWbRxDescData : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbRxDescData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    iWbRxDescWr   : IN  STD_LOGIC;
    iWbRxDescAddr : IN  STD_LOGIC_VECTOR(8 DOWNTO 2);
    iRxBufBegin   : IN  STD_LOGIC_VECTOR(31 DOWNTO 2);
    iRxBufEnd     : IN  STD_LOGIC_VECTOR(31 DOWNTO 2);

    -- hardware checksum check
    iCheckSumIPCheck   : IN STD_LOGIC;
    iCheckSumTCPCheck  : IN STD_LOGIC;
    iCheckSumUDPCheck  : IN STD_LOGIC;
    iCheckSumICMPCheck : IN STD_LOGIC;
    
    oWbRxInt : OUT STD_LOGIC
    );

END ENTITY rgmii_rx_top;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_rx_top IS

  SIGNAL cSOF        : STD_LOGIC;
  SIGNAL cEof        : STD_LOGIC;
  SIGNAL cErrCrc     : STD_LOGIC;
  SIGNAL cErrLen     : STD_LOGIC;
  SIGNAL cGetArp     : STD_LOGIC;
  SIGNAL cErrCheckSum : STD_LOGIC;
  SIGNAL cGetIPv4    : STD_LOGIC;
  SIGNAL cGetCtrl    : STD_LOGIC;
  SIGNAL cGetRaw     : STD_LOGIC;
  SIGNAL cPayloadLen : UNSIGNED(15 DOWNTO 0);
  SIGNAL cRxData     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL cRxDV       : STD_LOGIC;

  SIGNAL cRxData32                                           : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cRxInfo                                             : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cRxDataRd, cRxInfoRd, cIntNewFrame, cIntNewFrameClr : STD_LOGIC;
  
BEGIN  -- ARCHITECTURE rtl

  rgmii_rx_1 : ENTITY work.rgmii_rx
    PORT MAP (
      iClk               => iEthClk,
      iRst_n             => iRst_n,
      iRxData            => iEnetRxData,
      iRxDV              => iEnetRxDv,
      iRxEr              => iEnetRxErr,
      iCheckSumIPCheck   => iCheckSumIPCheck,
      iCheckSumTCPCheck  => iCheckSumTCPCheck,
      iCheckSumUDPCheck  => iCheckSumUDPCheck,
      iCheckSumICMPCheck => iCheckSumICMPCheck,
      oEOF               => cEof,
      oCRCErr            => cErrCrc,
      oRxErr             => OPEN,
      oLenErr            => cErrLen,
      oCheckSumErr       => cErrCheckSum,
      iMyMAC             => MY_MAC,
      oGetARP            => cGetArp,
      oGetIPv4           => cGetIPv4,
      oGetCtrl           => cGetCtrl,
      oGetRaw            => cGetRaw,
      oSOF               => cSOF,
      oTaged             => OPEN,
      oTagInfo           => OPEN,
      oStackTaged        => OPEN,
      oTagInfo2          => OPEN,
      oLink              => OPEN,
      oSpeed             => OPEN,
      oDuplex            => OPEN,
      oPayloadLen        => cPayloadLen,
      oRxData            => cRxData,
      oRxDV              => cRxDV);

  rgmii_rx_buf_1 : ENTITY work.rgmii_rx_buf
    PORT MAP (
      iEthClk         => iEthClk,
      iWbClk          => iWbClk,
      iRst_n          => iRst_n,
      iEOF            => cEof,
      iRxData         => cRxData,
      iPayloadLen     => cPayloadLen,
      iRxDV           => cRxDV,
      iErrCRC         => cErrCrc,
      iErrCheckSum    => cErrCheckSum,
      iErrLen         => cErrLen,
      iGetArp         => cGetArp,
      iGetIPv4        => cGetIPv4,
      iGetRaw         => cGetRaw,
      iSOF            => cSOF,
      oRxData         => cRxData32,
      oRxLenInfo      => cRxInfo,
      iRxDataRead     => cRxDataRd,
      iRxInfoRead     => cRxInfoRd,
      oIntNewFrame    => cIntNewFrame,
      iIntNewFrameClr => cIntNewFrameClr,
      iRxEn           => iWbRxEn);

  rgmii_rx_wbm_1 : ENTITY work.rgmii_rx_wbm
    GENERIC MAP (
      IN_SIMULATION => IN_SIMULATION)
    PORT MAP (
      iWbClk      => iWbClk,
      iRst_n      => iRst_n,
      oWbM2S      => oWbM2S,
      iWbS2M      => iWbS2M,
      -- synthesis translate_off
      oWbM2S_dat  => oWbM2S_dat,
      oWbM2S_addr => oWbM2S_addr,
      oWbM2S_sel  => oWbM2S_sel,
      oWbM2S_cyc  => oWbM2S_cyc,
      oWbM2S_stb  => oWbM2S_stb,
      oWbM2S_we   => oWbM2S_we,
      oWbM2S_cti  => oWbM2S_cti,
      oWbM2S_bte  => oWbM2S_bte,
      iWbS2M_ack  => iWbS2M_ack,
      -- synthesis translate_on

      iIntNewFrame    => cIntNewFrame,
      oIntNewFrameClr => cIntNewFrameClr,
      oRxDataRead     => cRxDataRd,
      iRxData         => cRxData32,
      oRxInfoRead     => cRxInfoRd,
      iRxInfo         => cRxInfo,

      iRegBufBegin => iRxBufBegin,
      iRegBufEnd   => iRxBufEnd,
      iWbAddr      => iWbRxDescAddr,
      iWbWE        => iWbRxDescWr,
      iWbData      => iWbRxDescData,
      oWbData      => oWbRxDescData,
      iWbRxIntClr  => iWbRxIntClr,
      oWbRxIntInfo => oWbRxIntInfo,
      oWbRxInt     => oWbRxInt,
      iWbRxIntEn   => iWbRxIntEn);

END ARCHITECTURE rtl;

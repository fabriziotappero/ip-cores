-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_top.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2012-12-02
-- Last update: 2013-05-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-12-02  1.0      liyi    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.de2_pkg.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_top IS
  GENERIC(
    MY_MAC        : STD_LOGIC_VECTOR(47 DOWNTO 0) := X"10BF487A0FED";
    IN_SIMULATION : BOOLEAN                       := FALSE);
  PORT (
    iWbClk : IN STD_LOGIC;
    iRst_n : IN STD_LOGIC;

    ---------------------------------------------------------------------------
    -- wishbone slave
    ---------------------------------------------------------------------------
    iWbM2S      : IN  wbMasterToSlaveIF_t;
    oWbS2M      : OUT wbSlaveToMasterIF_t;
    -- synthesis translate_off
    iWbM2S_addr : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    iWbM2S_dat  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    iWbM2S_sel  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0)  := (OTHERS => '0');
    iWbM2S_stb  : IN  STD_LOGIC                     := '0';
    iWbM2S_cyc  : IN  STD_LOGIC                     := '0';
    iWbM2S_we   : IN  STD_LOGIC                     := '0';
    oWbS2M_dat  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbS2M_ack  : OUT STD_LOGIC;
    -- synthesis translate_ON

    ---------------------------------------------------------------------------
    -- wishbone master for read
    ---------------------------------------------------------------------------
    oWb0M2S      : OUT wbMasterToSlaveIF_t;
    iWb0S2M      : IN  wbSlaveToMasterIF_t;
    -- synthesis translate_off
    oWb0M2S_dat  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWb0M2S_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWb0M2S_sel  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    oWb0M2S_cyc  : OUT STD_LOGIC;
    oWb0M2S_stb  : OUT STD_LOGIC;
    oWb0M2S_we   : OUT STD_LOGIC;
    oWb0M2S_cti  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    oWb0M2S_bte  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    iWb0S2M_ack  : IN  STD_LOGIC := '0';
    -- synthesis translate_on

    ---------------------------------------------------------------------------
    -- wishbone master for write
    ---------------------------------------------------------------------------
    oWb1M2S      : OUT wbMasterToSlaveIF_t;
    iWb1S2M      : IN  wbSlaveToMasterIF_t;
    -- synthesis translate_off
    oWb1M2S_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWb1M2S_sel  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    oWb1M2S_cyc  : OUT STD_LOGIC;
    oWb1M2S_stb  : OUT STD_LOGIC;
    oWb1M2S_we   : OUT STD_LOGIC;
    oWb1M2S_cti  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    oWb1M2S_bte  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    iWb1S2M_ack  : IN  STD_LOGIC                     := '0';
    iWb1S2M_dat  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    -- synthesis translate_on

    ---------------------------------------------------------------------------
    -- rgmii for enet0
    ---------------------------------------------------------------------------
    ENET1_MDC     : OUT   STD_LOGIC;
    ENET1_MDIO    : INOUT STD_LOGIC;
    ENET1_RX_CLK  : IN    STD_LOGIC;
    ENET1_RX_DV   : IN    STD_LOGIC;
    ENET1_RX_DATA : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
    ENET1_GTX_CLK : OUT   STD_LOGIC;
    ENET1_TX_EN   : OUT   STD_LOGIC;
    ENET1_TX_DATA : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);

    oTxInt : OUT STD_LOGIC;
    oRxInt : OUT STD_LOGIC
    );

END ENTITY rgmii_top;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_top IS

  SIGNAL mdHz, mdi0, mdi1, mdi, mdc : STD_LOGIC;
  SIGNAL phyAddr, regAddr           : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL noPre                      : STD_LOGIC;
  SIGNAL rdOp, wrOp                 : STD_LOGIC;
  SIGNAL clkDiv                     : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL clrRdOp, clrWrOp           : STD_LOGIC;
  SIGNAL data2PHY, dataFromPhy      : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL dataFromPhyValid           : STD_LOGIC;
  SIGNAL mdioBusy                   : STD_LOGIC;

  SIGNAL cEnetTxData : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL cEnetTxEn   : STD_LOGIC;
  SIGNAL cEnetTxErr  : STD_LOGIC;
  SIGNAL cEnetRxData : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL cEnetRxDV   : STD_LOGIC;
  SIGNAL cEnetRxErr  : STD_LOGIC;
  SIGNAL cEthClk     : STD_LOGIC;

  SIGNAL cTxEn        : STD_LOGIC;
  SIGNAL cTxIntEn     : STD_LOGIC;
  SIGNAL cTxIntClr    : STD_LOGIC;
  SIGNAL cTxIntInfo   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL cTxDescDataO : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cTxDescDataI : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cTxDescWr    : STD_LOGIC;
  SIGNAL cTxDescAddr  : STD_LOGIC_VECTOR(8 DOWNTO 2);

  SIGNAL cRxEn        : STD_LOGIC;
  SIGNAL cRxDescAddr  : STD_LOGIC_VECTOR(8 DOWNTO 2);
  SIGNAL cRxDescWr    : STD_LOGIC;
  SIGNAL cRxDescDataO : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cRxDescDataI : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cRxIntClr    : STD_LOGIC;
  SIGNAL cRxIntInfo   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL cRxIntEn     : STD_LOGIC;
  SIGNAL cRxBufBegin  : STD_LOGIC_VECTOR(31 DOWNTO 2);
  SIGNAL cRxBufEnd    : STD_LOGIC_VECTOR(31 DOWNTO 2);

  SIGNAL cCheckSumIPCheck   : STD_LOGIC;
  SIGNAL cCheckSumTCPCheck  : STD_LOGIC;
  SIGNAL cCheckSumUDPCheck  : STD_LOGIC;
  SIGNAL cCheckSumICMPCheck : STD_LOGIC;

  SIGNAL cCheckSumIPGen   : STD_LOGIC;
  SIGNAL cCheckSumTCPGen  : STD_LOGIC;
  SIGNAL cCheckSumUDPGen  : STD_LOGIC;
  SIGNAL cCheckSumICMPGen : STD_LOGIC;
  
BEGIN  -- ARCHITECTURE rtl

  --ENET0_MDC  <= mdc;
  ENET1_MDC  <= mdc;
  --ENET0_MDIO <= 'Z' WHEN mdHz = '1' ELSE '0';
  ENET1_MDIO <= 'Z' WHEN mdHz = '1' ELSE '0';
  --mdi0       <= ENET0_MDIO;
  mdi1       <= ENET1_MDIO;
  mdi0       <= '1';
  mdi        <= mdi0 AND mdi1;
  rgmii_mdio_1 : ENTITY work.rgmii_mdio
    PORT MAP (
      iWbClk            => iWbClk,
      iRst_n            => iRst_n,
      iPHYAddr          => phyAddr,
      iRegAddr          => regAddr,
      iNoPre            => noPre,
      iData2PHY         => data2PHY,
      --iClkDiv           => clkDiv,
      iClkDiv           => X"FF",
      iRdOp             => rdOp,
      iWrOp             => wrOp,
      oDataFromPHY      => dataFromPhy,
      oDataFromPHYValid => dataFromPhyValid,
      oClrRdOp          => clrRdOp,
      oClrWrOp          => clrWrOp,
      oMDIOBusy         => mdioBusy,
      iMDI              => mdi,
      oMDHz             => mdHz,
      oMDC              => mdc);

  rgmii_wbs_1 : ENTITY work.rgmii_wbs
    GENERIC MAP (
      IN_SIMULATION => IN_SIMULATION)
    PORT MAP (
      iWbClk => iWbClk,
      iRst_n => iRst_n,
      iWbM2S => iWbM2S,
      oWbS2M => oWbS2M,

      -- synthesis translate_off
      iWbM2S_addr => iWbM2S_addr,
      iWbM2S_dat  => iWbM2S_dat,
      iWbM2S_sel  => iWbM2S_sel,
      iWbM2S_stb  => iWbM2S_stb,
      iWbM2S_cyc  => iWbM2S_cyc,
      iWbM2S_we   => iWbM2S_we,
      oWbS2M_dat  => oWbS2M_dat,
      oWbS2M_ack  => oWbS2M_ack,
      -- synthesis translate_on

      oTxEn       => cTxEn,
      oTxIntEn    => cTxIntEn,
      oTxIntClr   => cTxIntClr,
      iTxIntInfo  => cTxIntInfo,
      oTxDescData => cTxDescDataO,
      iTxDescData => cTxDescDataI,
      oTxDescWr   => cTxDescWr,
      oTxDescAddr => cTxDescAddr,

      oCheckSumIPGen   => cCheckSumIPGen,
      oCheckSumTCPGen  => cCheckSumTCPGen,
      oCheckSumUDPGen  => cCheckSumUDPGen,
      oCheckSumICMPGen => cCheckSumICMPGen,

      oRxEn       => cRxEn,
      oRxDescAddr => cRxDescAddr,
      oRxDescWr   => cRxDescWr,
      oRxDescData => cRxDescDataO,
      iRxDescData => cRxDescDataI,
      oRxIntClr   => cRxIntClr,
      iRxIntInfo  => cRxIntInfo,
      oRxIntEn    => cRxIntEn,
      oRxBufBegin => cRxBufBegin,
      oRxBufEnd   => cRxBufEnd,

      oCheckSumIPCheck   => cCheckSumIPCheck,
      oCheckSumTCPCheck  => cCheckSumTCPCheck,
      oCheckSumUDPCheck  => cCheckSumUDPCheck,
      oCheckSumICMPCheck => cCheckSumICMPCheck,

      oPHYAddr          => phyAddr,
      oRegAddr          => regAddr,
      oRdOp             => rdOp,
      oWrOp             => wrOp,
      oNoPre            => noPre,
      oClkDiv           => clkDiv,
      iClrRdOp          => clrRdOp,
      iClrWrOp          => clrWrOp,
      oDataToPHY        => data2PHY,
      iDataFromPHY      => dataFromPhy,
      iDataFromPHYValid => dataFromPhyValid,
      iMDIOBusy         => mdioBusy);

  rgmii_io_1 : ENTITY work.rgmii100_io
    PORT MAP (
      iRst_n  => iRst_n,
      TXC     => ENET1_GTX_CLK,
      TX_CTL  => ENET1_TX_EN,
      TD      => ENET1_TX_DATA,
      RXC     => ENET1_RX_CLK,
      RX_CTL  => ENET1_RX_DV,
      RD      => ENET1_RX_DATA,
      iTxData => cEnetTxData,
      iTxEn   => cEnetTxEn,
      iTxErr  => cEnetTxErr,
      oRxData => cEnetRxData,
      oRxDV   => cEnetRxDV,
      oRxErr  => cEnetRxErr,
      oEthClk => cEthClk);

  rgmii_rx_top_1 : ENTITY work.rgmii_rx_top
    GENERIC MAP (
      MY_MAC        => MY_MAC,
      IN_SIMULATION => IN_SIMULATION)
    PORT MAP (
      iWbClk        => iWbClk,
      iEthClk       => cEthClk,
      iRst_n        => iRst_n,
      iWbS2M        => iWb0S2M,
      oWbM2S        => oWb0M2S,
      -- synthesis translate_off
      oWbM2S_dat    => oWb0M2S_dat,
      oWbM2S_addr   => oWb0M2S_addr,
      oWbM2S_sel    => oWb0M2S_sel,
      oWbM2S_cyc    => oWb0M2S_cyc,
      oWbM2S_stb    => oWb0M2S_stb,
      oWbM2S_we     => oWb0M2S_we,
      oWbM2S_cti    => oWb0M2S_cti,
      oWbM2S_bte    => oWb0M2S_bte,
      iWbS2M_ack    => iWb0S2M_ack,
      -- synthesis translate_on
      iEnetRxData   => cEnetRxData,
      iEnetRxDv     => cEnetRxDv,
      iEnetRxErr    => cEnetRxErr,
      iWbRxEn       => cRxEn,
      iWbRxIntEn    => cRxIntEn,
      iWbRxIntClr   => cRxIntClr,
      oWbRxIntInfo  => cRxIntInfo,
      iWbRxDescData => cRxDescDataO,
      oWbRxDescData => cRxDescDataI,
      iWbRxDescWr   => cRxDescWr,
      iWbRxDescAddr => cRxDescAddr,
      iRxBufBegin   => cRxBufBegin,
      iRxBufEnd     => cRxBufEnd,

      iCheckSumIPCheck   => cCheckSumIPCheck,
      iCheckSumTCPCheck  => cCheckSumTCPCheck,
      iCheckSumUDPCheck  => cCheckSumUDPCheck,
      iCheckSumICMPCheck => cCheckSumICMPCheck,

      oWbRxInt => oRxInt);

  rgmii_tx_top_1 : ENTITY work.rgmii_tx_top
    GENERIC MAP (
      IN_SIMULATION => IN_SIMULATION)
    PORT MAP (
      iWbClk        => iWbClk,
      iEthClk       => cEthClk,
      iRst_n        => iRst_n,
      iWbS2M        => iWb1S2M,
      oWbM2S        => oWb1M2S,
      -- synthesis translate_off
      oWbM2S_addr   => oWb1M2S_addr,
      oWbM2S_sel    => oWb1M2S_sel,
      oWbM2S_cyc    => oWb1M2S_cyc,
      oWbM2S_stb    => oWb1M2S_stb,
      oWbM2S_we     => oWb1M2S_we,
      oWbM2S_cti    => oWb1M2S_cti,
      oWbM2S_bte    => oWb1M2S_bte,
      iWbS2M_ack    => iWb1S2M_ack,
      iWbS2M_dat    => iWb1S2M_dat,
      -- synthesis translate_on
      oEnetTxData   => cEnetTxData,
      oEnetTxEn     => cEnetTxEn,
      oEnetTxErr    => cEnetTxErr,
      iWbTxEn       => cTxEn,
      iWbTxIntEn    => cTxIntEn,
      iWbTxIntClr   => cTxIntClr,
      oWbTxIntInfo  => cTxIntInfo,
      iWbTxDescData => cTxDescDataO,
      oWbTxDescData => cTxDescDataI,
      iWbTxDescWr   => cTxDescWr,
      iWbTxDescAddr => cTxDescAddr,

      iCheckSumIPGen   => cCheckSumIPGen,
      iCheckSumTCPGen  => cCheckSumTCPGen,
      iCheckSumUDPGen  => cCheckSumUDPGen,
      iCheckSumICMPGen => cCheckSumICMPGen,
      
      oWbTxInt      => oTxInt);

END ARCHITECTURE rtl;

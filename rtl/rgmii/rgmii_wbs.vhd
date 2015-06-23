-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_wbs.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2012-12-02
-- Last update: 2013-05-20
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
USE ieee.numeric_std.ALL;
USE work.de2_pkg.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_wbs IS
  GENERIC (
    IN_SIMULATION : BOOLEAN := FALSE);
  PORT (
    iWbClk : IN STD_LOGIC;
    iRst_n : IN STD_LOGIC;

    iWbM2S      : IN  wbMasterToSlaveIF_t;
    oWbS2M      : OUT wbSlaveToMasterIF_t;
    -- synthesis translate_off
    iWbM2S_addr : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    iWbM2S_dat  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    iWbM2S_sel  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
    iWbM2S_stb  : IN  STD_LOGIC;
    iWbM2S_cyc  : IN  STD_LOGIC;
    iWbM2S_we   : IN  STD_LOGIC;
    oWbS2M_dat  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbS2M_ack  : OUT STD_LOGIC;
    -- synthesis translate_on

    ---------------------------------------------------------------------------
    -- tx wishbone master
    ---------------------------------------------------------------------------
    oTxEn            : OUT STD_LOGIC;   -- tx module enable
    oTxIntEn         : OUT STD_LOGIC;   -- interrupt enable
    oTxIntClr        : OUT STD_LOGIC;   -- clear interrupt SIGNAL
    iTxIntInfo       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    oTxDescData      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    iTxDescData      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    oTxDescWr        : OUT STD_LOGIC;
    oTxDescAddr      : OUT STD_LOGIC_VECTOR(8 DOWNTO 2);
    -- hardware checksum generation
    oCheckSumIPGen   : OUT STD_LOGIC;
    oCheckSumTCPGen  : OUT STD_LOGIC;
    oCheckSumUDPGen  : OUT STD_LOGIC;
    oCheckSumICMPGen : OUT STD_LOGIC;

    ---------------------------------------------------------------------------
    -- rx wishbone master
    ---------------------------------------------------------------------------
    oRxEn              : OUT STD_LOGIC;
    oRxDescAddr        : OUT STD_LOGIC_VECTOR(8 DOWNTO 2);
    oRxDescWr          : OUT STD_LOGIC;
    oRxDescData        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    iRxDescData        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    oRxIntClr          : OUT STD_LOGIC;
    iRxIntInfo         : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    oRxIntEn           : OUT STD_LOGIC;
    oRxBufBegin        : OUT STD_LOGIC_VECTOR(31 DOWNTO 2);
    oRxBufEnd          : OUT STD_LOGIC_VECTOR(31 DOWNTO 2);
    -- hardware checksum check
    oCheckSumIPCheck   : OUT STD_LOGIC;
    oCheckSumTCPCheck  : OUT STD_LOGIC;
    oCheckSumUDPCheck  : OUT STD_LOGIC;
    oCheckSumICMPCheck : OUT STD_LOGIC;

    ---------------------------------------------------------------------------
    -- MDIO
    ---------------------------------------------------------------------------
    oPHYAddr          : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    oRegAddr          : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    oRdOp             : OUT STD_LOGIC;
    oWrOp             : OUT STD_LOGIC;
    oNoPre            : OUT STD_LOGIC;
    oClkDiv           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    iClrRdOp          : IN  STD_LOGIC                     := '0';
    iClrWrOp          : IN  STD_LOGIC                     := '0';
    oDataToPHY        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    iDataFromPHY      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0) := X"0000";
    iDataFromPHYValid : IN  STD_LOGIC                     := '0';
    iMDIOBusy         : IN  STD_LOGIC                     := '0'
    );

END ENTITY rgmii_wbs;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_wbs IS
  TYPE state_t IS (IDLE, WAIT1, WAIT2, WAIT3);
  SIGNAL rState   : state_t;
  SIGNAL rRegCtrl : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL cWbDatI : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cWbAddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cWbWE   : STD_LOGIC;
  SIGNAL cWbCyc  : STD_LOGIC;
  SIGNAL cWbStb  : STD_LOGIC;
  SIGNAL cWbSel  : STD_LOGIC_VECTOR(3 DOWNTO 0);

  SIGNAL rWbAck  : STD_LOGIC;
  SIGNAL rWbDatO : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN  -- ARCHITECTURE rtl

  oWbS2M.stall <= '0';
  oWbS2M.err   <= '0';
  oWbS2M.rty   <= '0';
  oWbS2M.ack   <= rWbAck;
  oWbS2M.dat   <= rWbDatO;

  -- synthesis translate_off
  gen0 : IF IN_SIMULATION GENERATE
    cWbDatI <= iWbM2S_dat;
    cWbAddr <= iWbM2S_addr;
    cWbWE   <= iWbM2S_we;
    cWbCyc  <= iWbM2S_cyc;
    cWbStb  <= iWbM2S_stb;
    cWbSel  <= iWbM2S_sel;
  END GENERATE gen0;
  oWbS2M_ack <= rWbAck;
  oWbS2M_dat <= rWbDatO;
  -- synthesis translate_on
  gen1 : IF NOT IN_SIMULATION GENERATE
    cWbDatI <= iWbM2S.dat;
    cWbAddr <= iWbM2S.addr;
    cWbWE   <= iWbM2S.we;
    cWbCyc  <= iWbM2S.cyc;
    cWbStb  <= iWbM2S.stb;
    cWbSel  <= iWbM2S.sel;
  END GENERATE gen1;

  oTxDescData <= cWbDatI;
  oTxDescAddr <= cWbAddr(8 DOWNTO 2);
  oTxDescWr   <= cWbWE AND
                 cWbStb AND
                 cWbCyc AND
                 NOT cWbAddr(10) AND
                 NOT cWbAddr(9);

  oRxDescData <= cWbDatI;
  oRxDescAddr <= cWbAddr(8 DOWNTO 2);
  oRxDescWr   <= cWbWE AND
                 cWbStb AND
                 cWbCyc AND
                 NOT cWbAddr(10) AND
                 cWbAddr(9);

  oTxEn              <= rRegCtrl(0);
  oTxIntEn           <= rRegCtrl(1);
  oCheckSumIPGen     <= rRegCtrl(8);
  oCheckSumTCPGen    <= rRegCtrl(9);
  oCheckSumUDPGen    <= rRegCtrl(10);
  oCheckSumICMPGen   <= rRegCtrl(11);
  oRxEn              <= rRegCtrl(16);
  oRxIntEn           <= rRegCtrl(17);
  oCheckSumIPCheck   <= rRegCtrl(24);
  oCheckSumTCPCheck  <= rRegCtrl(25);
  oCheckSumUDPCheck  <= rRegCtrl(26);
  oCheckSumICMPCheck <= rRegCtrl(27);
  PROCESS (iWbClk, iRst_n) IS
  BEGIN
    IF iRst_n = '0' THEN
      rWbAck      <= '0';
      rWbDatO     <= (OTHERS => '0');
      oTxIntClr   <= '0';
      oRxIntClr   <= '0';
      rRegCtrl    <= (OTHERS => '0');
      oRxBufBegin <= (OTHERS => '0');
      oRxBufEnd   <= (OTHERS => '0');
    ELSIF rising_edge(iWbClk) THEN
      oTxIntClr <= '0';
      oRxIntClr <= '0';
      rWbAck    <= '0';
      CASE rState IS
        WHEN IDLE =>
          IF cWbCyc = '1' AND cWbStb = '1' THEN
            rWbAck <= cWbWE;
            IF cWbWE = '1' THEN
              rState <= WAIT3;
            ELSE
              rState <= WAIT1;
            END IF;

            IF cWbWE = '0' AND cWbAddr(10) = '1' THEN
              IF cWbAddr(3 DOWNTO 2) = B"11" THEN
                oTxIntClr <= cWbSel(0);
                oRxIntClr <= cWbSel(1);
              END IF;
            END IF;
            IF (cWbWE AND cWbAddr(10)) = '1' THEN
              CASE cWbAddr(3 DOWNTO 2) IS
                WHEN B"00" =>
                  rRegCtrl <= cWbDatI;
                WHEN B"01" =>
                  oRxBufBegin <= cWbDatI(31 DOWNTO 2);
                WHEN B"10" =>
                  oRxBufEnd <= cWbDatI(31 DOWNTO 2);
                WHEN OTHERS => NULL;
              END CASE;
            END IF;
          END IF;
        -----------------------------------------------------------------------
        WHEN WAIT1 =>
          rState <= WAIT2;
        WHEN WAIT2 =>
          rState <= WAIT3;
          rWbAck <= '1';
          IF cWbAddr(10) = '0' THEN
            IF cWbAddr(9) = '0' THEN
              rWbDatO <= iTxDescData;
            ELSE
              rWbDatO <= iRxDescData;
            END IF;
          ELSE
            CASE cWbAddr(3 DOWNTO 2) IS
              WHEN B"11"  => rWbDatO <= X"0000"&iRxIntInfo&iTxIntInfo;
              WHEN OTHERS => NULL;
            END CASE;
          END IF;
        -----------------------------------------------------------------------
        WHEN WAIT3 =>
          rState <= IDLE;
        WHEN OTHERS => NULL;
      END CASE;
    END IF;
  END PROCESS;
  
END ARCHITECTURE rtl;

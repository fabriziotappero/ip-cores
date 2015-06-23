-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_tx.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2012-11-15
-- Last update: 2013-05-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-11-15  1.0      root    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_tx IS

  PORT (
    iClk   : IN STD_LOGIC;
    iRst_n : IN STD_LOGIC;

    -- from fifo
    iTxData     : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
    oSOF        : OUT STD_LOGIC;
    iEOF        : IN  STD_LOGIC;
    iGenFrame   : IN  STD_LOGIC;
    oGenFrameAck : OUT STD_LOGIC;

    -- signals TO PHY
    oTxData : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    oTxEn   : OUT STD_LOGIC;
    oTxErr  : OUT STD_LOGIC
    );

END ENTITY rgmii_tx;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_tx IS

  TYPE state_t IS (IDLE, PREAMBLE, SEND_DATA, PAD, SEND_CRC, IPG);
  SIGNAL state                      : state_t;
  ATTRIBUTE syn_encoding            : STRING;
  ATTRIBUTE syn_encoding OF state_t : TYPE IS "safe,onehot";

  SIGNAL byteCnt : UNSIGNED(15 DOWNTO 0);

  SIGNAL crcInit : STD_LOGIC;
  SIGNAL crcEn   : STD_LOGIC;
  SIGNAL crc     : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
BEGIN  -- ARCHITECTURE rtl

  crcCalc : ENTITY work.eth_crc32
    PORT MAP (
      iClk    => iClk,
      iRst_n  => iRst_n,
      iInit   => crcInit,
      iCalcEn => crcEn,
      iData   => iTxData,
      oCRC    => crc,
      oCRCErr => OPEN);

  oTxErr <= '0';

  PROCESS (iClk, iRst_n) IS
  BEGIN
    IF iRst_n = '0' THEN
      state        <= IDLE;
      oSOF         <= '0';
      byteCnt      <= (OTHERS => '0');
      oGenFrameAck <= '0';
      crcInit      <= '0';
      crcEn        <= '0';
      oTxData      <= (OTHERS => '0');
      oTxEn        <= '0';
    ELSIF rising_edge(iClk) THEN
      oGenFrameAck <= '0';
      crcInit      <= '0';
      oSOF         <= '0';
      byteCnt      <= byteCnt + 1;
      CASE state IS
        WHEN IDLE =>
          byteCnt <= (OTHERS => '0');
          IF iGenFrame = '1' THEN
            crcInit      <= '1';
            oGenFrameAck <= '1';
            state        <= PREAMBLE;
          END IF;
        -----------------------------------------------------------------------
        WHEN PREAMBLE =>
          oTxEn   <= '1';
          oTxData <= X"55";
          CASE byteCnt(2 DOWNTO 0) IS
            WHEN B"101" => oSOF <= '1';
            WHEN B"111" =>
              oTxData <= X"D5";
              crcEn   <= '1';
              state   <= SEND_DATA;
              byteCnt <= (OTHERS => '0');
            WHEN OTHERS => NULL;
          END CASE;
        -----------------------------------------------------------------------
        WHEN SEND_DATA =>
          oTxData <= iTxData;
          IF iEOF = '1' THEN
            IF byteCnt < X"003B" THEN
              state <= PAD;
            ELSE
              state <= SEND_CRC;
              crcEn <= '0';
              byteCnt <= (OTHERS => '0');
            END IF;
          END IF;
        -----------------------------------------------------------------------
        WHEN PAD =>
          oTxData <= iTxData;
          IF byteCnt(7 DOWNTO 0) = X"3B" THEN
            crcEn   <= '0';
            state   <= SEND_CRC;
            byteCnt <= (OTHERS => '0');
          END IF;
        -----------------------------------------------------------------------
        WHEN SEND_CRC =>
          CASE byteCnt(1 DOWNTO 0) IS
            WHEN B"00" => oTxData <= crc(31 DOWNTO 24);
            WHEN B"01" => oTxData <= crc(23 DOWNTO 16);
            WHEN B"10" => oTxData <= crc(15 DOWNTO 8);
            WHEN B"11" =>
              oTxData <= crc(7 DOWNTO 0);
              state   <= IPG;
              byteCnt <= (OTHERS => '0');
            WHEN OTHERS => NULL;
          END CASE;
        -----------------------------------------------------------------------
        WHEN IPG =>                     -- 96 bits(12 Bytes) time
          oTxEn <= '0';
          IF byteCnt(3 DOWNTO 0) = X"B" THEN
            state   <= IDLE;
            byteCnt <= (OTHERS => '0');
          END IF;
        -----------------------------------------------------------------------
        WHEN OTHERS => NULL;
      END CASE;
    END IF;
  END PROCESS;

END ARCHITECTURE rtl;

-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_tx_buf.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2013-05-06
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
-- 2013-05-06  1.0      liyi    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_tx_buf IS

  PORT (
    iEthClk : IN STD_LOGIC;
    iWbClk  : IN STD_LOGIC;
    iRst_n  : IN STD_LOGIC;

    --oEthTxLen       : OUT UNSIGNED(15 DOWNTO 0);
    oEthTxData      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    iEthSOF         : IN  STD_LOGIC;
    oEthEOF         : OUT STD_LOGIC;
    oEthGenFrame    : OUT STD_LOGIC;
    iEthGenFrameAck : IN  STD_LOGIC;

    iWbTxData   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    iWbTxAddr   : IN UNSIGNED(10 DOWNTO 0);
    iWbTxDataWr : IN STD_LOGIC;
    iWbTxInfo   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    iWbTxInfoWr : IN STD_LOGIC;

    iWbIntEn  : IN  STD_LOGIC;
    iWbIntClr : IN  STD_LOGIC;
    oWbInt    : OUT STD_LOGIC;
    oWbTxInfo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );

END ENTITY rgmii_tx_buf;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_tx_buf IS

  CONSTANT DATA_WIDTH : NATURAL                              := 32;
  CONSTANT ADDR_WIDTH : NATURAL                              := 11;
  -- Build a 2-D array type for the RAM
  SUBTYPE word_t IS STD_LOGIC_VECTOR((DATA_WIDTH-1) DOWNTO 0);
  TYPE memory_t IS ARRAY(2**ADDR_WIDTH-1 DOWNTO 0) OF word_t;
  -- Declare the RAM signal.    
  SIGNAL ram          : memory_t;
  SIGNAL raddr        : UNSIGNED(ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
  --SIGNAL waddr        : UNSIGNED(ADDR_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL rWE          : STD_LOGIC                            := '0';
  SIGNAL rTxData      : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL cInfoFifoEmpty : STD_LOGIC;
  SIGNAL cInfoFifoFull  : STD_LOGIC;
  SIGNAL cInfo          : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN  -- ARCHITECTURE rtl

  blk2 : BLOCK IS
    SIGNAL rWbTxInfo : STD_LOGIC_VECTOR(31 DOWNTO 0);
  BEGIN  -- BLOCK blk2
    oWbTxInfo(1 DOWNTO 0)              <= B"00";
    oWbTxInfo(31)                      <= cInfoFifoFull;
    oWbTxInfo(30 DOWNTO ADDR_WIDTH+16) <= (OTHERS => '0');
	-- tell the tx wbm module the next frame begin address in the buffer
	-- this infomation will be send back to this module!
    -- oWbTxInfo(ADDR_WIDTH+15 DOWNTO 16) <= STD_LOGIC_VECTOR(waddr);
    oWbTxInfo(ADDR_WIDTH+15 DOWNTO 16) <= STD_LOGIC_VECTOR(iWbTxAddr);
    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        rWbTxInfo(15 DOWNTO 2) <= (OTHERS => '0');
        oWbTxInfo(15 DOWNTO 2) <= (OTHERS => '0');
      ELSIF rising_edge(iWbClk) THEN
        rWbTxInfo(15 DOWNTO 2) <= STD_LOGIC_VECTOR(
          TO_UNSIGNED(
            --2**ADDR_WIDTH - TO_INTEGER(waddr) + TO_INTEGER(raddr), 14));
            2**ADDR_WIDTH - TO_INTEGER(iWbTxAddr) + TO_INTEGER(raddr), 14));
        oWbTxInfo(15 DOWNTO 2) <= rWbTxInfo(15 DOWNTO 2);
      END IF;
    END PROCESS;
  END BLOCK blk2;

  --PROCESS (iWbClk, iRst_n) IS
  --BEGIN
  --  IF iRst_n = '0' THEN
  --    waddr <= (OTHERS => '0');
  --  ELSIF rising_edge(iWbClk) THEN
  --    IF iWbTxDataWr = '1' THEN
  --      waddr <= waddr + 1;
  --    END IF;
  --  END IF;
  --END PROCESS;

  blk1 : BLOCK IS
    --SIGNAL rWordCnt : UNSIGNED(15 DOWNTO 2);
    SIGNAL rByteCnt  : UNSIGNED(15 DOWNTO 0);
    SIGNAL rLen      : UNSIGNED(15 DOWNTO 0);
    --SIGNAL rRipple  : UNSIGNED(1 DOWNTO 0);
    SIGNAL rFinished : STD_LOGIC;
    TYPE state_t IS (IDLE, WAIT1, DATA);
    SIGNAL rState    : state_t;
  BEGIN  -- BLOCK blk1
    PROCESS (iEthClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        raddr        <= (OTHERS => '0');
        --rWordCnt   <= (OTHERS => '0');
        --rRipple    <= (OTHERS => '0');
        rState       <= IDLE;
        oEthGenFrame <= '0';
        oEthTxData   <= (OTHERS => '0');
        oWbInt       <= '0';
        oEthEOF      <= '0';
        rByteCnt     <= (OTHERS => '0');
        rFinished    <= '0';
      ELSIF rising_edge(iEthClk) THEN
        oEthEOF <= '0';
        IF iWbIntClr = '1' THEN
          oWbInt <= '0';
        END IF;
        CASE rState IS
          WHEN IDLE =>
            rFinished <= '0';
            rByteCnt  <= (OTHERS => '0');
            IF cInfoFifoEmpty = '0' THEN
              oEthGenFrame <= '1';
            END IF;
            IF iEthGenFrameAck = '1' THEN
              oEthGenFrame <= '0';
              rState       <= WAIT1;
            END IF;
          ---------------------------------------------------------------------
          WHEN WAIT1 =>
            --IF cInfo(1 DOWNTO 0) /= B"00" THEN
            --  rWordCnt <= UNSIGNED(cInfo(15 DOWNTO 2));
            --ELSE
            --  rWordCnt <= UNSIGNED(cInfo(15 DOWNTO 2)) - 1;
            --END IF;
            rLen  <= UNSIGNED(cInfo(15 DOWNTO 0)) - 1;
            raddr <= UNSIGNED(cInfo(ADDR_WIDTH+15 DOWNTO 16));
            -- there's same clock cycles before iEthSOF asserted....
            IF iEthSOF = '1' THEN
              rState <= DATA;
            END IF;
          ---------------------------------------------------------------------
          WHEN DATA =>
            --rRipple <= rRipple + 1;
            rByteCnt <= rByteCnt + 1;
            --CASE rRipple IS
            IF rByteCnt = rLen THEN
              oEthEOF   <= '1';
              rFinished <= '1';
            END IF;
            CASE rByteCnt(1 DOWNTO 0) IS
              WHEN B"00" => oEthTxData <= rTxData(31 DOWNTO 24);
              WHEN B"01" => oEthTxData <= rTxData(23 DOWNTO 16);
              WHEN B"10" =>
                oEthTxData <= rTxData(15 DOWNTO 8);
                raddr      <= raddr + 1;
              WHEN B"11" =>
                oEthTxData <= rTxData(7 DOWNTO 0);
                --rWordCnt   <= rWordCnt - 1;
                --IF rWordCnt = X"000"&B"00" THEN
                IF rFinished = '1' OR rByteCnt = rLen THEN
                  rState <= IDLE;
                  oWbInt <= iWbIntEn;
                END IF;
              WHEN OTHERS => NULL;
            END CASE;
          ---------------------------------------------------------------------
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
  END BLOCK blk1;

  -----------------------------------------------------------------------------
  -- data buffer
  -----------------------------------------------------------------------------
  PROCESS(iWbClk)
  BEGIN
    IF(rising_edge(iWbClk)) THEN
      IF(iWbTxDataWr = '1') THEN
        --ram(TO_INTEGER(waddr)) <= iWbTxData;
        ram(TO_INTEGER(iWbTxAddr)) <= iWbTxData;
      END IF;
    END IF;
  END PROCESS;
  PROCESS(iEthClk)
  BEGIN
    IF(rising_edge(iEthClk)) THEN
      rTxData <= ram(TO_INTEGER(raddr));
    END IF;
  END PROCESS;

  --oEthTxLen <= UNSIGNED(cInfo(15 DOWNTO 0));
  fifo32x8_1 : ENTITY work.fifo32x8
    PORT MAP (
      data    => iWbTxInfo,
      rdclk   => iEthClk,
      rdreq   => iEthGenFrameAck,
      wrclk   => iWbClk,
      wrreq   => iWbTxInfoWr,
      q       => cInfo,
      rdempty => cInfoFifoEmpty,
      wrfull  => cInfoFifoFull);

END ARCHITECTURE rtl;

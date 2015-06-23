-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_rx_buf.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2013-05-05
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
-- 2013-05-05  1.0      liyi    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_rx_buf IS

  PORT (
    iEthClk : IN STD_LOGIC;
    iWbClk  : IN STD_LOGIC;
    iRst_n  : IN STD_LOGIC;

    iEOF        : IN STD_LOGIC;
    iRxData     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    iPayloadLen : IN UNSIGNED(15 DOWNTO 0);
    iRxDV       : IN STD_LOGIC;
    iErrCRC     : IN STD_LOGIC;
    iErrLen     : IN STD_LOGIC;
    iErrCheckSum: IN STD_LOGIC;
    iGetArp     : IN STD_LOGIC;
    iGetIPv4    : IN STD_LOGIC;
    iGetRaw     : IN STD_LOGIC;
    iSOF        : IN STD_LOGIC;

    oRxData     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oRxLenInfo  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    iRxDataRead : IN  STD_LOGIC;
    iRxInfoRead : IN  STD_LOGIC;

    oIntNewFrame    : OUT STD_LOGIC;
    iIntNewFrameClr : IN  STD_LOGIC;

    -- receive enable
    iRxEn : IN STD_LOGIC
    );

END ENTITY rgmii_rx_buf;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_rx_buf IS

  CONSTANT DATA_WIDTH : NATURAL  := 32;
  CONSTANT ADDR_WIDTH : NATURAL  := 11;
  -- Build a 2-D array type for the RAM
  SUBTYPE word_t IS STD_LOGIC_VECTOR((DATA_WIDTH-1) DOWNTO 0);
  TYPE memory_t IS ARRAY(2**ADDR_WIDTH-1 DOWNTO 0) OF word_t;
  -- Declare the RAM signal.    
  SIGNAL ram          : memory_t := (OTHERS => (OTHERS => '0'));
  SIGNAL raddr        : NATURAL RANGE 0 TO 2**ADDR_WIDTH - 1;
  SIGNAL waddr        : NATURAL RANGE 0 TO 2**ADDR_WIDTH - 1;
  SIGNAL rWE          : STD_LOGIC;
  SIGNAL rRxData      : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL rRxInfoI       : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cRxInfoO       : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL cInfoFifoRd    : STD_LOGIC;
  SIGNAL rInfoFifoWr    : STD_LOGIC;
  SIGNAL cInfoFifoEmpty : STD_LOGIC;
  SIGNAL cInfoFifoFull  : STD_LOGIC;

BEGIN  -- ARCHITECTURE rtl

  blk0 : BLOCK IS
    TYPE state_t IS (IDLE, DATA);
    SIGNAL rState     : state_t;
    SIGNAL rCnt       : UNSIGNED(1 DOWNTO 0);
    SIGNAL rBeginAddr : NATURAL RANGE 0 TO 2**ADDR_WIDTH - 1;

    --SIGNAL rNewFrame  : STD_LOGIC;
    --SIGNAL rNewFrameD : STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL rInfoFifoRdD1 : STD_LOGIC;
  BEGIN  -- BLOCK blk0
    PROCESS (iEthClk, iRst_n) IS
    --VARIABLE vGetFrame : STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN
      IF iRst_n = '0' THEN
        rState                           <= IDLE;
        rCnt                             <= (OTHERS => '0');
        waddr                            <= 0;
        rBeginAddr                       <= 0;
        rWE                              <= '0';
        --rNewFrame   <= '0';
        rRxInfoI(15+ADDR_WIDTH DOWNTO 0) <= (OTHERS => '0');
        rInfoFifoWr                      <= '0';
        rRxInfoI(31 DOWNTO 28) <= (OTHERS => '0');
      ELSIF rising_edge(iEthClk) THEN
        rWE                               <= '0';
        rInfoFifoWr                       <= '0';
        --rRxInfoI(27 DOWNTO ADDR_WIDTH+16) <= (OTHERS => '0');
        IF rWE = '1' THEN
          -- synthesis translate_off
          IF waddr < 2**ADDR_WIDTH-1 THEN
            -- synthesis translate_on
            waddr <= waddr + 1;
          -- synthesis translate_off
          END IF;
        -- synthesis translate_on
        END IF;
        CASE rState IS
          WHEN IDLE =>
            rCnt <= (OTHERS => '0');
            --vGetFrame              := '0'&iGetArp&iGetIPv4&iGetRaw;
            --rRxInfoI(31 DOWNTO 28) <= vGetFrame;
            -- IF vGetFrame /= X"0" AND iRxEn = '1' AND cInfoFifoFull = '0' THEN
            -- IF iSOF = '1' AND iRxEn = '1' AND cInfoFifoFull = '0' THEN
			IF iSOF = '1' AND cInfoFifoFull = '0' THEN
              rState     <= DATA;
              rBeginAddr <= waddr;
              --rNewFrame  <= '0';

              rRxInfoI(15+ADDR_WIDTH DOWNTO 16) <= STD_LOGIC_VECTOR(TO_UNSIGNED(waddr, ADDR_WIDTH));
            END IF;
          ---------------------------------------------------------------------
          WHEN DATA =>
            IF iRxDV = '1' THEN
              rCnt <= rCnt + 1;
              CASE rCnt IS
                WHEN B"00" => rRxData(31 DOWNTO 24) <= iRxData;
                WHEN B"01" => rRxData(23 DOWNTO 16) <= iRxData;
                WHEN B"10" => rRxData(15 DOWNTO 8)  <= iRxData;
                WHEN B"11" =>
                  rRxData(7 DOWNTO 0) <= iRxData;
                  rWE                 <= '1';
                WHEN OTHERS => NULL;
              END CASE;
            END IF;
            IF iEOF = '1' THEN 
              rRxInfoI(31 DOWNTO 28) <= '0'&iGetArp&iGetIPv4&iGetRaw;
              rRxInfoI(15 DOWNTO 0) <= STD_LOGIC_VECTOR(iPayloadLen);
              rState                <= IDLE;
              IF iErrCheckSum = '1' OR iErrCRC = '1' OR iErrLen = '1' THEN  -- discard wath we just write
                waddr <= rBeginAddr;
              ELSE                      -- no err
                -- rNewFrame             <= '1';
                rInfoFifoWr <= '1';
                IF rCnt /= B"00" THEN   -- last one,length NOT multiple of 4
                  rWE <= '1';
                END IF;
              END IF;
            END IF;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- interrupt generate
    ---------------------------------------------------------------------------
    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        oIntNewFrame  <= '0';
        --rNewFrameD    <= (OTHERS => '0');
        --oRxLenInfo    <= (OTHERS => '0');
        --rInfoFifoRd   <= '0';
        rInfoFifoRdD1 <= '0';
        raddr         <= 0;
      ELSIF rising_edge(iWbClk) THEN
        IF iRxDataRead = '1' THEN
          -- synthesis translate_off
          IF raddr < 2**ADDR_WIDTH-1 THEN
            -- synthesis translate_on
            raddr <= raddr + 1;
          -- synthesis translate_off
          END IF;
        -- synthesis translate_on
        END IF;
        --rNewFrameD    <= rNewFrameD(0)&rNewFrame;
        --rInfoFifoRd   <= '0';
        rInfoFifoRdD1 <= cInfoFifoRd;
        IF rInfoFifoRdD1 = '1' THEN
          raddr <= to_integer(UNSIGNED(cRxInfoO(15+ADDR_WIDTH DOWNTO 16)));
        END IF;
        IF cInfoFifoEmpty = '0' THEN
          -- oIntNewFrame <= '1';
		  oIntNewFrame <= iRxEn;
        END IF;
        IF iIntNewFrameClr = '1' OR cInfoFifoEmpty = '1' THEN
          oIntNewFrame <= '0';
        END IF;
      END IF;
    END PROCESS;
    
  END BLOCK blk0;

  -----------------------------------------------------------------------------
  -- data buffer
  -----------------------------------------------------------------------------
  PROCESS(iEthClk)
  BEGIN
    IF(rising_edge(iEthClk)) THEN
      IF(rWE = '1') THEN
        ram(waddr) <= rRxData;
      END IF;
    END IF;
  END PROCESS;
  PROCESS(iWbClk)
  BEGIN
    IF(rising_edge(iWbClk)) THEN
      oRxData <= ram(raddr);
    END IF;
  END PROCESS;

  -----------------------------------------------------------------------------
  -- infomation fifo
  -----------------------------------------------------------------------------
  oRxLenInfo  <= cRxInfoO;
  cInfoFifoRd <= (iRxInfoRead OR NOT iRxEn) AND NOT cInfoFifoEmpty;
  fifo32x8_1 : ENTITY work.fifo32x8
    PORT MAP (
      data    => rRxInfoI,
      rdclk   => iWbClk,
      rdreq   => cInfoFifoRd,
      wrclk   => iEthClk,
      wrreq   => rInfoFifoWr,
      q       => cRxInfoO,
      rdempty => cInfoFifoEmpty,
      wrfull  => cInfoFifoFull);

END ARCHITECTURE rtl;

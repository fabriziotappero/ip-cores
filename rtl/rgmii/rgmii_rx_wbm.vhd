-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_rx_wbm.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2013-05-07
-- Last update: 2013-05-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-05-07  1.0      liyi    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.de2_pkg.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_rx_wbm IS
  GENERIC (
    IN_SIMULATION : BOOLEAN := FALSE);

  PORT (
    iWbClk  : IN STD_LOGIC;
    iRst_n  : IN STD_LOGIC;

    oWbM2S : OUT wbMasterToSlaveIF_t;
    iWbS2M : IN  wbSlaveToMasterIF_t;

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

    iRegBufBegin : IN STD_LOGIC_VECTOR(31 DOWNTO 2);
    iRegBufEnd   : IN STD_LOGIC_VECTOR(31 DOWNTO 2);

    -- from RX
    iIntNewFrame    : IN     STD_LOGIC;
    oIntNewFrameClr : OUT    STD_LOGIC;
    oRxDataRead     : BUFFER STD_LOGIC;
    iRxData         : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);
    oRxInfoRead     : OUT    STD_LOGIC;
    iRxInfo         : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);

    ---------------------------------------------------------------------------
    -- wishbone slave
    iWbAddr      : IN  STD_LOGIC_VECTOR(8 DOWNTO 2);
    iWbWE        : IN  STD_LOGIC;
    iWbData      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbData      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    iWbRxIntClr  : IN  STD_LOGIC;
    oWbRxIntInfo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    oWbRxInt     : OUT STD_LOGIC;
    iWbRxIntEn   : IN  STD_LOGIC        -- interrupt enable
    );

END ENTITY rgmii_rx_wbm;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_rx_wbm IS

  SIGNAL rStreamFifoWr : STD_LOGIC;
  SIGNAL cStreamFifoRd : STD_LOGIC;
  SIGNAL cStreamFifoDI : STD_LOGIC_VECTOR(33 DOWNTO 0);
  SIGNAL cStreamFifoDO : STD_LOGIC_VECTOR(33 DOWNTO 0);

  -----------------------------------------------------------------------------
  SIGNAL rBurstReq  : BOOLEAN;
  SIGNAL rBurstDone : BOOLEAN;

  -----------------------------------------------------------------------------
  --
  SIGNAL rDescWE   : STD_LOGIC;
  SIGNAL rDescAddr : UNSIGNED(6 DOWNTO 0);
  SIGNAL rDescDO   : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL rDescDI   : STD_LOGIC_VECTOR(31 DOWNTO 0);

  ------------------------------------------------------------------------------
  --
  SIGNAL rStartTran : BOOLEAN;
  SIGNAL rTransDone : BOOLEAN;
  SIGNAL rStartAddr : STD_LOGIC_VECTOR(31 DOWNTO 2);
  SIGNAL rFlush     : BOOLEAN;
  
BEGIN  -- ARCHITECTURE rtl

  -----------------------------------------------------------------------------
  -- FOR receive dma descriptors,32x128
  -----------------------------------------------------------------------------
  blkDescriptor : BLOCK IS
    -- Build a 2-D array type for the RAM
    SUBTYPE word_t IS STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE memory_t IS ARRAY(127 DOWNTO 0) OF word_t;
    -- Declare the RAM 
    SHARED VARIABLE ram : memory_t := (OTHERS => (OTHERS => '0'));
  BEGIN  -- BLOCK blkDescriptor
    -- Port A,wishbone slave
    PROCESS(iWbClk)
    BEGIN
      IF(rising_edge(iWbClk)) THEN
        IF(iWbWE = '1') THEN
          ram(to_integer(UNSIGNED(iWbAddr))) := iWbData;
        END IF;
        oWbData <= ram(to_integer(UNSIGNED(iWbAddr)));
      END IF;
    END PROCESS;
    -- Port B ,internal use
    PROCESS(iWbClk)
    BEGIN
      IF(rising_edge(iWbClk)) THEN
        IF(rDescWE = '1') THEN
          ram(to_integer(rDescAddr)) := rDescDI;
        END IF;
        rDescDO <= ram(to_integer(rDescAddr));
      END IF;
    END PROCESS;
  END BLOCK blkDescriptor;

  fifo_sc_34x64_1 : ENTITY work.fifo_sc_34x64
    PORT MAP (
      clock => iWbClk,
      data  => cStreamFifoDI,
      rdreq => cStreamFifoRd,
      wrreq => rStreamFifoWr,
      empty => OPEN,
      full  => OPEN,
      q     => cStreamFifoDO);

  
  blk2 : BLOCK IS
    TYPE state_t IS (FIRST_TIME, IDLE, WAIT1, FIND_USEABLE1, FLUSH,
                     FIND_USEABLE2, WRITE_ADDR, GET_INFO, TRANS);
    SIGNAL rState     : state_t;
    SIGNAL rBeginAddr : UNSIGNED(6 DOWNTO 0);
    SIGNAL cEmpty     : STD_LOGIC;
    SIGNAL cFull      : STD_LOGIC;
    SIGNAL cIntDesc   : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL rWrReq     : STD_LOGIC;
    SIGNAL cRdReq     : STD_LOGIC;
    SIGNAL rIntDesc   : STD_LOGIC_VECTOR(5 DOWNTO 0);
  BEGIN  -- BLOCK blk2
    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        oWbRxInt <= '0';
      ELSIF rising_edge(iWbClk) THEN
        IF cEmpty = '0' THEN
          oWbRxInt <= iWbRxIntEn;
        END IF;
        IF cEmpty = '1' OR iWbRxIntClr = '1' THEN
          oWbRxInt <= '0';
        END IF;
      END IF;
    END PROCESS;

    oWbRxIntInfo(6 DOWNTO 0) <= cIntDesc&'0';
    cRdReq                   <= iWbRxIntClr AND NOT cEmpty;
    PROCESS (iWbClk) IS
    BEGIN
      IF rising_edge(iWbClk) THEN
        IF iWbRxIntClr = '1' THEN
          oWbRxIntInfo(7) <= cEmpty;
        END IF;
      END IF;
    END PROCESS;
    fifo_sc_6x64_1 : ENTITY work.fifo_sc_6x64
      PORT MAP (
        clock => iWbClk,
        data  => rIntDesc,
        rdreq => cRdReq,
        wrreq => rWrReq,
        empty => cEmpty,
        full  => cFull,
        q     => cIntDesc);

    PROCESS (iWbClk, iRst_n) IS
      VARIABLE vNextStartAddr : UNSIGNED(31 DOWNTO 2);
      VARIABLE vIntDescAddr   : UNSIGNED(5 DOWNTO 0);
    BEGIN
      IF iRst_n = '0' THEN
        rState          <= FIRST_TIME;
        oIntNewFrameClr <= '0';
        oRxInfoRead     <= '0';
        rStartTran      <= FALSE;
        rStartAddr      <= (OTHERS => '0');
        rBeginAddr      <= (OTHERS => '0');
        rDescAddr       <= (OTHERS => '0');
        rDescWE         <= '0';
        rDescDI         <= (OTHERS => '0');
        rIntDesc        <= (OTHERS => '0');
        rWrReq          <= '0';
        rFlush          <= FALSE;
      ELSIF rising_edge(iWbClk) THEN
        rWrReq          <= '0';
        oIntNewFrameClr <= '0';
        oRxInfoRead     <= '0';
        rDescWE         <= '0';
        rStartTran      <= FALSE;
        rFlush          <= FALSE;
        IF rDescWE = '1' THEN
          rDescAddr <= rDescAddr + 1;
        END IF;
        CASE rState IS
          WHEN FIRST_TIME =>
            rStartAddr <= iRegBufBegin;
            IF iIntNewFrame = '1' THEN
              oIntNewFrameClr <= '1';
              oRxInfoRead     <= '1';
              IF cFull = '0' THEN
                IF rDescDO(16) = '0' THEN     -- get a useable descriptor
                  rState <= WAIT1;      -- WAIT FOR info ready
                ELSE
                  rDescAddr <= rDescAddr + 2;
                  rState    <= FIND_USEABLE1;
                END IF;
                rBeginAddr <= (OTHERS => '0');
              ELSE
                rState <= FLUSH;
                rFlush <= TRUE;
              END IF;
            END IF;
          WHEN IDLE=>
            IF iIntNewFrame = '1' THEN
              oIntNewFrameClr <= '1';
              oRxInfoRead     <= '1';
              IF cFull = '0' THEN
                IF rDescDO(16) = '0' THEN     -- get a useable descriptor
                  rState <= WAIT1;
                ELSE
                  rDescAddr <= rDescAddr + 2;
                  rState    <= FIND_USEABLE1;
                END IF;
                rBeginAddr <= rDescAddr;
              ELSE
                rState <= FLUSH;
                rFlush <= TRUE;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN WAIT1 =>
            rState <= GET_INFO;
          WHEN GET_INFO =>
            rState                <= WRITE_ADDR;
            rStartTran            <= TRUE;
            rDescWE               <= '1';
            rDescDI(15 DOWNTO 0)  <= iRxInfo(15 DOWNTO 0);  -- length IN bytes
            rDescDI(16)           <= '1';     --flag
            rDescDI(27 DOWNTO 24) <= iRxInfo(31 DOWNTO 28);   -- frame TYPE
          ---------------------------------------------------------------------
          WHEN FIND_USEABLE1 =>
            rState <= FIND_USEABLE2;
          WHEN FIND_USEABLE2 =>
            IF rDescDO(16) = '0' THEN
              -- find one
              rStartTran            <= TRUE;
              rDescWE               <= '1';
              rDescDI(15 DOWNTO 0)  <= iRxInfo(15 DOWNTO 0);  -- length IN bytes
              rDescDI(16)           <= '1';   --flag
              rDescDI(27 DOWNTO 24) <= iRxInfo(31 DOWNTO 28);  -- frame TYPE
              rState                <= WRITE_ADDR;
            ELSE
              rDescAddr <= rDescAddr + 2;
              IF rDescAddr = rBeginAddr THEN  -- LOOP,still no useable
                -- we just flush the received frame
                rFlush <= TRUE;
                rState <= FLUSH;
              ELSE
                rState <= FIND_USEABLE1;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN WRITE_ADDR =>
            rDescWE <= '1';
            rDescDI <= rStartAddr&B"00";
            rState  <= TRANS;
          ---------------------------------------------------------------------
          WHEN TRANS =>
            IF rTransDone THEN
              vNextStartAddr := UNSIGNED(rStartAddr)+UNSIGNED(iRxInfo(15 DOWNTO 2))+1;
              -- NEXT start addr
              IF vNextStartAddr > UNSIGNED(iRegBufEnd) THEN
                rStartAddr <= iRegBufBegin;
              ELSE
                rStartAddr <= STD_LOGIC_VECTOR(vNextStartAddr);
              END IF;
              rState       <= IDLE;
              rWrReq       <= '1';
              vIntDescAddr := rDescAddr(6 DOWNTO 1) - 1;
              rIntDesc     <= STD_LOGIC_VECTOR(vIntDescAddr);
            END IF;
          ---------------------------------------------------------------------
          WHEN FLUSH =>
            IF rTransDone THEN
              rState <= IDLE;
            END IF;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
  END BLOCK blk2;

  blk1 : BLOCK IS
    SIGNAL rCyc      : STD_LOGIC;
    SIGNAL rPreRead  : STD_LOGIC;
    SIGNAL rReadEn   : STD_LOGIC;
    TYPE state_t IS (IDLE, PRE_READ, WAIT1, START, SINGLE, BURST, LAST_ONE);
    SIGNAL rState    : state_t;
    SIGNAL rWbAddr   : UNSIGNED(31 DOWNTO 2);
    SIGNAL cWbS2MAck : STD_LOGIC;
  BEGIN  -- BLOCK blk1
    oWbM2S.bte  <= LINEAR;
    oWbM2S.dat  <= cStreamFifoDO(31 DOWNTO 0);
    oWbM2S.stb  <= rCyc;
    oWbM2S.cyc  <= rCyc;
    oWbM2S.we   <= '1';
    oWbM2S.sel  <= X"F";
    oWbM2S.addr <= STD_LOGIC_VECTOR(rWbAddr)&B"00";

    -- synthesis translate_off
    oWbM2S_bte  <= LINEAR;
    oWbM2S_dat  <= cStreamFifoDO(31 DOWNTO 0);
    oWbM2S_stb  <= rCyc;
    oWbM2S_cyc  <= rCyc;
    oWbM2S_we   <= '1';
    oWbM2S_sel  <= X"F";
    oWbM2S_addr <= STD_LOGIC_VECTOR(rWbAddr)&B"00";
    -- synthesis translate_on
	
	-- synthesis translate_off
    sim0 : IF IN_SIMULATION GENERATE
      cWbS2MAck <= iWbS2M_ack;
    END GENERATE sim0;
	-- synthesis translate_on
    sim1 : IF NOT IN_SIMULATION GENERATE
      cWbS2MAck <= iWbS2M.ack;
    END GENERATE sim1;

    cStreamFifoRd <= rPreRead OR (rReadEn AND cWbS2MAck);

    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        rWbAddr <= (OTHERS => '0');
      ELSIF rising_edge(iWbClk) THEN
        IF rStartTran THEN
          rWbAddr <= UNSIGNED(rStartAddr);
        END IF;
        IF cWbS2MAck = '1' THEN
          rWbAddr <= rWbAddr + 1;
        END IF;
      END IF;
    END PROCESS;

    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        rCyc       <= '0';
        rPreRead   <= '0';
        rReadEn    <= '0';
        -- synthesis translate_off
        oWbM2S_cti <= CLASSIC;
        -- synthesis translate_on
        oWbM2S.cti <= CLASSIC;
        rState     <= IDLE;
        rBurstDone <= FALSE;
      ELSIF rising_edge(iWbClk) THEN
        rPreRead   <= '0';
        rBurstDone <= FALSE;
        CASE rState IS
          WHEN IDLE =>
            IF rBurstReq THEN
              rPreRead <= '1';
              rState   <= WAIT1;
            END IF;
          ---------------------------------------------------------------------
          WHEN WAIT1 =>
            rState <= START;
          ---------------------------------------------------------------------
          WHEN START =>
            rCyc <= '1';
            IF cStreamFifoDO(32) = '1' THEN                      -- last
              -- synthesis translate_off
              oWbM2S_cti <= CLASSIC;
              -- synthesis translate_on
              oWbM2S.cti <= CLASSIC;
              rState     <= SINGLE;
            ELSE
              -- synthesis translate_off
              oWbM2S_cti <= INCR;
              -- synthesis translate_on
              oWbM2S.cti <= INCR;
              rState     <= BURST;
              rReadEn    <= '1';
            END IF;
          ---------------------------------------------------------------------
          WHEN SINGLE =>
            IF cWbS2MAck = '1' THEN
              rState     <= IDLE;
              rBurstDone <= TRUE;
              rCyc       <= '0';
            END IF;
          ---------------------------------------------------------------------
          WHEN BURST =>
            IF cStreamFifoDO(33) = '1' AND cWbS2MAck = '1' THEN  -- pre last
              -- synthesis translate_off
              oWbM2S_cti <= LAST;
              -- synthesis translate_on
              oWbM2S.cti <= LAST;
              rReadEn    <= '0';
              rState     <= LAST_ONE;
            END IF;
          ---------------------------------------------------------------------
          WHEN LAST_ONE =>
            IF cWbS2MAck = '1' THEN
              rState     <= IDLE;
              rBurstDone <= TRUE;
              rCyc       <= '0';
            END IF;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
  END BLOCK blk1;


  blk0 : BLOCK IS
    TYPE state_t IS (IDLE, REFILL, WAIT_DONE);
    SIGNAL rState    : state_t;
    SIGNAL rCnt      : UNSIGNED(15 DOWNTO 2);
    SIGNAL rCnt64    : INTEGER RANGE 0 TO 63;
    SIGNAL rLast     : STD_LOGIC;
    SIGNAL rPreLast  : STD_LOGIC;
    SIGNAL rNotFlush : STD_LOGIC;
    SIGNAL rFinished : BOOLEAN;
  BEGIN  -- BLOCK blk0
    cStreamFifoDI(32)          <= rLast;
    cStreamFifoDI(33)          <= rPreLast;
    cStreamFifoDI(31 DOWNTO 0) <= iRxData;
    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        oRxDataRead   <= '0';
        rCnt          <= (OTHERS => '0');
        rStreamFifoWr <= '0';
        rTransDone    <= FALSE;
        rBurstReq     <= FALSE;
        rLast         <= '0';
        rPreLast      <= '0';
        rCnt64        <= 0;
        rNotFlush     <= '0';
        rFinished     <= FALSE;
      ELSIF rising_edge(iWbClk) THEN
        IF oRxDataRead = '1' THEN
          rCnt <= rCnt - 1;
          -- synthesis translate_off
          IF rCnt64 > 0 THEN
            -- synthesis translate_on
            rCnt64 <= rCnt64 - 1;
          -- synthesis translate_off
          END IF;
        -- synthesis translate_on
        END IF;
        rStreamFifoWr <= oRxDataRead AND rNotFlush;
        rTransDone    <= FALSE;
        rBurstReq     <= FALSE;
        rLast         <= '0';
        rPreLast      <= '0';
        CASE rState IS
          WHEN IDLE =>
            rFinished <= FALSE;
            IF rStartTran OR rFlush THEN
              oRxDataRead <= '1';
              IF iRxInfo(1 DOWNTO 0) /= B"00" THEN
                rCnt <= UNSIGNED(iRxInfo(15 DOWNTO 2));
              ELSE
                rCnt <= UNSIGNED(iRxInfo(15 DOWNTO 2)) - 1;
              END IF;
              rCnt64 <= 63;
              rState <= REFILL;
            END IF;
            IF rFlush THEN
              rNotFlush <= '0';
            END IF;
            IF rStartTran THEN
              rNotFlush <= '1';
            END IF;
          ---------------------------------------------------------------------
          WHEN REFILL =>
            IF rCnt64 = 0 THEN
              oRxDataRead <= '0';
              rState      <= WAIT_DONE;
              rLast       <= '1';
              rBurstReq   <= To_Boolean(rNotFlush);
            END IF;
            IF rCnt = X"000"&B"00" THEN
              rFinished   <= TRUE;
              oRxDataRead <= '0';
              rState      <= WAIT_DONE;
              rLast       <= '1';
              rBurstReq   <= To_Boolean(rNotFlush);
            END IF;
            IF rCnt = X"000"&B"01" OR rCnt64 = 1 THEN
              rPreLast <= '1';
            END IF;
          ---------------------------------------------------------------------
          WHEN WAIT_DONE =>
            rCnt64 <= 63;
            IF rBurstDone OR rNotFlush = '0' THEN
              IF rFinished THEN
                rTransDone <= TRUE;
                rState     <= IDLE;
              ELSE
                rState      <= REFILL;
                oRxDataRead <= '1';
              END IF;
            END IF;
          WHEN OTHERS => NULL;
        END CASE;
      -------------------------------------------------------------------------
      END IF;
    END PROCESS;
  END BLOCK blk0;

END ARCHITECTURE rtl;

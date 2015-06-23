-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_tx_wbm.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2013-05-09
-- Last update: 2013-05-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-05-09  1.0      liyi    Created
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.de2_pkg.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_tx_wbm IS
  GENERIC (
    IN_SIMULATION : BOOLEAN := FALSE);
  PORT (
    iWbClk : IN STD_LOGIC;
    iRst_n : IN STD_LOGIC;

    oWbM2S : OUT wbMasterToSlaveIF_t;
    iWbS2M : IN  wbSlaveToMasterIF_t;

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

    -- tx buf
    iTxDone     : IN  STD_LOGIC;        -- act as an interrupt SIGNAL(if used)
    oTxDoneClr  : OUT STD_LOGIC;
    iTxDoneInfo : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    oTxData     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oTxAddr     : OUT UNSIGNED(10 DOWNTO 0);
    oTxDataWr   : OUT STD_LOGIC;
    oTxInfo     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oTxInfoWr   : BUFFER STD_LOGIC;

    --wb
    iWbTxEnable  : IN  STD_LOGIC;
    oWbTxInt     : OUT STD_LOGIC;
    iWbTxIntClr  : IN  STD_LOGIC;
    iWbTxIntEn   : IN  STD_LOGIC;
    iWbTxAddr    : IN  STD_LOGIC_VECTOR(8 DOWNTO 2);
    iWbTxWE      : IN  STD_LOGIC;
    iWbTxData    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbTxData    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    oWbTxIntInfo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    iCheckSumIPGen   : IN STD_LOGIC;
    iCheckSumTCPGen  : IN STD_LOGIC;
    iCheckSumUDPGen  : IN STD_LOGIC;
    iCheckSumICMPGen : IN STD_LOGIC
    );

END ENTITY rgmii_tx_wbm;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_tx_wbm IS

  SIGNAL rDescWE   : STD_LOGIC;
  SIGNAL rDescAddr : UNSIGNED(6 DOWNTO 0);
  SIGNAL cDescDI   : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL rDescDO   : STD_LOGIC_VECTOR(31 DOWNTO 0);

  -- the length OF current frame descriptor
  SIGNAL rFrameLen     : UNSIGNED(15 DOWNTO 0):=(OTHERS => '0');
  SIGNAL rDescriptorLen : STD_LOGIC_VECTOR(15 DOWNTO 0);-- 当前descriptor的长度
  SIGNAL rStartTran    : BOOLEAN;
  SIGNAL rTransDone    : BOOLEAN;
  SIGNAL rCheckSumDone : BOOLEAN;

  SIGNAL cWbAck   : STD_LOGIC;
  SIGNAL rWbAck : STD_LOGIC;
  SIGNAL rLastOne : BOOLEAN;
  SIGNAL cWbData : STD_LOGIC_VECTOR(31 DOWNTO 0);
  
  -- 当前descriptor里面，从wishbone总线读取的32bit宽度数据中，
  -- 第一个和最后一个，有效字节数各为多少(大端模式)
  SIGNAL rFirstNibbleBytes : NATURAL RANGE 1 TO 4;
  SIGNAL rLastNibbleBytes  : NATURAL RANGE 1 TO 4;
  -- 一个以太网帧可能占用多个descriptor，例如帧的头和载荷在不同的物理区域，
  -- 那么下面一个信号表示这是当前帧的最后一个descriptor
  SIGNAL rLastDescriptor   : STD_LOGIC;

  -- the data read from outer buf to be send
  SIGNAL rDMADat  : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL rDMADatV : STD_LOGIC;

  -- 当前帧的最后一个wishbone读取
  SIGNAL rRellyLastOne  : BOOLEAN;
BEGIN  -- ARCHITECTURE rtl
    
  -- synthesis translate_off
  gen0 : IF IN_SIMULATION GENERATE
    cWbAck <= iWbS2M_ack;
    cWbData <= iWbS2M_dat;
  END GENERATE gen0;
  -- synthesis translate_on
  gen1 : IF NOT IN_SIMULATION GENERATE
    cWbAck <= iWbS2M.ack;
    cWbData <= iWbS2M.dat;
  END GENERATE gen1;

  PROCESS (iWbClk) IS
  BEGIN
    IF rising_edge(iWbClk) THEN
      rWbAck <= cWbAck;
    END IF;
  END PROCESS;
  
  csGen : BLOCK IS
    SIGNAL rTxAddr : UNSIGNED(10 DOWNTO 0);
    TYPE state_t IS (IDLE, TYPE_LEN, TAGED, STACK_TAG,IP4_PAYLOAD,
                     --ICMP, TCP, UDP,
                     IP4_HEAD, WAIT_FINISH, CS1, CS2, DONE, DONE2);
    SIGNAL rState        : state_t;
    SIGNAL rAddrRecord   : UNSIGNED(10 DOWNTO 0);
    SIGNAL rCheckSum     : UNSIGNED(31 DOWNTO 0);
    SIGNAL cCheckSum     : UNSIGNED(15 DOWNTO 0);
    SIGNAL rCheckSum2    : UNSIGNED(31 DOWNTO 0);
    SIGNAL cCheckSum2    : UNSIGNED(15 DOWNTO 0);
    SIGNAL rWordCnt      : UNSIGNED(13 DOWNTO 0):=(OTHERS => '0');
    SIGNAL rIPHeadLen    : UNSIGNED(3 DOWNTO 0);  -- IN 32bit
    SIGNAL rIPTotalLen   : UNSIGNED(15 DOWNTO 0);
    SIGNAL rProtocol     : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cIPPayloadLen : UNSIGNED(15 DOWNTO 0);
    SIGNAL rCS1Addr      : UNSIGNED(10 DOWNTO 0);
    SIGNAL rCS2Addr      : UNSIGNED(10 DOWNTO 0);
    SIGNAL rCS1DatBak    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rCS2DatBak    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL rDMADatVD1 : STD_LOGIC;
  BEGIN  -- BLOCK csGen
    cIPPayloadLen <= rIPTotalLen - to_integer(rIPHeadLen&B"00");
    cCheckSum     <= NOT (rCheckSum(31 DOWNTO 16)+rCheckSum(15 DOWNTO 0));
    cCheckSum2    <= NOT (rCheckSum2(31 DOWNTO 16)+rCheckSum2(15 DOWNTO 0));
    oTxAddr       <= rTxAddr;           -- BUFFER address

    PROCESS (iWbClk) IS 
    BEGIN 
      IF rising_edge(iWbClk) THEN
        rDMADatVD1 <= rDMADatV;
      END IF;
    END PROCESS;
    
    PROCESS (iWbClk, iRst_n) IS
      -- VARIABLE vTemp17 : UNSIGNED(16 DOWNTO 0);
      VARIABLE vTemp17 : NATURAL RANGE 0 TO 131071;
    BEGIN
      IF iRst_n = '0' THEN
        rTxAddr       <= (OTHERS => '0');
        rAddrRecord   <= (OTHERS => '0');
        rState        <= IDLE;
        rWordCnt      <= (OTHERS => '0');
        rCheckSumDone <= FALSE;
        rIPHeadLen    <= (OTHERS => '0');
        rIPTotalLen   <= (OTHERS => '0');
        rProtocol     <= (OTHERS => '0');
        rCheckSum2    <= (OTHERS => '0');
        rCS1Addr      <= (OTHERS => '0');
        rCS2Addr      <= (OTHERS => '0');
        rCS1DatBak    <= (OTHERS => '0');
        rCS2DatBak    <= (OTHERS => '0');
      ELSIF rising_edge(iWbClk) THEN
        rCheckSumDone <= FALSE;
        oTxDataWr     <= rDMADatV;
        oTxData       <= rDMADat;
        IF rDMADatVD1 = '1' THEN
          rTxAddr <= rTxAddr + 1;
        END IF;
        IF rDMADatV = '1' THEN
          rWordCnt <= rWordCnt + 1;
        END IF;
        IF rRellyLastOne THEN 
          rAddrRecord <= rTxAddr + 2;
          rWordCnt <= (OTHERS => '0');
        END IF;
        --IF rRellyLastOne THEN
        --  rCheckSumDone <= TRUE;
        --END IF;
        CASE rState IS
          WHEN IDLE =>
            --rWordCnt   <= (OTHERS => '0');
            rCheckSum  <= (OTHERS => '0');
            rCheckSum2 <= (OTHERS => '0');
            --IF rStartTran THEN
            --  rState <= MAC;
            --END IF;
            IF rWordCnt(1 DOWNTO 0) = B"10" AND rDMADatV = '1' THEN
              rState <= TYPE_LEN;
            END IF;
          ---------------------------------------------------------------------
          --WHEN MAC =>
          --  IF rWordCnt(1 DOWNTO 0) = B"10" AND rDMADatV = '1' THEN
          --    rState <= TYPE_LEN;
          --  END IF;
          --  IF rRellyLastOne THEN          -- this should nerver happen
          --    rCheckSumDone <= TRUE;
          --    rState        <= IDLE;
          --  END IF;
          ---------------------------------------------------------------------
          WHEN TYPE_LEN =>
            IF rDMADatV = '1' THEN
              rState <= DONE;
              CASE rDMADat(31 DOWNTO 16) IS 
                WHEN X"0800" =>         -- IPv4
                  rCheckSum            <= rCheckSum + UNSIGNED(rDMADat(15 DOWNTO 0));
                  rIPHeadLen           <= UNSIGNED(rDMADat(11 DOWNTO 8));
                  rWordCnt(3 DOWNTO 0) <= X"1";
                  rState               <= IP4_HEAD;
                WHEN X"8100" =>         -- taged,4 bytes
                  rState <= TAGED;
                WHEN X"88A8" | X"9100" =>      -- stack taged,8 bytes
                  rState <= STACK_TAG;
                WHEN OTHERS => NULL;
              END CASE;
            END IF;
            IF rRellyLastOne THEN          -- this should nerver happen
              rCheckSumDone <= TRUE;
              rState        <= IDLE;
            END IF;
          ---------------------------------------------------------------------
          WHEN TAGED =>
            IF rDMADatV = '1' THEN
              IF rDMADat(31 DOWNTO 16) = X"0800" THEN
                rCheckSum            <= rCheckSum + UNSIGNED(rDMADat(15 DOWNTO 0));
                rIPHeadLen           <= UNSIGNED(rDMADat(11 DOWNTO 8));
                rWordCnt(3 DOWNTO 0) <= X"1";
                rState               <= IP4_HEAD;
              ELSE
                rState <= DONE;
              END IF;
            END IF;
            IF rRellyLastOne THEN          -- this should nerver happen
              rCheckSumDone <= TRUE;
              rState        <= IDLE;
            END IF;
          ---------------------------------------------------------------------
          WHEN STACK_TAG =>
            IF rDMADatV = '1' THEN
              rState <= TAGED;
            END IF;
            IF rRellyLastOne THEN          -- this should nerver happen
              rCheckSumDone <= TRUE;
              rState        <= IDLE;
            END IF;
          ---------------------------------------------------------------------
          WHEN IP4_HEAD =>
            -- rCheckSum2 here used FOR pesudo head sum
            IF rDMADatV = '1' THEN
              CASE rWordCnt(3 DOWNTO 0) IS 
                -- 16位的总长度+16位的标识
                WHEN X"1" =>            -- byte 3,4,5,6
                  rIPTotalLen <= UNSIGNED(rDMADat(31 DOWNTO 16));
                  vTemp17     := to_integer(UNSIGNED(rDMADat(31 DOWNTO 16)))+
                                 to_integer(UNSIGNED(rDMADat(15 DOWNTO 0)));
                  rCheckSum <= rCheckSum + vTemp17;
                -- 3bit标志+13bit片偏移量  + 8bit TTL + 8 bit Protocol
                WHEN X"2" =>            -- byte 7,8,9,10
                  vTemp17 := to_integer(UNSIGNED(rDMADat(31 DOWNTO 16)))+
                             to_integer(UNSIGNED(rDMADat(15 DOWNTO 0)));
                  rCheckSum  <= rCheckSum + vTemp17;
                  rCheckSum2 <= X"0000"&cIPPayloadLen +
                                to_integer((UNSIGNED(rDMADat(7 DOWNTO 0))));
                  rProtocol <= rDMADat(7 DOWNTO 0);
                -- 16bit 校验和+源IP地址的高16bit
                WHEN X"3" =>            -- byte 11,12,13,14
                  -- checksum assumed TO be zero
                  -- add the higher two bytes OF Source IP Address
                  rCheckSum  <= rCheckSum + UNSIGNED(rDMADat(15 DOWNTO 0));
                  rCheckSum2 <= rCheckSum2 + UNSIGNED(rDMADat(15 DOWNTO 0));
                  rCS1DatBak <= rDMADat(15 DOWNTO 0);
                  -- 记录下相对地址，一会儿checksum计算完成后要写入
                  IF rDMADatVD1 = '1' THEN
                    rCS1Addr <= rTxAddr + 1;
                  ELSE
                    rCS1Addr <= rTxAddr;
                  END IF;
                -- 源IP地址低16bit + 目的IP地址高16bit
                WHEN X"4" =>            -- byte 15,16,17,18
                  vTemp17 := to_integer(UNSIGNED(rDMADat(31 DOWNTO 16)))+
                             to_integer(UNSIGNED(rDMADat(15 DOWNTO 0)));
                  rCheckSum  <= rCheckSum + vTemp17;
                  rCheckSum2 <= rCheckSum2 + vTemp17;
                -- 目的IP地址低16bit + 选项(或数据) 16bit
                WHEN X"5" =>
                  -- rCheckSum2 表示的伪头在这里就计算结束了
                  rCheckSum2 <= rCheckSum2 + UNSIGNED(rDMADat(31 DOWNTO 16));
                  -- 但是对于IP头的校验和，还要继续计算选项部分
                  vTemp17 := to_integer(UNSIGNED(rDMADat(31 DOWNTO 16)))+
                             to_integer(UNSIGNED(rDMADat(15 DOWNTO 0)));
                  rCheckSum  <= rCheckSum + vTemp17;
                WHEN OTHERS =>
                  vTemp17 := to_integer(UNSIGNED(rDMADat(31 DOWNTO 16)))+
                             to_integer(UNSIGNED(rDMADat(15 DOWNTO 0)));
                  rCheckSum  <= rCheckSum + vTemp17;
              END CASE;
              
              IF rIPHeadLen = rWordCnt(3 DOWNTO 0) THEN  -- ip head finished
                rCheckSum <= rCheckSum + UNSIGNED(rDMADat(31 DOWNTO 16));
                rWordCnt  <= (OTHERS => '0');
                rState    <= WAIT_FINISH;
                IF cIPPayloadLen /= X"0000" THEN 
                  CASE rProtocol IS
                    WHEN X"01" =>       -- icmp
                      rCheckSum2 <= X"0000"&UNSIGNED(rDMADat(15 DOWNTO 0));
                      rState <= IP4_PAYLOAD;
                    WHEN X"06" | X"11" =>       -- tcp
                      IF rIPHeadLen = X"5" THEN  -- 没有IP头选项部分
                        vTemp17 := to_integer(UNSIGNED(rDMADat(31 DOWNTO 16)))+
                                   to_integer(UNSIGNED(rDMADat(15 DOWNTO 0)));
                        rCheckSum2 <= rCheckSum2 + vTemp17;
                      ELSE
                        rCheckSum2 <= rCheckSum2 + UNSIGNED(rDMADat(15 DOWNTO 0));
                      END IF;
                      rState <= IP4_PAYLOAD;
                    WHEN OTHERS => NULL;
                  END CASE;
                END IF;
              END IF;
              
            END IF;
            IF rRellyLastOne THEN          -- this should nerver happen
              rCheckSumDone <= TRUE;
              rState        <= IDLE;
            END IF;
          ---------------------------------------------------------------------
          WHEN IP4_PAYLOAD =>
            IF rDMADatV = '1' THEN 
              -- 最后一个32位数据，但是，4字节不都是有效的，但是已经保证其它的无效
              -- 的数据为0了，因此，跟平常一样加起来也无所谓
              vTemp17 := to_integer(UNSIGNED(rDMADat(31 DOWNTO 16)))+
                         to_integer(UNSIGNED(rDMADat(15 DOWNTO 0)));
              rCheckSum2 <= rCheckSum2 + vTemp17;
              CASE rProtocol IS
                WHEN X"01" =>           -- icmp
                  IF rWordCnt = X"000"&B"00" THEN 
                    rCS2DatBak <= rDMADat(15 DOWNTO 0);
                    rCheckSum2 <= rCheckSum2 + UNSIGNED(rDMADat(15 DOWNTO 0));
                    IF rDMADatVD1 = '1' THEN
                      rCS2Addr <= rTxAddr + 1;
                    ELSE
                      rCS2Addr <= rTxAddr;
                    END IF;
                  END IF;
                ---------------------------------------------------------------
                WHEN X"06" =>           -- tcp
                  IF rWordCnt = X"000"&B"11" THEN 
                    rCS2DatBak <= rDMADat(31 DOWNTO 16);
                    rCheckSum2 <= rCheckSum2 + UNSIGNED(rDMADat(31 DOWNTO 16));
                    IF rDMADatVD1 = '1' THEN
                      rCS2Addr <= rTxAddr + 1;
                    ELSE
                      rCS2Addr <= rTxAddr;
                    END IF;
                  END IF;
                ---------------------------------------------------------------
                WHEN X"11" =>           -- udp
                  IF rWordCnt = X"000"&B"01" THEN 
                    rCS2DatBak <= rDMADat(15 DOWNTO 0);
                    rCheckSum2 <= rCheckSum2 + UNSIGNED(rDMADat(15 DOWNTO 0));
                    IF rDMADatVD1 = '1' THEN
                      rCS2Addr <= rTxAddr + 1;
                    ELSE
                      rCS2Addr <= rTxAddr;
                    END IF;
                  END IF;
                WHEN OTHERS => NULL;
              END CASE;              
            END IF;
            
            IF rRellyLastOne THEN 
              rState <= CS2;
            END IF;
          ---------------------------------------------------------------------
          WHEN WAIT_FINISH =>
            IF rRellyLastOne THEN 
              rState <= CS1;
            END IF;
          ---------------------------------------------------------------------
          WHEN CS1 =>                   -- ip checksum
            rTxAddr   <= rCS1Addr;
            oTxData   <= STD_LOGIC_VECTOR(cCheckSum)&rCS1DatBak;
            oTxDataWr <= '1';
            rState    <= DONE2;
          ---------------------------------------------------------------------
          WHEN CS2 =>                   -- tcp udp icmp checksum
            IF rProtocol = X"06" THEN   -- tcp
              oTxData <= rCS2DatBak&STD_LOGIC_VECTOR(cCheckSum2);
            ELSE
              oTxData <= STD_LOGIC_VECTOR(cCheckSum2)&rCS2DatBak;
            END IF;
            rTxAddr     <= rCS2Addr;
            oTxDataWr   <= '1';
            rState <= CS1;
          ---------------------------------------------------------------------
          -- 不是ipv4的帧
          WHEN DONE =>
            IF rRellyLastOne THEN
              rCheckSumDone <= TRUE;
              rState <= IDLE;
            END IF;
          ---------------------------------------------------------------------
          WHEN DONE2 =>
            oTxDataWr     <= '0';
            rState        <= IDLE;
            rCheckSumDone <= TRUE;
            rTxAddr       <= rAddrRecord;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
  END BLOCK csGen;


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
        IF(iWbTxWE = '1') THEN
          ram(to_integer(UNSIGNED(iWbTxAddr))) := iWbTxData;
        END IF;
        oWbTxData <= ram(to_integer(UNSIGNED(iWbTxAddr)));
      END IF;
    END PROCESS;
    -- Port B ,internal use
    PROCESS(iWbClk)
    BEGIN
      IF(rising_edge(iWbClk)) THEN
        IF(rDescWE = '1') THEN
          ram(to_integer(rDescAddr)) := cDescDI;
        END IF;
        rDescDO <= ram(to_integer(rDescAddr));
      END IF;
    END PROCESS;
  END BLOCK blkDescriptor;

  -----------------------------------------------------------------------------
  -- un-unsed
  PROCESS (iWbClk, iRst_n) IS
  BEGIN
    IF iRst_n = '0' THEN
      oTxDoneClr <= '0';
    ELSIF rising_edge(iWbClk) THEN
      oTxDoneClr <= '0';
      IF iTxDone = '1' THEN
        oTxDoneClr <= '1';
      END IF;
    END IF;
  END PROCESS;

  blk0 : BLOCK IS
    TYPE state_t IS (IDLE, FIND_USEABLE1, WAIT2, TRANS);
    SIGNAL rState   : state_t;
    SIGNAL cEmpty   : STD_LOGIC;
    SIGNAL cFull    : STD_LOGIC;
    SIGNAL cIntDesc : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL rWrReq   : STD_LOGIC;
    SIGNAL cRdReq   : STD_LOGIC;
    SIGNAL rIntDesc : STD_LOGIC_VECTOR(5 DOWNTO 0);
  BEGIN  -- BLOCK blk0
    cDescDI              <= (OTHERS => '0');
    oTxInfo(31)          <= '0';
    oTxInfo(15 DOWNTO 0) <= STD_LOGIC_VECTOR(rFrameLen);

    oWbTxIntInfo(6 DOWNTO 0) <= cIntDesc&'0';
    cRdReq                   <= iWbTxIntClr AND NOT cEmpty;
    PROCESS (iWbClk) IS
    BEGIN
      IF rising_edge(iWbClk) THEN
        IF iWbTxIntClr = '1' THEN
          oWbTxIntInfo(7) <= cEmpty;
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
    BEGIN
      IF iRst_n = '0' THEN
        oWbTxInt <= '0';
      ELSIF rising_edge(iWbClk) THEN
        IF cEmpty = '0' THEN
          oWbTxInt <= iWbTxIntEn;
        END IF;
        IF cEmpty = '1' OR iWbTxIntClr = '1' THEN
          oWbTxInt <= '0';
        END IF;
      END IF;
    END PROCESS;

    PROCESS (iWbClk) IS
    BEGIN
      IF rising_edge(iWbClk) THEN
        rWrReq <= '0';
        IF rTransDone THEN
        --IF rCheckSumDone THEN
          rWrReq   <= iWbTxIntEn;
          rIntDesc <= STD_LOGIC_VECTOR(rDescAddr(6 DOWNTO 1));
        END IF;
      END IF;
    END PROCESS;

    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        rState                <= IDLE;
        rDescAddr             <= (OTHERS => '0');
        rDescWE               <= '0';
        rFrameLen             <= (OTHERS => '0');
        rStartTran            <= FALSE;
        oTxInfo(30 DOWNTO 16) <= (OTHERS => '0');
        oTxInfoWr             <= '0';
        rLastDescriptor       <= '0';
        rDescriptorLen <= (OTHERS => '0');
      ELSIF rising_edge(iWbClk) THEN
        rDescWE    <= '0';
        rStartTran <= FALSE;
        oTxInfoWr  <= '0';
        IF oTxInfoWr = '1' THEN
          rFrameLen <= (OTHERS => '0');
        END IF;
        CASE rState IS
          WHEN IDLE =>
            IF cFull = '0' AND iWbTxEnable = '1' AND
              -- NOT too much frames pending...
              iTxDoneInfo(31) = '0' THEN
              IF rDescDO(16) = '1' AND rDescDO(15 DOWNTO 0) /= X"0000" THEN  -- ready to be send
                -- 当前帧的最后一个descriptor了
                rLastDescriptor <= rDescDO(17);
                -- and theres is plenty room for this frame
                IF rDescDO(15 DOWNTO 0) < iTxDoneInfo(15 DOWNTO 0) THEN
                  -- then start sending...
                  rFrameLen             <= UNSIGNED(rDescDO(15 DOWNTO 0))+rFrameLen;
                  rDescriptorLen        <= rDescDO(15 DOWNTO 0);
                  rState                <= WAIT2;
                  -- start addr in the tx buf
                  oTxInfo(30 DOWNTO 16) <= iTxDoneInfo(30 DOWNTO 16);
                  --this will give us the location of the current frame
                  rDescAddr             <= rDescAddr + 1;
                END IF;
              ELSE                      -- find NEXT one
                rDescAddr <= rDescAddr + 2;
                rState    <= FIND_USEABLE1;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN FIND_USEABLE1 =>
            rState <= IDLE;
          ---------------------------------------------------------------------
          --WHEN WAIT1 =>
          --  rState    <= WAIT2;
          WHEN WAIT2 =>
            rStartTran <= TRUE;
            rState     <= TRANS;
            rDescAddr  <= rDescAddr - 1;
            rDescWE    <= '1';
          WHEN TRANS =>
            -- 如果当前descriptor已经读入完成，并且不是最后一个，那么就不等待
            -- checksum计算完成，直接进入下一个descriptor的查找
            IF rTransDone AND rLastDescriptor = '0' THEN
              rState <= IDLE;
            ELSIF rCheckSumDone THEN
              rState    <= IDLE;
              -- this will info the tx_buf module a valid frame has been
              -- successfully writen into the buf,and ready to be send out
              oTxInfoWr <= '1';
            -- IF we clear now AND jump TO IDLE,the flag IS NOT fully cleared
            -- rDescWE   <= '1';move TO the previous state !!!BUG
            END IF;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
  END BLOCK blk0;

  blk1 : BLOCK IS
    SIGNAL rCnt    : UNSIGNED(15 DOWNTO 2);
    SIGNAL rCnt64  : UNSIGNED(5 DOWNTO 0);
    TYPE state_t IS (IDLE, REFILL, WAIT1, WASTE);
    SIGNAL rState  : state_t;
    SIGNAL rCycStb : STD_LOGIC;
    SIGNAL rWbAddr : UNSIGNED(31 DOWNTO 2);
    SIGNAL rWbCti  : STD_LOGIC_VECTOR(2 DOWNTO 0);
  BEGIN  -- BLOCK blk1
    oWbM2S.bte  <= LINEAR;
    oWbM2S.cyc  <= rCycStb;
    oWbM2S.stb  <= rCycStb;
    oWbM2S.we   <= '0';
    oWbM2S.addr <= STD_LOGIC_VECTOR(rWbAddr)&B"00";
    oWbM2S.sel  <= X"F";
    oWbM2S.cti  <= rWbCti;
    -- synthesis translate_off
    oWbM2S_bte  <= LINEAR;
    oWbM2S_cyc  <= rCycStb;
    oWbM2S_stb  <= rCycStb;
    oWbM2S_we   <= '0';
    oWbM2S_addr <= STD_LOGIC_VECTOR(rWbAddr)&B"00";
    oWbM2S_sel  <= X"F";
    oWbM2S_cti  <= rWbCti;
    -- synthesis translate_on

    PROCESS (iWbClk, iRst_n) IS
      VARIABLE vCnt    : UNSIGNED(15 DOWNTO 2);
      VARIABLE vTemp16 : UNSIGNED(15 DOWNTO 0);
    BEGIN
      IF iRst_n = '0' THEN
        rTransDone        <= FALSE;
        rCnt64            <= (OTHERS => '0');
        rCnt              <= (OTHERS => '0');
        rState            <= IDLE;
        rCycStb           <= '0';
        rWbCti            <= CLASSIC;
        rWbAddr           <= (OTHERS => '0');
        rLastOne          <= FALSE;
        rFirstNibbleBytes <= 1;
        rLastNibbleBytes  <= 1;
      ELSIF rising_edge(iWbClk) THEN
        rTransDone <= FALSE;
        IF cWbAck = '1' THEN
          rWbAddr <= rWbAddr + 1;
          rCnt    <= rCnt - 1;
          rCnt64  <= rCnt64 - 1;
        END IF;
        CASE rState IS
          WHEN IDLE =>
            rWbAddr  <= UNSIGNED(rDescDO(31 DOWNTO 2));
            
            -- 注意，这里rFirstNibbleBytes直接记录的首次有多少
            -- 有效字节数，在大端模式下，rDescDO(1 DOWNTO 0)=B"00"表示
            -- 4字节有效，rDescDO(1 DOWNTO 0)=B"10"表示高16bit有效
            rFirstNibbleBytes <= 4 - to_integer(UNSIGNED(rDescDO(1 DOWNTO 0)));

            -- descriptors 给出的目标数据的起始地址很可能不是4字节对齐的
            vTemp16 := UNSIGNED(rDescriptorLen) - 4 + to_integer(UNSIGNED(rDescDO(1 DOWNTO 0)));
            IF vTemp16(1 DOWNTO 0) /= B"00" THEN
              vCnt             := vTemp16(15 DOWNTO 2)+1;
              -- rLastNibbleBytes给出的是当前descriptor最后一次32位读取中，有效的
              -- 字节数
              rLastNibbleBytes <= to_integer(vTemp16(1 DOWNTO 0));
            ELSE
              vCnt             := vTemp16(15 DOWNTO 2);
              rLastNibbleBytes <= 4;
            END IF;
            --IF rFrameLen(1 DOWNTO 0) /= B"00" THEN
            --  vCnt := UNSIGNED(rFrameLen(15 DOWNTO 2));
            --ELSE
            --  vCnt := UNSIGNED(rFrameLen(15 DOWNTO 2)) - 1;
            --END IF;
            rCnt   <= vCnt;
            rCnt64 <= (OTHERS => '1');
            IF rStartTran THEN 
              rLastOne <= FALSE;          -- last in a frame
              IF vCnt = 0 THEN
                rState   <= WAIT1;
                rWbCti   <= CLASSIC;
                rLastOne <= TRUE;
              ELSE
                rState <= REFILL;
                rWbCti <= INCR;
              END IF;
              rCycStb <= '1';
            END IF;
          ---------------------------------------------------------------------
          WHEN REFILL =>
            IF cWbAck = '1' THEN
              IF rCnt = X"000"&B"01" THEN
                rWbCti   <= LAST;
                rState   <= WAIT1;
                rLastOne <= TRUE;
              ELSIF rCnt64 = 1 THEN
                rWbCti <= LAST;
                rState <= WASTE;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN WAIT1 =>
            IF cWbAck = '1' THEN
              rState     <= IDLE;
              rCycStb    <= '0';
              rTransDone <= TRUE;
            END IF;
          ---------------------------------------------------------------------
          WHEN WASTE =>
            rCnt64 <= rCnt64 + 1;
            IF rCnt64 = 16 THEN
              rCycStb <= '1';
              IF rCnt = 0 THEN
                rState   <= WAIT1;
                rWbCti   <= CLASSIC;
                rLastOne <= TRUE;
              ELSE
                rState <= REFILL;
                rWbCti <= INCR;
              END IF;
            END IF;
            IF cWbAck = '1' THEN
              rCycStb <= '0';
            END IF;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
  END BLOCK blk1;

  blkDataMix : BLOCK IS
    TYPE state_t IS (ST1, ST2);
    SIGNAL rState         : state_t;
    
    -- 当前wishbone读取的，有效字节数
    SIGNAL rValidBytes    : NATURAL RANGE 1 TO 4;
    TYPE array8x8_t IS ARRAY (8 DOWNTO 1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rArray8x8_2      : array8x8_t;
    SIGNAL rArray8x8_1      : array8x8_t;  -- 实际上只使用了4 DOWNTO 1
    SIGNAL rReveivedBytes : NATURAL RANGE 0 TO 8;
    SIGNAL rStateLittle   : BOOLEAN;
    SIGNAL rLastOneD1 : BOOLEAN;
  BEGIN  -- BLOCK blkDataMix

    PROCESS (iWbClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        rState <= ST1;
      ELSIF rising_edge(iWbClk) THEN
        CASE rState IS
          -- 这是每一个descriptor的第一个读取的32位数，当然，不一定全部有效
          -- rFirstNibbleBytes 会告诉我们到底有几个字节有效
          WHEN ST1 =>
            IF cWbAck = '1' THEN
              rValidBytes <= rFirstNibbleBytes;
              rArray8x8_1(1) <= cWbData(7 DOWNTO 0);
              rArray8x8_1(2) <= cWbData(15 DOWNTO 8);
              rArray8x8_1(3) <= cWbData(23 DOWNTO 16);
              rArray8x8_1(4) <= cWbData(31 DOWNTO 24);
              -- 当前descriptor只需要读一次
              IF rLastOne THEN          -- 在大端下，
                NULL;
                --rArray8x8_1(1) <= cWbData(7 DOWNTO 0);
                --rArray8x8_1(2) <= cWbData(15 DOWNTO 8);
                --rArray8x8_1(3) <= cWbData(23 DOWNTO 16);
                --rArray8x8_1(4) <= cWbData(31 DOWNTO 24);
              ELSE
                rState <= ST2;
                --rArray8x8_1(1) <= cWbData(7 DOWNTO 0);
                --rArray8x8_1(2) <= cWbData(15 DOWNTO 8);
                --rArray8x8_1(3) <= cWbData(23 DOWNTO 16);
                --rArray8x8_1(4) <= cWbData(31 DOWNTO 24);
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN ST2 =>
            IF cWbAck = '1' THEN
              IF rLastOne THEN
                rValidBytes <= rLastNibbleBytes;
                rState      <= ST1;
                -- 大端下，残留的最后一个是靠齐。。。
                CASE rLastNibbleBytes IS
                  WHEN 1 =>
                    rArray8x8_1(1) <= cWbData(31 DOWNTO 24);
                  WHEN 2 =>
                    rArray8x8_1(2) <= cWbData(31 DOWNTO 24);
                    rArray8x8_1(1) <= cWbData(23 DOWNTO 16);
                  WHEN 3 =>
                    rArray8x8_1(3) <= cWbData(31 DOWNTO 24);
                    rArray8x8_1(2) <= cWbData(23 DOWNTO 16);
                    rArray8x8_1(1) <= cWbData(15 DOWNTO 8);
                  WHEN 4 =>
                    rArray8x8_1(4) <= cWbData(31 DOWNTO 24);
                    rArray8x8_1(3) <= cWbData(23 DOWNTO 16);
                    rArray8x8_1(2) <= cWbData(15 DOWNTO 8);
                    rArray8x8_1(1) <= cWbData(7 DOWNTO 0);
                  WHEN OTHERS => NULL;
                END CASE;
              ELSE
                rValidBytes <= 4;
                rArray8x8_1(1) <= cWbData(7 DOWNTO 0);
                rArray8x8_1(2) <= cWbData(15 DOWNTO 8);
                rArray8x8_1(3) <= cWbData(23 DOWNTO 16);
                rArray8x8_1(4) <= cWbData(31 DOWNTO 24);
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;

    PROCESS (iWbClk) IS 
    BEGIN 
      IF rising_edge(iWbClk) THEN
        rLastOneD1 <= rLastOne;
      END IF;
    END PROCESS;
    
    PROCESS (iWbClk, iRst_n) IS
      VARIABLE vReceivedBytes : NATURAL RANGE 1 TO 8;
      VARIABLE vArray8x8 : array8x8_t;
    BEGIN
      IF iRst_n = '0' THEN
        rDMADatV       <= '0';
        rDMADat        <= (OTHERS => '0');
        rReveivedBytes <= 0;
        rRellyLastOne  <= FALSE;
        rStateLittle   <= FALSE;
      ELSIF rising_edge(iWbClk) THEN
        rDMADatV      <= '0';
        rRellyLastOne <= FALSE;
        CASE rStateLittle IS
          WHEN FALSE =>
            IF rWbAck = '1' THEN 
              vArray8x8(rValidBytes DOWNTO 1) := rArray8x8_1(rValidBytes DOWNTO 1);
              vArray8x8(8 DOWNTO rValidBytes+1) := rArray8x8_2(8-rValidBytes DOWNTO 1);
              --rArray8x8_2(rValidBytes DOWNTO 1) <= rArray8x8_1(rValidBytes DOWNTO 1);
              --rArray8x8_2(8 DOWNTO rValidBytes+1) <= rArray8x8_2(8-rValidBytes DOWNTO 1);
              rArray8x8_2 <= vArray8x8;
              
              vReceivedBytes := rReveivedBytes + rValidBytes;
              IF rLastOneD1 AND rLastDescriptor = '1' THEN
                IF vReceivedBytes > 4 THEN
                  rDMADatV              <= '1';
                  rStateLittle          <= TRUE;
                  rReveivedBytes        <= vReceivedBytes - 4;
                  rDMADat(31 DOWNTO 24) <= vArray8x8(vReceivedBytes);
                  rDMADat(23 DOWNTO 16) <= vArray8x8(vReceivedBytes-1);
                  rDMADat(15 DOWNTO 8)  <= vArray8x8(vReceivedBytes-2);
                  rDMADat(7 DOWNTO 0)   <= vArray8x8(vReceivedBytes-3);
                ELSE
                  rDMADatV       <= '1';
                  rRellyLastOne  <= TRUE;
                  rReveivedBytes <= 0;
                  CASE vReceivedBytes IS
                    WHEN 1 =>
                      rDMADat(31 DOWNTO 24) <= vArray8x8(1);
                      rDMADat(23 DOWNTO 0)  <= (OTHERS => '0');
                    WHEN 2 =>
                      rDMADat(31 DOWNTO 24) <= vArray8x8(2);
                      rDMADat(23 DOWNTO 16) <= vArray8x8(1);
                      rDMADat(15 DOWNTO 0)  <= (OTHERS => '0');
                    WHEN 3 =>
                      rDMADat(31 DOWNTO 24) <= vArray8x8(3);
                      rDMADat(23 DOWNTO 16) <= vArray8x8(2);
                      rDMADat(15 DOWNTO 8)  <= vArray8x8(1);
                      rDMADat(7 DOWNTO 0)   <= (OTHERS => '0');
                    WHEN 4 =>
                      rDMADat(31 DOWNTO 24) <= vArray8x8(4);
                      rDMADat(23 DOWNTO 16) <= vArray8x8(3);
                      rDMADat(15 DOWNTO 8)  <= vArray8x8(2);
                      rDMADat(7 DOWNTO 0)   <= vArray8x8(1);
                    WHEN OTHERS => NULL;
                  END CASE;
                END IF;
              ELSE                      -- NOT really last one
                IF vReceivedBytes >= 4 THEN
                  rDMADatV              <= '1';
                  rReveivedBytes        <= vReceivedBytes - 4;
                  rDMADat(31 DOWNTO 24) <= vArray8x8(vReceivedBytes);
                  rDMADat(23 DOWNTO 16) <= vArray8x8(vReceivedBytes-1);
                  rDMADat(15 DOWNTO 8)  <= vArray8x8(vReceivedBytes-2);
                  rDMADat(7 DOWNTO 0)   <= vArray8x8(vReceivedBytes-3);
                ELSE
                  rReveivedBytes <= vReceivedBytes;
                END IF;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN TRUE =>
            rStateLittle   <= FALSE;
            rRellyLastOne  <= TRUE;
            rDMADatV       <= '1';
            rReveivedBytes <= 0;
            CASE rReveivedBytes IS
              WHEN 1 =>
                rDMADat(31 DOWNTO 24) <= rArray8x8_2(1);
                rDMADat(23 DOWNTO 0)  <= (OTHERS => '0');
              WHEN 2 =>
                rDMADat(31 DOWNTO 24) <= rArray8x8_2(2);
                rDMADat(23 DOWNTO 16) <= rArray8x8_2(1);
                rDMADat(15 DOWNTO 0)  <= (OTHERS => '0');
              WHEN 3 =>
                rDMADat(31 DOWNTO 24) <= rArray8x8_2(3);
                rDMADat(23 DOWNTO 16) <= rArray8x8_2(2);
                rDMADat(15 DOWNTO 8)  <= rArray8x8_2(1);
                rDMADat(7 DOWNTO 0)   <= (OTHERS => '0');
              -- 应该不会到4这个分支的！！
              WHEN 4 =>
                rDMADat(31 DOWNTO 24) <= rArray8x8_2(4);
                rDMADat(23 DOWNTO 16) <= rArray8x8_2(3);
                rDMADat(15 DOWNTO 8)  <= rArray8x8_2(2);
                rDMADat(7 DOWNTO 0)   <= rArray8x8_2(1);
              WHEN OTHERS => NULL;
            END CASE;
          ---------------------------------------------------------------------
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
    
  END BLOCK blkDataMix;

END ARCHITECTURE rtl;

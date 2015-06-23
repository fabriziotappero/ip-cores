-------------------------------------------------------------------------------
-- Title      : 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : rgmii_rx.vhd
-- Author     : liyi  <alxiuyain@foxmail.com>
-- Company    : OE@HUST
-- Created    : 2012-11-14
-- Last update: 2013-05-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 OE@HUST
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-11-14  1.0      root    Created
-- 2013-05-13  1.0      liyi    change dataen signal ,now the dest&sourcr mac
--                              addr and type_len info are counted as valid data 
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.eth_pkg.ALL;
-------------------------------------------------------------------------------
ENTITY rgmii_rx IS

  PORT (
    iClk   : IN STD_LOGIC;
    iRst_n : IN STD_LOGIC;

    iRxData : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    iRxDV   : IN STD_LOGIC;
    iRxEr   : IN STD_LOGIC;

    -- these signals come from wishbone clock domian, NOT synchronized
    iCheckSumIPCheck   : IN STD_LOGIC;
    iCheckSumTCPCheck  : IN STD_LOGIC;
    iCheckSumUDPCheck  : IN STD_LOGIC;
    iCheckSumICMPCheck : IN STD_LOGIC;

    oEOF         : OUT STD_LOGIC;
    oSOF         : OUT STD_LOGIC;
    oCRCErr      : OUT STD_LOGIC;
    oRxErr       : OUT STD_LOGIC;
    oLenErr      : OUT STD_LOGIC;
    oCheckSumErr : OUT STD_LOGIC;

    iMyMAC : IN STD_LOGIC_VECTOR(47 DOWNTO 0);

    oGetARP  : OUT    STD_LOGIC;
    oGetIPv4 : BUFFER STD_LOGIC;
    oGetCtrl : OUT    STD_LOGIC;
    oGetRaw  : BUFFER STD_LOGIC;

    oTaged      : OUT    STD_LOGIC;
    oTagInfo    : OUT    STD_LOGIC_VECTOR(15 DOWNTO 0);
    oStackTaged : BUFFER STD_LOGIC;
    oTagInfo2   : OUT    STD_LOGIC_VECTOR(15 DOWNTO 0);

    oLink   : OUT STD_LOGIC;
    oSpeed  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    oDuplex : OUT STD_LOGIC;

    oPayloadLen : BUFFER UNSIGNED(15 DOWNTO 0);
    oRxData     : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0);
    oRxDV       : OUT    STD_LOGIC
    );

END ENTITY rgmii_rx;
-------------------------------------------------------------------------------
ARCHITECTURE rtl OF rgmii_rx IS

  SIGNAL sof, eof      : STD_LOGIC;
  SIGNAL crcEn, crcEn2 : STD_LOGIC;
  SIGNAL crcErr        : STD_LOGIC;

  SIGNAL dvDly   : STD_LOGIC_VECTOR(3 DOWNTO 0);
  TYPE dataAyy_t IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL dataDly : dataAyy_t;

  TYPE state_t IS (IDLE, SFD, DEST_MAC, SOURCE_MAC, FRAME_TYPE, TAG_INFO1, TAG_INFO2, PAYLOAD);
  SIGNAL state       : state_t;
  SIGNAL byteCnt     : UNSIGNED(15 DOWNTO 0);
  SIGNAL destMACAddr : STD_LOGIC_VECTOR(47 DOWNTO 8);

  SIGNAL frm4Me : STD_LOGIC;

  SIGNAL rxDV, dataEn : STD_LOGIC;

  SIGNAL rCheckSumOk : BOOLEAN;

BEGIN  -- ARCHITECTURE rtl

  -- check sum calc
  blkCS : BLOCK IS
    TYPE state_t IS (IDLE, IP4_HEAD, TCP, UDP, ICMP, UNKNOWN, DONE);
    SIGNAL rState         : state_t;
    SIGNAL cRxDataD1      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rCheckSum      : UNSIGNED(31 DOWNTO 0);
    SIGNAL cCheckSum      : UNSIGNED(15 DOWNTO 0);
    SIGNAL rIPCSOK        : BOOLEAN;               -- ip checksum ok
    SIGNAL rByteCnt       : UNSIGNED(15 DOWNTO 0);
    SIGNAL cByteValid     : STD_LOGIC;
    SIGNAL rPesudoCS      : UNSIGNED(18 DOWNTO 0);
    SIGNAL rIPHeadLen     : UNSIGNED(5 DOWNTO 0);  -- 20~60 bytes
    SIGNAL rTotalLen      : UNSIGNED(15 DOWNTO 0);
    SIGNAL cIPPayloadLen  : UNSIGNED(15 DOWNTO 0);
    SIGNAL rProtocol      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cIPCSCheckEn   : BOOLEAN;
    SIGNAL cTCPCSCheckEn  : BOOLEAN;
    SIGNAL cICMPCSCheckEn : BOOLEAN;
    SIGNAL cUDPCSCheckEn  : BOOLEAN;
    SIGNAL rGetCheckSum   : BOOLEAN;
    SIGNAL rCsCheckSync   : STD_LOGIC_VECTOR(7 DOWNTO 0);
  BEGIN  -- BLOCK blkCS
    cRxDataD1      <= dataDly(0);
    cByteValid     <= dvDly(0);
    cCheckSum      <= rCheckSum(31 DOWNTO 16) + rCheckSum(15 DOWNTO 0);
    --cCheckSumOk   <= cCheckSum = X"FFFF";
    cIPPayloadLen  <= rTotalLen - rIPHeadLen;
    cIPCSCheckEn   <= rCsCheckSync(1) = '1';
    cTCPCSCheckEn  <= rCsCheckSync(3) = '1';
    cUDPCSCheckEn  <= rCsCheckSync(5) = '1';
    cICMPCSCheckEn <= rCsCheckSync(7) = '1';

    PROCESS (iClk) IS
    BEGIN
      IF rising_edge(iClk) THEN
        rCsCheckSync(1 DOWNTO 0) <= rCsCheckSync(0)&iCheckSumIPCheck;
        rCsCheckSync(3 DOWNTO 2) <= rCsCheckSync(2)&iCheckSumTCPCheck;
        rCsCheckSync(5 DOWNTO 4) <= rCsCheckSync(4)&iCheckSumUDPCheck;
        rCsCheckSync(7 DOWNTO 6) <= rCsCheckSync(6)&iCheckSumICMPCheck;
      END IF;
    END PROCESS;

    PROCESS (iClk, iRst_n) IS
    BEGIN
      IF iRst_n = '0' THEN
        rState       <= IDLE;
        rCheckSum    <= (OTHERS => '0');
        rByteCnt     <= (OTHERS => '0');
        rPesudoCS    <= (OTHERS => '0');
        rIPHeadLen   <= (OTHERS => '0');
        rTotalLen    <= (OTHERS => '0');
        rProtocol    <= (OTHERS => '0');
        rCheckSumOk  <= FALSE;
        rGetCheckSum <= FALSE;
        rIPCSOK      <= FALSE;
      ELSIF rising_edge(iClk) THEN
        rGetCheckSum <= FALSE;
        IF eof = '1' THEN
          rState <= IDLE;
        END IF;
        CASE rState IS
          WHEN IDLE =>
            rPesudoCS   <= (OTHERS => '0');
            rCheckSum   <= (OTHERS => '0');
            rByteCnt    <= X"0001";
            rCheckSumOk <= TRUE;
            rIPCSOK     <= FALSE;
            IF oGetIPv4 = '1' THEN
              rState <= IP4_HEAD;
              rCheckSumOk <= FALSE;
            END IF;
          ---------------------------------------------------------------------
          WHEN IP4_HEAD =>
            IF cByteValid = '1' THEN
              rByteCnt <= rByteCnt + 1;
              IF rByteCnt(0) = '1' THEN  -- higher byte
                rCheckSum <= rCheckSum + to_integer(UNSIGNED(cRxDataD1)&X"00");
              ELSE                       -- lower byte
                rCheckSum <= rCheckSum + UNSIGNED(cRxDataD1);
              END IF;
              CASE rByteCnt(5 DOWNTO 0) IS
                WHEN B"000001" =>
                  rIPHeadLen <= UNSIGNED(cRxDataD1(3 DOWNTO 0))&B"00";
                WHEN B"000011" => rTotalLen(15 DOWNTO 8) <= UNSIGNED(cRxDataD1);
                WHEN B"000100" => rTotalLen(7 DOWNTO 0)  <= UNSIGNED(cRxDataD1);
                WHEN B"001010" =>        -- Protocol
                  rPesudoCS <= rPesudoCS + UNSIGNED(cRxDataD1);
                  rProtocol <= cRxDataD1;
                WHEN B"001011" =>
                  rPesudoCS <= rPesudoCS + cIPPayloadLen;
                -- source &Destination ip addr
                WHEN B"001101" | B"001111" | B"010001" | B"010011" =>
                  rPesudoCS <= rPesudoCS + to_integer(UNSIGNED(cRxDataD1)&X"00");
                WHEN B"001110" | B"010000" | B"010010" | B"010100"=>
                  rPesudoCS <= rPesudoCS + UNSIGNED(cRxDataD1);
                WHEN OTHERS => NULL;
              END CASE;
              IF rIPHeadLen = rByteCnt(5 DOWNTO 0) THEN
                rGetCheckSum <= TRUE;
                rState       <= UNKNOWN;
                CASE rProtocol IS
                  WHEN X"01" =>          -- ICMP
                    rState <= ICMP;
                  WHEN X"06" =>          -- TCP
                    rState <= TCP;
                  WHEN X"11" =>          -- UDP
                    rState <= UDP;
                  WHEN OTHERS => NULL;
                END CASE;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          -- tcp & udp are the same,both contain a pesudo header
          WHEN TCP | UDP =>
            IF rGetCheckSum THEN
              rIPCSOK   <= NOT cIPCSCheckEn OR (cIPCSCheckEn AND cCheckSum = X"FFFF");
              rCheckSum <= X"000"&B"0"&rPesudoCS;
            END IF;
            IF cByteValid = '1' THEN
              rByteCnt <= rByteCnt + 1;
              IF rByteCnt(0) = '1' THEN  -- higher byte
                IF rGetCheckSum THEN
                  rCheckSum <= X"000"&'0'&rPesudoCS + to_integer(UNSIGNED(cRxDataD1)&X"00");
                ELSE
                  rCheckSum <= rCheckSum + to_integer(UNSIGNED(cRxDataD1)&X"00");
                END IF;
              ELSE                       -- lower byte
                rCheckSum <= rCheckSum + UNSIGNED(cRxDataD1);
              END IF;
              IF rByteCnt = rTotalLen THEN
                rState       <= DONE;
                rGetCheckSum <= TRUE;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN ICMP =>
            IF rGetCheckSum THEN
              rIPCSOK   <= NOT cIPCSCheckEn OR (cIPCSCheckEn AND cCheckSum = X"FFFF");
              rCheckSum <= (OTHERS => '0');
            END IF;
            IF cByteValid = '1' THEN
              rByteCnt <= rByteCnt + 1;
              IF rByteCnt(0) = '1' THEN  -- higher byte
                IF rGetCheckSum THEN
                  rCheckSum <= X"0000"&UNSIGNED(cRxDataD1)&X"00";
                ELSE
                  rCheckSum <= rCheckSum + to_integer(UNSIGNED(cRxDataD1)&X"00");
                END IF;
              ELSE                       -- lower byte
                rCheckSum <= rCheckSum + UNSIGNED(cRxDataD1);
              END IF;
              IF rByteCnt = rTotalLen THEN
                rState       <= DONE;
                rGetCheckSum <= TRUE;
              END IF;
            END IF;
          ---------------------------------------------------------------------
          WHEN UNKNOWN =>
            IF rGetCheckSum THEN
              rCheckSumOk <= NOT cIPCSCheckEn OR (cIPCSCheckEn AND cCheckSum = X"FFFF");
            END IF;
          ---------------------------------------------------------------------
          WHEN DONE =>
            IF rGetCheckSum THEN
              CASE rProtocol IS
                WHEN X"01" =>
                  rCheckSumOk <= rIPCSOK AND
                                 (NOT cICMPCSCheckEn OR
                                  (cICMPCSCheckEn AND cCheckSum = X"FFFF"));
                WHEN X"06" =>
                  rCheckSumOk <= rIPCSOK AND
                                 (NOT cTCPCSCheckEn OR
                                  (cTCPCSCheckEn AND cCheckSum = X"FFFF"));
                WHEN X"11" =>
                  rCheckSumOk <= rIPCSOK AND
                                 (NOT cUDPCSCheckEn OR
                                  (cUDPCSCheckEn AND cCheckSum = X"FFFF"));
                WHEN OTHERS => NULL;
              END CASE;
            END IF;
          ---------------------------------------------------------------------
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END PROCESS;
  END BLOCK blkCS;

  -- USE normal inter-frame TO get link information
  PROCESS (iClk, iRst_n) IS
  BEGIN
    IF iRst_n = '0' THEN
      oLink   <= '0';
      oSpeed  <= B"00";
      oDuplex <= '0';
    ELSIF rising_edge(iClk) THEN
      IF iRxEr = '0' AND iRxDV = '0' THEN
        oLink   <= iRxData(0);          -- 0=down,1=up
        oSpeed  <= iRxData(2 DOWNTO 1);  -- 00=10Mbps,01=100Mbps,10=1000Mbps,11=reserved
        oDuplex <= iRxData(3);          -- 0=half-duplex,1=full-duplex
      END IF;
    END IF;
  END PROCESS;

  oEOF    <= eof;
  oCRCErr <= crcErr;

  -- delay! IN order TO get OUT OF the CRC part
  rxDV    <= iRxDV AND dataEn AND NOT iRxEr;
  oRxData <= dataDly(3);
  --oRxDV   <= dvDly(3) AND rxDV;
  oRxDV   <= dvDly(3) AND dataEn;       -- changed @ 2013-05-20
  PROCESS (iClk, iRst_n) IS
  BEGIN
    IF iRst_n = '0' THEN
      dvDly      <= (OTHERS => '0');
      dataDly(0) <= (OTHERS => '0');
      dataDly(1) <= (OTHERS => '0');
      dataDly(2) <= (OTHERS => '0');
      dataDly(3) <= (OTHERS => '0');
    ELSIF rising_edge(iClk) THEN
      dvDly      <= dvDly(2 DOWNTO 0) & rxDV;
      dataDly(3) <= dataDly(2);
      dataDly(2) <= dataDly(1);
      dataDly(1) <= dataDly(0);
      dataDly(0) <= iRxData;
    END IF;
  END PROCESS;

  crcEn2 <= crcEn AND iRxDV AND NOT iRxEr;
  crcCheck : ENTITY work.eth_crc32
    PORT MAP (
      iClk    => iClk,
      iRst_n  => iRst_n,
      iInit   => sof,
      iCalcEn => crcEn2,
      iData   => iRxData,
      oCRC    => OPEN,
      oCRCErr => crcErr);

  PROCESS (iClk, iRst_n) IS
    VARIABLE ethType : STD_LOGIC_VECTOR(15 DOWNTO 0);
  BEGIN
    IF iRst_n = '0' THEN
      state        <= IDLE;
      eof          <= '0';
      byteCnt      <= (OTHERS => '0');
      oPayloadLen  <= (OTHERS => '0');
      oGetCtrl     <= '0';
      oGetARP      <= '0';
      oGetIPv4     <= '0';
      oGetRaw      <= '0';
      --oDrop       <= '0';
      frm4Me       <= '0';
      crcEn        <= '0';
      sof          <= '0';
      dataEn       <= '0';
      destMACAddr  <= (OTHERS => '0');
      oTagInfo2    <= (OTHERS => '0');
      oTaged       <= '0';
      oStackTaged  <= '0';
      oTagInfo     <= (OTHERS => '0');
      oLenErr      <= '0';
      oCheckSumErr <= '0';
      oSOF         <= '0';
    ELSIF rising_edge(iClk) THEN
      --oGetCtrl <= '0';
      --oGetARP  <= '0';
      --oGetIPv4 <= '0';
      --oGetRaw  <= '0';
      eof  <= '0';
      --oDrop    <= '0';
      sof  <= '0';
      oSOF <= '0';
      IF iRxDV = '1' AND iRxEr = '1' THEN
        oRxErr <= '1';
      END IF;

      CASE state IS
        WHEN IDLE =>
          crcEn        <= '0';
          dataEn       <= '0';
          frm4Me       <= '0';
          oGetCtrl     <= '0';
          oGetARP      <= '0';
          oGetIPv4     <= '0';
          oGetRaw      <= '0';
          oRxErr       <= '0';
          oTaged       <= '0';
          oStackTaged  <= '0';
          oLenErr      <= '0';
          oCheckSumErr <= '0';
          IF iRxData = X"55" THEN
            state   <= SFD;
            byteCnt <= (OTHERS => '0');
            sof     <= '1';
          END IF;
        -----------------------------------------------------------------------
        WHEN SFD =>
          IF iRxData = X"55" THEN
            byteCnt <= byteCnt + 1;
          ELSIF iRxData = X"D5" THEN
            IF byteCnt(2 DOWNTO 0) = B"110" THEN
              state   <= DEST_MAC;
              crcEn   <= '1';
              dataEn  <= '1';           -- 2013-05-13
              oSOF    <= '1';
              byteCnt <= (OTHERS => '0');
            ELSE
              state <= IDLE;
            END IF;
          ELSE
            state <= IDLE;
          END IF;
          IF iRxDV = '0' THEN
            state   <= IDLE;
            eof     <= '1';
            oLenErr <= '1';
          END IF;
        -----------------------------------------------------------------------
        WHEN DEST_MAC =>
          IF iRxDV = '1' AND iRxEr = '0' THEN
            byteCnt <= byteCnt + 1;
            CASE byteCnt(2 DOWNTO 0) IS
              WHEN B"000" => destMACAddr(47 DOWNTO 40) <= iRxData;
              WHEN B"001" => destMACAddr(39 DOWNTO 32) <= iRxData;
              WHEN B"010" => destMACAddr(31 DOWNTO 24) <= iRxData;
              WHEN B"011" => destMACAddr(23 DOWNTO 16) <= iRxData;
              WHEN B"100" => destMACAddr(15 DOWNTO 8)  <= iRxData;
              WHEN B"101" =>
                byteCnt(2 DOWNTO 0) <= (OTHERS => '0');
                state               <= SOURCE_MAC;
                IF destMACAddr(47 DOWNTO 8)&iRxData = iMyMAC  -- unicast
                            OR destMACAddr(47 DOWNTO 8)&iRxData = MAC_ADDR_CTRL  -- multicast for flow control
                            OR destMACAddr(47 DOWNTO 8)&iRxData = X"FFFFFFFFFFFF" THEN  -- broadcast
                  --oDrop <= '1';
                  frm4Me <= '1';
                END IF;
              WHEN OTHERS => NULL;
            END CASE;
          END IF;
          IF iRxDV = '0' THEN
            state   <= IDLE;
            eof     <= '1';
            oLenErr <= '1';
          END IF;
        -----------------------------------------------------------------------
        WHEN SOURCE_MAC =>
          IF iRxDV = '1' AND iRxEr = '0' THEN
            byteCnt <= byteCnt + 1;
            IF byteCnt(2 DOWNTO 0) = B"101" THEN
              state               <= FRAME_TYPE;
              byteCnt(2 DOWNTO 0) <= (OTHERS => '0');
            END IF;
          END IF;
          IF iRxDV = '0' THEN
            state   <= IDLE;
            eof     <= '1';
            oLenErr <= '1';
          END IF;
        -----------------------------------------------------------------------
        WHEN FRAME_TYPE =>
          IF iRxDV = '1' AND iRxEr = '0' THEN
            byteCnt <= byteCnt + 1;
            IF byteCnt(0) = '0' THEN
              destMACAddr(15 DOWNTO 8) <= iRxData;
            ELSE
              byteCnt(1 DOWNTO 0) <= (OTHERS => '0');
              ethType             := destMACAddr(15 DOWNTO 8) & iRxData;
              IF ethType < X"0600" AND ethType > X"0000" THEN
                oGetRaw <= frm4Me;
                state   <= PAYLOAD;
                dataEn  <= '1';
              END IF;
              oPayloadLen <= UNSIGNED(ethType);
              -- check the ethnert frame TYPE ,only ARP AND IP PACKAGE are wanted
              CASE ethType IS
                WHEN ETH_TYPE_IPv4 =>
                  oGetIPv4 <= frm4Me;
                  state    <= PAYLOAD;
                  dataEn   <= '1';
                WHEN ETH_TYPE_ARP =>
                  oGetARP <= frm4Me;
                  state   <= PAYLOAD;
                  dataEn  <= '1';
                WHEN ETH_TYPE_CTRL =>
                  oGetCtrl <= frm4Me;
                  state    <= PAYLOAD;
                  dataEn   <= '1';
                WHEN x"8100" =>
                  oTaged <= '1';
                  state  <= TAG_INFO1;
                  dataEn <= '0';
                WHEN x"88A8" | x"9100" =>
                  oStackTaged <= '1';
                  state       <= TAG_INFO1;
                  dataEn      <= '0';
                WHEN OTHERS =>          --oDrop    <= '1';
                  state  <= PAYLOAD;
                  dataEn <= '0';
                  frm4Me <= '0';        -- add @ 2013-05-13
              END CASE;
            END IF;
          END IF;
          IF iRxDV = '0' THEN
            state   <= IDLE;
            eof     <= '1';
            oLenErr <= '1';
          END IF;
        -----------------------------------------------------------------------
        WHEN TAG_INFO1 =>
          IF iRxDV = '1' AND iRxEr = '0' THEN
            byteCnt <= byteCnt + 1;
            IF byteCnt(0) = '0' THEN
              oTagInfo(15 DOWNTO 8) <= iRxData;
            ELSE
              byteCnt(1 DOWNTO 0)  <= (OTHERS => '0');
              oTagInfo(7 DOWNTO 0) <= iRxData;
              IF oStackTaged = '1' THEN
                state <= TAG_INFO2;
              ELSE
                state <= FRAME_TYPE;
              END IF;
            END IF;
          END IF;
          IF iRxDV = '0' THEN
            state   <= IDLE;
            eof     <= '1';
            oLenErr <= '1';
          END IF;
        -----------------------------------------------------------------------
        WHEN TAG_INFO2 =>
          IF iRxDV = '1' AND iRxEr = '0' THEN
            byteCnt <= byteCnt + 1;
            CASE byteCnt(1 DOWNTO 0) IS
              -- we do NOT check,but 0x8100 is expected!
              WHEN B"00" => NULL;
              WHEN B"01" => NULL;
              WHEN B"10" =>
                oTagInfo2(15 DOWNTO 8) <= iRxData;
              WHEN B"11" =>
                oTagInfo2(7 DOWNTO 0) <= iRxData;
                byteCnt(2 DOWNTO 0)   <= (OTHERS => '0');
                state                 <= FRAME_TYPE;
              WHEN OTHERS => NULL;
            END CASE;
          END IF;
                             IF iRxDV = '0' THEN
                               state   <= IDLE;
                               eof     <= '1';
                               oLenErr <= '1';
                             END IF;
        -----------------------------------------------------------------------
        WHEN PAYLOAD =>
          IF oGetRaw = '1' THEN
            IF byteCnt + 1 = oPayloadLen THEN                 -- PAD truncation
              dataEn <= '0';
            END IF;
          END IF;
          IF iRxDV = '1' THEN
            IF iRxEr = '0' THEN
              byteCnt <= byteCnt + 1;
            END IF;
          ELSE
            state <= IDLE;
            eof   <= '1';
            IF rCheckSumOk THEN
              oCheckSumErr <= '0';
            ELSE
              oCheckSumErr <= '1';
            END IF;
            IF frm4Me = '0' THEN        -- add @ 2013-05-13
              oLenErr <= '1';
            END IF;
            IF oGetRaw = '0' THEN
              -- oPayloadLen <= byteCnt - 4; change @ 2013-05-13
              oPayloadLen <= 14 + byteCnt - 4;
            ELSIF oPayloadLen > byteCnt - 4 THEN
              oLenErr <= '1';
            END IF;
            -- add @ 2013-05-13
            IF oGetRaw = '1' THEN
              oPayloadLen <= oPayloadLen + 14;
            END IF;
            IF byteCnt > X"0600" OR byteCnt < X"0020" THEN
              oLenErr <= '1';
            END IF;
          END IF;
        WHEN OTHERS => state <= IDLE;
      END CASE;
      
    END IF;
  END PROCESS;
  
END ARCHITECTURE rtl;

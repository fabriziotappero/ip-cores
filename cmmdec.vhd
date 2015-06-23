-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - Command decoder
--
--     File name      : commdec.vhd 
--
--     Description    : Tag Command decoder    
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;
library work;
use work.epc_tag.all;


entity CommandDecoder is

  generic (
    LOG2_10_TARI_CK_CYC        : integer := 9;  -- Log2(clock cycles for 10 maximum TARI value) (def:Log2(490) = 9 @TCk=520ns)
    DELIMITIER_TIME_CK_CYC_MIN : integer := 22;  -- Min Clock cycles for 12,5 us delimitier
    DELIMITIER_TIME_CK_CYC_MAX : integer := 24);  -- Max Clock cycles for 12,5 us delimitier
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    tdi       : in  std_logic;
    en        : in  std_logic;
    CommDone  : out CommandInternalCode_t;
    Data_r    : out std_logic_vector(31 downto 0);
    CRC_r     : out std_logic_vector(15 downto 0);
    Pointer_r : out std_logic_vector(15 downto 0);
    RN16_r    : out std_logic_vector(15 downto 0);
    Length_r  : out std_logic_vector(7 downto 0);
    Mask_r    : out std_logic_vector(MASKLENGTH-1 downto 0)
    );

end CommandDecoder;

architecture CommandDec1 of CommandDecoder is


  component SymbolDecoder
    generic (
      LOG2_10_TARI_CK_CYC        : integer;
      DELIMITIER_TIME_CK_CYC_MIN : integer;
      DELIMITIER_TIME_CK_CYC_MAX : integer);
    port (
      clk      : in  std_logic;
      rst_n    : in  std_logic;
      tdi      : in  std_logic;
      en       : in  std_logic;
      start    : in  std_logic;
      sserror  : out std_logic;
      ssovalid : out std_logic;
      sso      : out std_logic);
  end component;


  component crc5encdec
    generic (
      PRESET_CRC5 : integer);
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      init  : in  std_logic;
      ce    : in  std_logic;
      sdi   : in  std_logic;
      cout  : out std_logic_vector(4 downto 0));
  end component;


  component crc16encdec
    generic (
      PRESET_CRC16 : integer);
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      init  : in  std_logic;
      ce    : in  std_logic;
      sdi   : in  std_logic;
      cout  : out std_logic_vector(15 downto 0));
  end component;


  component COUNTERCLR
    generic (
      width : integer);
    port (
      clk    : in  std_logic;
      rst_n  : in  std_logic;
      en     : in  std_logic;
      clear  : in  std_logic;
      outcnt : out std_logic_vector(width-1 downto 0));
  end component;

  component shiftreg
    generic (
      REGWD : integer);
    port (
      clk   : in  std_logic;
      rst_n : in  std_logic;
      ce    : in  std_logic;
      sin   : in  std_logic;
      pout  : out std_logic_vector(REGWD - 1 downto 0));
  end component;

  

  type CmDecFSM_t is (st_Init, st_Start, st_Cm2_0, st_QueryRep, st_Ack,
                      st_Cm4or8_1, st_Cm4_10, st_Cm4_100,
                      st_Query, st_QueryAdjust, st_Cm4_101, st_Select,
                      st_Cm8_11, st_Cm8_110, st_Cm8_1100, st_Cm8_11000,
                      st_Cm8_110000, st_Cm8_1100000, st_Nak, st_ReqRN,
                      st_Cm8_1100001, st_Read, st_Write, st_Cm8_110001,
                      st_Cm8_1100010, st_Kill, st_Lock, st_Cm8_1100011,
                      st_Access, st_BlockWrite, st_Cm8_11001, st_Cm8_110010,
                      st_Cm8_1100100, st_BlockErase, st_ErrorDec, st_CommandReady,
                      st_QueryRep_w, st_Ack_w, st_Query_w, st_QueryAdjust_w, st_Select_w,
                      st_Nak_w, st_ReqRN_w, st_Read_w, st_Write_w, st_Kill_w, st_Lock_w,
                      st_Access_w, st_BlockWrite_w, st_BlockErase_w);

  type CmDataRecFSM_t is (st_WaitCmd, st_QueryRep_GetData, st_QueryRep_Done,
                          st_Ack_GetRN, st_Ack_Done,
                          st_Nak_Done,
                          st_Query_GetData, st_Query_GetCRC5, st_Query_Done,
                          st_QueryAdjust_GetData, st_QueryAdjust_Done,
                          st_Select_GetData1, st_Select_GetPointer, st_Select_GetPointer_LastByte,
                          st_Select_GetPointer_NotLastByte, st_Select_GetLength,
                          st_Select_GetMask, st_Select_GetData2, st_Select_GetCRC16, st_Select_Done,
                          st_ReqRN_GetRN, st_ReqRN_GetCRC16, st_ReqRN_Done,
                          st_Read_GetData1, st_Read_GetWordPtr, st_Read_GetLength,
                          st_Read_GetRN, st_Read_GetCRC16, st_Read_Done,
                          st_Read_GetWordPtr_LastByte, st_Read_GetWordPtr_NotLastByte,
                          st_Write_GetData1, st_Write_GetWordPtr, st_Write_GetData2,
                          st_Write_GetRN, st_Write_GetCRC16, st_Write_Done,
                          st_Write_GetWordPtr_LastByte, st_Write_GetWordPtr_NotLastByte,
                          st_Kill_GetData, st_Kill_GetRN, st_Kill_GetCRC16, st_Kill_Done,
                          st_Lock_GetData, st_Lock_GetRN, st_Lock_GetCRC16, st_Lock_Done,
                          st_Access_GetData, st_Access_GetRN, st_Access_GetCRC16, st_Access_Done,
                          st_BlockWrite_GetData, st_BlockWrite_GetWordPtr,
                          st_BlockWrite_GetWordCnt, st_BlockWrite_GetWriteData,
                          st_BlockWrite_GetRN, st_BlockWrite_GetCRC16, st_BlockWrite_Done,
                          st_BlockErase_GetData1, st_BlockErase_GetWordPtr, st_BlockErase_GetData2,
                          st_BlockErase_GetRN, st_BlockErase_GetCRC16, st_BlockErase_Done);


  -- Constants 
  constant PRESET_CRC5                                   : integer := 9;
  constant PRESET_CRC16                                  : integer := 65535;
  -- Decoder States Signals
  signal   StDec, NextStDec                              : CmDecFSM_t;
  signal   StartSDec_i, StartSDec                        : std_logic;
  -- Data Receiver State Signals
  signal   StDat, NextStDat                              : CmDataRecFSM_t;
  -- Command Start and Done
  signal   CommandDone, CommandDone_i                    : CommandInternalCode_t;
  signal   CommandStart, CommandStart_i                  : CommandInternalCode_t;
  -- Counter signals
  signal   DataCnt, RNCnt, CRCCnt                        : std_logic_vector(7 downto 0);
  signal   PointerCnt                                    : std_logic_vector(7 downto 0);
  signal   DataCnt_Inc, DataCnt_Inc_i, RNCnt_Inc         : std_logic;
  signal   RNCnt_Inc_i, PointerCnt_Inc, PointerCnt_Inc_i : std_logic;
  signal   CRCCnt_Inc, CRCCnt_Inc_i, DataCnt_Clear       : std_logic;
  signal   DataCnt_Clear_i, RNCnt_Clear, RNCnt_Clear_i   : std_logic;
  signal   PointerCnt_Clear, PointerCnt_Clear_i          : std_logic;
  signal   CRCCnt_Clear, CRCCnt_Clear_i                  : std_logic;
  -- Flags
  signal   LastPntByteFlag, LastPntByteFlag_i            : std_logic;
  signal   FirstPntBitTaken, FirstPntBitTaken_i          : std_logic;
  signal   CommandDoneFlag, CommandDoneFlag_i            : std_logic;
  -- Register enables
  signal   DatRegEnable, RNRegEnable, CRCRegEnable       : std_logic;
  signal   DatRegEnable_i, RNRegEnable_i, CRCRegEnable_i : std_logic;
  signal   PointerRegEnable, PointerRegEnable_i          : std_logic;
  signal   LengthWCntRegEnable, LengthWCntRegEnable_i    : std_logic;
  signal   MaskRegEnable_i, MaskRegEnable                : std_logic;
  -- Registers 
  signal   RN16_o, CRC16_o                               : std_logic_vector(15 downto 0);
  signal   RN16_ce, CRC16_ce, GPReg_ce                   : std_logic;
  signal   GPReg_o                                       : std_logic_vector(31 downto 0);
  signal   Pointer_o                                     : std_logic_vector(15 downto 0);
  signal   Pointer_ce                                    : std_logic;
  signal   Pointer_rst, Pointer_rst_i, Pointer_NOTrst    : std_logic;
  signal   LengthWCnt_o                                  : std_logic_vector(7 downto 0);
  signal   LengthWCnt_ce                                 : std_logic;
  signal   MaskReg_o                                     : std_logic_vector(MASKLENGTH-1 downto 0);
  signal   MaskReg_ce                                    : std_logic;
  -- CRC regs & control
  signal   CRC5Dec                                       : std_logic_vector(4 downto 0);
  signal   CRC16Dec                                      : std_logic_vector(15 downto 0);
  signal   CRC5Init, CRC16Init, CRC5Init_i, CRC16Init_i  : std_logic;
  signal   CRC5ce, CRC16ce                               : std_logic;
  -- Symbol Decoder signals
  signal   sso, ssovalid, sserror                        : std_logic;
  
begin  -- CommandDec1


-------------------------------------------------------------------------------
-- COMMAND DECODER PROCESSES
-------------------------------------------------------------------------------
  
  SYNCRO_DEC : process (clk, rst_n)
  begin  -- process SYNCRO
    if rst_n = '0' then                 -- asynchronous reset (active low)
      StartSDec    <= '0';
      -- Command start signal
      CommandStart <= cmd_NULL;
      -- CRC signals
      CRC5Init     <= '0';
      CRC16Init    <= '0';
      -- State signal
      StDec        <= st_Init;
    elsif clk'event and clk = '1' then  -- rising clock edge
      StartSDec    <= StartSDec_i;
      -- Command start signal
      CommandStart <= CommandStart_i;
      -- CRC signals
      CRC5Init     <= CRC5Init_i;
      CRC16Init    <= CRC16Init_i;
      -- State signal
      StDec        <= NextStDec;
    end if;
  end process SYNCRO_DEC;

  NEXT_ST_DEC : process (StDec, sso, ssovalid, CommandDoneFlag, sserror)
  begin  -- process NEXT_ST
    NextStDec <= StDec;

    case StDec is
      when st_Init =>
        NextStDec <= st_Start;
      when st_Start =>
        if ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm2_0;
          else
            NextStDec <= st_Cm4or8_1;
          end if;
        end if;

        -- two-bit commands
      when st_Cm2_0 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_QueryRep;   -- 00
          else
            NextStDec <= st_Ack;        -- 01
          end if;
        end if;
      when st_Cm4or8_1 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm4_10;
          else
            NextStDec <= st_Cm8_11;
          end if;
        end if;

        -- four-bit commands
      when st_Cm4_10 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0'then
            NextStDec <= st_Cm4_100;
          else
            NextStDec <= st_Cm4_101;
          end if;
        end if;
      when st_Cm4_100 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Query;        -- 1000
          else
            NextStDec <= st_QueryAdjust;  -- 1001
          end if;
        end if;
      when st_Cm4_101 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Select;       -- 1010
          else
            NextStDec <= st_ErrorDec;
          end if;
        end if;

        -- eight-bit commands
      when st_Cm8_11 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_110;
          else
            NextStDec <= st_ErrorDec;
          end if;
        end if;
      when st_Cm8_110 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_1100;
          else
            NextStDec <= st_ErrorDec;
          end if;
        end if;
      when st_cm8_1100 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_11000;
          else
            NextStDec <= st_Cm8_11001;
          end if;
        end if;
      when st_Cm8_11000 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_110000;
          else
            NextStDec <= st_Cm8_110001;
          end if;
        end if;
      when st_Cm8_110000 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_1100000;
          else
            NextStDec <= st_Cm8_1100001;
          end if;
        end if;
      when st_Cm8_1100000 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Nak;         -- 11000000
          else
            NextStDec <= st_ReqRN;       -- 11000001
          end if;
        end if;
      when st_Cm8_1100001 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Read;        -- 11000010
          else
            NextStDec <= st_Write;       -- 11000011
          end if;
        end if;
      when st_Cm8_110001 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_1100010;
          else
            NextStDec <= st_Cm8_1100011;
          end if;
        end if;
      when st_Cm8_1100010 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Kill;        -- 11000100
          else
            NextStDec <= st_Lock;        -- 11000101
          end if;
        end if;
      when st_Cm8_1100011 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Access;      -- 11000110
          else
            NextStDec <= st_BlockWrite;  -- 11000111
          end if;
        end if;
      when st_Cm8_11001 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_110010;
          else
            NextStDec <= st_ErrorDec;
          end if;
        end if;
      when st_Cm8_110010 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_Cm8_1100100;
          else
            NextStDec <= st_ErrorDec;
          end if;
        end if;
      when st_Cm8_1100100 =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif ssovalid = '1' then
          if sso = '0' then
            NextStDec <= st_BlockErase;  -- 11001000
          else
            NextStDec <= st_ErrorDec;
          end if;
        end if;

        -- Command Start states
      when st_QueryRep =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_QueryRep_w;
        end if;
      when st_Ack =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Ack_w;
        end if;
      when st_Query =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Query_w;
        end if;
      when st_QueryAdjust =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_QueryAdjust_w;
        end if;
      when st_Select =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Select_w;
        end if;
      when st_Nak =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Nak_w;
        end if;
      when st_ReqRN =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_ReqRN_w;
        end if;
      when st_Read =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Read_w;
        end if;
      when st_Write =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Write_w;
        end if;
      when st_Kill =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Kill_w;
        end if;
      when st_Lock =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Lock_w;
        end if;
      when st_Access =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_Access_w;
        end if;
      when st_BlockWrite =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_BlockWrite_w;
        end if;
      when st_BlockErase =>
        if sserror = '1' then
          NextStDec <= st_Init;
        else
          NextStDec <= st_BlockErase_w;
        end if;

        -- Command done-waiting states
      when st_QueryRep_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Ack_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Query_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_QueryAdjust_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Select_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Nak_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_ReqRN_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Read_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Write_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Kill_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Lock_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_Access_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_BlockWrite_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
      when st_BlockErase_w =>
        if sserror = '1' then
          NextStDec <= st_Init;
        elsif CommandDoneFlag = '1' then
          NextStDec <= st_CommandReady;
        end if;
        
      when others =>
        NextStDec <= st_Init;
    end case;
  end process NEXT_ST_DEC;


  OUTPUTDEC_DEC : process (StDec)
  begin  -- process OUTPUT_DEC
    StartSDec_i    <= '0';
    CommandStart_i <= cmd_NULL;
    CRC5Init_i     <= '0';
    CRC16Init_i    <= '0';

    case StDec is
      when st_Init =>
        CRC5Init_i  <= '1';
        CRC16Init_i <= '1';
        StartSDec_i <= '1';
      when st_Start =>
        StartSDec_i <= '1';
      when st_QueryRep =>
        CommandStart_i <= cmd_QueryRep;
      when st_Ack =>
        CommandStart_i <= cmd_Ack;
      when st_Query =>
        CommandStart_i <= cmd_Query;
      when st_QueryAdjust =>
        CommandStart_i <= cmd_QueryAdjust;
      when st_Select =>
        CommandStart_i <= cmd_Select;
      when st_Nak =>
        CommandStart_i <= cmd_Nak;
      when st_ReqRN =>
        CommandStart_i <= cmd_ReqRN;
      when st_Read =>
        CommandStart_i <= cmd_Read;
      when st_Write =>
        CommandStart_i <= cmd_Write;
      when st_Kill =>
        CommandStart_i <= cmd_Kill;
      when st_Lock =>
        CommandStart_i <= cmd_Lock;
      when st_Access =>
        CommandStart_i <= cmd_Access;
      when st_BlockWrite =>
        CommandStart_i <= cmd_BlockWrite;
      when st_BlockErase =>
        CommandStart_i <= cmd_BlockErase;
      when others => null;
    end case;
  end process OUTPUTDEC_DEC;


-------------------------------------------------------------------------------
-- DATA RECEIVER PROCESSES
-------------------------------------------------------------------------------

  SYNCRO_DAT : process (clk, rst_n)
  begin  -- process SYNCRO
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- Command Done signal
      CommandDone         <= cmd_NULL;
      -- Counters
      DataCnt_Inc         <= '0';
      DataCnt_Clear       <= '0';
      RNCnt_Inc           <= '0';
      RNCnt_Clear         <= '0';
      CRCCnt_Inc          <= '0';
      CRCCnt_Clear        <= '0';
      PointerCnt_Inc      <= '0';
      PointerCnt_Clear    <= '0';
      -- Reg CE
      DatRegEnable        <= '0';
      RNRegEnable         <= '0';
      CRCRegEnable        <= '0';
      PointerRegEnable    <= '0';
      LengthWCntRegEnable <= '0';
      MaskRegEnable       <= '0';
      Pointer_rst         <= '0';
      -- Flags
      LastPntByteFlag     <= '0';
      FirstPntBitTaken    <= '0';
      CommandDoneFlag     <= '0';
      -- State signal
      StDat               <= st_WaitCmd;
    elsif clk'event and clk = '1' then  -- rising clock edge;
      -- Command Done signal
      CommandDone         <= CommandDone_i;
      -- Counters
      DataCnt_Inc         <= DataCnt_Inc_i;
      DataCnt_Clear       <= DataCnt_Clear_i;
      RNCnt_Inc           <= RNCnt_Inc_i;
      RNCnt_Clear         <= RNCnt_Clear_i;
      CRCCnt_Inc          <= CRCCnt_Inc_i;
      CRCCnt_Clear        <= CRCCnt_Clear_i;
      PointerCnt_Inc      <= PointerCnt_Inc_i;
      PointerCnt_Clear    <= PointerCnt_Clear_i;
      -- Reg CE
      DatRegEnable        <= DatRegEnable_i;
      RNRegEnable         <= RNRegEnable_i;
      CRCRegEnable        <= CRCRegEnable_i;
      PointerRegEnable    <= PointerRegEnable_i;
      LengthWCntRegEnable <= LengthWCntRegEnable_i;
      MaskRegEnable       <= MaskRegEnable_i;
      Pointer_rst         <= Pointer_rst_i;
      -- Flags
      LastPntByteFlag     <= LastPntByteFlag_i;
      FirstPntBitTaken    <= FirstPntBitTaken_i;
      CommandDoneFlag     <= CommandDoneFlag_i;
      -- State signal
      StDat               <= NextStDat;
    end if;
  end process SYNCRO_DAT;


  NEXT_ST_DAT : process (StDat, CommandStart, sserror, DataCnt, RNCnt, CRCCnt, FirstPntBitTaken, LastPntByteFlag, PointerCnt, LengthWCnt_o)
  begin  -- process NEXT_ST_DAT
    NextStDat <= StDat;

    case StDat is
      when st_WaitCmd =>
        case CommandStart is
          when cmd_Select =>
            NextStDat <= st_Select_GetData1;
          when cmd_Query =>
            NextStDat <= st_Query_GetData;
          when cmd_QueryAdjust =>
            NextStDat <= st_QueryAdjust_GetData;
          when cmd_QueryRep =>
            NextStDat <= st_QueryRep_GetData;
          when cmd_Ack =>
            NextStDat <= st_Ack_GetRN;
          when cmd_Nak =>
            NextStDat <= st_Nak_Done;
          when cmd_ReqRN =>
            NextStDat <= st_ReqRN_GetRN;
          when cmd_Read =>
            NextStDat <= st_Read_GetData1;
          when cmd_Write =>
            NextStDat <= st_Write_GetData1;
          when cmd_Kill =>
            NextStDat <= st_Kill_GetData;
          when cmd_Lock =>
            NextStDat <= st_Lock_GetData;
          when cmd_Access =>
            NextStDat <= st_Access_GetData;
          when cmd_BlockWrite =>
            NextStDat <= st_BlockWrite_GetData;
          when cmd_BlockErase =>
            NextStDat <= st_BlockErase_GetData1;
          when others => null;
        end case;

        -- Select
      when st_Select_GetData1 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(8, 8) then  -- Target(3)-Action(3)-Membank(2)
          NextStDat <= st_Select_GetPointer;
        end if;
      when st_Select_GetPointer =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif FirstPntBitTaken = '1' then
          if LastPntByteFlag = '1' then
            NextStDat <= st_Select_GetPointer_LastByte;
          else
            NextStDat <= st_Select_GetPointer_NotLastByte;
          end if;
        end if;
      when st_Select_GetPointer_NotLastByte =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif PointerCnt = conv_std_logic_vector(7, 8) then
          NextStDat <= st_Select_GetPointer;
        end if;
      when st_Select_GetPointer_LastByte =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif PointerCnt = conv_std_logic_vector(7, 8) then
          NextStDat <= st_Select_GetLength;
        end if;
      when st_Select_GetLength =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(8, 8) then
          NextStDat <= st_Select_GetMask;
        end if;
      when st_Select_GetMask =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif PointerCnt = LengthWCnt_o then
          NextStDat <= st_Select_GetData2;
        end if;
      when st_Select_GetData2 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(1, 8) then  -- Truncate(1)
          NextStDat <= st_Select_GetCRC16;
        end if;
      when st_Select_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Select_Done;
        end if;
      when st_Select_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Query
      when st_Query_GetData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(13, 8) then  -- DR(1)-M(2)-TRext(1)-Sel(2)-Session(2)-Target(1)-Q(4)
          NextStDat <= st_Query_GetCRC5;
        end if;
      when st_Query_GetCRC5 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(5, 8) then
          NextStDat <= st_Query_Done;
        end if;
      when st_Query_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- QueryAdjust
      when st_QueryAdjust_GetData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(5, 8) then  -- Session(2)-UpDn(3)
          NextStDat <= st_QueryAdjust_Done;
        end if;
      when st_QueryAdjust_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- QueryRep
      when st_QueryRep_GetData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(2, 8) then  --Session(2)
          NextStDat <= st_QueryRep_Done;
        end if;
      when st_QueryRep_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Ack
      when st_Ack_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Ack_Done;
        end if;
      when st_Ack_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Nak
      when st_Nak_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- ReqRN
      when st_ReqRN_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_ReqRN_GetCRC16;
        end if;
      when st_ReqRN_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_ReqRN_Done;
        end if;
      when st_ReqRN_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Read
      when st_Read_GetData1 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(2, 8) then  -- Membank(2)
          NextStDat <= st_Read_GetWordPtr;
        end if;
      when st_Read_GetWordPtr =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif FirstPntBitTaken = '1' then
          if LastPntByteFlag = '1' then
            NextStDat <= st_Read_GetWordPtr_LastByte;
          else
            NextStDat <= st_Read_GetWordPtr_NotLastByte;
          end if;
        end if;
      when st_Read_GetWordPtr_LastByte =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif PointerCnt = conv_std_logic_vector(7, 8) then
          NextStDat <= st_Read_GetLength;
        end if;
      when st_Read_GetWordPtr_NotLastByte =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif PointerCnt = conv_std_logic_vector(7, 8) then
          NextStDat <= st_Read_GetWordPtr;
        end if;
      when st_Read_GetLength =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(8, 8) then  -- WordCount(8)
          NextStDat <= st_Read_GetRN;
        end if;
      when st_Read_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Read_GetCRC16;
        end if;
      when st_Read_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Read_Done;
        end if;
      when st_Read_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Write
      when st_Write_GetData1 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(2, 8) then   -- Membank(2)
          NextStDat <= st_Write_GetWordPtr;
        end if;
      when st_Write_GetWordPtr =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif FirstPntBitTaken = '1' then
          if LastPntByteFlag = '1' then
            NextStDat <= st_Write_GetWordPtr_LastByte;
          else
            NextStDat <= st_Write_GetWordPtr_NotLastByte;
          end if;
        end if;
      when st_Write_GetWordPtr_LastByte =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif PointerCnt = conv_std_logic_vector(7, 8) then
          NextStDat <= st_Write_GetData2;
        end if;
      when st_Write_GetWordPtr_NotLastByte =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif PointerCnt = conv_std_logic_vector(7, 8) then
          NextStDat <= st_Write_GetWordPtr;
        end if;
      when st_Write_GetData2 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(16, 8) then  --Data(16)
          NextStDat <= st_Write_GetRN;
        end if;
      when st_Write_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Write_GetCRC16;
        end if;
      when st_Write_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Write_Done;
        end if;
      when st_Write_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Kill
      when st_Kill_GetData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(19, 8) then  -- Data(16)-RFU(3)
          NextStDat <= st_Kill_GetRN;
        end if;
      when st_Kill_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Kill_GetCRC16;
        end if;
      when st_Kill_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Kill_Done;
        end if;
      when st_Kill_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Lock
      when st_Lock_GetData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(20, 8) then  -- Payload(20)
          NextStDat <= st_Lock_GetRN;
        end if;
      when st_Lock_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Lock_GetCRC16;
        end if;
      when st_Lock_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Lock_Done;
        end if;
      when st_Lock_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- Access
      when st_Access_GetData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Access_GetRN;
        end if;
      when st_Access_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Access_GetCRC16;
        end if;
      when st_Access_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_Access_Done;
        end if;
      when st_Access_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- BlockWrite
      when st_BlockWrite_GetData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(2, 8) then  --Membank(2)
          NextStDat <= st_BlockWrite_GetWordPtr;
        end if;
      when st_BlockWrite_GetWordPtr =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_BlockWrite_GetWordCnt;
        end if;
      when st_BlockWrite_GetWordCnt =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_BlockWrite_GetWriteData;
        end if;
      when st_BlockWrite_GetWriteData =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_BlockWrite_GetRN;
        end if;
      when st_BlockWrite_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_BlockWrite_GetCRC16;
        end if;
      when st_BlockWrite_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_BlockWrite_Done;
        end if;
      when st_BlockWrite_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

        -- BlockErase
      when st_BlockErase_GetData1 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(2, 8) then  --Membank(2)
          NextStDat <= st_BlockErase_GetWordPtr;
        end if;
      when st_BlockErase_GetWordPtr =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_BlockErase_GetData2;
        end if;
      when st_BlockErase_GetData2 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif DataCnt = conv_std_logic_vector(8, 8) then
          NextStDat <= st_BlockErase_GetRN;
        end if;
      when st_BlockErase_GetRN =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif RNCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_BlockErase_GetCRC16;
        end if;
      when st_BlockErase_GetCRC16 =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        elsif CRCCnt = conv_std_logic_vector(16, 8) then
          NextStDat <= st_BlockErase_Done;
        end if;
      when st_BlockErase_Done =>
        if sserror = '1' then
          NextStDat <= st_WaitCmd;
        else
          NextStDat <= st_WaitCmd;
        end if;

      when others => null;
    end case;
    
  end process NEXT_ST_DAT;

  OUPUTDEC_DAT : process (StDat, ssovalid, sso, CRC5Dec, CRC16Dec)
  begin  -- process OUPUTDEC_DAT
    CommandDone_i         <= cmd_NULL;
    CommandDoneFlag_i     <= '0';
    -- Counters
    DataCnt_Inc_i         <= '0';
    DataCnt_Clear_i       <= '1';
    RNCnt_Inc_i           <= '0';       -- Used also as "Select.Length" counter
    RNCnt_Clear_i         <= '1';
    CRCCnt_Inc_i          <= '0';
    CRCCnt_Clear_i        <= '1';
    PointerCnt_Inc_i      <= '0';       -- Used also as "Select.Mask" counter
    PointerCnt_Clear_i    <= '1';
    -- Reg CE
    MaskRegEnable_i       <= '0';
    DatRegEnable_i        <= '0';
    PointerRegEnable_i    <= '0';
    LengthWCntRegEnable_i <= '0';
    RNRegEnable_i         <= '0';
    CRCRegEnable_i        <= '0';
    -- Flags
    LastPntByteFlag_i     <= '0';
    FirstPntBitTaken_i    <= '0';
    Pointer_rst_i         <= '0';

    case StDat is

      -- Select
      when st_Select_GetData1 =>
        DatRegEnable_i  <= '1';
        Pointer_rst_i   <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Select_GetPointer =>
        if ssovalid = '1' then
          FirstPntbitTaken_i <= '1';
          if sso = '0' then
            LastPntByteFlag_i <= '1';
          end if;
        end if;
      when st_Select_GetPointer_NotLastByte =>
        PointerRegEnable_i <= '1';
        PointerCnt_Clear_i <= '0';
        if ssovalid = '1' then
          PointerCnt_Inc_i <= '1';
        end if;
      when st_Select_GetPointer_LastByte =>
        PointerRegEnable_i <= '1';
        PointerCnt_Clear_i <= '0';
        if ssovalid = '1' then
          PointerCnt_Inc_i <= '1';
        end if;
      when st_Select_GetLength =>
        LengthWCntRegEnable_i <= '1';
        RNCnt_Clear_i         <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_Select_GetMask =>
        MaskRegEnable_i    <= '1';
        PointerCnt_Clear_i <= '0';
        if ssovalid = '1' then
          PointerCnt_Inc_i <= '1';
        end if;
      when st_Select_GetData2 =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Select_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_Select_Done =>
        CommandDoneFlag_i <= '1';
        if CRC16Dec = X"0000" then
          CommandDone_i <= cmd_Select;
        end if;

        -- Query
      when st_Query_GetData =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Query_GetCRC5 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_Query_Done =>
        CommandDoneFlag_i <= '1';
        if CRC5Dec = "00000" then
          CommandDone_i <= cmd_Query;
        end if;

        -- QueryAdjust
      when st_QueryAdjust_GetData =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_QueryAdjust_Done =>
        CommandDoneFlag_i <= '1';
        CommandDone_i     <= cmd_QueryAdjust;

        -- QueryRep
      when st_QueryRep_GetData =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_QueryRep_Done =>
        CommandDoneFlag_i <= '1';
        CommandDone_i     <= cmd_QueryRep;

        -- Ack
      when st_Ack_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_Ack_Done =>
        CommandDoneFlag_i <= '1';
        CommandDone_i     <= cmd_Ack;

        -- Nak
      when st_Nak_Done =>
        CommandDoneFlag_i <= '1';
        CommandDone_i     <= cmd_Nak;

        -- ReqRN
      when st_ReqRN_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_ReqRN_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_ReqRN_Done =>
        CommandDoneFlag_i <= '1';
        if CRC16Dec = X"0000" then
          CommandDone_i <= cmd_ReqRN;
        end if;

        -- Read
      when st_Read_GetData1 =>
        Pointer_rst_i   <= '1';
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Read_GetWordPtr =>
        if ssovalid = '1' then
          FirstPntbitTaken_i <= '1';
          if sso = '0' then
            LastPntByteFlag_i <= '1';
          end if;
        end if;
      when st_Read_GetWordPtr_NotLastByte =>
        PointerRegEnable_i <= '1';
        PointerCnt_Clear_i <= '0';
        if ssovalid = '1' then
          PointerCnt_Inc_i <= '1';
        end if;
      when st_Read_GetWordPtr_LastByte =>
        PointerRegEnable_i <= '1';
        PointerCnt_Clear_i <= '0';
        if ssovalid = '1' then
          PointerCnt_Inc_i <= '1';
        end if;
      when st_Read_GetLength =>
        --DatRegEnable_i  <= '1';
        LengthWCntRegEnable_i <= '1';
        DataCnt_Clear_i       <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Read_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_Read_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_Read_Done =>
        CommandDoneFlag_i <= '1';
        if CRC16Dec = X"0000" then
          CommandDone_i <= cmd_Read;
        end if;

        -- Write
      when st_Write_GetData1 =>
        DatRegEnable_i  <= '1';
        Pointer_rst_i   <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Write_GetWordPtr =>
        if ssovalid = '1' then
          FirstPntbitTaken_i <= '1';
          if sso = '0' then
            LastPntByteFlag_i <= '1';
          end if;
        end if;
      when st_Write_GetWordPtr_NotLastByte =>
        PointerRegEnable_i <= '1';
        PointerCnt_Clear_i <= '0';
        if ssovalid = '1' then
          PointerCnt_Inc_i <= '1';
        end if;
      when st_Write_GetWordPtr_LastByte =>
        PointerRegEnable_i <= '1';
        PointerCnt_Clear_i <= '0';
        if ssovalid = '1' then
          PointerCnt_Inc_i <= '1';
        end if;
      when st_Write_GetData2 =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Write_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_Write_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_Write_Done =>
        CommandDoneFlag_i <= '1';
        if CRC16Dec = X"0000" then
          CommandDone_i <= cmd_Write;
        end if;

        -- Kill
      when st_Kill_GetData =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Kill_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_Kill_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_Kill_Done =>
        CommandDoneFlag_i <= '1';
        if CRC16Dec = X"0000" then
          CommandDone_i <= cmd_Kill;
        end if;

        -- Lock
      when st_Lock_GetData =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Lock_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_Lock_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_Lock_Done =>
        CommandDoneFlag_i <= '1';
        if CRC16Dec = X"0000" then
          CommandDone_i <= cmd_Lock;
        end if;

        -- Access (not fully implemented)
      when st_Access_GetData =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_Access_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_Access_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_Access_Done =>
        CommandDoneFlag_i <= '1';
        CommandDone_i     <= cmd_Access;

        -- BlockWrite (not fully implemented)
      when st_BlockWrite_GetData =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_BlockWrite_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_BlockWrite_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_BlockWrite_Done =>
        CommandDoneFlag_i <= '1';
        CommandDone_i     <= cmd_BlockWrite;

        -- BlockErase (not fully implemented)
      when st_BlockErase_GetData1 =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_BlockErase_GetData2 =>
        DatRegEnable_i  <= '1';
        DataCnt_Clear_i <= '0';
        if ssovalid = '1' then
          DataCnt_Inc_i <= '1';
        end if;
      when st_BlockErase_GetRN =>
        RNRegEnable_i <= '1';
        RNCnt_Clear_i <= '0';
        if ssovalid = '1' then
          RNCnt_Inc_i <= '1';
        end if;
      when st_BlockErase_GetCRC16 =>
        CRCRegEnable_i <= '1';
        CRCCnt_Clear_i <= '0';
        if ssovalid = '1' then
          CRCCnt_Inc_i <= '1';
        end if;
      when st_BlockErase_Done =>
        CommandDoneFlag_i <= '1';
        CommandDone_i     <= cmd_BlockErase;
        
        
      when others => null;
    end case;
    
  end process OUPUTDEC_DAT;


-------------------------------------------------------------------------------
-- Data Shift Registers
-------------------------------------------------------------------------------  

  -- 16 bit register:
  -- RN 16 
  RN16_SHREG : shiftreg
    generic map (
      REGWD => 16)
    port map (
      clk   => clk,
      rst_n => rst_n,
      ce    => RN16_ce,
      sin   => sso,
      pout  => RN16_o);

  RN16_ce <= ssovalid and RNRegEnable;


  -- 16 bit register:
  -- CRC 16 
  CRC16_SHREG : shiftreg
    generic map (
      REGWD => 16)
    port map (
      clk   => clk,
      rst_n => rst_n,
      ce    => CRC16_ce,
      sin   => sso,
      pout  => CRC16_o);

  CRC16_ce <= ssovalid and CRCRegEnable;


  -- 32 Register
  -- General Purpose Register
  GPREG_SHREG : shiftreg
    generic map (
      REGWD => 32)
    port map (
      clk   => clk,
      rst_n => rst_n,
      ce    => GPReg_ce,
      sin   => sso,
      pout  => GPReg_o);

  GPReg_ce <= ssovalid and DatRegEnable;


  -- 16 bit register:
  -- Pointer register 
  POINTER_SHREG : shiftreg
    generic map (
      REGWD => 16)
    port map (
      clk   => clk,
      rst_n => Pointer_NOTrst,
      ce    => Pointer_ce,
      sin   => sso,
      pout  => Pointer_o);

  Pointer_NOTrst <= not(Pointer_rst) and rst_n;
  Pointer_ce     <= ssovalid and PointerRegEnable;


  -- 8 bit register
  -- Length/WordCount Register
  LNT_SHREG : shiftreg
    generic map (
      REGWD => 8)
    port map (
      clk   => clk,
      rst_n => rst_n,
      ce    => LengthWCnt_ce,
      sin   => sso,
      pout  => LengthWCnt_o);

  LengthWCnt_ce <= ssovalid and LengthWCntRegEnable;

  -- MASKLENGTH bit register (def: 256 bit)
  -- MASK Register
  MASK_SHREG : shiftreg
    generic map (
      REGWD => MASKLENGTH)
    port map (
      clk   => clk,
      rst_n => rst_n,
      ce    => MaskReg_ce,
      sin   => sso,
      pout  => MaskReg_o);

  MaskReg_ce <= ssovalid and MaskRegEnable;


-------------------------------------------------------------------------------
-- Counters
-------------------------------------------------------------------------------

  -- DataCnt
  DataCnt_i : COUNTERCLR
    generic map (
      width => 8)
    port map (
      clk    => clk,
      rst_n  => rst_n,
      en     => DataCnt_Inc,
      clear  => DataCnt_Clear,
      outcnt => DataCnt);

  -- PointerCnt
  PointerCnt_i : COUNTERCLR
    generic map (
      width => 8)
    port map (
      clk    => clk,
      rst_n  => rst_n,
      en     => PointerCnt_Inc,
      clear  => PointerCnt_Clear,
      outcnt => PointerCnt);

  -- RNCnt
  RNCnt_i : COUNTERCLR
    generic map (
      width => 8)
    port map (
      clk    => clk,
      rst_n  => rst_n,
      en     => RNCnt_Inc,
      clear  => RNCnt_Clear,
      outcnt => RNCnt);

  -- CRCCnt
  CRCCnt_i : COUNTERCLR
    generic map (
      width => 8)
    port map (
      clk    => clk,
      rst_n  => rst_n,
      en     => CRCCnt_Inc,
      clear  => CRCCnt_Clear,
      outcnt => CRCCnt);

-------------------------------------------------------------------------------
-- CRC 5 & 16
-------------------------------------------------------------------------------

  crc5encdec_i : crc5encdec
    generic map (
      PRESET_CRC5 => PRESET_CRC5)
    port map (
      clk   => clk,
      rst_n => rst_n,
      init  => CRC5Init,
      ce    => CRC5ce,
      sdi   => sso,
      cout  => CRC5Dec);

  CRC5ce <= ssovalid;


  crc16encdec_i : crc16encdec
    generic map (
      PRESET_CRC16 => PRESET_CRC16)
    port map (
      clk   => clk,
      rst_n => rst_n,
      init  => CRC16Init,
      ce    => CRC16ce,
      sdi   => sso,
      cout  => CRC16Dec);

  CRC16ce <= ssovalid;

-------------------------------------------------------------------------------
-- Output Signals
-------------------------------------------------------------------------------

  CommDone  <= CommandDone;
  Data_r    <= GPReg_o;
  CRC_r     <= CRC16_o;
  Pointer_r <= Pointer_o;
  RN16_r    <= RN16_o;
  Mask_r    <= MaskReg_o;
  Length_r  <= LengthWCnt_o;


-------------------------------------------------------------------------------
-- Symbol Decoder
-------------------------------------------------------------------------------
  SymbolDecoder_i : SymbolDecoder
    generic map (
      LOG2_10_TARI_CK_CYC        => LOG2_10_TARI_CK_CYC,
      DELIMITIER_TIME_CK_CYC_MIN => DELIMITIER_TIME_CK_CYC_MIN,
      DELIMITIER_TIME_CK_CYC_MAX => DELIMITIER_TIME_CK_CYC_MAX)
    port map (
      clk      => clk,
      rst_n    => rst_n,
      tdi      => tdi,
      en       => en,
      start    => StartSDec,
      sserror  => sserror,
      ssovalid => ssovalid,
      sso      => sso);


end CommandDec1;

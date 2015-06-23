-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - Tag main FSM
--
--     File name      : TagFSM.vhd 
--
--     Description    : Tag finite state machine (Mealy).     
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Tag Finite State Machine based on EPC Class 1 Gen 2 Air interface
--
-- The following requirements of the EPC document are not fully implemented.
--     -In the "Select" command, the comparison between the mask and any
--      portion of the memory does not work with bit precision. According        
--      to the EPC document, the comparison may start at any bit of any
--      portion of the memory. In this implementation, the comparison starts
--      with a word. It may, however, be of any length.
--     -In the "Select" command, the truncate bit is not currently
--      implemented and does not cause any effect.
--     -Kill and Access passwords are not implemented. So, the tag behaves
--      as though it had zero-valued passwords.
--     -Access command is not implemented.
--     -Kill and Lock commands are currently unavailable.
--      
-------------------------------------------------------------------------------   
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_ARITH.all;
library work;
use work.epc_tag.all;


entity TagFSM is
  generic(
    WordsRSV : integer := 8;
    WordsEPC : integer := 16;
    WordsTID : integer := 8;
    WordsUSR : integer := 256;
    AddrUSR  : integer := 5;            -- 1/2 memory address pins (maximum)
    Data     : integer := 16);          -- memory data width
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    -- Receiver
    CommDone  : in  CommandInternalCode_t;
    Data_r    : in  std_logic_vector(31 downto 0);
    Pointer_r : in  std_logic_vector(15 downto 0);
    RN16_r    : in  std_logic_vector(15 downto 0);
    Length_r  : in  std_logic_vector(7 downto 0);
    Mask_r    : in  std_logic_vector(MASKLENGTH-1 downto 0);
--  -- MCU
--    MCUComm    : out CommandMCU_t;
--    MCUCommVal : out std_logic;
--    MCURdy     : in  std_logic;
    -- Inventoried and Select flags
    SInvD     : out std_logic_vector(3 downto 0);  -- Flag input
    SelD      : out std_logic;
    SInvQ     : in  std_logic_vector(3 downto 0);  -- Flag output
    SelQ      : in  std_logic;
    SInvCE    : out std_logic_vector(3 downto 0);  -- Flag enable
    SelCE     : out std_logic;
    -- Random Number Generator
    rng_init  : out std_logic;
    rng_cin   : out std_logic_vector(30 downto 0);
    rng_ce    : out std_logic;
    rng_cout  : in  std_logic_vector(30 downto 0);
    -- Memory
    mem_WR    : out std_logic;
    mem_RD    : out std_logic;
    mem_RB    : in  std_logic;
    mem_BANK  : out std_logic_vector(1 downto 0);
    mem_ADR   : out std_logic_vector((2*AddrUSR)-1 downto 0);
    mem_DTI   : out std_logic_vector(Data-1 downto 0);
    mem_DTO   : in  std_logic_vector(Data-1 downto 0);
    -- Interrogator Response Timer Flag (T2) - see EPC Standard 1.09 p.34
    T2ExpFlag : in  std_logic;
    -- Transmitter Command and Output buffer
    trm_cmd   : out std_logic_vector(2 downto 0);
    trm_buf   : out std_logic_vector(15 downto 0)
    );

end TagFSM;

architecture TagFSM1 of TagFSM is

-------------------------------------------------------------------------------
-- DATA_r values according to received command
-------------------------------------------------------------------------------
  -- QUERY
  --    ___________________________________________________________
  --   |__DR__|__M__|__TRext__|__Sel__|__Session__|__Target__|__Q__|
  --    12     11    9         8       6           4          3    0

  -- QUERYREP
  --    ___________
  --   |__Session__|
  --    1          0    

  -- QUERYADJUST
  --    ____________________
  --   |__Session__|__UpDn__|
  --    4           2       0

  -- SELECT
  --    ______________________________________________
  --   |__Target__|__Action__|__MemBank__|__Truncate__|
  --    8          5          2            0

  -- READ
  --    ___________
  --   |__MemBank__|
  --    1          0

  -- WRITE
  --    _____________________________
  --   |__MemBank__|__Data xor RN16__|
  --    17          15               0


-------------------------------------------------------------------------------
-- Signals
-------------------------------------------------------------------------------

  -- Kill Flag & RNG initialization address (MSB)
  -- (LSB = MEMORY_KILL_RNG_ADDRESS_MSB + 1)
  constant MEMORY_KILL_RNG_ADDRESS_MSB : std_logic_vector((2*AddrUSR)-1 downto 0)   := (others => '0');
  constant RESERVED_MEMORY_BANK        : std_logic_vector(1 downto 0)               := "00";
  constant EPC_MEMORY_BANK             : std_logic_vector(1 downto 0)               := "01";
  constant MEMORY_PC_ADDRESS_16b       : std_logic_vector(15 downto 0)              := conv_std_logic_vector(1, 16);
  constant MEMORY_CRC16_ADDRESS        : std_logic_vector((2 * AddrUSR)-1 downto 0) := (others => '0');

  -- Error Codes
  constant NON_SPECIFIC_ERROR : std_logic_vector(15 downto 0) := X"00F0";

  -- Finite State Machine. [ st_STATE_COMMAND_DESCRIPTION ]
  type TagFSM_t is (st_PowerUp, st_PowerUp_GetFlagMSB, st_PowerUp_GetFlagLSB, st_PowerUp_LoadRNG,
                    -- Ready
                    st_Ready, st_Ready_QRY_LoadSlot_AND_SaveRN, st_Ready_QRY_CheckSlot_AND_SaveRN,
                    st_Ready_QRY_LoadRN16Handler_AND_SaveRN, st_Ready_QRY_BackscatterRN16_AND_SaveRN,
                    st_Ready_SEL_GetWord, st_Ready_SEL_NonMatchingTag, st_Ready_SEL_CompareWords,
                    st_Ready_SEL_CompareBits, st_Ready_SEL_PrepareComparison, st_Ready_SEL_MatchingTag,
                    -- Arbitrate
                    st_Arbitrate, st_Arbitrate_QRYQRA_LoadSlot_AND_SaveRN, st_Arbitrate_QRR_CheckSlot,
                    st_Arbitrate_QRYQRA_CheckSlot_AND_SaveRN,
                    -- Reply
                    st_Reply, st_Reply_ACK_SendPC_AND_DecodeEPCLength, st_Reply_ACK_GetPC,
                    st_Reply_ACK_GetAndSendEPC, st_Reply_ACK_GetAndSendCRC16,
                    -- Acknoledged
                    st_Acknowledged, st_Acknowledged_QRY_CheckFlags, st_Acknowledged_RRN_LoadHandler_AND_SaveRN,
                    st_Acknowledged_RRN_BackscatterHandler_AND_SaveRN,
                    -- Open
                    st_Open, st_Open_ACK_GetPC, st_Open_ACK_SendPC_AND_DecodeEPCLength,
                    st_Open_ACK_GetAndSendEPC, st_Open_ACK_GetAndSendCRC16,
                    st_Open_RRN_LoadHandler_AND_SaveRN, st_Open_RRN_BackscatterHandler_AND_SaveRN,
                    -- Secured
                    st_Secured, st_Secured_ACK_GetPC, st_Secured_ACK_SendPC_AND_DecodeEPCLength,
                    st_Secured_ACK_GetAndSendEPC, st_Secured_ACK_GetAndSendCRC16,
                    st_Secured_RRN_LoadHandler_AND_SaveRN, st_Secured_RRN_BackscatterHandler_AND_SaveRN,
                    st_Secured_WR_CheckMemoryBounds, st_Secured_WR_WriteWord, st_Secured_WR_WriteIsDone,
                    st_Secured_RD_CheckMemoryBounds, st_Secured_RD_ReadMemory, st_Secured_RD_Read_AND_Send,
                    st_Secured_RD_SendLast, st_Secured_RD_SendHandle,
                    -- Killed
                    st_Killed);
  signal StTag, NextStTag                 : TagFSM_t;
  signal KillFlag, SlotIsZero             : std_logic;
  signal Query_InventoryFlag_Match        : std_logic;
  signal Query_SelectFlag_Match           : std_logic;
  signal Slot, Slot_i                     : std_logic_vector(15 downto 0);
  signal GPR, GPR_i                       : std_logic_vector(31 downto 0);  -- general purpose register
  signal RN16Handler, RN16Handler_i       : std_logic_vector(15 downto 0);
  signal CurrSession, CurrSession_i       : std_logic_vector(1 downto 0);
  signal CurrQ, CurrQ_i                   : std_logic_vector(3 downto 0);
  signal Select_Address_Pointer_Length_OK : std_logic;
  signal Select_Address_Bounds_OK         : std_logic;
  signal Write_Address_Pointer_Length_OK  : std_logic;
  signal Write_Address_Bounds_OK          : std_logic;
  signal Read_Address_Pointer_Length_OK   : std_logic;
  signal Read_Address_Bounds_OK           : std_logic;
  signal GCounter, GCounter_i             : std_logic_vector(7 downto 0);
  signal GCounter2, Gcounter2_i           : std_logic_vector(7 downto 0);
  signal FirstCompWord, FirstCompWord_i   : std_logic;
  signal ComparisonReg, ComparisonReg_i   : std_logic_vector(Data-1 downto 0);
  signal ADRint, ADRint_i                 : std_logic_vector(15 downto 0);

  signal GPR_AFTER_COMPARISON_MUX       : std_logic_vector(15 downto 0);
  signal MASK_AFTER_COMPARISON_BIT_MUX      : std_logic_vector(15 downto 0);
  signal MASK_AFTER_FIRSTCOMPARISON_MUX : std_logic_vector(15 downto 0);
  signal SLOT_VALUE : std_logic_vector(15 downto 0);

  signal SelD_i, SelCE_i   : std_logic;
  signal SInvD_i, SInvCE_i : std_logic_vector(3 downto 0);

  signal trm_cmd_i : std_logic_vector(2 downto 0);
  signal trm_buf_i : std_logic_vector(15 downto 0);

  -- Memory Signals
  signal mem_WR_i, mem_RD_i   : std_logic;
  signal mem_ADR_i            : std_logic_vector((2*AddrUSR)-1 downto 0);
  signal mem_DTI_i            : std_logic_vector(Data-1 downto 0);
  signal mem_BANK_i           : std_logic_vector(1 downto 0);
  -- RNG signals
  signal rng_cin_i            : std_logic_vector(30 downto 0);
  signal rng_init_i, rng_ce_i : std_logic;


begin  -- TagFSM1

  SYNCRO : process (clk, rst_n)
  begin  -- process SYNCRO
    if rst_n = '0' then                 -- asynchronous reset (active low)
      -- FSM
      StTag         <= st_PowerUp;
      -- General Purpose Register
      GPR           <= (others => '0');
      -- Slot Register
      Slot          <= (others => '1');
      -- RN16 & Handler Register
      RN16Handler   <= (others => '0');
      -- Memory signals
      mem_WR        <= '0';
      mem_RD        <= '0';
      mem_ADR       <= (others => '0');
      mem_DTI       <= (others => '0');
      mem_BANK      <= (others => '0');
      ADRint        <= (others => '0');
      -- RNG signals
      rng_cin       <= (others => '0');
      rng_init      <= '0';
      rng_ce        <= '0';
      -- Internal signals and Flags
      CurrSession   <= "00";
      CurrQ         <= (others => '0');
      FirstCompWord <= '0';
      ComparisonReg <= (others => '0');
      -- Counters
      GCounter      <= (others => '0');
      GCounter2     <= (others => '0');
      -- Transmitter
      trm_cmd       <= trmcmd_Null;
      trm_buf       <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- FSM
      StTag         <= NextStTag;
      -- General Purpose Register
      GPR           <= GPR_i;
      -- Slot Register
      Slot          <= Slot_i;
      -- RN16 & Handler Register
      RN16Handler   <= RN16Handler_i;
      -- Memory signals
      mem_WR        <= mem_WR_i;
      mem_RD        <= mem_RD_i;
      mem_ADR       <= mem_ADR_i;
      mem_DTI       <= mem_DTI_i;
      mem_BANK      <= mem_BANK_i;
      ADRint        <= ADRint_i;
      -- RNG signals
      rng_init      <= rng_init_i;
      rng_cin       <= rng_cin_i;
      rng_ce        <= rng_ce_i;
      -- Internal signals and Flags
      CurrSession   <= CurrSession_i;
      CurrQ         <= CurrQ_i;
      FirstCompWord <= FirstCompWord_i;
      ComparisonReg <= ComparisonReg_i;
      -- Counters
      GCounter      <= GCounter_i;
      GCounter2     <= GCounter2_i;
      -- Transmitter
      trm_cmd       <= trm_cmd_i;
      trm_buf       <= trm_buf_i;
    end if;
  end process SYNCRO;


-------------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- NEXT STATE PROCESS
-----------------------------------------------------------------------------
-------------------------------------------------------------------------------
  NEXT_ST : process (StTag, CommDone, mem_RB, mem_DTO, Query_SelectFlag_Match, Query_InventoryFlag_Match, SlotIsZero,
                     Select_Address_Pointer_Length_OK, GPR, T2ExpFlag, RN16Handler, Write_Address_Pointer_Length_OK,
                     Read_Address_Pointer_Length_OK, GCounter, MASK_AFTER_FIRSTCOMPARISON_MUX, MASK_AFTER_COMPARISON_BIT_MUX,
                     GPR_AFTER_COMPARISON_MUX, CurrSession, Data_r, RN16_r)
  begin  -- process NEXT_ST
    NextStTag <= StTag;
    case StTag is
      -------------------------------------------------------------------------
      -- POWERUP        (in next state process)
      -------------------------------------------------------------------------
      when st_PowerUp =>
        if mem_RB = '1' then
          NextStTag <= st_PowerUp_GetFlagMSB;
        end if;
      when st_PowerUp_GetFlagMSB =>
        if mem_RB = '1' then
          if mem_DTO(15) = '1' then     -- KILL flag!
            NextStTag <= st_Killed;
          else
            NextStTag <= st_PowerUp_GetFlagLSB;
          end if;
        end if;
      when st_PowerUp_GetFlagLSB =>
        if mem_RB = '1' then
          NextStTag <= st_PowerUp_LoadRNG;
        end if;
      when st_PowerUp_LoadRNG =>
        NextStTag <= st_Ready;
        -----------------------------------------------------------------------
        -- READY        (in next state process)       
        -----------------------------------------------------------------------
      when st_Ready =>
        if CommDone = cmd_Query then
          -- Check for matching Inventoried and SL flags
          if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1'then
            NextStTag <= st_Ready_QRY_LoadSlot_AND_SaveRN;
          end if;
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            NextStTag <= st_Ready_SEL_GetWord;
          else
            NextStTag <= st_Ready_SEL_NonMatchingTag;
          end if;
        end if;

      when st_Ready_QRY_LoadSlot_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Ready_QRY_CheckSlot_AND_SaveRN;
        end if;

      when st_Ready_QRY_CheckSlot_AND_SaveRN =>
        if mem_RB = '1' then
          if SlotIsZero = '1' then
            NextStTag <= st_Ready_QRY_LoadRN16Handler_AND_SaveRN;
          else
            NextStTag <= st_Arbitrate;
          end if;
        end if;

      when st_Ready_QRY_LoadRN16Handler_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Ready_QRY_BackscatterRN16_AND_SaveRN;
        end if;

      when st_Ready_QRY_BackscatterRN16_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Reply;
        end if;

        -- NOTE: Select command does not support
        -- "bit" comparison. Comparison starts at
        -- the beginning of a Word!!  
      when st_Ready_SEL_GetWord =>
        if mem_RB = '1' then
          NextStTag <= st_Ready_SEL_CompareWords;
        end if;

      when st_Ready_SEL_PrepareComparison =>
        if mem_RB = '1' then
          if unsigned(GCounter) < Data then
            NextStTag <= st_Ready_SEL_CompareBits;
          else
            NextStTag <= st_Ready_SEL_CompareWords;
          end if;
        end if;

      when st_Ready_SEL_CompareWords =>
   --if Mask_r((GCounter2)+15 downto conv_integer(unsigned(GCounter2))) = GPR(15 downto 0) then       
        if MASK_AFTER_FIRSTCOMPARISON_MUX = GPR(15 downto 0) then
          NextStTag <= st_Ready_SEL_GetWord;
        else
          NextStTag <= st_Ready_SEL_NonMatchingTag;
        end if;

      when st_Ready_SEL_CompareBits =>
--        if Mask_r(conv_integer(unsigned(GCounter2))+conv_integer(unsigned(GCounter))-1 downto conv_integer(unsigned(GCounter2))) = GPR(conv_integer(unsigned(GCounter))-1 downto 0) then
        if MASK_AFTER_COMPARISON_BIT_MUX = GPR_AFTER_COMPARISON_MUX then
          NextStTag <= st_Ready_SEL_MatchingTag;
        else
          NextStTag <= st_Ready_SEL_NonMatchingTag;
        end if;

      when st_Ready_SEL_NonMatchingTag =>
        NextStTag <= st_Ready;

      when st_Ready_SEL_MatchingTag =>
        NextStTag <= st_Ready;

        -----------------------------------------------------------------------
        -- ARBITRATE    (in next state process)
        -----------------------------------------------------------------------
      when st_Arbitrate =>
        -- Query command, in the Arbitrate state, behaves as in the Ready state
        if CommDone = cmd_Query then
          if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1'then
            NextStTag <= st_Ready_QRY_LoadSlot_AND_SaveRN;
          else
            NextStTag <= st_Ready;
          end if;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            NextStTag <= st_Arbitrate_QRR_CheckSlot;
          end if;
          -- After Adjusting Q, the behavior of a QueryAdjust command
          -- is the same as the Query Command.
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            if Data_r(2 downto 0) = "000" or Data_r(2 downto 0) = "110" or Data_r(2 downto 0) = "011" then
              NextStTag <= st_Ready_QRY_LoadSlot_AND_SaveRN;
            end if;
          end if;
          -- Select Command behaves always as in the Ready state!
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            NextStTag <= st_Ready_SEL_GetWord;
          else
            NextStTag <= st_Ready_SEL_NonMatchingTag;
          end if;
        end if;

      when st_Arbitrate_QRR_CheckSlot =>
        if SlotIsZero = '1' then
          NextStTag <= st_Ready_QRY_LoadRN16Handler_AND_SaveRN;
        else
          NextStTag <= st_Arbitrate;
        end if;

        -----------------------------------------------------------------------
        -- REPLY    (in next state process)
        -----------------------------------------------------------------------
      when st_Reply =>
        -- If interrogator reponse time expires, tag exits the Reply state
        if T2ExpFlag = '1' then
          NextStTag <= st_Arbitrate;
        end if;
        -- Query command, in the Reply state, behaves as in the Ready state
        if CommDone = cmd_Query then
          if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1'then
            NextStTag <= st_Ready_QRY_LoadSlot_AND_SaveRN;
          else
            NextStTag <= st_Ready;
          end if;
          -- QueryRep behaves as in the Arbitrate state
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            NextStTag <= st_Arbitrate_QRR_CheckSlot;
          end if;
          -- After Adjusting Q, the behavior of a QueryAdjust command
          -- is the same as the Query Command.
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            if Data_r(2 downto 0) = "000" or Data_r(2 downto 0) = "110" or Data_r(2 downto 0) = "011" then
              NextStTag <= st_Ready_QRY_LoadSlot_AND_SaveRN;
            end if;
          end if;
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            NextStTag <= st_Reply_ACK_GetPC;
          else
            NextStTag <= st_Arbitrate;
          end if;
        elsif CommDone = cmd_Nak then
          NextStTag <= st_Arbitrate;
          -- Select Command behaves always as in the Ready state!
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            NextStTag <= st_Ready_SEL_GetWord;
          else
            NextStTag <= st_Ready_SEL_NonMatchingTag;
          end if;
        elsif (CommDone = cmd_Invalid) or (CommDone = cmd_NULL) then
          NextStTag <= st_Reply;
        else
          NextStTag <= st_Arbitrate;
        end if;

      when st_Reply_ACK_GetPC =>
        if mem_RB = '1' then
          NextStTag <= st_Reply_ACK_SendPC_AND_DecodeEPCLength;
        end if;

      when st_Reply_ACK_SendPC_AND_DecodeEPCLength =>
        if mem_RB = '1' then
          NextStTag <= st_Reply_ACK_GetAndSendEPC;
        end if;

      when st_Reply_ACK_GetAndSendEPC =>
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            NextStTag <= st_Reply_ACK_GetAndSendEPC;
          else
            NextStTag <= st_Reply_ACK_GetAndSendCRC16;
          end if;
        end if;

      when st_Reply_ACK_GetAndSendCRC16 =>
        if mem_RB = '1' then
          NextStTag <= st_Acknowledged;
        end if;

        -----------------------------------------------------------------------
        -- ACKNOWLEDGED    (in next state process)
        -----------------------------------------------------------------------
      when st_Acknowledged =>
        -- If interrogator reponse time expires, tag exits the Acknowledged state
        if T2ExpFlag = '1' then
          NextStTag <= st_Arbitrate;
        end if;
        if CommDone = cmd_Query then
          NextStTag <= st_Acknowledged_QRY_CheckFlags;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            NextStTag <= st_Ready;
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            NextStTag <= st_Ready;
          end if;
          -- Ack Command is the same as in the Reply state.
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            NextStTag <= st_Reply_ACK_GetPC;
          else
            NextStTag <= st_Arbitrate;
          end if;
        elsif CommDone = cmd_Nak then
          NextStTag <= st_Arbitrate;
        elsif CommDone = cmd_ReqRN then
          if RN16_r = RN16Handler then
            NextStTag <= st_Acknowledged_RRN_LoadHandler_AND_SaveRN;
          end if;
          -- Select Command behaves always as in the Ready state!
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            NextStTag <= st_Ready_SEL_GetWord;
          else
            NextStTag <= st_Ready_SEL_NonMatchingTag;
          end if;
        elsif (CommDone = cmd_Invalid) or (CommDone = cmd_NULL) then
          NextStTag <= st_Acknowledged;
        else
          NextStTag <= st_Arbitrate;
        end if;

      when st_Acknowledged_QRY_CheckFlags =>
        -- Query Command in the Acknowledged state is almost the same as in the
        -- Ready state. The difference is that the inventoried flags may change
        -- (if the session is the same) before evaluating the Query condition.
        if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1'then
          NextStTag <= st_Ready_QRY_LoadSlot_AND_SaveRN;
        else
          NextStTag <= st_Ready;
        end if;

      when st_Acknowledged_RRN_LoadHandler_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Acknowledged_RRN_BackscatterHandler_AND_SaveRN;
        end if;

      when st_Acknowledged_RRN_BackscatterHandler_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Secured;
        end if;

        -----------------------------------------------------------------------
        -- OPEN         (in next state process)
        -----------------------------------------------------------------------
      when st_Open =>
        -- Query in Open = Query in Acknowledged
        if CommDone = cmd_Query then
          NextStTag <= st_Acknowledged_QRY_CheckFlags;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            NextStTag <= st_Ready;
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            NextStTag <= st_Ready;
          end if;
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            NextStTag <= st_Open_ACK_GetPC;
          else
            NextStTag <= st_Arbitrate;
          end if;
        elsif CommDone = cmd_Nak then
          NextStTag <= st_Arbitrate;
        elsif CommDone = cmd_ReqRN then
          if RN16_r = RN16Handler then
            NextStTag <= st_Open_RRN_LoadHandler_AND_SaveRN;
          end if;
          -- Select Command behaves always as in the Ready state!
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            NextStTag <= st_Ready_SEL_GetWord;
          else
            NextStTag <= st_Ready_SEL_NonMatchingTag;
          end if;
-- elsif CommDone = cmd_Kill then       -- See kill flowchart pg.60 (EPC Standard)
--          if "Valid handle" then
--            if "Kill Password != 0" then
--              if "Valid Kill Password" then
--                NextStTag <= st_Killed;
--              else
--                NextStTag <= st_Arbitrate;
--              end if;
--            end if;
--          end if;
--        elsif CommDone = cmd_Access then  -- See Access flowchart pg.63 (EPC Standard)
--          if "Valid Handle" then
--            if "Valid Access Password" then
--              NextStTag <= st_Secured;
--            else
--              NextStTag <= st_Arbitrate;
--            end if;
--          end if;
        elsif CommDone = cmd_Invalid then  -- See state & note pg.73
          NextStTag <= st_Arbitrate;
        end if;

      when st_Open_RRN_LoadHandler_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Open_RRN_BackscatterHandler_AND_SaveRN;
        end if;

      when st_Open_RRN_BackscatterHandler_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Open;
        end if;

      when st_Open_ACK_GetPC =>
        if mem_RB = '1' then
          NextStTag <= st_Open_ACK_SendPC_AND_DecodeEPCLength;
        end if;

      when st_Open_ACK_SendPC_AND_DecodeEPCLength =>
        if mem_RB = '1' then
          NextStTag <= st_Open_ACK_GetAndSendEPC;
        end if;

      when st_Open_ACK_GetAndSendEPC =>
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            NextStTag <= st_Open_ACK_GetAndSendEPC;
          else
            NextStTag <= st_Open_ACK_GetAndSendCRC16;
          end if;
        end if;

      when st_Open_ACK_GetAndSendCRC16 =>
        if mem_RB = '1' then
          NextStTag <= st_Open;
        end if;

        -----------------------------------------------------------------------
        -- SECURED    (in next state process)
        -----------------------------------------------------------------------
      when st_Secured =>
        -- Query in Secured = Query in Acknowledged
        if CommDone = cmd_Query then
          NextStTag <= st_Acknowledged_QRY_CheckFlags;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            NextStTag <= st_Ready;
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            NextStTag <= st_Ready;
          end if;
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            NextStTag <= st_Secured_ACK_GetPC;
          else
            NextStTag <= st_Arbitrate;
          end if;
        elsif CommDone = cmd_Nak then
          NextStTag <= st_Arbitrate;
        elsif CommDone = cmd_ReqRN then
          if RN16_r = RN16Handler then
            NextStTag <= st_Secured_RRN_LoadHandler_AND_SaveRN;
          end if;
          -- Select Command behaves always as in the Ready state!
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            NextStTag <= st_Ready_SEL_GetWord;
          else
            NextStTag <= st_Ready_SEL_NonMatchingTag;
          end if;
        elsif CommDone = cmd_Write then
          if RN16_r = RN16Handler then
            NextStTag <= st_Secured_WR_CheckMemoryBounds;
          end if;
        elsif CommDone = cmd_Read then
          if RN16_r = RN16Handler then
            NextStTag <= st_Secured_RD_CheckMemoryBounds;
          end if;
-- elsif CommDone = cmd_Kill then       -- See kill flowchart pg.60 (EPC Standard)
--          if "Valid handle" then
--            if "Kill Password != 0" then
--              if "Valid Kill Password" then
--                NextStTag <= st_Killed;
--              else
--                NextStTag <= st_Arbitrate;
--              end if;
--            end if;
--          end if;
--        elsif CommDone = cmd_Access then  -- See Access flowchart pg.63 (EPC Standard)
--          if "Valid Handle" then
--            if "Valid Access Password" then
--              NextStTag <= st_Secured;
--            else
--              NextStTag <= st_Arbitrate;
--            end if;
--          end if;
        elsif CommDone = cmd_Invalid then  -- See state & note pg.74
          NextStTag <= st_Arbitrate;
        end if;

      when st_Secured_RRN_LoadHandler_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Secured_RRN_BackscatterHandler_AND_SaveRN;
        end if;

      when st_Secured_RRN_BackscatterHandler_AND_SaveRN =>
        if mem_RB = '1' then
          NextStTag <= st_Secured;
        end if;

      when st_Secured_ACK_GetPC =>
        if mem_RB = '1' then
          NextStTag <= st_Secured_ACK_SendPC_AND_DecodeEPCLength;
        end if;

      when st_Secured_ACK_SendPC_AND_DecodeEPCLength =>
        if mem_RB = '1' then
          NextStTag <= st_Secured_ACK_GetAndSendEPC;
        end if;

      when st_Secured_ACK_GetAndSendEPC =>
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            NextStTag <= st_Secured_ACK_GetAndSendEPC;
          else
            NextStTag <= st_Secured_ACK_GetAndSendCRC16;
          end if;
        end if;

      when st_Secured_ACK_GetAndSendCRC16 =>
        if mem_RB = '1' then
          NextStTag <= st_Secured;
        end if;

      when st_Secured_WR_CheckMemoryBounds =>
        if Write_Address_Pointer_Length_OK = '1' then
          NextStTag <= st_Secured_WR_WriteWord;
        else
          NextStTag <= st_Secured;
        end if;

      when st_Secured_WR_WriteWord =>
        if mem_RB = '1' then
          NextStTag <= st_Secured_WR_WriteIsDone;
        end if;

      when st_Secured_WR_WriteIsDone =>
        if mem_RB = '1' then
          NextStTag <= st_Secured;
        end if;

      when st_Secured_RD_CheckMemoryBounds =>
        if Read_Address_Pointer_Length_OK = '1' then
          NextStTag <= st_Secured_RD_ReadMemory;
        else
          NextStTag <= st_Secured;
        end if;

      when st_Secured_RD_ReadMemory =>
        if mem_RB = '1' then
          NextStTag <= st_Secured_RD_Read_AND_Send;
        end if;

      when st_Secured_RD_Read_AND_Send =>
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            NextStTag <= st_Secured_RD_Read_AND_Send;
          else
            NextStTag <= st_Secured_RD_SendLast;
          end if;
        end if;

      when st_Secured_RD_SendLast =>
        if mem_RB = '1' then
          NextStTag <= st_Secured_RD_SendHandle;
        end if;

      when st_Secured_RD_SendHandle =>
        NextStTag <= st_Secured;

        -----------------------------------------------------------------------
        -- KILLED    (in next state process)
        -----------------------------------------------------------------------
      when st_Killed =>
        NextStTag <= st_Killed;

      when others => null;
    end case;
  end process NEXT_ST;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- OUTPUT DECODER PROCESS
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  OUTPUT_DEC : process (StTag, CommDone, mem_RB, RN16Handler, GPR, Slot, CurrSession, CurrQ, mem_DTO, Query_SelectFlag_Match,
                        Query_InventoryFlag_Match, Select_Address_Pointer_Length_OK, SlotIsZero, Write_Address_Pointer_Length_OK,
                        Read_Address_Pointer_Length_OK, Data_r, Pointer_r, Length_r, SLOT_VALUE, rng_cout, GCounter2, GCounter,
                        ADRint, SelQ, RN16_r, SInvQ)
  begin  -- process OUTPUT_DEC
    RN16Handler_i   <= RN16Handler;
    GPR_i           <= GPR;
    Slot_i          <= Slot;
    mem_DTI_i       <= (others => '0');
    mem_WR_i        <= '0';
    mem_RD_i        <= '0';
    mem_ADR_i       <= (others => '0');
    mem_BANK_i      <= (others => '0');
    rng_cin_i       <= (others => '0');
    rng_init_i      <= '0';
    rng_ce_i        <= '0';
    CurrSession_i   <= CurrSession;
    CurrQ_i         <= CurrQ;
    FirstCompWord_i <= '0';
    GCounter_i      <= (others => '0');
    GCounter2_i     <= (others => '0');
    ADRint_i        <= (others => '0');
    -- SEL & Inventory Flags
    SelD            <= '0';
    SelCE           <= '0';
    SInvD           <= (others => '0');
    SInvCE          <= (others => '0');
    -- Transmitter
    trm_cmd_i       <= trmcmd_Null;
    trm_buf_i       <= (others => '0');

    case StTag is
      -----------------------------------------------------------------------
      -- POWERUP    (in output process)
      -----------------------------------------------------------------------
      when st_PowerUp =>
        if mem_RB = '1' then
          mem_ADR_i  <= MEMORY_KILL_RNG_ADDRESS_MSB;
          mem_BANK_i <= RESERVED_MEMORY_BANK;
          mem_RD_i   <= '1';
        end if;

      when st_PowerUp_GetFlagMSB =>
        if mem_RB = '1' then
          GPR_i(31 downto 16) <= mem_DTO;
          mem_ADR_i           <= MEMORY_KILL_RNG_ADDRESS_MSB + '1';
          mem_BANK_i          <= RESERVED_MEMORY_BANK;
          mem_RD_i            <= '1';
        end if;

      when st_PowerUp_GetFlagLSB =>
        if mem_RB = '1' then
          GPR_i(15 downto 0) <= mem_DTO;
        end if;

      when st_PowerUp_LoadRNG =>
        rng_init_i <= '1';
        rng_cin_i  <= GPR(30 downto 0);
        -----------------------------------------------------------------------
        -- READY    (in output process)
        -----------------------------------------------------------------------
      when st_Ready =>
        if CommDone = cmd_Query then
          if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1' then
            rng_ce_i      <= '1';       -- Prepare new RN
            CurrSession_i <= Data_r(6 downto 5);
            CurrQ_i       <= Data_r(3 downto 0);
          end if;
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            ADRint_i(11 downto 0) <= Pointer_r(15 downto 4);
            --       CompLSBit_i <= Pointer_r(3 downto 0);
            GCounter_i            <= Length_r;
          end if;
        end if;

      when st_Ready_QRY_LoadSlot_AND_SaveRN =>
        if mem_RB = '1' then
          Slot_i     <= SLOT_VALUE;
          mem_DTI_i  <= rng_cout(15 downto 0);
          mem_ADR_i  <= MEMORY_KILL_RNG_ADDRESS_MSB + '1';
          mem_BANK_i <= RESERVED_MEMORY_BANK;
          mem_WR_i   <= '1';
        end if;

      when st_Ready_QRY_CheckSlot_AND_SaveRN =>
        if mem_RB = '1' then
          mem_DTI_i  <= '0' & rng_cout(30 downto 16);
          mem_ADR_i  <= MEMORY_KILL_RNG_ADDRESS_MSB;
          mem_BANK_i <= RESERVED_MEMORY_BANK;
          mem_WR_i   <= '1';
          if SlotIsZero = '1' then
            rng_ce_i <= '1';            -- Prepare new RN
          end if;
        end if;

      when st_Ready_QRY_LoadRN16Handler_AND_SaveRN =>
        if mem_RB = '1' then
          RN16Handler_i <= rng_cout(15 downto 0);
          mem_DTI_i     <= rng_cout(15 downto 0);
          mem_ADR_i     <= MEMORY_KILL_RNG_ADDRESS_MSB + '1';
          mem_BANK_i    <= RESERVED_MEMORY_BANK;
          mem_WR_i      <= '1';
        end if;

      when st_Ready_QRY_BackscatterRN16_AND_SaveRN =>
        if mem_RB = '1' then
          mem_DTI_i  <= '0' & rng_cout(30 downto 16);
          mem_ADR_i  <= MEMORY_KILL_RNG_ADDRESS_MSB;
          mem_BANK_i <= RESERVED_MEMORY_BANK;
          mem_WR_i   <= '1';
          -- Backscatter RN16
          trm_cmd_i  <= trmcmd_Send;
          trm_buf_i  <= RN16Handler;
        end if;

        -- NOTE: Select command does not support
        -- "bit" comparison. Comparison starts at
        -- the beginning of a Word!!  
      when st_Ready_SEL_GetWord =>
        GCounter2_i <= GCounter2;       -- Number of bits already compared
        GCounter_i  <= GCounter;        -- Number of bits to compare
        ADRint_i    <= ADRint;
-- CompLSBit_i <= CompLSBit;            -- Starting bits (unused within this version)
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_BANK_i <= Data_r(2 downto 1);
          mem_RD_i   <= '1';
        end if;

      when st_Ready_SEL_PrepareComparison =>
        GCounter2_i <= GCounter2;            -- Number of bits already compared
        GCounter_i  <= GCounter;             -- Number of bits to compare
        ADRint_i    <= ADRint;
        if mem_RB = '1' then
          ADRint_i           <= ADRint + 1;  -- prepare next word address
          GPR_i(15 downto 0) <= mem_DTO;
        end if;

      when st_Ready_SEL_CompareWords =>
        GCounter2_i <= GCounter2 + conv_std_logic_vector(16, 8);  -- Number of bits already compared
        GCounter_i  <= GCounter - conv_std_logic_vector(16, 8);  -- Number of Bits to compare
        ADRint_i    <= ADRint;

      when st_Ready_SEL_CompareBits =>
        GCounter2_i <= GCounter2 + conv_std_logic_vector(unsigned(GCounter), 8);  -- Number of bits already compared
        GCounter_i  <= GCounter - conv_std_logic_vector(unsigned(GCounter), 8);  -- Number of Bits to compare
        ADRint_i    <= ADRint;

      when st_Ready_SEL_MatchingTag =>
        case Data_r(5 downto 3) is      -- Action
          when "000" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '1';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '0';  -- -> A
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "001" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '1';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '0';  -- -> A
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "011" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= not(SelQ);
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= not(SInvQ(conv_integer(Data_r(7 downto 6))));  -- -> negate
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "100" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '0';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '1';  -- -> B
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "101" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '0';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '1';  -- -> B
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when others => null;
        end case;

      when st_Ready_SEL_NonMatchingTag =>
        case Data_r(5 downto 3) is      -- Action
          when "000" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '0';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '1';  -- -> B
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "010" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '0';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '1';  -- -> B
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "100" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '1';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '0';  -- -> A
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "110" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= '1';
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= '0';  -- -> A
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when "111" =>
            if Data_r(8) = '1' then
              if Data_r(7 downto 6) = "00" then
                SelD  <= not(SelQ);
                SelCE <= '1';
              end if;
            else
              SInvD(conv_integer(Data_r(7 downto 6)))  <= not(SInvQ(conv_integer(Data_r(7 downto 6))));  -- -> negate
              SInvCE(conv_integer(Data_r(7 downto 6))) <= '1';
            end if;
          when others => null;
        end case;
        -----------------------------------------------------------------------
        -- ARBITRATE    (in output process)
        -----------------------------------------------------------------------
      when st_Arbitrate =>
        if CommDone = cmd_Query then
          if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1' then
            rng_ce_i      <= '1';       -- Prepare new RN
            CurrSession_i <= Data_r(6 downto 5);
            CurrQ_i       <= Data_r(3 downto 0);
          end if;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            Slot_i <= Slot - '1';
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            if Data_r(2 downto 0) = "000" then                  -- Q = Q
              rng_ce_i <= '1';          -- Prepare new RN
            elsif Data_r(2 downto 0) = "110"then                -- Q = Q + 1
              rng_ce_i <= '1';          -- Prepare new RN
              if CurrQ /= "1111" then
                CurrQ_i <= CurrQ + '1';
              end if;
            elsif Data_r(2 downto 0) = "011" then               -- Q = Q - 1
              rng_ce_i <= '1';          -- Prepare new RN
              if CurrQ /= "0000" then
                CurrQ_i <= CurrQ - '1';
              end if;
            end if;
          end if;
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            ADRint_i(11 downto 0) <= Pointer_r(15 downto 4);
            --     CompLSBit_i <= Pointer_r(3 downto 0);
            GCounter_i            <= Length_r;
          end if;
        end if;

      when st_Arbitrate_QRR_CheckSlot =>
        if SlotIsZero = '1' then
          rng_ce_i <= '1';              -- Prepare new RN
        end if;

        -----------------------------------------------------------------------
        -- REPLY    (in output process)
        -----------------------------------------------------------------------
      when st_Reply =>
        if CommDone = cmd_Query then
          if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1' then
            rng_ce_i      <= '1';                  -- Prepare new RN
            CurrSession_i <= Data_r(6 downto 5);
            CurrQ_i       <= Data_r(3 downto 0);
          end if;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            Slot_i <= Slot - '1';
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            if Data_r(2 downto 0) = "000" then     -- Q = Q
              rng_ce_i <= '1';                     -- Prepare new RN
            elsif Data_r(2 downto 0) = "110"then   -- Q = Q + 1
              rng_ce_i <= '1';                     -- Prepare new RN
              if CurrQ /= "1111" then
                CurrQ_i <= CurrQ + '1';
              end if;
            elsif Data_r(2 downto 0) = "011" then  -- Q = Q - 1
              rng_ce_i <= '1';                     -- Prepare new RN
              if CurrQ /= "0000" then
                CurrQ_i <= CurrQ - '1';
              end if;
            end if;
          end if;
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            ADRint_i(11 downto 0) <= Pointer_r(15 downto 4);
            -- CompLSBit_i <= Pointer_r(3 downto 0);
            GCounter_i            <= Length_r;
          end if;
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            ADRint_i <= MEMORY_PC_ADDRESS_16b;
          end if;
        end if;

      when st_Reply_ACK_GetPC =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_BANK_i <= EPC_MEMORY_BANK;
          mem_RD_i   <= '1';
          ADRint_i   <= ADRint + '1';
          GPR_i      <= (others => '0');
        end if;

      when st_Reply_ACK_SendPC_AND_DecodeEPCLength =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_BANK_i <= EPC_MEMORY_BANK;
          ADRint_i   <= ADRint + '1';
          mem_RD_i   <= '1';
-- GPR_i(4 downto 0) <= mem_DTO(0 to 4);  --Length of the PC+EPC (in words)
          GPR_i(4)   <= mem_DTO(0);
          GPR_i(3)   <= mem_DTO(1);
          GPR_i(2)   <= mem_DTO(2);
          GPR_i(1)   <= mem_DTO(3);
          GPR_i(0)   <= mem_DTO(4);
          trm_cmd_i  <= trmcmd_Send;
          trm_buf_i  <= mem_DTO;
        end if;

      when st_Reply_ACK_GetAndSendEPC =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
            mem_BANK_i <= EPC_MEMORY_BANK;
            ADRint_i   <= ADRint + '1';
            mem_RD_i   <= '1';
            GPR_i      <= GPR - '1';
            trm_cmd_i  <= trmcmd_Send;
            trm_buf_i  <= mem_DTO;
          else
            mem_ADR_i  <= MEMORY_CRC16_ADDRESS;
            mem_BANK_i <= EPC_MEMORY_BANK;
            mem_RD_i   <= '1';
          end if;
        end if;

      when st_Reply_ACK_GetAndSendCRC16 =>
        if mem_RB = '1' then
          trm_cmd_i <= trmcmd_Send;
          trm_buf_i <= mem_DTO;
        end if;

        -----------------------------------------------------------------------
        -- ACKNOWLEDGED    (in output process)
        -----------------------------------------------------------------------
      when st_Acknowledged =>
        if CommDone = cmd_Query then
          if Data_r(6 downto 5) = CurrSession then  --TODO: Verify flags refresh in one clockcycle.  -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            ADRint_i <= MEMORY_PC_ADDRESS_16b;
          end if;
        elsif CommDone = cmd_ReqRN then
          if RN16_r = RN16Handler then
            rng_ce_i <= '1';            -- Prepare new RN
          end if;
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            ADRint_i(11 downto 0) <= Pointer_r(15 downto 4);
            --  CompLSBit_i <= Pointer_r(3 downto 0);
            GCounter_i            <= Length_r;
          end if;
        end if;

      when st_Acknowledged_QRY_CheckFlags =>
        if Query_SelectFlag_Match = '1' and Query_InventoryFlag_Match = '1' then
          rng_ce_i      <= '1';         -- Prepare new RN
          CurrSession_i <= Data_r(6 downto 5);
          CurrQ_i       <= Data_r(3 downto 0);
        end if;

      when st_Acknowledged_RRN_LoadHandler_AND_SaveRN =>
        if mem_RB = '1' then
          RN16Handler_i <= rng_cout(15 downto 0);
          mem_DTI_i     <= rng_cout(15 downto 0);
          mem_ADR_i     <= MEMORY_KILL_RNG_ADDRESS_MSB + '1';
          mem_BANK_i    <= RESERVED_MEMORY_BANK;
          mem_WR_i      <= '1';
        end if;

      when st_Acknowledged_RRN_BackscatterHandler_AND_SaveRN =>
        if mem_RB = '1' then
          mem_DTI_i  <= '0' & rng_cout(30 downto 16);
          mem_ADR_i  <= MEMORY_KILL_RNG_ADDRESS_MSB;
          mem_BANK_i <= RESERVED_MEMORY_BANK;
          mem_WR_i   <= '1';
          -- Backscatter RN16
          trm_cmd_i  <= trmcmd_Send;
          trm_buf_i  <= RN16Handler;
        end if;

        -----------------------------------------------------------------------
        -- OPEN            (in output process)
        -----------------------------------------------------------------------
      when st_Open =>
        if CommDone = cmd_Query then
          if Data_r(6 downto 5) = CurrSession then  --TODO: Verify flags refresh in one clockcycle.                                                    
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            ADRint_i <= MEMORY_PC_ADDRESS_16b;
          end if;
        elsif CommDone = cmd_ReqRN then
          if RN16_r = RN16Handler then
            rng_ce_i <= '1';            -- Prepare new RN
          end if;
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            ADRint_i(11 downto 0) <= Pointer_r(15 downto 4);
-- CompLSBit_i <= Pointer_r(3 downto 0);
            GCounter_i            <= Length_r;
          end if;
        end if;

      when st_Open_ACK_GetPC =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_BANK_i <= EPC_MEMORY_BANK;
          ADRint_i   <= ADRint + '1';
          mem_RD_i   <= '1';
          GPR_i      <= (others => '0');
        end if;

      when st_Open_ACK_SendPC_AND_DecodeEPCLength =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_BANK_i <= EPC_MEMORY_BANK;
          ADRint_i   <= ADRint + '1';
          mem_RD_i   <= '1';
-- GPR_i(4 downto 0) <= mem_DTO(0 to 4);  --Length of the PC+EPC (in words)
          GPR_i(4)   <= mem_DTO(0);
          GPR_i(3)   <= mem_DTO(1);
          GPR_i(2)   <= mem_DTO(2);
          GPR_i(1)   <= mem_DTO(3);
          GPR_i(0)   <= mem_DTO(4);
          trm_cmd_i  <= trmcmd_Send;
          trm_buf_i  <= mem_DTO;
        end if;

      when st_Open_ACK_GetAndSendEPC =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
            mem_BANK_i <= EPC_MEMORY_BANK;
            ADRint_i   <= ADRint + '1';
            mem_RD_i   <= '1';
            GPR_i      <= GPR - '1';
            trm_cmd_i  <= trmcmd_Send;
            trm_buf_i  <= mem_DTO;
          else
            mem_ADR_i  <= MEMORY_CRC16_ADDRESS;
            mem_BANK_i <= EPC_MEMORY_BANK;
            mem_RD_i   <= '1';
          end if;
        end if;

      when st_Open_ACK_GetAndSendCRC16 =>
        if mem_RB = '1' then
          trm_cmd_i <= trmcmd_Send;
          trm_buf_i <= mem_DTO;
        end if;

      when st_Open_RRN_LoadHandler_AND_SaveRN =>
        if mem_RB = '1' then
          RN16Handler_i <= rng_cout(15 downto 0);
          mem_DTI_i     <= rng_cout(15 downto 0);
          mem_ADR_i     <= MEMORY_KILL_RNG_ADDRESS_MSB + '1';
          mem_BANK_i    <= RESERVED_MEMORY_BANK;
          mem_WR_i      <= '1';
        end if;

      when st_Open_RRN_BackscatterHandler_AND_SaveRN =>
        if mem_RB = '1' then
          mem_DTI_i  <= '0' & rng_cout(30 downto 16);
          mem_ADR_i  <= MEMORY_KILL_RNG_ADDRESS_MSB;
          mem_BANK_i <= RESERVED_MEMORY_BANK;
          mem_WR_i   <= '1';
          -- Backscatter RN16
          trm_cmd_i  <= trmcmd_Send;
          trm_buf_i  <= RN16Handler;
        end if;



        -----------------------------------------------------------------------
        -- SECURED      (in output process)
        -----------------------------------------------------------------------      
      when st_Secured =>
        if CommDone = cmd_Query then
          if Data_r(6 downto 5) = CurrSession then  --TODO: Verify flags refresh in one clockcycle.                                                    
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_QueryRep then
          if CurrSession = Data_r(1 downto 0) then
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_QueryAdjust then
          if CurrSession = Data_r(4 downto 3) then
            -- Toggle inventoried flag
            case CurrSession is
              when "00" =>
                SInvD(0)  <= not(SInvQ(0));
                SInvCE(0) <= '1';
              when "01" =>
                SInvD(1)  <= not(SInvQ(1));
                SInvCE(1) <= '1';
              when "10" =>
                SInvD(2)  <= not(SInvQ(2));
                SInvCE(2) <= '1';
              when "11" =>
                SInvD(3)  <= not(SInvQ(3));
                SInvCE(3) <= '1';
              when others => null;
            end case;
          end if;
        elsif CommDone = cmd_Ack then
          if RN16_r = RN16Handler then
            ADRint_i <= MEMORY_PC_ADDRESS_16b;
          end if;
        elsif CommDone = cmd_ReqRN then
          if RN16_r = RN16Handler then
            rng_ce_i <= '1';            -- Prepare new RN
          end if;
        elsif CommDone = cmd_Select then
          if Select_Address_Pointer_Length_OK = '1' then
            ADRint_i(11 downto 0) <= Pointer_r(15 downto 4);
-- CompLSBit_i <= Pointer_r(3 downto 0);
            GCounter_i            <= Length_r;
          end if;
        elsif CommDone = cmd_Read then
          if RN16_r = RN16Handler then
            GPR_i <= (others => '0');
          end if;
          -- Write command does not cause any FSM output at this point (see next_state_process)
        end if;

      when st_Secured_ACK_GetPC =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_BANK_i <= EPC_MEMORY_BANK;
          ADRint_i   <= ADRint + '1';
          mem_RD_i   <= '1';
          GPR_i      <= (others => '0');
        end if;

      when st_Secured_ACK_SendPC_AND_DecodeEPCLength =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_BANK_i <= EPC_MEMORY_BANK;
          ADRint_i   <= ADRint + '1';
          mem_RD_i   <= '1';
-- GPR_i(4 downto 0) <= mem_DTO(0 to 4);  --Length of the PC+EPC (in words)
          GPR_i(4)   <= mem_DTO(0);
          GPR_i(3)   <= mem_DTO(1);
          GPR_i(2)   <= mem_DTO(2);
          GPR_i(1)   <= mem_DTO(3);
          GPR_i(0)   <= mem_DTO(4);
          trm_cmd_i  <= trmcmd_Send;
          trm_buf_i  <= mem_DTO;
        end if;

      when st_Secured_ACK_GetAndSendEPC =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
            mem_BANK_i <= EPC_MEMORY_BANK;
            ADRint_i   <= ADRint + '1';
            mem_RD_i   <= '1';
            GPR_i      <= GPR - '1';
            trm_cmd_i  <= trmcmd_Send;
            trm_buf_i  <= mem_DTO;
          else
            mem_ADR_i  <= MEMORY_CRC16_ADDRESS;
            mem_BANK_i <= EPC_MEMORY_BANK;
            mem_RD_i   <= '1';
          end if;
        end if;

      when st_Secured_ACK_GetAndSendCRC16 =>
        if mem_RB = '1' then
          trm_cmd_i <= trmcmd_Send;
          trm_buf_i <= mem_DTO;
        end if;

      when st_Secured_RRN_LoadHandler_AND_SaveRN =>
        if mem_RB = '1' then
          RN16Handler_i <= rng_cout(15 downto 0);
          mem_DTI_i     <= rng_cout(15 downto 0);
          mem_ADR_i     <= MEMORY_KILL_RNG_ADDRESS_MSB + '1';
          mem_BANK_i    <= RESERVED_MEMORY_BANK;
          mem_WR_i      <= '1';
        end if;

      when st_Secured_RRN_BackscatterHandler_AND_SaveRN =>
        if mem_RB = '1' then
          mem_DTI_i  <= '0' & rng_cout(30 downto 16);
          mem_ADR_i  <= MEMORY_KILL_RNG_ADDRESS_MSB;
          mem_BANK_i <= RESERVED_MEMORY_BANK;
          mem_WR_i   <= '1';
          -- Backscatter RN16
          trm_cmd_i  <= trmcmd_Send;
          trm_buf_i  <= RN16Handler;
        end if;

      when st_Secured_WR_CheckMemoryBounds =>
        if Write_Address_Pointer_Length_OK = '1' then
          ADRint_i           <= Pointer_r;
          GPR_i(15 downto 0) <= Data_r(15 downto 0) xor RN16Handler;
        else
          trm_cmd_i <= trmcmd_SendError;
          trm_buf_i <= NON_SPECIFIC_ERROR;  -- X"0F"
        end if;

      when st_Secured_WR_WriteWord =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
          mem_DTI_i  <= GPR(15 downto 0);
          mem_BANK_i <= Data_r(17 downto 16);
          mem_WR_i   <= '1';
        end if;

      when st_Secured_WR_WriteIsDone =>
        if mem_RB = '1' then
          -- Backscatter Handler
          trm_cmd_i <= trmcmd_Send;
          trm_buf_i <= RN16Handler;
        end if;

      when st_Secured_RD_CheckMemoryBounds =>
        if Read_Address_Pointer_Length_OK = '1' then
          ADRint_i          <= Pointer_r;
          GPR_i(7 downto 0) <= Length_r;
        else
          trm_cmd_i <= trmcmd_SendError;
          trm_buf_i <= NON_SPECIFIC_ERROR;  -- X"0F"
        end if;

      when st_Secured_RD_ReadMemory =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
            mem_BANK_i <= Data_r(1 downto 0);
            mem_RD_i   <= '1';
            ADRint_i   <= ADRint + '1';
            GPR_i      <= GPR - '1';
          else  -- Backscatter the whole memory (TODO:check when MEMBANK="01" (EPC))
            mem_ADR_i                  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
            mem_BANK_i                 <= Data_r(1 downto 0);
            mem_RD_i                   <= '1';
            ADRint_i                   <= ADRint + '1';
--            GPR_i(31 downto 2*AddrUSR) <= (others => '0');
            case Data_r(1 downto 0) is
              when "00" =>              --Reserved Memory
                --  GPR_i((2*AddrUSR)-1 downto 0) <= conv_std_logic_vector(WordsRSV-1, 2*AddrUSR);
                GPR_i <= EXT(conv_std_logic_vector(WordsRSV-1, 2 * AddrUSR), 32);
              when "01" =>              -- EPC Memory
--                GPR_i((2*AddrUSR)-1 downto 0) <= conv_std_logic_vector(WordsEPC-1, 2*AddrUSR);
                 GPR_i <= EXT(conv_std_logic_vector(WordsEPC-1, 2 * AddrUSR), 32);
              when "10" =>              --TID Memory
--                GPR_i((2*AddrUSR)-1 downto 0) <= conv_std_logic_vector(WordsTID-1, 2*AddrUSR);
                 GPR_i <= EXT(conv_std_logic_vector(WordsTID-1, 2 * AddrUSR), 32);
              when "11" =>              -- User Memory
--                GPR_i((2*AddrUSR)-1 downto 0) <= conv_std_logic_vector(WordsUSR-1, 2*AddrUSR);
                 GPR_i <= EXT(conv_std_logic_vector(WordsUSR-1, 2 * AddrUSR), 32);
              when others => null;
            end case;
          end if;
        end if;

      when st_Secured_RD_Read_AND_Send =>
        ADRint_i <= ADRint;
        if mem_RB = '1' then
          if unsigned(GPR) /= 0 then
            mem_ADR_i  <= conv_std_logic_vector(conv_integer(ADRint), 2*AddrUSR);
            mem_BANK_i <= Data_r(1 downto 0);
            mem_RD_i   <= '1';
            ADRint_i   <= ADRint + '1';
            GPR_i      <= GPR - '1';
            --backscatter data
            trm_cmd_i  <= trmcmd_SendRData;
            trm_buf_i  <= mem_DTO;
          end if;
        end if;

      when st_Secured_RD_SendLast =>
        if mem_RB = '1' then
          --backscatter data
          trm_cmd_i <= trmcmd_SendRData;
          trm_buf_i <= mem_DTO;
        end if;

      when st_Secured_RD_SendHandle =>
        trm_cmd_i <= trmcmd_SendRHandler;
        trm_buf_i <= RN16Handler;



        -----------------------------------------------------------------------
        -- KILLED    (in output process)
        -----------------------------------------------------------------------
      when st_Killed => null;


      when others => null;
    end case;


  end process OUTPUT_DEC;




  -----------------------------------------------------------------------------
  -- Inventory and Select Flag Comparison
  -----------------------------------------------------------------------------
  Query_InventoryFlag_Match <= '1' when Data_r(8 downto 7) = "00" else
                               '1' when Data_r(8 downto 7) = "01"                  else
                               '1' when (Data_r(8 downto 7) = "10" and SelQ = '0') else
                               '1' when (Data_r(8 downto 7) = "11" and SelQ = '1') else
                               '0';
  Query_SelectFlag_Match <= '1' when (Data_r(6 downto 5) = "00" and Data_r(4) = SInvQ(0)) else
                            '1' when (Data_r(6 downto 5) = "01" and Data_r(4) = SInvQ(1)) else
                            '1' when (Data_r(6 downto 5) = "10" and Data_r(4) = SInvQ(2)) else
                            '1' when (Data_r(6 downto 5) = "11" and Data_r(4) = SInvQ(3)) else
                            '0';

  -----------------------------------------------------------------------------
  -- Slot Zero comparison
  -----------------------------------------------------------------------------
  SlotIsZero <= '1' when conv_integer(Slot) = 0 else
                '0';

  -----------------------------------------------------------------------------
  -- Adress Pointer & Length Control (Select Command)
  -----------------------------------------------------------------------------

  Select_Address_Pointer_Length_OK <= '1' when Select_Address_Bounds_OK = '1' and conv_integer(Length_r) /= 0 else
                                      '0';

  Select_Address_Bounds_OK <= '1' when (Data_r(2 downto 1) = "00") and ((conv_integer(Pointer_r(15 downto 4))+ conv_integer(Length_r)) < WordsRSV) else
                              '1' when (Data_r(2 downto 1) = "01") and ((conv_integer(Pointer_r(15 downto 4))+ conv_integer(Length_r)) < WordsEPC) else
                              '1' when (Data_r(2 downto 1) = "10") and ((conv_integer(Pointer_r(15 downto 4))+ conv_integer(Length_r)) < WordsTID) else
                              '1' when (Data_r(2 downto 1) = "11") and ((conv_integer(Pointer_r(15 downto 4))+ conv_integer(Length_r)) < WordsUSR) else
                              '0';

  -----------------------------------------------------------------------------
  -- Adress Pointer & Length Control (Read Command)
  -----------------------------------------------------------------------------

  Read_Address_Pointer_Length_OK <= '1' when Read_Address_Bounds_OK = '1' and conv_integer(Length_r) /= 0 else
                                    '0';

  Read_Address_Bounds_OK <= '1' when (Data_r(1 downto 0) = "00") and ((conv_integer(Pointer_r)+ conv_integer(Length_r)) < WordsRSV) else
                            '1' when (Data_r(1 downto 0) = "01") and ((conv_integer(Pointer_r)+ conv_integer(Length_r)) < WordsEPC) else
                            '1' when (Data_r(1 downto 0) = "10") and ((conv_integer(Pointer_r)+ conv_integer(Length_r)) < WordsTID) else
                            '1' when (Data_r(1 downto 0) = "11") and ((conv_integer(Pointer_r)+ conv_integer(Length_r)) < WordsUSR) else
                            '0';

  -----------------------------------------------------------------------------
  -- Adress Pointer & Length Control (Write Command)
  -----------------------------------------------------------------------------

  Write_Address_Pointer_Length_OK <= '1' when Write_Address_Bounds_OK = '1' else
                                     '0';

  Write_Address_Bounds_OK <= '1' when (Data_r(17 downto 16) = "00") and (conv_integer(Pointer_r) < WordsRSV) else
                             '1' when (Data_r(17 downto 16) = "01") and (conv_integer(Pointer_r) < WordsEPC) else
                             '1' when (Data_r(17 downto 16) = "10") and (conv_integer(Pointer_r) < WordsTID) else
                             '1' when (Data_r(17 downto 16) = "11") and (conv_integer(Pointer_r) < WordsUSR) else
                             '0';


  -----------------------------------------------------------------------------
  -- MASK Comparison (Select Command)
  -----------------------------------------------------------------------------
  GPR_AFTER_COMPARISON_MUX <= X"000" & "000" & GPR(0) when unsigned(GCounter(3 downto 0)) = 0 else
                              EXT(GPR(1 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 1  else
                              EXT(GPR(2 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 2  else
                              EXT(GPR(3 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 3  else
                              EXT(GPR(4 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 4  else
                              EXT(GPR(5 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 5  else
                              EXT(GPR(6 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 6  else
                              EXT(GPR(7 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 7  else
                              EXT(GPR(8 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 8  else
                              EXT(GPR(9 downto 0), 16)  when unsigned(GCounter(3 downto 0)) = 9  else
                              EXT(GPR(10 downto 0), 16) when unsigned(GCounter(3 downto 0)) = 10 else
                              EXT(GPR(11 downto 0), 16) when unsigned(GCounter(3 downto 0)) = 11 else
                              EXT(GPR(12 downto 0), 16) when unsigned(GCounter(3 downto 0)) = 12 else
                              EXT(GPR(13 downto 0), 16) when unsigned(GCounter(3 downto 0)) = 13 else
                              EXT(GPR(14 downto 0), 16) when unsigned(GCounter(3 downto 0)) = 14 else
                              GPR(15 downto 0);

  MASK_AFTER_FIRSTCOMPARISON_MUX <= Mask_r(15 downto 0) when unsigned(GCounter2) = 0 else
                                    Mask_r(16 downto 1)  when unsigned(GCounter2) = 1  else
                                    Mask_r(17 downto 2)  when unsigned(GCounter2) = 2  else
                                    Mask_r(18 downto 3)  when unsigned(GCounter2) = 3  else
                                    Mask_r(19 downto 4)  when unsigned(GCounter2) = 4  else
                                    Mask_r(20 downto 5)  when unsigned(GCounter2) = 5  else
                                    Mask_r(21 downto 6)  when unsigned(GCounter2) = 6  else
                                    Mask_r(22 downto 7)  when unsigned(GCounter2) = 7  else
                                    Mask_r(23 downto 8)  when unsigned(GCounter2) = 8  else
                                    Mask_r(24 downto 9)  when unsigned(GCounter2) = 9  else
                                    Mask_r(25 downto 10) when unsigned(GCounter2) = 10 else
                                    Mask_r(26 downto 11) when unsigned(GCounter2) = 11 else
                                    Mask_r(27 downto 12) when unsigned(GCounter2) = 12 else
                                    Mask_r(28 downto 13) when unsigned(GCounter2) = 13 else
                                    Mask_r(29 downto 14) when unsigned(GCounter2) = 14 else
                                    Mask_r(30 downto 15) when unsigned(GCounter2) = 15 else
                                    Mask_r(31 downto 16) when unsigned(GCounter2) = 16 else
                                    Mask_r(32 downto 17) when unsigned(GCounter2) = 17 else
                                    Mask_r(33 downto 18) when unsigned(GCounter2) = 18 else
                                    Mask_r(34 downto 19) when unsigned(GCounter2) = 19 else
                                    Mask_r(35 downto 20) when unsigned(GCounter2) = 20 else
                                    Mask_r(36 downto 21);

  MASK_AFTER_COMPARISON_BIT_MUX <= MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000000000001" when unsigned(GCounter(3 downto 0)) = 0 else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000000000011" when unsigned(GCounter(3 downto 0)) = 1  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000000000111" when unsigned(GCounter(3 downto 0)) = 2  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000000001111" when unsigned(GCounter(3 downto 0)) = 3  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000000011111" when unsigned(GCounter(3 downto 0)) = 4  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000000111111" when unsigned(GCounter(3 downto 0)) = 5  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000001111111" when unsigned(GCounter(3 downto 0)) = 6  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000011111111" when unsigned(GCounter(3 downto 0)) = 7  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000000111111111" when unsigned(GCounter(3 downto 0)) = 8  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000001111111111" when unsigned(GCounter(3 downto 0)) = 9  else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000011111111111" when unsigned(GCounter(3 downto 0)) = 10 else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0000111111111111" when unsigned(GCounter(3 downto 0)) = 11 else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0001111111111111" when unsigned(GCounter(3 downto 0)) = 12 else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0011111111111111" when unsigned(GCounter(3 downto 0)) = 13 else
                               MASK_AFTER_FIRSTCOMPARISON_MUX and "0111111111111111" when unsigned(GCounter(3 downto 0)) = 14 else
                               MASK_AFTER_FIRSTCOMPARISON_MUX;
  
  -----------------------------------------------------------------------------
  -- SLOT VALUE (Query Command)
  -----------------------------------------------------------------------------
  SLOT_VALUE <= X"0000" when unsigned(CurrQ) = 0 else
                X"000" & "000" & rng_cout(0) when unsigned(CurrQ) = 1 else
                EXT(rng_cout(1 downto 0), 16) when unsigned(CurrQ) = 2 else
                EXT(rng_cout(2 downto 0), 16) when unsigned(CurrQ) = 3 else
                EXT(rng_cout(3 downto 0), 16) when unsigned(CurrQ) = 4 else
                EXT(rng_cout(4 downto 0), 16) when unsigned(CurrQ) = 5 else
                EXT(rng_cout(5 downto 0), 16) when unsigned(CurrQ) = 6 else
                EXT(rng_cout(6 downto 0), 16) when unsigned(CurrQ) = 7 else
                EXT(rng_cout(7 downto 0), 16) when unsigned(CurrQ) = 8 else
                EXT(rng_cout(8 downto 0), 16) when unsigned(CurrQ) = 9 else
                EXT(rng_cout(9 downto 0), 16) when unsigned(CurrQ) = 10 else
                EXT(rng_cout(10 downto 0), 16) when unsigned(CurrQ) = 11 else
                EXT(rng_cout(11 downto 0), 16) when unsigned(CurrQ) = 12 else
                EXT(rng_cout(12 downto 0), 16) when unsigned(CurrQ) = 13 else
                EXT(rng_cout(13 downto 0), 16) when unsigned(CurrQ) = 14 else
                EXT(rng_cout(14 downto 0), 16);
                
  

end TagFSM1;

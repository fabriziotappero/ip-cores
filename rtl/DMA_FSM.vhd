----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    DMA_FSM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--               The state machine controls the DMA routine, writes the channel
--               buffer, as well as outputs DMA stata.
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  25.07.2007
-- 
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.abb64Package.all;


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DMA_FSM is
    port (
      -- Fixed word for 1st header of TLP: MRd/MWr
      TLP_Has_Payload    : IN  std_logic;
      TLP_Hdr_is_4DW     : IN  std_logic;
      DMA_Addr_Inc       : IN  std_logic;

      DMA_BAR_Number     : IN  std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);

      -- FSM control signals
      DMA_Start          : IN  std_logic;
      DMA_Start2         : IN  std_logic;
      DMA_Stop           : IN  std_logic;
      DMA_Stop2          : IN  std_logic;

      No_More_Bodies     : IN  std_logic;
      ThereIs_Snout      : IN  std_logic;
      ThereIs_Body       : IN  std_logic;
      ThereIs_Tail       : IN  std_logic;
      ThereIs_Dex        : IN  std_logic;

      -- Parameters to be written into ChBuf
      DMA_PA_Loaded      : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_PA_Var         : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_HA_Var         : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      DMA_BDA_fsm        : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      BDA_is_64b_fsm     : IN  std_logic;

      DMA_Snout_Length   : IN  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto  0);
      DMA_Body_Length    : IN  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
      DMA_Tail_Length    : IN  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto  0);

      -- Busy/Done conditions
      Done_Condition_1   : IN  std_logic;
      Done_Condition_2   : IN  std_logic;
      Done_Condition_3   : IN  std_logic;
      Done_Condition_4   : IN  std_logic;
      Done_Condition_5   : IN  std_logic;
      Done_Condition_6   : IN  std_logic;


      -- Channel buffer write
      us_MWr_Param_Vec   : IN  std_logic_vector(6-1   downto 0);
      ChBuf_aFull        : IN  std_logic;
      ChBuf_WrEn         : OUT std_logic;
      ChBuf_WrDin        : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);


      -- FSM indicators
      State_Is_LoadParam : OUT std_logic;
      State_Is_Snout     : OUT std_logic;
      State_Is_Body      : OUT std_logic;
      State_Is_Tail      : OUT std_logic;
      DMA_Cmd_Ack        : OUT std_logic;

      -- To Tx Port
      ChBuf_ValidRd      : IN  std_logic;
      BDA_nAligned       : OUT std_logic;
      DMA_TimeOut        : OUT std_logic;
      DMA_Busy           : OUT std_logic;
      DMA_Done           : OUT std_logic;
--      DMA_Done_Rise      : OUT std_logic;

      -- Tags
      Pkt_Tag            : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);
      Dex_Tag            : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Common ports
      dma_clk            : IN  std_logic;
      dma_reset          : IN  std_logic
    );

end entity DMA_FSM;



architecture Behavioral of DMA_FSM is

  --   DMA operation control FSM
  type DMAStates is            ( 
                                 -- dmaST_Init: Initial state at reset.
                                 dmaST_Init

                                 -- dmaST_Load_Param: Load DMA parameters (PA, HA, BDA and Leng).
                               , dmaST_Load_Param

                                 -- dmaST_Snout: 1st TLP might be non-integeral of MAX_SIZE.
                               , dmaST_Snout

                                 -- dmaST_Stomp: after every ChBuf write, pause a clock before taking
                                 --              next write.  This state checks the availability of 
                                 --              the ChBuf (channel buffer) for write.
                               , dmaST_Stomp

                                 -- dmaST_Body: TLP's in the middle, always integeral of MAX_SIZE.
                               , dmaST_Body

                                 -- dmaST_Tail: the last TLP, similar with the 1st one, whose size 
                                 --             should be specially calculated.
                               , dmaST_Tail

--                                 -- dmaST_Before_Dex: before writing the MRd TLP (for next descriptor)
--                                 --                   information for the next descriptor (if any), 
--                                 --                   a pause is needed to wait for the ChBuf available.
--                               , dmaST_Before_Dex

                                 -- dmaST_NextDex: writing the descriptor MRd TLP information to 
                                 --                the ChBuf.
                               , dmaST_NextDex

                                 -- dmaST_Await_Dex: after MRd(descriptor) info is written in the ChBuf, 
                                 --                  the state machine waits for the descriptor's 
                                 --                  arrival.
                               , dmaST_Await_Dex
                               );

  signal DMA_NextState         : DMAStates;
  signal DMA_State             : DMAStates;


  -- Busy/Done state bits generation
  type FSM_BusyDone is         (
                                 FSM_Idle
                               , FSM_Busy1
                               , FSM_Busy2
                               , FSM_Busy3
                               , FSM_Busy4
                               , FSM_Busy5
                               , FSM_Busy6
                               , FSM_Done
                               );

  signal BusyDone_NextState    : FSM_BusyDone;
  signal BusyDone_State        : FSM_BusyDone;


  -- Time-out state
  type FSM_Time_Out is         (
                                 toutSt_Idle
                               , toutSt_CountUp
                               , toutSt_Pause
                               );

  signal DMA_TimeOut_State     : FSM_Time_Out;

  --  DMA Start command from MWr channel
  signal  DMA_Start_r1         : std_logic;
  --  DMA Start command from CplD channel
  signal  DMA_Start2_r1        : std_logic;
  --  Registered Dex indicator
  signal  ThereIs_Dex_reg      : std_logic;
  signal  ThereIs_Snout_reg    : std_logic;
  signal  ThereIs_Body_reg     : std_logic;
  signal  ThereIs_Tail_reg     : std_logic;

  -- DMA Stutus monitor
  signal  BDA_nAligned_i       : std_logic;
  signal  DMA_Busy_i           : std_logic;
  signal  DMA_Done_i           : std_logic;

  -- FSM state indicators
  signal  State_Is_LoadParam_i : std_logic;
  signal  State_Is_Snout_i     : std_logic;
  signal  State_Is_Body_i      : std_logic;
  signal  State_Is_Tail_i      : std_logic;
  signal  State_Is_AwaitDex_i  : std_logic;

  --  Acknowledge for DMA_Start command
  signal  DMA_Cmd_Ack_i        : std_logic;


  -- channel FIFO Write control
  signal  ChBuf_WrDin_i        : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  ChBuf_WrEn_i         : std_logic;
  signal  ChBuf_aFull_i        : std_logic;


  --  ---------------------------------------------------------------------------------
  --    Time-out calculation :  invisible to the user, so moved out of the abbPackage
  --  ---------------------------------------------------------------------------------

  signal  cnt_DMA_TO           : std_logic_vector(C_TOUT_WIDTH-1 downto  0);
  signal  Tout_Lo_Carry        : std_logic;
  signal  DMA_TimeOut_i        : std_logic;

  -- Carry bit, only for better timing
  Constant  CBIT_TOUT_CARRY    : integer  := C_TOUT_WIDTH/2;

begin

   -- As DMA Statuses
   BDA_nAligned       <=  '0'            ;   -- BDA_nAligned_i ;
   DMA_Busy           <=  DMA_Busy_i     ;
   DMA_Done           <=  DMA_Done_i     ;
--   DMA_Done_Rise      <=  DMA_Done_Rise_i;
   DMA_TimeOut        <=  DMA_TimeOut_i  ;


   -- Abstract buffer write control
   ChBuf_WrEn         <=  ChBuf_WrEn_i;
   ChBuf_WrDin        <=  ChBuf_WrDin_i;
   ChBuf_aFull_i      <=  ChBuf_aFull;


   -- FSM State indicators
   State_Is_LoadParam <=  State_Is_LoadParam_i;
   State_Is_Snout     <=  State_Is_Snout_i;
   State_Is_Body      <=  State_Is_Body_i;
   State_Is_Tail      <=  State_Is_Tail_i;

   DMA_Cmd_Ack        <=  DMA_Cmd_Ack_i;


-- -----------------------------------------
-- Syn_Delay: DMA_Start
--            DMA_Start2
-- 
   Syn_Delay_DMA_Starts:
   process ( dma_clk)
   begin
      if dma_clk'event and dma_clk = '1' then
         DMA_Start_r1    <= DMA_Start;
         DMA_Start2_r1   <= DMA_Start2;
      end if;

   end process;



---- -----------------------------------------
---- -----------------------------------------
---- 
-- States synchronous: DMA
---- 
   Syn_DMA_States:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_State   <= dmaST_Init;
      elsif dma_clk'event and dma_clk = '1' then
         DMA_State   <= DMA_NextState;
      end if;

   end process;



-- Next States: DMA
   Comb_DMA_NextState:
   process ( 
             DMA_State
           , DMA_Start_r1
           , DMA_Start2_r1
           , ChBuf_aFull_i

           , No_More_Bodies
           , ThereIs_Snout  --_reg
--           , ThereIs_Body
           , ThereIs_Tail_reg
           , ThereIs_Dex_reg
           )
   begin
     case DMA_State  is

       when dmaST_Init  =>
          if DMA_Start_r1 = '1' then
             DMA_NextState <= dmaST_Load_Param;
          else
             DMA_NextState <= dmaST_Init;
          end if;


       when dmaST_Load_Param  =>
          if ChBuf_aFull_i = '1' then
             DMA_NextState <= dmaST_Load_Param;
          elsif ThereIs_Dex_reg = '1' then
             DMA_NextState <= dmaST_NextDex;
          elsif ThereIs_Snout = '1' then
             DMA_NextState <= dmaST_Snout;
--          elsif ThereIs_Body = '1' then
--             DMA_NextState <= dmaST_Stomp;
          else
             DMA_NextState <= dmaST_Stomp;
          end if;


       when dmaST_NextDex  =>
          if ThereIs_Snout = '1' then
             DMA_NextState <= dmaST_Snout;
          elsif No_More_Bodies = '0' then
             DMA_NextState <= dmaST_Body;
          else
             DMA_NextState <= dmaST_Await_Dex;
          end if;


       when dmaST_Snout  =>
             DMA_NextState <= dmaST_Stomp;


       when dmaST_Stomp  =>
          if ChBuf_aFull_i = '1' then
             DMA_NextState <= dmaST_Stomp;
          elsif No_More_Bodies= '0' then
             DMA_NextState <= dmaST_Body;
          elsif ThereIs_Tail_reg= '1' then
             DMA_NextState <= dmaST_Tail;
          elsif ThereIs_Dex_reg= '1' then
             DMA_NextState <= dmaST_Await_Dex;
          else
             DMA_NextState <= dmaST_Init;
          end if;


       when dmaST_Body  =>
             DMA_NextState <= dmaST_Stomp;


       when dmaST_Tail  =>
          if ThereIs_Dex_reg = '1' then
            DMA_NextState <= dmaST_Await_Dex;
          else
            DMA_NextState <= dmaST_Init;
          end if;


       when dmaST_Await_Dex  =>
          if DMA_Start2_r1 = '1' then
             DMA_NextState <= dmaST_Load_Param;
          else
             DMA_NextState <= dmaST_Await_Dex;
          end if;


       when Others  =>
          DMA_NextState <= dmaST_Init;


     end case;   -- DMA_State

   end process;



-- ----------------------------------------------------
-- States synchronous: DMA_Cmd_Ack
--                     equivalent to State_Is_LoadParam
--
   Syn_DMA_Cmd_Ack:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_Cmd_Ack_i   <= '0';
      elsif dma_clk'event and dma_clk = '1' then

         if DMA_NextState = dmaST_Load_Param  then
            DMA_Cmd_Ack_i  <= '1';
         else
            DMA_Cmd_Ack_i  <= '0';
         end if;
      end if;

   end process;


-- ----------------------------------------------------
-- States synchronous: ThereIs_Dex_reg
--
   Syn_ThereIs_Dex_reg:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         ThereIs_Dex_reg   <= '0';
         ThereIs_Snout_reg <= '0';
         ThereIs_Body_reg  <= '0';
         ThereIs_Tail_reg  <= '0';

      elsif dma_clk'event and dma_clk = '1' then

         if    DMA_Start = '1' 
            or State_Is_LoadParam_i = '1'
            or State_Is_AwaitDex_i ='1'
            then
            ThereIs_Dex_reg    <= ThereIs_Dex;
            ThereIs_Snout_reg  <= ThereIs_Snout;
            ThereIs_Body_reg   <= ThereIs_Body;
            ThereIs_Tail_reg   <= ThereIs_Tail;
         else
            ThereIs_Dex_reg    <= ThereIs_Dex_reg;
            ThereIs_Snout_reg  <= ThereIs_Snout_reg;
            ThereIs_Body_reg   <= ThereIs_Body_reg;
            ThereIs_Tail_reg   <= ThereIs_Tail_reg;
         end if;
      end if;

   end process;



-- -------------------------------------------------------------
-- Synchronous reg: 
--                  State_Is_LoadParam
--                  State_Is_Snout
--                  State_Is_Body
--                  State_Is_Tail
--                  State_Is_AwaitDex
--
   FSM_State_Is_i:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         State_Is_LoadParam_i <= '0';
         State_Is_Snout_i     <= '0';
         State_Is_Body_i      <= '0';
         State_Is_Tail_i      <= '0';
         State_Is_AwaitDex_i  <= '0';

      elsif dma_clk'event and dma_clk = '1' then

         if DMA_NextState= dmaST_Load_Param then
            State_Is_LoadParam_i <= '1';
         else
            State_Is_LoadParam_i <= '0';
         end if;

         if DMA_NextState= dmaST_Snout then
            State_Is_Snout_i <= '1';
         else
            State_Is_Snout_i <= '0';
         end if;

         if DMA_NextState= dmaST_Body then
            State_Is_Body_i <= '1';
         else
            State_Is_Body_i <= '0';
         end if;

         if DMA_NextState= dmaST_Tail then
            State_Is_Tail_i <= '1';
         else
            State_Is_Tail_i <= '0';
         end if;

         if DMA_NextState= dmaST_Await_Dex then
            State_Is_AwaitDex_i <= '1';
         else
            State_Is_AwaitDex_i <= '0';
         end if;

      end if;
   end process;



-------------------------------------------------------------------
-- Synchronous Output: DMA_Abstract_Buffer_Write
-- 
-- DMA Channel (downstream and upstream) Buffers (128-bit) definition:
--     Note: Type not shows in this buffer
--
--  127 ~ xxx : Peripheral address
--  xxy ~  96 : reserved
--         95 : Address increments
--         94 : Valid
--   93 ~  30 : Host Address
--   29 ~  27 : BAR number
--   26 ~  19 : Tag
-- 
--   18 ~  17 : Format
--   16 ~  14 : TC
--         13 : TD
--         12 : EP
--   11 ~  10 : Attribute
--    9 ~   0 : Length
-- 
   FSM_DMA_Abstract_Buffer_Write:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         ChBuf_WrEn_i   <= '0';
         ChBuf_WrDin_i  <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then

         case DMA_State is

            when dmaST_NextDex =>
                 ChBuf_WrEn_i  <= '1';

                 ChBuf_WrDin_i   <= (OTHERS=>'0');   -- must be the first argument
                 ChBuf_WrDin_i(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT)            <= DMA_BDA_fsm;
                 ChBuf_WrDin_i(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)            <= C_ALL_ZEROS(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT);    -- any value
                 ChBuf_WrDin_i(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT)          <= Dex_Tag;
                 ChBuf_WrDin_i(C_CHBUF_DMA_BAR_BIT_TOP downto C_CHBUF_DMA_BAR_BIT_BOT)  <= DMA_BAR_Number;

                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_TOP)                                     <= C_TLP_HAS_NO_DATA;  --C_MRD_HEAD0_WORD(C_TLP_FMT_BIT_TOP);
                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_BOT)                                     <= BDA_is_64b_fsm;
                 ChBuf_WrDin_i(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)        <= C_NEXT_BD_LENGTH(C_TLP_FLD_WIDTH_OF_LENG+1 downto 2);

                 ChBuf_WrDin_i(C_CHBUF_QVALID_BIT)                                      <= '1';
                 ChBuf_WrDin_i(C_CHBUF_AINC_BIT)                                        <= DMA_Addr_Inc;  -- any value

                 ChBuf_WrDin_i(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT)        <= C_RELAXED_ORDERING & C_NO_SNOOP;

            when dmaST_Snout =>
                 ChBuf_WrEn_i   <= '1';

                 ChBuf_WrDin_i   <= (OTHERS=>'0');   -- must be the first argument
                 ChBuf_WrDin_i(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT)    <= DMA_HA_Var;
                 if    DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)    <= DMA_PA_Loaded(C_EP_AWIDTH-1 downto 0);
                 elsif DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_BRAM_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)    <= DMA_PA_Loaded(C_PRAM_AWIDTH-1+2 downto 0);
                 elsif DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT)  <= DMA_PA_Loaded(C_DDR_IAWIDTH-1 downto 0);
                 else
                   ChBuf_WrDin_i(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)    <= C_ALL_ZEROS(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT);
                 end if;

                 ChBuf_WrDin_i(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT)          <= Pkt_Tag;
                 ChBuf_WrDin_i(C_CHBUF_DMA_BAR_BIT_TOP downto C_CHBUF_DMA_BAR_BIT_BOT)  <= DMA_BAR_Number;

                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_TOP)                                     <= TLP_Has_Payload;
                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_BOT)                                     <= TLP_Hdr_is_4DW;

                 if DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)        <= DMA_Snout_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto 3) & '0';
                 else
                   ChBuf_WrDin_i(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)        <= DMA_Snout_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto 2);
                 end if;

                 ChBuf_WrDin_i(C_CHBUF_QVALID_BIT)                                      <= '1';
                 ChBuf_WrDin_i(C_CHBUF_AINC_BIT)                                        <= DMA_Addr_Inc;

                 ChBuf_WrDin_i(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT)            <= us_MWr_Param_Vec(2 downto 0);
                 ChBuf_WrDin_i(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT)        <= us_MWr_Param_Vec(5 downto 4);  -- C_RELAXED_ORDERING & C_NO_SNOOP;

            when dmaST_Body =>
                 ChBuf_WrEn_i   <= '1';

                 ChBuf_WrDin_i   <= (OTHERS=>'0');   -- must be the first argument
                 ChBuf_WrDin_i(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT)     <= DMA_HA_Var;
                 if    DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)   <= DMA_PA_Var(C_EP_AWIDTH-1 downto 0);
                 elsif DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_BRAM_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)   <= DMA_PA_Var(C_PRAM_AWIDTH-1+2 downto 0);
                 elsif DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT) <= DMA_PA_Var(C_DDR_IAWIDTH-1 downto 0);
                 else
                   ChBuf_WrDin_i(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)   <= C_ALL_ZEROS(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT);
                 end if;

                 ChBuf_WrDin_i(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT)          <= Pkt_Tag;
                 ChBuf_WrDin_i(C_CHBUF_DMA_BAR_BIT_TOP downto C_CHBUF_DMA_BAR_BIT_BOT)  <= DMA_BAR_Number;

                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_TOP)                                     <= TLP_Has_Payload;
                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_BOT)                                     <= TLP_Hdr_is_4DW;

                 if DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)        <= DMA_Body_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto 3) & '0';
                 else
                   ChBuf_WrDin_i(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)        <= DMA_Body_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto 2);
                 end if;

                 ChBuf_WrDin_i(C_CHBUF_QVALID_BIT)                                      <= '1';
                 ChBuf_WrDin_i(C_CHBUF_AINC_BIT)                                        <= DMA_Addr_Inc;

                 ChBuf_WrDin_i(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT)            <= us_MWr_Param_Vec(2 downto 0);
                 ChBuf_WrDin_i(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT)        <= us_MWr_Param_Vec(5 downto 4);  -- C_RELAXED_ORDERING & C_NO_SNOOP;


            when dmaST_Tail =>
                 ChBuf_WrEn_i   <= '1';

                 ChBuf_WrDin_i   <= (OTHERS=>'0');   -- must be the first argument
                 ChBuf_WrDin_i(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT)     <= DMA_HA_Var;
                 if    DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)   <= DMA_PA_Var(C_EP_AWIDTH-1 downto 0);
                 elsif DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_BRAM_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)   <= DMA_PA_Var(C_PRAM_AWIDTH-1+2 downto 0);
                 elsif DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT) <= DMA_PA_Var(C_DDR_IAWIDTH-1 downto 0);
                 else
                   ChBuf_WrDin_i(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)   <= C_ALL_ZEROS(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT);
                 end if;

                 ChBuf_WrDin_i(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT)          <= Pkt_Tag;
                 ChBuf_WrDin_i(C_CHBUF_DMA_BAR_BIT_TOP downto C_CHBUF_DMA_BAR_BIT_BOT)  <= DMA_BAR_Number;

                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_TOP)                                     <= TLP_Has_Payload;
                 ChBuf_WrDin_i(C_CHBUF_FMT_BIT_BOT)                                     <= TLP_Hdr_is_4DW;

                 if DMA_BAR_Number=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                   ChBuf_WrDin_i(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)        <= DMA_Tail_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto 3) & '0';
                 else
                   ChBuf_WrDin_i(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)        <= DMA_Tail_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto 2);
                 end if;

                 ChBuf_WrDin_i(C_CHBUF_QVALID_BIT)                                      <= '1';
                 ChBuf_WrDin_i(C_CHBUF_AINC_BIT)                                        <= DMA_Addr_Inc;

                 ChBuf_WrDin_i(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT)            <= us_MWr_Param_Vec(2 downto 0);
                 ChBuf_WrDin_i(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT)        <= us_MWr_Param_Vec(5 downto 4);  -- C_RELAXED_ORDERING & C_NO_SNOOP;


            when OTHERS =>
                 ChBuf_WrEn_i   <= '0';
                 ChBuf_WrDin_i  <= ChBuf_WrDin_i;

         end case;

      end if;
   end process;



-- ----------------------------------------------
-- Synchronous Latch: BDA_nAligned_i
--                  : Capture design defect
-- 
   Latch_BDA_nAligned:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         BDA_nAligned_i <= '0';

      elsif dma_clk'event and dma_clk = '1' then
         -- If the lowest 2 bits are not zero, error bit set accordingly,
         --   because the logic can not deal with this situation.
         --   can be removed.

         if DMA_BDA_fsm(1) ='1' or DMA_BDA_fsm(0) ='1' then
            BDA_nAligned_i <= '1';
         else
            BDA_nAligned_i <= BDA_nAligned_i;
         end if;

      end if;
   end process;


-- States synchronous: BusyDone_States
   Syn_BusyDone_States:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         BusyDone_State   <= FSM_Idle;
      elsif dma_clk'event and dma_clk = '1' then
         BusyDone_State   <= BusyDone_NextState;
      end if;

   end process;


-- Next States: BusyDone_State
   Comb_BusyDone_State:
   process ( 
             BusyDone_State
           , DMA_State
--           , Done_Condition_1
           , Done_Condition_2
           , Done_Condition_3
           , Done_Condition_4
           , Done_Condition_5
           , Done_Condition_6
           )
   begin
     case BusyDone_State  is

       when FSM_Idle  =>
          if DMA_State = dmaST_Load_Param then
             BusyDone_NextState <= FSM_Busy1;
          else
             BusyDone_NextState <= FSM_Idle;
          end if;

       when FSM_Busy1  =>
          if DMA_State = dmaST_Init      ---  Done_Condition_1='1'
             then
             BusyDone_NextState <= FSM_Busy2;
          else
             BusyDone_NextState <= FSM_Busy1;
          end if;

       when FSM_Busy2  =>
          if Done_Condition_2='1'
             then
             BusyDone_NextState <= FSM_Busy3;
          else
             BusyDone_NextState <= FSM_Busy2;
          end if;

       when FSM_Busy3  =>
          if Done_Condition_3='1'
             then
             BusyDone_NextState <= FSM_Busy4;
          else
             BusyDone_NextState <= FSM_Busy3;
          end if;

       when FSM_Busy4  =>
          if Done_Condition_4='1'
             then
             BusyDone_NextState <= FSM_Busy5;
          else
             BusyDone_NextState <= FSM_Busy4;
          end if;

       when FSM_Busy5  =>
          if Done_Condition_5='1'
             then
             BusyDone_NextState <= FSM_Busy6;
          else
             BusyDone_NextState <= FSM_Busy5;
          end if;

       when FSM_Busy6  =>
          if Done_Condition_6='1'
             then
             BusyDone_NextState <= FSM_Done;
          else
             BusyDone_NextState <= FSM_Busy6;
          end if;

       when FSM_Done  =>
          if DMA_State = dmaST_Init then
             BusyDone_NextState <= FSM_Idle;
          else
             BusyDone_NextState <= FSM_Done;
          end if;

       when Others  =>
          BusyDone_NextState    <= FSM_Idle;

     end case;  -- BusyDone_State

   end process;



-- Synchronous Output: DMA_Busy_i
   FSM_Output_DMA_Busy:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_Busy_i     <= '0';
      elsif dma_clk'event and dma_clk = '1' then

        case BusyDone_State is

          when FSM_Idle =>
            DMA_Busy_i  <= '0';

          when FSM_Busy1 =>
            DMA_Busy_i  <= '1';

          when FSM_Busy2 =>
            DMA_Busy_i  <= '1';

          when FSM_Busy3 =>
            DMA_Busy_i  <= '1';

          when FSM_Busy4 =>
            DMA_Busy_i  <= '1';

          when FSM_Busy5 =>
            DMA_Busy_i  <= '1';

          when FSM_Busy6 =>
            DMA_Busy_i  <= '1';

          when FSM_Done =>
            DMA_Busy_i  <= '0';

          when Others =>
            DMA_Busy_i  <= '0';

        end case; -- BusyDone_State

      end if;
   end process;


-- Synchronous Output: DMA_Done_i
   FSM_Output_DMA_Done:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_Done_i     <= '0';
      elsif dma_clk'event and dma_clk = '1' then

        case BusyDone_State is

--          when FSM_Busy1 =>
--            DMA_Done_i  <= '0';
--
--          when FSM_Busy2 =>
--            DMA_Done_i  <= '0';
--
--          when FSM_Busy3 =>
--            DMA_Done_i  <= '0';
--
          when FSM_Done =>
            DMA_Done_i  <= '1';

          when Others =>
            DMA_Done_i  <= DMA_Done_i;

        end case; -- BusyDone_State

      end if;
   end process;



-- ----------------------------------------------
-- Time out counter
-- Synchronous Output: Counter_DMA_TimeOut_i
   FSM_Counter_DMA_TimeOut_i:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         cnt_DMA_TO         <= (Others=>'0');
         Tout_Lo_Carry      <= '0';
         DMA_TimeOut_State  <= toutSt_Idle;

      elsif dma_clk'event and dma_clk = '1' then

        case DMA_TimeOut_State is

          when toutSt_Idle =>
            cnt_DMA_TO         <= (Others=>'0');
            Tout_Lo_Carry      <= '0';
            if DMA_Start='1' then
              DMA_TimeOut_State  <= toutSt_CountUp;
            else
              DMA_TimeOut_State  <= toutSt_Idle;
            end if;

          when toutSt_CountUp =>
            if DMA_Done_i='1' or DMA_Start='1' then
              cnt_DMA_TO         <= (Others=>'0');
              Tout_Lo_Carry      <= '0';
              DMA_TimeOut_State  <= toutSt_Idle;
            elsif DMA_Stop='1' then
              cnt_DMA_TO         <= cnt_DMA_TO;
              Tout_Lo_Carry      <= Tout_Lo_Carry;
              DMA_TimeOut_State  <= toutSt_Pause;
            elsif ChBuf_ValidRd='1' then
              cnt_DMA_TO         <= (Others=>'0');
              Tout_Lo_Carry      <= '0';
              DMA_TimeOut_State  <= toutSt_CountUp;
            else
              cnt_DMA_TO(CBIT_TOUT_CARRY-1 downto 0)  <= cnt_DMA_TO(CBIT_TOUT_CARRY-1 downto 0) + '1';
              if cnt_DMA_TO(CBIT_TOUT_CARRY-1 downto 0)=C_ALL_ONES(CBIT_TOUT_CARRY-1 downto 0) then
                 Tout_Lo_Carry    <= '1';
              else
                 Tout_Lo_Carry    <= '0';
              end if;
              if Tout_Lo_Carry='1' then
                 cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_TOUT_CARRY)  <= cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_TOUT_CARRY) + '1';
              else
                 cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_TOUT_CARRY)  <= cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_TOUT_CARRY);
              end if;
              DMA_TimeOut_State  <= toutSt_CountUp;
            end if;

          when toutSt_Pause =>
            cnt_DMA_TO         <= cnt_DMA_TO;
            Tout_Lo_Carry      <= Tout_Lo_Carry;
            if DMA_Start='1' then
              DMA_TimeOut_State  <= toutSt_CountUp;
            elsif DMA_Done_i='1' then
              DMA_TimeOut_State  <= toutSt_Idle;
            else
              DMA_TimeOut_State  <= toutSt_Pause;
            end if;

          when Others =>
            cnt_DMA_TO         <= cnt_DMA_TO;
            Tout_Lo_Carry      <= Tout_Lo_Carry;
            DMA_TimeOut_State  <= toutSt_Idle;

        end case;



--        case DMA_State is
--
--          when dmaST_Init =>
--            cnt_DMA_TO       <= (Others=>'0');
--            Tout_Lo_Carry    <= '0';
--
--          when dmaST_Snout =>
--            cnt_DMA_TO       <= (Others=>'0');
--            Tout_Lo_Carry    <= '0';
--
--
--          when Others =>
--            cnt_DMA_TO(CBIT_CARRY-1 downto 0)  <= cnt_DMA_TO(CBIT_CARRY-1 downto 0) + '1';
--
--            if cnt_DMA_TO(CBIT_CARRY-1 downto 0)=C_ALL_ONES(CBIT_CARRY-1 downto 0) then
--               Tout_Lo_Carry    <= '1';
--            else
--               Tout_Lo_Carry    <= '0';
--            end if;
--
--            if Tout_Lo_Carry='1' then
--               cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_CARRY)  <= cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_CARRY) + '1';
--            else
--               cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_CARRY)  <= cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_CARRY);
--            end if;
--
--        end case;

      end if;
   end process;


-- ----------------------------------------------
-- Time out state bit
-- Synchronous Output: DMA_TimeOut_i
   FSM_DMA_TimeOut:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_TimeOut_i     <= '0';
      elsif dma_clk'event and dma_clk = '1' then
         -- Capture the time-out trigger
--         if cnt_DMA_TO(CBIT_TOUT_BOT downto 0) = C_TIME_OUT_VALUE then
         if cnt_DMA_TO(C_TOUT_WIDTH-1 downto CBIT_TOUT_BOT) = C_TIME_OUT_VALUE then
            DMA_TimeOut_i  <= '1';
         else
            DMA_TimeOut_i  <= DMA_TimeOut_i;
         end if;

      end if;
   end process;


end architecture Behavioral;

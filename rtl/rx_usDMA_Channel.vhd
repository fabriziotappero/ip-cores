----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    usDMA_Transact - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  14.12.2006
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

entity usDMA_Transact is
    port (
      -- Around the Channel Buffer
      usTlp_Req          : OUT std_logic;
      usTlp_RE           : IN  std_logic;
      usTlp_Qout         : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      us_FC_stop         : IN  std_logic;
      us_Last_sof        : IN  std_logic;
      us_Last_eof        : IN  std_logic;
      FIFO_Data_Count    : IN  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
      FIFO_Empty         : IN  std_logic;
      FIFO_Reading       : IN  std_logic;

      -- Upstream reset from MWr channel
      usDMA_Channel_Rst  : IN  std_logic;

      -- Upstream Registers from MWr Channel
      DMA_us_PA          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_HA          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_BDA         : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Length      : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Control     : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      usDMA_BDA_eq_Null  : IN  std_logic;
      us_MWr_Param_Vec   : IN  std_logic_vector(6-1   downto 0);

      -- Calculation in advance, for better timing
      usHA_is_64b        : IN  std_logic;
      usBDA_is_64b       : IN  std_logic;

      -- Calculation in advance, for better timing
      usLeng_Hi19b_True  : IN  std_logic;
      usLeng_Lo7b_True   : IN  std_logic;

      -- from Cpl/D channel
      usDMA_dex_Tag      : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Upstream Control Signals from MWr Channel
      usDMA_Start        : IN  std_logic;   -- out of 1st dex
      usDMA_Stop         : IN  std_logic;   -- out of 1st dex

      -- Upstream Control Signals from CplD Channel
      usDMA_Start2       : IN  std_logic;   -- out of consecutive dex
      usDMA_Stop2        : IN  std_logic;   -- out of consecutive dex

      -- Upstream DMA Acknowledge to the start command
      DMA_Cmd_Ack        : OUT std_logic;

      -- To Interrupt module
      DMA_Done           : OUT std_logic;
      DMA_TimeOut        : OUT std_logic;
      DMA_Busy           : OUT std_logic;

      -- To Registers' Group
      DMA_us_Status      : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Additional
      cfg_dcommand       : IN  std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);

       -- Common ports
      trn_clk            : IN  std_logic;
      trn_reset_n        : IN  std_logic
    );

end entity usDMA_Transact;



architecture Behavioral of usDMA_Transact is

  -- Upstream DMA channel
  signal  Local_Reset_i        : std_logic;
  signal  DMA_Status_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  cfg_MPS              : std_logic_vector(C_CFG_MPS_BIT_TOP-C_CFG_MPS_BIT_BOT downto 0);


  signal  usDMA_MWr_Tag        : std_logic_vector(C_TAG_WIDTH-1 downto  0);


  -- DMA calculation
  COMPONENT DMA_Calculate
    PORT(
      -- Downstream Registers from MWr Channel
      DMA_PA             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);  -- EP   (local)
      DMA_HA             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);  -- Host (remote)
      DMA_BDA            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_Length         : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_Control        : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Calculation in advance, for better timing
      HA_is_64b          : IN  std_logic;
      BDA_is_64b         : IN  std_logic;

      -- Calculation in advance, for better timing
      Leng_Hi19b_True    : IN  std_logic;
      Leng_Lo7b_True     : IN  std_logic;


      -- Parameters fed to DMA_FSM
      DMA_PA_Loaded      : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_PA_Var         : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_HA_Var         : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      DMA_BDA_fsm        : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      BDA_is_64b_fsm     : OUT std_logic;
      DMA_0_Leng         : OUT std_logic;

      -- Only for downstream channel
      DMA_PA_Snout       : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_BAR_Number     : OUT std_logic_vector(C_TAGBAR_BIT_TOP-C_TAGBAR_BIT_BOT downto 0);

      -- 
      DMA_Snout_Length   : OUT std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
      DMA_Body_Length    : OUT std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
      DMA_Tail_Length    : OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0);


      -- Engine control signals
      DMA_Start          : IN  std_logic;
      DMA_Start2         : IN  std_logic;   -- out of consecutive dex

      -- Control signals to FSM
      No_More_Bodies     : OUT std_logic;
      ThereIs_Snout      : OUT std_logic;
      ThereIs_Body       : OUT std_logic;
      ThereIs_Tail       : OUT std_logic;
      ThereIs_Dex        : OUT std_logic;
      HA64bit            : OUT std_logic;
      Addr_Inc           : OUT std_logic;

      -- FSM indicators
      State_Is_LoadParam : IN  std_logic;
      State_Is_Snout     : IN  std_logic;
      State_Is_Body      : IN  std_logic;
--      State_Is_Tail      : IN  std_logic;


      -- Additional
      Param_Max_Cfg      : IN  std_logic_vector(2 downto 0);

      -- Common ports
      dma_clk            : IN  std_logic;
      dma_reset          : IN  std_logic
      );
  END COMPONENT;

  signal  usDMA_PA_Loaded      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  usDMA_PA_Var         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  usDMA_HA_Var         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  usDMA_BDA_fsm        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  usBDA_is_64b_fsm     : std_logic;
  signal  usDMA_0_Leng         : std_logic;

  signal  usDMA_PA_snout       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  usDMA_BAR_Number     : std_logic_vector(C_TAGBAR_BIT_TOP-C_TAGBAR_BIT_BOT downto 0);

  signal  usDMA_Snout_Length   : std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
  signal  usDMA_Body_Length    : std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
  signal  usDMA_Tail_Length    : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0);

  signal  usNo_More_Bodies     : std_logic;
  signal  usThereIs_Snout      : std_logic;
  signal  usThereIs_Body       : std_logic;
  signal  usThereIs_Tail       : std_logic;
  signal  usThereIs_Dex        : std_logic;
  signal  usHA64bit            : std_logic;
  signal  us_AInc              : std_logic;

  signal  us_Last_sof_or       : std_logic;
  signal  us_Last_eof_or       : std_logic;


  -- DMA state machine
  COMPONENT DMA_FSM
    PORT(
      -- Fixed information for 1st header of TLP: MRd/MWr
      TLP_Has_Payload    : IN  std_logic;
      TLP_Hdr_is_4DW     : IN  std_logic;
      DMA_Addr_Inc       : IN  std_logic;

      DMA_BAR_Number     : IN  std_logic_vector(C_TAGBAR_BIT_TOP-C_TAGBAR_BIT_BOT downto 0);

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

      DMA_Snout_Length   : IN  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
      DMA_Body_Length    : IN  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
      DMA_Tail_Length    : IN  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0);

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
  END COMPONENT;


  -- FSM state indicators
  signal  usState_Is_LoadParam : std_logic;
  signal  usState_Is_Snout     : std_logic;
  signal  usState_Is_Body      : std_logic;
  signal  usState_Is_Tail      : std_logic;

  signal  usChBuf_ValidRd      : std_logic;
  signal  usBDA_nAligned       : std_logic;
  signal  usDMA_TimeOut_i      : std_logic;
  signal  usDMA_Busy_i         : std_logic;
  signal  usDMA_Done_i         : std_logic;


  -- Built-in single-port fifo as downstream DMA channel buffer
  --   128-bit wide, for 64-bit address
  component v5sfifo_15x128
    port (
          clk                  : IN  std_logic;
          rst                  : IN  std_logic;
          prog_full            : OUT std_logic;
--          wr_clk             : IN  std_logic;
          wr_en                : IN  std_logic;
          din                  : IN  std_logic_VECTOR(C_CHANNEL_BUF_WIDTH-1 downto 0);
          full                 : OUT std_logic;
--          rd_clk             : IN  std_logic;
          rd_en                : IN  std_logic;
          dout                 : OUT std_logic_VECTOR(C_CHANNEL_BUF_WIDTH-1 downto 0);
          prog_empty           : OUT std_logic;
          empty                : OUT std_logic
    );
  end component;


  -- Signal with DMA_upstream channel abstract buffer
  signal  usTlp_din            : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  usTlp_Qout_wire      : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  usTlp_Qout_reg       : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  usTlp_Qout_i         : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  usTlp_RE_i           : std_logic;
  signal  usTlp_RE_i_r1        : std_logic;
  signal  usTlp_we             : std_logic;
  signal  usTlp_empty_i        : std_logic;
  signal  usTlp_full           : std_logic;
  signal  usTlp_prog_Full      : std_logic;

  signal  usTlp_pempty         : std_logic;
  signal  usTlp_Npempty_r1     : std_logic;
  signal  usTlp_Nempty_r1      : std_logic;
  signal  usTlp_empty_r1       : std_logic;
  signal  usTlp_empty_r2       : std_logic;
  signal  usTlp_empty_r3       : std_logic;
  signal  usTlp_empty_r4       : std_logic;
  signal  usTlp_prog_Full_r1   : std_logic;

  -- Request for output arbitration
  signal  usTlp_NoMoreReq      : std_logic;
  signal  usTlp_Req_i          : std_logic;
  signal  usTlp_nReq_r1        : std_logic;
  signal  FIFO_Reading_r1      : std_logic;
  signal  FIFO_Reading_r2      : std_logic;
  signal  FIFO_Reading_r3p     : std_logic;
  signal  usTlp_MWr_Leng       : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);

  -- Busy/Done state bits generation
  type FSM_Request is         (
                                 REQST_Idle
                               , REQST_1Read
                               , REQST_Decision
                               , REQST_nFIFO_Req
                               , REQST_Quantity
                               , REQST_FIFO_Req
                               );

  signal FSM_REQ_us           : FSM_Request;

begin

   -- DMA done signal
   DMA_Done           <= usDMA_Done_i;
   DMA_TimeOut        <= usDMA_TimeOut_i;
   DMA_Busy           <= usDMA_Busy_i;

   -- connecting FIFO's signals
   usTlp_Qout         <= usTlp_Qout_i;
   usTlp_Req          <= usTlp_Req_i and not FIFO_Reading_r3p;

   -- sent packet frames
   us_Last_sof_or     <= us_Last_sof or usDMA_0_Leng;
   us_Last_eof_or     <= us_Last_eof or usDMA_0_Leng;

   -- positive local reset
--   Local_Reset_i      <= not trn_reset_n or usDMA_Channel_Rst;
   Local_Reset_i      <= usDMA_Channel_Rst;

   -- Max Payload Size bits
   cfg_MPS            <= cfg_dcommand(C_CFG_MPS_BIT_TOP downto C_CFG_MPS_BIT_BOT);


   -- Kernel Engine
   us_DMA_Calculation:
   DMA_Calculate
   PORT MAP(

            DMA_PA             => DMA_us_PA        ,
            DMA_HA             => DMA_us_HA        ,
            DMA_BDA            => DMA_us_BDA       ,
            DMA_Length         => DMA_us_Length    ,
            DMA_Control        => DMA_us_Control   ,

            HA_is_64b          => usHA_is_64b        ,
            BDA_is_64b         => usBDA_is_64b       ,


            Leng_Hi19b_True    => usLeng_Hi19b_True  ,
            Leng_Lo7b_True     => usLeng_Lo7b_True   ,


            DMA_PA_Loaded      => usDMA_PA_Loaded  ,
            DMA_PA_Var         => usDMA_PA_Var     ,
            DMA_HA_Var         => usDMA_HA_Var     ,

            DMA_BDA_fsm        => usDMA_BDA_fsm    ,
            BDA_is_64b_fsm     => usBDA_is_64b_fsm ,
            DMA_0_Leng         => usDMA_0_Leng     ,

            -- Only for downstream channel
            DMA_PA_Snout       => usDMA_PA_snout   ,
            DMA_BAR_Number     => usDMA_BAR_Number ,

            -- Lengths
            DMA_Snout_Length   => usDMA_Snout_Length ,
            DMA_Body_Length    => usDMA_Body_Length  ,
            DMA_Tail_Length    => usDMA_Tail_Length  ,


            -- Control signals to FSM
            No_More_Bodies     => usNo_More_Bodies   ,
            ThereIs_Snout      => usThereIs_Snout    ,
            ThereIs_Body       => usThereIs_Body     ,
            ThereIs_Tail       => usThereIs_Tail     ,
            ThereIs_Dex        => usThereIs_Dex      ,
            HA64bit            => usHA64bit          ,
            Addr_Inc           => us_AInc            ,


            DMA_Start          => usDMA_Start       ,
            DMA_Start2         => usDMA_Start2      ,

            State_Is_LoadParam => usState_Is_LoadParam ,
            State_Is_Snout     => usState_Is_Snout     ,
            State_Is_Body      => usState_Is_Body      ,
--            State_Is_Tail      => usState_Is_Tail      ,


            Param_Max_Cfg      => cfg_MPS       ,

            dma_clk            => trn_clk       ,
            dma_reset          => Local_Reset_i     
   );


   -- Kernel FSM
   us_DMA_StateMachine:
   DMA_FSM
   PORT MAP(
            TLP_Has_Payload    => '1'               ,
            TLP_Hdr_is_4DW     => usHA64bit         ,
            DMA_Addr_Inc       => us_AInc           ,

            DMA_BAR_Number     => usDMA_BAR_Number  ,

            DMA_Start          => usDMA_Start       ,
            DMA_Start2         => usDMA_Start2      ,
            DMA_Stop           => usDMA_Stop        ,
            DMA_Stop2          => usDMA_Stop2       ,

            -- Control signals to FSM
            No_More_Bodies     => usNo_More_Bodies   ,
            ThereIs_Snout      => usThereIs_Snout    ,
            ThereIs_Body       => usThereIs_Body     ,
            ThereIs_Tail       => usThereIs_Tail     ,
            ThereIs_Dex        => usThereIs_Dex      ,


            DMA_PA_Loaded      => usDMA_PA_Loaded  ,
            DMA_PA_Var         => usDMA_PA_Var     ,
            DMA_HA_Var         => usDMA_HA_Var     ,

            DMA_BDA_fsm        => usDMA_BDA_fsm    ,
            BDA_is_64b_fsm     => usBDA_is_64b_fsm ,


            DMA_Snout_Length   => usDMA_Snout_Length ,
            DMA_Body_Length    => usDMA_Body_Length  ,
            DMA_Tail_Length    => usDMA_Tail_Length  ,


            ChBuf_ValidRd      => usChBuf_ValidRd    ,
            BDA_nAligned       => usBDA_nAligned     ,
            DMA_TimeOut        => usDMA_TimeOut_i    ,
            DMA_Busy           => usDMA_Busy_i       ,
            DMA_Done           => usDMA_Done_i       ,
--            DMA_Done_Rise      => open             ,

            Pkt_Tag            => usDMA_MWr_Tag      ,
            Dex_Tag            => usDMA_dex_Tag      ,


            Done_Condition_1   => '1'                ,
            Done_Condition_2   => usTlp_empty_r3     ,
            Done_Condition_3   => usTlp_nReq_r1      ,
            Done_Condition_4   => us_Last_sof_or     ,
            Done_Condition_5   => us_Last_eof_or     ,
            Done_Condition_6   => usTlp_NoMoreReq    ,

            us_MWr_Param_Vec   => us_MWr_Param_Vec   ,
            ChBuf_aFull        => usTlp_Npempty_r1   ,  -- usTlp_prog_Full_r1 ,
            ChBuf_WrEn         => usTlp_we           ,
            ChBuf_WrDin        => usTlp_din          ,

            State_Is_LoadParam => usState_Is_LoadParam ,
            State_Is_Snout     => usState_Is_Snout     ,
            State_Is_Body      => usState_Is_Body      ,
            State_Is_Tail      => usState_Is_Tail      ,

            DMA_Cmd_Ack        => DMA_Cmd_Ack     ,


            dma_clk            => trn_clk         ,
            dma_reset          => Local_Reset_i     
   );

   usChBuf_ValidRd     <= usTlp_RE;  -- usTlp_RE_i and not usTlp_empty_i;

-- -------------------------------------------------
-- 
   DMA_us_Status       <= DMA_Status_i;
-- 
-- Synchronous output: DMA_Status_i
-- 
   US_DMA_Status_Concat:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         DMA_Status_i <= (OTHERS =>'0');
      elsif trn_clk'event and trn_clk = '1' then

         DMA_Status_i <= (
                          CINT_BIT_DMA_STAT_NALIGN  => usBDA_nAligned,
                          CINT_BIT_DMA_STAT_TIMEOUT => usDMA_TimeOut_i,
                          CINT_BIT_DMA_STAT_BDANULL => usDMA_BDA_eq_Null,
                          CINT_BIT_DMA_STAT_BUSY    => usDMA_Busy_i,
                          CINT_BIT_DMA_STAT_DONE    => usDMA_Done_i,
                          Others                    => '0'
                         );

      end if;
   end process;


-- -----------------------------------
-- Synchronous Register: usDMA_MWr_Tag
   FSM_usDMA_usDMA_MWr_Tag:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         usDMA_MWr_Tag     <= C_TAG0_DMA_US_MWR;

      elsif trn_clk'event and trn_clk = '1' then

         if    usState_Is_Snout='1'
            or usState_Is_Body='1'
            or usState_Is_Tail='1'
            then
                -- Only 4 lower bits increment, higher 4 stay
            usDMA_MWr_Tag(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0) 
         <= usDMA_MWr_Tag(C_TAG_WIDTH-C_TAG_DECODE_BITS-1 downto 0) 
          + CONV_STD_LOGIC_VECTOR(1, C_TAG_WIDTH-C_TAG_DECODE_BITS);
         else
            usDMA_MWr_Tag <= usDMA_MWr_Tag;
         end if;

      end if;
   end process;


   -- -------------------------------------------------
   -- us MWr/MRd TLP Buffer
   -- -------------------------------------------------
   US_TLP_Buffer:
   v5sfifo_15x128
      port map (
         clk           => trn_clk,
         rst           => Local_Reset_i,
         prog_full     => usTlp_prog_Full ,
--         wr_clk        => trn_clk,
         wr_en         => usTlp_we,
         din           => usTlp_din,
         full          => usTlp_full,
--         rd_clk        => trn_clk,
         rd_en         => usTlp_RE_i,
         dout          => usTlp_Qout_wire,
         prog_empty    => usTlp_pempty,
         empty         => usTlp_empty_i
       );

-- ---------------------------------------------
--  Synchronous delay
-- 
   Synch_Delay_ren_Qout:
   process (Local_Reset_i, trn_clk )
   begin
      if Local_Reset_i = '1' then
         FIFO_Reading_r1 <= '0';
         FIFO_Reading_r2 <= '0';
         FIFO_Reading_r3p<= '0';
         usTlp_RE_i_r1   <= '0';
         usTlp_nReq_r1   <= '0';
         usTlp_Qout_reg  <= (OTHERS=>'0');
         usTlp_MWr_Leng  <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then
         FIFO_Reading_r1 <= FIFO_Reading;
         FIFO_Reading_r2 <= FIFO_Reading_r1;
         FIFO_Reading_r3p<= FIFO_Reading_r1 or FIFO_Reading_r2;
         usTlp_RE_i_r1  <= usTlp_RE_i;
         usTlp_nReq_r1  <= not usTlp_Req_i;
         if usTlp_RE_i_r1='1' then
            usTlp_Qout_reg <= usTlp_Qout_wire;
            usTlp_MWr_Leng <= usTlp_Qout_wire(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
         else
            usTlp_Qout_reg <= usTlp_Qout_reg;
            usTlp_MWr_Leng <= usTlp_MWr_Leng;
         end if;

      end if;
   end process;


-- ---------------------------------------------
--  Request for arbitration
-- 
   Synch_Req_Proc:
   process (Local_Reset_i, trn_clk )
   begin
      if Local_Reset_i = '1' then
         usTlp_RE_i     <= '0';
         usTlp_Req_i    <= '0';
         usTlp_NoMoreReq<= '1';
         FSM_REQ_us     <= REQST_IDLE;

      elsif trn_clk'event and trn_clk = '1' then

         case FSM_REQ_us  is

           when REQST_IDLE  =>
             usTlp_NoMoreReq <= '1';
             if usTlp_empty_i = '0' then
               usTlp_RE_i   <= '1';
               usTlp_Req_i  <= '0';
               FSM_REQ_us   <= REQST_1Read;
             else
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <= '0';
               FSM_REQ_us   <= REQST_IDLE;
             end if;

           when REQST_1Read  =>
             usTlp_NoMoreReq <= '0';
             usTlp_RE_i   <= '0';
             usTlp_Req_i  <= '0';
             FSM_REQ_us   <= REQST_Decision;

           when REQST_Decision  =>
             usTlp_NoMoreReq <= '0';
             if usTlp_Qout_wire(C_CHBUF_FMT_BIT_TOP) = '1'  -- Has Payload
               and usTlp_Qout_wire(C_CHBUF_DMA_BAR_BIT_TOP downto C_CHBUF_DMA_BAR_BIT_BOT)
                   =CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) 
               then
               usTlp_RE_i  <= '0';
               usTlp_Req_i <= '0';
               FSM_REQ_us  <= REQST_Quantity;
             else
               usTlp_RE_i  <= '0';
               usTlp_Req_i <=  not usDMA_Stop
                           and not usDMA_Stop2
                           and not us_FC_stop;
               FSM_REQ_us  <= REQST_nFIFO_Req;
             end if;

           when REQST_nFIFO_Req  =>
             usTlp_NoMoreReq <= '0';
             if usTlp_RE = '1' then
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <= '0';
               FSM_REQ_us   <= REQST_IDLE;
             else
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <=  not usDMA_Stop
                            and not usDMA_Stop2
                            and not us_FC_stop;
               FSM_REQ_us   <= REQST_nFIFO_Req;
             end if;

           when REQST_Quantity  =>
             usTlp_NoMoreReq <= '0';
             if usTlp_RE = '1' then
               usTlp_RE_i   <= '1';
               usTlp_Req_i  <= '0';
               FSM_REQ_us   <= REQST_Quantity;
             elsif (FIFO_Data_Count(C_FIFO_DC_WIDTH downto C_TLP_FLD_WIDTH_OF_LENG)=C_ALL_ZEROS(C_FIFO_DC_WIDTH downto C_TLP_FLD_WIDTH_OF_LENG)
               and FIFO_Data_Count(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) < usTlp_MWr_Leng(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0))
               or  FIFO_Empty='1'
               then
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <= '0';
               FSM_REQ_us   <= REQST_Quantity;
             else
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <=  not usDMA_Stop
                            and not usDMA_Stop2
                            and not us_FC_stop;
               FSM_REQ_us   <= REQST_FIFO_Req;
             end if;

           when REQST_FIFO_Req  =>
             usTlp_NoMoreReq <= '0';
             if (FIFO_Data_Count(C_FIFO_DC_WIDTH downto C_TLP_FLD_WIDTH_OF_LENG)=C_ALL_ZEROS(C_FIFO_DC_WIDTH downto C_TLP_FLD_WIDTH_OF_LENG)
               and FIFO_Data_Count(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) < usTlp_MWr_Leng(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0))
               or  FIFO_Empty='1'
               then
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <= '0';
               FSM_REQ_us   <= REQST_Quantity;
             elsif usTlp_RE = '1' then
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <= '0';
               FSM_REQ_us   <= REQST_IDLE;
             else
               usTlp_RE_i   <= '0';
               usTlp_Req_i  <=  not usDMA_Stop
                            and not usDMA_Stop2
                            and not us_FC_stop;
               FSM_REQ_us   <= REQST_FIFO_Req;
             end if;

           when OTHERS  =>
             usTlp_NoMoreReq <= '1';
             usTlp_RE_i     <= '0';
             usTlp_Req_i    <= '0';
             FSM_REQ_us     <= REQST_IDLE;

         end case;

      end if;
   end process;


-- ---------------------------------------------
--  Sending usTlp_Qout
-- 
   Synch_usTlp_Qout:
   process (Local_Reset_i, trn_clk )
   begin
      if Local_Reset_i = '1' then
         usTlp_Qout_i   <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         if usTlp_RE = '1' then
            usTlp_Qout_i  <= usTlp_Qout_reg;
         else
            usTlp_Qout_i  <= usTlp_Qout_i;
         end if;

      end if;
   end process;


-- ---------------------------------------------
--  Delay of Empty and prog_Full
-- 
   Synch_Delay_empty_and_full:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         usTlp_Npempty_r1   <= not usTlp_pempty;
         usTlp_Nempty_r1    <= not usTlp_empty_i;
         usTlp_empty_r1     <= usTlp_empty_i;
         usTlp_empty_r2     <= usTlp_empty_r1;
         usTlp_empty_r3     <= usTlp_empty_r2;
         usTlp_empty_r4     <= usTlp_empty_r3;
         usTlp_prog_Full_r1 <= usTlp_prog_Full;
--         usTlp_Req_i        <= not usTlp_empty_i 
--                           and not usDMA_Stop
--                           and not usDMA_Stop2
--                           and not us_FC_stop
--                           ;
      end if;
   end process;


end architecture Behavioral;

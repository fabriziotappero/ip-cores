----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    dsDMA_Transact - Behavioral 
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

entity dsDMA_Transact is
    port (
      -- downstream DMA Channel Buffer
      MRd_dsp_Req        : OUT std_logic;
      MRd_dsp_RE         : IN  std_logic;
      MRd_dsp_Qout       : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- Downstream reset from MWr channel
      dsDMA_Channel_Rst  : IN  std_logic;

      -- Downstream Registers from MWr Channel
      DMA_ds_PA          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_HA          : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_BDA         : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Length      : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Control     : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      dsDMA_BDA_eq_Null  : IN  std_logic;

      -- Calculation in advance, for better timing
      dsHA_is_64b        : IN  std_logic;
      dsBDA_is_64b       : IN  std_logic;

      -- Calculation in advance, for better timing
      dsLeng_Hi19b_True  : IN  std_logic;
      dsLeng_Lo7b_True   : IN  std_logic;

      -- from Cpl/D channel
      dsDMA_dex_Tag      : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Downstream Control Signals from MWr Channel
      dsDMA_Start        : IN  std_logic;   -- out of 1st dex
      dsDMA_Stop         : IN  std_logic;   -- out of 1st dex


      -- Downstream Control Signals from CplD Channel
      dsDMA_Start2       : IN  std_logic;   -- out of consecutive dex
      dsDMA_Stop2        : IN  std_logic;   -- out of consecutive dex

      -- Downstream DMA Acknowledge to the start command
      DMA_Cmd_Ack        : OUT std_logic;

      -- Downstream Handshake Signals with CplD Channel for Busy/Done
      Tag_Map_Clear      : IN  std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);
      FC_pop             : IN  std_logic;

      -- Downstream tRAM port A write request
      tRAM_weB           : OUT std_logic;
      tRAM_AddrB         : OUT std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
      tRAM_dinB          : OUT std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);

      -- To Interrupt module
      DMA_Done           : OUT std_logic;
      DMA_TimeOut        : OUT std_logic;
      DMA_Busy           : OUT std_logic;

      -- To Tx Port
      DMA_ds_Status      : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Additional
      cfg_dcommand       : IN  std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);

      -- Common ports
      trn_clk            : IN  std_logic;
      trn_reset_n        : IN  std_logic
    );

end entity dsDMA_Transact;



architecture Behavioral of dsDMA_Transact is

  signal  FC_push              : std_logic;
  signal  FC_counter           : std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
  signal  dsFC_stop            : std_logic;
  signal  dsFC_stop_128B       : std_logic;
  signal  dsFC_stop_256B       : std_logic;
  signal  dsFC_stop_512B       : std_logic;
  signal  dsFC_stop_1024B      : std_logic;
  signal  dsFC_stop_2048B      : std_logic;
  signal  dsFC_stop_4096B      : std_logic;

  -- Reset
  signal  Local_Reset_i        : std_logic;

  signal  cfg_MRS              : std_logic_vector(C_CFG_MRS_BIT_TOP-C_CFG_MRS_BIT_BOT downto 0);

  -- Tag RAM port B write
  signal  tRAM_dinB_i          : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);
  signal  tRAM_AddrB_i         : std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
  signal  tRAM_weB_i           : std_logic;


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

  signal  dsDMA_PA_Loaded      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  dsDMA_PA_Var         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  dsDMA_HA_Var         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  dsDMA_BDA_fsm        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  dsBDA_is_64b_fsm     : std_logic;

  signal  dsDMA_PA_snout       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal  dsDMA_BAR_Number     : std_logic_vector(C_TAGBAR_BIT_TOP-C_TAGBAR_BIT_BOT downto 0);

  signal  dsDMA_Snout_Length   : std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
  signal  dsDMA_Body_Length    : std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
  signal  dsDMA_Tail_Length    : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0);

  signal  dsNo_More_Bodies     : std_logic;
  signal  dsThereIs_Snout      : std_logic;
  signal  dsThereIs_Body       : std_logic;
  signal  dsThereIs_Tail       : std_logic;
  signal  dsThereIs_Dex        : std_logic;
  signal  dsHA64bit            : std_logic;
  signal  ds_AInc              : std_logic;

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

  signal  Tag_DMA_dsp          : std_logic_vector(C_TAG_WIDTH-1 downto  0);

  -- FSM state indicators
  signal  dsState_Is_LoadParam : std_logic;
  signal  dsState_Is_Snout     : std_logic;
  signal  dsState_Is_Body      : std_logic;
  signal  dsState_Is_Tail      : std_logic;

  signal  dsChBuf_ValidRd      : std_logic;
  signal  dsBDA_nAligned       : std_logic;
  signal  dsDMA_TimeOut_i      : std_logic;
  signal  dsDMA_Busy_i         : std_logic;
  signal  dsDMA_Done_i         : std_logic;

  signal  DMA_Status_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  ---------------------------------------------------------------
  --    Done state identification uses 2^C_TAGRAM_AWIDTH bits, 2 stages logic
  signal  Tag_Map_Bits         : std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);
  signal  Tag_Map_filling      : std_logic_vector(C_SUB_TAG_MAP_WIDTH-1 downto 0);
  signal  All_CplD_have_come   : std_logic;


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

  -- Signal with DMA_downstream channel FIFO
  signal  MRd_dsp_din          : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  MRd_dsp_dout         : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  MRd_dsp_re_i         : std_logic;
  signal  MRd_dsp_we           : std_logic;
  signal  MRd_dsp_empty_i      : std_logic;
  signal  MRd_dsp_full         : std_logic;
  signal  MRd_dsp_prog_Full    : std_logic;

  signal  MRd_dsp_prog_Full_r1 : std_logic;
  signal  MRd_dsp_re_r1        : std_logic;
  signal  MRd_dsp_empty_r1     : std_logic;

  -- Request for output arbitration
  signal  MRd_dsp_Req_i        : std_logic;


begin

   -- DMA done signal
   DMA_Done          <= dsDMA_Done_i;
   DMA_TimeOut       <= dsDMA_TimeOut_i;
   DMA_Busy          <= dsDMA_Busy_i;

   -- connecting FIFO's signals
   MRd_dsp_Qout      <= MRd_dsp_dout;
   MRd_dsp_re_i      <= MRd_dsp_RE;
   MRd_dsp_Req       <= MRd_dsp_Req_i;

   --  tag RAM write request signals
   tRAM_weB          <= tRAM_weB_i;
   tRAM_AddrB        <= tRAM_AddrB_i;
   tRAM_dinB         <= tRAM_dinB_i;


   -- positive local reset
--   Local_Reset_i     <= not trn_reset_n or dsDMA_Channel_Rst;
   Local_Reset_i     <= dsDMA_Channel_Rst;

   -- Max Read Request Size bits
   cfg_MRS           <= cfg_dcommand(C_CFG_MRS_BIT_TOP downto C_CFG_MRS_BIT_BOT);


   -- Kernel Engine
   ds_DMA_Calculation:
   DMA_Calculate
   PORT MAP(

            DMA_PA             => DMA_ds_PA        ,
            DMA_HA             => DMA_ds_HA        ,
            DMA_BDA            => DMA_ds_BDA       ,
            DMA_Length         => DMA_ds_Length    ,
            DMA_Control        => DMA_ds_Control   ,

            HA_is_64b          => dsHA_is_64b        ,
            BDA_is_64b         => dsBDA_is_64b       ,

            Leng_Hi19b_True    => dsLeng_Hi19b_True  ,
            Leng_Lo7b_True     => dsLeng_Lo7b_True   ,

            DMA_PA_Loaded      => dsDMA_PA_Loaded  ,
            DMA_PA_Var         => dsDMA_PA_Var     ,
            DMA_HA_Var         => dsDMA_HA_Var     ,

            DMA_BDA_fsm        => dsDMA_BDA_fsm    ,
            BDA_is_64b_fsm     => dsBDA_is_64b_fsm ,
            DMA_0_Leng         => open             ,

            -- Only for downstream channel
            DMA_PA_Snout       => dsDMA_PA_snout   ,
            DMA_BAR_Number     => dsDMA_BAR_Number ,

            -- Lengths
            DMA_Snout_Length   => dsDMA_Snout_Length ,
            DMA_Body_Length    => dsDMA_Body_Length  ,
            DMA_Tail_Length    => dsDMA_Tail_Length  ,

            -- Control signals to FSM
            No_More_Bodies     => dsNo_More_Bodies   ,
            ThereIs_Snout      => dsThereIs_Snout    ,
            ThereIs_Body       => dsThereIs_Body     ,
            ThereIs_Tail       => dsThereIs_Tail     ,
            ThereIs_Dex        => dsThereIs_Dex      ,
            HA64bit            => dsHA64bit          ,
            Addr_Inc           => ds_AInc            ,


            DMA_Start          => dsDMA_Start       ,
            DMA_Start2         => dsDMA_Start2      ,

            State_Is_LoadParam => dsState_Is_LoadParam ,
            State_Is_Snout     => dsState_Is_Snout     ,
            State_Is_Body      => dsState_Is_Body      ,
--            State_Is_Tail      => dsState_Is_Tail      ,

            Param_Max_Cfg      => cfg_MRS       ,

            dma_clk            => trn_clk       ,
            dma_reset          => Local_Reset_i     
   );


   -- Kernel FSM
   ds_DMA_StateMachine:
   DMA_FSM
   PORT MAP(
            TLP_Has_Payload    => '0'               ,
            TLP_Hdr_is_4DW     => dsHA64bit         ,
            DMA_Addr_Inc       => '0'               ,    -- of any value

            DMA_BAR_Number     => dsDMA_BAR_Number  ,

            DMA_Start          => dsDMA_Start       ,
            DMA_Start2         => dsDMA_Start2      ,
            DMA_Stop           => dsDMA_Stop        ,
            DMA_Stop2          => dsDMA_Stop2       ,

            -- Control signals to FSM
            No_More_Bodies     => dsNo_More_Bodies   ,
            ThereIs_Snout      => dsThereIs_Snout    ,
            ThereIs_Body       => dsThereIs_Body     ,
            ThereIs_Tail       => dsThereIs_Tail     ,
            ThereIs_Dex        => dsThereIs_Dex      ,

            DMA_PA_Loaded      => dsDMA_PA_Loaded  ,
            DMA_PA_Var         => dsDMA_PA_Var     ,
            DMA_HA_Var         => dsDMA_HA_Var     ,

            DMA_BDA_fsm        => dsDMA_BDA_fsm    ,
            BDA_is_64b_fsm     => dsBDA_is_64b_fsm ,

            DMA_Snout_Length   => dsDMA_Snout_Length ,
            DMA_Body_Length    => dsDMA_Body_Length  ,
            DMA_Tail_Length    => dsDMA_Tail_Length  ,

            ChBuf_ValidRd      => dsChBuf_ValidRd,
            BDA_nAligned       => dsBDA_nAligned ,
            DMA_TimeOut        => dsDMA_TimeOut_i,
            DMA_Busy           => dsDMA_Busy_i   ,
            DMA_Done           => dsDMA_Done_i   ,
--            DMA_Done_Rise      => open         ,

            Pkt_Tag            => Tag_DMA_dsp        ,
            Dex_Tag            => dsDMA_dex_Tag      ,

            Done_Condition_1   => '1' ,
            Done_Condition_2   => MRd_dsp_empty_r1   ,
            Done_Condition_3   => '1' ,
            Done_Condition_4   => '1' ,
            Done_Condition_5   => All_CplD_have_come ,
            Done_Condition_6   => '1' ,

            us_MWr_Param_Vec   => "000000"             ,
            ChBuf_aFull        => MRd_dsp_prog_Full_r1 ,
            ChBuf_WrEn         => MRd_dsp_we        ,
            ChBuf_WrDin        => MRd_dsp_din       ,

            State_Is_LoadParam => dsState_Is_LoadParam ,
            State_Is_Snout     => dsState_Is_Snout     ,
            State_Is_Body      => dsState_Is_Body      ,
            State_Is_Tail      => dsState_Is_Tail      ,

            DMA_Cmd_Ack        => DMA_Cmd_Ack     ,

            dma_clk            => trn_clk       ,
            dma_reset          => Local_Reset_i     
   );

   dsChBuf_ValidRd     <= MRd_dsp_RE;   -- MRd_dsp_re_i and not MRd_dsp_empty_i;

-- -------------------------------------------------
--
   DMA_ds_Status       <= DMA_Status_i;
-- 
-- Synchronous output: DMA_Status
-- 
   DS_DMA_Status_Concat:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         DMA_Status_i <= (OTHERS =>'0');

      elsif trn_clk'event and trn_clk = '1' then

         DMA_Status_i <= (	
                          CINT_BIT_DMA_STAT_NALIGN  => dsBDA_nAligned,
                          CINT_BIT_DMA_STAT_TIMEOUT => dsDMA_TimeOut_i,
                          CINT_BIT_DMA_STAT_BDANULL => dsDMA_BDA_eq_Null,
                          CINT_BIT_DMA_STAT_BUSY    => dsDMA_Busy_i,
                          CINT_BIT_DMA_STAT_DONE    => dsDMA_Done_i,
                          Others                    => '0'
                         );

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: tRAM_weB
--                  tRAM_AddrB
--                  tRAM_dinB
--
   FSM_dsDMA_tRAM_PortB:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         tRAM_weB_i     <= '0';
         tRAM_AddrB_i   <= (OTHERS =>'1');
         tRAM_dinB_i    <= (OTHERS =>'0');
      elsif trn_clk'event and trn_clk = '1' then

         tRAM_AddrB_i   <= Tag_DMA_dsp(C_TAGRAM_AWIDTH-1 downto 0);

         tRAM_weB_i     <= dsState_Is_Snout
                        or dsState_Is_Body
                        or dsState_Is_Tail;

         if    dsState_Is_Snout='1' then
               tRAM_dinB_i  <= 
                               ds_AInc           -- DMA_ds_Control(CINT_BIT_DMA_CTRL_AINC)
                             & dsDMA_BAR_Number  -- (C_TAGBAR_BIT_TOP-C_TAGBAR_BIT_BOT downto 0)
                             & dsDMA_PA_snout(C_TAGBAR_BIT_BOT-1 downto 2)&"00"
                             ;
         elsif dsState_Is_Body='1' then
               tRAM_dinB_i  <= 
                               ds_AInc           -- DMA_ds_Control(CINT_BIT_DMA_CTRL_AINC)
                             & dsDMA_BAR_Number  -- (C_TAGBAR_BIT_TOP-C_TAGBAR_BIT_BOT downto 0)
                             & dsDMA_PA_Var(C_TAGBAR_BIT_BOT-1 downto 2) &"00"
                             ;
         elsif dsState_Is_Tail='1' then
               tRAM_dinB_i  <= 
                               ds_AInc           -- DMA_ds_Control(CINT_BIT_DMA_CTRL_AINC)
                             & dsDMA_BAR_Number  -- (C_TAGBAR_BIT_TOP-C_TAGBAR_BIT_BOT downto 0)
                             & dsDMA_PA_Var(C_TAGBAR_BIT_BOT-1 downto 2) &"00"
                             ;
         else
               tRAM_dinB_i  <= (Others=>'0');

         end if;

      end if;
   end process;


-- ------------------------------------------
--  Loop:  Tag_Map
-- 
   Sync_Tag_set_reset_Bits:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Tag_Map_Bits   <= (Others=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         FOR j IN 0 TO C_TAG_MAP_WIDTH-1 LOOP
            if  tRAM_AddrB_i=CONV_STD_LOGIC_VECTOR(j, C_TAGRAM_AWIDTH) and tRAM_weB_i='1' then
                Tag_Map_Bits(j)   <= '1';
            elsif Tag_Map_Clear(j)='1' then
                Tag_Map_Bits(j)   <= '0';
            else
                Tag_Map_Bits(j)   <= Tag_Map_Bits(j);
            end if;
         END LOOP;

      end if;
   end process;


-- ------------------------------------------
-- Determination: All_CplD_have_come
-- 
   Sync_Reg_All_CplD_have_come:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Tag_Map_filling     <= (OTHERS =>'0');
         All_CplD_have_come  <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         FOR k IN 0 TO C_SUB_TAG_MAP_WIDTH-1 LOOP
            if  Tag_Map_Bits((C_TAG_MAP_WIDTH/C_SUB_TAG_MAP_WIDTH)*(k+1)-1 downto (C_TAG_MAP_WIDTH/C_SUB_TAG_MAP_WIDTH)*k)
               = C_ALL_ZEROS((C_TAG_MAP_WIDTH/C_SUB_TAG_MAP_WIDTH)*(k+1)-1 downto (C_TAG_MAP_WIDTH/C_SUB_TAG_MAP_WIDTH)*k)
               then
                Tag_Map_filling(k)   <= '1';
            else
                Tag_Map_filling(k)   <= '0';
            end if;
         END LOOP;

         -- final signal :  All_CplD_have_come
         if    Tag_Map_filling=C_ALL_ONES(C_SUB_TAG_MAP_WIDTH-1 downto 0) then
             All_CplD_have_come   <= '1';
         else
             All_CplD_have_come   <= '0';
         end if;


      end if;
   end process;



-- ------------------------------------------
-- Synchronous Output: Tag_DMA_dsp
-- 
   FSM_dsDMA_Tag_DMA_dsp:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         Tag_DMA_dsp    <= (OTHERS =>'0');

      elsif trn_clk'event and trn_clk = '1' then

         if    dsState_Is_Snout='1'
            or dsState_Is_Body='1'
            or dsState_Is_Tail='1'
            then
            Tag_DMA_dsp    <= '0' & dsDMA_BAR_Number(1)
                            & ( Tag_DMA_dsp(C_TAGRAM_AWIDTH-1 downto 0)
                              + CONV_STD_LOGIC_VECTOR(1, C_TAGRAM_AWIDTH));
         else
            Tag_DMA_dsp    <= '0' & dsDMA_BAR_Number(1)
                            & Tag_DMA_dsp(C_TAGRAM_AWIDTH-1 downto 0);
         end if;

      end if;
   end process;



   -- -------------------------------------------------
   -- ds MRd TLP Buffer
   -- -------------------------------------------------
   DMA_DSP_Buffer:
   v5sfifo_15x128
      port map (
         clk           => trn_clk,
         rst           => Local_Reset_i,
         prog_full     => MRd_dsp_prog_Full,
--         wr_clk        => trn_clk,
         wr_en         => MRd_dsp_we,
         din           => MRd_dsp_din,
         full          => MRd_dsp_full,
--         rd_clk        => trn_clk,
         rd_en         => MRd_dsp_re_i,
         dout          => MRd_dsp_dout,
         prog_empty    => open,
         empty         => MRd_dsp_empty_i
       );


-- ---------------------------------------------
--  Delay of Empty and prog_Full
-- 
   Synch_Delay_empty_and_full:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         MRd_dsp_re_r1        <= MRd_dsp_re_i;
         MRd_dsp_empty_r1     <= MRd_dsp_empty_i;
         MRd_dsp_prog_Full_r1 <= MRd_dsp_prog_Full;
         MRd_dsp_Req_i        <= not MRd_dsp_empty_i 
                             and not dsDMA_Stop
                             and not dsDMA_Stop2
                             and not dsFC_stop
                             ;
      end if;
   end process;


-- ------------------------------------------
-- Synchronous: FC_push
-- 
   Synch_Calc_FC_push:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         FC_push    <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         FC_push    <= MRd_dsp_re_r1 and not MRd_dsp_empty_r1 
                   and not MRd_dsp_dout(C_CHBUF_TAG_BIT_TOP);

      end if;
   end process;

-- ------------------------------------------
-- Synchronous: FC_counter
-- 
   Synch_Calc_FC_counter:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         FC_counter    <= (Others=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         if FC_push='1' and FC_pop='0' then
            FC_counter    <= FC_counter + '1';
         elsif FC_push='0' and FC_pop='1' then
            FC_counter    <= FC_counter - '1';
         else
            FC_counter    <= FC_counter;
         end if;

      end if;
   end process;



-- ------------------------------------------
-- Synchronous: dsFC_stop
-- 
   Synch_Calc_dsFC_stop:
   process ( trn_clk, Local_Reset_i)
   begin
      if Local_Reset_i = '1' then
         dsFC_stop_128B     <= '1';
         dsFC_stop_256B     <= '1';
         dsFC_stop_512B     <= '1';
         dsFC_stop_1024B    <= '1';
         dsFC_stop_2048B    <= '1';
         dsFC_stop_4096B    <= '1';

      elsif trn_clk'event and trn_clk = '1' then

         if FC_counter(C_TAGRAM_AWIDTH-1 downto 0)/=C_ALL_ZEROS(C_TAGRAM_AWIDTH-1 downto 0) then
           dsFC_stop_4096B    <= '1';
         else
           dsFC_stop_4096B    <= '0';
         end if;

         if FC_counter(C_TAGRAM_AWIDTH-1 downto 0)/=C_ALL_ZEROS(C_TAGRAM_AWIDTH-1 downto 0) then
           dsFC_stop_2048B    <= '1';
         else
           dsFC_stop_2048B    <= '0';
         end if;

         if FC_counter(C_TAGRAM_AWIDTH-1 downto 1)/=C_ALL_ZEROS(C_TAGRAM_AWIDTH-1 downto 1) then
           dsFC_stop_1024B    <= '1';
         else
           dsFC_stop_1024B    <= '0';
         end if;

         if FC_counter(C_TAGRAM_AWIDTH-1 downto 2)/=C_ALL_ZEROS(C_TAGRAM_AWIDTH-1 downto 2) then
           dsFC_stop_512B    <= '1';
         else
           dsFC_stop_512B    <= '0';
         end if;

         if FC_counter(C_TAGRAM_AWIDTH-1 downto 3)/=C_ALL_ZEROS(C_TAGRAM_AWIDTH-1 downto 3) then
           dsFC_stop_256B    <= '1';
         else
           dsFC_stop_256B    <= '0';
         end if;

         if FC_counter(C_TAGRAM_AWIDTH-1 downto 4)/=C_ALL_ZEROS(C_TAGRAM_AWIDTH-1 downto 4) then
           dsFC_stop_128B    <= '1';
         else
           dsFC_stop_128B    <= '0';
         end if;

      end if;
   end process;


  -- ------------------------------------------
  -- Configuration pamameters: cfg_MRS
  --
    Syn_Config_Param_cfg_MRS:
    process ( trn_clk, Local_Reset_i)
    begin
       if Local_Reset_i = '1' then  -- 0x0080 Bytes
               dsFC_stop      <= '1';

       elsif trn_clk'event and trn_clk = '1' then

          case cfg_MRS is

            when "000" =>  -- 0x0080 Bytes
               dsFC_stop      <= dsFC_stop_128B;

            when "001" =>  -- 0x0100 Bytes
               dsFC_stop      <= dsFC_stop_256B;

            when "010" =>  -- 0x0200 Bytes
               dsFC_stop      <= dsFC_stop_512B;

            when "011" =>  -- 0x0400 Bytes
               dsFC_stop      <= dsFC_stop_1024B;

            when "100" =>  -- 0x0800 Bytes
               dsFC_stop      <= dsFC_stop_2048B;

            when "101" =>  -- 0x1000 Bytes
               dsFC_stop      <= dsFC_stop_4096B;

            when Others => -- as 0x0080 Bytes
               dsFC_stop      <= dsFC_stop_128B;

          end case;

       end if;
    end process;

end architecture Behavioral;

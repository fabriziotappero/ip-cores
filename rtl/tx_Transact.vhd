----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    tx_Transact - Behavioral 
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

entity tx_Transact is
    port (
      -- Common ports
      trn_clk            : IN  std_logic;
      trn_reset_n        : IN  std_logic;
      trn_lnk_up_n       : IN  std_logic;

      -- Transaction
      trn_tsof_n         : OUT std_logic;
      trn_teof_n         : OUT std_logic;
      trn_td             : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_trem_n         : OUT std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_terrfwd_n      : OUT std_logic;
      trn_tsrc_rdy_n     : OUT std_logic;
      trn_tdst_rdy_n     : IN  std_logic;
      trn_tsrc_dsc_n     : OUT std_logic;
      trn_tdst_dsc_n     : IN  std_logic;
      trn_tbuf_av        : IN  std_logic_vector(C_TBUF_AWIDTH-1 downto 0);

      -- Upstream DMA transferred bytes count up
      us_DMA_Bytes_Add   : OUT std_logic;
      us_DMA_Bytes       : OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- Event Buffer FIFO read port
      eb_FIFO_re         : OUT std_logic; 
      eb_FIFO_empty      : IN  std_logic; 
      eb_FIFO_qout       : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Read interface for Tx port
      Regs_RdAddr        : OUT std_logic_vector(C_EP_AWIDTH-1   downto 0);
      Regs_RdQout        : IN  std_logic_vector(C_DBUS_WIDTH-1   downto 0);

      -- Irpt Channel
      Irpt_Req           : IN  std_logic;
      Irpt_RE            : OUT std_logic;
      Irpt_Qout          : IN  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- PIO MRd Channel
      pioCplD_Req        : IN  std_logic;
      pioCplD_RE         : OUT std_logic;
      pioCplD_Qout       : IN  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      pio_FC_stop        : OUT std_logic;

      -- downstream MRd Channel
      dsMRd_Req          : IN  std_logic;
      dsMRd_RE           : OUT std_logic;
      dsMRd_Qout         : IN  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- upstream MWr/MRd Channel
      usTlp_Req          : IN  std_logic;
      usTlp_RE           : OUT std_logic;
      usTlp_Qout         : IN  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      us_FC_stop         : OUT std_logic;
      us_Last_sof        : OUT std_logic;
      us_Last_eof        : OUT std_logic;

      -- Message routing method
      Msg_Routing        : IN  std_logic_vector(C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT downto 0);

      --  DDR read port
      DDR_rdc_sof        : OUT   std_logic;
      DDR_rdc_eof        : OUT   std_logic;
      DDR_rdc_v          : OUT   std_logic;
      DDR_rdc_FA         : OUT   std_logic;
      DDR_rdc_Shift      : OUT   std_logic;
      DDR_rdc_din        : OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_rdc_full       : IN    std_logic;

      -- DDR payload FIFO Read Port
      DDR_FIFO_RdEn      : OUT std_logic; 
      DDR_FIFO_Empty     : IN  std_logic;
      DDR_FIFO_RdQout    : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--      DDR_rdD_sof        : IN    std_logic;
--      DDR_rdD_eof        : IN    std_logic;
--      DDR_rdDout_V       : IN    std_logic;
--      DDR_rdDout         : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);


      -- Additional
      Tx_TimeOut         : OUT   std_logic;
      Tx_eb_TimeOut      : OUT   std_logic;
      Format_Shower      : OUT   std_logic;
      mbuf_UserFull      : IN  std_logic;
      Tx_Reset           : IN  std_logic;
      localID            : IN  std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end tx_Transact;


architecture Behavioral of tx_Transact is

  type TxTrnStates is      ( St_TxIdle           -- Idle

--                           , St_d_CmdReq         -- Issue the read command to MemReader
                           , St_d_CmdAck         -- Wait for the read command ACK from MemReader
                           , St_d_Header0        -- 1st Header for TLP with payload
                           , St_d_Header2        -- 2nd Header for TLP with payload
--                           , St_d_HeaderPlus     -- Extra Header for TLP4 with payload
                           , St_d_1st_Data       -- Last Header for TLP3/4 with payload
                           , St_d_Payload        -- Data for TLP with payload
                           , St_d_Payload_used   -- Data flow from memory buffer discontinued
                           , St_d_Tail           -- Last data for TLP with payload
                           , St_d_Tail_chk       -- Last data extended for TLP with payload
                           , St_d_AfterChk       -- Last data extended for TLP with payload if arbitrating

                           , St_nd_Prepare       -- Prepare for 1st Header of TLP without payload
--                           , St_nd_Header1       -- 1st Header for TLP without payload
                           , St_nd_Header2       -- 2nd Header for TLP without payload
--                           , St_nd_HeaderPlus    -- Extra Header for TLP4 without payload
                           , St_nd_HeaderLast    -- Tail processing for the last dword of TLP w/o payload
                           , St_nd_Arbitration   -- One extra cycle for arbitration
                           );

  -- State variables
  signal   TxTrn_State            : TxTrnStates;

  -- Signals with the arbitrator
  signal   take_an_Arbitration    : std_logic;
  signal   Req_Bundle             : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal   Read_a_Buffer          : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal   Read_aBuffer_r1        : std_logic;
  signal   Read_aBuffer_r2        : std_logic;
  signal   Read_aBuffer_r3        : std_logic;
  signal   Ack_Indice             : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);

  signal   Tx_Indicator           : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal   b1_Tx_Indicator        : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal   vec_ChQout_Valid       : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal   Tx_Busy                : std_logic;

  -- Channel buffer output token bits
  signal   usTLP_is_MWr           : std_logic;
  signal   TLP_is_CplD            : std_logic;

  -- Bit information, telling whether the outgoing TLP has payload
  signal   ChBuf_has_Payload      : std_logic;
  signal   ChBuf_No_Payload       : std_logic;

  -- Channel buffers output OR'ed and registered
  signal   Trn_Qout_wire          :  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal   Trn_Qout_reg           :  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  --  Addresses from different channel buffer
  signal   mAddr_pioCplD          : std_logic_vector(C_PRAM_AWIDTH-1+2 downto 0);
  signal   mAddr_usTlp            : std_logic_vector(C_PRAM_AWIDTH-1+2 downto 0);
  signal   DDRAddr_usTlp          : std_logic_vector(C_DDR_IAWIDTH-1 downto 0);
  signal   Regs_Addr_pioCplD      : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal   DDRAddr_pioCplD        : std_logic_vector(C_DDR_IAWIDTH-1 downto 0);
  --  BAR number
  signal   BAR_pioCplD            : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
  signal   BAR_usTlp              : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
  --  Misc. info.
  signal   AInc_usTlp             : std_logic;
  signal   pioCplD_is_0Leng       : std_logic;

  -- Delay for requests from Channel Buffers
  signal   Irpt_Req_r1            : std_logic;
  signal   pioCplD_Req_r1         : std_logic;
  signal   dsMRd_Req_r1           : std_logic;
  signal   usTlp_Req_r1           : std_logic;

  -- Registered channel buffer outputs
  signal   Irpt_Qout_to_TLP       : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal   pioCplD_Qout_to_TLP    : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal   dsMRd_Qout_to_TLP      : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal   usTlp_Qout_to_TLP      : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  signal   pioCplD_Req_Min_Leng   : std_logic;
  signal   pioCplD_Req_2DW_Leng   : std_logic;
  signal   usTlp_Req_Min_Leng     : std_logic;
  signal   usTlp_Req_2DW_Leng     : std_logic;

  --  Channel buffer read enables
  signal   Irpt_RE_i              : std_logic;
  signal   pioCplD_RE_i           : std_logic;
  signal   dsMRd_RE_i             : std_logic;
  signal   usTlp_RE_i             : std_logic;

  -- Flow controls
  signal   pio_FC_stop_i          : std_logic;
  signal   us_FC_stop_i           : std_logic;

  -- Local reset for tx
  signal   trn_tx_Reset_n         : std_logic;

  -- Alias for transaction interface signals
  signal   trn_td_i               : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   trn_tsof_n_i           : std_logic;
  signal   trn_trem_n_i           : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal   trn_teof_n_i           : std_logic;
  signal   Format_Shower_i        : std_logic;

  signal   trn_tsrc_rdy_n_i       : std_logic;
  signal   trn_tsrc_dsc_n_i       : std_logic;
  signal   trn_terrfwd_n_i        : std_logic;

  signal   trn_tdst_rdy_n_i       : std_logic;
  signal   trn_tdst_rdy_n_r1      : std_logic;

  signal   trn_tdst_dsc_n_i       : std_logic;
  signal   trn_tbuf_av_i          : std_logic_vector(C_TBUF_AWIDTH-1 downto 0);

  -- Upstream DMA transferred bytes count up
  signal   us_DMA_Bytes_Add_i     : std_logic;
  signal   us_DMA_Bytes_i         : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

  ---------------------  Memory Reader  -----------------------------
  --- 
  --- Memory reader is the interface to access all sorts of memories
  ---   BRAM, FIFO, Registers, as well as possible DDR SDRAM
  --- 
  -------------------------------------------------------------------
  COMPONENT
  tx_Mem_Reader
  PORT(
       DDR_rdc_sof           : OUT   std_logic;
       DDR_rdc_eof           : OUT   std_logic;
       DDR_rdc_v             : OUT   std_logic;
       DDR_rdc_FA            : OUT   std_logic;
       DDR_rdc_Shift         : OUT   std_logic;
       DDR_rdc_din           : OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
       DDR_rdc_full          : IN    std_logic;

--       DDR_rdD_sof           : IN    std_logic;
--       DDR_rdD_eof           : IN    std_logic;
--       DDR_rdDout_V          : IN    std_logic;
--       DDR_rdDout            : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

       DDR_FIFO_RdEn         : OUT   std_logic;
       DDR_FIFO_Empty        : IN    std_logic;
       DDR_FIFO_RdQout       : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

       eb_FIFO_re            : OUT   std_logic; 
       eb_FIFO_empty         : IN    std_logic; 
       eb_FIFO_qout          : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

       Regs_RdAddr           : OUT   std_logic_vector(C_EP_AWIDTH-1 downto 0);
       Regs_RdQout           : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

       RdNumber              : IN    std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
       RdNumber_eq_One       : IN    std_logic;
       RdNumber_eq_Two       : IN    std_logic;
       StartAddr             : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
       Shift_1st_QWord       : IN    std_logic;
       FixedAddr             : IN    std_logic;
       is_CplD               : IN    std_logic;
       BAR_value             : IN    std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
       RdCmd_Req             : IN    std_logic;
       RdCmd_Ack             : OUT   std_logic;

       mbuf_WE               : OUT   std_logic;
       mbuf_Din              : OUT   std_logic_vector(C_DBUS_WIDTH*9/8-1 downto 0);
       mbuf_Full             : IN    std_logic;
       mbuf_aFull            : IN    std_logic;
       mbuf_UserFull         : IN    std_logic;

       Tx_TimeOut            : OUT   std_logic;
       Tx_eb_TimeOut         : OUT   std_logic;
       mReader_Rst_n         : IN    std_logic;
       trn_clk               : IN    std_logic
      );
  END COMPONENT;

  signal   RdNumber               : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
  signal   RdNumber_eq_One        : std_logic;
  signal   RdNumber_eq_Two        : std_logic;
  signal   StartAddr              : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   Shift_1st_QWord        : std_logic;
  signal   FixedAddr              : std_logic;
  signal   is_CplD                : std_logic;
  signal   BAR_value              : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
  signal   RdCmd_Req              : std_logic;
  signal   RdCmd_Ack              : std_logic;


  ---------------------  Memory Buffer  -----------------------------
  --- 
  --- A unified memory buffer holding the payload for the next tx TLP 
  ---   34 bits wide, wherein 2 additional framing bits
  ---   temporarily 64 data depth, possibly deepened.
  --- 
  -------------------------------------------------------------------
  component
  mBuf_128x72
  port (
        clk                  : IN     std_logic;
        rst                  : IN     std_logic;
        wr_en                : IN     std_logic;
        din                  : IN     std_logic_VECTOR(C_DBUS_WIDTH*9/8-1 downto 0);
        prog_full            : OUT    std_logic;
        full                 : OUT    std_logic;
        rd_en                : IN     std_logic;
        dout                 : OUT    std_logic_VECTOR(C_DBUS_WIDTH*9/8-1 downto 0);
        empty                : OUT    std_logic
       );
  end component;

  signal   mbuf_reset_b3          : std_logic;
  signal   mbuf_reset_b2          : std_logic;
  signal   mbuf_reset_b1          : std_logic;
  signal   mbuf_reset             : std_logic;
  signal   mbuf_WE                : std_logic;
  signal   mbuf_Din               : std_logic_VECTOR(C_DBUS_WIDTH*9/8-1 downto 0);
  signal   mbuf_Full              : std_logic;
  signal   mbuf_aFull             : std_logic;
  signal   mbuf_RE                : std_logic;
  signal   mbuf_Qout              : std_logic_VECTOR(C_DBUS_WIDTH*9/8-1 downto 0);
  signal   mbuf_Empty             : std_logic;
  -- Calculated infomation
  signal   mbuf_RE_ok             : std_logic;
  signal   mbuf_Qvalid            : std_logic;

--  signal   Payload_Rd_Debt        : std_logic;
  signal   Payload_rd_count       : std_logic_VECTOR(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);

  ---------------------  Output arbitration  ------------------------
  --- 
  --- For sake of fairness, the priorities are cycled every time 
  ---   a service is done, after which the priority of the request 
  ---   just serviced is set to the lowest and other lower priorities
  ---   increased and higher stay.
  --- 
  -------------------------------------------------------------------
  COMPONENT
  Tx_Output_Arbitor
  PORT(
        rst_n                : IN    std_logic;
        clk                  : IN    std_logic;
        arbtake              : IN    std_logic;
        Req                  : IN    std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
        bufread              : OUT   std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
        Ack                  : OUT   std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0)
      );
  END COMPONENT;

  type ArbReqStates is     ( StA_idle            -- Intial idle
                           , StA_req             -- Wait for ack from mReader module
                           , StA_take            -- Waiting for arbitration take signal
                           );

  -- Arbitration State variables
  signal   arq_State              : ArbReqStates;

begin

   -- Connect outputs
   trn_td                <= trn_td_i;
   trn_tsof_n            <= trn_tsof_n_i;
   trn_trem_n            <= trn_trem_n_i;
   trn_teof_n            <= trn_teof_n_i;

   trn_tsrc_rdy_n        <= trn_tsrc_rdy_n_i;
   trn_tsrc_dsc_n        <= trn_tsrc_dsc_n_i;
   trn_terrfwd_n         <= trn_terrfwd_n_i;

   Format_Shower         <= Format_Shower_i;
   us_Last_sof           <= usTLP_is_MWr and not trn_tsof_n_i;
   us_Last_eof           <= usTLP_is_MWr and not trn_teof_n_i;

   -- Connect inputs 
   trn_tdst_rdy_n_i      <= trn_tdst_rdy_n;
   trn_tdst_dsc_n_i      <= trn_tdst_dsc_n;
   trn_tbuf_av_i         <= trn_tbuf_av;


   -- Always deasserted
   trn_tsrc_dsc_n_i      <= '1';
   trn_terrfwd_n_i       <= '1';
--   trn_trem_n_i          <= (OTHERS=>'0');


   -- Upstream DMA transferred bytes counting up
   us_DMA_Bytes_Add      <= us_DMA_Bytes_Add_i;
   us_DMA_Bytes          <= us_DMA_Bytes_i    ;


   -- Flow controls
   pio_FC_stop           <= pio_FC_stop_i;
   us_FC_stop            <= us_FC_stop_i;


-----------------------------------------------------
-- Synchronous Delay: trn_tdst_rdy_n_i
-- 
   Synchron_Delay_trn_tdst_rdy_n_i:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
        trn_tdst_rdy_n_r1    <= trn_tdst_rdy_n_i;
      end if;
   end process;

---------------------------------------------------------------------------------
-- Synchronous Calculation: us_FC_stop, pio_FC_stop
-- 
   Synch_Calc_FC_stop:
   process ( trn_clk, Tx_Reset)
   begin
      if Tx_Reset = '1' then
         us_FC_stop_i        <= '1';
         pio_FC_stop_i       <= '1';
      elsif trn_clk'event and trn_clk = '1' then
        if trn_tbuf_av_i(C_TBUF_AWIDTH-1 downto 1) /=C_ALL_ZEROS(C_TBUF_AWIDTH-1 downto 1) then
           us_FC_stop_i        <= '0';
           pio_FC_stop_i       <= '0';
        else
           us_FC_stop_i        <= '1';
           pio_FC_stop_i       <= '1';
        end if;
      end if;
   end process;


   -- Channel buffer read enable
   Irpt_RE               <= Irpt_RE_i;
   pioCplD_RE            <= pioCplD_RE_i;
   dsMRd_RE              <= dsMRd_RE_i;
   usTlp_RE              <= usTlp_RE_i;


-- -----------------------------------
--   Synchronized Local reset
--
   Syn_Local_Reset:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         trn_tx_Reset_n   <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         trn_tx_Reset_n   <= trn_tdst_dsc_n_i and not Tx_Reset;
      end if;
   end process;

-- -----------------------------------
--   Format detector
--
   Syn_Format_Shower:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         Format_Shower_i   <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         if Format_Shower_i = '0' then
           if trn_tsof_n_i='0' and trn_tsrc_rdy_n_i='0' and trn_tdst_rdy_n_i='0' then
              Format_Shower_i   <= '1';
           else
              Format_Shower_i   <= '0';
           end if;
         else
           if trn_teof_n_i='0' and trn_tsrc_rdy_n_i='0' and trn_tdst_rdy_n_i='0' then
              Format_Shower_i   <= '0';
           else
              Format_Shower_i   <= '1';
           end if;
         end if;
      end if;
   end process;

------------------------------------------------------------
---             Memory reader
------------------------------------------------------------
   ABB_Tx_MReader:
   tx_Mem_Reader
   PORT MAP(
            DDR_rdc_sof     => DDR_rdc_sof     ,  --  OUT   std_logic;
            DDR_rdc_eof     => DDR_rdc_eof     ,  --  OUT   std_logic;
            DDR_rdc_v       => DDR_rdc_v       ,  --  OUT   std_logic;
            DDR_rdc_FA      => DDR_rdc_FA      ,  --  OUT   std_logic;
            DDR_rdc_Shift   => DDR_rdc_Shift   ,  --  OUT   std_logic;
            DDR_rdc_din     => DDR_rdc_din     ,  --  OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
            DDR_rdc_full    => DDR_rdc_full    ,  --  IN    std_logic;

--            DDR_rdD_sof     => DDR_rdD_sof     ,  --  IN    std_logic;
--            DDR_rdD_eof     => DDR_rdD_eof     ,  --  IN    std_logic;
--            DDR_rdDout_V    => DDR_rdDout_V    ,  --  IN    std_logic;
--            DDR_rdDout      => DDR_rdDout      ,  --  IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

            DDR_FIFO_RdEn   => DDR_FIFO_RdEn   ,  -- OUT std_logic;
            DDR_FIFO_Empty  => DDR_FIFO_Empty  ,  -- IN  std_logic;
            DDR_FIFO_RdQout => DDR_FIFO_RdQout ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

            eb_FIFO_re      => eb_FIFO_re      ,  -- OUT std_logic; 
            eb_FIFO_empty   => eb_FIFO_empty   ,  -- IN  std_logic; 
            eb_FIFO_qout    => eb_FIFO_qout    ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

            Regs_RdAddr     => Regs_RdAddr     ,  -- OUT std_logic_vector(C_EP_AWIDTH-1 downto 0);
            Regs_RdQout     => Regs_RdQout     ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

            RdNumber        => RdNumber        ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
            RdNumber_eq_One => RdNumber_eq_One ,  -- IN  std_logic;
            RdNumber_eq_Two => RdNumber_eq_Two ,  -- IN  std_logic;
            StartAddr       => StartAddr       ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
            Shift_1st_QWord => Shift_1st_QWord ,  -- IN  std_logic;
            FixedAddr       => '0',         -- FixedAddr       ,  -- IN  std_logic;
            is_CplD         => is_CplD         ,  -- IN  std_logic;
            BAR_value       => BAR_value       ,  -- IN  std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
            RdCmd_Req       => RdCmd_Req       ,  -- IN  std_logic;
            RdCmd_Ack       => RdCmd_Ack       ,  -- OUT std_logic;

            mbuf_WE         => mbuf_WE         ,  -- OUT std_logic;
            mbuf_Din        => mbuf_Din        ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
            mbuf_Full       => mbuf_Full       ,  -- IN  std_logic;
            mbuf_aFull      => mbuf_aFull      ,  -- IN  std_logic;
            mbuf_UserFull   => mbuf_UserFull   ,  -- IN  std_logic;

            Tx_TimeOut      => Tx_TimeOut      ,  -- OUT std_logic;
            Tx_eb_TimeOut   => Tx_eb_TimeOut   ,  -- OUT std_logic;
            mReader_Rst_n   => trn_tx_Reset_n  ,  -- IN  std_logic;
            trn_clk         => trn_clk            -- IN  std_logic
           );


------------------------------------------------------------
---             Memory buffer
------------------------------------------------------------
   ABB_Tx_MBuffer:
   mBuf_128x72
   PORT MAP(
            wr_en         => mbuf_WE               , -- IN  std_logic;
            din           => mbuf_Din              , -- IN  std_logic_VECTOR(C_DBUS_WIDTH+1 downto 0);
            prog_full     => mbuf_aFull            , -- OUT std_logic;
            full          => mbuf_Full             , -- OUT std_logic;
            rd_en         => mbuf_RE               , -- IN  std_logic;
            dout          => mbuf_Qout             , -- OUT std_logic_VECTOR(C_DBUS_WIDTH+1 downto 0);
            empty         => mbuf_Empty            , -- OUT std_logic
            rst           => mbuf_reset, --Tx_Reset              , -- IN  std_logic;
            clk           => trn_clk                 -- IN  std_logic;
           );

   mbuf_RE        <=  mbuf_RE_ok and (not trn_tdst_rdy_n_i or trn_tsrc_rdy_n_i);


-- ---------------------------------------------------
-- State Machine Tx: mbuf_reset
--
   TxFSM_Output_mbuf_reset:
   process ( trn_clk, trn_tx_Reset_n)
   begin
      if trn_tx_Reset_n = '0' then
         mbuf_reset_b3           <= '1';
         mbuf_reset_b2           <= '1';
         mbuf_reset_b1           <= '1';
         mbuf_reset              <= '1';

      elsif trn_clk'event and trn_clk = '1' then

         mbuf_reset_b3 <= '0';
         mbuf_reset_b2 <= mbuf_reset_b3;
         mbuf_reset_b1 <= mbuf_reset_b2;
         mbuf_reset    <= mbuf_reset_b3 or mbuf_reset_b2 or mbuf_reset_b1;

      end if;
   end process;


---------------------------------------------------------------------------------
-- Synchronous Delay: mbuf_Qout Valid
-- 
   Synchron_Delay_mbuf_Qvalid:
   process ( trn_clk, Tx_Reset)
   begin
      if Tx_Reset = '1' then
         mbuf_Qvalid        <= '0';
      elsif trn_clk'event and trn_clk = '1' then
        if     mbuf_Qvalid='0' and mbuf_RE='1' and mbuf_Empty='0' then  -- a valid data is going out
           mbuf_Qvalid          <= '1';
        elsif  mbuf_Qvalid='1' and mbuf_RE='1' and mbuf_Empty='1' then  -- an invalid data is going out
           mbuf_Qvalid          <= '0';
        else                                                        -- state stays
           mbuf_Qvalid          <= mbuf_Qvalid;
        end if;
      end if;
   end process;


------------------------------------------------------------
---             Output arbitration
------------------------------------------------------------
   O_Arbitration: 
   Tx_Output_Arbitor
   PORT MAP(
            rst_n         => trn_tx_Reset_n,
            clk           => trn_clk,
            arbtake       => take_an_Arbitration,
            Req           => Req_Bundle,
            bufread       => Read_a_Buffer,
            Ack           => Ack_Indice
           );


-----------------------------------------------------
-- Synchronous Delay: Channel Requests
-- 
   Synchron_Delay_ChRequests:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
         Irpt_Req_r1      <= Irpt_Req;
         pioCplD_Req_r1   <= pioCplD_Req;
         dsMRd_Req_r1     <= dsMRd_Req;
         usTlp_Req_r1     <= usTlp_Req;
      end if;
   end process;


-----------------------------------------------------
-- Synchronous Delay: Read_a_Buffer
-- 
   Synchron_Delay_Read_a_Buffer:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
        Read_aBuffer_r3      <= Read_aBuffer_r2;
        Read_aBuffer_r2      <= Read_aBuffer_r1;
        if Read_a_Buffer=C_ALL_ZEROS(C_CHANNEL_NUMBER-1 downto 0) then
           Read_aBuffer_r1      <= '0';
        else
           Read_aBuffer_r1      <= '1';
        end if;
      end if;
   end process;


-----------------------------------------------------
-- Synchronous Delay: Tx_Busy
-- 
   Synchron_Delay_Tx_Busy:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
         Tx_Indicator     <= b1_Tx_Indicator;
         Tx_Busy          <= (b1_Tx_Indicator(C_CHAN_INDEX_IRPT)   and vec_ChQout_Valid(C_CHAN_INDEX_IRPT)  )
                          or (b1_Tx_Indicator(C_CHAN_INDEX_MRD)    and vec_ChQout_Valid(C_CHAN_INDEX_MRD)   )
                          or (b1_Tx_Indicator(C_CHAN_INDEX_DMA_DS) and vec_ChQout_Valid(C_CHAN_INDEX_DMA_DS))
                          or (b1_Tx_Indicator(C_CHAN_INDEX_DMA_US) and vec_ChQout_Valid(C_CHAN_INDEX_DMA_US))
                          ;
      end if;
   end process;


-- ---------------------------------------------
-- Reg : Channel Buffer Qout has Payload
-- 
   Reg_ChBuf_with_Payload:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         ChBuf_has_Payload     <= (b1_Tx_Indicator(C_CHAN_INDEX_MRD)    and TLP_is_CplD  and vec_ChQout_Valid(C_CHAN_INDEX_MRD)   )
                               or (b1_Tx_Indicator(C_CHAN_INDEX_DMA_US) and usTLP_is_MWr and vec_ChQout_Valid(C_CHAN_INDEX_DMA_US))
                               ;
      end if;
   end process;

-- ---------------------------------------------
-- Channel Buffer Qout has no Payload
--   (! subordinate to ChBuf_has_Payload ! )
--
   ChBuf_No_Payload      <=   Tx_Busy;


-- Arbitrator inputs
   Req_Bundle(C_CHAN_INDEX_IRPT)         <= Irpt_Req_r1;
   Req_Bundle(C_CHAN_INDEX_MRD)          <= pioCplD_Req_r1;
   Req_Bundle(C_CHAN_INDEX_DMA_DS)       <= dsMRd_Req_r1;
   Req_Bundle(C_CHAN_INDEX_DMA_US)       <= usTlp_Req_r1;

-- Arbitrator outputs
   b1_Tx_Indicator(C_CHAN_INDEX_IRPT)    <= Ack_Indice(C_CHAN_INDEX_IRPT);
   b1_Tx_Indicator(C_CHAN_INDEX_MRD)     <= Ack_Indice(C_CHAN_INDEX_MRD);
   b1_Tx_Indicator(C_CHAN_INDEX_DMA_DS)  <= Ack_Indice(C_CHAN_INDEX_DMA_DS);
   b1_Tx_Indicator(C_CHAN_INDEX_DMA_US)  <= Ack_Indice(C_CHAN_INDEX_DMA_US);


-- Arbitrator reads channel buffers
   Irpt_RE_i                             <= Read_a_Buffer(C_CHAN_INDEX_IRPT);
   pioCplD_RE_i                          <= Read_a_Buffer(C_CHAN_INDEX_MRD);
   dsMRd_RE_i                            <= Read_a_Buffer(C_CHAN_INDEX_DMA_DS);
   usTlp_RE_i                            <= Read_a_Buffer(C_CHAN_INDEX_DMA_US);


-- determine whether the upstream TLP is an MWr or an MRd.
   usTLP_is_MWr          <= usTlp_Qout  (C_CHBUF_FMT_BIT_TOP);
   TLP_is_CplD           <= pioCplD_Qout(C_CHBUF_FMT_BIT_TOP);


-- check if the Channel buffer output is valid
   vec_ChQout_Valid(C_CHAN_INDEX_IRPT)    <= Irpt_Qout   (C_CHBUF_QVALID_BIT);
   vec_ChQout_Valid(C_CHAN_INDEX_MRD)     <= pioCplD_Qout(C_CHBUF_QVALID_BIT);
   vec_ChQout_Valid(C_CHAN_INDEX_DMA_DS)  <= dsMRd_Qout  (C_CHBUF_QVALID_BIT);
   vec_ChQout_Valid(C_CHAN_INDEX_DMA_US)  <= usTlp_Qout  (C_CHBUF_QVALID_BIT);


-- -----------------------------------
-- Delay : Channel_Buffer_Qout
--         Bit-mapping is done
-- 
   Delay_Channel_Buffer_Qout:
   process ( trn_clk, trn_tx_Reset_n)
   begin
      if trn_tx_Reset_n = '0' then
         Irpt_Qout_to_TLP      <= (Others=>'0');
         pioCplD_Qout_to_TLP   <= (Others=>'0');
         dsMRd_Qout_to_TLP     <= (Others=>'0');
         usTlp_Qout_to_TLP     <= (Others=>'0');

         pioCplD_Req_Min_Leng  <= '0';
         pioCplD_Req_2DW_Leng  <= '0';
         usTlp_Req_Min_Leng    <= '0';
         usTlp_Req_2DW_Leng    <= '0';

         Regs_Addr_pioCplD     <= (Others=>'1');
         mAddr_pioCplD         <= (Others=>'1');
         mAddr_usTlp           <= (Others=>'1');
         AInc_usTlp            <= '1';
         BAR_pioCplD           <= (Others=>'1');
         BAR_usTlp             <= (Others=>'1');
         pioCplD_is_0Leng      <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         if b1_Tx_Indicator(C_CHAN_INDEX_IRPT)='1' then
            Irpt_Qout_to_TLP  <= (Others=>'0');   -- must be 1st argument
            -- 1st header Hi
            Irpt_Qout_to_TLP(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)    <= Irpt_Qout(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT);
--            Irpt_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)  <= C_TYPE_OF_MSG; --Irpt_Qout(C_CHBUF_MSGTYPE_BIT_TOP downto C_CHBUF_MSGTYPE_BIT_BOT);
            Irpt_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)  <= C_TYPE_OF_MSG(C_TLP_TYPE_BIT_TOP 
                                                                               downto C_TLP_TYPE_BIT_BOT+1+C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT)
                                                                             & Msg_Routing;
            Irpt_Qout_to_TLP(C_TLP_TC_BIT_TOP   downto C_TLP_TC_BIT_BOT)    <= Irpt_Qout(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT);
            Irpt_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)  <= Irpt_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);

            -- 1st header Lo
            Irpt_Qout_to_TLP(C_TLP_REQID_BIT_TOP downto C_TLP_REQID_BIT_BOT)  <= localID;
            Irpt_Qout_to_TLP(C_TLP_TAG_BIT_TOP   downto C_TLP_TAG_BIT_BOT)    <= Irpt_Qout(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT);
            Irpt_Qout_to_TLP(C_MSG_CODE_BIT_TOP  downto C_MSG_CODE_BIT_BOT)   <= Irpt_Qout(C_CHBUF_MSG_CODE_BIT_TOP downto C_CHBUF_MSG_CODE_BIT_BOT);
            -- 2nd headers all zero
            -- ...

         else
            Irpt_Qout_to_TLP     <= (Others=>'0');
         end if;


         if b1_Tx_Indicator(C_CHAN_INDEX_MRD)='1' then
            pioCplD_Qout_to_TLP  <= (Others=>'0');   -- must be 1st argument
            -- 1st header Hi
            pioCplD_Qout_to_TLP(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)   <= pioCplD_Qout(C_CHBUF_FMT_BIT_TOP  downto C_CHBUF_FMT_BIT_BOT);
            pioCplD_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)  <= C_TYPE_COMPLETION; --pioCplD_Qout(C_CHBUF_TYPE_BIT_TOP downto C_CHBUF_TYPE_BIT_BOT);
            pioCplD_Qout_to_TLP(C_TLP_TC_BIT_TOP   downto C_TLP_TC_BIT_BOT)    <= pioCplD_Qout(C_CHBUF_TC_BIT_TOP   downto C_CHBUF_TC_BIT_BOT);
            pioCplD_Qout_to_TLP(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT)  <= pioCplD_Qout(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT);
            pioCplD_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)  <= pioCplD_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
            -- 1st header Lo
            pioCplD_Qout_to_TLP(C_CPLD_CPLT_ID_BIT_TOP downto C_CPLD_CPLT_ID_BIT_BOT)  <= localID;
            pioCplD_Qout_to_TLP(C_CPLD_CS_BIT_TOP     downto C_CPLD_CS_BIT_BOT)        <= pioCplD_Qout(C_CHBUF_CPLD_CS_BIT_TOP downto C_CHBUF_CPLD_CS_BIT_BOT);
            pioCplD_Qout_to_TLP(C_CPLD_BC_BIT_TOP     downto C_CPLD_BC_BIT_BOT)        <= pioCplD_Qout(C_CHBUF_CPLD_BC_BIT_TOP downto C_CHBUF_CPLD_BC_BIT_BOT);
            -- 2nd header Hi
            pioCplD_Qout_to_TLP(C_DBUS_WIDTH+C_CPLD_REQID_BIT_TOP downto C_DBUS_WIDTH+C_CPLD_REQID_BIT_BOT)  <= pioCplD_Qout(C_CHBUF_CPLD_REQID_BIT_TOP downto C_CHBUF_CPLD_REQID_BIT_BOT);
            pioCplD_Qout_to_TLP(C_DBUS_WIDTH+C_CPLD_TAG_BIT_TOP   downto C_DBUS_WIDTH+C_CPLD_TAG_BIT_BOT)    <= pioCplD_Qout(C_CHBUF_CPLD_TAG_BIT_TOP   downto C_CHBUF_CPLD_TAG_BIT_BOT);
            pioCplD_Qout_to_TLP(C_DBUS_WIDTH+C_CPLD_LA_BIT_TOP    downto C_DBUS_WIDTH+C_CPLD_LA_BIT_BOT)     <= pioCplD_Qout(C_CHBUF_CPLD_LA_BIT_TOP    downto C_CHBUF_CPLD_LA_BIT_BOT);
            -- no 2nd header Lo

            if pioCplD_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
               = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG)
               then
               pioCplD_Req_Min_Leng  <= '1';
            else
               pioCplD_Req_Min_Leng  <= '0';
            end if;
            if pioCplD_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
               = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG)
               then
               pioCplD_Req_2DW_Leng  <= '1';
            else
               pioCplD_Req_2DW_Leng  <= '0';
            end if;

            -- Misc
            Regs_Addr_pioCplD    <= pioCplD_Qout(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT);
            mAddr_pioCplD        <= pioCplD_Qout(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT);  -- !! C_CHBUF_MA_BIT_BOT);
            DDRAddr_pioCplD      <= pioCplD_Qout(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT);
            BAR_pioCplD          <= pioCplD_Qout(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT);
            pioCplD_is_0Leng     <= pioCplD_Qout(C_CHBUF_0LENG_BIT);
         else
            pioCplD_Req_Min_Leng <= '0';
            pioCplD_Req_2DW_Leng <= '0';
            pioCplD_Qout_to_TLP  <= (Others=>'0');
            Regs_Addr_pioCplD    <= (Others=>'1');
            mAddr_pioCplD        <= (Others=>'1');
            DDRAddr_pioCplD      <= (Others=>'1');
            BAR_pioCplD          <= (Others=>'1');
            pioCplD_is_0Leng     <= '0';
         end if;


         if b1_Tx_Indicator(C_CHAN_INDEX_DMA_US)='1' then
            usTlp_Qout_to_TLP  <= (Others=>'0');   -- must be 1st argument
            -- 1st header HI
            usTlp_Qout_to_TLP(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)   <= usTlp_Qout(C_CHBUF_FMT_BIT_TOP  downto C_CHBUF_FMT_BIT_BOT);
            usTlp_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)  <= C_ALL_ZEROS(C_TLP_TYPE_BIT_TOP  downto C_TLP_TYPE_BIT_BOT);
            usTlp_Qout_to_TLP(C_TLP_TC_BIT_TOP   downto C_TLP_TC_BIT_BOT)    <= usTlp_Qout(C_CHBUF_TC_BIT_TOP   downto C_CHBUF_TC_BIT_BOT);
            usTlp_Qout_to_TLP(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT)  <= usTlp_Qout(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT);
            usTlp_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)  <= usTlp_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
            -- 1st header LO
            usTlp_Qout_to_TLP(C_TLP_REQID_BIT_TOP   downto C_TLP_REQID_BIT_BOT)    <= localID;
            usTlp_Qout_to_TLP(C_TLP_TAG_BIT_TOP     downto C_TLP_TAG_BIT_BOT)      <= usTlp_Qout(C_CHBUF_TAG_BIT_TOP   downto C_CHBUF_TAG_BIT_BOT);
            usTlp_Qout_to_TLP(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT)  <= C_ALL_ONES(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT);
            usTlp_Qout_to_TLP(C_TLP_1ST_BE_BIT_TOP  downto C_TLP_1ST_BE_BIT_BOT)   <= C_ALL_ONES(C_TLP_1ST_BE_BIT_TOP  downto C_TLP_1ST_BE_BIT_BOT);
            -- 2nd header HI (Address)
--            usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH)    <= usTlp_Qout(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT);
            if usTlp_Qout(C_CHBUF_FMT_BIT_BOT)='1' then  -- 4DW MWr
               usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH+32)    <= usTlp_Qout(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT+32);
            else
               usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH+32)    <= usTlp_Qout(C_CHBUF_HA_BIT_TOP-32 downto C_CHBUF_HA_BIT_BOT);
            end if;
            -- 2nd header LO (Address)
            usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1-32 downto C_DBUS_WIDTH)    <= usTlp_Qout(C_CHBUF_HA_BIT_TOP-32 downto C_CHBUF_HA_BIT_BOT);

            -- 
            if usTlp_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
               = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG)
               then
               usTlp_Req_Min_Leng  <= '1';
            else
               usTlp_Req_Min_Leng  <= '0';
            end if;
            if usTlp_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
               = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG)
               then
               usTlp_Req_2DW_Leng  <= '1';
            else
               usTlp_Req_2DW_Leng  <= '0';
            end if;

            -- Misc
            DDRAddr_usTlp        <= usTlp_Qout(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT);
            mAddr_usTlp          <= usTlp_Qout(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT);  -- !! C_CHBUF_MA_BIT_BOT);
            AInc_usTlp           <= usTlp_Qout(C_CHBUF_AINC_BIT);
            BAR_usTlp            <= usTlp_Qout(C_CHBUF_DMA_BAR_BIT_TOP downto C_CHBUF_DMA_BAR_BIT_BOT);

         else
            usTlp_Req_Min_Leng   <= '0';
            usTlp_Req_2DW_Leng   <= '0';
            usTlp_Qout_to_TLP    <= (Others=>'0');
            DDRAddr_usTlp        <= (Others=>'1');
            mAddr_usTlp          <= (Others=>'1');
            AInc_usTlp           <= '1';
            BAR_usTlp            <= (Others=>'1');
         end if;


         if b1_Tx_Indicator(C_CHAN_INDEX_DMA_DS)='1' then
            dsMRd_Qout_to_TLP  <= (Others=>'0');   -- must be 1st argument
            -- 1st header HI
            dsMRd_Qout_to_TLP(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)   <= dsMRd_Qout(C_CHBUF_FMT_BIT_TOP  downto C_CHBUF_FMT_BIT_BOT);
            dsMRd_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)  <= C_ALL_ZEROS(C_TLP_TYPE_BIT_TOP  downto C_TLP_TYPE_BIT_BOT);
            dsMRd_Qout_to_TLP(C_TLP_TC_BIT_TOP   downto C_TLP_TC_BIT_BOT)    <= dsMRd_Qout(C_CHBUF_TC_BIT_TOP   downto C_CHBUF_TC_BIT_BOT);
            dsMRd_Qout_to_TLP(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT)  <= dsMRd_Qout(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT);
            dsMRd_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)  <= dsMRd_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
            -- 1st header LO
            dsMRd_Qout_to_TLP(C_TLP_REQID_BIT_TOP   downto C_TLP_REQID_BIT_BOT)    <= localID;
            dsMRd_Qout_to_TLP(C_TLP_TAG_BIT_TOP     downto C_TLP_TAG_BIT_BOT)      <= dsMRd_Qout(C_CHBUF_TAG_BIT_TOP   downto C_CHBUF_TAG_BIT_BOT);
            dsMRd_Qout_to_TLP(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT)  <= C_ALL_ONES(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT);
            dsMRd_Qout_to_TLP(C_TLP_1ST_BE_BIT_TOP  downto C_TLP_1ST_BE_BIT_BOT)   <= C_ALL_ONES(C_TLP_1ST_BE_BIT_TOP  downto C_TLP_1ST_BE_BIT_BOT);
            -- 2nd header (Address)
            dsMRd_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH)    <= dsMRd_Qout(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT);

         else
            dsMRd_Qout_to_TLP    <= (Others=>'0');
         end if;

      end if;
   end process;


-- OR-wired channel buffer outputs
   Trn_Qout_wire        <= Irpt_Qout_to_TLP 
                        or pioCplD_Qout_to_TLP 
                        or dsMRd_Qout_to_TLP 
                        or usTlp_Qout_to_TLP
                        ;

-- ---------------------------------------------------
-- State Machine: Tx output control
--
   TxFSM_OutputControl:
   process ( trn_clk, trn_tx_Reset_n)
   begin
      if trn_tx_Reset_n = '0' then
         trn_tsrc_rdy_n_i     <= '1';
         trn_tsof_n_i         <= '1';
         trn_teof_n_i         <= '1';
         trn_td_i             <= (Others=>'0');
         trn_trem_n_i         <= (Others=>'0');
         TxTrn_State          <= St_TxIdle;

      elsif trn_clk'event and trn_clk = '1' then

         case TxTrn_State is

            when St_TxIdle    =>
              trn_tsrc_rdy_n_i     <= '1';
              trn_tsof_n_i         <= '1';
              trn_teof_n_i         <= '1';
              trn_td_i             <= (Others=>'0');
              trn_trem_n_i         <= (Others=>'0');

              if ChBuf_has_Payload = '1' then
                TxTrn_State          <= St_d_CmdAck;   -- St_d_CmdReq;
              elsif ChBuf_No_Payload = '1' then
                TxTrn_State          <= St_nd_Prepare;
              else
                TxTrn_State          <= St_TxIdle;
              end if;


            --- --- --- --- --- --- --- --- --- --- --- --- ---
            --- --- --- --- --- --- --- --- --- --- --- --- ---

            when St_nd_Prepare    =>
              trn_teof_n_i         <= '1';
              if trn_tdst_rdy_n_i = '0' then
                TxTrn_State          <= St_nd_Header2;
                trn_tsrc_rdy_n_i     <= '0';
                trn_tsof_n_i         <= '0';
                trn_td_i             <= Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
              else
                TxTrn_State          <= St_nd_Prepare;
                trn_tsrc_rdy_n_i     <= '1';
                trn_tsof_n_i         <= '1';
                trn_td_i             <= (Others=>'0');
              end if;


            when St_nd_Header2    =>
              trn_tsrc_rdy_n_i     <= '0';
              if trn_tdst_rdy_n_i = '1' then
                TxTrn_State          <= St_nd_Header2;
                trn_tsof_n_i         <= trn_tsof_n_i;
                trn_teof_n_i         <= '1';
                trn_td_i             <= trn_td_i; -- Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
              else                                                    -- 3DW header
                TxTrn_State          <= St_nd_HeaderLast;
                trn_tsof_n_i         <= '1';
                trn_teof_n_i         <= '0';
                if Trn_Qout_reg (C_TLP_FMT_BIT_BOT) = '1' then       -- 4DW header
                  trn_trem_n_i         <= X"00";
                  trn_td_i             <= Trn_Qout_reg (C_DBUS_WIDTH*2-1 downto C_DBUS_WIDTH);
                else
                  trn_trem_n_i         <= X"0F";
                  trn_td_i             <= Trn_Qout_reg (C_DBUS_WIDTH-1+32 downto C_DBUS_WIDTH) & X"00000000";
                end if;
              end if;


            when St_nd_HeaderLast    =>
              trn_tsof_n_i         <= '1';
              if trn_tdst_rdy_n_i = '1' then
                TxTrn_State          <= St_nd_HeaderLast;
                trn_tsrc_rdy_n_i     <= '0';
                trn_teof_n_i         <= '0';
                trn_td_i             <= trn_td_i;
                trn_trem_n_i         <= trn_trem_n_i;
              else
                TxTrn_State          <= St_nd_Arbitration;  -- St_TxIdle;
                trn_tsrc_rdy_n_i     <= '1';
                trn_teof_n_i         <= '1';
                trn_td_i             <= trn_td_i;
                trn_trem_n_i         <= trn_trem_n_i;
              end if;

            when St_nd_Arbitration    =>
              trn_tsof_n_i         <= '1';
              TxTrn_State          <= St_TxIdle;
              trn_tsrc_rdy_n_i     <= '1';
              trn_teof_n_i         <= '1';
              trn_td_i             <= trn_td_i;
              trn_trem_n_i         <= (OTHERS=>'0');


            --- --- --- --- --- --- --- --- --- --- --- --- ---
            --- --- --- --- --- --- --- --- --- --- --- --- ---

--            when St_d_CmdReq    =>
--              if RdCmd_Ack = '1' then
--                RdCmd_Req            <= '0';
--                TxTrn_State          <= St_d_CmdAck;
--              else
--                RdCmd_Req            <= '1';
--                TxTrn_State          <= St_d_CmdReq;
--              end if;


            when St_d_CmdAck    =>
              trn_teof_n_i         <= '1';
              if mbuf_Empty = '0' and trn_tdst_rdy_n_i = '0' then
                trn_tsrc_rdy_n_i     <= '1';
                trn_tsof_n_i         <= '1';
                trn_td_i             <= (Others=>'0');
                TxTrn_State          <= St_d_Header0;
              else
                trn_tsrc_rdy_n_i     <= '1';
                trn_tsof_n_i         <= '1';
                trn_td_i             <= (Others=>'0');
                TxTrn_State          <= St_d_CmdAck;
              end if;


            when St_d_Header0    =>
              if trn_tdst_rdy_n_i = '0' then
                trn_tsrc_rdy_n_i     <= '0';
                trn_tsof_n_i         <= '0';
                trn_teof_n_i         <= '1';
                trn_td_i             <= Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
                TxTrn_State          <= St_d_Header2;
              else
                trn_tsrc_rdy_n_i     <= '1';
                trn_tsof_n_i         <= '1';
                trn_teof_n_i         <= '1';
                trn_td_i             <= trn_td_i;
                TxTrn_State          <= St_d_Header0;
              end if;


            when St_d_Header2    =>
              trn_tsrc_rdy_n_i     <= '0';
              trn_trem_n_i         <= (OTHERS=>'0');
              if trn_tdst_rdy_n_i = '1' then
                TxTrn_State          <= St_d_Header2;
                trn_td_i             <= Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
                trn_tsof_n_i         <= '0';
                trn_teof_n_i         <= '1';
              elsif Trn_Qout_reg (C_TLP_FMT_BIT_BOT) = '1' then   -- 4DW header
                TxTrn_State          <= St_d_1st_Data;  -- St_d_HeaderPlus;
                trn_td_i             <= Trn_Qout_reg (C_DBUS_WIDTH*2-1 downto C_DBUS_WIDTH);
                trn_tsof_n_i         <= '1';
                trn_teof_n_i         <= '1';
              else                                                -- 3DW header
                trn_td_i             <= Trn_Qout_reg (C_DBUS_WIDTH*2-1 downto C_DBUS_WIDTH+32) 
                                      & mbuf_Qout(C_DBUS_WIDTH-1-32 downto 0);
                trn_tsof_n_i         <= '1';
                trn_teof_n_i         <= mbuf_Qout(C_DBUS_WIDTH);
                if mbuf_Qout(C_DBUS_WIDTH) = '0' then
                  TxTrn_State          <= St_d_Tail_chk;
                else
                  TxTrn_State          <= St_d_1st_Data;
                end if;
              end if;


            when St_d_1st_Data    =>
              if trn_tdst_rdy_n_i = '1' then
                TxTrn_State          <= St_d_1st_Data;
                trn_teof_n_i         <= '1';
                trn_td_i             <= trn_td_i;
                trn_tsrc_rdy_n_i     <= '0';
              elsif mbuf_Qout(C_DBUS_WIDTH) = '0' then
                TxTrn_State          <= St_d_Tail_chk;
                trn_teof_n_i         <= '0';
                trn_trem_n_i         <= X"0" & mbuf_Qout(70) & mbuf_Qout(70) 
                                             & mbuf_Qout(70) & mbuf_Qout(70);
                trn_td_i             <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
                trn_tsrc_rdy_n_i     <= not mbuf_Qvalid; -- '0';
              elsif mbuf_Qvalid = '0' then
                TxTrn_State          <= St_d_Payload_used;
                trn_teof_n_i         <= '1';
                trn_td_i             <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
                trn_tsrc_rdy_n_i     <= '1';
              else
                TxTrn_State          <= St_d_Payload;
                trn_teof_n_i         <= '1';
                trn_td_i             <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
                trn_tsrc_rdy_n_i     <= '0';
              end if;


            when St_d_Payload    =>
              if trn_tdst_rdy_n_i='1' then
                trn_td_i             <= trn_td_i;
                trn_teof_n_i         <= trn_teof_n_i;
                trn_trem_n_i         <= trn_trem_n_i;
                trn_tsrc_rdy_n_i     <= '0';
                if mbuf_Qout(C_DBUS_WIDTH) = '0' then
                  TxTrn_State          <= St_d_Tail;
                elsif mbuf_Qvalid='1' then
                  TxTrn_State          <= St_d_Payload;
                else
                  TxTrn_State          <= St_d_Payload_used;
                end if;
              else
                trn_td_i             <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
                trn_teof_n_i         <= mbuf_Qout(C_DBUS_WIDTH);
                trn_tsrc_rdy_n_i     <= mbuf_Qout(C_DBUS_WIDTH) and not mbuf_Qvalid;
                if mbuf_Qout(C_DBUS_WIDTH) = '0' then
                  TxTrn_State          <= St_d_Tail_chk;
                  trn_trem_n_i         <= X"0" & mbuf_Qout(70) & mbuf_Qout(70) 
                                               & mbuf_Qout(70) & mbuf_Qout(70);
                elsif mbuf_Qvalid='1' then
                  trn_trem_n_i         <= (OTHERS=>'0');
                  TxTrn_State          <= St_d_Payload;
                else
                  trn_trem_n_i         <= (OTHERS=>'0');
                  TxTrn_State          <= St_d_Payload_used;
                end if;
              end if;


            when St_d_Payload_used    =>
              if trn_tsrc_rdy_n_i='0' then
                trn_td_i             <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
                trn_tsrc_rdy_n_i     <= not mbuf_Qvalid and not trn_tdst_rdy_n_i;
                if mbuf_Qout(C_DBUS_WIDTH) = '0' then
                  trn_teof_n_i         <= '0';
                  trn_trem_n_i         <= X"0" & mbuf_Qout(70) & mbuf_Qout(70) 
                                               & mbuf_Qout(70) & mbuf_Qout(70);
                else
                  trn_teof_n_i         <= '1';
                  trn_trem_n_i         <= (OTHERS=>'0');
                end if;
                if mbuf_Qvalid='1' then
                  TxTrn_State          <= St_d_Payload;
                else
                  TxTrn_State          <= St_d_Payload_used;
                end if;
              elsif mbuf_Qvalid='1' then
                  trn_td_i             <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
                  trn_tsrc_rdy_n_i     <= '0';
                  if mbuf_Qout(C_DBUS_WIDTH) = '0' then
                    trn_teof_n_i         <= '0';
                    trn_trem_n_i         <= X"0" & mbuf_Qout(70) & mbuf_Qout(70) 
                                                 & mbuf_Qout(70) & mbuf_Qout(70);
                  else
                    trn_teof_n_i         <= '1';
                    trn_trem_n_i         <= (OTHERS=>'0');
                  end if;
                  if mbuf_Qout(C_DBUS_WIDTH) = '0' then
                    TxTrn_State          <= St_d_Tail_chk;
                  else
                    TxTrn_State          <= St_d_Payload;
                  end if;
              else
                  TxTrn_State          <= St_d_Payload_used;
                  trn_td_i             <= trn_td_i;
                  trn_teof_n_i         <= trn_teof_n_i;
                  trn_trem_n_i         <= trn_trem_n_i;
                  trn_tsrc_rdy_n_i     <= '1';
              end if;


            when St_d_Tail    =>
              trn_tsrc_rdy_n_i     <= '0';
              if trn_tdst_rdy_n_i = '1' then
                TxTrn_State          <= St_d_Tail;
                trn_teof_n_i         <= trn_teof_n_i;
                trn_trem_n_i         <= trn_trem_n_i;
                trn_td_i             <= trn_td_i;
              else
                TxTrn_State          <= St_d_Tail_chk;
                trn_teof_n_i         <= '0';
                trn_trem_n_i         <= X"0" & mbuf_Qout(70) & mbuf_Qout(70) 
                                             & mbuf_Qout(70) & mbuf_Qout(70);
                trn_td_i             <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
              end if;


            when St_d_Tail_chk    =>
              if trn_tdst_rdy_n_i = '1' then
                trn_tsrc_rdy_n_i     <= '0';
                trn_teof_n_i         <= '0';
                trn_trem_n_i         <= trn_trem_n_i;
                trn_td_i             <= trn_td_i;
                TxTrn_State          <= St_d_Tail_chk;
              elsif take_an_Arbitration = '1' then
                trn_tsrc_rdy_n_i     <= '1';
                trn_teof_n_i         <= '1';
                trn_td_i             <= (Others=>'0');
                trn_trem_n_i         <= (Others=>'0');
                TxTrn_State          <= St_d_AfterChk;
              else
                trn_tsrc_rdy_n_i     <= '1';
                trn_teof_n_i         <= '1';
                trn_td_i             <= (Others=>'0');
                trn_trem_n_i         <= (Others=>'0');
                TxTrn_State          <= St_TxIdle;
              end if;


            when St_d_AfterChk    =>
              trn_tsrc_rdy_n_i     <= '1';
              trn_teof_n_i         <= '1';
              trn_td_i             <= (Others=>'0');
              trn_trem_n_i         <= (Others=>'0');
              TxTrn_State          <= St_TxIdle;


            when Others    =>
               trn_tsrc_rdy_n_i     <= '1';
               trn_tsof_n_i         <= '1';
               trn_teof_n_i         <= '1';
               trn_td_i             <= (Others=>'0');
               trn_trem_n_i         <= (Others=>'0');
               TxTrn_State          <= St_TxIdle;

         end case;


      end if;
   end process;


-- ---------------------------------------------------
-- State Machine output: mbuf_RE_ok
--
   TxFSM_Output_mbuf_RE_ok:
   process ( trn_clk, trn_tx_Reset_n)
   begin
      if trn_tx_Reset_n = '0' then
         mbuf_RE_ok     <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         case TxTrn_State is

            when St_TxIdle    =>
              mbuf_RE_ok           <= '0';

            when St_d_CmdAck    =>
              mbuf_RE_ok           <= not mbuf_Empty and not trn_tdst_rdy_n_i;

            when St_d_Header0    =>
              mbuf_RE_ok           <= not Trn_Qout_reg(C_TLP_FMT_BIT_BOT) and not trn_tdst_rdy_n_i;      -- '1'; -- 4DW

            when St_d_Header2    =>
              if Trn_Qout_reg(C_TLP_FMT_BIT_BOT)='1' then          -- 4DW header
                mbuf_RE_ok           <= not trn_tdst_rdy_n_i;
              elsif Payload_rd_count=CONV_STD_LOGIC_VECTOR(0, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= '0';
              elsif Payload_rd_count=CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= not mbuf_RE or mbuf_Empty;
              else                                                 -- 3DW header
                mbuf_RE_ok           <= not trn_tsrc_rdy_n_i;  -- or trn_tdst_rdy_n_i;
              end if;

            when St_d_1st_Data    =>
              if Payload_rd_count=CONV_STD_LOGIC_VECTOR(0, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= '0';
              elsif Payload_rd_count=CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= not mbuf_RE or mbuf_Empty;
              else
                mbuf_RE_ok           <= '1';
              end if;

            when St_d_Payload    =>
              if Payload_rd_count=CONV_STD_LOGIC_VECTOR(0, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= '0';
              elsif Payload_rd_count=CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= not mbuf_RE or mbuf_Empty;
              else
                mbuf_RE_ok           <= '1';
              end if;

            when St_d_Payload_used    =>
              if Payload_rd_count=CONV_STD_LOGIC_VECTOR(0, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= '0';
              elsif Payload_rd_count=CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
                mbuf_RE_ok           <= not mbuf_RE or mbuf_Empty;
              else
                mbuf_RE_ok           <= '1';
              end if;

            when Others    =>
               mbuf_RE_ok           <= '0';

         end case;

      end if;
   end process;


-- ---------------------------------------------------
-- State Machine output: Payload_rd_count
--
   TxFSM_Output_Payload_rd_count:
   process ( trn_clk, trn_tx_Reset_n)
   begin
      if trn_tx_Reset_n = '0' then
         Payload_rd_count     <= (Others=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         case TxTrn_State is

            when St_d_CmdAck    =>
              if Trn_Qout_reg(C_TLP_LENG_BIT_BOT)='0'              -- Length[0]
                 and Trn_Qout_reg(C_TLP_FMT_BIT_BOT)='1'           -- 4-DW
                 then
                Payload_rd_count     <=  '0'&Trn_Qout_wire(C_TLP_FLD_WIDTH_OF_LENG-1+32 downto 32+1);
              else
                Payload_rd_count     <=  ('0'&Trn_Qout_wire(C_TLP_FLD_WIDTH_OF_LENG-1+32 downto 32+1)) + '1';
              end if;

            when Others    =>
              if mbuf_RE='1' and mbuf_Empty='0' then
                Payload_rd_count     <=  Payload_rd_count - '1';
              else
                Payload_rd_count     <=  Payload_rd_count;
              end if;

         end case;

      end if;
   end process;


-- ---------------------------------------------------
-- State Machine output: take_an_Arbitration
--
   TxFSM_take_an_Arbitration:
   process ( trn_clk, trn_tx_Reset_n)
   begin
      if trn_tx_Reset_n = '0' then
         take_an_Arbitration     <= '0';
         Trn_Qout_reg            <= (Others=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         case TxTrn_State is

            when St_nd_Header2    =>
              if trn_tdst_rdy_n_i = '0' then
                take_an_Arbitration  <= '1';
              else
                take_an_Arbitration  <= '0';
              end if;

            when St_d_Header2    =>             -- //  St_d_Header0
              if trn_tdst_rdy_n_i = '0' then
                take_an_Arbitration  <= '1';
              else
                take_an_Arbitration  <= '0';
              end if;

            when Others    =>
               take_an_Arbitration  <= '0';

         end case;

         if Read_aBuffer_r2='1' then
           Trn_Qout_reg         <= Trn_Qout_wire;
         else
           Trn_Qout_reg         <= Trn_Qout_reg;
         end if;

      end if;
   end process;


-- ---------------------------------------------------
-- State Machine: Arbitration requests data
--
   TxFSM_arq_State:
   process ( trn_clk, trn_tx_Reset_n)
   begin
      if trn_tx_Reset_n = '0' then
         RdNumber             <= (Others=>'0');
         RdNumber_eq_One      <= '0';
         RdNumber_eq_Two      <= '0';
         StartAddr            <= (Others=>'0');
         Shift_1st_QWord      <= '0';
         is_CplD              <= '0';
         BAR_value            <= (Others=>'0');
         RdCmd_Req            <= '0';
         arq_State            <= StA_idle;

      elsif trn_clk'event and trn_clk = '1' then

         case arq_State is

            when StA_idle    =>
              if ChBuf_has_Payload = '1' and Read_aBuffer_r2='1' then
                RdNumber             <=  Trn_Qout_wire (C_TLP_FLD_WIDTH_OF_LENG-1+32 downto 32);
                RdNumber_eq_One      <=  pioCplD_Req_Min_Leng or usTlp_Req_Min_Leng;
                RdNumber_eq_Two      <=  pioCplD_Req_2DW_Leng or usTlp_Req_2DW_Leng;
                RdCmd_Req            <=  '1';
                if pioCplD_is_0Leng='1' then
                  BAR_value            <=  '0' & CONV_STD_LOGIC_VECTOR(CINT_REGS_SPACE_BAR, C_ENCODE_BAR_NUMBER-1);
                  StartAddr            <=  C_ALL_ONES(C_DBUS_WIDTH-1 downto 0) ;
                  Shift_1st_QWord      <=  '1';
                  is_CplD              <=  '0';
                elsif BAR_pioCplD=CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                  BAR_value            <=  '0' & BAR_pioCplD(C_ENCODE_BAR_NUMBER-2 downto 0);
                  StartAddr            <=  (C_ALL_ONES(C_DBUS_WIDTH-1 downto C_DDR_IAWIDTH) & DDRAddr_pioCplD);
                  Shift_1st_QWord      <=  '1';
                  is_CplD              <=  '1';
                elsif BAR_pioCplD=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                  BAR_value            <=  '0' & BAR_pioCplD(C_ENCODE_BAR_NUMBER-2 downto 0);
                  StartAddr            <=  (C_ALL_ONES(C_DBUS_WIDTH-1 downto C_PRAM_AWIDTH+2) & mAddr_pioCplD);
                  Shift_1st_QWord      <=  '1';
                  is_CplD              <=  '1';
                elsif BAR_usTlp=CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                  BAR_value            <=  '0' & BAR_usTlp(C_ENCODE_BAR_NUMBER-2 downto 0);
                  StartAddr            <=  C_ALL_ONES(C_DBUS_WIDTH-1 downto C_DDR_IAWIDTH) & DDRAddr_usTlp;
                  Shift_1st_QWord      <=  not usTlp_Qout_to_TLP(C_TLP_FMT_BIT_BOT);
                  is_CplD              <=  '0';
                elsif BAR_usTlp=CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
                  BAR_value            <=  '0' & BAR_usTlp(C_ENCODE_BAR_NUMBER-2 downto 0);
                  StartAddr            <=  C_ALL_ONES(C_DBUS_WIDTH-1 downto C_DDR_IAWIDTH) & DDRAddr_usTlp;
                  Shift_1st_QWord      <=  not usTlp_Qout_to_TLP(C_TLP_FMT_BIT_BOT);
                  is_CplD              <=  '0';
                else
                  BAR_value            <=  '0' & BAR_pioCplD(C_ENCODE_BAR_NUMBER-2 downto 0);
                  StartAddr            <=  (C_ALL_ONES(C_DBUS_WIDTH-1 downto C_EP_AWIDTH) & Regs_Addr_pioCplD);
                  Shift_1st_QWord      <=  '1';
                  is_CplD              <=  '0';
                end if;
                arq_State            <=  StA_req;
              else
                RdNumber             <=  RdNumber;
                RdNumber_eq_One      <=  RdNumber_eq_One;
                RdNumber_eq_Two      <=  RdNumber_eq_Two;
                RdCmd_Req            <=  '0';
                BAR_value            <=  BAR_value;
                StartAddr            <=  StartAddr;
                Shift_1st_QWord      <=  Shift_1st_QWord;
                is_CplD              <=  is_CplD;
                arq_State            <=  StA_idle;
              end if;

            when StA_req    =>
              if RdCmd_Ack = '1' then
                RdCmd_Req          <= '0';
                arq_State          <= StA_idle;
              else
                RdCmd_Req          <= '1';
                arq_State          <= StA_req;
              end if;

            when Others    =>
              RdNumber           <=  RdNumber;
              RdNumber_eq_One    <=  RdNumber_eq_One;
              RdNumber_eq_Two    <=  RdNumber_eq_Two;
              RdCmd_Req          <=  '0';
              BAR_value          <=  BAR_value;
              StartAddr          <=  StartAddr;
              Shift_1st_QWord    <=  Shift_1st_QWord;
              is_CplD            <=  is_CplD;
              arq_State          <=  StA_idle;

         end case;

      end if;
   end process;


---------------------------------------------------------------------------------
-- Synchronous Accumulation: us_DMA_Bytes
-- 
   Synch_Acc_us_DMA_Bytes:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
        us_DMA_Bytes_i   <= '0' & trn_td_i(32+C_TLP_FLD_WIDTH_OF_LENG-1 downto 32) & "00";
        if trn_td_i(C_TLP_FMT_BIT_TOP) = '1'
           and trn_td_i(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) 
               = C_ALL_ZEROS(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) then
           us_DMA_Bytes_Add_i  <=  not trn_tsof_n_i 
                               and not trn_tsrc_rdy_n_i
                               and not trn_tdst_rdy_n_i
                               ;
        else
           us_DMA_Bytes_Add_i  <= '0';
        end if;
      end if;
   end process;


end architecture Behavioral;

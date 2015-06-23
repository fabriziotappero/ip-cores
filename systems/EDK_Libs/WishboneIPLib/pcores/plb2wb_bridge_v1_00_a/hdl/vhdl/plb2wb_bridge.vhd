----------------------------------------------------------------------
----                                                              ----
----  PLB2WB-Bridge                                               ----
----                                                              ----
----  This file is part of the PLB-to-WB-Bridge project           ----
----  http://opencores.org/project,plb2wbbridge                   ----
----                                                              ----
----  Description                                                 ----
----  Implementation of a PLB-to-WB-Bridge according to           ----
----  PLB-to-WB Bridge specification document.                    ----
----                                                              ----
----  To Do:                                                      ----
----   Nothing                                                    ----
----                                                              ----
----  Author(s):                                                  ----
----      - Christian Haettich                                    ----
----        feddischson@opencores.org                             ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2010 Authors                                   ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


library plb2wb_bridge_v1_00_a;
use plb2wb_bridge_v1_00_a.all;
use plb2wb_bridge_v1_00_a.plb2wb_pkg.ALL;

------------------------------------------------------------------------------
-- Definition of Generics:
--
--   SYNCHRONY                    -- The PLB and WB clocks are synchron
--   WB_ADR_OFFSET                -- Address offset: is added to every address on WB side
--   WB_ADR_OFFSET_NEG            -- Defines if WB_ADR_OFFSET is added or subtracted
--   WB_PIC_INTS                  -- Number of Wishbone interrupt lines
--   WB_PIC_INT_LEVEL             -- Interrupts are active high or acrive low
--   WB_SUPPORT_BLOCK             -- Wishbone block transfers are supported
--   WB_DAT_W                     -- Wishbone data bus width
--   WB_ADR_W                     -- Wishbone address bus width
--   WB_TIMEOUT_CYCLES            -- Watchdog timer cycles
--   
--   
--   C_BASEADDR                   -- PLBv46 slave: base address
--   C_HIGHADDR                   -- PLBv46 slave: high address
--   C_SPLB_AWIDTH                -- PLBv46 slave: address bus width
--   C_STATUS_BASEADDR            -- PLBv46 slave: base address of status registers
--   C_STATUS_HIGHADDR            -- PLBv46 slave: base address of status registers
--   C_SPLB_DWIDTH                -- PLBv46 slave: data bus width
--   C_SPLB_NUM_MASTERS           -- PLBv46 slave: Number of masters
--   C_SPLB_MID_WIDTH             -- PLBv46 slave: master ID bus width
--   C_SPLB_NATIVE_DWIDTH         -- PLBv46 slave: internal native data bus width
--   C_SPLB_SUPPORT_BUR_LINE      -- PLBv46 slave: support burst and line transfers
--   C_SPLB_SUPPORT_ADR_PIPE      -- PLBv46 slave: support address pipelining
--
-- Definition of Ports:
--   SPLB_Clk                     -- PLB main bus clock
--   SPLB_Rst                     -- PLB main bus reset
--   PLB_ABus                     -- PLB address bus
--   PLB_UABus                    -- PLB upper address bus
--   PLB_PAValid                  -- PLB primary address valid indicator
--   PLB_SAValid                  -- PLB secondary address valid indicator
--   PLB_rdPrim                   -- PLB secondary to primary read request indicator
--   PLB_wrPrim                   -- PLB secondary to primary write request indicator
--   PLB_masterID                 -- PLB current master identifier
--   PLB_abort                    -- PLB abort request indicator
--   PLB_busLock                  -- PLB bus lock
--   PLB_RNW                      -- PLB read/not write
--   PLB_BE                       -- PLB byte enables
--   PLB_MSize                    -- PLB master data bus size
--   PLB_size                     -- PLB transfer size
--   PLB_type                     -- PLB transfer type
--   PLB_lockErr                  -- PLB lock error indicator
--   PLB_wrDBus                   -- PLB write data bus
--   PLB_wrBurst                  -- PLB burst write transfer indicator
--   PLB_rdBurst                  -- PLB burst read transfer indicator
--   PLB_wrPendReq                -- PLB write pending bus request indicator
--   PLB_rdPendReq                -- PLB read pending bus request indicator
--   PLB_wrPendPri                -- PLB write pending request priority
--   PLB_rdPendPri                -- PLB read pending request priority
--   PLB_reqPri                   -- PLB current request priority
--   PLB_TAttribute               -- PLB transfer attribute
--   Sl_addrAck                   -- PLB slave address acknowledge
--   Sl_SSize                     -- PLB slave data bus size
--   Sl_wait                      -- PLB slave wait indicator
--   Sl_rearbitrate               -- PLB slave re-arbitrate bus indicator
--   Sl_wrDAck                    -- PLB slave write data acknowledge
--   Sl_wrComp                    -- PLB slave write transfer complete indicator
--   Sl_wrBTerm                   -- PLB slave terminate write burst transfer
--   Sl_rdDBus                    -- PLB slave read data bus
--   Sl_rdWdAddr                  -- PLB slave read word address
--   Sl_rdDAck                    -- PLB slave read data acknowledge
--   Sl_rdComp                    -- PLB slave read transfer complete indicator
--   Sl_rdBTerm                   -- PLB slave terminate read burst transfer
--   Sl_MBusy                     -- PLB slave busy indicator
--   Sl_MWrErr                    -- PLB slave write error indicator
--   Sl_MRdErr                    -- PLB slave read error indicator
--   Sl_MIRQ                      -- PLB slave bus interrupt indicator (not used by xilinx)
--   PLB2WB_IRQ                   -- PLB slave interrupt out 

-- WB Signals ---------------------------------------
--   wb_clk_i                     -- WB bus clock
--   wb_rst_i                     -- WB bus reset
--   wb_dat_i                     -- WB master read data bus
--   wb_dat_o                     -- WB master write data bus
--   wb_adr_o                     -- WB master address bus
--   wb_sel_o                     -- WB master byte enables
--   wb_we_o                      -- WB master write enable ('0' when read)
--   wb_cyc_o                     -- WB master bus cycle indicator
--   wb_stb_o                     -- WB master strobe output
--   wb_ack_i                     -- WB master acknowledge input
--   wb_err_i                     -- WB master error input
--   wb_rty_i                     -- WB master retry input
--   wb_lock_o                    -- WB master bus lock
--   wb_pic_int_i                 -- WB master interrupt input

------------------------------------------------------------------------------

entity plb2wb_bridge is
   generic
   (
      SYNCHRONY                      : boolean              := true;       --  true = synchron, false = asynchron!

      -- PLB Parameters -----------------------------------
      C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
      C_HIGHADDR                     : std_logic_vector     := X"00000000";
      C_STATUS_BASEADDR              : std_logic_vector     := X"FFFFFFFF";
      C_STATUS_HIGHADDR              : std_logic_vector     := X"00000000";
      C_SPLB_AWIDTH                  : integer              := 32;
      C_SPLB_DWIDTH                  : integer              := 128;
      C_SPLB_NUM_MASTERS             : integer              := 8;
      C_SPLB_MID_WIDTH               : integer              := 3;
      C_SPLB_NATIVE_DWIDTH           : integer              := 32;
      C_SPLB_SUPPORT_BUR_LINE          : integer              := 1;
      C_SPLB_SUPPORT_ADR_PIPE        : integer              := 1;

      -- WB Parameters -----------------------------------
      WB_DAT_W                       : integer              := 32;
      WB_ADR_W                       : integer              := 32;
      WB_TIMEOUT_CYCLES              : integer              := 10;
      WB_ADR_OFFSET                  : std_logic_vector     := X"00000000";
      WB_ADR_OFFSET_NEG              : std_logic            := '0';
      WB_PIC_INTS                    : integer              := 0;    
      WB_PIC_INT_LEVEL               : std_logic            := '1';
      WB_SUPPORT_BLOCK               : integer              := 1
   );
   port
   (

      PLB2WB_IRQ                    : out  std_logic;

      -- WB Signals ---------------------------------------
      wb_clk_i                      : in   std_logic;
      wb_rst_i                      : in   std_logic;
      wb_dat_i                      : in   std_logic_vector( WB_DAT_W-1   downto 0 );
      wb_dat_o                      : out  std_logic_vector( WB_DAT_W-1   downto 0 );
      wb_adr_o                      : out  std_logic_vector( WB_ADR_W-1   downto 0 );
      wb_sel_o                      : out  std_logic_vector( WB_DAT_W/8-1 downto 0 );
      wb_we_o                       : out  std_logic;
      wb_cyc_o                      : out  std_logic;
      wb_stb_o                      : out  std_logic;
      wb_ack_i                      : in   std_logic;
      wb_err_i                      : in   std_logic;
      wb_rty_i                      : in   std_logic;
      wb_lock_o                     : out  std_logic;
     
      wb_pic_int_i                  : in   std_logic_vector( WB_PIC_INTS-1 downto 0 );
      
      -- PLB Signals --------------------------------------
      SPLB_Clk                       : in  std_logic;
      SPLB_Rst                       : in  std_logic;
      PLB_ABus                       : in  std_logic_vector( 0 to 31 );
      PLB_UABus                      : in  std_logic_vector( 0 to 31 );
      PLB_PAValid                    : in  std_logic;
      PLB_SAValid                    : in  std_logic;
      PLB_rdPrim                     : in  std_logic;
      PLB_wrPrim                     : in  std_logic;
      PLB_masterID                   : in  std_logic_vector( 0 to C_SPLB_MID_WIDTH-1 );
      PLB_abort                      : in  std_logic;
      PLB_busLock                    : in  std_logic;
      PLB_RNW                        : in  std_logic;
      PLB_BE                         : in  std_logic_vector( 0 to C_SPLB_DWIDTH/8-1 );
      PLB_MSize                      : in  std_logic_vector( 0 to 1 );
      PLB_size                       : in  std_logic_vector( 0 to 3 );
      PLB_type                       : in  std_logic_vector( 0 to 2 );
      PLB_lockErr                    : in  std_logic;
      PLB_wrDBus                     : in  std_logic_vector( 0 to C_SPLB_DWIDTH-1 );
      PLB_wrBurst                    : in  std_logic;
      PLB_rdBurst                    : in  std_logic;
      PLB_wrPendReq                  : in  std_logic;
      PLB_rdPendReq                  : in  std_logic;
      PLB_wrPendPri                  : in  std_logic_vector( 0 to 1  );
      PLB_rdPendPri                  : in  std_logic_vector( 0 to 1  );
      PLB_reqPri                     : in  std_logic_vector( 0 to 1  );
      PLB_TAttribute                 : in  std_logic_vector( 0 to 15 );
      Sl_addrAck                     : out std_logic;
      Sl_SSize                       : out std_logic_vector( 0 to 1  );
      Sl_wait                        : out std_logic;
      Sl_rearbitrate                 : out std_logic;
      Sl_wrDAck                      : out std_logic;
      Sl_wrComp                      : out std_logic;
      Sl_wrBTerm                     : out std_logic;
      Sl_rdDBus                      : out std_logic_vector( 0 to C_SPLB_DWIDTH-1 );
      Sl_rdWdAddr                    : out std_logic_vector( 0 to 3               );
      Sl_rdDAck                      : out std_logic;
      Sl_rdComp                      : out std_logic;
      Sl_rdBTerm                     : out std_logic;
      Sl_MBusy                       : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
      Sl_MWrErr                      : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
      Sl_MRdErr                      : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
      Sl_MIRQ                        : out std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 )
   );
   

   constant WB_DWIDTH               : integer := 32;
   constant WB_AWIDTH               : integer := WB_ADR_W;
   constant C_SPLB_SIZE_WIDTH       : integer := 4;
   constant C_SPLB_TYPE_WIDTH       : integer := 3;
   constant C_SPLB_BE_WIDTH         : integer := C_SPLB_DWIDTH/8;
   constant C_SPLB_NATIVE_BE_WIDTH  : integer := C_SPLB_NATIVE_DWIDTH/8;


end entity plb2wb_bridge;





architecture IMP of plb2wb_bridge is


   signal  wb_dat_o_t         : std_logic_vector( WB_DAT_W-1   downto 0 );
   signal  wb_adr_o_t         : std_logic_vector( WB_ADR_W-1   downto 0 );
   signal  wb_sel_o_t         : std_logic_vector( WB_DAT_W/8-1 downto 0 );
   signal  wb_we_o_t          : std_logic;
   signal  wb_cyc_o_t         : std_logic;
   signal  wb_stb_o_t         : std_logic;

   signal  Sl_addrAck_t       : std_logic;
   signal  Sl_SSize_t         : std_logic_vector( 0 to 1 );
   signal  Sl_wait_t          : std_logic;
   signal  Sl_rearbitrate_t   : std_logic;
   signal  Sl_wrDAck_t        : std_logic;
   signal  Sl_wrComp_t        : std_logic;
   signal  Sl_wrBTerm_t       : std_logic;
   signal  Sl_rdDBus_t        : std_logic_vector( 0 to C_SPLB_DWIDTH-1  );
   signal  Sl_rdWdAddr_t      : std_logic_vector( 0 to 3                );
   signal  Sl_rdDAck_t        : std_logic;
   signal  Sl_rdComp_t        : std_logic;
   signal  Sl_rdBTerm_t       : std_logic;
   signal  Sl_MBusy_t         : std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
   signal  Sl_MWrErr_t        : std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
   signal  Sl_MRdErr_t        : std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );
   signal  Sl_MIRQ_t          : std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1 );

   signal  AMU_buf_RNW        : std_logic;

   signal  AMU_bufEmpty       : std_logic;
   signal  AMU_bufFull        : std_logic;
   signal  AMU_deviceSelect   : std_logic;
   signal  AMU_statusSelect   : std_logic;
   signal  AMU_addrAck        : std_logic;
   signal  AMU_pipe_wmID      : std_logic_vector( 0 to C_SPLB_MID_WIDTH -1 );
   signal  AMU_pipe_rmID      : std_logic_vector( 0 to C_SPLB_MID_WIDTH -1 );
   signal  AMU_buf_size       : std_logic_vector( C_SPLB_SIZE_WIDTH-1 downto 0 );
   signal  AMU_buf_BE         : std_logic_vector( C_SPLB_NATIVE_BE_WIDTH-1 downto 0 );
   signal  AMU_buf_adr        : std_logic_vector( WB_ADR_W-1   downto 0 );
   signal  AMU_buf_adr_wo     : std_logic_vector( WB_ADR_W-1   downto 0 );
   signal  AMU_pipe_size      : std_logic_vector( 0 to C_SPLB_SIZE_WIDTH-1 );
   signal  AMU_pipe_BE        : std_logic_vector( 0 to C_SPLB_NATIVE_BE_WIDTH-1 );
   signal  AMU_pipe_adr       : std_logic_vector( 0 to C_SPLB_AWIDTH-1 );
   signal  AMU_buf_masterID   : std_logic_vector( 0 to C_SPLB_MID_WIDTH-1 );
   signal  AMU_pipe_rStatusSelect : std_logic;
   signal  AMU_pipe_wStatusSelect : std_logic;


   signal  RBF_rBus           : std_logic_vector( WB_DWIDTH-1   downto 0 );
   signal  RBF_empty          : std_logic;
   signal  RBF_almostEmpty    : std_logic;
   signal  RBF_full           : std_logic;
   signal  RBF_rdErrOut       : std_logic;
   signal  RBF_rdErrIn        : std_logic;

   signal  WBF_empty          : std_logic;
   signal  WBF_full           : std_logic;
   signal  WBF_wBus           : std_logic_vector( 0 to C_SPLB_NATIVE_DWIDTH-1   );


   signal  TCU_wbufWEn        : std_logic;
   signal  TCU_wbufREn        : std_logic;
   signal  TCU_rbufWEn        : std_logic;
   signal  TCU_rbufREn        : std_logic;
   signal  TCU_adrBufREn      : std_logic;
   signal  TCU_adrBufWEn      : std_logic;
   signal  TCU_enRdDBus       : std_logic;
   signal  TCU_enStuRdDBus    : std_logic;
   signal  TCU_MRBusy         : std_logic_vector( 0 to C_SPLB_NUM_MASTERS-1     );  
   signal  TCU_addrAck        : std_logic;
   signal  TCU_rpipeRdEn      : std_logic;
   signal  TCU_wpipeRdEn      : std_logic;
   signal  TCU_adr_offset     : std_logic_vector( 3 downto 0 );
   signal  TCU_stuLatchPA     : std_logic;
   signal  TCU_stuLatchSA     : std_logic;
   signal  TCU_stuWritePA     : std_logic;
   signal  TCU_stuWriteSA     : std_logic;

   signal  TCU_wb_status_info : std_logic_vector( STATUS2PLB_INFO_SIZE-1 downto 0 );
   signal  TCU_stat2plb_en    : std_logic;

   signal  STU_rdDBus         : std_logic_vector( 0 to C_SPLB_DWIDTH-1 );

   signal  STU_full           : std_logic;
   signal  STU_continue       : std_logic;
   signal  STU_abort          : std_logic;
   signal  STU_softReset      : std_logic;


   signal  plb2wb_rst         : std_logic;
   signal  TCU_wb_irq_info    : std_logic_vector( IRQ_INFO_SIZE-1 downto 0 );  

begin


   wb_dat_o          <= wb_dat_o_t       ;
   wb_adr_o          <= wb_adr_o_t       ;
   wb_sel_o          <= wb_sel_o_t       ;
   wb_we_o           <= wb_we_o_t        ;
   wb_cyc_o          <= wb_cyc_o_t       ;
   wb_stb_o          <= wb_stb_o_t       ;

   Sl_addrAck        <= Sl_addrAck_t     ;
   Sl_SSize          <= Sl_SSize_t       ;
   Sl_wait           <= Sl_wait_t        ;
   Sl_rearbitrate    <= Sl_rearbitrate_t ;
   Sl_wrDAck         <= Sl_wrDAck_t      ;
   Sl_wrComp         <= Sl_wrComp_t      ;
   Sl_wrBTerm        <= Sl_wrBTerm_t     ;
   Sl_rdDBus         <= Sl_rdDBus_t      or STU_rdDBus;
   Sl_rdWdAddr       <= Sl_rdWdAddr_t    ;
   Sl_rdDAck         <= Sl_rdDAck_t      ;
   Sl_rdComp         <= Sl_rdComp_t      ;
   Sl_rdBTerm        <= Sl_rdBTerm_t     ;
   Sl_MBusy          <= Sl_MBusy_t       ;
   Sl_MWrErr         <= Sl_MWrErr_t      ;
   Sl_MRdErr         <= Sl_MRdErr_t      ;
   Sl_MIRQ           <= Sl_MIRQ_t        ;



   Sl_MBusy_t        <= TCU_MRBusy;
   Sl_addrAck_t      <= TCU_addrAck or AMU_addrAck;

   -----
   --
   --    Set the slave-size, depending on SPLB_NATIVE_DWIDTH
   --
   Sl_SSize_t <= "01"  when C_SPLB_NATIVE_DWIDTH = 64  else
                 "10"  when C_SPLB_NATIVE_DWIDTH = 128 else
                 "00";



   plb2wb_rst  <= SPLB_Rst or STU_softReset;


   stu : entity plb2wb_bridge_v1_00_a.plb2wb_stu( IMP )
   generic map(
      SYNCHRONY               => SYNCHRONY,
      WB_DWIDTH               => WB_DWIDTH,
      WB_AWIDTH               => WB_AWIDTH,
      C_SPLB_AWIDTH           => C_SPLB_AWIDTH,
      C_SPLB_DWIDTH           => C_SPLB_DWIDTH,
      C_SPLB_MID_WIDTH        => C_SPLB_MID_WIDTH,
      C_SPLB_NUM_MASTERS      => C_SPLB_NUM_MASTERS,
      C_SPLB_SIZE_WIDTH       => C_SPLB_SIZE_WIDTH,
      C_SPLB_BE_WIDTH         => C_SPLB_BE_WIDTH,
      C_SPLB_NATIVE_BE_WIDTH  => C_SPLB_NATIVE_BE_WIDTH,
      C_SPLB_NATIVE_DWIDTH    => C_SPLB_NATIVE_DWIDTH
   )
   port map(
      wb_clk_i             => wb_clk_i,
      SPLB_Clk             => SPLB_Clk,
      SPLB_Rst             => SPLB_Rst,

      AMU_masterID         => AMU_pipe_wmID,
      AMU_pipe_adr         => AMU_pipe_adr,
      AMU_buf_adr_wo       => AMU_buf_adr_wo,
      AMU_buf_masterID     => AMU_buf_masterID,

      PLB_masterID         => PLB_masterID,
      PLB_size             => PLB_size,
      PLB_wrDBus           => PLB_wrDBus,
      PLB_ABus             => PLB_ABus,
      PLB_BE               => PLB_BE       ,
      Sl_rdWdAddr          => Sl_rdWdAddr_t,
      Sl_MIRQ              => Sl_MIRQ_t,

      STU_rdDBus           => STU_rdDBus,
      STU_full             => STU_full,
      STU_continue         => STU_continue,
      STU_abort            => STU_abort,
      STU_softReset        => STU_softReset,
      WBF_wBus             => WBF_wBus,

      TCU_wb_irq_info      => TCU_wb_irq_info,
      TCU_enStuRdDBus      => TCU_enStuRdDBus,
      TCU_wb_status_info   => TCU_wb_status_info,
      TCU_stuLatchPA       => TCU_stuLatchPA,
      TCU_stuLatchSA       => TCU_stuLatchSA,
      TCU_stuWritePA       => TCU_stuWritePA,
      TCU_stuWriteSA       => TCU_stuWriteSA,
      TCU_stat2plb_en      => TCU_stat2plb_en,
      PLB2WB_IRQ           => PLB2WB_IRQ
   );






   amu : entity plb2wb_bridge_v1_00_a.plb2wb_amu( IMP )
   generic map(
      SYNCHRONY               => SYNCHRONY,

      WB_DWIDTH               => WB_DWIDTH,
      WB_AWIDTH               => WB_AWIDTH,
      WB_ADR_OFFSET           => WB_ADR_OFFSET,
      WB_ADR_OFFSET_NEG       => WB_ADR_OFFSET_NEG,

      C_BASEADDR              => C_BASEADDR,
      C_HIGHADDR              => C_HIGHADDR,
      C_STATUS_BASEADDR       => C_STATUS_BASEADDR,
      C_STATUS_HIGHADDR       => C_STATUS_HIGHADDR,
      C_SPLB_AWIDTH           => C_SPLB_AWIDTH,  
      C_SPLB_SIZE_WIDTH       => C_SPLB_SIZE_WIDTH, 
      C_SPLB_TYPE_WIDTH       => C_SPLB_TYPE_WIDTH,
      C_SPLB_BE_WIDTH         => C_SPLB_BE_WIDTH,
      C_SPLB_NATIVE_BE_WIDTH  => C_SPLB_NATIVE_BE_WIDTH,
      C_SPLB_SUPPORT_BUR_LINE => C_SPLB_SUPPORT_BUR_LINE,
      C_SPLB_MID_WIDTH        => C_SPLB_MID_WIDTH,
      C_SPLB_SUPPORT_ADR_PIPE => C_SPLB_SUPPORT_ADR_PIPE
   )
   port map(

      wb_clk_i             => wb_clk_i     ,
      wb_sel_o             => wb_sel_o_t   ,

      SPLB_Clk             => SPLB_Clk     ,
      plb2wb_rst           => plb2wb_rst   ,

      PLB_ABus             => PLB_ABus     ,
      PLB_UABus            => PLB_UABus    ,
      PLB_SAValid          => PLB_SAValid  ,
      PLB_size             => PLB_size     ,
      PLB_type             => PLB_type     ,
      PLB_BE               => PLB_BE       ,
      PLB_RNW              => PLB_RNW      ,
      PLB_masterID         => PLB_masterID ,

      TCU_adrBufREn        => TCU_adrBufREn,
      TCU_adrBufWEn        => TCU_adrBufWEn,
      TCU_rpipeRdEn        => TCU_rpipeRdEn,
      TCU_wpipeRdEn        => TCU_wpipeRdEn ,
      TCU_stuWriteSA       => TCU_stuWriteSA,

      AMU_deviceSelect     => AMU_deviceSelect,
      AMU_statusSelect     => AMU_statusSelect,
      AMU_bufEmpty         => AMU_bufEmpty ,
      AMU_bufFull          => AMU_bufFull,
      AMU_addrAck          => AMU_addrAck,
      AMU_buf_RNW          => AMU_buf_RNW,
      AMU_pipe_wmID        => AMU_pipe_wmID,
      AMU_pipe_rmID        => AMU_pipe_rmID,
      AMU_buf_size         => AMU_buf_size,
      AMU_buf_masterID     => AMU_buf_masterID,
      AMU_buf_adr          => AMU_buf_adr,
      AMU_buf_adr_wo       => AMU_buf_adr_wo,
      AMU_pipe_size        => AMU_pipe_size,
      AMU_pipe_BE          => AMU_pipe_BE,
      AMU_buf_BE           => AMU_buf_BE,
      AMU_pipe_adr         => AMU_pipe_adr,
      AMU_pipe_rStatusSelect  =>AMU_pipe_rStatusSelect,
      AMU_pipe_wStatusSelect  =>AMU_pipe_wStatusSelect
   );


   wb_adr_o_t <= std_logic_vector( unsigned( AMU_buf_adr ) + unsigned( TCU_adr_offset & "00" ) );








   tcu : entity plb2wb_bridge_v1_00_a.plb2wb_tcu( IMP )
   generic map(
      C_SPLB_SIZE_WIDTH       => C_SPLB_SIZE_WIDTH,
      C_SPLB_DWIDTH           => C_SPLB_DWIDTH,
      C_SPLB_NATIVE_BE_WIDTH  => C_SPLB_NATIVE_BE_WIDTH,
      C_SPLB_NUM_MASTERS      => C_SPLB_NUM_MASTERS,
      C_SPLB_MID_WIDTH        => C_SPLB_MID_WIDTH,
      C_SPLB_TYPE_WIDTH       => C_SPLB_TYPE_WIDTH,
      C_SPLB_SUPPORT_BUR_LINE   => C_SPLB_SUPPORT_BUR_LINE,
      WB_PIC_INTS             => WB_PIC_INTS,
      WB_PIC_INT_LEVEL        => WB_PIC_INT_LEVEL,
      WB_SUPPORT_BLOCK        => WB_SUPPORT_BLOCK               
   )
   port map(

      wb_clk_i             => wb_clk_i,
      wb_stb_o             => wb_stb_o_t,
      wb_we_o              => wb_we_o_t,
      wb_cyc_o             => wb_cyc_o_t,
      wb_ack_i             => wb_ack_i,
      wb_err_i             => wb_err_i,
      wb_rty_i             => wb_rty_i,
      wb_lock_o            => wb_lock_o,
      wb_rst_i             => wb_rst_i,
      wb_pic_int_i         => wb_pic_int_i,

      SPLB_Clk             => SPLB_Clk,
      plb2wb_rst           => plb2wb_rst,
      PLB_MSize            => PLB_MSize,
      PLB_TAttribute       => PLB_TAttribute,
      PLB_lockErr          => PLB_lockErr,
      PLB_abort            => PLB_abort,
      PLB_rdBurst          => PLB_rdBurst,
      PLB_wrBurst          => PLB_wrBurst,     
      PLB_RNW              => PLB_RNW,
      PLB_PAValid          => PLB_PAValid,
      PLB_masterID         => PLB_masterID,
      PLB_rdPrim           => PLB_rdPrim,
      PLB_wrPrim           => PLB_wrPrim,
      PLB_size             => PLB_size,
      PLB_BE               => PLB_BE,
      PLB_type             => PLB_type,

      STU_continue         => STU_continue,
      STU_abort            => STU_abort,

      Sl_MWrErr            => Sl_MWrErr_t,
      Sl_wrDAck            => Sl_wrDAck_t,
      Sl_wrComp            => Sl_wrComp_t,
      Sl_wrBTerm           => Sl_wrBTerm_t,
      Sl_rdDAck            => Sl_rdDAck_t,
      Sl_rdComp            => Sl_rdComp_t,
      Sl_rdBTerm           => Sl_rdBTerm_t,
      Sl_rdWdAddr          => Sl_rdWdAddr_t,
      Sl_wait              => Sl_wait_t,
      Sl_rearbitrate       => Sl_rearbitrate_t,
      Sl_MRdErr            => Sl_MRdErr_t,

      AMU_deviceSelect     => AMU_deviceSelect,
      AMU_bufEmpty         => AMU_bufEmpty,
      AMU_bufFull          => AMU_bufFull,
      AMU_buf_RNW          => AMU_buf_RNW,
      AMU_buf_BE           => AMU_buf_BE,
      AMU_buf_size         => AMU_buf_size,
      AMU_pipe_rmID        => AMU_pipe_rmID,
      AMU_pipe_wmID        => AMU_pipe_wmID,
      AMU_pipe_size        => AMU_pipe_size,
      AMU_pipe_BE          => AMU_pipe_BE,
      AMU_statusSelect     => AMU_statusSelect,
      AMU_pipe_rStatusSelect  =>AMU_pipe_rStatusSelect,
      AMU_pipe_wStatusSelect  =>AMU_pipe_wStatusSelect,

      TCU_wbufWEn          => TCU_wbufWEn,
      TCU_wbufREn          => TCU_wbufREn,
      TCU_rbufWEn          => TCU_rbufWEn,
      TCU_rbufREn          => TCU_rbufREn,
      TCU_adrBufREn        => TCU_adrBufREn,
      TCU_adrBufWEn        => TCU_adrBufWEn,
      TCU_enStuRdDBus      => TCU_enStuRdDBus,
      TCU_enRdDBus         => TCU_enRdDBus,
      TCU_MRBusy           => TCU_MRBusy,
      TCU_addrAck          => TCU_addrAck,
      TCU_rpipeRdEn        => TCU_rpipeRdEn,
      TCU_wpipeRdEn        => TCU_wpipeRdEn ,
      TCU_adr_offset       => TCU_adr_offset,
      TCU_stuLatchPA       => TCU_stuLatchPA,
      TCU_stuLatchSA       => TCU_stuLatchSA,
      TCU_stuWritePA       => TCU_stuWritePA,
      TCU_stuWriteSA       => TCU_stuWriteSA,
      TCU_stat2plb_en      => TCU_stat2plb_en,
      TCU_wb_status_info   => TCU_wb_status_info,
      TCU_wb_irq_info      => TCU_wb_irq_info,

      WBF_empty            => WBF_empty,
      WBF_full             => WBF_full,

      RBF_rdErrOut         => RBF_rdErrOut,
      RBF_rdErrIn          => RBF_rdErrIn,
      RBF_empty            => RBF_empty,
      RBF_almostEmpty      => RBF_almostEmpty,
      RBF_full             => RBF_full
   );











   ---------------------------------
   --
   --
   --
   --    Read and Write Buffer
   --
   --
   wb_dat_o_t     <= WBF_wBus;
  
   gen_128 : if C_SPLB_DWIDTH = 128 generate
      Sl_rdDBus_t <= RBF_rBus & RBF_rBus & RBF_rBus & RBF_rBus when TCU_enRdDBus = '1' else
                                                ( others => '0' );
   end generate gen_128;

   gen_64 : if C_SPLB_DWIDTH = 64 generate
      Sl_rdDBus_t <= RBF_rBus & RBF_rBus                       when TCU_enRdDBus = '1' else
                                                ( others => '0' );
   end generate gen_64;

   gen_32 : if C_SPLB_DWIDTH = 32 generate
      Sl_rdDBus_t <= RBF_rBus                                  when TCU_enRdDBus = '1' else
                                                ( others => '0' );
   end generate gen_32;




   wbuf : entity plb2wb_bridge_v1_00_a.plb2wb_wbuf( IMP_32 )
   generic map(
      SYNCHRONY            => SYNCHRONY,
      C_SPLB_DWIDTH        => C_SPLB_DWIDTH,
      C_SPLB_NATIVE_DWIDTH => C_SPLB_NATIVE_DWIDTH,
      C_SPLB_SIZE_WIDTH    => C_SPLB_SIZE_WIDTH
   )
   port map(

      wb_clk_i             => wb_clk_i,
      SPLB_Clk             => SPLB_Clk,
      plb2wb_rst           => plb2wb_rst,
      PLB_size             => PLB_size,
      PLB_wrDBus           => PLB_wrDBus,
      TCU_wbufWEn          => TCU_wbufWEn,
      TCU_wbufREn          => TCU_wbufREn,
      
      WBF_empty            => WBF_empty,
      WBF_full             => WBF_full,
      WBF_wBus             => WBF_wBus
   );

   rbuf : entity plb2wb_bridge_v1_00_a.plb2wb_rbuf( IMP_32 )
   generic map(
      SYNCHRONY            => SYNCHRONY,
      WB_DWIDTH            => WB_DWIDTH
   )
   port map(
      wb_clk_i             => wb_clk_i,
      SPLB_Clk             => SPLB_Clk,
      plb2wb_rst           => plb2wb_rst,
      wb_dat_i             => wb_dat_i,
      RBF_rBus             => RBF_rBus,
      RBF_empty            => RBF_empty,
      RBF_almostEmpty      => RBF_almostEmpty,
      RBF_full             => RBF_full,  
      RBF_rdErrOut         => RBF_rdErrOut,
      RBF_rdErrIn          => RBF_rdErrIn,
      TCU_rbufWEn          => TCU_rbufWEn,
      TCU_rbufREn          => TCU_rbufREn
   );
   --
   -------------------------------------------






end IMP;

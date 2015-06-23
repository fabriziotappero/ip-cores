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


entity top is

   generic
   (
      SYNCHRONY                      : boolean              := false;       --  true = synchron, false = asynchron!

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
      C_SPLB_SUPPORT_BUR_LINE        : integer              := 1;
      C_SPLB_SUPPORT_ADR_PIPE        : integer              := 1;

      -- WB Parameters -----------------------------------
      WB_DAT_W                       : integer              := 32;
      WB_ADR_W                       : integer              := 32;
      WB_TIMEOUT_CYCLES              : integer              := 32;
      WB_ADR_OFFSET                  : std_logic_vector     := X"f0000000";
      WB_ADR_OFFSET_NEG              : std_logic            := '0';
      WB_PIC_INTS                    : integer              := 32;    
      WB_PIC_INT_LEVEL               : std_logic            := '1';
      WB_SUPPORT_BLOCK               : integer              := 1
   );


port(
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


end entity top;


architecture imp of top is



begin     

        bridge : entity plb2wb_bridge_v1_00_a.plb2wb_bridge(IMP) 
           generic map
           (
              SYNCHRONY                => SYNCHRONY              ,
                                                                 
              C_BASEADDR               => C_BASEADDR             ,
              C_HIGHADDR               => C_HIGHADDR             ,
              C_STATUS_BASEADDR        => C_STATUS_BASEADDR      ,
              C_STATUS_HIGHADDR        => C_STATUS_HIGHADDR      ,
              C_SPLB_AWIDTH            => C_SPLB_AWIDTH          ,
              C_SPLB_DWIDTH            => C_SPLB_DWIDTH          ,
              C_SPLB_NUM_MASTERS       => C_SPLB_NUM_MASTERS     ,
              C_SPLB_MID_WIDTH         => C_SPLB_MID_WIDTH       ,
              C_SPLB_NATIVE_DWIDTH     => C_SPLB_NATIVE_DWIDTH   ,
              C_SPLB_SUPPORT_BUR_LINE  => C_SPLB_SUPPORT_BUR_LINE  ,
              C_SPLB_SUPPORT_ADR_PIPE  => C_SPLB_SUPPORT_ADR_PIPE,
                                                                 
              WB_DAT_W                 => WB_DAT_W               ,
              WB_ADR_W                 => WB_ADR_W               ,
              WB_TIMEOUT_CYCLES        => WB_TIMEOUT_CYCLES      ,
              WB_ADR_OFFSET            => WB_ADR_OFFSET          ,
              WB_ADR_OFFSET_NEG        => WB_ADR_OFFSET_NEG      ,
              WB_PIC_INTS              => WB_PIC_INTS            ,
              WB_PIC_INT_LEVEL         => WB_PIC_INT_LEVEL       ,
              WB_SUPPORT_BLOCK         => WB_SUPPORT_BLOCK       
           )
           port map
           (

              PLB2WB_IRQ               =>    PLB2WB_IRQ     ,
                                                            
              wb_clk_i                 =>    wb_clk_i       ,
              wb_rst_i                 =>    wb_rst_i       ,
              wb_dat_i                 =>    wb_dat_i       ,
              wb_dat_o                 =>    wb_dat_o       ,
              wb_adr_o                 =>    wb_adr_o       ,
              wb_sel_o                 =>    wb_sel_o       ,
              wb_we_o                  =>    wb_we_o        ,
              wb_cyc_o                 =>    wb_cyc_o       ,
              wb_stb_o                 =>    wb_stb_o       ,
              wb_ack_i                 =>    wb_ack_i       ,
              wb_err_i                 =>    wb_err_i       ,
              wb_rty_i                 =>    wb_rty_i       ,
              wb_lock_o                =>    wb_lock_o      ,
                                                            
              wb_pic_int_i             =>    wb_pic_int_i   ,
                                             
              SPLB_Clk                 =>    SPLB_Clk       ,
              SPLB_Rst                 =>    SPLB_Rst       ,
              PLB_ABus                 =>    PLB_ABus       ,
              PLB_UABus                =>    PLB_UABus      ,
              PLB_PAValid              =>    PLB_PAValid    ,
              PLB_SAValid              =>    PLB_SAValid    ,
              PLB_rdPrim               =>    PLB_rdPrim     ,
              PLB_wrPrim               =>    PLB_wrPrim     ,
              PLB_masterID             =>    PLB_masterID   ,
              PLB_abort                =>    PLB_abort      ,
              PLB_busLock              =>    PLB_busLock    ,
              PLB_RNW                  =>    PLB_RNW        ,
              PLB_BE                   =>    PLB_BE         ,
              PLB_MSize                =>    PLB_MSize      ,
              PLB_size                 =>    PLB_size       ,
              PLB_type                 =>    PLB_type       ,
              PLB_lockErr              =>    PLB_lockErr    ,
              PLB_wrDBus               =>    PLB_wrDBus     ,
              PLB_wrBurst              =>    PLB_wrBurst    ,
              PLB_rdBurst              =>    PLB_rdBurst    ,
              PLB_wrPendReq            =>    PLB_wrPendReq  ,
              PLB_rdPendReq            =>    PLB_rdPendReq  ,
              PLB_wrPendPri            =>    PLB_wrPendPri  ,
              PLB_rdPendPri            =>    PLB_rdPendPri  ,
              PLB_reqPri               =>    PLB_reqPri     ,
              PLB_TAttribute           =>    PLB_TAttribute ,
              Sl_addrAck               =>    Sl_addrAck     ,
              Sl_SSize                 =>    Sl_SSize       ,
              Sl_wait                  =>    Sl_wait        ,
              Sl_rearbitrate           =>    Sl_rearbitrate ,
              Sl_wrDAck                =>    Sl_wrDAck      ,
              Sl_wrComp                =>    Sl_wrComp      ,
              Sl_wrBTerm               =>    Sl_wrBTerm     ,
              Sl_rdDBus                =>    Sl_rdDBus      ,
              Sl_rdWdAddr              =>    Sl_rdWdAddr    ,
              Sl_rdDAck                =>    Sl_rdDAck      ,
              Sl_rdComp                =>    Sl_rdComp      ,
              Sl_rdBTerm               =>    Sl_rdBTerm     ,
              Sl_MBusy                 =>    Sl_MBusy       ,
              Sl_MWrErr                =>    Sl_MWrErr      ,
              Sl_MRdErr                =>    Sl_MRdErr      ,
              Sl_MIRQ                  =>    Sl_MIRQ        
           );
           








end architecture imp;





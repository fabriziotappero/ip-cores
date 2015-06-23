-- $Id: pdp11_sys70.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_sys70 - syn
-- Description:    pdp11: 11/70 system - single core +rbus,debug,cache
--
-- Dependencies:   w11a/pdp11_core_rbus
--                 w11a/pdp11_core
--                 w11a/pdp11_cache
--                 w11a/pdp11_mem70
--                 ibus/ibd_ibmon
--                 ibus/ib_sres_or_3
--                 w11a/pdp11_tmu_sb           [sim only]
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-09   677   1.1    start/stop/suspend overhaul; reset overhaul
-- 2015-05-01   672   1.0    Initial version (extracted from sys_w11a_*)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.pdp11.all;
use work.iblib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity pdp11_sys70 is                   -- 11/70 system 1 core +rbus,debug,cache
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus request  (slave)
    RB_SRES : out rb_sres_type;         -- rbus response
    RB_STAT : out slv4;                 -- rbus status flags
    RB_LAM_CPU : out slbit;             -- rbus lam (cpu)
    GRESET : out slbit;                 -- general reset (from rbus)
    CRESET : out slbit;                 -- cpu reset     (from cp)
    BRESET : out slbit;                 -- bus reset     (from cp or cpu)
    CP_STAT : out cp_stat_type;         -- console port status
    EI_PRI  : in slv3;                  -- external interrupt priority
    EI_VECT : in slv9_2;                -- external interrupt vector
    EI_ACKM : out slbit;                -- external interrupt acknowledge
    ITIMER : out slbit;                 -- instruction timer
    IB_MREQ : out ib_mreq_type;         -- ibus request  (master)
    IB_SRES : in ib_sres_type;          -- ibus response
    MEM_REQ : out slbit;                -- memory: request
    MEM_WE : out slbit;                 -- memory: write enable
    MEM_BUSY : in slbit;                -- memory: controller busy
    MEM_ACK_R : in slbit;               -- memory: acknowledge read
    MEM_ADDR : out slv20;               -- memory: address
    MEM_BE : out slv4;                  -- memory: byte enable
    MEM_DI : out slv32;                 -- memory: data in  (memory view)
    MEM_DO : in slv32;                  -- memory: data out (memory view)
    DM_STAT_DP : out dm_stat_dp_type    -- debug and monitor status - dpath
  );
end pdp11_sys70;

architecture syn of pdp11_sys70 is
  
  signal RB_SRES_CPU   : rb_sres_type := rb_sres_init;

  signal CP_CNTL : cp_cntl_type := cp_cntl_init;
  signal CP_ADDR : cp_addr_type := cp_addr_init;
  signal CP_DIN  : slv16 := (others=>'0');
  signal CP_STAT_L : cp_stat_type := cp_stat_init;
  signal CP_DOUT : slv16 := (others=>'0');

  signal EM_MREQ : em_mreq_type := em_mreq_init;
  signal EM_SRES : em_sres_type := em_sres_init;
  
  signal GRESET_L : slbit := '0';
  signal CRESET_L : slbit := '0';
  signal BRESET_L : slbit := '0';

  signal HM_ENA      : slbit := '0';
  signal MEM70_FMISS : slbit := '0';
  signal CACHE_FMISS : slbit := '0';
  signal CACHE_CHIT  : slbit := '0';

  signal DM_STAT_DP_L : dm_stat_dp_type := dm_stat_dp_init;
  signal DM_STAT_VM   : dm_stat_vm_type := dm_stat_vm_init;
  signal DM_STAT_CO   : dm_stat_co_type := dm_stat_co_init;
  signal DM_STAT_SY   : dm_stat_sy_type := dm_stat_sy_init;

  signal IB_MREQ_M : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_M : ib_sres_type := ib_sres_init;
  signal IB_SRES_MEM70 : ib_sres_type := ib_sres_init;
  signal IB_SRES_IBMON : ib_sres_type := ib_sres_init;

  constant rbaddr_ibus0 : slv16 := x"4000"; -- 4000/1000: 0100 xxxx xxxx xxxx
  constant rbaddr_core0 : slv16 := x"0000"; -- 0000/0020: 0000 0000 000x xxxx

begin

  RB2CP : pdp11_core_rbus
    generic map (
      RB_ADDR_CORE => rbaddr_core0,
      RB_ADDR_IBUS => rbaddr_ibus0)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_CPU,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM_CPU,
      GRESET    => GRESET_L,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT_L,
      CP_DOUT   => CP_DOUT      
    );

  W11A : pdp11_core
    port map (
      CLK       => CLK,
      RESET     => GRESET_L,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT_L,
      CP_DOUT   => CP_DOUT,
      ESUSP_O   => open,
      ESUSP_I   => '0',
      ITIMER    => ITIMER,
      EBREAK    => '0',
      DBREAK    => '0',
      EI_PRI    => EI_PRI,
      EI_VECT   => EI_VECT,
      EI_ACKM   => EI_ACKM,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      CRESET    => CRESET_L,
      BRESET    => BRESET_L,
      IB_MREQ_M => IB_MREQ_M,
      IB_SRES_M => IB_SRES_M,
      DM_STAT_DP => DM_STAT_DP_L,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO
    );  

  CACHE: pdp11_cache
    port map (
      CLK       => CLK,
      GRESET    => GRESET_L,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      FMISS     => CACHE_FMISS,
      CHIT      => CACHE_CHIT,
      MEM_REQ   => MEM_REQ,
      MEM_WE    => MEM_WE,
      MEM_BUSY  => MEM_BUSY,
      MEM_ACK_R => MEM_ACK_R,
      MEM_ADDR  => MEM_ADDR,
      MEM_BE    => MEM_BE,
      MEM_DI    => MEM_DI,
      MEM_DO    => MEM_DO
    );

  MEM70: pdp11_mem70
    port map (
      CLK         => CLK,
      CRESET      => BRESET_L,
      HM_ENA      => HM_ENA,
      HM_VAL      => CACHE_CHIT,
      CACHE_FMISS => MEM70_FMISS,
      IB_MREQ     => IB_MREQ_M,
      IB_SRES     => IB_SRES_MEM70
    );

  HM_ENA      <= EM_SRES.ack_r or EM_SRES.ack_w;
  CACHE_FMISS <= MEM70_FMISS or sys_conf_cache_fmiss;
  
  IBMON : if sys_conf_ibmon_awidth > 0 generate
  begin
    I0 : ibd_ibmon
      generic map (
        IB_ADDR => slv(to_unsigned(8#160000#,16)),
        AWIDTH  => sys_conf_ibmon_awidth)
      port map (
        CLK         => CLK,
        RESET       => RESET,
        IB_MREQ     => IB_MREQ_M,
        IB_SRES     => IB_SRES_IBMON,
        IB_SRES_SUM => DM_STAT_VM.ibsres
      );
  end generate IBMON;

  IB_SRES_OR : ib_sres_or_3
    port map (
      IB_SRES_1  => IB_SRES_MEM70,
      IB_SRES_2  => IB_SRES,
      IB_SRES_3  => IB_SRES_IBMON,
      IB_SRES_OR => IB_SRES_M
    );

  RB_SRES    <= RB_SRES_CPU;        -- currently single rbus device
  IB_MREQ    <= IB_MREQ_M;          -- setup output signals
  GRESET     <= GRESET_L;
  CRESET     <= CRESET_L;
  BRESET     <= BRESET_L;
  CP_STAT    <= CP_STAT_L;
  DM_STAT_DP <= DM_STAT_DP_L;
  
-- synthesis translate_off
  DM_STAT_SY.emmreq <= EM_MREQ;
  DM_STAT_SY.emsres <= EM_SRES;
  DM_STAT_SY.chit   <= CACHE_CHIT;
  
  TMU : pdp11_tmu_sb
    generic map (
      ENAPIN => 13)
    port map (
      CLK        => CLK,
      DM_STAT_DP => DM_STAT_DP_L,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_SY => DM_STAT_SY
    );
-- synthesis translate_on
  
end syn;

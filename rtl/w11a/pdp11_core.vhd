-- $Id: pdp11_core.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2006-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_core - syn
-- Description:    pdp11: full processor core
--
-- Dependencies:   pdp11_vmbox
--                 pdp11_dpath
--                 pdp11_decode
--                 pdp11_sequencer
--                 pdp11_irq
--                 pdp11_reg70
--                 ibus/ib_sres_or_4
--
-- Test bench:     tb/tb_pdp11core
--                 tb/tb_rlink_tba_pdp11core
--
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-09   679   1.4    start/stop/suspend overhaul; reset overhaul
-- 2015-04-30   670   1.3.2  rename pdp11_sys70 -> pdp11_reg70
-- 2011-11-18   427   1.3.1  now numeric_std clean
-- 2010-06-13   305   1.3    add CP_ADDR in port; drop R_CPDIN, R_CPOUT; _vmbox
--                           CP_ADDR now from in port; dpath CP_DIN now from in
--                           port; out port CP_DOUT now from _dpath
-- 2009-05-30   220   1.2.5  final removal of snoopers (were already commented)
-- 2008-08-22   161   1.2.4  rename pdp11_ibres_ -> ib_sres_
-- 2008-04-25   138   1.2.3  BRESET: add for _vmbox, use for _irq
-- 2008-04-19   137   1.2.2  add DM_STAT_(DP|VM|CO) port; added pdp11_sys70
-- 2008-03-02   121   1.2.1  remove snoopers
-- 2008-02-17   117   1.2    add em_(mreq|sres) interface for memory
-- 2008-01-20   112   1.1.3  add BRESET port (intbus reset), rename P->BRESET
-- 2008-01-06   111   1.1.2  rename signal EI_ACK->EI_ACKM (master ack)
-- 2008-01-01   109   1.1.1  _vmbox w/ IB_SRES_(CPU|EXT)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now; remove DMA port
-- 2007-07-15    66   1.0.3  rename pdp11_top -> pdp11_core
-- 2007-07-02    63   1.0.2  reordered ports on pdp11_top (by function, not i/o)
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_core is                    -- full processor core
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CP_CNTL : in cp_cntl_type;          -- console control port
    CP_ADDR : in cp_addr_type;          -- console address port
    CP_DIN : in slv16;                  -- console data in
    CP_STAT : out cp_stat_type;         -- console status port
    CP_DOUT : out slv16;                -- console data out
    ESUSP_O : out slbit;                -- external suspend output
    ESUSP_I : in slbit;                 -- external suspend input
    ITIMER : out slbit;                 -- instruction timer
    EBREAK : in slbit;                  -- execution break
    DBREAK : in slbit;                  -- data break
    EI_PRI : in slv3;                   -- external interrupt priority
    EI_VECT : in slv9_2;                -- external interrupt vector
    EI_ACKM : out slbit;                -- external interrupt acknowledge
    EM_MREQ : out em_mreq_type;         -- external memory: request
    EM_SRES : in em_sres_type;          -- external memory: response
    CRESET : out slbit;                 -- cpu reset
    BRESET : out slbit;                 -- bus reset
    IB_MREQ_M : out ib_mreq_type;       -- ibus master request (master)
    IB_SRES_M : in ib_sres_type;        -- ibus slave response (master)
    DM_STAT_DP : out dm_stat_dp_type;   -- debug and monitor status - dpath
    DM_STAT_VM : out dm_stat_vm_type;   -- debug and monitor status - vmbox
    DM_STAT_CO : out dm_stat_co_type    -- debug and monitor status - core
  );
end pdp11_core;

architecture syn of pdp11_core is

  signal GRESET : slbit := '0';
  signal CRESET_L : slbit := '0';
  signal BRESET_L : slbit := '0';
  signal VM_CNTL : vm_cntl_type := vm_cntl_init;
  signal VM_STAT : vm_stat_type := vm_stat_init;
  signal MMU_MONI : mmu_moni_type := mmu_moni_init;
  signal DP_CNTL : dpath_cntl_type := dpath_cntl_init;
  signal DP_STAT : dpath_stat_type := dpath_stat_init;
  signal DP_PSW : psw_type := psw_init;
  signal DP_PC : slv16 := (others=>'0');
  signal DP_IREG : slv16 := (others=>'0');
  signal VM_DIN : slv16 := (others=>'0');
  signal VM_ADDR : slv16 := (others=>'0'); 
  signal VM_DOUT : slv16 := (others=>'0');
  signal ID_STAT : decode_stat_type := decode_stat_init;
  signal INT_PRI : slv3 := (others=>'0'); 
  signal INT_VECT : slv9_2 := (others=>'0'); 
  signal CP_STAT_L : cp_stat_type := cp_stat_init;
  signal INT_ACK : slbit := '0';

  signal IB_SRES_DP : ib_sres_type := ib_sres_init;
  signal IB_SRES_SEQ : ib_sres_type := ib_sres_init;
  signal IB_SRES_IRQ : ib_sres_type := ib_sres_init;
  signal IB_SRES_SYS : ib_sres_type := ib_sres_init;

  signal IB_MREQ : ib_mreq_type := ib_mreq_init; -- ibus request  (local)
  signal IB_SRES : ib_sres_type := ib_sres_init; -- ibus response (local)

begin

  GRESET   <= RESET;
  
  VMBOX : pdp11_vmbox
    port map (
      CLK       => CLK,
      GRESET    => GRESET,
      CRESET    => CRESET_L,
      BRESET    => BRESET_L,
      CP_ADDR   => CP_ADDR,
      VM_CNTL   => VM_CNTL,
      VM_ADDR   => VM_ADDR,
      VM_DIN    => VM_DIN,
      VM_STAT   => VM_STAT,
      VM_DOUT   => VM_DOUT,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      MMU_MONI  => MMU_MONI,
      IB_MREQ_M => IB_MREQ,
      IB_SRES_CPU => IB_SRES,
      IB_SRES_EXT => IB_SRES_M,
      DM_STAT_VM  => DM_STAT_VM
    );
  
  DPATH : pdp11_dpath
    port map (
      CLK     => CLK,
      CRESET  => CRESET_L,
      CNTL    => DP_CNTL,
      STAT    => DP_STAT,
      CP_DIN  => CP_DIN,
      CP_DOUT => CP_DOUT,
      PSWOUT  => DP_PSW,
      PCOUT   => DP_PC,
      IREG    => DP_IREG,
      VM_ADDR => VM_ADDR,
      VM_DOUT => VM_DOUT,
      VM_DIN  => VM_DIN,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_DP,
      DM_STAT_DP => DM_STAT_DP
    );

  IDEC : pdp11_decode
    port map (
      IREG => DP_IREG,
      STAT => ID_STAT
    );

  SEQ : pdp11_sequencer
    port map (
      CLK       => CLK,
      GRESET    => GRESET,
      PSW       => DP_PSW,
      PC        => DP_PC,
      IREG      => DP_IREG,
      ID_STAT   => ID_STAT,
      DP_STAT   => DP_STAT,
      CP_CNTL   => CP_CNTL,
      VM_STAT   => VM_STAT,
      INT_PRI   => INT_PRI,
      INT_VECT  => INT_VECT,
      INT_ACK   => INT_ACK,
      CRESET    => CRESET_L,
      BRESET    => BRESET_L,
      MMU_MONI  => MMU_MONI,
      DP_CNTL   => DP_CNTL,
      VM_CNTL   => VM_CNTL,
      CP_STAT   => CP_STAT_L,
      ESUSP_O   => ESUSP_O,
      ESUSP_I   => ESUSP_I,
      ITIMER    => ITIMER,
      EBREAK    => EBREAK,
      DBREAK    => DBREAK,
      IB_MREQ   => IB_MREQ,
      IB_SRES   => IB_SRES_SEQ
    );

  IRQ : pdp11_irq
    port map (
      CLK     => CLK,
      BRESET  => BRESET_L,
      INT_ACK => INT_ACK,
      EI_PRI  => EI_PRI,
      EI_VECT => EI_VECT,
      EI_ACKM => EI_ACKM,
      PRI     => INT_PRI,
      VECT    => INT_VECT,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_IRQ
    );

  REG70 : pdp11_reg70
    port map (
      CLK     => CLK,
      CRESET  => CRESET_L,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_SYS
    );

  IB_SRES_OR : ib_sres_or_4
    port map (
      IB_SRES_1  => IB_SRES_DP,
      IB_SRES_2  => IB_SRES_SEQ,
      IB_SRES_3  => IB_SRES_IRQ,
      IB_SRES_4  => IB_SRES_SYS,
      IB_SRES_OR => IB_SRES
    );

  IB_MREQ_M <= IB_MREQ;
  
  CP_STAT <= CP_STAT_L;

  CRESET  <= CRESET_L;
  BRESET  <= BRESET_L;
  
  DM_STAT_CO.cpugo    <= CP_STAT_L.cpugo;
  DM_STAT_CO.cpususp  <= CP_STAT_L.cpususp;
  DM_STAT_CO.suspint  <= CP_STAT_L.suspint;
  DM_STAT_CO.suspext  <= CP_STAT_L.suspext;

end syn;


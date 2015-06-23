-- $Id: tbd_pdp11core.vhd 674 2015-05-04 16:17:40Z mueller $
--
-- Copyright 2007-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tbd_pdp11core - syn
-- Description:    Wrapper for pdp11_core to avoid records. It has a port
--                 interface which will not be modified by xst synthesis
--                 (no records, no generic port).
--
-- Dependencies:   genlib/clkdivce
--                 pdp11_core
--                 pdp11_bram
--                 ibus/ibdr_minisys
--                 pdp11_tmu_sb           [sim only]
--
-- To test:        pdp11_core
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-06-13   305  11.4   L68  xc3s1000-4   601 2504  206 1428 s 18.6
-- 2008-03-01   120  8.2.03 I34  xc3s1000-4   679 2562  206 1465 s 18.5
-- 2008-01-06   111  8.2.03 I34  xc3s1000-4   605 2324  164 1297 s 18.7
-- 2007-12-30   107  8.2.03 I34  xc3s1000-4   536 2119  119 1184 s 19.3
-- 2007-10-27    92  9.2.02 J39  xc3s1000-4  INTERNAL_ERROR -> blog_webpack
-- 2007-10-27    92  9.1    J30  xc3s1000-4   503 2021  119    - t 18.7
-- 2007-10-27    92  8.2.03 I34  xc3s1000-4   534 2091  119 1170 s 19.3
-- 2007-10-27    92  8.1.03 I27  xc3s1000-4   557 2186  119    - s 18.6 
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-03   674   1.6    start/stop/suspend overhaul
-- 2011-11-18   427   1.5.1  now numeric_std clean
-- 2010-12-30   351   1.5    rename tbd_pdp11_core -> tbd_pdp11core
-- 2010-10-23   335   1.4.2  rename RRI_LAM->RB_LAM;
-- 2010-06-20   307   1.4.1  add CP_ADDR_racc, CP_ADDR_be port
-- 2010-06-13   305   1.4    add CP_ADDR_... in ports; add CP_CNTL_rnum in port
-- 2010-06-11   303   1.3.9  use IB_MREQ.racc instead of RRI_REQ
-- 2009-07-12   233   1.3.8  adapt to ibdr_minisys interface changes
-- 2009-05-10   214   1.3.7  use pdp11_tmu_sb instead of pdp11_tmu
-- 2008-08-22   161   1.3.6  use iblib, ibdlib
-- 2008-05-03   143   1.3.5  rename _cpursta->_cpurust
-- 2008-04-27   140   1.3.4  use cpursta interface, remove cpufail
-- 2008-04-19   137   1.3.3  add DM_STAT_(DP|VM|CO|SY) signals, add pdp11_tmu
-- 2008-04-18   136   1.3.2  add RESET for ibdr_minisys
-- 2008-02-23   118   1.3.1  use sys_conf for bram size
-- 2008-02-17   117   1.3    adapt to em_ core interface; use pdp11_bram
-- 2008-01-20   112   1.2.1  rename clkgen->clkdivce; use ibdr_minisys, BRESET;
-- 2008-01-06   111   1.2    add some external devices: KW11L, DL11, RK11
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now; remove DMA port
-- 2007-09-23    85   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

entity tbd_pdp11core is               -- full core [no records]
  port (
    CLK : in slbit;                   -- clock
    RESET : in slbit;                 -- reset
    CP_CNTL_req : in slbit;           -- console control port
    CP_CNTL_func : in slv5;           -- console control port
    CP_CNTL_rnum : in slv3;           -- console control port
    CP_ADDR_addr : in slv22_1;        -- console address port
    CP_ADDR_racc : in slbit;          -- console address port
    CP_ADDR_be   : in slv2;           -- console address port
    CP_ADDR_ena_22bit : in slbit;     -- console address port
    CP_ADDR_ena_ubmap : in slbit;     -- console address port
    CP_DIN : in slv16;                -- console data in
    CP_STAT_cmdbusy : out slbit;      -- console status port
    CP_STAT_cmdack : out slbit;       -- console status port
    CP_STAT_cmderr : out slbit;       -- console status port
    CP_STAT_cmdmerr : out slbit;      -- console status port
    CP_STAT_cpugo : out slbit;        -- console status port
    CP_STAT_cpustep : out slbit;      -- console status port
    CP_STAT_cpuwait : out slbit;      -- console status port
    CP_STAT_cpususp : out slbit;      -- console status port
    CP_STAT_cpurust : out slv4;       -- console status port
    CP_STAT_suspint : out slbit;      -- console status port
    CP_STAT_suspext : out slbit;      -- console status port
    CP_DOUT : out slv16               -- console data out
  );
end tbd_pdp11core;


architecture syn of tbd_pdp11core is
  
  signal CE_USEC : slbit := '0';

  signal EI_PRI  : slv3 := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit := '0';

  signal CP_CNTL : cp_cntl_type := cp_cntl_init;
  signal CP_ADDR : cp_addr_type := cp_addr_init;
  signal CP_STAT : cp_stat_type := cp_stat_init;

  signal EM_MREQ : em_mreq_type := em_mreq_init;
  signal EM_SRES : em_sres_type := em_sres_init;
  
  signal BRESET  : slbit := '0';
  signal IB_MREQ_M : ib_mreq_type := ib_mreq_init;
  signal IB_SRES_M : ib_sres_type := ib_sres_init;

  signal DM_STAT_DP : dm_stat_dp_type := dm_stat_dp_init;
  signal DM_STAT_VM : dm_stat_vm_type := dm_stat_vm_init;
  signal DM_STAT_CO : dm_stat_co_type := dm_stat_co_init;
  signal DM_STAT_SY : dm_stat_sy_type := dm_stat_sy_init;

begin

  CP_CNTL.req  <= CP_CNTL_req;
  CP_CNTL.func <= CP_CNTL_func;
  CP_CNTL.rnum <= CP_CNTL_rnum;

  CP_ADDR.addr      <= CP_ADDR_addr;
  CP_ADDR.racc      <= CP_ADDR_racc;
  CP_ADDR.be        <= CP_ADDR_be;
  CP_ADDR.ena_22bit <= CP_ADDR_ena_22bit;
  CP_ADDR.ena_ubmap <= CP_ADDR_ena_ubmap;

  CP_STAT_cmdbusy <= CP_STAT.cmdbusy;
  CP_STAT_cmdack  <= CP_STAT.cmdack;
  CP_STAT_cmderr  <= CP_STAT.cmderr;
  CP_STAT_cmdmerr <= CP_STAT.cmdmerr;
  CP_STAT_cpugo   <= CP_STAT.cpugo;
  CP_STAT_cpustep <= CP_STAT.cpustep;
  CP_STAT_cpuwait <= CP_STAT.cpuwait;
  CP_STAT_cpususp <= CP_STAT.cpususp;
  CP_STAT_cpurust <= CP_STAT.cpurust;
  CP_STAT_suspint <= CP_STAT.suspint;
  CP_STAT_suspext <= CP_STAT.suspext;

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV => 50,
      MSECDIV => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => open
    );

  PDP11 : pdp11_core
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CP_CNTL => CP_CNTL,
      CP_ADDR => CP_ADDR,
      CP_DIN  => CP_DIN,
      CP_STAT => CP_STAT,
      CP_DOUT => CP_DOUT,
      ESUSP_O => open,                  -- not tested
      ESUSP_I => '0',                   -- dito
      ITIMER  => open,                  -- dito
      EBREAK  => '0',                   -- dito
      DBREAK  => '0',                   -- dito
      EI_PRI  => EI_PRI,
      EI_VECT => EI_VECT,
      EI_ACKM => EI_ACKM,
      EM_MREQ => EM_MREQ,
      EM_SRES => EM_SRES,
      BRESET  => BRESET,
      IB_MREQ_M  => IB_MREQ_M,
      IB_SRES_M  => IB_SRES_M,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO
    );
  
  MEM : pdp11_bram
    generic map (
      AWIDTH => sys_conf_bram_awidth)
    port map (
      CLK     => CLK,
      GRESET  => RESET,
      EM_MREQ => EM_MREQ,
      EM_SRES => EM_SRES
    );
  
  IBDR_SYS : ibdr_minisys
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_USEC,              -- !! in test benches msec = usec !!
      RESET    => RESET,
      BRESET   => BRESET,
      RB_LAM   => open,
      IB_MREQ  => IB_MREQ_M,
      IB_SRES  => IB_SRES_M,
      EI_ACKM  => EI_ACKM,
      EI_PRI   => EI_PRI,
      EI_VECT  => EI_VECT,
      DISPREG  => open
    );  

-- synthesis translate_off

  DM_STAT_SY.emmreq <= EM_MREQ;
  DM_STAT_SY.emsres <= EM_SRES;
  DM_STAT_SY.chit   <= '0';
  
  TMU : pdp11_tmu_sb
    generic map (
      ENAPIN => 13)
     port map (
      CLK        => CLK,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_SY => DM_STAT_SY
    );
  
-- synthesis translate_on
  
end syn;

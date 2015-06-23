-- $Id: pdp11.vhd 677 2015-05-09 21:52:32Z mueller $
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
-- Package Name:   pdp11
-- Description:    Definitions for pdp11 components
--
-- Dependencies:   -
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-09   677   1.6    start/stop/suspend overhaul; reset overhaul
-- 2015-05-01   672   1.5.5  add pdp11_sys70, sys_hio70
-- 2015-04-30   670   1.5.4  rename pdp11_sys70 -> pdp11_reg70
-- 2015-02-20   649   1.5.3  add pdp11_statleds
-- 2015-02-08   644   1.5.2  add pdp11_bram_memctl
-- 2014-08-28   588   1.5.1  use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   1.5    rb_mreq addr now 16 bit
-- 2014-08-10:  581   1.4.10 add c_cc_f_* field defs for condition code array
-- 2014-07-12   569   1.4.9  dpath_stat_type: merge div_zero+div_ovfl to div_quit
--                           dpath_cntl_type: add munit_s_div_sr
-- 2011-11-18   427   1.4.8  now numeric_std clean
-- 2010-12-30   351   1.4.7  rename pdp11_core_rri->pdp11_core_rbus; use rblib
-- 2010-10-23   335   1.4.6  rename RRI_LAM->RB_LAM;
-- 2010-10-16   332   1.4.5  renames of pdp11_du_drv port names
-- 2010-09-18   330   1.4.4  rename (adlm)box->(oalm)unit
-- 2010-06-20   308   1.4.3  add c_ibrb_ibf_ def's
-- 2010-06-20   307   1.4.2  rename cpacc to cacc in vm_cntl_type, mmu_cntl_type
-- 2010-06-18   306   1.4.1  add racc, be to cp_addr_type; rm pdp11_ibdr_rri
-- 2010-06-13   305   1.4    add rnum to cp_cntl_type, cprnum to cpustat_type;
--                           reassign cp command codes and rename: c_cp_func_...
--                           -> c_cpfunc_...; remove  cpaddr_(lal|lah|inc) from
--                           dpath_cntl_type; add cpdout_we to dpath_cntl_type;
--                           reassign rbus adresses and rename: c_rb_addr_...
--                           -> c_rbaddr_...; rename rbus fields: c_rb_statf_...
--                           -> c_stat_rbf_...
-- 2010-06-12   304   1.3.3  add cpuwait to cp_stat_type and cpustat_type
-- 2010-06-11   303   1.3.2  use IB_MREQ.racc instead of RRI_REQ
-- 2010-05-02   287   1.3.1  rename RP_STAT->RB_STAT
-- 2010-05-01   285   1.3    port to rri V2 interface; drop pdp11_rri_2rp;
--                           rename c_rp_addr_* -> c_rb_addr_*
-- 2010-03-21   270   1.2.6  add pdp11_du_drv
-- 2009-05-30   220   1.2.5  final removal of snoopers (were already commented)
-- 2009-05-10   214   1.2.4  add ENA (trace enable) for _tmu; add _pdp11_tmu_sb
-- 2009-05-09   213   1.2.3  BUGFIX: default for inst_compl now '0'
-- 2008-12-14   177   1.2.2  add gpr_* fields to DM_STAT_DP
-- 2008-11-30   174   1.2.1  BUGFIX: add updt_dstadsrc;
-- 2008-08-22   161   1.2    move slvnn_m subtypes to slvtypes;
--                           move (and rename) intbus defs to iblib package;
--                           move intbus devices to ibdlib package;
--                           rename ubf_ --> ibf_;
-- 2008-05-09   144   1.1.17 use EI_ACK with _kw11l, _dl11
-- 2008-05-03   143   1.1.16 rename _cpursta->_cpurust
-- 2008-04-27   140   1.1.15 add c_cpursta_xxx defs; cpufail->cpursta in cp_stat
-- 2008-04-25   138   1.1.14 add BRESET port to _mmu, _vmbox, use in _irq
-- 2008-04-19   137   1.1.13 add _tmu,_sys70 entity, dm_stat_** types and ports
-- 2008-04-18   136   1.1.12 ibdr_sdreg: use RESET; ibdr_minisys: add RESET
-- 2008-03-02   121   1.1.11 remove snoopers; add waitsusp in cpustat_type
-- 2008-02-24   119   1.1.10 add lah,rps,wps commands, cp_addr_type.
--                           _vmbox,_mmu interface changed
-- 2008-02-17   117   1.1.9  add em_(mreq|sres)_type, pdp11_cache, pdp11_bram
-- 2008-01-27   115   1.1.8  add pdp11_ubmap, pdp11_mem70
-- 2008-01-26   114   1.1.7  add c_rp_addr_ibr(b) defs (for ibr addresses)
-- 2008-01-20   113   1.1.6  _core_rri: use RRI_LAM; _minisys: RRI_LAM vector
-- 2008-01-20   112   1.1.5  added ibdr_minisys; _ibdr_rri
-- 2008-01-06   111   1.1.4  rename ibdr_kw11l->ibd_kw11l; add ibdr_(dl11|rk11)
--                           mod pdp11_intmap;
-- 2008-01-05   110   1.1.3  delete _mmu_regfile; rename _mmu_regs->_mmu_sadr
--                           rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
--                           add ibdr_kw11l.
-- 2008-01-01   109   1.1.2  _vmbox w/ IB_SRES_(CPU|EXT); remove vm_regs_type
-- 2007-12-30   108   1.1.1  add ibdr_sdreg, ubf_byte[01]
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now; remove DMA port
-- 2007-08-16    74   1.0.6  add AP_LAM interface to pdp11_core_rri
-- 2007-08-12    73   1.0.5  add c_rp_addr_xxx and c_rp_statf_xxx def's
-- 2007-08-10    72   1.0.4  added c_cp_func_xxx constant def's for commands
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
use work.rblib.all;

package pdp11 is

  type psw_type is record               -- processor status
    cmode : slv2;                       -- current mode
    pmode : slv2;                       -- previous mode
    rset : slbit;                       -- register set
    pri : slv3;                         -- processor priority
    tflag : slbit;                      -- trace flag
    cc : slv4;                          -- condition codes (NZVC).
  end record psw_type;

  constant c_cc_f_n: integer := 3;      -- condition code: n
  constant c_cc_f_z: integer := 2;      -- condition code: z
  constant c_cc_f_v: integer := 1;      -- condition code: v
  constant c_cc_f_c: integer := 0;      -- condition code: c

  constant psw_init : psw_type := (
    "00","00",                          -- cmode, pmode  (=kernel)
    '0',"111",'0',                      -- rset, pri (=7), tflag
    "0000"                              -- cc     NZVC=0
  );

  constant c_psw_kmode : slv2 := "00";  -- processor mode: kernel
  constant c_psw_smode : slv2 := "01";  -- processor mode: supervisor
  constant c_psw_umode : slv2 := "11";  -- processor mode: user

  subtype  psw_ibf_cmode  is integer range 15 downto 14;
  subtype  psw_ibf_pmode  is integer range 13 downto 12;
  constant psw_ibf_rset:  integer := 11;
  subtype  psw_ibf_pri    is integer range  7 downto  5;
  constant psw_ibf_tflag: integer :=  4;
  subtype  psw_ibf_cc     is integer range  3 downto  0;  

  type sarsdr_type is record            -- combined SAR/SDR MMU status
    saf : slv16;                        -- segment address field
    slf : slv7;                         -- segment length field
    ed : slbit;                         -- expansion direction
    acf : slv3;                         -- access control field
  end record sarsdr_type;

  constant sarsdr_init : sarsdr_type := (
    (others=>'0'),                      -- saf
    "0000000",'0',"000"                 -- slf, ed, acf
  );

  type dpath_cntl_type is record        -- data path control
    gpr_asrc : slv3;                    -- src register address
    gpr_adst : slv3;                    -- dst register address
    gpr_mode : slv2;                    -- psw mode for gpr access
    gpr_rset : slbit;                   -- register set
    gpr_we : slbit;                     -- gpr write enable
    gpr_bytop : slbit;                  -- gpr high byte enable
    gpr_pcinc : slbit;                  -- pc increment enable
    psr_ccwe : slbit;                   -- enable update cc
    psr_we: slbit;                      -- write enable psw (from DIN)
    psr_func : slv3;                    -- write function psw (from DIN)
    dsrc_sel : slbit;                   -- src data register source select
    dsrc_we : slbit;                    -- src data register write enable
    ddst_sel : slbit;                   -- dst data register source select
    ddst_we : slbit;                    -- dst data register write enable
    dtmp_sel : slv2;                    -- tmp data register source select
    dtmp_we : slbit;                    -- tmp data register write enable
    ounit_asel : slv2;                  -- ounit a port selector
    ounit_azero : slbit;                -- ounit a port force zero
    ounit_const : slv9;                 -- ounit b port const
    ounit_bsel : slv2;                  -- ounit b port selector
    ounit_opsub : slbit;                -- ounit operation
    aunit_srcmod : slv2;                -- aunit src port modifier
    aunit_dstmod : slv2;                -- aunit dst port modifier
    aunit_cimod : slv2;                 -- aunit ci port modifier
    aunit_cc1op : slbit;                -- aunit use cc modes (1 op instruction)
    aunit_ccmode : slv3;                -- aunit cc port mode
    aunit_bytop : slbit;                -- aunit byte operation
    lunit_func : slv4;                  -- lunit function
    lunit_bytop : slbit;                -- lunit byte operation
    munit_func : slv2;                  -- munit function
    munit_s_div : slbit;                -- munit s_opg_div state
    munit_s_div_cn : slbit;             -- munit s_opg_div_cn state
    munit_s_div_cr : slbit;             -- munit s_opg_div_cr state
    munit_s_div_sr : slbit;             -- munit s_opg_div_sr state
    munit_s_ash : slbit;                -- munit s_opg_ash state
    munit_s_ash_cn : slbit;             -- munit s_opg_ash_cn state
    munit_s_ashc : slbit;               -- munit s_opg_ashc state
    munit_s_ashc_cn : slbit;            -- munit s_opg_ashc_cn state
    ireg_we : slbit;                    -- ireg register write enable
    cres_sel : slv3;                    -- result bus (cres) select
    dres_sel : slv3;                    -- result bus (dres) select
    vmaddr_sel : slv2;                  -- virtual address select
    cpdout_we : slbit;                  -- capture dres for cpdout
  end record dpath_cntl_type;

  constant dpath_cntl_init : dpath_cntl_type := (
    "000","000","00",'0','0','0','0',   -- gpr
    '0','0',"000",                      -- psr
    '0','0','0','0',"00",'0',           -- dsrc,..,dtmp
    "00",'0',"000000000","00",'0',      -- ounit
    "00","00","00",'0',"000",'0',       -- aunit
    "0000",'0',                         -- lunit
    "00",'0','0','0','0','0','0','0','0',-- munit
    '0',"000","000","00",'0'            -- rest
  );
     
  constant c_dpath_dsrc_src  : slbit := '0'; -- DSRC = R(SRC)
  constant c_dpath_dsrc_res  : slbit := '1'; -- DSRC = DRES
  constant c_dpath_ddst_dst  : slbit := '0'; -- DDST = R(DST)
  constant c_dpath_ddst_res  : slbit := '1'; -- DDST = DRES

  constant c_dpath_dtmp_dsrc  : slv2 := "00"; -- DTMP = DSRC
  constant c_dpath_dtmp_psw   : slv2 := "01"; -- DTMP = PSW
  constant c_dpath_dtmp_dres  : slv2 := "10"; -- DTMP = DRES
  constant c_dpath_dtmp_drese : slv2 := "11"; -- DTMP = DRESE

  constant c_dpath_res_ounit  : slv3 := "000"; -- D/CRES = OUNIT
  constant c_dpath_res_aunit  : slv3 := "001"; -- D/CRES = AUNIT
  constant c_dpath_res_lunit  : slv3 := "010"; -- D/CRES = LUNIT
  constant c_dpath_res_munit  : slv3 := "011"; -- D/CRES = MUNIT
  constant c_dpath_res_vmdout : slv3 := "100"; -- D/CRES = VMDOUT
  constant c_dpath_res_fpdout : slv3 := "101"; -- D/CRES = FPDOUT
  constant c_dpath_res_ireg   : slv3 := "110"; -- D/CRES = IREG
  constant c_dpath_res_cpdin  : slv3 := "111"; -- D/CRES = CPDIN

  constant c_dpath_vmaddr_dsrc : slv2 := "00"; -- VMADDR = DSRC
  constant c_dpath_vmaddr_ddst : slv2 := "01"; -- VMADDR = DDST
  constant c_dpath_vmaddr_pc   : slv2 := "10"; -- VMADDR = PC
  constant c_dpath_vmaddr_dtmp : slv2 := "11"; -- VMADDR = DTMP

  type dpath_stat_type is record        -- data path status
    ccout_z : slbit;                    -- current effective Z cc flag
    shc_tc : slbit;                     -- last shc cycle (shc==0)
    div_cr : slbit;                     -- division: remainder correction needed
    div_cq : slbit;                     -- division: quotient correction needed
    div_quit : slbit;                   -- division: abort (0/ or /0 or V=1)
  end record dpath_stat_type;
  
  constant dpath_stat_init : dpath_stat_type := (others=>'0');

  type decode_stat_type is record       -- decode status
    is_dstmode0 : slbit;                -- dest. is register mode
    is_srcpc : slbit;                   -- source is pc
    is_srcpcmode1 : slbit;              -- source is pc and mode=1
    is_dstpc : slbit;                   -- dest. is pc
    is_dstw_reg : slbit;                -- dest. register to be written
    is_dstw_pc  : slbit;                -- pc register to be written
    is_rmwop : slbit;                   -- read-modify-write operation
    is_bytop : slbit;                   -- byte operation
    is_res : slbit;                     -- reserved operation code
    op_rtt : slbit;                     -- RTT instruction
    op_mov : slbit;                     -- MOV instruction
    trap_vec : slv3;                    -- trap vector addr bits 4:2
    force_srcsp : slbit;                -- force src register to be sp
    updt_dstadsrc : slbit;              -- update dsrc in dsta flow
    aunit_srcmod : slv2;                -- aunit src port modifier
    aunit_dstmod : slv2;                -- aunit dst port modifier
    aunit_cimod : slv2;                 -- aunit ci port modifier
    aunit_cc1op : slbit;                -- aunit use cc modes (1 op instruction)
    aunit_ccmode : slv3;                -- aunit cc port mode
    lunit_func : slv4;                  -- lunit function
    munit_func : slv2;                  -- munit function
    res_sel : slv3;                     -- result bus (cres/dres) select
    fork_op : slv4;                     -- op fork after idecode state
    fork_srcr : slv2;                   -- src-read fork after idecode state
    fork_dstr : slv2;                   -- dst-read fork after src read state
    fork_dsta : slv2;                   -- dst-addr fork after idecode state
    fork_opg : slv4;                    -- opg fork
    fork_opa : slv3;                    -- opa fork
    do_fork_op : slbit;                 -- execute fork_op
    do_fork_srcr : slbit;               -- execute fork_srcr
    do_fork_dstr : slbit;               -- execute fork_dstr
    do_fork_dsta : slbit;               -- execute fork_dsta
    do_fork_opg : slbit;                -- execute fork_opg
    do_pref_dec : slbit;                -- can do prefetch at decode phase
  end record decode_stat_type;
  
  constant decode_stat_init : decode_stat_type := (
    '0','0','0','0','0','0','0','0','0', -- is_
    '0','0',"000",'0','0',               -- op_, trap_, force_, updt_
    "00","00","00",'0',"000",            -- aunit_
    "0000","00","000",                   -- lunit_, munit_, res_
    "0000","00","00","00","0000","000",  -- fork_
    '0','0','0','0','0',                 -- do_fork_
    '0'                                  -- do_pref_
  );
    
  constant c_fork_op_halt : slv4 := "0000";
  constant c_fork_op_wait : slv4 := "0001";
  constant c_fork_op_rtti : slv4 := "0010";
  constant c_fork_op_trap : slv4 := "0011";
  constant c_fork_op_reset: slv4 := "0100";
  constant c_fork_op_rts :  slv4 := "0101";
  constant c_fork_op_spl :  slv4 := "0110";
  constant c_fork_op_mcc :  slv4 := "0111";
  constant c_fork_op_br :   slv4 := "1000";
  constant c_fork_op_mark : slv4 := "1001";
  constant c_fork_op_sob :  slv4 := "1010";
  constant c_fork_op_mtp :  slv4 := "1011";

  constant c_fork_srcr_def : slv2:= "00";
  constant c_fork_srcr_inc : slv2:= "01";
  constant c_fork_srcr_dec : slv2:= "10";
  constant c_fork_srcr_ind : slv2:= "11";

  constant c_fork_dstr_def : slv2:= "00";
  constant c_fork_dstr_inc : slv2:= "01";
  constant c_fork_dstr_dec : slv2:= "10";
  constant c_fork_dstr_ind : slv2:= "11";

  constant c_fork_dsta_def : slv2:= "00";
  constant c_fork_dsta_inc : slv2:= "01";
  constant c_fork_dsta_dec : slv2:= "10";
  constant c_fork_dsta_ind : slv2:= "11";

  constant c_fork_opg_gen  : slv4 := "0000";
  constant c_fork_opg_wdef : slv4 := "0001";
  constant c_fork_opg_winc : slv4 := "0010";
  constant c_fork_opg_wdec : slv4 := "0011";
  constant c_fork_opg_wind : slv4 := "0100";
  constant c_fork_opg_mul  : slv4 := "0101";
  constant c_fork_opg_div  : slv4 := "0110";
  constant c_fork_opg_ash  : slv4 := "0111";
  constant c_fork_opg_ashc : slv4 := "1000";

  constant c_fork_opa_jsr :     slv3 := "000";
  constant c_fork_opa_jmp :     slv3 := "001";
  constant c_fork_opa_mtp :     slv3 := "010";
  constant c_fork_opa_mfp_reg : slv3 := "011";
  constant c_fork_opa_mfp_mem : slv3 := "100";

  -- Note: MSB=0 are 'normal' states, MSB=1 are fatal errors
  constant c_cpurust_init   : slv4 := "0000";  -- cpu in init state
  constant c_cpurust_halt   : slv4 := "0001";  -- cpu executed HALT
  constant c_cpurust_reset  : slv4 := "0010";  -- cpu was reset    
  constant c_cpurust_stop   : slv4 := "0011";  -- cpu was stopped
  constant c_cpurust_step   : slv4 := "0100";  -- cpu was stepped
  constant c_cpurust_susp   : slv4 := "0101";  -- cpu was suspended
  constant c_cpurust_runs   : slv4 := "0111";  -- cpu running
  constant c_cpurust_vecfet : slv4 := "1000";  -- vector fetch error halt
  constant c_cpurust_recrsv : slv4 := "1001";  -- recursive red-stack halt
  constant c_cpurust_sfail  : slv4 := "1100";  -- sequencer failure
  constant c_cpurust_vfail  : slv4 := "1101";  -- vmbox failure

  type cpustat_type is record           -- CPU status
    cmdbusy : slbit;                    -- command busy
    cmdack  : slbit;                    -- command acknowledge
    cmderr  : slbit;                    -- command error
    cmdmerr : slbit;                    -- command memory access error
    cpugo   : slbit;                    -- CPU go state
    cpustep : slbit;                    -- CPU step flag
    cpususp : slbit;                    -- CPU susp flag
    cpuwait : slbit;                    -- CPU wait flag
    cpurust : slv4;                     -- CPU run status
    suspint : slbit;                    -- internal suspend flag
    suspext : slbit;                    -- external suspend flag
    cpfunc  : slv5;                     -- current control port function
    cprnum  : slv3;                     -- current control port register number
    waitsusp : slbit;                   -- WAIT instruction suspended
    itimer : slbit;                     -- ITIMER pulse
    creset : slbit;                     -- CRESET pulse
    breset : slbit;                     -- BRESET pulse
    intack : slbit;                     -- INT_ACK pulse
    intvect  : slv9_2;                  -- current interrupt vector
    trap_mmu : slbit;                   -- mmu trace trap pending
    trap_ysv : slbit;                   -- ysv trap pending
    prefdone : slbit;                   -- prefetch done
    do_gprwe : slbit;                   -- pending gpr_we
    do_intrsv : slbit;                  -- active rsv interrupt sequence
  end record cpustat_type;

  constant cpustat_init : cpustat_type := (
    '0','0','0','0',                    -- cmdbusy,cmdack,cmderr,cmdmerr
    '0','0','0','0',                    -- cpugo,cpustep,cpususp,cpuwait
    c_cpurust_init,                     -- cpurust
    '0','0',                            -- suspint,suspext
    "00000","000",                      -- cpfunc, cprnum
    '0',                                -- waitsusp
    '0','0','0','0',                    -- itimer,creset,breset,intack
    (others=>'0'),                      -- intvect 
    '0','0','0',                        -- trap_(mmu|ysv), prefdone
    '0','0'                             -- do_gprwe, do_intrsv
  );

  type cpuerr_type is record            -- CPU error register
    illhlt : slbit;                     -- illegal halt (in non-kernel mode)
    adderr : slbit;                     -- address error (odd, jmp/jsr reg)
    nxm : slbit;                        -- non-existent memory
    iobto : slbit;                      -- I/O bus timeout (non-exist UB)
    ysv : slbit;                        -- yellow stack violation
    rsv : slbit;                        -- red stack violation
  end record cpuerr_type;

  constant cpuerr_init : cpuerr_type := (others=>'0');

  type vm_cntl_type is record           -- virt memory control port
    req : slbit;                        -- request
    wacc : slbit;                       -- write access
    macc : slbit;                       -- modify access (r-m-w sequence)
    cacc : slbit;                       -- console access
    bytop : slbit;                      -- byte operation
    dspace : slbit;                     -- dspace operation
    kstack : slbit;                     -- access through kernel stack
    intrsv : slbit;                     -- active rsv interrupt sequence
    mode : slv2;                        -- mode
    trap_done : slbit;                  -- mmu trap taken (to set ssr0 bit)
  end record vm_cntl_type;

  constant vm_cntl_init : vm_cntl_type := (
    '0','0','0','0',                    -- req, wacc, macc,cacc
    '0','0','0',                        -- bytop, dspace, kstack
    '0',"00",'0'                        -- intrsv, mode, trap_done
  );

  type vm_stat_type is record           -- virt memory status port
    ack : slbit;                        -- acknowledge
    err : slbit;                        -- error (see err_xxx for reason)
    fail : slbit;                       -- failure (machine check)
    err_odd : slbit;                    -- abort: odd address error
    err_mmu : slbit;                    -- abort: mmu reject
    err_nxm : slbit;                    -- abort: non-existing memory
    err_iobto : slbit;                  -- abort: non-existing I/O resource
    err_rsv : slbit;                    -- abort: red stack violation
    trap_ysv : slbit;                   -- trap: yellow stack violation
    trap_mmu : slbit;                   -- trap: mmu trace trap
  end record vm_stat_type;

  constant vm_stat_init : vm_stat_type := (others=>'0');

  type em_mreq_type is record           -- external memory - master request
    req : slbit;                        -- request
    we : slbit;                         -- write enable
    be : slv2;                          -- byte enables
    cancel : slbit;                     -- cancel request
    addr : slv22_1;                     -- address
    din : slv16;                        -- data in (input to memory)
  end record em_mreq_type;

  constant em_mreq_init : em_mreq_type := (
    '0','0',"00",'0',                   -- req, we, be, cancel
    (others=>'0'),(others=>'0')         -- addr, din
  );

  type em_sres_type is record           -- external memory - slave response
    ack_r  : slbit;                     -- acknowledge read
    ack_w  : slbit;                     -- acknowledge write
    dout : slv16;                       -- data out (output from memory)
  end record em_sres_type;
  
  constant em_sres_init : em_sres_type := (
    '0','0',                            -- ack_r, ack_w
    (others=>'0')                       -- dout
  );

  type mmu_cntl_type is record          -- mmu control port
    req : slbit;                        -- translate request
    wacc : slbit;                       -- write access
    macc : slbit;                       -- modify access (r-m-w sequence)
    cacc : slbit;                       -- console access (bypass mmu)
    dspace : slbit;                     -- dspace access
    mode : slv2;                        -- processor mode
    trap_done : slbit;                  -- mmu trap taken (set ssr0 bit)
  end record mmu_cntl_type;

  constant mmu_cntl_init : mmu_cntl_type := (
    '0','0','0','0',                    -- req, wacc, macc, cacc
    '0',"00",'0'                        -- dspace, mode, trap_done
  );

  type mmu_stat_type is record          -- mmu status port
    vaok : slbit;                       -- virtual address valid
    trap : slbit;                       -- mmu trap request
    ena_mmu : slbit;                    -- mmu enable (ssr0 bit 0)
    ena_22bit : slbit;                  -- mmu in 22 bit mode (ssr3 bit 4)
    ena_ubmap : slbit;                  -- ubmap enable (ssr3 bit 5)
  end record mmu_stat_type;

  constant mmu_stat_init : mmu_stat_type := (others=>'0');

  type mmu_moni_type is record          -- mmu monitor port
    istart : slbit;                     -- instruction start
    idone : slbit;                      -- instruction done
    pc : slv16;                         -- PC of new instruction
    regmod : slbit;                     -- register modified
    regnum : slv3;                      -- register number
    delta : slv4;                       -- register offset
    isdec : slbit;                      -- offset to be subtracted
    trace_prev : slbit;                 -- use ssr12 trace state of prev. state
  end record mmu_moni_type;

  constant mmu_moni_init : mmu_moni_type := (
    '0','0',(others=>'0'),              -- istart, idone, pc
    '0',"000","0000",                   -- regmod, regnum, delta
    '0','0'                             -- isdec, trace_prev
  );

  type mmu_ssr0_type is record          -- MMU ssr0
    abo_nonres : slbit;                 -- abort non resident
    abo_length : slbit;                 -- abort segment length
    abo_rdonly : slbit;                 -- abort read-only
    trap_mmu : slbit;                   -- trap management
    ena_trap : slbit;                   -- enable traps
    inst_compl : slbit;                 -- instruction complete
    seg_mode : slv2;                    -- segement mode
    dspace : slbit;                     -- address space (D=1, I=0)
    seg_num : slv3;                     -- segment number
    ena_mmu : slbit;                    -- enable memory management
    trace_prev : slbit;                 -- ssr12 trace status in prev. state
  end record mmu_ssr0_type;

  constant mmu_ssr0_init : mmu_ssr0_type := (
    inst_compl=>'0', seg_mode=>"00", seg_num=>"000",
    others=>'0'
  );

  type mmu_ssr1_type is record          -- MMU ssr1
    rb_delta : slv5;                    -- RB: amount change
    rb_num : slv3;                      -- RB: register number
    ra_delta : slv5;                    -- RA: amount change
    ra_num : slv3;                      -- RA: register number
  end record mmu_ssr1_type;
  
  constant mmu_ssr1_init : mmu_ssr1_type := (
    "00000","000",                      -- rb_...
    "00000","000"                       -- ra_...
  );

  type mmu_ssr3_type is record          -- MMU ssr3
    ena_ubmap : slbit;                  -- enable unibus mapping
    ena_22bit : slbit;                  -- enable 22 bit mapping
    dspace_km : slbit;                  -- enable dspace kernel
    dspace_sm : slbit;                  -- enable dspace supervisor
    dspace_um : slbit;                  -- enable dspace user
  end record mmu_ssr3_type;

  constant mmu_ssr3_init : mmu_ssr3_type := (others=>'0');

-- control port definitions --------------------------------------------------

  type cp_cntl_type is record           -- control port control
    req : slbit;                        -- request
    func : slv5;                        -- function
    rnum : slv3;                        -- register number
  end record cp_cntl_type;

  constant c_cpfunc_noop    : slv5 := "00000";  -- noop : no operation
  constant c_cpfunc_start   : slv5 := "00001";  -- sta  : cpu start
  constant c_cpfunc_stop    : slv5 := "00010";  -- sto  : cpu stop 
  constant c_cpfunc_step    : slv5 := "00011";  -- cont : cpu step
  constant c_cpfunc_creset  : slv5 := "00100";  -- step : cpu cpu reset
  constant c_cpfunc_breset  : slv5 := "00101";  -- rst  : cpu bus reset
  constant c_cpfunc_suspend : slv5 := "00110";  -- rst  : cpu suspend
  constant c_cpfunc_resume  : slv5 := "00111";  -- rst  : cpu resume

  constant c_cpfunc_rreg    : slv5 := "10000";  -- rreg : read register
  constant c_cpfunc_wreg    : slv5 := "10001";  -- wreg : write register
  constant c_cpfunc_rpsw    : slv5 := "10010";  -- rpsw : read psw
  constant c_cpfunc_wpsw    : slv5 := "10011";  -- wpsw : write psw
  constant c_cpfunc_rmem    : slv5 := "10100";  -- rmem : read memory
  constant c_cpfunc_wmem    : slv5 := "10101";  -- wmem : write memory

  constant cp_cntl_init : cp_cntl_type := ('0',c_cpfunc_noop,"000");

  type cp_stat_type is record           -- control port status
    cmdbusy : slbit;                    -- command busy
    cmdack : slbit;                     -- command acknowledge
    cmderr : slbit;                     -- command error
    cmdmerr : slbit;                    -- command memory access error
    cpugo : slbit;                      -- CPU go state
    cpustep : slbit;                    -- CPU step flag
    cpuwait : slbit;                    -- CPU wait flag
    cpususp : slbit;                    -- CPU susp flag
    cpurust : slv4;                     -- CPU run status
    suspint : slbit;                    -- internal suspend
    suspext : slbit;                    -- external suspend
  end record cp_stat_type;

  constant cp_stat_init : cp_stat_type := (
    '0','0','0','0',                    -- cmd...
    '0','0','0','0',                    -- cpu...
    (others=>'0'),                      -- cpurust
    '0','0'                             -- susp...
  );

  type cp_addr_type is record           -- control port address
    addr : slv22_1;                     -- address
    racc : slbit;                       -- ibus remote access
    be : slv2;                          -- byte enables
    ena_22bit : slbit;                  -- enable 22 bit mode
    ena_ubmap : slbit;                  -- enable unibus mapper
  end record cp_addr_type;

  constant cp_addr_init : cp_addr_type := (
    (others=>'0'),                      -- addr
    '0',"00",                           -- racc, be
    '0','0'                             -- ena_...
  );

-- debug and monitoring port definitions -------------------------------------

  type dm_cntl_type is record           -- debug and monitor control
    dum1 : slbit;                       -- dummy 1
    dum2 : slbit;                       -- dummy 2
  end record dm_cntl_type;

  constant dm_cntl_init : dm_cntl_type := (others=>'0');

  type dm_stat_dp_type is record        -- debug and monitor status - dpath
    pc : slv16;                         -- pc
    psw : psw_type;                     -- psw
    ireg : slv16;                       -- ireg
    ireg_we : slbit;                    -- ireg we
    dsrc : slv16;                       -- dsrc register
    ddst : slv16;                       -- ddst register
    dtmp : slv16;                       -- dtmp register
    dres : slv16;                       -- dres bus
    gpr_adst : slv3;                    -- gpr dst regsiter
    gpr_mode : slv2;                    -- gpr mode
    gpr_bytop : slbit;                  -- gpr bytop
    gpr_we : slbit;                     -- gpr we
  end record dm_stat_dp_type;

  constant dm_stat_dp_init : dm_stat_dp_type := (
    (others=>'0'),                      -- pc
    psw_init,                           -- psw
    (others=>'0'),'0',                  -- ireg, ireg_we
    (others=>'0'),(others=>'0'),        -- dsrc, ddst
    (others=>'0'),(others=>'0'),        -- dtmp, dres
    (others=>'0'),(others=>'0'),        -- gpr_adst, gpr_mode
    '0','0'                             -- gpr_bytop, gpr_we
  );

  type dm_stat_vm_type is record        -- debug and monitor status - vmbox
    ibmreq : ib_mreq_type;              -- ibus master request
    ibsres : ib_sres_type;              -- ibus slave response
  end record dm_stat_vm_type;

  constant dm_stat_vm_init : dm_stat_vm_type := (ib_mreq_init,ib_sres_init);

  type dm_stat_co_type is record        -- debug and monitor status - core
    cpugo : slbit;                      -- cpugo state flag
    cpususp : slbit;                    -- cpususp state flag
    suspint : slbit;                    -- suspint state flag
    suspext : slbit;                    -- suspext state flag
  end record dm_stat_co_type;

  constant dm_stat_co_init : dm_stat_co_type := (
    '0','0',                            -- cpu...
    '0','0'                             -- susp...
  );

  type dm_stat_sy_type is record        -- debug and monitor status - system
    emmreq : em_mreq_type;              -- external memory: request
    emsres : em_sres_type;              -- external memory: response
    chit : slbit;                       -- cache hit
  end record dm_stat_sy_type;

  constant dm_stat_sy_init : dm_stat_sy_type := (
    em_mreq_init,                       -- emmreq
    em_sres_init,                       -- emsres
    '0'                                 -- chit
  );

-- rbus interface definitions ------------------------------------------------

  constant c_rbaddr_conf : slv5 := "00000"; -- R/W configuration reg
  constant c_rbaddr_cntl : slv5 := "00001"; -- -/F  control reg
  constant c_rbaddr_stat : slv5 := "00010"; -- R/- status reg
  constant c_rbaddr_psw  : slv5 := "00011"; -- R/W psw access
  constant c_rbaddr_al   : slv5 := "00100"; -- R/W address low reg
  constant c_rbaddr_ah   : slv5 := "00101"; -- R/W address high reg
  constant c_rbaddr_mem  : slv5 := "00110"; -- R/W memory access
  constant c_rbaddr_memi : slv5 := "00111"; -- R/W memory access; inc addr

  constant c_rbaddr_r0   : slv5 := "01000"; -- R/W gpr 0
  constant c_rbaddr_r1   : slv5 := "01001"; -- R/W gpr 1
  constant c_rbaddr_r2   : slv5 := "01010"; -- R/W gpr 2
  constant c_rbaddr_r3   : slv5 := "01011"; -- R/W gpr 3
  constant c_rbaddr_r4   : slv5 := "01100"; -- R/W gpr 4
  constant c_rbaddr_r5   : slv5 := "01101"; -- R/W gpr 5
  constant c_rbaddr_sp   : slv5 := "01110"; -- R/W gpr 6 (sp)
  constant c_rbaddr_pc   : slv5 := "01111"; -- R/W gpr 7 (pc)
  
  constant c_rbaddr_membe: slv5 := "10000"; -- R/W memory write byte enables

  subtype  c_al_rbf_addr        is integer range 15 downto 1;  -- al: address
  constant c_ah_rbf_ena_ubmap:  integer :=  7;                 -- ah: ubmap
  constant c_ah_rbf_ena_22bit:  integer :=  6;                 -- ah: 22bit
  subtype  c_ah_rbf_addr        is integer range  5 downto 0;  -- ah: address

  constant c_stat_rbf_suspext:  integer := 9;  -- stat field: suspext
  constant c_stat_rbf_suspint:  integer := 8;  -- stat field: suspint
  subtype  c_stat_rbf_cpurust   is integer range  7 downto  4;  -- cpurust
  constant c_stat_rbf_cpususp:  integer := 3;  -- stat field: cpususp
  constant c_stat_rbf_cpugo:    integer := 2;  -- stat field: cpugo
  constant c_stat_rbf_cmdmerr:  integer := 1;  -- stat field: cmdmerr
  constant c_stat_rbf_cmderr:   integer := 0;  -- stat field: cmderr

  subtype  c_membe_rbf_be       is integer range  1 downto 0; -- membe: be's
  constant c_membe_rbf_stick:   integer := 2;  -- membe: sticky flag

-- -------------------------------------
  
component pdp11_gpr is                  -- general purpose registers
  port (
    CLK : in slbit;                     -- clock
    DIN : in slv16;                     -- input data
    ASRC : in slv3;                     -- source register number
    ADST : in slv3;                     -- destination register number
    MODE : in slv2;                     -- processor mode (k=>00,s=>01,u=>11)
    RSET : in slbit;                    -- register set
    WE : in slbit;                      -- write enable
    BYTOP : in slbit;                   -- byte operation (write low byte only)
    PCINC : in slbit;                   -- increment PC
    DSRC : out slv16;                   -- source register data
    DDST : out slv16;                   -- destination register data
    PC : out slv16                      -- current PC value
  );
end component;

constant c_gpr_r5 : slv3 := "101";      -- register number of r5
constant c_gpr_sp : slv3 := "110";      -- register number of SP
constant c_gpr_pc : slv3 := "111";      -- register number of PC

component pdp11_psr is                  -- processor status word register
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    DIN : in slv16;                     -- input data
    CCIN : in slv4;                     -- cc input
    CCWE : in slbit;                    -- enable update cc
    WE : in slbit;                      -- write enable (from DIN)
    FUNC : in slv3;                     -- write function (from DIN)
    PSW : out psw_type;                 -- current psw
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

constant c_psr_func_wspl : slv3 := "000"; -- SPL mode: set pri
constant c_psr_func_wcc  : slv3 := "001"; -- CC mode: set/clear cc
constant c_psr_func_wint : slv3 := "010"; -- interupt mode: pmode=cmode
constant c_psr_func_wrti : slv3 := "011"; -- rti mode: protect modes
constant c_psr_func_wall : slv3 := "100"; -- write all fields

component pdp11_ounit is                -- offset adder for addresses (ounit)
  port (
    DSRC : in slv16;                    -- 'src' data for port A
    DDST : in slv16;                    -- 'dst' data for port A
    DTMP : in slv16;                    -- 'tmp' data for port A
    PC : in slv16;                      -- PC data for port A
    ASEL : in slv2;                     -- selector for port A
    AZERO : in slbit;                   -- force zero for port A
    IREG8 : in slv8;                    -- 'ireg' data for port B
    VMDOUT : in slv16;                  -- virt. memory data for port B
    CONST : in slv9;                    -- sequencer const data for port B
    BSEL : in slv2;                     -- selector for port B
    OPSUB : in slbit;                   -- operation: 0 add, 1 sub
    DOUT : out slv16;                   -- data output
    NZOUT : out slv2                    -- NZ condition codes out
  );
end component;

constant c_ounit_asel_ddst : slv2 := "00";   -- A = DDST
constant c_ounit_asel_dsrc : slv2 := "01";   -- A = DSRC
constant c_ounit_asel_pc   : slv2 := "10";   -- A = PC  
constant c_ounit_asel_dtmp : slv2 := "11";   -- A = DTMP

constant c_ounit_bsel_const  : slv2 := "00"; -- B = CONST
constant c_ounit_bsel_vmdout : slv2 := "01"; -- B = VMDOUT
constant c_ounit_bsel_ireg6  : slv2 := "10"; -- B = 2*IREG(6bit)
constant c_ounit_bsel_ireg8  : slv2 := "11"; -- B = 2*IREG(8bit,sign-extend)

component pdp11_aunit is                -- arithmetic unit for data (aunit)
  port (                              
    DSRC : in slv16;                    -- 'src' data in
    DDST : in slv16;                    -- 'dst' data in
    CI : in slbit;                      -- carry flag in
    SRCMOD : in slv2;                   -- src modifier mode
    DSTMOD : in slv2;                   -- dst modifier mode
    CIMOD : in slv2;                    -- ci modifier mode
    CC1OP : in slbit;                   -- use cc modes (1 op instruction)
    CCMODE : in slv3;                   -- cc mode
    BYTOP : in slbit;                   -- byte operation
    DOUT : out slv16;                   -- data output
    CCOUT : out slv4                    -- condition codes out
  );
end component;

constant c_aunit_mod_pass : slv2 := "00"; -- pass data
constant c_aunit_mod_inv  : slv2 := "01"; -- invert data
constant c_aunit_mod_zero : slv2 := "10"; -- set to 0
constant c_aunit_mod_one  : slv2 := "11"; -- set to 1

-- the c_aunit_ccmode codes follow exactly the opcode format (bit 8:6)
constant c_aunit_ccmode_clr : slv3 := "000"; -- do clr instruction
constant c_aunit_ccmode_com : slv3 := "001"; -- do com instruction
constant c_aunit_ccmode_inc : slv3 := "010"; -- do inc instruction
constant c_aunit_ccmode_dec : slv3 := "011"; -- do dec instruction
constant c_aunit_ccmode_neg : slv3 := "100"; -- do neg instruction
constant c_aunit_ccmode_adc : slv3 := "101"; -- do adc instruction
constant c_aunit_ccmode_sbc : slv3 := "110"; -- do sbc instruction
constant c_aunit_ccmode_tst : slv3 := "111"; -- do tst instruction
  
component pdp11_lunit is                -- logic unit for data (lunit)
  port (
    DSRC : in slv16;                    -- 'src' data in
    DDST : in slv16;                    -- 'dst' data in
    CCIN : in slv4;                     -- condition codes in
    FUNC : in slv4;                     -- function
    BYTOP : in slbit;                   -- byte operation
    DOUT : out slv16;                   -- data output
    CCOUT : out slv4                    -- condition codes out
  );        
end component;

constant c_lunit_func_asr  : slv4 := "0000"; -- ASR/ASRB ??? recheck coding !!
constant c_lunit_func_asl  : slv4 := "0001"; -- ASL/ASLB
constant c_lunit_func_ror  : slv4 := "0010"; -- ROR/RORB
constant c_lunit_func_rol  : slv4 := "0011"; -- ROL/ROLB
constant c_lunit_func_bis  : slv4 := "0100"; -- BIS/BISB
constant c_lunit_func_bic  : slv4 := "0101"; -- BIC/BICB
constant c_lunit_func_bit  : slv4 := "0110"; -- BIT/BITB
constant c_lunit_func_mov  : slv4 := "0111"; -- MOV/MOVB
constant c_lunit_func_sxt  : slv4 := "1000"; -- SXT
constant c_lunit_func_swap : slv4 := "1001"; -- SWAB
constant c_lunit_func_xor  : slv4 := "1010"; -- XOR

component pdp11_munit is                -- mul/div unit for data (munit)
  port (                              
    CLK : in slbit;                     -- clock
    DSRC : in slv16;                    -- 'src' data in
    DDST : in slv16;                    -- 'dst' data in
    DTMP : in slv16;                    -- 'tmp' data in
    GPR_DSRC : in slv16;                -- 'src' data from GPR
    FUNC : in slv2;                     -- function
    S_DIV : in slbit;                   -- s_opg_div state    (load dd_low)
    S_DIV_CN : in slbit;                -- s_opg_div_cn state (1st..16th cycle)
    S_DIV_CR : in slbit;                -- s_opg_div_cr state (remainder corr.)
    S_DIV_SR : in slbit;                -- s_opg_div_sr state (store remainder)
    S_ASH : in slbit;                   -- s_opg_ash state
    S_ASH_CN : in slbit;                -- s_opg_ash_cn state
    S_ASHC : in slbit;                  -- s_opg_ashc state
    S_ASHC_CN : in slbit;               -- s_opg_ashc_cn state
    SHC_TC : out slbit;                 -- last shc cycle (shc==0)
    DIV_CR : out slbit;                 -- division: remainder correction needed
    DIV_CQ : out slbit;                 -- division: quotient correction needed
    DIV_QUIT : out slbit;               -- division: abort (0/ or /0 or V=1)
    DOUT : out slv16;                   -- data output
    DOUTE : out slv16;                  -- data output extra
    CCOUT : out slv4                    -- condition codes out
  );
end component;

constant c_munit_func_mul  : slv2 := "00"; -- MUL
constant c_munit_func_div  : slv2 := "01"; -- DIV
constant c_munit_func_ash  : slv2 := "10"; -- ASH
constant c_munit_func_ashc : slv2 := "11"; -- ASHC

component pdp11_mmu_sadr is             -- mmu SAR/SDR register set
  port (
    CLK : in slbit;                     -- clock
    MODE : in slv2;                     -- mode
    ASN : in slv4;                      -- augmented segment number (1+3 bit)
    AIB_WE : in slbit;                  -- update AIB
    AIB_SETA : in slbit;                -- set access AIB
    AIB_SETW : in slbit;                -- set write AIB
    SARSDR : out sarsdr_type;           -- combined SAR/SDR
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component pdp11_mmu_ssr12 is            -- mmu register ssr1 and ssr2
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    TRACE : in slbit;                   -- trace enable
    MONI : in mmu_moni_type;            -- MMU monitor port data
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component pdp11_mmu is                  -- mmu - memory management unit
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    BRESET : in slbit;                  -- bus reset
    CNTL : in mmu_cntl_type;            -- control port
    VADDR : in slv16;                   -- virtual address
    MONI : in mmu_moni_type;            -- monitor port
    STAT : out mmu_stat_type;           -- status port
    PADDRH : out slv16;                 -- physical address (upper 16 bit)
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component pdp11_vmbox is                -- virtual memory
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    CRESET : in slbit;                  -- cpu reset
    BRESET : in slbit;                  -- bus reset
    CP_ADDR : in cp_addr_type;          -- console port address
    VM_CNTL : in vm_cntl_type;          -- vm control port
    VM_ADDR : in slv16;                 -- vm address
    VM_DIN : in slv16;                  -- vm data in
    VM_STAT : out vm_stat_type;         -- vm status port
    VM_DOUT : out slv16;                -- vm data out
    EM_MREQ : out em_mreq_type;         -- external memory: request
    EM_SRES : in em_sres_type;          -- external memory: response
    MMU_MONI : in mmu_moni_type;        -- mmu monitor port
    IB_MREQ_M : out ib_mreq_type;       -- ibus request  (master)
    IB_SRES_CPU : in ib_sres_type;      -- ibus response (CPU registers)
    IB_SRES_EXT : in ib_sres_type;      -- ibus response (external devices)
    DM_STAT_VM : out dm_stat_vm_type    -- debug and monitor status
  );
end component;
  
component pdp11_dpath is                -- CPU datapath
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    CNTL : in dpath_cntl_type;          -- control interface
    STAT : out dpath_stat_type;         -- status interface
    CP_DIN : in slv16;                  -- console port data in
    CP_DOUT : out slv16;                -- console port data out
    PSWOUT : out psw_type;              -- current psw
    PCOUT : out slv16;                  -- current pc
    IREG : out slv16;                   -- ireg out
    VM_ADDR : out slv16;                -- virt. memory address
    VM_DOUT : in slv16;                 -- virt. memory data out
    VM_DIN : out slv16;                 -- virt. memory data in
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    DM_STAT_DP : out dm_stat_dp_type    -- debug and monitor status - dpath
  );
end component;

component pdp11_decode is             -- instruction decoder
  port (
    IREG : in slv16;                  -- input instruction word
    STAT : out decode_stat_type       -- status output
  );
end component;

component pdp11_sequencer is            -- cpu sequencer
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    PSW : in psw_type;                  -- processor status
    PC : in slv16;                      -- program counter
    IREG : in slv16;                    -- IREG
    ID_STAT : in decode_stat_type;      -- instr. decoder status
    DP_STAT : in dpath_stat_type;       -- data path status
    CP_CNTL : in cp_cntl_type;          -- console port control
    VM_STAT : in vm_stat_type;          -- virtual memory status port
    INT_PRI : in slv3;                  -- interrupt priority
    INT_VECT : in slv9_2;               -- interrupt vector
    INT_ACK : out slbit;                -- interrupt acknowledge
    CRESET : out slbit;                 -- cpu reset
    BRESET : out slbit;                 -- bus reset
    MMU_MONI : out mmu_moni_type;       -- mmu monitor port
    DP_CNTL : out dpath_cntl_type;      -- data path control
    VM_CNTL : out vm_cntl_type;         -- virtual memory control port
    CP_STAT : out cp_stat_type;         -- console port status
    ESUSP_O : out slbit;                -- external suspend output
    ESUSP_I : in slbit;                 -- external suspend input
    ITIMER : out slbit;                 -- instruction timer
    EBREAK : in slbit;                  -- execution break
    DBREAK : in slbit;                  -- data break
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response    
  );
end component;

component pdp11_irq is                  -- interrupt requester
  port (
    CLK : in slbit;                     -- clock
    BRESET : in slbit;                  -- bus reset
    INT_ACK : in slbit;                 -- interrupt acknowledge from CPU
    EI_PRI : in slv3;                   -- external interrupt priority
    EI_VECT : in slv9_2;                -- external interrupt vector
    EI_ACKM : out slbit;                -- external interrupt acknowledge
    PRI : out slv3;                     -- interrupt priority
    VECT : out slv9_2;                  -- interrupt vector
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component pdp11_ubmap is                -- 11/70 unibus mapper
  port (
    CLK : in slbit;                     -- clock
    MREQ : in slbit;                    -- request mapping
    ADDR_UB : in slv18_1;               -- UNIBUS address (in)
    ADDR_PM : out slv22_1;              -- physical memory address (out)
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component pdp11_reg70 is                -- 11/70 memory system registers
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component pdp11_mem70 is                -- 11/70 memory system registers
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- cpu reset
    HM_ENA : in slbit;                  -- hit/miss enable
    HM_VAL : in slbit;                  -- hit/miss value
    CACHE_FMISS : out slbit;            -- cache force miss
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component pdp11_cache is                -- cache
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    EM_MREQ : in em_mreq_type;          -- em request
    EM_SRES : out em_sres_type;         -- em response
    FMISS : in slbit;                   -- force miss
    CHIT : out slbit;                   -- cache hit flag
    MEM_REQ : out slbit;                -- memory: request
    MEM_WE : out slbit;                 -- memory: write enable
    MEM_BUSY : in slbit;                -- memory: controller busy
    MEM_ACK_R : in slbit;               -- memory: acknowledge read
    MEM_ADDR : out slv20;               -- memory: address
    MEM_BE : out slv4;                  -- memory: byte enable
    MEM_DI : out slv32;                 -- memory: data in  (memory view)
    MEM_DO : in slv32                   -- memory: data out (memory view)
  );
end component;

component pdp11_core is                 -- full processor core
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
end component;

component pdp11_tmu is                  -- trace and monitor unit
  port (
    CLK : in slbit;                     -- clock
    ENA : in slbit := '0';              -- enable trace output
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type;    -- debug and monitor status - core
    DM_STAT_SY : in dm_stat_sy_type     -- debug and monitor status - system
  );
end component;

component pdp11_tmu_sb is               -- trace and mon. unit; simbus wrapper
  generic (
    ENAPIN : integer := 13);            -- SB_CNTL signal to use for enable
   port (
    CLK : in slbit;                     -- clock
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type;    -- debug and monitor status - core
    DM_STAT_SY : in dm_stat_sy_type     -- debug and monitor status - system
  );
end component;

component pdp11_du_drv is               -- display unit low level driver
  generic (
    CDWIDTH : positive :=  3);          -- clock divider width
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    ROW0 : in slv22;                    -- led row 0 (22 leds, top)
    ROW1 : in slv16;                    -- led row 1 (16 leds)
    ROW2 : in slv16;                    -- led row 2 (16 leds)
    ROW3 : in slv10;                    -- led row 3 (10 leds, bottom)
    SWOPT : out slv8;                   -- option pattern from du
    SWOPT_RDY : out slbit;              -- marks update of swopt
    DU_SCLK : out slbit;                -- DU: sclk
    DU_SS_N : out slbit;                -- DU: ss_n
    DU_MOSI : out slbit;                -- DU: mosi (master out, slave in)
    DU_MISO : in slbit                  -- DU: miso (master in, slave out)
  );
end component;

component pdp11_bram is                 -- BRAM based ext. memory dummy
  generic (
    AWIDTH : positive := 14);           -- address width
  port (
    CLK : in slbit;                     -- clock
    GRESET : in slbit;                  -- general reset
    EM_MREQ : in em_mreq_type;          -- em request
    EM_SRES : out em_sres_type          -- em response
  );
end component;

component pdp11_bram_memctl is          -- BRAM based memctl
  generic (
    MAWIDTH : positive := 4;            -- mux address width
    NBLOCK : positive := 11);           -- write delay in clock cycles
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv20;                    -- address
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32                      -- data out (memory view)
  );
end component;

component pdp11_statleds is             -- status leds
  port (
    MEM_ACT_R : in slbit;               -- memory active read
    MEM_ACT_W : in slbit;               -- memory active write
    CP_STAT : in cp_stat_type;          -- console port status
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    STATLEDS : out slv8                 -- 8 bit CPU status 
  );
end component;

component pdp11_ledmux is               -- hio led mux
  generic (
    LWIDTH : positive := 8);            -- led width
  port (
    SEL : in slbit;                     -- select (0=stat;1=dr)
    STATLEDS : in slv8;                 -- 8 bit CPU status
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    LED : out slv(LWIDTH-1 downto 0)    -- hio leds
  );
end component;

component pdp11_dspmux is               -- hio dsp mux
  generic (
    DCWIDTH : positive := 2);           -- digit counter width (2 or 3)
  port (
    SEL : in slv2;                      -- select
    ABCLKDIV : in slv16;                -- serport clock divider
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - dpath
    DISPREG : in slv16;                 -- display register
    DSP_DAT : out slv(4*(2**DCWIDTH)-1 downto 0)  -- display data
  );
end component;

component pdp11_core_rbus is            -- core to rbus interface
  generic (
    RB_ADDR_CORE : slv16 := slv(to_unsigned(16#0000#,16));
    RB_ADDR_IBUS : slv16 := slv(to_unsigned(16#4000#,16)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_STAT : out slv4;                 -- rbus: status flags
    RB_LAM : out slbit;                 -- remote attention
    GRESET : out slbit;                 -- general reset
    CP_CNTL : out cp_cntl_type;         -- console control port
    CP_ADDR : out cp_addr_type;         -- console address port
    CP_DIN : out slv16;                 -- console data in
    CP_STAT : in cp_stat_type;          -- console status port
    CP_DOUT : in slv16                  -- console data out
  );
end component;

component pdp11_sys70 is                -- 11/70 system 1 core +rbus,debug,cache
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
    IB_SRES : in ib_sres_type;          -- ibus response (from IO system)
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
end component;

component pdp11_hio70 is                -- hio led and dsp for sys70
  generic (
    LWIDTH : positive := 8;             -- led width
    DCWIDTH : positive := 2);           -- digit counter width (2 or 3)
  port (
    SEL_LED : in slbit;                 -- led select (0=stat;1=dr)
    SEL_DSP : in slv2;                  -- dsp select
    MEM_ACT_R : in slbit;               -- memory active read
    MEM_ACT_W : in slbit;               -- memory active write
    CP_STAT : in cp_stat_type;          -- console port status
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status
    ABCLKDIV : in slv16;                -- serport clock divider
    DISPREG : in slv16;                 -- display register
    LED : out slv(LWIDTH-1 downto 0);   -- hio leds
    DSP_DAT : out slv(4*(2**DCWIDTH)-1 downto 0)  -- display data
  );
end component;

-- ----- move later to pdp11_conf --------------------------------------------

constant conf_vect_pirq : integer := 8#240#;
constant conf_pri_pirq_1 : integer := 1;
constant conf_pri_pirq_2 : integer := 2;
constant conf_pri_pirq_3 : integer := 3;
constant conf_pri_pirq_4 : integer := 4;
constant conf_pri_pirq_5 : integer := 5;
constant conf_pri_pirq_6 : integer := 6;
constant conf_pri_pirq_7 : integer := 7;

end package pdp11;

-- $Id: pdp11_sequencer.vhd 679 2015-05-13 17:38:46Z mueller $
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
-- Module Name:    pdp11_sequencer - syn
-- Description:    pdp11: CPU sequencer
--
-- Dependencies:   ib_sel
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-05-10   678   1.6    start/stop/suspend overhaul; reset overhaul
-- 2015-02-07   643   1.5.2  s_op_wait: load R0 in DSRC for DR emulation
-- 2014-07-12   569   1.5.1  rename s_opg_div_zero -> s_opg_div_quit;
--                           use DP_STAT.div_quit; set munit_s_div_sr;
--                           BUGFIX: s_opg_div_sr: check for late div_quit
-- 2014-04-20   554   1.5    now vivado compatible (add dummy assigns in procs)
-- 2011-11-18   427   1.4.2  now numeric_std clean
-- 2010-10-23   335   1.4.1  use ib_sel
-- 2010-10-17   333   1.4    use ibus V2 interface
-- 2010-09-18   300   1.3.2  rename (adlm)box->(oalm)unit
-- 2010-06-20   307   1.3.1  rename cpacc to cacc in vm_cntl_type
-- 2010-06-13   305   1.3    remove CPDIN_WE, CPDOUT_WE out ports; set
--                           CNTL.cpdout_we instead of CPDOUT_WE
-- 2010-06-12   304   1.2.8  signal cpuwait when spinning in s_op_wait
-- 2009-05-30   220   1.2.7  final removal of snoopers (were already commented)
-- 2009-05-09   213   1.2.6  BUGFIX: use is_dstkstack1246, stklim for mode=6
-- 2009-05-02   211   1.2.5  BUGFIX: 11/70 spl semantics again in kernel mode
-- 2009-04-26   209   1.2.4  BUGFIX: give interrupts priority over trap handling
-- 2008-12-14   177   1.2.3  BUGFIX: use is_dstkstack124, fix stklim check bug
-- 2008-12-13   176   1.2.2  BUGFIX: use is_pci in s_dstw_inc if DSTDEF='1'
-- 2008-11-30   174   1.2.1  BUGFIX: add updt_dstadsrc; prevent stale DSRC
-- 2008-08-22   161   1.2    rename ubf_ -> ibf_; use iblib
-- 2008-05-03   143   1.1.9  rename _cpursta->_cpurust; cp reset sets now
--                           c_cpurust_reset; proper c_cpurust_vfail handling
-- 2008-04-27   140   1.1.8  BUGFIX: halt cpu in case of a vector fetch error
--                           use cpursta to encode why cpu halts, remove cpufail
-- 2008-04-27   139   1.1.7  BUGFIX: correct bytop handling for address fetches;
--                           BUGFIX: redo mtp flow; add fork_dsta fork and ddst
--                                   reload in s_opa_mtp_pop_w;
-- 2008-04-19   137   1.1.6  BUGFIX: fix loop state in s_rti_getpc_w
-- 2008-03-30   131   1.1.5  BUGFIX: inc/dec by 2 for byte mode -(sp),(sp)+
--                             inc/dec by 2 for @(R)+ and @-(R) also for bytop's
-- 2008-03-02   121   1.1.4  remove snoopers; add waitsusp, redo WAIT handling
-- 2008-02-24   119   1.1.3  add lah,rps,wps command; revamp cp memory access
--                           change WAIT logic, now also bails out on cp command
-- 2008-01-20   112   1.1.2  rename PRESET->BRESET
-- 2008-01-05   110   1.1.1  rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
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

entity pdp11_sequencer is               -- CPU sequencer
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
end pdp11_sequencer;

architecture syn of pdp11_sequencer is

  constant ibaddr_cpuerr : slv16 := slv(to_unsigned(8#177766#,16));
  
  constant cpuerr_ibf_illhlt : integer := 7;
  constant cpuerr_ibf_adderr : integer := 6;
  constant cpuerr_ibf_nxm : integer := 5;
  constant cpuerr_ibf_iobto : integer := 4;
  constant cpuerr_ibf_ysv : integer := 3;
  constant cpuerr_ibf_rsv : integer := 2;

  type state_type is (
    s_idle,
    s_cp_regread,
    s_cp_rps,
    s_cp_memr_w,
    s_cp_memw_w,
    s_ifetch,
    s_ifetch_w,
    s_idecode,

    s_srcr_def,
    s_srcr_def_w,
    s_srcr_inc,
    s_srcr_inc_w,
    s_srcr_dec,
    s_srcr_dec1,
    s_srcr_ind,
    s_srcr_ind1_w,
    s_srcr_ind2,
    s_srcr_ind2_w,

    s_dstr_def,
    s_dstr_def_w,
    s_dstr_inc,
    s_dstr_inc_w,
    s_dstr_dec,
    s_dstr_dec1,
    s_dstr_ind,
    s_dstr_ind1_w,
    s_dstr_ind2,
    s_dstr_ind2_w,

    s_dstw_def,
    s_dstw_def_w,
    s_dstw_inc,
    s_dstw_inc_w,
    s_dstw_incdef_w,
    s_dstw_dec,
    s_dstw_dec1,
    s_dstw_ind,
    s_dstw_ind_w,
    s_dstw_def246,

    s_dsta_inc,
    s_dsta_incdef_w,
    s_dsta_dec,
    s_dsta_dec1,
    s_dsta_ind,
    s_dsta_ind_w,

    s_op_halt,
    s_op_wait,
    s_op_trap,
    s_op_reset,
    s_op_rts,
    s_op_rts_pop,
    s_op_rts_pop_w,
    s_op_spl,
    s_op_mcc,
    s_op_br,
    s_op_mark,
    s_op_mark1,
    s_op_mark_pop,
    s_op_mark_pop_w,
    s_op_sob,
    s_op_sob1,

    s_opg_gen,
    s_opg_gen_rmw_w,
    s_opg_mul,
    s_opg_mul1,
    s_opg_div,
    s_opg_div_cn,
    s_opg_div_cr,
    s_opg_div_sq,
    s_opg_div_sr,
    s_opg_div_quit,
    s_opg_ash,
    s_opg_ash_cn,
    s_opg_ashc,
    s_opg_ashc_cn,
    s_opg_ashc_wl,

    s_opa_jsr,
    s_opa_jsr1,
    s_opa_jsr_push,
    s_opa_jsr_push_w,
    s_opa_jsr2,
    s_opa_jmp,
    s_opa_mtp,
    s_opa_mtp_pop_w,
    s_opa_mtp_reg,
    s_opa_mtp_mem,
    s_opa_mtp_mem_w,
    s_opa_mfp_reg,
    s_opa_mfp_mem,
    s_opa_mfp_mem_w,
    s_opa_mfp_dec,
    s_opa_mfp_push,
    s_opa_mfp_push_w,
    
    s_trap_4,
    s_trap_10,
    s_trap_disp,

    s_int_ext,

    s_int_getpc,
    s_int_getpc_w,
    s_int_getps,
    s_int_getps_w,
    s_int_getsp,
    s_int_decsp,
    s_int_pushps,
    s_int_pushps_w,
    s_int_pushpc,
    s_int_pushpc_w,

    s_rti_getpc,
    s_rti_getpc_w,
    s_rti_getps,
    s_rti_getps_w,
    s_rti_newpc,
    
    s_vmerr,
    s_cpufail
  );

  signal R_STATE : state_type := s_idle;  -- state register
  signal N_STATE : state_type := s_idle;

  signal R_STATUS : cpustat_type := cpustat_init;
  signal N_STATUS : cpustat_type := cpustat_init;
  signal R_CPUERR : cpuerr_type := cpuerr_init;
  signal N_CPUERR : cpuerr_type := cpuerr_init;

  signal R_IDSTAT : decode_stat_type := decode_stat_init;
  signal N_IDSTAT : decode_stat_type := decode_stat_init;

  signal R_VMSTAT : vm_stat_type := vm_stat_init;

  signal IBSEL_CPUERR : slbit := '0';

begin

  SEL : ib_sel
    generic map (
      IB_ADDR => ibaddr_cpuerr)
    port map (
      CLK     => CLK,
      IB_MREQ => IB_MREQ,
      SEL     => IBSEL_CPUERR
    );

  proc_ibres : process (IBSEL_CPUERR, IB_MREQ, R_CPUERR)
    variable idout : slv16 := (others=>'0');
  begin
    idout := (others=>'0');
    if IBSEL_CPUERR = '1' then
      idout(cpuerr_ibf_illhlt) := R_CPUERR.illhlt;
      idout(cpuerr_ibf_adderr) := R_CPUERR.adderr;
      idout(cpuerr_ibf_nxm)    := R_CPUERR.nxm;
      idout(cpuerr_ibf_iobto)  := R_CPUERR.iobto;
      idout(cpuerr_ibf_ysv)    := R_CPUERR.ysv;
      idout(cpuerr_ibf_rsv)    := R_CPUERR.rsv;
    end if;
    IB_SRES.dout <= idout;
    IB_SRES.ack  <= IBSEL_CPUERR and (IB_MREQ.re or IB_MREQ.we); -- ack all
    IB_SRES.busy <= '0';
  end process proc_ibres;

  proc_status: process (CLK)
  begin
    if rising_edge(CLK) then
      if GRESET = '1' then
        R_STATUS <= cpustat_init;
        R_CPUERR <= cpuerr_init;
        R_IDSTAT <= decode_stat_init;
        R_VMSTAT <= vm_stat_init;
      else
        R_STATUS <= N_STATUS;
        R_CPUERR <= N_CPUERR;
        R_IDSTAT <= N_IDSTAT;
        R_VMSTAT <= VM_STAT;
      end if;
    end if;
  end process proc_status;

  proc_state: process (CLK)
  begin
    if rising_edge(CLK) then
      if GRESET = '1' then
        R_STATE <= s_idle;
      else
        R_STATE <= N_STATE;
      end if;
    end if;
  end process proc_state;

  proc_next: process (R_STATE, R_STATUS, PSW, PC, CP_CNTL,
                      ID_STAT, R_IDSTAT, IREG, VM_STAT, DP_STAT,
                      R_CPUERR, R_VMSTAT, IB_MREQ, IBSEL_CPUERR,
                      INT_PRI, INT_VECT, ESUSP_I, EBREAK, DBREAK)
    
    variable nstate : state_type;
    variable nstatus : cpustat_type := cpustat_init;
    variable ncpuerr : cpuerr_type := cpuerr_init;

    variable ndpcntl : dpath_cntl_type := dpath_cntl_init;
    variable nvmcntl : vm_cntl_type := vm_cntl_init;
    variable nidstat : decode_stat_type := decode_stat_init;
    variable nmmumoni : mmu_moni_type := mmu_moni_init;
    
    variable imemok : boolean;
    variable bytop : slbit := '0';           -- local bytop  access flag
    variable macc  : slbit := '0';           -- local modify access flag

    variable lvector : slv9_2 := (others=>'0'); -- local trap/interrupt vector
    
    variable brcode : slv4 := (others=>'0'); -- reduced br opcode (15,10-8)
    variable brcond : slbit := '0';          -- br condition value

    variable is_kmode : slbit := '0';        -- cmode is kernel mode
    variable is_dstkstack1246 : slbit := '0'; -- dest is k-stack & mode= 1,2,4,6

    variable int_pending : slbit := '0';     -- an interrupt is pending
    
    alias SRCMOD : slv2 is IREG(11 downto 10); -- src register mode high
    alias SRCDEF : slbit is IREG(9);           -- src register mode defered
    alias SRCREG : slv3 is IREG(8 downto 6);   -- src register number
    alias DSTMODF : slv3 is IREG(5 downto 3);  -- dst register full mode
    alias DSTMOD : slv2 is IREG(5 downto 4);   -- dst register mode high
    alias DSTDEF : slbit is IREG(3);           -- dst register mode defered
    alias DSTREG : slv3 is IREG(2 downto 0);   -- dst register number

    procedure do_memread_i(nstate  : inout state_type;
                           ndpcntl : inout dpath_cntl_type;
                           nvmcntl : inout vm_cntl_type;
                           wstate  : in state_type) is
    begin
      ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc;       -- VA = PC
      nvmcntl.dspace := '0';
      nvmcntl.req := '1';
      ndpcntl.gpr_pcinc := '1';                      -- (pc)++
      nstate := wstate;
    end procedure do_memread_i;
    
    procedure do_memread_d(nstate  : inout state_type;
                           nvmcntl : inout vm_cntl_type;
                           wstate  : in state_type;
                           bytop   : in slbit := '0';
                           macc    : in slbit := '0';
                           is_pci  : in slbit := '0') is
    begin
      nvmcntl.dspace := not is_pci;        -- ispace if pc immediate modes
--      bytop := R_IDSTAT.is_bytop and not is_addr;
      nvmcntl.bytop := bytop;
      nvmcntl.macc  := macc;
      nvmcntl.req   := '1';
      nstate := wstate;
    end procedure do_memread_d;
    
    procedure do_memread_srcinc(nstate   : inout state_type;
                                ndpcntl  : inout dpath_cntl_type;
                                nvmcntl  : inout vm_cntl_type;
                                wstate   : in state_type;
                                nmmumoni : inout mmu_moni_type;
                                updt_sp  : in slbit := '0') is
    begin
      ndpcntl.ounit_asel := c_ounit_asel_dsrc;   -- OUNIT A=DSRC
      ndpcntl.ounit_const := "000000010";        -- OUNIT const=2
      ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const
      ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
      ndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DSRC = DRES
      ndpcntl.dsrc_we := '1';                    -- update DSRC
      if updt_sp = '1' then
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '0';
        ndpcntl.gpr_adst := c_gpr_sp;            -- update SP too
        ndpcntl.gpr_we := '1';
      end if;
      ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
      nvmcntl.dspace := '1';
      nvmcntl.req := '1';
      nstate := wstate;
    end procedure do_memread_srcinc;
    
    procedure do_memwrite(nstate  : inout state_type;
                          nvmcntl : inout vm_cntl_type;
                          wstate  : in state_type;
                          macc    : in slbit :='0') is
    begin
      nvmcntl.dspace := '1';
      nvmcntl.bytop := R_IDSTAT.is_bytop;
      nvmcntl.wacc := '1';
      nvmcntl.macc := macc;
      nvmcntl.req := '1';
      nstate := wstate;
    end procedure do_memwrite;
    
    procedure do_memcheck(nstate  : inout state_type;
                          nstatus : inout cpustat_type;
                          mok     : out boolean) is
    begin
      nstate  := nstate;                -- dummy to add driver (vivado)
      nstatus := nstatus;               -- "
      mok := false;
      if VM_STAT.ack = '1' then
        mok := true;
        nstatus.trap_mmu := VM_STAT.trap_mmu;
        if R_CPUERR.ysv = '0' then      -- ysv trap when cpuerr not yet set
          nstatus.trap_ysv := VM_STAT.trap_ysv;
        end if;
      elsif VM_STAT.err='1' or VM_STAT.fail='1' then
        nstate := s_vmerr;
      end if;
    end procedure do_memcheck;

    procedure do_const_opsize(ndpcntl : inout dpath_cntl_type;
                              bytop   : in slbit;
                              isdef   : in slbit;
                              regnum  : in slv3) is
    begin
      ndpcntl := ndpcntl;               -- dummy to add driver (vivado)
      if bytop='0' or isdef='1' or
         regnum=c_gpr_pc or regnum=c_gpr_sp then
        ndpcntl.ounit_const := "000000010";
      else
        ndpcntl.ounit_const := "000000001";
      end if;
    end procedure do_const_opsize;

    procedure do_fork_dstr(nstate : inout state_type;
                           idstat : in decode_stat_type) is
    begin
      case idstat.fork_dstr is
        when c_fork_dstr_def => nstate := s_dstr_def;
        when c_fork_dstr_inc => nstate := s_dstr_inc;
        when c_fork_dstr_dec => nstate := s_dstr_dec;
        when c_fork_dstr_ind => nstate := s_dstr_ind;
        when others => nstate := s_cpufail;
      end case;
    end procedure do_fork_dstr;

    procedure do_fork_opg(nstate : inout state_type;
                          idstat : in decode_stat_type) is
    begin
      case idstat.fork_opg is
        when c_fork_opg_gen  => nstate := s_opg_gen;
        when c_fork_opg_wdef => nstate := s_dstw_def;
        when c_fork_opg_winc => nstate := s_dstw_inc;
        when c_fork_opg_wdec => nstate := s_dstw_dec;
        when c_fork_opg_wind => nstate := s_dstw_ind;
        when c_fork_opg_mul  => nstate := s_opg_mul;
        when c_fork_opg_div  => nstate := s_opg_div;
        when c_fork_opg_ash  => nstate := s_opg_ash;
        when c_fork_opg_ashc => nstate := s_opg_ashc;
        when others => nstate := s_cpufail;
      end case;
    end procedure do_fork_opg;

    procedure do_fork_opa(nstate : inout state_type;
                          idstat : in decode_stat_type) is
    begin
      case idstat.fork_opa is
        when c_fork_opa_jmp => nstate := s_opa_jmp;
        when c_fork_opa_jsr => nstate := s_opa_jsr;
        when c_fork_opa_mtp => nstate := s_opa_mtp_mem;
        when c_fork_opa_mfp_reg => nstate := s_opa_mfp_reg;
        when c_fork_opa_mfp_mem => nstate := s_opa_mfp_mem;
        when others => nstate := s_cpufail;
      end case;
    end procedure do_fork_opa;

    procedure do_fork_next(nstate   : inout state_type;
                           nstatus  : inout cpustat_type;
                           nmmumoni : inout mmu_moni_type) is
    begin
      nmmumoni.idone := '1';
      if unsigned(INT_PRI) > unsigned(PSW.pri) then
        nstate := s_idle;
      elsif R_STATUS.trap_mmu='1' or nstatus.trap_mmu='1' or
            R_STATUS.trap_ysv='1' or nstatus.trap_ysv='1' or
            PSW.tflag='1' then
        nstate := s_trap_disp;
      elsif R_STATUS.cpugo='1' and        -- running
            R_STATUS.cpususp='0' and      --   and not suspended
            not R_STATUS.cmdbusy='1' then --   and no cmd pending
        nstate := s_ifetch;                               -- fetch next
      else
        nstate := s_idle;                                 -- otherwise idle
      end if;
    end procedure do_fork_next;
    
    procedure do_fork_next_pref(nstate   : inout state_type;
                                nstatus  : inout cpustat_type;
                                ndpcntl  : inout dpath_cntl_type;
                                nvmcntl  : inout vm_cntl_type;
                                nmmumoni : inout mmu_moni_type) is
    begin
      ndpcntl := ndpcntl;               -- dummy to add driver (vivado)
      nvmcntl := nvmcntl;               -- "
      nmmumoni.idone := '1';
      if unsigned(INT_PRI) > unsigned(PSW.pri) then
        nstate := s_idle;
      elsif R_STATUS.trap_mmu='1' or nstatus.trap_mmu='1' or
            R_STATUS.trap_ysv='1' or nstatus.trap_ysv='1' or
            PSW.tflag='1' then
        nstate := s_trap_disp;
      elsif R_STATUS.cpugo='1' and       -- running
            R_STATUS.cpususp='0' and      --   and not suspended
            not R_STATUS.cmdbusy='1' then --   and no cmd pending
        nvmcntl.req := '1';                 -- read next instruction
        ndpcntl.gpr_pcinc := '1';           -- inc PC
        nmmumoni.istart := '1';             -- signal istart to MMU
        nstate := s_ifetch_w;               -- next: wait for fetched instruction
      else
        nstate := s_idle;                   -- otherwise idle
      end if;
    end procedure do_fork_next_pref;
    
    procedure do_start_int(nstate  : inout state_type;
                           ndpcntl : inout dpath_cntl_type;
                           vector  : in slv9_2) is
    begin
      ndpcntl.dtmp_sel := c_dpath_dtmp_psw;    -- DTMP = PSW 
      ndpcntl.dtmp_we := '1';
      ndpcntl.ounit_azero := '1';              -- OUNIT A = 0
      ndpcntl.ounit_const := vector & "00";    -- vector
      ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const(vector)
      ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
      ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
      ndpcntl.dsrc_we := '1';                  -- DSRC = vector
      nstate := s_int_getpc;
    end procedure do_start_int;
    
  begin
    
    nstate  := R_STATE;
    nstatus := R_STATUS;
    ncpuerr := R_CPUERR;

    nstatus.cpuwait := '0';             -- wait flag 0 unless set in s_op_wait

    -- itimer pulse logic:
    --   if neither running nor suspended --> free run, set itimer = 1
    --   otherwise clear to ensure single cycle pulses generated by
    --   s_idecode or s_op_wait
    if R_STATUS.cpugo='0' and R_STATUS.cpususp='0' then
      nstatus.itimer := '1';            
    else
      nstatus.itimer := '0';
    end if;
    
    nstatus.creset := '0';              -- ensure single cycle pulse
    nstatus.breset := '0';              -- dito
    nstatus.intack := '0';              -- dito
    
    nidstat := R_IDSTAT;

    if IBSEL_CPUERR='1' and IB_MREQ.we='1' then -- write to CPUERR clears it !
      ncpuerr := cpuerr_init;
    end if;

    int_pending := '0';
    if unsigned(INT_PRI) > unsigned(PSW.pri) then
      int_pending := '1';
    end if;
    
    imemok := false;

    nmmumoni := mmu_moni_init;
    nmmumoni.pc := PC;
    
    macc  := '0';
    bytop := '0';
    brcode := IREG(15) & IREG(10 downto 8);
    brcond := '1';

    is_kmode := '0';
    is_dstkstack1246 := '0';
    
    if PSW.cmode = c_psw_kmode then
      is_kmode := '1';
      if DSTREG = c_gpr_sp and
         (DSTMODF="001" or DSTMODF="010" or
          DSTMODF="100" or DSTMODF="110") then
        is_dstkstack1246 := '1';
      end if;      
    end if;
      
    lvector := (others=>'0');
    
    nvmcntl := vm_cntl_init;
    nvmcntl.dspace := '1';                -- DEFAULT
    nvmcntl.mode := PSW.cmode;            -- DEFAULT
    nvmcntl.intrsv := R_STATUS.do_intrsv; -- DEFAULT
    
    ndpcntl := dpath_cntl_init;
    ndpcntl.gpr_asrc := SRCREG;           -- DEFAULT
    ndpcntl.gpr_adst := DSTREG;           -- DEFAULT
    ndpcntl.gpr_mode := PSW.cmode;        -- DEFAULT
    ndpcntl.gpr_rset := PSW.rset;         -- DEFAULT
    ndpcntl.gpr_we := '0';                -- DEFAULT
    ndpcntl.gpr_bytop := '0';             -- DEFAULT
    ndpcntl.gpr_pcinc := '0';             -- DEFAULT

    ndpcntl.psr_ccwe := '0';              -- DEFAULT
    ndpcntl.psr_we := '0';                -- DEFAULT
    ndpcntl.psr_func := "000";            -- DEFAULT

    ndpcntl.dsrc_sel := c_dpath_dsrc_src;
    ndpcntl.dsrc_we := '0';
    ndpcntl.ddst_sel := c_dpath_ddst_dst;
    ndpcntl.ddst_we := '0';
    ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;
    ndpcntl.dtmp_we := '0';

    ndpcntl.ounit_asel  := c_ounit_asel_ddst;
    ndpcntl.ounit_azero := '0';            -- DEFAULT
    ndpcntl.ounit_const := (others=>'0');  -- DEFAULT
    ndpcntl.ounit_bsel  := c_ounit_bsel_const;
    ndpcntl.ounit_opsub := '0';            -- DEFAULT

    ndpcntl.aunit_srcmod := R_IDSTAT.aunit_srcmod; -- STATIC
    ndpcntl.aunit_dstmod := R_IDSTAT.aunit_dstmod; -- STATIC
    ndpcntl.aunit_cimod  := R_IDSTAT.aunit_cimod;  -- STATIC
    ndpcntl.aunit_cc1op  := R_IDSTAT.aunit_cc1op;  -- STATIC
    ndpcntl.aunit_ccmode := R_IDSTAT.aunit_ccmode; -- STATIC
    ndpcntl.aunit_bytop  := R_IDSTAT.is_bytop;     -- STATIC

    ndpcntl.lunit_func   := R_IDSTAT.lunit_func;   -- STATIC
    ndpcntl.lunit_bytop  := R_IDSTAT.is_bytop;     -- STATIC

    ndpcntl.munit_func := R_IDSTAT.munit_func;     -- STATIC

    ndpcntl.ireg_we := '0';

    ndpcntl.cres_sel := R_IDSTAT.res_sel;        -- DEFAULT
    ndpcntl.dres_sel := c_dpath_res_ounit;
    ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc;

    if CP_CNTL.req='1' and R_STATUS.cmdbusy='0' then
      nstatus.cmdbusy := '1';
      nstatus.cpfunc  := CP_CNTL.func;
      nstatus.cprnum  := CP_CNTL.rnum;
    end if;
    
    if R_STATUS.cmdack = '1' then
      nstatus.cmdack  := '0';
      nstatus.cmderr  := '0';
      nstatus.cmdmerr := '0';
    end if;
    
    case R_STATE is
      
  -- idle and command port states ---------------------------------------------

      -- Note: s_idle was entered from suspended WAIT when waitsusp='1'
      -- --> all exits must check this and either return to s_op_wait
      --     or abort the WAIT and set waitsusp='0'
      
      when s_idle =>

        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;   -- VA = DDST (do mux early)
        nstatus.cpustep := '0';
        
        if R_STATUS.cmdbusy = '1' then
          case R_STATUS.cpfunc is

            when c_cpfunc_noop =>       -- noop : no operation -------
              nstatus.cmdack   := '1';
              nstate := s_idle;                  

            when c_cpfunc_start =>      -- start : cpu start ---------
              nstatus.cmdack   := '1';
              if R_STATUS.cpugo = '1' then -- if already running
                nstatus.cmderr := '1';       -- reject
              else                         -- if not running
                nstatus.cpugo    := '1';     -- start cpu
                nstatus.cpurust  := c_cpurust_runs;
                nstatus.waitsusp := '0';
              end if;
              nstate := s_idle;                  

            when c_cpfunc_stop =>       -- stop : cpu stop -----------
              nstatus.cmdack   := '1';
              nstatus.cpugo    := '0';
              nstatus.cpurust  := c_cpurust_stop;
              nstatus.waitsusp := '0';
              nstate := s_idle;                  

            when c_cpfunc_step =>       -- step : cpu step -----------
              nstatus.cmdack   := '1';
              nstatus.cpustep  := '1';
              nstatus.cpurust  := c_cpurust_step;
              nstatus.waitsusp := '0';
              if int_pending = '1' then
                nstatus.intack  := '1';
                nstatus.intvect := INT_VECT;
                nstate := s_int_ext;
              else
                nstate := s_ifetch;
              end if;

            when c_cpfunc_creset =>     -- creset : cpu reset --------
              nstatus.cmdack   := '1';
              if R_STATUS.cpugo = '1' then -- if already running
                nstatus.cmderr := '1';       -- reject
              else                         -- if not running
                nstatus.creset  := '1';      --  do cpu reset
                nstatus.breset  := '1';      -- and bus reset !
                nstatus.suspint := '0';      -- clear suspend
                nstatus.cpurust := c_cpurust_init;
              end if;
              nstate := s_idle;                  

            when c_cpfunc_breset =>     -- breset : bus reset --------
              nstatus.cmdack   := '1';
              if R_STATUS.cpugo = '1' then -- if already running
                nstatus.cmderr := '1';       -- reject
              else                         -- if not running
                nstatus.breset := '1';        -- do bus reset only
              end if;
              nstate := s_idle;                  

            when c_cpfunc_suspend =>    -- suspend : cpu suspend -----
              nstatus.cmdack   := '1';
              nstatus.suspint  := '1';
              nstatus.cpurust  := c_cpurust_susp;
              nstate := s_idle;                  

            when c_cpfunc_resume =>     -- resume : cpu resume -------
              nstatus.cmdack   := '1';
              nstatus.suspint  := '0';
              if R_STATUS.cpugo = '1' then
                nstatus.cpurust  := c_cpurust_runs;
              else
                nstatus.cpurust  := c_cpurust_stop;
              end if;  
              nstate := s_idle;                  

            when c_cpfunc_rreg =>       -- rreg : read register ------
              ndpcntl.gpr_adst := R_STATUS.cprnum;
              ndpcntl.ddst_sel := c_dpath_ddst_dst;
              ndpcntl.ddst_we := '1';
              nstate := s_cp_regread;

            when c_cpfunc_wreg =>       -- wreg : write register -----
              ndpcntl.dres_sel := c_dpath_res_cpdin;  -- DRES = CPDIN
              ndpcntl.gpr_adst := R_STATUS.cprnum;
              ndpcntl.gpr_we := '1';
              nstatus.cmdack := '1';
              nstate := s_idle;

            when c_cpfunc_rpsw =>       -- rpsw : read psw -----------
              ndpcntl.dtmp_sel := c_dpath_dtmp_psw;   -- DTMP = PSW 
              ndpcntl.dtmp_we := '1';
              nstate := s_cp_rps;

            when c_cpfunc_wpsw =>       -- wpsw : write psw ----------
              ndpcntl.dres_sel := c_dpath_res_cpdin;  -- DRES = CPDIN
              ndpcntl.psr_func := c_psr_func_wall;    -- write all fields
              ndpcntl.psr_we := '1';                  -- load new PS
              nstatus.cmdack := '1';
              nstate := s_idle;

            when c_cpfunc_rmem =>       -- rmem : read memory --------
              nvmcntl.cacc := '1';
              nvmcntl.req  := '1';
              nstate := s_cp_memr_w;
              
            when c_cpfunc_wmem =>       -- wmem : write memory -------
              ndpcntl.dres_sel := c_dpath_res_cpdin;     -- DRES = CPDIN
              nvmcntl.wacc := '1';                       -- write mem
              nvmcntl.cacc := '1';
              nvmcntl.req  := '1';
              nstate := s_cp_memw_w;

            when others => 
              nstatus.cmdack := '1';
              nstatus.cmderr := '1';
              nstate := s_idle;

          end case;

        elsif R_STATUS.waitsusp = '1' then
          nstatus.waitsusp := '0';
          nstate := s_op_wait;          

        elsif R_STATUS.cpugo = '1' and    -- running
              R_STATUS.cpususp='0' then   --   and not suspended
          if int_pending = '1' then         -- interrupt pending
            nstatus.intack  := '1';           -- acknowledle it
            nstatus.intvect := INT_VECT;      -- latch vector address
            nstate := s_int_ext;              -- and handle
          else
            nstate := s_ifetch;               -- otherwise fetch intruction
          end if;
          
        end if;

      when s_cp_regread =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst;  -- OUNIT A = DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel  := c_dpath_res_ounit;   -- DRES = OUNIT
        nstatus.cmdack := '1';
        nstate := s_idle;
        
      when s_cp_rps =>
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel  := c_dpath_res_ounit;   -- DRES = OUNIT
        nstatus.cmdack := '1';
        nstate := s_idle;

      when s_cp_memr_w =>
        nstate := s_cp_memr_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        if (VM_STAT.ack or VM_STAT.err or VM_STAT.fail)='1' then
          nstatus.cmdack   := '1';
          nstatus.trap_ysv := '0';               -- suppress traps on console
          nstatus.trap_mmu := '0';
          nstatus.cmdmerr  := VM_STAT.err or VM_STAT.fail;
          nstate := s_idle;
        end if;

      when s_cp_memw_w =>
        nstate := s_cp_memw_w;
        if (VM_STAT.ack or VM_STAT.err or VM_STAT.fail)='1' then
          nstatus.cmdack   := '1';
          nstatus.trap_ysv := '0';               -- suppress traps on console
          nstatus.trap_mmu := '0';
          nstatus.cmdmerr  := VM_STAT.err or VM_STAT.fail;
          nstate := s_idle;
        end if;
        
  -- instruction fetch and decode ---------------------------------------------

      when s_ifetch =>
        nmmumoni.istart := '1';         -- do here; memread_i inc PC ! 
        do_memread_i(nstate, ndpcntl, nvmcntl, s_ifetch_w);
        
      when s_ifetch_w =>
        nstate := s_ifetch_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ireg_we := '1';
          nstate := s_idecode;
        end if;
        
      when s_idecode =>
        nstatus.itimer := '1';          -- signal instruction started
        nidstat := ID_STAT;             -- register decode status
        if ID_STAT.force_srcsp = '1' then
          ndpcntl.gpr_asrc := c_gpr_sp;
        end if;
        ndpcntl.dsrc_sel := c_dpath_dsrc_src;
        ndpcntl.dsrc_we := '1';
        ndpcntl.ddst_sel := c_dpath_ddst_dst;
        ndpcntl.ddst_we := '1';

        nvmcntl.dspace := '0';
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc;       -- VA = PC
        
        if ID_STAT.do_pref_dec='1' and PSW.tflag='0' and int_pending='0' and
           R_STATUS.cpugo='1' and R_STATUS.cpususp='0' and
           not R_STATUS.cmdbusy='1'
        then          
          nvmcntl.req := '1';
          ndpcntl.gpr_pcinc := '1';                    -- (pc)++
          nmmumoni.istart := '1';
          nstatus.prefdone := '1';
        end if;
        
        if ID_STAT.do_fork_op = '1' then
          case ID_STAT.fork_op is
            when c_fork_op_halt => nstate := s_op_halt;
            when c_fork_op_wait => nstate := s_op_wait;
            when c_fork_op_rtti => nstate := s_rti_getpc;
            when c_fork_op_trap => nstate := s_op_trap;
            when c_fork_op_reset=> nstate := s_op_reset;
            when c_fork_op_rts  => nstate := s_op_rts;
            when c_fork_op_spl  => nstate := s_op_spl;
            when c_fork_op_mcc  => nstate := s_op_mcc;
            when c_fork_op_br   => nstate := s_op_br;
            when c_fork_op_mark => nstate := s_op_mark;
            when c_fork_op_sob  => nstate := s_op_sob;
            when c_fork_op_mtp  => nstate := s_opa_mtp;
            when others => nstate := s_cpufail;
          end case;
        elsif ID_STAT.do_fork_srcr = '1' then
          case ID_STAT.fork_srcr is
            when c_fork_srcr_def => nstate := s_srcr_def;
            when c_fork_srcr_inc => nstate := s_srcr_inc;
            when c_fork_srcr_dec => nstate := s_srcr_dec;
            when c_fork_srcr_ind => nstate := s_srcr_ind;
            when others => nstate := s_cpufail;
          end case;
        elsif ID_STAT.do_fork_dstr = '1' then
          do_fork_dstr(nstate, ID_STAT);
        elsif ID_STAT.do_fork_dsta = '1' then
          case ID_STAT.fork_dsta is         -- 2nd dsta fork in s_opa_mtp_pop_w
            when c_fork_dsta_def => do_fork_opa(nstate, ID_STAT);
            when c_fork_dsta_inc => nstate := s_dsta_inc;
            when c_fork_dsta_dec => nstate := s_dsta_dec;
            when c_fork_dsta_ind => nstate := s_dsta_ind;
            when others => nstate := s_cpufail;
          end case;
        elsif ID_STAT.do_fork_opg = '1' then
          do_fork_opg(nstate, ID_STAT);
        elsif ID_STAT.is_res = '1' then
          nstate := s_trap_10;           -- do trap 10;
        else
          nstate := s_cpufail;           -- catch mistakes here...
        end if;

  -- source read states -------------------------------------------------------
  --   flows:
  --     1  (r)    s_srcr_def           req (r)
  --               s_srcr_def_w         get (r)
  --               -> do_fork_dstr or do_fork_opg
  --              
  --     2  (r)+   s_srcr_inc           req (r); r+=s
  --               s_srcr_inc_w         get (r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     3  @(r)+  s_srcr_inc           req (r); r+=s
  --               s_srcr_inc_w         get (r)
  --               s_srcr_def           req @(r)
  --               s_srcr_def_w         get @(r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     4  -(r)   s_srcr_dec           r-=s
  --               s_srcr_dec1          req (r)
  --               s_srcr_inc_w         get (r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     5  @-(r)  s_srcr_dec           r-=s
  --               s_srcr_dec1          req (r)
  --               s_srcr_inc_w         get (r)
  --               s_srcr_def           req @(r)
  --               s_srcr_def_w         get @(r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     6  n(r)   s_srcr_ind           req n
  --               s_srcr_ind1_w        get n; ea=r+n
  --               s_srcr_ind2          req n(r)
  --               s_srcr_ind2_w        get n(r)
  --               -> do_fork_dstr or do_fork_opg
  --
  --     7  @n(r)  s_srcr_ind           req n
  --               s_srcr_ind1_w        get n; ea=r+n
  --               s_srcr_ind2          req n(r)
  --               s_srcr_ind2_w        get n(r)
  --               s_srcr_def           req @n(r)
  --               s_srcr_def_w         get @n(r)
  --               -> do_fork_dstr or do_fork_opg
        
      when s_srcr_def =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        do_memread_d(nstate, nvmcntl, s_srcr_def_w,
                     bytop=>R_IDSTAT.is_bytop,
                     is_pci=>R_IDSTAT.is_srcpcmode1);

      when s_srcr_def_w =>
        nstate := s_srcr_def_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          if R_IDSTAT.do_fork_dstr = '1' then
            do_fork_dstr(nstate, R_IDSTAT);
          else
            do_fork_opg(nstate, R_IDSTAT);
          end if;
        end if;

      when s_srcr_inc =>
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, SRCDEF, SRCREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gpr_adst := SRCREG;
        ndpcntl.gpr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '0';
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES (for if)
        if DSTREG = SRCREG then                  -- prevent stale DDST copy 
          ndpcntl.ddst_we := '1';                -- update DDST
        end if;
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        bytop := R_IDSTAT.is_bytop and not SRCDEF;
        do_memread_d(nstate, nvmcntl, s_srcr_inc_w,
                     bytop=>bytop, is_pci=>R_IDSTAT.is_srcpc);
        
      when s_srcr_inc_w =>
        nstate := s_srcr_inc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          if SRCDEF = '1' then
            nstate := s_srcr_def;
          else
            if R_IDSTAT.do_fork_dstr = '1' then
              do_fork_dstr(nstate, R_IDSTAT);
            else
              do_fork_opg(nstate, R_IDSTAT);
            end if;
          end if;
        end if;
        
      when s_srcr_dec =>
        ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A=DSRC
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, SRCDEF, SRCREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                  -- update DSRC
        ndpcntl.gpr_adst := SRCREG;
        ndpcntl.gpr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES (for if)
        if DSTREG = SRCREG then                  -- prevent stale DDST copy
          ndpcntl.ddst_we := '1';                -- update DDST
        end if;
        nstate := s_srcr_dec1;

      when s_srcr_dec1 =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        bytop := R_IDSTAT.is_bytop and not SRCDEF;
        do_memread_d(nstate, nvmcntl, s_srcr_inc_w, bytop=>bytop);

      when s_srcr_ind =>
        do_memread_i(nstate, ndpcntl, nvmcntl, s_srcr_ind1_w);

      when s_srcr_ind1_w =>
        nstate := s_srcr_ind1_w;
        if R_IDSTAT.is_srcpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A = DSRC
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout; -- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.ddst_sel := c_dpath_ddst_dst;    -- DDST = R(DST)
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          ndpcntl.ddst_we := '1';                -- update DDST (to reload PC)
          nstate := s_srcr_ind2;
        end if;

      when s_srcr_ind2 =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        bytop := R_IDSTAT.is_bytop and not SRCDEF;
        do_memread_d(nstate, nvmcntl, s_srcr_ind2_w, bytop=>bytop);

      when s_srcr_ind2_w =>
        nstate := s_srcr_ind2_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          if SRCDEF = '1' then
            nstate := s_srcr_def;
          else
            if R_IDSTAT.do_fork_dstr = '1' then
              do_fork_dstr(nstate, R_IDSTAT);
            else
              do_fork_opg(nstate, R_IDSTAT);
            end if;
          end if;
        end if;
        
  -- destination read states --------------------------------------------------
  --   flows:
  --     1  (r)    s_dstr_def           req (r) (rmw if rmw op)
  --               s_dstr_def_w         get (r)
  --               -> do_fork_opg
  --              
  --     2  (r)+   s_dstr_inc           req (r); r+=s (rmw if rmw op)
  --               s_dstr_inc_w         get (r)
  --               -> do_fork_opg
  --
  --     3  @(r)+  s_dstr_inc           req (r); r+=s
  --               s_dstr_inc_w         get (r)
  --               s_dstr_def           req @(r) (rmw if rmw op)
  --               s_dstr_def_w         get @(r)
  --               -> do_fork_opg
  --
  --     4  -(r)   s_dstr_dec           r-=s
  --               s_dstr_dec1          req (r) (rmw if rmw op)
  --               s_dstr_inc_w         get (r)
  --               -> do_fork_opg
  --
  --     5  @-(r)  s_dstr_dec           r-=s
  --               s_dstr_dec1          req (r)
  --               s_dstr_inc_w         get (r)
  --               s_dstr_def           req @(r) (rmw if rmw op)
  --               s_dstr_def_w         get @(r)
  --               -> do_fork_opg
  --
  --     6  n(r)   s_dstr_ind           req n
  --               s_dstr_ind1_w        get n; ea=r+n
  --               s_dstr_ind2          req n(r) (rmw if rmw op)
  --               s_dstr_ind2_w        get n(r)
  --               -> do_fork_opg
  --
  --     7  @n(r)  s_dstr_ind           req n
  --               s_dstr_ind1_w        get n; ea=r+n
  --               s_dstr_ind2          req n(r)
  --               s_dstr_ind2_w        get n(r)
  --               s_dstr_def           req @n(r) (rmw if rmw op)
  --               s_dstr_def_w         get @n(r)
  --               -> do_fork_opg

      when s_dstr_def =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        do_memread_d(nstate, nvmcntl, s_dstr_def_w,
                     bytop=>R_IDSTAT.is_bytop, macc=>R_IDSTAT.is_rmwop);

      when s_dstr_def_w =>
        nstate := s_dstr_def_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          do_fork_opg(nstate, R_IDSTAT);
        end if;

      when s_dstr_inc =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gpr_adst := DSTREG;
        ndpcntl.gpr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '0';
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        macc  := R_IDSTAT.is_rmwop and not DSTDEF;
        bytop := R_IDSTAT.is_bytop and not DSTDEF;
        do_memread_d(nstate, nvmcntl, s_dstr_inc_w,
                     bytop=>bytop, macc=>macc, is_pci=>R_IDSTAT.is_dstpc);
        
      when s_dstr_inc_w =>
        nstate := s_dstr_inc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          if DSTDEF = '1' then
            nstate := s_dstr_def;
          else
            do_fork_opg(nstate, R_IDSTAT);
          end if;
        end if;
        
      when s_dstr_dec =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        ndpcntl.ddst_we := '1';                  -- update DDST
        ndpcntl.gpr_adst := DSTREG;
        ndpcntl.gpr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_dstr_dec1;

      when s_dstr_dec1 =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        macc  := R_IDSTAT.is_rmwop and not DSTDEF;
        bytop := R_IDSTAT.is_bytop and not DSTDEF;
        do_memread_d(nstate, nvmcntl, s_dstr_inc_w,
                     bytop=>bytop, macc=>macc);

      when s_dstr_ind =>
        do_memread_i(nstate, ndpcntl, nvmcntl, s_dstr_ind1_w);

      when s_dstr_ind1_w =>
        nstate := s_dstr_ind1_w;
        if R_IDSTAT.is_dstpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout;-- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dstr_ind2;
        end if;

      when s_dstr_ind2 =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        macc  := R_IDSTAT.is_rmwop and not DSTDEF;
        bytop := R_IDSTAT.is_bytop and not DSTDEF;
        do_memread_d(nstate, nvmcntl, s_dstr_ind2_w,
                     bytop=>bytop, macc=>macc);

      when s_dstr_ind2_w =>
        nstate := s_dstr_ind2_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          if DSTDEF = '1' then
            nstate := s_dstr_def;
          else
            do_fork_opg(nstate, R_IDSTAT);
          end if;
        end if;
        
  -- destination write states -------------------------------------------------
  --   flows:
  --     1  (r)    s_dstw_def           wreq (r)            check kstack
  --               s_dstw_def_w         ack  (r)
  --               -> do_fork_next
  --              
  --     2  (r)+   s_dstw_inc           wreq (r)            check kstack
  --               s_dstw_inc_w         ack  (r); r+=s
  --               -> do_fork_next
  --
  --     3  @(r)+  s_dstw_inc           rreq (r); r+=s
  --               s_dstw_incdef_w      get  (r)
  --               s_dstw_def246        wreq @(r)
  --               s_dstw_def_w         ack  @(r)
  --               -> do_fork_next
  --
  --     4  -(r)   s_dstw_dec           r-=s
  --               s_dstw_dec1          wreq (r)            check kstack
  --               s_dstw_def_w         ack  (r)
  --               -> do_fork_next
  --
  --     5  @-(r)  s_dstw_dec           r-=s
  --               s_dstw_dec1          rreq (r)
  --               s_dstw_incdef_w      get  (r)
  --               s_dstw_def246        wreq @(r)
  --               s_dstw_def_w         ack  @(r)
  --               -> do_fork_next
  --
  --     6  n(r)   s_dstw_ind           rreq n
  --               s_dstw_ind_w         get  n; ea=r+n
  --               s_dstw_dec1          wreq n(r)           check kstack
  --               s_dstw_def_w         ack  n(r)
  --               -> do_fork_next
  --
  --     7  @n(r)  s_dstw_ind           rreq n
  --               s_dstw_ind_w         get  n; ea=r+n
  --               s_dstw_dec1          rreq n(r)
  --               s_dstw_incdef_w      get  n(r)
  --               s_dstw_def246        wreq @n(r)
  --               s_dstw_def_w         ack  @n(r)
  --               -> do_fork_next
        
      when s_dstw_def =>
        ndpcntl.psr_ccwe := '1';
        ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = choice of idec
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        nvmcntl.kstack := is_dstkstack1246;
        do_memwrite(nstate, nvmcntl, s_dstw_def_w);
        
      when s_dstw_def_w =>
        nstate := s_dstw_def_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;

      when s_dstw_inc =>
        ndpcntl.psr_ccwe := '1';
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;   -- VA = DDST
        ndpcntl.ounit_asel := c_ounit_asel_ddst;     -- OUNIT A=DDST  (for else)
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);  --(...)
        ndpcntl.ounit_bsel := c_ounit_bsel_const;    -- OUNIT B=const (for else)
        if DSTDEF = '0' then
          ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = choice of idec
          nvmcntl.kstack := is_dstkstack1246;
          do_memwrite(nstate, nvmcntl, s_dstw_inc_w);
          nstatus.do_gprwe := '1';
        else
          ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
          ndpcntl.gpr_adst := DSTREG;
          ndpcntl.gpr_we := '1';
          nmmumoni.regmod := '1';
          nmmumoni.isdec := '0';
          do_memread_d(nstate, nvmcntl, s_dstw_incdef_w,
                       is_pci=>R_IDSTAT.is_dstpc);
        end if;
        
      when s_dstw_inc_w =>
        nstate := s_dstw_inc_w;
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gpr_adst := DSTREG;
        if R_STATUS.do_gprwe = '1' then
          nmmumoni.regmod := '1';
          nmmumoni.isdec := '0';
          nmmumoni.trace_prev := '1';              -- ssr freeze of prev state
          ndpcntl.gpr_we := '1';                   -- update DST reg
        end if;
        nstatus.do_gprwe := '0';
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;

      when s_dstw_incdef_w =>
        nstate := s_dstw_incdef_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dstw_def246;
        end if;

      when s_dstw_dec =>
        ndpcntl.psr_ccwe := '1';
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        do_const_opsize(ndpcntl, R_IDSTAT.is_bytop, DSTDEF, DSTREG);
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        ndpcntl.ddst_we := '1';                  -- update DDST
        ndpcntl.gpr_adst := DSTREG;
        ndpcntl.gpr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_dstw_dec1;
        
      when s_dstw_dec1 =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = from idec (for if)
        if DSTDEF = '0' then
          nvmcntl.kstack := is_dstkstack1246;
          do_memwrite(nstate, nvmcntl, s_dstw_def_w);
        else
          do_memread_d(nstate, nvmcntl, s_dstw_incdef_w);
        end if;          

      when s_dstw_ind =>
        ndpcntl.psr_ccwe := '1';
        do_memread_i(nstate, ndpcntl, nvmcntl, s_dstw_ind_w);

      when s_dstw_ind_w =>
        nstate := s_dstw_ind_w;
        if R_IDSTAT.is_dstpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout;-- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dstw_dec1;
        end if;        

      when s_dstw_def246 =>
        ndpcntl.dres_sel := R_IDSTAT.res_sel;      -- DRES = choice of idec
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        do_memwrite(nstate, nvmcntl, s_dstw_def_w);

  -- destination address states -----------------------------------------------
  --   flows:
  --     1  (r)    -> do_fork_opa
  --              
  --     2  (r)+   s_dsta_inc           r+=2
  --               -> do_fork_opa
  --
  --     3  @(r)+  s_dsta_inc           req (r); r+=s
  --               s_dsta_incdef_w      get (r)
  --               -> do_fork_opa
  --
  --     4  -(r)   s_dsta_dec           r-=s
  --               s_dsta_dec1          ?? FIXME ?? what is done here ??
  --               -> do_fork_opa
  --
  --     5  @-(r)  s_dsta_dec           r-=s
  --               s_dsta_dec1          req (r)
  --               s_dsta_incdef_w      get (r)
  --               -> do_fork_opa
  --
  --     6  n(r)   s_dsta_ind           req n
  --               s_dsta_ind_w         get n; ea=r+n
  --               s_dsta_dec1          ?? FIXME ?? what is done here ??
  --               -> do_fork_opa
  --
  --     7  @n(r)  s_dsta_ind           req n
  --               s_dsta_ind_w         get n; ea=r+n
  --               s_dsta_dec1          req n(r)
  --               s_dsta_incdef_w      get n(r)
  --               -> do_fork_opa

      when s_dsta_inc =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(2)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gpr_adst := DSTREG;
        ndpcntl.gpr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '0';
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DSRC = DRES (for if)
        if R_IDSTAT.updt_dstadsrc = '1' then       -- prevent stale DSRC copy 
          ndpcntl.dsrc_we := '1';                    -- update DSRC
        end if;
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        if DSTDEF = '0' then
          do_fork_opa(nstate, R_IDSTAT);
        else
          do_memread_d(nstate, nvmcntl, s_dsta_incdef_w,
                       is_pci=>R_IDSTAT.is_dstpc);          
        end if;
          
      when s_dsta_incdef_w =>
        nstate := s_dsta_incdef_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          do_fork_opa(nstate, R_IDSTAT);
        end if;    
    
      when s_dsta_dec =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A=DDST
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const(2)
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        ndpcntl.ddst_we := '1';                  -- update DDST
        ndpcntl.gpr_adst := DSTREG;
        ndpcntl.gpr_we := '1';
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES (for if)
        if R_IDSTAT.updt_dstadsrc = '1' then     -- prevent stale DSRC copy 
          ndpcntl.dsrc_we := '1';                -- update DSRC
        end if;
        nstate := s_dsta_dec1;
        
      when s_dsta_dec1 =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst; -- VA = DDST
        if DSTDEF = '0' then                       -- check here used also by
          do_fork_opa(nstate, R_IDSTAT);           -- s_dsta_ind flow !!
        else
          do_memread_d(nstate, nvmcntl, s_dsta_incdef_w);
        end if;          

      when s_dsta_ind =>
        do_memread_i(nstate, ndpcntl, nvmcntl, s_dsta_ind_w);
        
      when s_dsta_ind_w =>
        nstate := s_dsta_ind_w;
        if R_IDSTAT.is_dstpc = '0' then
          ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        else
          ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC (for nn(pc))
        end if;
        ndpcntl.ounit_bsel := c_ounit_bsel_vmdout;-- OUNIT B = VMDOUT
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                -- update DDST
          nstate := s_dsta_dec1;
        end if;
        
  -- instruction operate states -----------------------------------------------

      when s_op_halt =>                 -- HALT
        if is_kmode = '1' then          -- if in kernel mode execute
          nmmumoni.idone := '1';
          nstatus.cpugo := '0';
          nstatus.cpurust := c_cpurust_halt;
          nstate := s_idle;
        else                            -- otherwise trap
          ncpuerr.illhlt := '1';
          nstate := s_trap_4;           -- trap 4 like 11/70
        end if;

      when s_op_wait =>                 -- WAIT
        ndpcntl.gpr_asrc := "000";      -- load R0 in DSRC for DR emulation
        ndpcntl.dsrc_sel := c_dpath_dsrc_src;
        ndpcntl.dsrc_we := '1';
         
        nstate := s_op_wait;            -- spin here
        if is_kmode = '0' then          -- but act as nop if not in kernel
          nstate := s_idle;
        elsif int_pending = '1' or      -- bail out if pending interrupt
          R_STATUS.cpustep='1' then     --  or the instruction is only stepped
          nstate := s_idle;
        elsif R_STATUS.cmdbusy = '1' then -- suspend if a cp command is pending
          nstatus.waitsusp := '1';
          nstate := s_idle;
        else
          nstatus.cpuwait := '1';       -- if spinning here, signal with cpuwait
          nstatus.itimer  := '1';       -- itimer will stay 1 during a WAIT
       end if;

      when s_op_trap =>                 -- traps
        lvector := "0000" & R_IDSTAT.trap_vec; -- vector
        do_start_int(nstate, ndpcntl, lvector);
        
      when s_op_reset =>                -- RESET
        if is_kmode = '1' then          -- if in kernel mode execute
          nstatus.breset := '1';          -- issue bus reset
        end if;
        nstate := s_idle;
        
      when s_op_rts =>                  -- RTS
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gpr_adst := c_gpr_pc;
        ndpcntl.gpr_we := '1';                     -- load PC with reg(dst)
        nstate := s_op_rts_pop;

      when s_op_rts_pop =>
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_op_rts_pop_w,
                          nmmumoni, updt_sp=>'1');
        
      when s_op_rts_pop_w =>
        nstate := s_op_rts_pop_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.gpr_adst := DSTREG;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then          
          ndpcntl.gpr_we := '1';                  -- load R with (SP)+
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;
        
      when s_op_spl =>                  -- SPL
        ndpcntl.dres_sel := c_dpath_res_ireg;    -- DRES = IREG
        ndpcntl.psr_func := c_psr_func_wspl;
        if is_kmode = '1' then                   -- active only in kernel mode
          ndpcntl.psr_we := '1';
          nstate := s_ifetch;                    -- unconditionally fetch next
                                                 -- instruction like a 11/70
                                                 -- no interrupt recognition !
        else
          do_fork_next(nstate, nstatus, nmmumoni);  -- in non-kernel, noop
        end if;

      when s_op_mcc =>                  -- CLx/SEx
        ndpcntl.dres_sel := c_dpath_res_ireg;    -- DRES = IREG
        ndpcntl.psr_func := c_psr_func_wcc;
        ndpcntl.psr_we := '1';
        do_fork_next(nstate, nstatus, nmmumoni);
        
      when s_op_br =>                   -- BR
        nvmcntl.dspace := '0';                   -- prepare do_fork_next_pref
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc; -- VA = PC
        ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC
        ndpcntl.ounit_bsel := c_ounit_bsel_ireg8;-- OUNIT B = IREG8
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        -- note: cc are NZVC
        case brcode(3 downto 1) is
          when "000" =>                 -- BR
            brcond := '1';
          when "001" =>                 -- BNE/BEQ: if Z = x
            brcond := PSW.cc(2);
          when "010" =>                 -- BGE/BLT: if N xor V = x
            brcond := PSW.cc(3) xor PSW.cc(1);
          when "011" =>                 -- BGT/BLE: if Z or (N xor V) = x
            brcond := PSW.cc(2) or (PSW.cc(3) xor PSW.cc(1));
          when "100" =>                 -- BPL/BMI: if N = x
            brcond := PSW.cc(3);
          when "101" =>                 -- BHI/BLOS:if C or Z = x
            brcond := PSW.cc(2) or PSW.cc(0);
          when "110" =>                 -- BVC/BVS: if V = x
            brcond := PSW.cc(1);
          when "111" =>                 -- BCC/BCS: if C = x
            brcond := PSW.cc(0);
          when others => null;
        end case;

        ndpcntl.gpr_adst := c_gpr_pc;
        if brcond = brcode(0) then      -- this coding creates redundant code
          ndpcntl.gpr_we := '1';        --   but synthesis optimizes this way !
          do_fork_next(nstate, nstatus, nmmumoni);
        else
          do_fork_next_pref(nstate, nstatus, ndpcntl, nvmcntl, nmmumoni);
        end if;
        
      when s_op_mark =>                 -- MARK 
        ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC
        ndpcntl.ounit_bsel := c_ounit_bsel_ireg6;-- OUNIT B = IREG6
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                  -- update DSRC (with PC+2*nn)
        ndpcntl.gpr_adst := c_gpr_r5;            -- fetch r5
        ndpcntl.ddst_sel := c_dpath_ddst_dst;
        ndpcntl.ddst_we := '1';
        nstate := s_op_mark1;

      when s_op_mark1 =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst; -- OUNIT A = DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gpr_adst := c_gpr_pc;
        ndpcntl.gpr_we := '1';                   -- load PC with r5
        nstate := s_op_mark_pop;

      when s_op_mark_pop =>
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_op_mark_pop_w,
                          nmmumoni, updt_sp=>'1');

      when s_op_mark_pop_w =>
        nstate := s_op_mark_pop_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.gpr_adst := c_gpr_r5;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then          
          ndpcntl.gpr_we := '1';                 -- load R5 with (sp)+
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;
        
      when s_op_sob =>                  -- SOB (dec)
        -- comment fork_next_pref out (blog 2006-10-02) due to synthesis impact
        --nvmcntl.dspace := '0';                   -- prepare do_fork_next_pref
        --ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc; -- VA = PC
        ndpcntl.dres_sel := R_IDSTAT.res_sel;
        ndpcntl.gpr_adst := SRCREG;
        ndpcntl.gpr_we := '1';

        if DP_STAT.ccout_z = '0' then   -- if z=0 branch, if z=1 fall thru
          nstate := s_op_sob1;
        else
          --do_fork_next_pref(nstate, ndpcntl, nvmcntl, nmmumoni);
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;
        
      when s_op_sob1 =>                 -- SOB (br) 
        ndpcntl.ounit_asel := c_ounit_asel_pc;   -- OUNIT A = PC
        ndpcntl.ounit_bsel := c_ounit_bsel_ireg6;-- OUNIT B = IREG6
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A - B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gpr_adst := c_gpr_pc;
        ndpcntl.gpr_we := '1';
        do_fork_next(nstate, nstatus, nmmumoni);

      when s_opg_gen =>
        nvmcntl.dspace := '0';                   -- prepare do_fork_next_pref
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc; -- VA = PC
        ndpcntl.gpr_bytop := R_IDSTAT.is_bytop;
        ndpcntl.dres_sel := R_IDSTAT.res_sel;    -- DRES = choice of idec
        
        if R_IDSTAT.op_mov = '1' then            -- in case of MOV xx,R
          ndpcntl.gpr_bytop := '0';              --  no bytop, do sign extend
        end if;

        ndpcntl.psr_ccwe := '1';

        if R_IDSTAT.is_dstw_reg = '1' then
          ndpcntl.gpr_we := '1';
        end if;

        if R_IDSTAT.is_rmwop = '1' then
          do_memwrite(nstate, nvmcntl, s_opg_gen_rmw_w, macc=>'1');
        else           
          if R_STATUS.prefdone = '1' then
            nstatus.prefdone :='0';
            nstate := s_ifetch_w;
            do_memcheck(nstate, nstatus, imemok);
            if imemok then
              ndpcntl.ireg_we := '1';
              nstate := s_idecode;
            end if;
          else
            if R_IDSTAT.is_dstw_pc = '1' then
              nstate := s_idle;
            else
              do_fork_next_pref(nstate, nstatus, ndpcntl, nvmcntl, nmmumoni);
            end if;      
          end if;
        end if;           

      when s_opg_gen_rmw_w =>
        nstate := s_opg_gen_rmw_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;

      when s_opg_mul =>                 -- MUL (oper)
        ndpcntl.dres_sel := R_IDSTAT.res_sel;   -- DRES = choice of idec
        ndpcntl.gpr_adst := SRCREG;             -- write high order result
        ndpcntl.gpr_we := '1';
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;   -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                 -- capture high order part
        ndpcntl.dtmp_sel := c_dpath_dtmp_drese; -- DTMP = DRESE
        ndpcntl.dtmp_we := '1';                 -- capture low order part
        nstate := s_opg_mul1;
        
      when s_opg_mul1 =>                -- MUL (write odd reg)
        ndpcntl.ounit_asel := c_ounit_asel_dtmp; -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gpr_adst := SRCREG(2 downto 1) & "1";-- write odd reg !
        ndpcntl.gpr_we := '1';
        ndpcntl.psr_ccwe := '1';
        do_fork_next(nstate, nstatus, nmmumoni);
        
      when s_opg_div =>                 -- DIV (load dd_low)
        ndpcntl.munit_s_div := '1';
        ndpcntl.gpr_asrc := SRCREG(2 downto 1) & "1";-- read odd reg !
        ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;
        ndpcntl.dtmp_we := '1';
        nstate := s_opg_div_cn;

      when s_opg_div_cn =>              -- DIV (1st...16th cycle)
        ndpcntl.munit_s_div_cn := '1';
        ndpcntl.dres_sel := R_IDSTAT.res_sel;     -- DRES = choice of idec
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.dtmp_sel := c_dpath_dtmp_drese;   -- DTMP = DRESE
        nstate := s_opg_div_cn;
        if DP_STAT.div_quit = '1' then
          nstate := s_opg_div_quit;
        else
          ndpcntl.dsrc_we := '1';                 -- update DSRC
          ndpcntl.dtmp_we := '1';                 -- update DTMP
        end if;
        if DP_STAT.shc_tc = '1' then
          nstate := s_opg_div_cr;
        end if;

      when s_opg_div_cr =>              -- DIV (remainder correction)
        ndpcntl.munit_s_div_cr := '1';
        ndpcntl.dres_sel := R_IDSTAT.res_sel;     -- DRES = choice of idec
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.dsrc_we := DP_STAT.div_cr;        -- update DSRC
        nstate := s_opg_div_sq;
        
      when s_opg_div_sq =>              -- DIV (correct and store quotient)
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A=DTMP
        ndpcntl.ounit_const := "00000000"&DP_STAT.div_cq;-- OUNIT const = Q corr.
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const (q cor)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gpr_adst := SRCREG;               -- write result
        ndpcntl.gpr_we := '1';
        ndpcntl.dtmp_sel := c_dpath_dtmp_dres;    -- DTMP = DRES
        ndpcntl.dtmp_we := '1';                   -- update DTMP (Q)
        nstate := s_opg_div_sr;

      when s_opg_div_sr =>              -- DIV (store remainder)
        ndpcntl.munit_s_div_sr := '1';
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gpr_adst := SRCREG(2 downto 1) & "1";-- write odd reg !
        ndpcntl.gpr_we := '1';
        ndpcntl.psr_ccwe := '1';
        if DP_STAT.div_quit = '1' then
          nstate := s_opg_div_quit;
        else
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;
        
      when s_opg_div_quit =>            -- DIV (0/ or /0 or V=1 aborts)
        ndpcntl.psr_ccwe := '1';
        do_fork_next(nstate, nstatus, nmmumoni);

      when s_opg_ash =>                 -- ASH (load shc)
        ndpcntl.munit_s_ash := '1';
        nstate := s_opg_ash_cn;

      when s_opg_ash_cn =>              -- ASH (shift cycles)
        nvmcntl.dspace := '0';                    -- prepare do_fork_next_pref
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const(0)
        ndpcntl.gpr_adst := SRCREG;               -- write result
        ndpcntl.munit_s_ash_cn := '1';
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_pc;  -- VA = PC
        nstate := s_opg_ash_cn;
        if DP_STAT.shc_tc = '0' then
          ndpcntl.dres_sel := R_IDSTAT.res_sel;   -- DRES = choice of idec
          ndpcntl.dsrc_we := '1';                 -- update DSRC
        else
          ndpcntl.dres_sel := c_dpath_res_ounit;  -- DRES = OUNIT
          ndpcntl.gpr_we := '1';
          ndpcntl.psr_ccwe := '1';
          do_fork_next_pref(nstate, nstatus, ndpcntl, nvmcntl, nmmumoni);
        end if;
          
      when s_opg_ashc =>                -- ASHC (load low, load shc)
        ndpcntl.gpr_asrc := SRCREG(2 downto 1) & "1";-- read odd reg !
        ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;
        ndpcntl.dtmp_we := '1';
        ndpcntl.munit_s_ashc := '1';
        nstate := s_opg_ashc_cn;

      when s_opg_ashc_cn =>             -- ASHC (shift cycles)
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;     -- DSRC = DRES
        ndpcntl.dtmp_sel := c_dpath_dtmp_drese;   -- DTMP = DRESE
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;  -- OUNIT A=DSRC
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const(0)
        ndpcntl.gpr_adst := SRCREG;               -- write result
        ndpcntl.munit_s_ashc_cn := '1';
        nstate := s_opg_ashc_cn;
        if DP_STAT.shc_tc = '0' then
          ndpcntl.dres_sel := R_IDSTAT.res_sel;   -- DRES = choice of idec
          ndpcntl.dsrc_we := '1';                 -- update DSRC
          ndpcntl.dtmp_we := '1';                 -- update DTMP
        else
          ndpcntl.dres_sel := c_dpath_res_ounit;  -- DRES = OUNIT
          ndpcntl.gpr_we := '1';
          ndpcntl.psr_ccwe := '1';
          nstate := s_opg_ashc_wl;
        end if;

      when s_opg_ashc_wl =>             -- ASHC (write low)
        ndpcntl.ounit_asel := c_ounit_asel_dtmp; -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.gpr_adst := SRCREG(2 downto 1) & "1";-- write odd reg !
        ndpcntl.gpr_we := '1';
        do_fork_next(nstate, nstatus, nmmumoni);

  -- dsta mode operations -----------------------------------------------------

      when s_opa_jsr =>
        ndpcntl.gpr_asrc := c_gpr_sp;              --                (for else)
        ndpcntl.dsrc_sel := c_dpath_dsrc_src;      -- DSRC = regfile (for else)
        if R_IDSTAT.is_dstmode0 = '1' then
          nstate := s_trap_10;                     -- trap 10 like 11/70
        else
          ndpcntl.dsrc_we := '1';
          nstate := s_opa_jsr1;
        end if;

      when s_opa_jsr1 =>
        ndpcntl.gpr_asrc := SRCREG;
        ndpcntl.dtmp_sel := c_dpath_dtmp_dsrc;     -- DTMP = regfile
        ndpcntl.dtmp_we := '1';
        
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;   -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(2)
        ndpcntl.ounit_opsub := '1';                -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DDST = DRES
        ndpcntl.dsrc_we := '1';                    -- update DDST
        ndpcntl.gpr_adst := c_gpr_sp;
        ndpcntl.gpr_we := '1';                     -- update SP
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_opa_jsr_push;

      when s_opa_jsr_push =>
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;   -- OUNIT A=DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.wacc := '1';
        nvmcntl.req := '1';
        nstate := s_opa_jsr_push_w;

      when s_opa_jsr_push_w =>
        nstate := s_opa_jsr_push_w;
        ndpcntl.ounit_asel := c_ounit_asel_pc;     -- OUNIT A=PC
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gpr_adst := SRCREG;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.gpr_we := '1';                   -- load R with PC
          nstate := s_opa_jsr2;
        end if;

      when s_opa_jsr2 =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gpr_adst := c_gpr_pc;
        ndpcntl.gpr_we := '1';                     -- load PC with dsta
        do_fork_next(nstate, nstatus, nmmumoni);

      when s_opa_jmp =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gpr_adst := c_gpr_pc;
        if R_IDSTAT.is_dstmode0 = '1' then
          nstate := s_trap_10;                     -- trap 10 like 11/70
        else
          ndpcntl.gpr_we := '1';                   -- load PC with dsta
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;

      when s_opa_mtp =>
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_opa_mtp_pop_w,
                          nmmumoni, updt_sp=>'1');
        
      when s_opa_mtp_pop_w =>
        nstate := s_opa_mtp_pop_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.dtmp_sel := c_dpath_dtmp_dres;    -- DTMP = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then          
          ndpcntl.dtmp_we := '1';                 -- load DTMP
          if R_IDSTAT.is_dstmode0 = '1' then      -- handle register access
            nstate := s_opa_mtp_reg;
          else
            case R_IDSTAT.fork_dsta is            -- 2nd dsta fork in s_idecode
              when c_fork_dsta_def => nstate := s_opa_mtp_mem;
              when c_fork_dsta_inc => nstate := s_dsta_inc;
              when c_fork_dsta_dec => nstate := s_dsta_dec;
              when c_fork_dsta_ind => nstate := s_dsta_ind;
              when others => nstate := s_cpufail;
            end case;
          end if;
        end if;
        ndpcntl.ddst_sel := c_dpath_ddst_dst;     -- DDST = R(DST)
        ndpcntl.ddst_we  := '1';                  -- update DDST (needed for sp)

      when s_opa_mtp_reg =>
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.psr_ccwe := '1';                  -- set cc (from ounit too)
        ndpcntl.gpr_mode := PSW.pmode;            -- load reg in pmode
        ndpcntl.gpr_we := '1';
        do_fork_next(nstate, nstatus, nmmumoni);

      when s_opa_mtp_mem =>
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;  -- OUNIT A = DTMP
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B = const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.psr_ccwe := '1';                  -- set cc (from ounit too)
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;-- VA = DDST
        nvmcntl.dspace := IREG(15);            -- msb indicates I/D: 0->I, 1->D
        nvmcntl.mode := PSW.pmode;
        nvmcntl.wacc := '1';
        nvmcntl.req := '1';
        nstate := s_opa_mtp_mem_w;
        
      when s_opa_mtp_mem_w =>
        nstate := s_opa_mtp_mem_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;

      when s_opa_mfp_reg =>
        ndpcntl.gpr_mode := PSW.pmode;           -- fetch reg in pmode
        ndpcntl.ddst_sel := c_dpath_ddst_dst;    -- DDST = reg(dst)
        ndpcntl.ddst_we := '1';
        nstate := s_opa_mfp_dec;
        
      when s_opa_mfp_mem =>
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_ddst;   -- VA = DDST
        if PSW.cmode=c_psw_umode and                 -- if cm=pm=user then
           PSW.cmode=c_psw_umode then                -- MFPI works like it
          nvmcntl.dspace := '1';                     -- were MFPD
        else
          nvmcntl.dspace := IREG(15);          -- msb indicates I/D: 0->I, 1->D
        end if;
        nvmcntl.mode := PSW.pmode;
        nvmcntl.req := '1';
        nstate := s_opa_mfp_mem_w;

      when s_opa_mfp_mem_w =>
        nstate := s_opa_mfp_mem_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;  -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;    -- DDST = DRES
        if imemok then
          ndpcntl.ddst_we := '1';
          nstate := s_opa_mfp_dec;
        end if;

      when s_opa_mfp_dec =>         
        ndpcntl.ounit_asel := c_ounit_asel_dsrc;   -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(2)
        ndpcntl.ounit_opsub := '1';                -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;      -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                    -- update DSRC
        ndpcntl.gpr_adst := c_gpr_sp;
        ndpcntl.gpr_we := '1';                     -- update SP
        nmmumoni.regmod := '1';
        nmmumoni.isdec := '1';
        nstate := s_opa_mfp_push;

      when s_opa_mfp_push =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const(0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.psr_ccwe := '1';                   -- set cc (from ounit too)
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.wacc := '1';
        nvmcntl.req := '1';
        nstate := s_opa_mfp_push_w;

      when s_opa_mfp_push_w =>
        nstate := s_opa_mfp_push_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;

  -- trap and interrupt handling states ---------------------------------------

      when s_trap_4 =>
        lvector := "0000001";           -- vector (4)
        do_start_int(nstate, ndpcntl, lvector);

      when s_trap_10 =>
        lvector := "0000010";           -- vector (10)
        do_start_int(nstate, ndpcntl, lvector);

      when s_trap_disp =>
        if R_STATUS.trap_mmu = '1' then
          nvmcntl.trap_done := '1';     -- mmu trap taken: set ssr0 trap bit
          lvector := "0101010";         -- mmu trap: vector (250)
        elsif R_STATUS.trap_ysv = '1' then
          lvector := "0000001";         -- ysv trap: vector (4)          
          ncpuerr.ysv := '1';
        else
          lvector := "0000011";         -- trace trap: vector (14)
        end if;
        nstatus.trap_mmu := '0';        -- clear pending trap flags
        nstatus.trap_ysv := '0';        -- 
        do_start_int(nstate, ndpcntl, lvector);

      when s_int_ext =>
        lvector := R_STATUS.intvect;    -- external vector
        do_start_int(nstate, ndpcntl, lvector);

      when s_int_getpc =>
        nvmcntl.mode := c_psw_kmode;    -- fetch PC from kernel D space
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_int_getpc_w, nmmumoni);

      when s_int_getpc_w =>
        nstate := s_int_getpc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;     -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if VM_STAT.err = '1' then                 -- in case of vm-err
          nstatus.cpugo   := '0';                 -- non-recoverable error
          nstatus.cpurust := c_cpurust_vecfet;    -- halt CPU
          nstate := s_idle;          
        end if;
        if imemok then
          ndpcntl.ddst_we := '1';                 -- DDST = new PC
          nstate := s_int_getps;
        end if;

      when s_int_getps =>
        nvmcntl.mode := c_psw_kmode;    -- fetch PS from kernel D space
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_int_getps_w, nmmumoni);

      when s_int_getps_w =>
        nstate := s_int_getps_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.psr_func := c_psr_func_wint;      -- interupt mode write
        do_memcheck(nstate, nstatus, imemok);
        if VM_STAT.err = '1' then                 -- in case of vm-err
          nstatus.cpugo   := '0';                 -- non-recoverable error
          nstatus.cpurust := c_cpurust_vecfet;    -- halt CPU
          nstate := s_idle;          
        end if;
        if imemok then
          ndpcntl.psr_we := '1';                  -- store new PS
          nstate := s_int_getsp;
        end if;

      when s_int_getsp =>
        ndpcntl.gpr_asrc := c_gpr_sp;
        ndpcntl.dsrc_we := '1';                  -- DSRC = SP (in new mode)
        nstate := s_int_decsp;

      when s_int_decsp =>
        ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";      -- OUNIT const=2
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.dsrc_we := '1';                  -- update DSRC
        ndpcntl.gpr_adst := c_gpr_sp;
        ndpcntl.gpr_we := '1';                   -- update SP too
        nstate := s_int_pushps;

      when s_int_pushps =>
        ndpcntl.ounit_asel := c_ounit_asel_dtmp;   -- OUNIT A=DTMP (old PS)
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.wacc := '1';                       -- write mem
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.req := '1';
        nstate := s_int_pushps_w;

      when s_int_pushps_w =>
        ndpcntl.ounit_asel := c_ounit_asel_dsrc; -- OUNIT A=DSRC
        ndpcntl.ounit_const := "000000010";      -- OUNIT const=2
        ndpcntl.ounit_bsel := c_ounit_bsel_const;-- OUNIT B=const
        ndpcntl.ounit_opsub := '1';              -- OUNIT = A-B
        ndpcntl.dres_sel := c_dpath_res_ounit;   -- DRES = OUNIT
        ndpcntl.dsrc_sel := c_dpath_dsrc_res;    -- DSRC = DRES
        ndpcntl.gpr_adst := c_gpr_sp;

        nstate := s_int_pushps_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.dsrc_we := '1';                -- update DSRC
          ndpcntl.gpr_we := '1';                 -- update SP too
          nstate := s_int_pushpc;
        end if;
        
      when s_int_pushpc =>
        ndpcntl.ounit_asel := c_ounit_asel_pc;     -- OUNIT A=PC
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.vmaddr_sel := c_dpath_vmaddr_dsrc; -- VA = DSRC
        nvmcntl.wacc := '1';                       -- write mem
        nvmcntl.dspace := '1';
        nvmcntl.kstack := is_kmode;
        nvmcntl.req := '1';
        nstate := s_int_pushpc_w;

      when s_int_pushpc_w =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst;   -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const;  -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;     -- DRES = OUNIT
        ndpcntl.gpr_adst := c_gpr_pc;

        nstate := s_int_pushpc_w;
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          nstatus.do_intrsv := '0';                -- signal end of rsv
          ndpcntl.gpr_we := '1';                   -- load new PC
          do_fork_next(nstate, nstatus, nmmumoni);         -- ???
        end if;
        
  -- return from trap or interrupt handling states ----------------------------

      when s_rti_getpc =>
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_rti_getpc_w,
                          nmmumoni, updt_sp=>'1');

      when s_rti_getpc_w =>
        nstate := s_rti_getpc_w;
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        ndpcntl.ddst_sel := c_dpath_ddst_res;     -- DDST = DRES
        do_memcheck(nstate, nstatus, imemok);
        if imemok then
          ndpcntl.ddst_we := '1';                 -- DDST = new PC
          nstate := s_rti_getps;
        end if;

      when s_rti_getps =>
        do_memread_srcinc(nstate, ndpcntl, nvmcntl, s_rti_getps_w,
                          nmmumoni, updt_sp=>'1');

      when s_rti_getps_w =>
        nstate := s_rti_getps_w;
        do_memcheck(nstate, nstatus, imemok);
        ndpcntl.dres_sel := c_dpath_res_vmdout;   -- DRES = VMDOUT
        if is_kmode = '1' then                    -- if in kernel mode
          ndpcntl.psr_func := c_psr_func_wall;    --   write all fields
        else
          ndpcntl.psr_func := c_psr_func_wrti;    --   otherwise filter
        end if;
        if imemok then
          ndpcntl.psr_we := '1';                  -- load new PS
          nstate := s_rti_newpc;
        end if;

      when s_rti_newpc =>
        ndpcntl.ounit_asel := c_ounit_asel_ddst;  -- OUNIT A=DDST
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const (0)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gpr_adst := c_gpr_pc;
        ndpcntl.gpr_we := '1';                    -- load new PC
        if R_IDSTAT.op_rtt = '1' then             -- if RTT instruction
          nstate := s_ifetch;                       --   force fetch
        else                                      -- otherwise RTI
          do_fork_next(nstate, nstatus, nmmumoni);
        end if;

  -- exception abort states ---------------------------------------------------

      when s_vmerr =>
        nstate := s_cpufail;

                                            -- setup for R_VMSTAT.err_rsv='1'
        ndpcntl.ounit_azero := '1';               -- OUNIT A = 0
        ndpcntl.ounit_const := "000000100";       -- emergency stack pointer
        ndpcntl.ounit_bsel := c_ounit_bsel_const; -- OUNIT B=const(vector)
        ndpcntl.dres_sel := c_dpath_res_ounit;    -- DRES = OUNIT
        ndpcntl.gpr_mode := c_psw_kmode;          -- set kmode SP to 4
        ndpcntl.gpr_adst := c_gpr_sp;
        
        nstatus.trap_mmu :='0';                   -- drop pending mmu trap

        if R_VMSTAT.fail = '1' then               -- vmbox failure
          nstatus.cpugo   := '0';                   -- halt cpu
          nstatus.cpurust := c_cpurust_vfail;
          nstate := s_idle; 

        elsif R_STATUS.do_intrsv = '1' then       -- double error
          nstatus.cpugo := '0';                     -- give up, HALT cpu
          nstatus.cpurust := c_cpurust_recrsv;
          nstate := s_idle;
          
        elsif R_VMSTAT.err = '1' then            -- normal vm errors
          if R_VMSTAT.err_rsv = '1' then
            nstatus.do_intrsv := '1';              -- signal start of rsv
            ndpcntl.gpr_we := '1';

            if R_VMSTAT.err_odd='1' or R_VMSTAT.err_mmu='1' then
              ncpuerr.adderr := '1';
            elsif R_VMSTAT.err_nxm = '1' then
              ncpuerr.nxm := '1';
            elsif R_VMSTAT.err_iobto = '1' then
              ncpuerr.iobto := '1';
            end if;
            ncpuerr.rsv := '1';
            nstate := s_trap_4;

          elsif R_VMSTAT.err_odd = '1' then
            ncpuerr.adderr := '1';
            nstate := s_trap_4;
          elsif R_VMSTAT.err_nxm = '1' then
            ncpuerr.nxm := '1';
            nstate := s_trap_4;
          elsif R_VMSTAT.err_iobto = '1' then
            ncpuerr.iobto := '1';
            nstate := s_trap_4;

          elsif R_VMSTAT.err_mmu = '1' then
            lvector := "0101010";                    -- vector (250)
            do_start_int(nstate, ndpcntl, lvector);
          end if;
        end if;
        
      when s_cpufail =>
        nstatus.cpugo   := '0';
        nstatus.cpurust := c_cpurust_sfail;
        nstate := s_idle; 
        
      when others =>
        nstate := s_cpufail;             --!!! catch undefined states !!!

    end case;

    if DBREAK = '1' then                -- handle BREAK
      nstatus.suspint :='1';
    end if;
    nstatus.suspext := ESUSP_I;

    -- handle cpususp transitions 
    if nstatus.suspint='1' or nstatus.suspext='1' then
      nstatus.cpususp := '1';
    elsif R_STATUS.suspint='0' and R_STATUS.suspext='0' then
      nstatus.cpususp := '0';
    end if;
    
    if nstatus.cmdack = '1' then        -- cmdack in next cycle ? Yes we test
                                           -- nstatus here !!
      nstatus.cmdbusy := '0';
      ndpcntl.cpdout_we := '1';
    end if;

    N_STATE  <= nstate;
    N_STATUS <= nstatus;
    N_CPUERR <= ncpuerr;
    N_IDSTAT <= nidstat;
    
    INT_ACK <= R_STATUS.intack;
    CRESET  <= R_STATUS.creset;
    BRESET  <= R_STATUS.breset;
    ESUSP_O <= R_STATUS.suspint;     -- FIXME_code: handle masking later
    ITIMER  <= R_STATUS.itimer;
    
    DP_CNTL <= ndpcntl;
    VM_CNTL <= nvmcntl;

    nmmumoni.regnum := ndpcntl.gpr_adst;
    nmmumoni.delta  := ndpcntl.ounit_const(3 downto 0);
    MMU_MONI <= nmmumoni;
    
  end process proc_next;

  proc_cpstat : process (R_STATUS)
  begin
    CP_STAT         <= cp_stat_init;
    CP_STAT.cmdbusy <= R_STATUS.cmdbusy;
    CP_STAT.cmdack  <= R_STATUS.cmdack;
    CP_STAT.cmderr  <= R_STATUS.cmderr;
    CP_STAT.cmdmerr <= R_STATUS.cmdmerr;
    CP_STAT.cpugo   <= R_STATUS.cpugo;
    CP_STAT.cpustep <= R_STATUS.cpustep;
    CP_STAT.cpuwait <= R_STATUS.cpuwait;
    CP_STAT.cpususp <= R_STATUS.cpususp;
    CP_STAT.cpurust <= R_STATUS.cpurust;
    CP_STAT.suspint <= R_STATUS.suspint;
    CP_STAT.suspext <= R_STATUS.suspext;
  end process proc_cpstat;
  
end syn;
 

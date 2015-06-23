-- $Id: pdp11_dpath.vhd 677 2015-05-09 21:52:32Z mueller $
--
-- Copyright 2006-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_dpath - syn
-- Description:    pdp11: CPU datapath
--
-- Dependencies:   pdp11_gpr
--                 pdp11_psr
--                 pdp11_ounit
--                 pdp11_aunit
--                 pdp11_lunit
--                 pdp11_munit
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-08-10   581   1.2.4  use c_cc_f_*
-- 2014-07-12   569   1.2.3  use DIV_QUIT and S_DIV_SR for pdp11_munit
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2010-09-18   300   1.2.1  rename (adlm)box->(oalm)unit
-- 2010-06-13   305   1.2    rename CPDIN -> CP_DIN; add CP_DOUT out port;
--                           remove CPADDR out port; drop R_CPADDR, proc_cpaddr;
--                           added R_CPDOUT, proc_cpdout
-- 2009-05-30   220   1.1.6  final removal of snoopers (were already commented)
-- 2008-12-14   177   1.1.5  fill gpr_* fields in DM_STAT_DP
-- 2008-08-22   161   1.1.4  rename ubf_ -> ibf_; use iblib
-- 2008-04-19   137   1.1.3  add DM_STAT_DP port
-- 2008-03-02   121   1.1.2  remove snoopers
-- 2008-02-24   119   1.1.1  add CPADDR register, remove R_MDIN (not needed)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now (for psr access)
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

entity pdp11_dpath is                   -- CPU datapath
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
    DM_STAT_DP : out dm_stat_dp_type    -- debug and monitor status
  );
end pdp11_dpath;

architecture syn of pdp11_dpath is

  signal R_DSRC : slv16 := (others=>'0');  -- SRC register
  signal R_DDST : slv16 := (others=>'0');  -- DST register
  signal R_DTMP : slv16 := (others=>'0');  -- TMP register

  signal R_IREG : slv16 := (others=>'0');  -- IREG register

  signal R_CPDOUT : slv16 := (others=>'0'); -- cp dout buffer
  
  signal GPR_DSRC : slv16 := (others=>'0');  -- 
  signal GPR_DDST : slv16 := (others=>'0');  -- 
  signal GPR_PC : slv16 := (others=>'0');    -- 

  signal PSW : psw_type := psw_init;     --
  signal CCIN : slv4 := (others=>'0');   -- cc input to xbox's
  signal CCOUT : slv4 := (others=>'0');  -- cc output from xbox's
  
  signal DRES : slv16 := (others=>'0');  -- result bus
  signal DRESE : slv16 := (others=>'0'); -- result bus extra

  signal OUNIT_DOUT : slv16 := (others=>'0'); -- result ounit
  signal AUNIT_DOUT : slv16 := (others=>'0'); -- result aunit
  signal LUNIT_DOUT : slv16 := (others=>'0'); -- result lunit
  signal MUNIT_DOUT : slv16 := (others=>'0'); -- result munit

  signal OUNIT_NZOUT : slv2 := (others=>'0'); -- nz flags ounit
  signal OUNIT_CCOUT : slv4 := (others=>'0'); -- cc flags ounit
  signal AUNIT_CCOUT : slv4 := (others=>'0'); -- cc flags aunit
  signal LUNIT_CCOUT : slv4 := (others=>'0'); -- cc flags lunit
  signal MUNIT_CCOUT : slv4 := (others=>'0'); -- cc flags munit

  subtype  lal_ibf_addr  is integer range 15 downto 1;
  subtype  lah_ibf_addr  is integer range  5 downto 0;
  constant lah_ibf_ena_22bit: integer :=  6;
  constant lah_ibf_ena_ubmap: integer :=  7;

begin

  GPR : pdp11_gpr port map (
    CLK   => CLK,
    DIN   => DRES,
    ASRC  => CNTL.gpr_asrc,
    ADST  => CNTL.gpr_adst,
    MODE  => CNTL.gpr_mode,
    RSET  => CNTL.gpr_rset,
    WE    => CNTL.gpr_we,
    BYTOP => CNTL.gpr_bytop,
    PCINC => CNTL.gpr_pcinc,
    DSRC  => GPR_DSRC,
    DDST  => GPR_DDST,
    PC    => GPR_PC
  );

  PSR : pdp11_psr port map(
    CLK     => CLK,
    CRESET  => CRESET,
    DIN     => DRES,
    CCIN    => CCOUT,
    CCWE    => CNTL.psr_ccwe,
    WE      => CNTL.psr_we,
    FUNC    => CNTL.psr_func,
    PSW     => PSW,
    IB_MREQ => IB_MREQ,
    IB_SRES => IB_SRES
  );
  
  OUNIT : pdp11_ounit port map (
    DSRC   => R_DSRC,
    DDST   => R_DDST,
    DTMP   => R_DTMP,
    PC     => GPR_PC,
    ASEL   => CNTL.ounit_asel,
    AZERO  => CNTL.ounit_azero,
    IREG8  => R_IREG(7 downto 0),
    VMDOUT => VM_DOUT,
    CONST  => CNTL.ounit_const,
    BSEL   => CNTL.ounit_bsel,
    OPSUB  => CNTL.ounit_opsub,
    DOUT   => OUNIT_DOUT,
    NZOUT  => OUNIT_NZOUT
  );
  
  AUNIT : pdp11_aunit port map (
    DSRC   => R_DSRC,
    DDST   => R_DDST,
    CI     => CCIN(c_cc_f_c),
    SRCMOD => CNTL.aunit_srcmod,
    DSTMOD => CNTL.aunit_dstmod,
    CIMOD  => CNTL.aunit_cimod,
    CC1OP  => CNTL.aunit_cc1op,
    CCMODE => CNTL.aunit_ccmode,
    BYTOP  => CNTL.aunit_bytop,
    DOUT   => AUNIT_DOUT,
    CCOUT  => AUNIT_CCOUT
  );

  LUNIT : pdp11_lunit port map (
    DSRC  => R_DSRC,
    DDST  => R_DDST,
    CCIN  => CCIN,
    FUNC  => CNTL.lunit_func,
    BYTOP => CNTL.lunit_bytop,
    DOUT  => LUNIT_DOUT,
    CCOUT => LUNIT_CCOUT
  );
  
  MUNIT : pdp11_munit port map (
    CLK       => CLK,
    DSRC      => R_DSRC,
    DDST      => R_DDST,
    DTMP      => R_DTMP,
    GPR_DSRC  => GPR_DSRC,
    FUNC      => CNTL.munit_func,
    S_DIV     => CNTL.munit_s_div,
    S_DIV_CN  => CNTL.munit_s_div_cn,
    S_DIV_CR  => CNTL.munit_s_div_cr,
    S_DIV_SR  => CNTL.munit_s_div_sr,
    S_ASH     => CNTL.munit_s_ash,
    S_ASH_CN  => CNTL.munit_s_ash_cn,
    S_ASHC    => CNTL.munit_s_ashc,
    S_ASHC_CN => CNTL.munit_s_ashc_cn,
    SHC_TC    => STAT.shc_tc,
    DIV_CR    => STAT.div_cr,
    DIV_CQ    => STAT.div_cq,
    DIV_QUIT  => STAT.div_quit,
    DOUT      => MUNIT_DOUT,
    DOUTE     => DRESE,
    CCOUT     => MUNIT_CCOUT
  );

  CCIN <= PSW.cc;

  OUNIT_CCOUT <= OUNIT_NZOUT & "0" & CCIN(c_cc_f_c); -- clear v, keep c
  
  proc_dres_sel: process (OUNIT_DOUT, AUNIT_DOUT, LUNIT_DOUT, MUNIT_DOUT,
                          VM_DOUT, R_IREG, CP_DIN, CNTL)
  begin
    case CNTL.dres_sel is
      when c_dpath_res_ounit  => DRES <= OUNIT_DOUT;
      when c_dpath_res_aunit  => DRES <= AUNIT_DOUT;
      when c_dpath_res_lunit  => DRES <= LUNIT_DOUT;
      when c_dpath_res_munit  => DRES <= MUNIT_DOUT;
      when c_dpath_res_vmdout => DRES <= VM_DOUT;
      when c_dpath_res_fpdout => DRES <= (others=>'0');
      when c_dpath_res_ireg   => DRES <= R_IREG;
      when c_dpath_res_cpdin  => DRES <= CP_DIN;
      when others => null;
    end case;
  end process proc_dres_sel;

  proc_cres_sel: process (OUNIT_CCOUT, AUNIT_CCOUT, LUNIT_CCOUT, MUNIT_CCOUT,
                          CCIN, CNTL)
  begin
    case CNTL.cres_sel is
      when c_dpath_res_ounit  => CCOUT <= OUNIT_CCOUT;
      when c_dpath_res_aunit  => CCOUT <= AUNIT_CCOUT;
      when c_dpath_res_lunit  => CCOUT <= LUNIT_CCOUT;
      when c_dpath_res_munit  => CCOUT <= MUNIT_CCOUT;
      when c_dpath_res_vmdout => CCOUT <= CCIN;
      when c_dpath_res_fpdout => CCOUT <= "0000";
      when c_dpath_res_ireg   => CCOUT <= CCIN;
      when c_dpath_res_cpdin  => CCOUT <= CCIN;
      when others => null;
    end case;
  end process proc_cres_sel;

  proc_dregs: process (CLK)
  begin

    if rising_edge(CLK) then
      
      if CNTL.dsrc_we = '1' then
        if CNTL.dsrc_sel = '0' then
          R_DSRC <= GPR_DSRC;
        else
          R_DSRC <= DRES;
        end if;
      end if;

      if CNTL.ddst_we = '1' then
        if CNTL.ddst_sel = '0' then
          R_DDST <= GPR_DDST;
        else
          R_DDST <= DRES;
        end if;
      end if;
      
      if CNTL.dtmp_we = '1' then
        case CNTL.dtmp_sel is
          when c_dpath_dtmp_dsrc  => R_DTMP <= GPR_DSRC;
          when c_dpath_dtmp_psw   =>
            R_DTMP <= (others=>'0');
            R_DTMP(psw_ibf_cmode) <= PSW.cmode;
            R_DTMP(psw_ibf_pmode) <= PSW.pmode;
            R_DTMP(psw_ibf_rset)  <= PSW.rset;
            R_DTMP(psw_ibf_pri)   <= PSW.pri;
            R_DTMP(psw_ibf_tflag) <= PSW.tflag;
            R_DTMP(psw_ibf_cc)    <= PSW.cc;
          when c_dpath_dtmp_dres  => R_DTMP <= DRES;
          when c_dpath_dtmp_drese => R_DTMP <= DRESE;
          when others => null;
        end case;
      end if;
      
    end if;
    
  end process proc_dregs;

  proc_mregs: process (CLK)
  begin

    if rising_edge(CLK) then
      
      if CNTL.ireg_we = '1' then
        R_IREG <= VM_DOUT;
      end if;

    end if;
  end process proc_mregs;

  proc_cpdout: process (CLK)
  begin
    if rising_edge(CLK) then
      if CRESET = '1' then
        R_CPDOUT <= (others=>'0');
      else
        if CNTL.cpdout_we = '1' then
          R_CPDOUT <= DRES;
        end if;
      end if;
    end if;
  end process proc_cpdout;

  proc_vmaddr_sel: process (R_DSRC, R_DDST, R_DTMP, GPR_PC, CNTL)
  begin
    case CNTL.vmaddr_sel is
      when c_dpath_vmaddr_dsrc => VM_ADDR <= R_DSRC;
      when c_dpath_vmaddr_ddst => VM_ADDR <= R_DDST;
      when c_dpath_vmaddr_dtmp => VM_ADDR <= R_DTMP;
      when c_dpath_vmaddr_pc   => VM_ADDR <= GPR_PC;
      when others => null;
    end case;
  end process proc_vmaddr_sel;

  STAT.ccout_z <= CCOUT(c_cc_f_z);      -- current Z cc flag
    
  PSWOUT  <= PSW;
  PCOUT   <= GPR_PC;
  IREG    <= R_IREG;
  VM_DIN  <= DRES;
  CP_DOUT <= R_CPDOUT;

  DM_STAT_DP.pc        <= GPR_PC;
  DM_STAT_DP.psw       <= PSW;
  DM_STAT_DP.ireg      <= R_IREG;
  DM_STAT_DP.ireg_we   <= CNTL.ireg_we;
  DM_STAT_DP.dsrc      <= R_DSRC;
  DM_STAT_DP.ddst      <= R_DDST;
  DM_STAT_DP.dtmp      <= R_DTMP;
  DM_STAT_DP.dres      <= DRES;
  DM_STAT_DP.gpr_adst  <= CNTL.gpr_adst;
  DM_STAT_DP.gpr_mode  <= CNTL.gpr_mode;
  DM_STAT_DP.gpr_bytop <= CNTL.gpr_bytop;
  DM_STAT_DP.gpr_we    <= CNTL.gpr_we;
  
end syn;

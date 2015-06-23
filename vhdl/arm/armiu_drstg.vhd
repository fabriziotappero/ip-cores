-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.int.all;
use work.memdef.all;
use work.armdecode.all;
use work.armshiefter.all;
use work.armpmodel.all;
use work.armdebug.all;
use work.armpctrl.all;
use work.armcmd.all;
use work.armldst.all;
use work.armcmd_comp.all;
use work.arm_comp.all;

entity armiu_drstg is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    i       : in  armiu_drstg_typ_in;
    o       : out armiu_drstg_typ_out
    );
end armiu_drstg;

architecture rtl of armiu_drstg is

  type armiu_drstg_tmp_type is record
    o       : armiu_drstg_typ_out;
    cmdali  : armcmd_al_typ_in;
    cmdsri  : armcmd_sr_typ_in;
    cmdldi  : armcmd_ld_typ_in;
    cmdsti  : armcmd_st_typ_in;
    cmdlmi  : armcmd_lm_typ_in;
    cmdsmi  : armcmd_sm_typ_in;
    cmdswi  : armcmd_sw_typ_in;
    cmdcri  : armcmd_cr_typ_in;
    cmdcli  : armcmd_cl_typ_in;
    cmdcsi  : armcmd_cs_typ_in;
    cmdbli  : armcmd_bl_typ_in;
    
    ctrli : acm_ctrlin;
    ctrlo : acm_ctrlout;
    pctrl, pctrl_bypass : apc_pctrl;
    
    commit : std_logic;
    insn : std_logic_vector(31 downto 0);
    trap   : apm_trapctrl;
    nextmicro, mem : std_logic;
    micro : apc_micro;
    am : ade_amode;
    
    r1_src, r2_src : acm_regsrc; 
    rd_src : acm_rdsrc;

    rn, rm, rd, rs, rlink, rpc : std_logic_vector(APM_REG_U downto APM_REG_D);
    nr : std_logic_vector(APM_REG_U downto APM_REG_D);
    nr_i : integer;
    nr_c : std_logic;
    startoff, endoff, incval : std_logic_vector(31 downto 0);
    m1, m2, md: std_logic_vector(APM_REG_U downto APM_REG_D);
    m1_valid, m2_valid: std_logic;
    rr1, rr2, rrd: std_logic_vector(APM_RREAL_U downto APM_RREAL_D);
    rmode : std_logic_vector(4 downto 0);
    
  end record;
  type armiu_drstg_reg_type is record
    cnt : std_logic_vector(ACM_CNT_SZ-1 downto 0);
    reglist : std_logic_vector(APM_REGLIST_SZ-1 downto 0);
  end record;
  type armiu_drstg_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_drstg_tmp_type;
     dbgpmode : adg_dbgpmode;
     dbgrmode : adg_dbgpmode;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_drstg_reg_type;
  signal rdbg, cdbg : armiu_drstg_dbg_type;

  signal cmdali : armcmd_al_typ_in;
  signal cmdalo : armcmd_al_typ_out;
  signal cmdsri : armcmd_sr_typ_in;
  signal cmdsro : armcmd_sr_typ_out;
  signal cmdldi : armcmd_ld_typ_in;
  signal cmdldo : armcmd_ld_typ_out;
  signal cmdsti : armcmd_st_typ_in;
  signal cmdsto : armcmd_st_typ_out;
  signal cmdlmi : armcmd_lm_typ_in;
  signal cmdlmo : armcmd_lm_typ_out;
  signal cmdsmi : armcmd_sm_typ_in;
  signal cmdsmo : armcmd_sm_typ_out;
  signal cmdswi : armcmd_sw_typ_in;
  signal cmdswo : armcmd_sw_typ_out;
  signal cmdcri : armcmd_cr_typ_in;
  signal cmdcro : armcmd_cr_typ_out;
  signal cmdcli : armcmd_cl_typ_in;
  signal cmdcso : armcmd_cs_typ_out;
  signal cmdcsi : armcmd_cs_typ_in;
  signal cmdclo : armcmd_cl_typ_out;
  signal cmdbli : armcmd_bl_typ_in;
  signal cmdblo : armcmd_bl_typ_out;

begin  
    
  p0: process (clk, rst, r, i,
               cmdalo, cmdsro, cmdldo, cmdsto, cmdlmo, cmdsmo, cmdswo,
               cmdcro, cmdclo, cmdcso, cmdblo )
    variable v    : armiu_drstg_reg_type;
    variable t    : armiu_drstg_tmp_type;
    variable vdbg : armiu_drstg_dbg_type;
  begin 
    
    -- $(init(t:armiu_drstg_tmp_type))
    -- $(init-automatically-generated-for-synthesis:(t:armiu_drstg_tmp_type))
    t.o.nextinsn_v := '0';
    t.o.toRR_micro_v.pctrl.insn.pc_8 := (others => '0');
    t.o.toRR_micro_v.pctrl.insn.insn := (others => '0');
    t.o.toRR_micro_v.pctrl.insn.insntyp := ade_typmem;
    t.o.toRR_micro_v.pctrl.insn.decinsn := type_arm_invalid;
    t.o.toRR_micro_v.pctrl.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.o.toRR_micro_v.pctrl.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.o.toRR_micro_v.pctrl.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.o.toRR_micro_v.pctrl.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.o.toRR_micro_v.pctrl.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.o.toRR_micro_v.pctrl.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.o.toRR_micro_v.pctrl.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.o.toRR_micro_v.pctrl.insn.valid := '0';
    t.o.toRR_micro_v.pctrl.insn.id := (others => '0');
    t.o.toRR_micro_v.pctrl.valid := '0';
    t.o.toRR_micro_v.pctrl.rr.dummy := '0';
    t.o.toRR_micro_v.pctrl.rs.rsop_op1_src := apc_opsrc_through;
    t.o.toRR_micro_v.pctrl.rs.rsop_op2_src := apc_opsrc_through;
    t.o.toRR_micro_v.pctrl.rs.rsop_buf1_src := apc_bufsrc_none;
    t.o.toRR_micro_v.pctrl.rs.rsop_buf2_src := apc_bufsrc_none;
    t.o.toRR_micro_v.pctrl.rs.rsop_styp := ash_styp_none;
    t.o.toRR_micro_v.pctrl.rs.rsop_sdir := ash_sdir_snone;
    t.o.toRR_micro_v.pctrl.rs.rs_shieftcarryout := '0';
    t.o.toRR_micro_v.pctrl.ex.exop_aluop := (others => '0');
    t.o.toRR_micro_v.pctrl.ex.exop_data_src := apc_datasrc_aluout;
    t.o.toRR_micro_v.pctrl.ex.exop_buf_src := apc_exbufsrc_none;
    t.o.toRR_micro_v.pctrl.ex.exop_setcpsr := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.ex.n := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.ex.z := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.ex.c := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.ex.v := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.wr.i := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.wr.f := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.wr.t := '0';
    t.o.toRR_micro_v.pctrl.ex.ex_cpsr.wr.mode := (others => '0');
    t.o.toRR_micro_v.pctrl.dm.dummy := '0';
    t.o.toRR_micro_v.pctrl.me.meop_enable := '0';
    t.o.toRR_micro_v.pctrl.me.meop_param.size := lmd_word;
    t.o.toRR_micro_v.pctrl.me.meop_param.read := '0';
    t.o.toRR_micro_v.pctrl.me.meop_param.lock := '0';
    t.o.toRR_micro_v.pctrl.me.meop_param.writedata := '0';
    t.o.toRR_micro_v.pctrl.me.meop_param.addrin := '0';
    t.o.toRR_micro_v.pctrl.me.meop_param.signed := '0';
    t.o.toRR_micro_v.pctrl.me.mexc := '0';
    t.o.toRR_micro_v.pctrl.wr.wrop_rd := (others => '0');
    t.o.toRR_micro_v.pctrl.wr.wrop_rdvalid := '0';
    t.o.toRR_micro_v.pctrl.wr.wrop_setspsr := '0';
    t.o.toRR_micro_v.pctrl.wr.wrop_trap.traptype := apm_trap_reset;
    t.o.toRR_micro_v.pctrl.wr.wrop_trap.trap := '0';
    t.o.toRR_micro_v.pctrl.data1 := (others => '0');
    t.o.toRR_micro_v.pctrl.data2 := (others => '0');
    t.o.toRR_micro_v.valid := '0';
    t.o.toRR_micro_v.r1 := (others => '0');
    t.o.toRR_micro_v.r2 := (others => '0');
    t.o.toRR_micro_v.r1_valid := '0';
    t.o.toRR_micro_v.r2_valid := '0';
    t.o.id := (others => '0');
    t.cmdali.ctrli.cnt := (others => '0');
    t.cmdali.ctrli.insn.pc_8 := (others => '0');
    t.cmdali.ctrli.insn.insn := (others => '0');
    t.cmdali.ctrli.insn.insntyp := ade_typmem;
    t.cmdali.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdali.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdali.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdali.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdali.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdali.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdali.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdali.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdali.ctrli.insn.valid := '0';
    t.cmdali.ctrli.insn.id := (others => '0');
    t.cmdali.ctrli.ctrlo.nextinsn := '0';
    t.cmdali.ctrli.ctrlo.nextcnt := '0';
    t.cmdali.ctrli.ctrlo.hold := '0';
    t.cmdsri.ctrli.cnt := (others => '0');
    t.cmdsri.ctrli.insn.pc_8 := (others => '0');
    t.cmdsri.ctrli.insn.insn := (others => '0');
    t.cmdsri.ctrli.insn.insntyp := ade_typmem;
    t.cmdsri.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdsri.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdsri.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdsri.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdsri.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdsri.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdsri.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdsri.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdsri.ctrli.insn.valid := '0';
    t.cmdsri.ctrli.insn.id := (others => '0');
    t.cmdsri.ctrli.ctrlo.nextinsn := '0';
    t.cmdsri.ctrli.ctrlo.nextcnt := '0';
    t.cmdsri.ctrli.ctrlo.hold := '0';
    t.cmdsri.deid := (others => '0');
    t.cmdsri.exid := (others => '0');
    t.cmdsri.exvalid := '0';
    t.cmdsri.wrid := (others => '0');
    t.cmdsri.wrvalid := '0';
    t.cmdldi.ctrli.cnt := (others => '0');
    t.cmdldi.ctrli.insn.pc_8 := (others => '0');
    t.cmdldi.ctrli.insn.insn := (others => '0');
    t.cmdldi.ctrli.insn.insntyp := ade_typmem;
    t.cmdldi.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdldi.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdldi.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdldi.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdldi.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdldi.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdldi.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdldi.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdldi.ctrli.insn.valid := '0';
    t.cmdldi.ctrli.insn.id := (others => '0');
    t.cmdldi.ctrli.ctrlo.nextinsn := '0';
    t.cmdldi.ctrli.ctrlo.nextcnt := '0';
    t.cmdldi.ctrli.ctrlo.hold := '0';
    t.cmdldi.ctrlmemo.data1 := (others => '0');
    t.cmdldi.ctrlmemo.data2 := (others => '0');
    t.cmdldi.ctrlmemo.r1_src := acm_none;
    t.cmdldi.ctrlmemo.r2_src := acm_none;
    t.cmdldi.ctrlmemo.rd_src := acm_rdnone;
    t.cmdldi.ctrlmemo.rsop_op1_src := apc_opsrc_through;
    t.cmdldi.ctrlmemo.rsop_op2_src := apc_opsrc_through;
    t.cmdldi.ctrlmemo.rsop_buf1_src := apc_bufsrc_none;
    t.cmdldi.ctrlmemo.rsop_buf2_src := apc_bufsrc_none;
    t.cmdldi.ctrlmemo.exop_data_src := apc_datasrc_aluout;
    t.cmdldi.ctrlmemo.exop_buf_src := apc_exbufsrc_none;
    t.cmdldi.ctrlmemo.meop_param.size := lmd_word;
    t.cmdldi.ctrlmemo.meop_param.read := '0';
    t.cmdldi.ctrlmemo.meop_param.lock := '0';
    t.cmdldi.ctrlmemo.meop_param.writedata := '0';
    t.cmdldi.ctrlmemo.meop_param.addrin := '0';
    t.cmdldi.ctrlmemo.meop_param.signed := '0';
    t.cmdldi.ctrlmemo.meop_enable := '0';
    t.cmdsti.ctrli.cnt := (others => '0');
    t.cmdsti.ctrli.insn.pc_8 := (others => '0');
    t.cmdsti.ctrli.insn.insn := (others => '0');
    t.cmdsti.ctrli.insn.insntyp := ade_typmem;
    t.cmdsti.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdsti.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdsti.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdsti.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdsti.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdsti.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdsti.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdsti.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdsti.ctrli.insn.valid := '0';
    t.cmdsti.ctrli.insn.id := (others => '0');
    t.cmdsti.ctrli.ctrlo.nextinsn := '0';
    t.cmdsti.ctrli.ctrlo.nextcnt := '0';
    t.cmdsti.ctrli.ctrlo.hold := '0';
    t.cmdsti.ctrlmemo.data1 := (others => '0');
    t.cmdsti.ctrlmemo.data2 := (others => '0');
    t.cmdsti.ctrlmemo.r1_src := acm_none;
    t.cmdsti.ctrlmemo.r2_src := acm_none;
    t.cmdsti.ctrlmemo.rd_src := acm_rdnone;
    t.cmdsti.ctrlmemo.rsop_op1_src := apc_opsrc_through;
    t.cmdsti.ctrlmemo.rsop_op2_src := apc_opsrc_through;
    t.cmdsti.ctrlmemo.rsop_buf1_src := apc_bufsrc_none;
    t.cmdsti.ctrlmemo.rsop_buf2_src := apc_bufsrc_none;
    t.cmdsti.ctrlmemo.exop_data_src := apc_datasrc_aluout;
    t.cmdsti.ctrlmemo.exop_buf_src := apc_exbufsrc_none;
    t.cmdsti.ctrlmemo.meop_param.size := lmd_word;
    t.cmdsti.ctrlmemo.meop_param.read := '0';
    t.cmdsti.ctrlmemo.meop_param.lock := '0';
    t.cmdsti.ctrlmemo.meop_param.writedata := '0';
    t.cmdsti.ctrlmemo.meop_param.addrin := '0';
    t.cmdsti.ctrlmemo.meop_param.signed := '0';
    t.cmdsti.ctrlmemo.meop_enable := '0';
    t.cmdlmi.ctrli.cnt := (others => '0');
    t.cmdlmi.ctrli.insn.pc_8 := (others => '0');
    t.cmdlmi.ctrli.insn.insn := (others => '0');
    t.cmdlmi.ctrli.insn.insntyp := ade_typmem;
    t.cmdlmi.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdlmi.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdlmi.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdlmi.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdlmi.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdlmi.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdlmi.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdlmi.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdlmi.ctrli.insn.valid := '0';
    t.cmdlmi.ctrli.insn.id := (others => '0');
    t.cmdlmi.ctrli.ctrlo.nextinsn := '0';
    t.cmdlmi.ctrli.ctrlo.nextcnt := '0';
    t.cmdlmi.ctrli.ctrlo.hold := '0';
    t.cmdlmi.ctrlmulti.ctrlmemo.data1 := (others => '0');
    t.cmdlmi.ctrlmulti.ctrlmemo.data2 := (others => '0');
    t.cmdlmi.ctrlmulti.ctrlmemo.r1_src := acm_none;
    t.cmdlmi.ctrlmulti.ctrlmemo.r2_src := acm_none;
    t.cmdlmi.ctrlmulti.ctrlmemo.rd_src := acm_rdnone;
    t.cmdlmi.ctrlmulti.ctrlmemo.rsop_op1_src := apc_opsrc_through;
    t.cmdlmi.ctrlmulti.ctrlmemo.rsop_op2_src := apc_opsrc_through;
    t.cmdlmi.ctrlmulti.ctrlmemo.rsop_buf1_src := apc_bufsrc_none;
    t.cmdlmi.ctrlmulti.ctrlmemo.rsop_buf2_src := apc_bufsrc_none;
    t.cmdlmi.ctrlmulti.ctrlmemo.exop_data_src := apc_datasrc_aluout;
    t.cmdlmi.ctrlmulti.ctrlmemo.exop_buf_src := apc_exbufsrc_none;
    t.cmdlmi.ctrlmulti.ctrlmemo.meop_param.size := lmd_word;
    t.cmdlmi.ctrlmulti.ctrlmemo.meop_param.read := '0';
    t.cmdlmi.ctrlmulti.ctrlmemo.meop_param.lock := '0';
    t.cmdlmi.ctrlmulti.ctrlmemo.meop_param.writedata := '0';
    t.cmdlmi.ctrlmulti.ctrlmemo.meop_param.addrin := '0';
    t.cmdlmi.ctrlmulti.ctrlmemo.meop_param.signed := '0';
    t.cmdlmi.ctrlmulti.ctrlmemo.meop_enable := '0';
    t.cmdlmi.ctrlmulti.ival := (others => '0');
    t.cmdlmi.ctrlmulti.soff := (others => '0');
    t.cmdlmi.ctrlmulti.eoff := (others => '0');
    t.cmdlmi.ctrlmulti.reglist := (others => '0');
    t.cmdlmi.ctrlmulti.mem := '0';
    t.cmdlmi.ctrlmulti.dabort := '0';
    t.cmdsmi.ctrli.cnt := (others => '0');
    t.cmdsmi.ctrli.insn.pc_8 := (others => '0');
    t.cmdsmi.ctrli.insn.insn := (others => '0');
    t.cmdsmi.ctrli.insn.insntyp := ade_typmem;
    t.cmdsmi.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdsmi.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdsmi.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdsmi.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdsmi.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdsmi.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdsmi.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdsmi.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdsmi.ctrli.insn.valid := '0';
    t.cmdsmi.ctrli.insn.id := (others => '0');
    t.cmdsmi.ctrli.ctrlo.nextinsn := '0';
    t.cmdsmi.ctrli.ctrlo.nextcnt := '0';
    t.cmdsmi.ctrli.ctrlo.hold := '0';
    t.cmdsmi.ctrlmulti.ctrlmemo.data1 := (others => '0');
    t.cmdsmi.ctrlmulti.ctrlmemo.data2 := (others => '0');
    t.cmdsmi.ctrlmulti.ctrlmemo.r1_src := acm_none;
    t.cmdsmi.ctrlmulti.ctrlmemo.r2_src := acm_none;
    t.cmdsmi.ctrlmulti.ctrlmemo.rd_src := acm_rdnone;
    t.cmdsmi.ctrlmulti.ctrlmemo.rsop_op1_src := apc_opsrc_through;
    t.cmdsmi.ctrlmulti.ctrlmemo.rsop_op2_src := apc_opsrc_through;
    t.cmdsmi.ctrlmulti.ctrlmemo.rsop_buf1_src := apc_bufsrc_none;
    t.cmdsmi.ctrlmulti.ctrlmemo.rsop_buf2_src := apc_bufsrc_none;
    t.cmdsmi.ctrlmulti.ctrlmemo.exop_data_src := apc_datasrc_aluout;
    t.cmdsmi.ctrlmulti.ctrlmemo.exop_buf_src := apc_exbufsrc_none;
    t.cmdsmi.ctrlmulti.ctrlmemo.meop_param.size := lmd_word;
    t.cmdsmi.ctrlmulti.ctrlmemo.meop_param.read := '0';
    t.cmdsmi.ctrlmulti.ctrlmemo.meop_param.lock := '0';
    t.cmdsmi.ctrlmulti.ctrlmemo.meop_param.writedata := '0';
    t.cmdsmi.ctrlmulti.ctrlmemo.meop_param.addrin := '0';
    t.cmdsmi.ctrlmulti.ctrlmemo.meop_param.signed := '0';
    t.cmdsmi.ctrlmulti.ctrlmemo.meop_enable := '0';
    t.cmdsmi.ctrlmulti.ival := (others => '0');
    t.cmdsmi.ctrlmulti.soff := (others => '0');
    t.cmdsmi.ctrlmulti.eoff := (others => '0');
    t.cmdsmi.ctrlmulti.reglist := (others => '0');
    t.cmdsmi.ctrlmulti.mem := '0';
    t.cmdsmi.ctrlmulti.dabort := '0';
    t.cmdswi.ctrli.cnt := (others => '0');
    t.cmdswi.ctrli.insn.pc_8 := (others => '0');
    t.cmdswi.ctrli.insn.insn := (others => '0');
    t.cmdswi.ctrli.insn.insntyp := ade_typmem;
    t.cmdswi.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdswi.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdswi.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdswi.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdswi.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdswi.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdswi.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdswi.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdswi.ctrli.insn.valid := '0';
    t.cmdswi.ctrli.insn.id := (others => '0');
    t.cmdswi.ctrli.ctrlo.nextinsn := '0';
    t.cmdswi.ctrli.ctrlo.nextcnt := '0';
    t.cmdswi.ctrli.ctrlo.hold := '0';
    t.cmdswi.ctrlmemo.data1 := (others => '0');
    t.cmdswi.ctrlmemo.data2 := (others => '0');
    t.cmdswi.ctrlmemo.r1_src := acm_none;
    t.cmdswi.ctrlmemo.r2_src := acm_none;
    t.cmdswi.ctrlmemo.rd_src := acm_rdnone;
    t.cmdswi.ctrlmemo.rsop_op1_src := apc_opsrc_through;
    t.cmdswi.ctrlmemo.rsop_op2_src := apc_opsrc_through;
    t.cmdswi.ctrlmemo.rsop_buf1_src := apc_bufsrc_none;
    t.cmdswi.ctrlmemo.rsop_buf2_src := apc_bufsrc_none;
    t.cmdswi.ctrlmemo.exop_data_src := apc_datasrc_aluout;
    t.cmdswi.ctrlmemo.exop_buf_src := apc_exbufsrc_none;
    t.cmdswi.ctrlmemo.meop_param.size := lmd_word;
    t.cmdswi.ctrlmemo.meop_param.read := '0';
    t.cmdswi.ctrlmemo.meop_param.lock := '0';
    t.cmdswi.ctrlmemo.meop_param.writedata := '0';
    t.cmdswi.ctrlmemo.meop_param.addrin := '0';
    t.cmdswi.ctrlmemo.meop_param.signed := '0';
    t.cmdswi.ctrlmemo.meop_enable := '0';
    t.cmdcri.ctrli.cnt := (others => '0');
    t.cmdcri.ctrli.insn.pc_8 := (others => '0');
    t.cmdcri.ctrli.insn.insn := (others => '0');
    t.cmdcri.ctrli.insn.insntyp := ade_typmem;
    t.cmdcri.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdcri.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdcri.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdcri.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdcri.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdcri.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdcri.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdcri.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdcri.ctrli.insn.valid := '0';
    t.cmdcri.ctrli.insn.id := (others => '0');
    t.cmdcri.ctrli.ctrlo.nextinsn := '0';
    t.cmdcri.ctrli.ctrlo.nextcnt := '0';
    t.cmdcri.ctrli.ctrlo.hold := '0';
    t.cmdcri.fromCP_busy := '0';
    t.cmdcli.ctrli.cnt := (others => '0');
    t.cmdcli.ctrli.insn.pc_8 := (others => '0');
    t.cmdcli.ctrli.insn.insn := (others => '0');
    t.cmdcli.ctrli.insn.insntyp := ade_typmem;
    t.cmdcli.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdcli.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdcli.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdcli.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdcli.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdcli.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdcli.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdcli.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdcli.ctrli.insn.valid := '0';
    t.cmdcli.ctrli.insn.id := (others => '0');
    t.cmdcli.ctrli.ctrlo.nextinsn := '0';
    t.cmdcli.ctrli.ctrlo.nextcnt := '0';
    t.cmdcli.ctrli.ctrlo.hold := '0';
    t.cmdcli.ctrlmemo.data1 := (others => '0');
    t.cmdcli.ctrlmemo.data2 := (others => '0');
    t.cmdcli.ctrlmemo.r1_src := acm_none;
    t.cmdcli.ctrlmemo.r2_src := acm_none;
    t.cmdcli.ctrlmemo.rd_src := acm_rdnone;
    t.cmdcli.ctrlmemo.rsop_op1_src := apc_opsrc_through;
    t.cmdcli.ctrlmemo.rsop_op2_src := apc_opsrc_through;
    t.cmdcli.ctrlmemo.rsop_buf1_src := apc_bufsrc_none;
    t.cmdcli.ctrlmemo.rsop_buf2_src := apc_bufsrc_none;
    t.cmdcli.ctrlmemo.exop_data_src := apc_datasrc_aluout;
    t.cmdcli.ctrlmemo.exop_buf_src := apc_exbufsrc_none;
    t.cmdcli.ctrlmemo.meop_param.size := lmd_word;
    t.cmdcli.ctrlmemo.meop_param.read := '0';
    t.cmdcli.ctrlmemo.meop_param.lock := '0';
    t.cmdcli.ctrlmemo.meop_param.writedata := '0';
    t.cmdcli.ctrlmemo.meop_param.addrin := '0';
    t.cmdcli.ctrlmemo.meop_param.signed := '0';
    t.cmdcli.ctrlmemo.meop_enable := '0';
    t.cmdcli.fromCP_busy := '0';
    t.cmdcli.fromCP_last := '0';
    t.cmdcsi.ctrli.cnt := (others => '0');
    t.cmdcsi.ctrli.insn.pc_8 := (others => '0');
    t.cmdcsi.ctrli.insn.insn := (others => '0');
    t.cmdcsi.ctrli.insn.insntyp := ade_typmem;
    t.cmdcsi.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdcsi.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdcsi.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdcsi.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdcsi.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdcsi.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdcsi.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdcsi.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdcsi.ctrli.insn.valid := '0';
    t.cmdcsi.ctrli.insn.id := (others => '0');
    t.cmdcsi.ctrli.ctrlo.nextinsn := '0';
    t.cmdcsi.ctrli.ctrlo.nextcnt := '0';
    t.cmdcsi.ctrli.ctrlo.hold := '0';
    t.cmdcsi.ctrlmemo.data1 := (others => '0');
    t.cmdcsi.ctrlmemo.data2 := (others => '0');
    t.cmdcsi.ctrlmemo.r1_src := acm_none;
    t.cmdcsi.ctrlmemo.r2_src := acm_none;
    t.cmdcsi.ctrlmemo.rd_src := acm_rdnone;
    t.cmdcsi.ctrlmemo.rsop_op1_src := apc_opsrc_through;
    t.cmdcsi.ctrlmemo.rsop_op2_src := apc_opsrc_through;
    t.cmdcsi.ctrlmemo.rsop_buf1_src := apc_bufsrc_none;
    t.cmdcsi.ctrlmemo.rsop_buf2_src := apc_bufsrc_none;
    t.cmdcsi.ctrlmemo.exop_data_src := apc_datasrc_aluout;
    t.cmdcsi.ctrlmemo.exop_buf_src := apc_exbufsrc_none;
    t.cmdcsi.ctrlmemo.meop_param.size := lmd_word;
    t.cmdcsi.ctrlmemo.meop_param.read := '0';
    t.cmdcsi.ctrlmemo.meop_param.lock := '0';
    t.cmdcsi.ctrlmemo.meop_param.writedata := '0';
    t.cmdcsi.ctrlmemo.meop_param.addrin := '0';
    t.cmdcsi.ctrlmemo.meop_param.signed := '0';
    t.cmdcsi.ctrlmemo.meop_enable := '0';
    t.cmdcsi.fromCP_busy := '0';
    t.cmdcsi.fromCP_last := '0';
    t.cmdbli.ctrli.cnt := (others => '0');
    t.cmdbli.ctrli.insn.pc_8 := (others => '0');
    t.cmdbli.ctrli.insn.insn := (others => '0');
    t.cmdbli.ctrli.insn.insntyp := ade_typmem;
    t.cmdbli.ctrli.insn.decinsn := type_arm_invalid;
    t.cmdbli.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.cmdbli.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdbli.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.cmdbli.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.cmdbli.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.cmdbli.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.cmdbli.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.cmdbli.ctrli.insn.valid := '0';
    t.cmdbli.ctrli.insn.id := (others => '0');
    t.cmdbli.ctrli.ctrlo.nextinsn := '0';
    t.cmdbli.ctrli.ctrlo.nextcnt := '0';
    t.cmdbli.ctrli.ctrlo.hold := '0';
    t.ctrli.cnt := (others => '0');
    t.ctrli.insn.pc_8 := (others => '0');
    t.ctrli.insn.insn := (others => '0');
    t.ctrli.insn.insntyp := ade_typmem;
    t.ctrli.insn.decinsn := type_arm_invalid;
    t.ctrli.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.ctrli.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.ctrli.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.ctrli.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.ctrli.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.ctrli.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.ctrli.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.ctrli.insn.valid := '0';
    t.ctrli.insn.id := (others => '0');
    t.ctrli.ctrlo.nextinsn := '0';
    t.ctrli.ctrlo.nextcnt := '0';
    t.ctrli.ctrlo.hold := '0';
    t.ctrlo.nextinsn := '0';
    t.ctrlo.nextcnt := '0';
    t.ctrlo.hold := '0';
    t.pctrl.insn.pc_8 := (others => '0');
    t.pctrl.insn.insn := (others => '0');
    t.pctrl.insn.insntyp := ade_typmem;
    t.pctrl.insn.decinsn := type_arm_invalid;
    t.pctrl.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.pctrl.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.pctrl.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.pctrl.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.pctrl.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.pctrl.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.pctrl.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.pctrl.insn.valid := '0';
    t.pctrl.insn.id := (others => '0');
    t.pctrl.valid := '0';
    t.pctrl.rr.dummy := '0';
    t.pctrl.rs.rsop_op1_src := apc_opsrc_through;
    t.pctrl.rs.rsop_op2_src := apc_opsrc_through;
    t.pctrl.rs.rsop_buf1_src := apc_bufsrc_none;
    t.pctrl.rs.rsop_buf2_src := apc_bufsrc_none;
    t.pctrl.rs.rsop_styp := ash_styp_none;
    t.pctrl.rs.rsop_sdir := ash_sdir_snone;
    t.pctrl.rs.rs_shieftcarryout := '0';
    t.pctrl.ex.exop_aluop := (others => '0');
    t.pctrl.ex.exop_data_src := apc_datasrc_aluout;
    t.pctrl.ex.exop_buf_src := apc_exbufsrc_none;
    t.pctrl.ex.exop_setcpsr := '0';
    t.pctrl.ex.ex_cpsr.ex.n := '0';
    t.pctrl.ex.ex_cpsr.ex.z := '0';
    t.pctrl.ex.ex_cpsr.ex.c := '0';
    t.pctrl.ex.ex_cpsr.ex.v := '0';
    t.pctrl.ex.ex_cpsr.wr.i := '0';
    t.pctrl.ex.ex_cpsr.wr.f := '0';
    t.pctrl.ex.ex_cpsr.wr.t := '0';
    t.pctrl.ex.ex_cpsr.wr.mode := (others => '0');
    t.pctrl.dm.dummy := '0';
    t.pctrl.me.meop_enable := '0';
    t.pctrl.me.meop_param.size := lmd_word;
    t.pctrl.me.meop_param.read := '0';
    t.pctrl.me.meop_param.lock := '0';
    t.pctrl.me.meop_param.writedata := '0';
    t.pctrl.me.meop_param.addrin := '0';
    t.pctrl.me.meop_param.signed := '0';
    t.pctrl.me.mexc := '0';
    t.pctrl.wr.wrop_rd := (others => '0');
    t.pctrl.wr.wrop_rdvalid := '0';
    t.pctrl.wr.wrop_setspsr := '0';
    t.pctrl.wr.wrop_trap.traptype := apm_trap_reset;
    t.pctrl.wr.wrop_trap.trap := '0';
    t.pctrl.data1 := (others => '0');
    t.pctrl.data2 := (others => '0');
    t.pctrl_bypass.insn.pc_8 := (others => '0');
    t.pctrl_bypass.insn.insn := (others => '0');
    t.pctrl_bypass.insn.insntyp := ade_typmem;
    t.pctrl_bypass.insn.decinsn := type_arm_invalid;
    t.pctrl_bypass.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.pctrl_bypass.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.pctrl_bypass.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.pctrl_bypass.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.pctrl_bypass.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.pctrl_bypass.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.pctrl_bypass.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.pctrl_bypass.insn.valid := '0';
    t.pctrl_bypass.insn.id := (others => '0');
    t.pctrl_bypass.valid := '0';
    t.pctrl_bypass.rr.dummy := '0';
    t.pctrl_bypass.rs.rsop_op1_src := apc_opsrc_through;
    t.pctrl_bypass.rs.rsop_op2_src := apc_opsrc_through;
    t.pctrl_bypass.rs.rsop_buf1_src := apc_bufsrc_none;
    t.pctrl_bypass.rs.rsop_buf2_src := apc_bufsrc_none;
    t.pctrl_bypass.rs.rsop_styp := ash_styp_none;
    t.pctrl_bypass.rs.rsop_sdir := ash_sdir_snone;
    t.pctrl_bypass.rs.rs_shieftcarryout := '0';
    t.pctrl_bypass.ex.exop_aluop := (others => '0');
    t.pctrl_bypass.ex.exop_data_src := apc_datasrc_aluout;
    t.pctrl_bypass.ex.exop_buf_src := apc_exbufsrc_none;
    t.pctrl_bypass.ex.exop_setcpsr := '0';
    t.pctrl_bypass.ex.ex_cpsr.ex.n := '0';
    t.pctrl_bypass.ex.ex_cpsr.ex.z := '0';
    t.pctrl_bypass.ex.ex_cpsr.ex.c := '0';
    t.pctrl_bypass.ex.ex_cpsr.ex.v := '0';
    t.pctrl_bypass.ex.ex_cpsr.wr.i := '0';
    t.pctrl_bypass.ex.ex_cpsr.wr.f := '0';
    t.pctrl_bypass.ex.ex_cpsr.wr.t := '0';
    t.pctrl_bypass.ex.ex_cpsr.wr.mode := (others => '0');
    t.pctrl_bypass.dm.dummy := '0';
    t.pctrl_bypass.me.meop_enable := '0';
    t.pctrl_bypass.me.meop_param.size := lmd_word;
    t.pctrl_bypass.me.meop_param.read := '0';
    t.pctrl_bypass.me.meop_param.lock := '0';
    t.pctrl_bypass.me.meop_param.writedata := '0';
    t.pctrl_bypass.me.meop_param.addrin := '0';
    t.pctrl_bypass.me.meop_param.signed := '0';
    t.pctrl_bypass.me.mexc := '0';
    t.pctrl_bypass.wr.wrop_rd := (others => '0');
    t.pctrl_bypass.wr.wrop_rdvalid := '0';
    t.pctrl_bypass.wr.wrop_setspsr := '0';
    t.pctrl_bypass.wr.wrop_trap.traptype := apm_trap_reset;
    t.pctrl_bypass.wr.wrop_trap.trap := '0';
    t.pctrl_bypass.data1 := (others => '0');
    t.pctrl_bypass.data2 := (others => '0');
    t.commit := '0';
    t.insn := (others => '0');
    t.trap.traptype := apm_trap_reset;
    t.trap.trap := '0';
    t.nextmicro := '0';
    t.mem := '0';
    t.micro.pctrl.insn.pc_8 := (others => '0');
    t.micro.pctrl.insn.insn := (others => '0');
    t.micro.pctrl.insn.insntyp := ade_typmem;
    t.micro.pctrl.insn.decinsn := type_arm_invalid;
    t.micro.pctrl.insn.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.micro.pctrl.insn.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.micro.pctrl.insn.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.micro.pctrl.insn.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.micro.pctrl.insn.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.micro.pctrl.insn.am.LDSTAMxLSV4AM_uacc := '0';
    t.micro.pctrl.insn.am.LDSTAMxLSV4AM_wb := '0';
    t.micro.pctrl.insn.valid := '0';
    t.micro.pctrl.insn.id := (others => '0');
    t.micro.pctrl.valid := '0';
    t.micro.pctrl.rr.dummy := '0';
    t.micro.pctrl.rs.rsop_op1_src := apc_opsrc_through;
    t.micro.pctrl.rs.rsop_op2_src := apc_opsrc_through;
    t.micro.pctrl.rs.rsop_buf1_src := apc_bufsrc_none;
    t.micro.pctrl.rs.rsop_buf2_src := apc_bufsrc_none;
    t.micro.pctrl.rs.rsop_styp := ash_styp_none;
    t.micro.pctrl.rs.rsop_sdir := ash_sdir_snone;
    t.micro.pctrl.rs.rs_shieftcarryout := '0';
    t.micro.pctrl.ex.exop_aluop := (others => '0');
    t.micro.pctrl.ex.exop_data_src := apc_datasrc_aluout;
    t.micro.pctrl.ex.exop_buf_src := apc_exbufsrc_none;
    t.micro.pctrl.ex.exop_setcpsr := '0';
    t.micro.pctrl.ex.ex_cpsr.ex.n := '0';
    t.micro.pctrl.ex.ex_cpsr.ex.z := '0';
    t.micro.pctrl.ex.ex_cpsr.ex.c := '0';
    t.micro.pctrl.ex.ex_cpsr.ex.v := '0';
    t.micro.pctrl.ex.ex_cpsr.wr.i := '0';
    t.micro.pctrl.ex.ex_cpsr.wr.f := '0';
    t.micro.pctrl.ex.ex_cpsr.wr.t := '0';
    t.micro.pctrl.ex.ex_cpsr.wr.mode := (others => '0');
    t.micro.pctrl.dm.dummy := '0';
    t.micro.pctrl.me.meop_enable := '0';
    t.micro.pctrl.me.meop_param.size := lmd_word;
    t.micro.pctrl.me.meop_param.read := '0';
    t.micro.pctrl.me.meop_param.lock := '0';
    t.micro.pctrl.me.meop_param.writedata := '0';
    t.micro.pctrl.me.meop_param.addrin := '0';
    t.micro.pctrl.me.meop_param.signed := '0';
    t.micro.pctrl.me.mexc := '0';
    t.micro.pctrl.wr.wrop_rd := (others => '0');
    t.micro.pctrl.wr.wrop_rdvalid := '0';
    t.micro.pctrl.wr.wrop_setspsr := '0';
    t.micro.pctrl.wr.wrop_trap.traptype := apm_trap_reset;
    t.micro.pctrl.wr.wrop_trap.trap := '0';
    t.micro.pctrl.data1 := (others => '0');
    t.micro.pctrl.data2 := (others => '0');
    t.micro.valid := '0';
    t.micro.r1 := (others => '0');
    t.micro.r2 := (others => '0');
    t.micro.r1_valid := '0';
    t.micro.r2_valid := '0';
    t.am.DAPRAM_typ := ade_DAPRAM_simm;
    t.am.LDSTAM_typ := ade_LDSTAMxLSV4AM_imm;
    t.am.LSV4AM_typ := ade_LDSTAMxLSV4AM_imm;
    t.am.LDSTAMxLSV4AM_pos := ade_pre;
    t.am.DAPRAMxLDSTAM_sdir := ash_sdir_snone;
    t.am.LDSTAMxLSV4AM_uacc := '0';
    t.am.LDSTAMxLSV4AM_wb := '0';
    t.r1_src := acm_none;
    t.r2_src := acm_none;
    t.rd_src := acm_rdnone;
    t.rn := (others => '0');
    t.rm := (others => '0');
    t.rd := (others => '0');
    t.rs := (others => '0');
    t.rlink := (others => '0');
    t.rpc := (others => '0');
    t.nr := (others => '0');
    t.nr_i := 0;
    t.nr_c := '0';
    t.startoff := (others => '0');
    t.endoff := (others => '0');
    t.incval := (others => '0');
    t.m1 := (others => '0');
    t.m2 := (others => '0');
    t.md := (others => '0');
    t.m1_valid := '0';
    t.m2_valid := '0';
    t.rr1 := (others => '0');
    t.rr2 := (others => '0');
    t.rrd := (others => '0');
    t.rmode := (others => '0');

    -- $(/init-automatically-generated-for-synthesis:(t:armiu_drstg_tmp_type))
    
    v := r;
    t.commit := not i.flush_v;

    t.insn := i.fromDE_insn_r.insn.insn;
    t.am := i.fromDE_insn_r.insn.am;
    t.rn := t.insn(ADE_RN_U downto ADE_RN_D);
    t.rm := t.insn(ADE_RM_U downto ADE_RM_D);
    t.rs := t.insn(ADE_SREG_U downto ADE_SREG_D);
    t.rd := t.insn(ADE_RD_U downto ADE_RD_D);
    t.rlink := APM_REG_LINK;
    t.r1_src    := acm_none;
    t.r2_src    := acm_none;
    t.rmode := i.pstate.fromEX_cpsr_r.wr.mode;
    t.m1 := t.rd;
    t.m2 := t.rd;
    t.md := t.rd;
    t.nr_c := '1';
    
    -- cmd lm, sm:
    t.nr := als_getnextpos(t.insn, r.reglist);
    t.nr_i := lin_convint(t.nr);

    als_offsets (t.insn, t.startoff, t.endoff, t.incval );
    
    t.mem := '0';
    if apc_is_mem(i.pstate.fromRR_pctrl_r) or
       apc_is_mem(i.pstate.fromRS_pctrl_r) or
       apc_is_mem(i.pstate.fromEX_pctrl_r) or
       apc_is_mem(i.pstate.fromDM_pctrl_r) or
       apc_is_mem(i.pstate.fromME_pctrl_r) or
       apc_is_mem(i.pstate.fromWR_pctrl_r) then
      t.mem := '1';
    end if;

    t.ctrlo.nextinsn := '1';
    t.ctrlo.nextcnt := '1';
    t.ctrlo.hold := '0';
    
    t.ctrli.cnt := r.cnt;
    t.ctrli.insn := i.fromDE_insn_r.insn;
    t.ctrli.ctrlo := t.ctrlo;

    t.pctrl.insn := i.fromDE_insn_r.insn;
    t.pctrl.ex.exop_aluop := i.fromDE_insn_r.insn.insn(ADE_OP_U downto ADE_OP_D);
    t.pctrl_bypass := t.pctrl;
    
    case i.fromDE_insn_r.insn.decinsn is
      when type_arm_invalid => 
      when type_arm_nop =>
        
-------------------------------------------------------------------------------
        
      when type_arm_mrs | 
           type_arm_msr =>

        t.cmdsri.ctrli := t.ctrli;
        t.cmdsri.deid := i.fromDE_insn_r.insn.id;
        t.cmdsri.exid := i.pstate.fromEX_pctrl_r.insn.id;
        t.cmdsri.exvalid := i.pstate.fromEX_pctrl_r.valid;
        t.cmdsri.wrid := i.pstate.fromWR_pctrl_r.insn.id;
        t.cmdsri.wrvalid := i.pstate.fromWR_pctrl_r.valid;
        t.ctrlo := cmdsro.ctrlo;
        
        t.r1_src := acm_none;
        t.r2_src := cmdsro.r2_src;
        t.rd_src := cmdsro.rd_src;
        
         -- rsstg: 
        t.pctrl.rs.rsop_op1_src := apc_opsrc_none;
        t.pctrl.rs.rsop_op2_src := cmdsro.rsop_op2_src;
        t.pctrl.rs.rsop_styp := cmdsro.rsop_styp;
        t.pctrl.rs.rsop_sdir := cmdsro.rsop_sdir;

        -- exstg:
        t.pctrl.ex.exop_setcpsr := cmdsro.exop_setcpsr;
        
-------------------------------------------------------------------------------
        
      when type_arm_bx => 
      when type_arm_mul => 
      when type_arm_mla => 
      when type_arm_sumull => 
      when type_arm_sumlal =>
        
-------------------------------------------------------------------------------
        
      when type_arm_teq |  
           type_arm_cmn |  
           type_arm_tst |  
           type_arm_cmp |
           type_arm_and |
           type_arm_sub |
           type_arm_eor |
           type_arm_rsb |
           type_arm_add |
           type_arm_orr |
           type_arm_bic |
           type_arm_mov |
           type_arm_mvn | 
           type_arm_sbc |  
           type_arm_adc |  
           type_arm_rsc =>
        
        t.cmdali.ctrli := t.ctrli;
        
        t.ctrlo := cmdalo.ctrlo;
        
        -- rrstg
        t.r1_src := cmdalo.r1_src;      -- (micro.r1)
        t.r2_src := cmdalo.r2_src;      -- (micro.r2)
        t.rd_src := cmdalo.rd_src;      -- (pctrl.wr.wrop_rd)
  
        -- rsstg:
        t.pctrl.rs.rsop_op1_src := cmdalo.rsop_op1_src; -- EXSTG operand1 source 
        t.pctrl.rs.rsop_op2_src := cmdalo.rsop_op2_src; -- EXSTG operand2 source 
        t.pctrl.rs.rsop_buf2_src := cmdalo.rsop_buf2_src; -- RSSTG buffer1 source
        t.pctrl.rs.rsop_styp := ash_styp_none;
        t.pctrl.rs.rsop_sdir := t.am.DAPRAMxLDSTAM_sdir;
        case t.am.DAPRAM_typ is
          when ade_DAPRAM_immrot => t.pctrl.rs.rsop_styp := ash_styp_immrot;
          when ade_DAPRAM_simm   => t.pctrl.rs.rsop_styp := ash_styp_simm;
          when ade_DAPRAM_sreg   => t.pctrl.rs.rsop_styp := ash_styp_sreg;
          when others => null;
        end case;
        
        t.pctrl.ex.exop_setcpsr := t.insn(ADE_SETCPSR_C);
        
-------------------------------------------------------------------------------
        
      when type_arm_str1 | type_arm_str2 | type_arm_str3 |
           type_arm_strhb =>

        t.cmdsti.ctrli := t.ctrli;
        
        t.ctrlo := cmdsto.ctrlo;
        
        acm_initmempctrl(t.pctrl, t.r1_src, t.r2_src, t.rd_src, cmdsto.ctrlmemo );
        
        case i.fromDE_insn_r.insn.decinsn is
          when type_arm_str1 |
               type_arm_str2 |
               type_arm_str3  =>
            als_LDSTAM_init_size(t.insn, t.pctrl);
          when others =>
            als_LSV4AM_init_size(t.insn, t.pctrl);
        end case;

        als_LDSTAMxLSV4AM_init_addsub(t.insn, t.pctrl);
        
        t.pctrl.rs.rsop_styp := cmdsto.rsop_styp; -- RSSTG shieft op 
        t.pctrl.rs.rsop_sdir := cmdsto.rsop_sdir; -- RSSTG shieft dir 
      
-------------------------------------------------------------------------------
        
      when type_arm_ldr1 |
           type_arm_ldrhb =>
        
        t.cmdldi.ctrli := t.ctrli;
        
        t.ctrlo := cmdldo.ctrlo;
        
        acm_initmempctrl(t.pctrl, t.r1_src, t.r2_src, t.rd_src, cmdldo.ctrlmemo );
        
        case i.fromDE_insn_r.insn.decinsn is
          when type_arm_ldr1 =>
            als_LDSTAM_init_size(t.insn, t.pctrl);
          when others =>
            als_LSV4AM_init_size(t.insn, t.pctrl);
        end case;
        
        als_LDSTAMxLSV4AM_init_addsub(t.insn, t.pctrl);
        
        t.pctrl.rs.rsop_styp := cmdldo.rsop_styp; -- RSSTG shieft op 
        t.pctrl.rs.rsop_sdir := cmdldo.rsop_sdir; -- RSSTG shieft dir 
        
-------------------------------------------------------------------------------
        
      when type_arm_stm =>

        t.cmdsmi.ctrli := t.ctrli;
        
        t.cmdsmi.ctrlmulti.ival := t.incval;
        t.cmdsmi.ctrlmulti.soff := t.startoff;
        t.cmdsmi.ctrlmulti.eoff := t.endoff;
        t.cmdsmi.ctrlmulti.reglist := r.reglist;
        t.cmdsmi.ctrlmulti.mem := t.mem;
        t.cmdsmi.ctrlmulti.dabort := i.fromWR_dabort_v;
        
        t.ctrlo := cmdsmo.ctrlo;
        
        acm_initmempctrl(t.pctrl, t.r1_src, t.r2_src, t.rd_src, cmdsmo.ctrlmemo );
        
        t.pctrl.ex.exop_aluop := ADE_OP_ADD;
        
        t.m1 := t.nr;               -- acm_local
        t.nr_c := r.cnt(0);         -- every second cycle
      
-------------------------------------------------------------------------------
        
      when type_arm_ldm =>
        
        t.cmdlmi.ctrli := t.ctrli;
        
        t.cmdlmi.ctrlmulti.ival := t.incval;
        t.cmdlmi.ctrlmulti.soff := t.startoff;
        t.cmdlmi.ctrlmulti.eoff := t.endoff;
        t.cmdlmi.ctrlmulti.reglist := r.reglist;
        t.cmdlmi.ctrlmulti.mem := t.mem;
        t.cmdlmi.ctrlmulti.dabort := i.fromWR_dabort_v;
        
        t.ctrlo := cmdlmo.ctrlo;
        
        acm_initmempctrl(t.pctrl, t.r1_src, t.r2_src, t.rd_src, cmdlmo.ctrlmemo );
        
        t.pctrl.ex.exop_aluop := ADE_OP_ADD;
        
        t.md := t.nr;                   -- acm_rdlocal
        
-------------------------------------------------------------------------------
        
      when type_arm_b =>

        t.ctrlo := cmdblo.ctrlo;

        t.r1_src := cmdblo.r1_src;
        t.r2_src := cmdblo.r2_src;
        t.rd_src := cmdblo.rd_src;
        t.pctrl.data2 := cmdblo.data2;
        
        -- rsstg:
        t.pctrl.rs.rsop_op2_src := cmdblo.rsop_op2_src;
        -- exstg:
        t.pctrl.ex.exop_aluop := ADE_OP_ADD;
        
        t.m1 := APM_REG_PC;            -- acm_local
      
-------------------------------------------------------------------------------
        
      when type_arm_swp =>
        
        t.cmdswi.ctrli := t.ctrli;

        t.ctrlo := cmdswo.ctrlo;
        
        t.pctrl.ex.exop_aluop := ADE_OP_ORR;
        
        acm_initmempctrl(t.pctrl, t.r1_src, t.r2_src, t.rd_src, cmdswo.ctrlmemo );
        
-------------------------------------------------------------------------------
        
      when type_arm_stc =>
        t.cmdcsi.ctrli := t.ctrli;

        t.cmdcsi.fromCP_busy := i.fromCPDE_busy;
        t.cmdcsi.fromCP_last := i.fromCPDE_last;
        t.ctrlo := cmdcso.ctrlo;
        
      when type_arm_ldc =>
        t.cmdcli.ctrli := t.ctrli;
        t.cmdcli.fromCP_busy := i.fromCPDE_busy;
        t.cmdcli.fromCP_last := i.fromCPDE_last;
        t.ctrlo := cmdclo.ctrlo;
        
      when type_arm_mrc |
           type_arm_mcr =>

        t.cmdcri.fromCP_busy := i.fromCPDE_busy;
        t.cmdcri.ctrli := t.ctrli;
        t.ctrlo := cmdcro.ctrlo;
        t.r1_src := cmdcro.r1_src;
        t.rd_src := cmdcro.rd_src;
        
        t.pctrl.ex.exop_data_src := apc_datasrc_none;  -- keep pctrl.data1
        
      when type_arm_swi =>
        t.trap.trap := '1';
        t.trap.traptype := apm_trap_swi;
        
      when type_arm_undefined =>
        t.trap.trap := '1';
        t.trap.traptype := apm_trap_undef;
        
      when type_arm_cdp =>
      when others => 
    end case;
    
    if i.fromDE_insn_r.trap = '1' then
      t.trap.trap := '1';
      t.trap.traptype := apm_trap_prefch;
    end if;
    
    -- traps
    if t.trap.trap = '1' then

      t.m1_valid := '0';
      t.m2_valid := '0';

      -- [frame:] r14 calculation 
      --
      --            RRSTG       RSSTG       EXSTG       DMSTG       MESTG       WRSTG
      --       --+-----------+-----------+-----------+-----------+-----------+----------+
      -- <pc+8>->+-----------+----------op1          |           |           |
      --         |           |           | \         |           |           |
      --         |  (regread)| (noshift) | +(aluop)  |  (trans)  | (dcache)  | +->(write)
      --         |           |           | /   |     |           |           | |
      --         |           |  <offset>op2    |     |           |           | |
      --       --+-----------+-----------+-----+-----+-----------+-----------+-+--------+
      --                                       |                               |
      --         pctrl.data1 (as r14-data) :   +-------------------------------+

      t.pctrl := t.pctrl_bypass;
      t.r1_src := acm_none;
      t.r2_src := acm_none;
      t.rd_src := acm_rdnone;
      
      t.pctrl.rs.rsop_op1_src := apc_opsrc_none;
      t.pctrl.rs.rsop_op2_src := apc_opsrc_none;
      t.pctrl.ex.exop_data_src := apc_datasrc_aluout;
      t.pctrl.data1 := i.fromDE_insn_r.insn.pc_8;
      t.pctrl.data2 := (others => '0');
      
      case t.trap.traptype is
        when apm_trap_reset    =>
          
-- $(del)
-- R14_svc = UNPREDICTABLE value
-- SPSR_svc = UNPREDICTABLE value
-- CPSR[4:0] = 0b10011 /* Enter Supervisor mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- CPSR[6] = 1 /* Disable fast interrupts */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0000
-- else
-- PC = 0x00000000
-- $(/del)
          
        when apm_trap_undef =>

-- $(del)
-- R14_und = address of next instruction after the undefined instruction
-- SPSR_und = CPSR
-- CPSR[4:0] = 0b11011 /* Enter Undefined mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0004
-- else
-- PC = 0x00000004
-- $(/del)
          
          t.pctrl.data2 := LIN_MINFOUR;
          
        when apm_trap_swi      =>

-- $(del)
-- R14_svc = address of next instruction after the SWI instruction
-- SPSR_svc = CPSR
-- CPSR[4:0] = 0b10011 /* Enter Supervisor mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0008
-- else
-- PC = 0x00000008
-- $(/del)
          
          t.pctrl.data2 := LIN_MINFOUR;
          
        when apm_trap_prefch =>

-- $(del)
-- R14_abt = address of the aborted instruction + 4
-- SPSR_abt = CPSR
-- CPSR[4:0] = 0b10111 /* Enter Abort mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF000C
-- else
-- PC = 0x0000000C
-- $(/del)
          
          t.pctrl.data2 := LIN_MINFOUR;
          
        when apm_trap_dabort   =>

-- $(del)
-- R14_abt = address of the aborted instruction + 8
-- SPSR_abt = CPSR
-- CPSR[4:0] = 0b10111 /* Enter Abort mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0010
-- else
-- PC = 0x00000010
-- $(/del)
          -- will not happen (later in pipeline)
          -- pragma translate_off
          assert false report "Wrong initialization of trap type" severity failure;
          -- pragma translate_on
          
        when apm_trap_irq      =>

-- $(del)
-- R14_irq = address of next instruction to be executed + 4
-- SPSR_irq = CPSR
-- CPSR[4:0] = 0b10010 /* Enter IRQ mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- /* CPSR[6] is unchanged */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF0018
-- else
-- PC = 0x00000018
-- $(/del)

          --v.pctrl.MESTGxWRSTG_data := t.regshiefto.RSSTG_pc_4;
          
        when apm_trap_fiq      =>

-- $(del)
-- R14_fiq = address of next instruction to be executed + 4
-- SPSR_fiq = CPSR
-- CPSR[4:0] = 0b10001 /* Enter FIQ mode */
-- CPSR[5] = 0 /* Execute in ARM state */
-- CPSR[6] = 1 /* Disable fast interrupts */
-- CPSR[7] = 1 /* Disable normal interrupts */
-- if high vectors configured then
-- PC = 0xFFFF001C
-- else
-- PC = 0x0000001C
-- $(/del)

          --v.pctrl.MESTGxWRSTG_data := t.regshiefto.RSSTG_pc_4;
          
        when others            => 
      end case;

    end if;
    t.pctrl.wr.wrop_trap := t.trap;
    
    -- src registers
    t.m1_valid  := '1';
    case t.r1_src is
      when acm_rrn  => t.m1 := t.rn; 
      when acm_rrm  => t.m1 := t.rm; 
      when acm_rrs  => t.m1 := t.rs; 
      when acm_rrd  => t.m1 := t.rd; 
      when acm_none => t.m1_valid := '0';
      when acm_local => t.m1_valid := '1';
      when others => null;
    end case;
    t.rr1 := apm_bankreg(t.rmode,t.m1);
    
    t.m2_valid  := '1';
    case t.r2_src is
      when acm_rrn  => t.m2 := t.rn; 
      when acm_rrm  => t.m2 := t.rm; 
      when acm_rrs  => t.m2 := t.rs; 
      when acm_rrd  => t.m2 := t.rd; 
      when acm_none => t.m2_valid := '0';
      when acm_local => t.m2_valid := '1';
      when others => 
    end case;
    t.rr2 := apm_bankreg(t.rmode,t.m2);

    t.pctrl.wr.wrop_rdvalid := '1';
    case t.rd_src is
      when acm_rdrrn  => t.md := t.rn; 
      when acm_rdrrd  => t.md := t.rd; 
      when acm_rdpc   => t.md := APM_REG_PC; 
      when acm_rdlink => t.md := APM_REG_LINK; 
      when acm_rdnone => t.pctrl.wr.wrop_rdvalid := '0'; 
      when acm_rdlocal => t.pctrl.wr.wrop_rdvalid := '1'; 
      when others => 
    end case;
    t.pctrl.wr.wrop_rd := apm_bankreg(t.rmode,t.md);
    
    t.micro.pctrl := t.pctrl;
    t.micro.r1 := t.rr1;
    t.micro.r2 := t.rr2;
    t.micro.r1_valid := t.m1_valid;
    t.micro.r2_valid := t.m2_valid;
    t.micro.pctrl.valid := '0';
    t.micro.valid := '1';
    
    -- microcode counter
    t.nextmicro := i.fromRR_nextmicro_v;
    
    if t.ctrlo.hold = '1' then
      t.nextmicro := '0';
      t.micro.valid := '0';
    end if;
        
    -- invalid insn & pipeline flush
    if (i.fromDE_insn_r.insn.valid = '0') or
       (not (t.commit = '1')) then
      t.ctrlo.nextinsn := '1';
      t.nextmicro := '1';
      t.micro.valid := '0';
    end if;
    t.o.toRR_micro_v := t.micro;
    
    if i.pstate.hold_r.hold = '0' then
      if t.nextmicro = '1' then
        if t.ctrlo.nextinsn = '1' then
          v.cnt := (others => '0');
          v.reglist := i.fromDE_insn_v.insn.insn(ADE_REGLIST_U downto ADE_REGLIST_D);
        else
          if t.ctrlo.nextcnt = '1' then
            lin_incdec(r.cnt,v.cnt,'1','1');
            if t.nr_c = '1' then
              v.reglist(t.nr_i) := '0';
            end if;
          end if;
        end if;
      else
        t.ctrlo.nextinsn := '0';
      end if;
    end if;
    
    
    t.o.nextinsn_v := t.ctrlo.nextinsn;
    t.o.id := i.fromDE_insn_r.insn.id;

    -- reset
    if ( rst = '0' ) then
    end if;
    
    c <= v;

    cmdali <= t.cmdali;
    cmdsri <= t.cmdsri;
    cmdldi <= t.cmdldi;
    cmdsti <= t.cmdsti;
    cmdlmi <= t.cmdlmi;
    cmdsmi <= t.cmdsmi;
    cmdswi <= t.cmdswi;
    cmdcri <= t.cmdcri;
    cmdcli <= t.cmdcli;
    cmdcsi <= t.cmdcsi;
    cmdbli <= t.cmdbli;
    
    o <= t.o;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
    vdbg.dbgpmode := adg_todbgpmode(i.pstate.fromEX_cpsr_r.wr.mode);
    vdbg.dbgrmode := adg_todbgpmode(t.rmode);
    cdbg <= vdbg;
    -- pragma translate_on  
    
  end process p0;
    
  pregs : process (clk, c)
  begin
    if rising_edge(clk) then
      r <= c;
      -- pragma translate_off
      rdbg <= cdbg;
      -- pragma translate_on
    end if;
  end process;

  al0: armcmd_al port map ( rst, clk, cmdali, cmdalo );
  sr0: armcmd_sr port map ( rst, clk, cmdsri, cmdsro );
  ld0: armcmd_ld port map ( rst, clk, cmdldi, cmdldo );
  st0: armcmd_st port map ( rst, clk, cmdsti, cmdsto );
  lm0: armcmd_lm port map ( rst, clk, cmdlmi, cmdlmo );
  sm0: armcmd_sm port map ( rst, clk, cmdsmi, cmdsmo );
  sw0: armcmd_sw port map ( rst, clk, cmdswi, cmdswo );
  cr0: armcmd_cr port map ( rst, clk, cmdcri, cmdcro );
  cl0: armcmd_cl port map ( rst, clk, cmdcli, cmdclo );
  cs0: armcmd_cs port map ( rst, clk, cmdcsi, cmdcso );
  bl0: armcmd_bl port map ( rst, clk, cmdbli, cmdblo );

end rtl;

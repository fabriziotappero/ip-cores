-- $(lic)
-- $(help_generic)
-- $(help_local)

library ieee;
use ieee.std_logic_1164.all;
use work.corelib.all;
use work.config.all;
use work.memdef.all;
use work.arm_comp.all;
use work.armpctrl.all;
use work.armcoproc.all;
use work.armcp_comp.all;
use work.cache_comp.all;

entity armiu is
  port ( 
    rst     : in  std_logic;
    clk     : in  std_logic;
    clkn    : in  std_logic;
    hold    : in cli_hold;
    ici     : out genic_type_in;
    ico     : in genic_type_out;
    dci     : out gendc_type_in;
    dco     : in gendc_type_out;
    i       : in  armiu_typ_in;
    o       : out armiu_typ_out
    );
end armiu;

architecture rtl of armiu is

  type armiu_tmp_type is record
    o       : armiu_typ_out;
    pstate  : apc_pstate;
    armiu_imstgi : armiu_imstg_typ_in;
    armiu_festgi : armiu_festg_typ_in;
    armiu_destgi : armiu_destg_typ_in;
    armiu_drstgi : armiu_drstg_typ_in;
    armiu_rrstgi : armiu_rrstg_typ_in;
    armiu_rsstgi : armiu_rsstg_typ_in;
    armiu_exstgi : armiu_exstg_typ_in;
    armiu_dmstgi : armiu_dmstg_typ_in;
    armiu_mestgi : armiu_mestg_typ_in;
    armiu_wrstgi : armiu_wrstg_typ_in;
    drid : std_logic_vector(2 downto 0);
    rrid : std_logic_vector(2 downto 0);
    rsid : std_logic_vector(2 downto 0);
    exid : std_logic_vector(2 downto 0);
    dmid : std_logic_vector(2 downto 0);
    meid : std_logic_vector(2 downto 0);
    wrid : std_logic_vector(2 downto 0);
    exclear : std_logic;
    wrclear : std_logic;
    addrvir : std_logic_vector(31 downto 0);
    branch : std_logic;
    
    ici : genic_type_in;
    dci : gendc_type_in;
    
    cpsyci  : aco_in;
  end record;
  type armiu_reg_type is record
    dummy      : std_logic;
  end record;
  type armiu_dbg_type is record
     dummy : std_logic;
     -- pragma translate_off
     dbg : armiu_tmp_type;
     -- pragma translate_on
  end record;
  signal r, c       : armiu_reg_type;
  signal rdbg, cdbg : armiu_dbg_type;

  -- iu
  signal armiu_imstgi : armiu_imstg_typ_in;
  signal armiu_imstgo : armiu_imstg_typ_out;
  signal armiu_festgi : armiu_festg_typ_in;
  signal armiu_festgo : armiu_festg_typ_out;
  signal armiu_destgi : armiu_destg_typ_in;
  signal armiu_destgo : armiu_destg_typ_out;
  signal armiu_drstgi : armiu_drstg_typ_in;
  signal armiu_drstgo : armiu_drstg_typ_out;
  signal armiu_rrstgi : armiu_rrstg_typ_in;
  signal armiu_rrstgo : armiu_rrstg_typ_out;
  signal armiu_rsstgi : armiu_rsstg_typ_in;
  signal armiu_rsstgo : armiu_rsstg_typ_out;
  signal armiu_exstgi : armiu_exstg_typ_in;
  signal armiu_exstgo : armiu_exstg_typ_out;
  signal armiu_dmstgi : armiu_dmstg_typ_in;
  signal armiu_dmstgo : armiu_dmstg_typ_out;
  signal armiu_mestgi : armiu_mestg_typ_in;
  signal armiu_mestgo : armiu_mestg_typ_out;
  signal armiu_wrstgi : armiu_wrstg_typ_in;
  signal armiu_wrstgo : armiu_wrstg_typ_out;

  -- coprocessors
  signal cpsyci  : aco_in;
  signal cpsyco  : aco_out;

begin  
    
  p0: process (clk, clkn, rst, r, hold, i, ico, dco,
               armiu_imstgo, armiu_festgo, armiu_destgo, armiu_drstgo,
               armiu_rrstgo, armiu_rsstgo, armiu_exstgo, armiu_dmstgo, 
               armiu_mestgo, armiu_wrstgo,
               cpsyco )
    variable v    : armiu_reg_type;
    variable t    : armiu_tmp_type;
    variable vdbg : armiu_dbg_type;
  begin 
    
    -- $(init(t:armiu_tmp_type))
    
    v := r;

    t.pstate.hold_r := hold;
    t.pstate.nextinsn_v := armiu_drstgo.nextinsn_v;
    t.pstate.fromEX_cpsr_r := armiu_exstgo.cpsr_r;
    
    t.pstate.fromRR_pctrl_r := armiu_rrstgo.pctrl_r;
    t.pstate.fromRS_pctrl_r := armiu_rsstgo.pctrl_r;
    t.pstate.fromEX_pctrl_r := armiu_exstgo.pctrl_r;
    t.pstate.fromDM_pctrl_r := armiu_dmstgo.pctrl_r;
    t.pstate.fromME_pctrl_r := armiu_mestgo.pctrl_r;
    t.pstate.fromWR_pctrl_r := armiu_wrstgo.pctrl_r;
    
    t.armiu_imstgi.pstate := t.pstate;
    t.armiu_festgi.pstate := t.pstate;
    t.armiu_destgi.pstate := t.pstate;
    t.armiu_drstgi.pstate := t.pstate;
    t.armiu_rrstgi.pstate := t.pstate;
    t.armiu_rsstgi.pstate := t.pstate;
    t.armiu_exstgi.pstate := t.pstate;
    t.armiu_dmstgi.pstate := t.pstate;
    t.armiu_mestgi.pstate := t.pstate;
    t.armiu_wrstgi.pstate := t.pstate;

    -- festg:
    t.armiu_festgi.ico := ico;
    t.armiu_festgi.fromIM_addrphy_v   := armiu_imstgo.toFE_addrphy_v;
    t.armiu_festgi.fromIM_addrvir_v   := armiu_imstgo.toFE_addrvir_v;
    t.armiu_festgi.fromIM_addrvalid_v := armiu_imstgo.toFE_addrvalid_v;
    t.armiu_festgi.fromIM_branch_v    := armiu_imstgo.toFE_branch_v;
    t.armiu_festgi.fromIM_trap_v      := armiu_imstgo.toFE_trap_v;
    t.ici := armiu_festgo.ici;
    
    -- destg:
    t.armiu_destgi.fromFE_insn_v := armiu_festgo.toDE_insn_v;
    t.armiu_destgi.fromFE_insn_r := armiu_festgo.toDE_insn_r;

    -- drstg:
    t.armiu_drstgi.fromDE_insn_v := armiu_destgo.toDR_insn_v;
    t.armiu_drstgi.fromDE_insn_r := armiu_destgo.toDR_insn_r;
    t.armiu_drstgi.fromRR_nextmicro_v := armiu_rrstgo.toDR_nextmicro_v;
    t.armiu_drstgi.fromWR_dabort_v := armiu_wrstgo.toDR_dabort_v;
    
    -- rrstg:
    t.armiu_rrstgi.fromDR_micro_v := armiu_drstgo.toRR_micro_v;
    t.armiu_rrstgi.fromEX_alures_v := armiu_exstgo.alures_v;
    t.armiu_rrstgi.fromWR_rd_v       := armiu_wrstgo.toRR_rd_v;
    t.armiu_rrstgi.fromWR_rd_valid_v := armiu_wrstgo.toRR_rd_valid_v;
    t.armiu_rrstgi.fromWR_rd_data_v  := armiu_wrstgo.toRR_rd_data_v;

    -- rsstg:
    t.armiu_rsstgi.fromRR_pctrl_v := armiu_rrstgo.toRS_pctrl_v;
    t.armiu_rsstgi.fromEX_alures_v := armiu_exstgo.alures_v;
    t.armiu_rsstgi.fromEX_cpsr_v := armiu_exstgo.cpsr_v;

    -- exstg:
    t.armiu_exstgi.fromRS_pctrl_v := armiu_rsstgo.toEX_pctrl_v;
    t.armiu_exstgi.fromWR_spsr_r    := armiu_wrstgo.spsr_r;
    t.armiu_exstgi.fromWR_cpsr_v    := armiu_wrstgo.toEX_cpsr_v;
    t.armiu_exstgi.fromWR_cpsrset_v := armiu_wrstgo.toEX_cpsrset_v;

    -- dmstg:
    t.armiu_dmstgi.fromEX_pctrl_v := armiu_exstgo.toDM_pctrl_v;

    -- mestg:
    t.armiu_mestgi.fromDM_pctrl_v := armiu_dmstgo.toME_pctrl_v;
    t.dci := armiu_mestgo.dci;
    t.armiu_mestgi.irqo := i.irqo;
      
    -- wrstg:
    t.armiu_wrstgi.fromME_pctrl_v := armiu_mestgo.toWR_pctrl_v;
    t.armiu_wrstgi.dco := dco;
    t.o.irqi := armiu_wrstgo.irqi;

-- clear on:
-- exstgtrap    x         x         x         x         x                                                  
-- regbra       x         x         x         x         x                                                  
-- wrbra        x         x         x         x         x         x         x         x                      
-- wrstgtrap    x         x         x         x         x         x         x         x
-- (nextaddr)  (clr)     (clr)     (clr)     (clr)     (clr)     (clr)     (clr)     (clr)
--   +----------+---------+---------+---------+---------+---------+-----+---+---------+---------------+
--   V          V         V         V         V         V         V     |   V         V               |
--  +---------+---------+---------+---------+---------+---------+-------+-+---------+---------+-------+-+
--  |IMSTG    |FESTG    |DESTG    |DRSTG    |RRSTG    |RSSTG    |EXSTG  | |DMSTG    |MESTG    |WRSTG  | |
--  |         |         |         |         |         |         | regbra+ |         |         |  wrbra+ |
--  |         |         |         |tundef-+ |         |         |       | |         |         |       | |
--  |         |   mexc+ |         |tswi  -+ |         |         |       | |         |  tdabrt-+tdabrt-+ |
--  | tprfch+-+-------+-+---------+-------+-+---------+---------+-------+ |         |         |       | |
--  +-------+-+-------+-+---------+-------+-+---------+---------+---------+---------+---------+-------+-+
--   / \    |         |                   V                                                           |   
--    |     |         |        pctrl.trap:+-----------------------------------------------------------+   
--    +-----+---------+-------------------+
--    (idle until wrbra)

    t.armiu_imstgi.flush_v := '0';
    t.armiu_festgi.flush_v := '0';
    t.armiu_destgi.flush_v := '0';
    t.armiu_drstgi.flush_v := '0';
    t.armiu_rrstgi.flush_v := '0';
    t.armiu_rsstgi.flush_v := '0';
    t.armiu_exstgi.flush_v := '0';
    t.armiu_dmstgi.flush_v := '0';
    t.armiu_mestgi.flush_v := '0';

    t.exclear := '0';
    t.wrclear := '0';
    if armiu_exstgo.flush_v = '1' then
      t.exclear := '1';
    end if;
    if armiu_wrstgo.toIM_branch_v = '1' then
      t.wrclear := '1';
    end if;

    -- reset
    if ( rst = '0' ) then
    end if;

    t.drid := armiu_drstgo.id;
    t.rrid := armiu_rrstgo.pctrl_r.insn.id;
    t.rsid := armiu_rsstgo.pctrl_r.insn.id;
    t.exid := armiu_exstgo.pctrl_r.insn.id;
    t.dmid := armiu_dmstgo.pctrl_r.insn.id;
    t.meid := armiu_mestgo.pctrl_r.insn.id;
    t.wrid := armiu_wrstgo.pctrl_r.insn.id;
    
    if t.exclear = '1' or t.wrclear = '1' then
      t.armiu_imstgi.flush_v := '1';
      t.armiu_festgi.flush_v := '1';
      t.armiu_destgi.flush_v := '1';
      if apc_is_flush(t.drid,t.exid) then
        t.armiu_drstgi.flush_v := '1';
      end if;
      if apc_is_flush(t.rrid,t.exid) then
        t.armiu_rrstgi.flush_v := '1';
      end if;
      if apc_is_flush(t.rsid,t.exid) then
        t.armiu_rsstgi.flush_v := '1';
      end if;
    end if;
    if t.wrclear = '1' then
      if apc_is_flush(t.exid,t.wrid) then
        t.armiu_exstgi.flush_v := '1';
      end if;
      if apc_is_flush(t.dmid,t.wrid) then
        t.armiu_dmstgi.flush_v := '1';
      end if;
      if apc_is_flush(t.meid,t.wrid) then
        t.armiu_mestgi.flush_v := '1';
      end if;
    end if;
    
    -- branch address
    t.addrvir := armiu_exstgo.alures_v;
    t.branch := '0';
    if armiu_exstgo.toIM_branch_v = '1' then
      t.addrvir := armiu_exstgo.alures_v;
      t.branch := '1';
    end if;
    if armiu_wrstgo.toIM_branch_v = '1' then
      t.addrvir := armiu_wrstgo.toIM_branchaddr_v;
      t.branch := '1';
    end if;
    t.armiu_imstgi.branch_v := t.branch;
    t.armiu_imstgi.addrvir_v := t.addrvir;


--                                            locking>|<
--  +---------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
--  |IMSTG    |FESTG    |DESTG    |DRSTG    |RRSTG    |RSSTG    |EXSTG    |DMSTG    |MESTG    |WRSTG    |
--  |         |         |         |         |         |         |take     |         |         |         |
--  |         |         |         |[undef]  |         |         |[undef]  |         |         |         |
--  |         |         |         |         |         |         |         |         |         |         |
--  |         |         |[insn]   |         |         |         |         |         |         |         |
--  +---------+---------++--------++--------+-+-------+---------+---------+---------+---------+-------+-+
--                       V         /\         /\                                                      V   
--                      ++--------++--------+-+-------+---------+---------+---------+---------+-------+-+           
--                      |         | ldc/stc | reg/lock|                                       |ldc/mrc| |         
--                      |         | ctrl    | stc/mcr |                                       |[reg] <+ |         
--                      |         | busy    |cpd-lock |                                       |commit   |                 
--                      |         |         |         |                                       |use id   | 
--                      +---------+---------+---------+                                       +---------+           
--                          FE        DEC       EX                                                                   
--                      |<  DRSTG.netxinsn controled >|
--  

    -- todo: check valid, not correct
    t.cpsyci.hold_r := hold;
    -- coprocessor: PR-DESTG -> CP-FESTG
    t.cpsyci.fromPRDE_insn := lmd_convert ( armiu_festgo.toDE_insn_r.insn, CFG_BO_INSN, CFG_BO_PROC );
    t.cpsyci.fromPRDE_valid := armiu_festgo.toDE_insn_r.valid;
    -- PR-DRSTG -> CP-DESTG
    t.cpsyci.fromPRDR_nextinsn_v := armiu_drstgo.nextinsn_v;
    t.cpsyci.fromPRDR_valid := armiu_destgo.toDR_insn_r.insn.valid;
    -- PR-RRSTG -> CP-EXSTG
    t.cpsyci.fromPRRR_valid := armiu_rrstgo.pctrl_r.valid;
    -- PR-WRSTG -> CP-WRSTG
    t.cpsyci.fromPRWR_data_v := armiu_wrstgo.toCPWR_crd_data_v;
    t.cpsyci.fromPRWR_valid := armiu_wrstgo.pctrl_r.valid;
    
    -- PR-DRSTG <- CP-DESTG
    t.armiu_drstgi.fromCPDE_busy := '0';
    t.armiu_drstgi.fromCPDE_last := '1';
    t.armiu_drstgi.fromCPDE_accept := '0';
    case armiu_destgo.toDR_insn_r.insn.insn(ACO_CPNUM_U downto ACO_CPNUM_D) is
      when "1111" =>                    -- sysctrl coprocessor
         -- PR-DRSTG <- CP-DESTG
         t.armiu_drstgi.fromCPDE_busy := cpsyco.CPDE_PRDR.busy;
         t.armiu_drstgi.fromCPDE_last := cpsyco.CPDE_PRDR.last;
         t.armiu_drstgi.fromCPDE_accept := cpsyco.CPDE_PRDR.accept;
      when others => null;
    end case;
    -- PR-RRSTG <- CP-EXSTG
    case armiu_rrstgo.pctrl_r.insn.insn(ACO_CPNUM_U downto ACO_CPNUM_D) is
      when "1111" =>                    -- sysctrl coprocessor
        -- PR-RRSTG <- CP-EXSTG
         t.armiu_rrstgi.fromCPEX_data := cpsyco.CPEX_PRRR.data;
         t.armiu_rrstgi.fromCPEX_lock := cpsyco.CPEX_PRRR.lock;
      when others => null;
    end case;
    
    c <= v;
    
    o <= t.o;
    armiu_imstgi <= t.armiu_imstgi;
    armiu_festgi <= t.armiu_festgi;
    armiu_destgi <= t.armiu_destgi;
    armiu_drstgi <= t.armiu_drstgi;
    armiu_rrstgi <= t.armiu_rrstgi;
    armiu_rsstgi <= t.armiu_rsstgi;
    armiu_exstgi <= t.armiu_exstgi;
    armiu_dmstgi <= t.armiu_dmstgi;
    armiu_mestgi <= t.armiu_mestgi;
    armiu_wrstgi <= t.armiu_wrstgi;
    cpsyci <= t.cpsyci;
    
    ici <= t.ici;
    dci <= t.dci;
    
    -- pragma translate_off
    vdbg := rdbg;
    vdbg.dbg := t;
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

  imstg0:  armiu_imstg port map ( rst, clk, armiu_imstgi, armiu_imstgo);
  festg0:  armiu_festg port map ( rst, clk, armiu_festgi, armiu_festgo);
  destg0:  armiu_destg port map ( rst, clk, armiu_destgi, armiu_destgo);
  drstg0:  armiu_drstg port map ( rst, clk, armiu_drstgi, armiu_drstgo);
  rrstg0:  armiu_rrstg port map ( rst, clk, clkn, armiu_rrstgi, armiu_rrstgo);
  rsstg0:  armiu_rsstg port map ( rst, clk, armiu_rsstgi, armiu_rsstgo);
  exstg0:  armiu_exstg port map ( rst, clk, armiu_exstgi, armiu_exstgo);
  dmstg0:  armiu_dmstg port map ( rst, clk, armiu_dmstgi, armiu_dmstgo);
  mestg0:  armiu_mestg port map ( rst, clk, armiu_mestgi, armiu_mestgo);
  wrstg0:  armiu_wrstg port map ( rst, clk, armiu_wrstgi, armiu_wrstgo);
  
  cpsys0:  armcp_sctrl port map ( rst, clk, cpsyci, cpsyco );

end rtl;
